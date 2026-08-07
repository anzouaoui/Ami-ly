const { test } = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('crypto');

const {
  COMPLETED_STATUS,
  parseWebhookBody,
  verifyConnectSignature,
  signedPdfStoragePath,
  storeSignedPdf,
  markContractSigned,
  processCompletedEnvelope,
  handleDocusignWebhook,
} = require('../signed-documents');

// ─── Fakes ─────────────────────────────────────────────────────────────────────

const TS = '__serverTimestamp__';

function fakeFieldValue() {
  return { serverTimestamp: () => TS };
}

function fakeBucket() {
  const saved = [];
  const urls = new Map();
  const bucket = {
    file(path) {
      return {
        save: async (content, opts) => {
          saved.push({ path, content, opts });
          urls.set(
            path,
            `https://firebasestorage.googleapis.com/v0/b/test.appspot.com/o/${encodeURIComponent(
              path
            )}?alt=media&token=fake`
          );
        },
        getDownloadURL: async () => urls.get(path),
      };
    },
  };
  bucket.__saved = saved;
  return bucket;
}

function fakeDb(contracts) {
  const updated = [];
  return {
    collection(name) {
      return {
        doc(id) {
          return {
            update: async (payload) => {
              updated.push({ id, payload });
            },
          };
        },
        where(field, op, value) {
          return {
            limit() {
              return {
                get: async () => {
                  const docs = contracts.filter((c) => c.data[field] === value);
                  return {
                    empty: docs.length === 0,
                    docs: docs.map((c) => ({ id: c.id, data: () => c.data })),
                  };
                },
              };
            },
          };
        },
      };
    },
    __updated: updated,
  };
}

function fakeEnvelopesApi(pdfBuffer) {
  const calls = [];
  return {
    __calls: calls,
    getDocument: async (accountId, envelopeId, documentId) => {
      calls.push({ accountId, envelopeId, documentId });
      return pdfBuffer;
    },
  };
}

function makeHmacPayload(body, hmacKey) {
  const rawBody = Buffer.from(JSON.stringify(body));
  const signature = crypto
    .createHmac('sha256', Buffer.from(hmacKey, 'base64'))
    .update(rawBody)
    .digest('base64');
  return { rawBody, signature };
}

// ─── parseWebhookBody ──────────────────────────────────────────────────────────

test('parseWebhookBody — format envelopeSummary', () => {
  const { envelopeId, status } = parseWebhookBody({
    envelopeSummary: { envelopeId: 'env-1', status: 'completed' },
  });
  assert.equal(envelopeId, 'env-1');
  assert.equal(status, 'completed');
});

test('parseWebhookBody — format plat', () => {
  const { envelopeId, status } = parseWebhookBody({
    envelopeId: 'env-2',
    status: 'declined',
  });
  assert.equal(envelopeId, 'env-2');
  assert.equal(status, 'declined');
});

test('parseWebhookBody — corps vide', () => {
  const { envelopeId, status } = parseWebhookBody();
  assert.equal(envelopeId, undefined);
  assert.equal(status, undefined);
});

// ─── verifyConnectSignature ────────────────────────────────────────────────────

test('verifyConnectSignature — désactivé sans clé', () => {
  const result = verifyConnectSignature({
    rawBody: Buffer.from('body'),
    signatureHeader: 'whatever',
    hmacKey: undefined,
  });
  assert.equal(result.valid, true);
  assert.equal(result.reason, 'hmac_disabled');
});

test('verifyConnectSignature — rejette un en-tête manquant', () => {
  const result = verifyConnectSignature({
    rawBody: Buffer.from('body'),
    signatureHeader: undefined,
    hmacKey: Buffer.from('key').toString('base64'),
  });
  assert.equal(result.valid, false);
  assert.equal(result.reason, 'missing_signature_header');
});

test('verifyConnectSignature — rejette une signature incorrecte', () => {
  const hmacKey = crypto.randomBytes(32).toString('base64');
  const body = { envelopeId: 'env-1', status: 'completed' };
  const { rawBody } = makeHmacPayload(body, hmacKey);
  const result = verifyConnectSignature({
    rawBody,
    signatureHeader: 'aW52YWxpZA==',
    hmacKey,
  });
  assert.equal(result.valid, false);
  assert.equal(result.reason, 'signature_mismatch');
});

test('verifyConnectSignature — accepte une signature valide', () => {
  const hmacKey = crypto.randomBytes(32).toString('base64');
  const body = { envelopeId: 'env-1', status: 'completed' };
  const { rawBody, signature } = makeHmacPayload(body, hmacKey);
  const result = verifyConnectSignature({
    rawBody,
    signatureHeader: signature,
    hmacKey,
  });
  assert.equal(result.valid, true);
});

// ─── signedPdfStoragePath ──────────────────────────────────────────────────────

test('signedPdfStoragePath — dossier propre au contrat', () => {
  assert.equal(
    signedPdfStoragePath('contract-42'),
    'contracts/contract-42/contrat_finalise.pdf'
  );
});

// ─── storeSignedPdf ────────────────────────────────────────────────────────────

test('storeSignedPdf — enregistre le PDF et renvoie chemin + URL', async () => {
  const bucket = fakeBucket();
  const pdfBuffer = Buffer.from('%PDF-1.7 fake');
  const { finalPdfPath, finalPdfUrl } = await storeSignedPdf({
    bucket,
    contractId: 'contract-42',
    pdfBuffer,
  });

  assert.equal(finalPdfPath, 'contracts/contract-42/contrat_finalise.pdf');
  assert.ok(finalPdfUrl.includes('alt=media&token=fake'));
  assert.ok(
    finalPdfUrl.includes(
      'contracts%2Fcontract-42%2Fcontrat_finalise.pdf'
    )
  );
  assert.equal(bucket.__saved.length, 1);
  assert.equal(bucket.__saved[0].path, 'contracts/contract-42/contrat_finalise.pdf');
  assert.equal(bucket.__saved[0].opts.metadata.contentType, 'application/pdf');
  assert.deepEqual(bucket.__saved[0].content, pdfBuffer);
});

// ─── markContractSigned ────────────────────────────────────────────────────────

test('markContractSigned — statut signed + URL + métadonnées', async () => {
  const db = fakeDb([]);
  await markContractSigned({
    db,
    contractId: 'contract-42',
    envelopeId: 'env-1',
    finalPdfPath: 'contracts/contract-42/contrat_finalise.pdf',
    finalPdfUrl: 'https://storage/contrat_finalise.pdf',
    nowIso: '2026-08-06T10:00:00.000Z',
    fieldValue: fakeFieldValue(),
  });

  assert.equal(db.__updated.length, 1);
  const { id, payload } = db.__updated[0];
  assert.equal(id, 'contract-42');
  assert.equal(payload.status, 'signed');
  assert.equal(payload.docusignStatus, COMPLETED_STATUS);
  assert.equal(payload.docusignEnvelopeId, 'env-1');
  assert.equal(payload.docusignSignedAt, TS);
  assert.equal(payload.parentSignedAt, TS);
  assert.equal(payload.assmatSignedAt, TS);
  assert.equal(payload.finalizedAt, '2026-08-06T10:00:00.000Z');
  assert.equal(payload.finalPdfPath, 'contracts/contract-42/contrat_finalise.pdf');
  assert.equal(payload.finalPdfUrl, 'https://storage/contrat_finalise.pdf');
});

// ─── processCompletedEnvelope ──────────────────────────────────────────────────

test('processCompletedEnvelope — télécharge, stocke et enregistre le PDF signé', async () => {
  const db = fakeDb([
    { id: 'contract-42', data: { docusignEnvelopeId: 'env-1' } },
  ]);
  const bucket = fakeBucket();
  const envelopesApi = fakeEnvelopesApi(Buffer.from('%PDF-1.7 combined'));

  const result = await processCompletedEnvelope({
    db,
    bucket,
    getEnvelopesApi: async () => envelopesApi,
    accountId: 'account-1',
    envelopeId: 'env-1',
    fieldValue: fakeFieldValue(),
  });

  assert.equal(result.outcome, 'signed');
  assert.equal(result.contractId, 'contract-42');
  assert.equal(result.finalPdfPath, 'contracts/contract-42/contrat_finalise.pdf');

  assert.equal(envelopesApi.__calls.length, 1);
  assert.equal(envelopesApi.__calls[0].envelopeId, 'env-1');
  assert.equal(envelopesApi.__calls[0].documentId, 'combined');

  assert.equal(bucket.__saved.length, 1);
  assert.equal(bucket.__saved[0].path, 'contracts/contract-42/contrat_finalise.pdf');

  const update = db.__updated[0].payload;
  assert.equal(update.status, 'signed');
  assert.ok(update.finalPdfUrl.includes('alt=media&token=fake'));
  assert.equal(update.docusignEnvelopeId, 'env-1');
});

test('processCompletedEnvelope — idempotent si le PDF est déjà stocké', async () => {
  const db = fakeDb([
    {
      id: 'contract-42',
      data: {
        docusignEnvelopeId: 'env-1',
        finalPdfUrl: 'https://storage/déjà-stocké',
      },
    },
  ]);
  const bucket = fakeBucket();
  let apiCalls = 0;
  const getEnvelopesApi = async () => {
    apiCalls++;
    return fakeEnvelopesApi(Buffer.from('pdf'));
  };

  const result = await processCompletedEnvelope({
    db,
    bucket,
    getEnvelopesApi,
    accountId: 'account-1',
    envelopeId: 'env-1',
    fieldValue: fakeFieldValue(),
  });

  assert.equal(result.outcome, 'already_finalized');
  assert.equal(apiCalls, 0);
  assert.equal(bucket.__saved.length, 0);
});

test('processCompletedEnvelope — contrat introuvable', async () => {
  const db = fakeDb([]);
  const result = await processCompletedEnvelope({
    db,
    bucket: fakeBucket(),
    getEnvelopesApi: async () => fakeEnvelopesApi(Buffer.from('pdf')),
    accountId: 'account-1',
    envelopeId: 'env-inconnu',
    fieldValue: fakeFieldValue(),
  });
  assert.equal(result.outcome, 'contract_not_found');
});

// ─── handleDocusignWebhook ─────────────────────────────────────────────────────

function webhookDeps(contracts) {
  return {
    hmacKey: undefined,
    db: fakeDb(contracts),
    bucket: fakeBucket(),
    getEnvelopesApi: async () =>
      fakeEnvelopesApi(Buffer.from('%PDF-1.7 combined')),
    accountId: 'account-1',
    fieldValue: fakeFieldValue(),
  };
}

test('handleDocusignWebhook — completed → 200 et contrat signé', async () => {
  const deps = webhookDeps([
    { id: 'contract-42', data: { docusignEnvelopeId: 'env-1' } },
  ]);
  const result = await handleDocusignWebhook({
    rawBody: Buffer.from('{}'),
    body: { envelopeSummary: { envelopeId: 'env-1', status: 'completed' } },
    signatureHeader: undefined,
    deps,
  });

  assert.equal(result.status, 200);
  assert.equal(result.body, 'OK');
  assert.equal(deps.db.__updated[0].payload.status, 'signed');
});

test('handleDocusignWebhook — statut en majuscules accepté', async () => {
  const deps = webhookDeps([
    { id: 'contract-42', data: { docusignEnvelopeId: 'env-1' } },
  ]);
  const result = await handleDocusignWebhook({
    rawBody: Buffer.from('{}'),
    body: { envelopeSummary: { envelopeId: 'env-1', status: 'Completed' } },
    signatureHeader: undefined,
    deps,
  });

  assert.equal(result.status, 200);
  assert.equal(deps.db.__updated[0].payload.status, 'signed');
  assert.equal(deps.db.__updated[0].payload.docusignStatus, 'completed');
});

test('handleDocusignWebhook — declined → mise à jour du statut seulement', async () => {
  const deps = webhookDeps([
    { id: 'contract-42', data: { docusignEnvelopeId: 'env-1' } },
  ]);
  const result = await handleDocusignWebhook({
    rawBody: Buffer.from('{}'),
    body: { envelopeSummary: { envelopeId: 'env-1', status: 'declined' } },
    signatureHeader: undefined,
    deps,
  });

  assert.equal(result.status, 200);
  const update = deps.db.__updated[0].payload;
  assert.equal(update.docusignStatus, 'declined');
  assert.equal(update.docusignDeclinedAt, TS);
  assert.equal(update.status, undefined);
});

test('handleDocusignWebhook — HMAC invalide → 400', async () => {
  const hmacKey = crypto.randomBytes(32).toString('base64');
  const deps = webhookDeps([]);
  deps.hmacKey = hmacKey;

  const result = await handleDocusignWebhook({
    rawBody: Buffer.from('{}'),
    body: { envelopeId: 'env-1', status: 'completed' },
    signatureHeader: 'aW52YWxpZA==',
    deps,
  });

  assert.equal(result.status, 400);
  assert.equal(result.body, 'Signature invalide');
});

test('handleDocusignWebhook — HMAC valide → 200', async () => {
  const hmacKey = crypto.randomBytes(32).toString('base64');
  const body = { envelopeId: 'env-1', status: 'completed' };
  const { rawBody, signature } = makeHmacPayload(body, hmacKey);

  const deps = webhookDeps([
    { id: 'contract-42', data: { docusignEnvelopeId: 'env-1' } },
  ]);
  deps.hmacKey = hmacKey;

  const result = await handleDocusignWebhook({
    rawBody,
    body,
    signatureHeader: signature,
    deps,
  });

  assert.equal(result.status, 200);
  assert.equal(deps.db.__updated[0].payload.status, 'signed');
});

test('handleDocusignWebhook — corps incomplet → 400', async () => {
  const deps = webhookDeps([]);
  const result = await handleDocusignWebhook({
    rawBody: Buffer.from('{}'),
    body: { envelopeSummary: {} },
    signatureHeader: undefined,
    deps,
  });
  assert.equal(result.status, 400);
  assert.equal(result.body, 'Données incomplètes');
});

test('handleDocusignWebhook — contrat introuvable → 404', async () => {
  const deps = webhookDeps([]);
  const result = await handleDocusignWebhook({
    rawBody: Buffer.from('{}'),
    body: { envelopeId: 'env-inconnu', status: 'completed' },
    signatureHeader: undefined,
    deps,
  });
  assert.equal(result.status, 404);
  assert.equal(result.body, 'Contrat non trouvé');
});
