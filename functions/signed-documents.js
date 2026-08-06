/**
 * Traitement des documents signés DocuSign.
 *
 * Ce module centralise la logique métier déclenchée par les notifications
 * DocuSign Connect (webhook) lorsque l'enveloppe est complétée — c'est-à-dire
 * lorsque le parent ET l'assistante maternelle ont finalisé leur signature :
 *
 *   1. lecture de l'enveloppe (envelopeId) depuis le corps du webhook ;
 *   2. vérification de la signature HMAC DocuSign Connect (si la clé est
 *      configurée via DOCUSIGN_CONNECT_HMAC_KEY) ;
 *   3. téléchargement du document combiné signé (combined) via l'API DocuSign ;
 *   4. stockage sécurisé du PDF dans Cloud Storage sous le dossier du contrat ;
 *   5. mise à jour du contrat en Firestore : statut `signed`, URL de
 *      téléchargement et métadonnées (id d'enveloppe, horodatage).
 *
 * Toutes les fonctions sont injectables (db, bucket, envelopesApi, fieldValue)
 * afin d'être testables unitairement sans émulateur.
 */

const crypto = require('crypto');

const SIGNED_PDF_FILENAME = 'contrat_finalise.pdf';
const COMPLETED_STATUS = 'completed';

/**
 * Extrait l'id d'enveloppe et le statut depuis le corps du webhook
 * DocuSign Connect (formats « envelopeSummary », « fields » et plat).
 *
 * @param {Record<string, any>} body
 * @returns {{ envelopeId?: string, status?: string }}
 */
function parseWebhookBody(body = {}) {
  const summary = body.envelopeSummary;
  if (summary && typeof summary === 'object') {
    return {
      envelopeId: summary.envelopeId,
      status: summary.status,
    };
  }
  return {
    envelopeId: body.envelopeId,
    status: body.status,
  };
}

/**
 * Vérifie la signature HMAC-SHA256 DocuSign Connect.
 *
 * Si `hmacKey` n'est pas fourni, la vérification est désactivée (environnement
 * de développement). La clé est la valeur base64 générée par DocuSign Connect,
 * la signature est envoyée dans l'en-tête `X-DocuSign-Signature-1`.
 *
 * @param {{ rawBody?: Buffer, signatureHeader?: string, hmacKey?: string }} params
 * @returns {{ valid: boolean, reason: string }}
 */
function verifyConnectSignature({ rawBody, signatureHeader, hmacKey }) {
  if (!hmacKey) return { valid: true, reason: 'hmac_disabled' };
  if (!signatureHeader) return { valid: false, reason: 'missing_signature_header' };
  if (!rawBody || rawBody.length === 0) return { valid: false, reason: 'missing_body' };

  const secret = Buffer.from(hmacKey, 'base64');
  const digest = crypto
    .createHmac('sha256', secret)
    .update(rawBody)
    .digest('base64');

  const expected = Buffer.from(digest, 'utf8');
  const provided = Buffer.from(signatureHeader, 'utf8');
  if (expected.length !== provided.length) {
    return { valid: false, reason: 'signature_mismatch' };
  }

  return {
    valid: crypto.timingSafeEqual(expected, provided),
    reason: 'signature_mismatch',
  };
}

/**
 * Chemin de stockage (Cloud Storage) du PDF final signé d'un contrat.
 *
 * @param {string} contractId
 * @returns {string} `contracts/{contractId}/contrat_finalise.pdf`
 */
function signedPdfStoragePath(contractId) {
  return `contracts/${contractId}/${SIGNED_PDF_FILENAME}`;
}

/**
 * Télécharge le document combiné signé (toutes les pièces + certificat)
 * depuis l'API DocuSign.
 *
 * @param {{ envelopesApi: { getDocument: Function }, accountId: string, envelopeId: string }} params
 * @returns {Promise<Buffer>}
 */
async function downloadCombinedDocument({ envelopesApi, accountId, envelopeId }) {
  return envelopesApi.getDocument(accountId, envelopeId, 'combined');
}

/**
 * Stocke le PDF signé dans Cloud Storage sous le dossier du contrat et
 * retourne son chemin et son URL de téléchargement (lien de téléchargement
 * Firebase, sans expiration, protégé par storage.rules).
 *
 * @param {{ bucket: { file: Function }, contractId: string, pdfBuffer: Buffer }} params
 * @returns {Promise<{ finalPdfPath: string, finalPdfUrl: string }>}
 */
async function storeSignedPdf({ bucket, contractId, pdfBuffer }) {
  const finalPdfPath = signedPdfStoragePath(contractId);
  const file = bucket.file(finalPdfPath);
  await file.save(pdfBuffer, {
    metadata: { contentType: 'application/pdf' },
  });
  const finalPdfUrl = await file.getDownloadURL();
  return { finalPdfPath, finalPdfUrl };
}

/**
 * Met à jour l'entrée du contrat : statut final `signed`, URL de
 * téléchargement et métadonnées (id d'enveloppe, horodatage de finalisation).
 *
 * @param {{ db: { collection: Function }, contractId: string, envelopeId: string, finalPdfPath: string, finalPdfUrl: string, nowIso: string, fieldValue: { serverTimestamp: Function } }} params
 * @returns {Promise<void>}
 */
async function markContractSigned({
  db,
  contractId,
  envelopeId,
  finalPdfPath,
  finalPdfUrl,
  nowIso,
  fieldValue,
}) {
  await db.collection('contracts').doc(contractId).update({
    status: 'signed',
    docusignStatus: COMPLETED_STATUS,
    docusignEnvelopeId: envelopeId,
    docusignSignedAt: fieldValue.serverTimestamp(),
    finalizedAt: nowIso,
    updatedAt: nowIso,
    parentSignedAt: fieldValue.serverTimestamp(),
    assmatSignedAt: fieldValue.serverTimestamp(),
    finalPdfPath,
    finalPdfUrl,
  });
}

/**
 * Traite la finalisation d'une enveloppe signée : télécharge le PDF combiné,
 * le stocke et met à jour Firestore. Idempotent : si le PDF final est déjà
 * enregistré, on ne relance pas le téléchargement.
 *
 * @param {{ db: { collection: Function }, bucket: { file: Function }, getEnvelopesApi: Function, accountId: string, envelopeId: string, fieldValue: { serverTimestamp: Function } }} params
 * @returns {Promise<{ outcome: string, contractId?: string, finalPdfPath?: string }>}
 */
async function processCompletedEnvelope({
  db,
  bucket,
  getEnvelopesApi,
  accountId,
  envelopeId,
  fieldValue,
}) {
  const snapshot = await db
    .collection('contracts')
    .where('docusignEnvelopeId', '==', envelopeId)
    .limit(1)
    .get();

  if (snapshot.empty) {
    return { outcome: 'contract_not_found' };
  }

  const contractDoc = snapshot.docs[0];
  const contractId = contractDoc.id;
  const data = contractDoc.data();

  if (data && data.finalPdfUrl) {
    await db.collection('contracts').doc(contractId).update({
      docusignStatus: COMPLETED_STATUS,
      docusignSignedAt: fieldValue.serverTimestamp(),
    });
    return { outcome: 'already_finalized', contractId };
  }

  const envelopesApi = await getEnvelopesApi();
  const pdfBuffer = await downloadCombinedDocument({
    envelopesApi,
    accountId,
    envelopeId,
  });

  const { finalPdfPath, finalPdfUrl } = await storeSignedPdf({
    bucket,
    contractId,
    pdfBuffer,
  });

  await markContractSigned({
    db,
    contractId,
    envelopeId,
    finalPdfPath,
    finalPdfUrl,
    nowIso: new Date().toISOString(),
    fieldValue,
  });

  return { outcome: 'signed', contractId, finalPdfPath };
}

/**
 * Handler HTTP du webhook DocUuSign Connect (logique pure, testable).
 *
 * @param {{ rawBody?: Buffer, body?: Record<string, any>, signatureHeader?: string, deps: { hmacKey?: string, db: any, bucket: any, getEnvelopesApi: Function, accountId: string, fieldValue: { serverTimestamp: Function } } }} params
 * @returns {Promise<{ status: number, body: string }>}
 */
async function handleDocusignWebhook({ rawBody, body, signatureHeader, deps }) {
  const verification = verifyConnectSignature({
    rawBody,
    signatureHeader,
    hmacKey: deps.hmacKey,
  });
  if (!verification.valid) {
    console.error('[docusignWebhook] Signature HMAC invalide:', verification.reason);
    return { status: 400, body: 'Signature invalide' };
  }

  const { envelopeId, status } = parseWebhookBody(body);
  if (!envelopeId || !status) {
    return { status: 400, body: 'Données incomplètes' };
  }

  const normalizedStatus = String(status).toLowerCase();

  if (normalizedStatus === COMPLETED_STATUS) {
    try {
      const result = await processCompletedEnvelope({
        db: deps.db,
        bucket: deps.bucket,
        getEnvelopesApi: deps.getEnvelopesApi,
        accountId: deps.accountId,
        envelopeId,
        fieldValue: deps.fieldValue,
      });

      if (result.outcome === 'contract_not_found') {
        return { status: 404, body: 'Contrat non trouvé' };
      }
      console.log(
        `[docusignWebhook] Enveloppe ${envelopeId} → ${result.outcome} (${result.contractId})`
      );
      return { status: 200, body: 'OK' };
    } catch (err) {
      // 500 → DocUuSign Connect rejoue le webhook plus tard.
      console.error('Erreur traitement enveloppe signée:', err);
      return { status: 500, body: 'Erreur interne' };
    }
  }

  // Autres statuts (sent, delivered, declined, voided, ...) : on met
  // simplement à jour le statut DocUuSign côté contrat.
  try {
    const snapshot = await deps.db
      .collection('contracts')
      .where('docusignEnvelopeId', '==', envelopeId)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return { status: 404, body: 'Contrat non trouvé' };
    }

    const contractId = snapshot.docs[0].id;
    const update = {
      docusignStatus: normalizedStatus,
      docusignUpdatedAt: deps.fieldValue.serverTimestamp(),
    };
    if (normalizedStatus === 'declined' || normalizedStatus === 'voided') {
      update.docusignDeclinedAt = deps.fieldValue.serverTimestamp();
    }
    await deps.db.collection('contracts').doc(contractId).update(update);

    return { status: 200, body: 'OK' };
  } catch (err) {
    console.error('Erreur webhook DocuSign:', err);
    return { status: 500, body: 'Erreur interne' };
  }
}

module.exports = {
  COMPLETED_STATUS,
  SIGNED_PDF_FILENAME,
  parseWebhookBody,
  verifyConnectSignature,
  signedPdfStoragePath,
  downloadCombinedDocument,
  storeSignedPdf,
  markContractSigned,
  processCompletedEnvelope,
  handleDocusignWebhook,
};
