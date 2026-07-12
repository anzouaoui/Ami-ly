const functions = require('firebase-functions/v2/https');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const docusign = require('docusign-esign');

admin.initializeApp();

const CFG = {
  integration_key: process.env.DOCUSIGN_INTEGRATION_KEY,
  user_id: process.env.DOCUSIGN_USER_ID,
  account_id: process.env.DOCUSIGN_ACCOUNT_ID,
  private_key: process.env.DOCUSIGN_PRIVATE_KEY,
  base_path: process.env.DOCUSIGN_BASE_PATH || 'https://demo.docusign.net',
  base_url: process.env.DOCUSIGN_BASE_URL,
};

function getApiClient() {
  const apiClient = new docusign.ApiClient();
  apiClient.setBasePath(CFG.base_path + '/restapi');
  return apiClient;
}

async function getJwtToken(apiClient) {
  const scopes = ['signature', 'impersonation'];
  const token = apiClient.requestJWTUserToken(
    CFG.integration_key,
    CFG.user_id,
    scopes,
    Buffer.from(CFG.private_key, 'utf8'),
    3600
  );
  return token;
}

async function getApiClientWithToken() {
  const apiClient = getApiClient();
  const token = await getJwtToken(apiClient);
  apiClient.addDefaultHeader('Authorization', `Bearer ${token.body.access_token}`);
  return apiClient;
}

exports.createEnvelope = functions.onCall(async (request) => {
  const { contractId, pdfUrl } = request.data;
  if (!contractId || !pdfUrl) {
    throw new functions.HttpsError('invalid-argument', 'contractId et pdfUrl requis');
  }

  const db = admin.firestore();

  console.log('[createEnvelope] contractId:', contractId, 'pdfUrl.length:', pdfUrl?.length);

  const contractDoc = await db.collection('contracts').doc(contractId).get();
  if (!contractDoc.exists) {
    throw new functions.HttpsError('not-found', 'Contrat introuvable');
  }
  const contract = contractDoc.data();
  console.log('[createEnvelope] parentUid:', contract.parentUid, 'assmatUid:', contract.assmatUid);

  const [parentDoc, assmatDoc] = await Promise.all([
    db.collection('users').doc(contract.parentUid).get(),
    db.collection('users').doc(contract.assmatUid).get(),
  ]);
  if (!parentDoc.exists || !assmatDoc.exists) {
    console.error('[createEnvelope] Utilisateur introuvable: parentExists:', parentDoc.exists, 'assmatExists:', assmatDoc.exists);
    throw new functions.HttpsError('not-found', 'Utilisateur introuvable');
  }
  const parent = parentDoc.data();
  const assmat = assmatDoc.data();
  console.log('[createEnvelope] parent email:', parent.email, 'displayName:', parent.displayName);
  console.log('[createEnvelope] assmat email:', assmat.email, 'displayName:', assmat.displayName);

  const storage = admin.storage();
  const bucket = storage.bucket();
  console.log('[createEnvelope] parsing pdfUrl:', pdfUrl);
  const urlObj = new URL(pdfUrl);
  const objectPath = decodeURIComponent(urlObj.pathname.split('/o/')[1] || '');
  console.log('[createEnvelope] objectPath:', objectPath);
  const file = bucket.file(objectPath);
  const [pdfBuffer] = await file.download();
  console.log('[createEnvelope] PDF downloaded, size:', pdfBuffer.length);

  const apiClient = await getApiClientWithToken();
  const envelopesApi = new docusign.EnvelopesApi(apiClient);
  console.log('[createEnvelope] DocuSign JWT OK');

  const docPdf = docusign.Document.constructFromObject({
    documentBase64: pdfBuffer.toString('base64'),
    name: 'Contrat',
    fileExtension: 'pdf',
    documentId: '1',
  });

  const parentSigner = docusign.Signer.constructFromObject({
    email: parent.email,
    name: parent.displayName || `${parent.firstName ?? ''} ${parent.lastName ?? ''}`.trim() || 'Parent',
    recipientId: '1',
    routingOrder: '1',
    clientUserId: contract.parentUid,
  });
  console.log('[createEnvelope] parentSigner name:', parentSigner.name);

  const assmatSigner = docusign.Signer.constructFromObject({
    email: assmat.email,
    name: assmat.displayName || `${assmat.firstName ?? ''} ${assmat.lastName ?? ''}`.trim() || 'Assistant(e) maternel(le)',
    recipientId: '2',
    routingOrder: '2',
    clientUserId: contract.assmatUid,
  });
  console.log('[createEnvelope] assmatSigner name:', assmatSigner.name);

  const signHere1 = docusign.SignHere.constructFromObject({
    documentId: '1',
    pageNumber: '1',
    recipientId: '1',
    tabLabel: 'SignatureParent',
    xPosition: '100',
    yPosition: '700',
  });

  const signHere2 = docusign.SignHere.constructFromObject({
    documentId: '1',
    pageNumber: '1',
    recipientId: '2',
    tabLabel: 'SignatureAssmat',
    xPosition: '100',
    yPosition: '750',
  });

  parentSigner.tabs = docusign.Tabs.constructFromObject({
    signHereTabs: [signHere1],
  });
  assmatSigner.tabs = docusign.Tabs.constructFromObject({
    signHereTabs: [signHere2],
  });

  const envelopeDefinition = docusign.EnvelopeDefinition.constructFromObject({
    emailSubject: 'Signature de contrat - Ami-ly',
    documents: [docPdf],
    recipients: docusign.Recipients.constructFromObject({
      signers: [parentSigner, assmatSigner],
    }),
    status: 'sent',
    eventNotification: {
      url: `${CFG.base_url ?? ''}/docusignWebhook`,
      loggingEnabled: true,
      envelopeEvents: [
        { envelopeEventStatusCode: 'completed' },
        { envelopeEventStatusCode: 'declined' },
        { envelopeEventStatusCode: 'voided' },
      ],
      recipientEvents: [
        { recipientEventStatusCode: 'Completed' },
      ],
    },
  });

  console.log('[createEnvelope] calling DocuSign API createEnvelope...');
  const results = await envelopesApi.createEnvelope(CFG.account_id, {
    envelopeDefinition: envelopeDefinition,
  });
  const envelopeId = results.envelopeId;
  console.log('[createEnvelope] envelope created:', envelopeId);

  await db.collection('contracts').doc(contractId).update({
    docusignEnvelopeId: envelopeId,
    docusignStatus: 'sent',
    docusignUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log('[createEnvelope] Firestore updated');

  return { envelopeId };
});

exports.getRecipientViewUrl = functions.onCall(async (request) => {
  const { contractId, userId } = request.data;
  if (!contractId || !userId) {
    throw new functions.HttpsError('invalid-argument', 'contractId et userId requis');
  }

  const db = admin.firestore();
  const contractDoc = await db.collection('contracts').doc(contractId).get();
  if (!contractDoc.exists) {
    throw new functions.HttpsError('not-found', 'Contrat introuvable');
  }
  const contract = contractDoc.data();
  const envelopeId = contract.docusignEnvelopeId;
  if (!envelopeId) {
    throw new functions.HttpsError('failed-precondition', 'Enveloppe DocuSign pas encore créée');
  }

  const apiClient = await getApiClientWithToken();
  const envelopesApi = new docusign.EnvelopesApi(apiClient);

  const role = userId === contract.parentUid ? 'parent' : 'assmat';
  const recipientId = role === 'parent' ? '1' : '2';
  const userDoc = await db.collection('users').doc(userId).get();
  const user = userDoc.data();

  const viewRequest = docusign.RecipientViewRequest.constructFromObject({
    authenticationMethod: 'none',
    clientUserId: userId,
    email: user.email,
    recipientId: recipientId,
    userName: user.displayName || `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim() || 'Utilisateur',
    returnUrl: `${CFG.base_url ?? ''}/docusignCallback?contractId=${contractId}&userId=${userId}`,
  });

  const results = await envelopesApi.createRecipientView(
    CFG.account_id,
    envelopeId,
    { recipientViewRequest: viewRequest },
  );

  return { signingUrl: results.url };
});

exports.docusignWebhook = functions.onRequest(async (req, res) => {
  try {
    const body = req.body;

    let envelopeId, status;
    if (body.envelopeSummary) {
      envelopeId = body.envelopeSummary.envelopeId;
      status = body.envelopeSummary.status;
    } else if (body.fields) {
      envelopeId = body.envelopeId;
      status = body.status;
    }

    if (!envelopeId || !status) {
      res.status(400).send('Données incomplètes');
      return;
    }

    const db = admin.firestore();
    const snapshot = await db
      .collection('contracts')
      .where('docusignEnvelopeId', '==', envelopeId)
      .get();

    if (snapshot.empty) {
      res.status(404).send('Contrat non trouvé');
      return;
    }

    const contractDoc = snapshot.docs[0];
    const contractId = contractDoc.id;

    await db.collection('contracts').doc(contractId).update({
      docusignStatus: status,
      docusignUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (status === 'completed') {
      const now = new Date().toISOString();
      await db.collection('contracts').doc(contractId).update({
        status: 'active',
        parentSignedAt: admin.firestore.FieldValue.serverTimestamp(),
        assmatSignedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: now,
      });

      try {
        const apiClient = await getApiClientWithToken();
        const envelopesApi = new docusign.EnvelopesApi(apiClient);
        const signedDoc = await envelopesApi.getDocument(
          CFG.account_id,
          envelopeId,
          'combined',
        );
        const bucket = admin.storage().bucket();
        const destPath = `contracts/${contractId}/contrat_finalise.pdf`;
        const file = bucket.file(destPath);
        await file.save(signedDoc, {
          metadata: { contentType: 'application/pdf' },
        });
        const [pdfUrl] = await file.getSignedUrl({
          action: 'read',
          expires: '01-01-2999',
        });

        await db.collection('contracts').doc(contractId).update({
          finalPdfUrl: pdfUrl,
          finalizedAt: now,
        });
      } catch (err) {
        console.error('Erreur téléchargement PDF signé:', err);
      }
    }

    res.status(200).send('OK');
  } catch (err) {
    console.error('Erreur webhook:', err);
    res.status(500).send('Erreur interne');
  }
});

exports.docusignCallback = functions.onRequest(async (req, res) => {
  const { contractId, userId, event } = req.query;
  const db = admin.firestore();

  if (event === 'signing_complete') {
    await db.collection('contracts').doc(contractId).update({
      [userId === req.query.userId ? 'parentSignedAt' : 'assmatSignedAt']:
        admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  const deepLink = `amily://signature-callback?contractId=${contractId}&event=${event ?? 'unknown'}`;
  res.redirect(deepLink);
});

exports.onNotificationCreated = onDocumentCreated('notifications/{notificationId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log('No data associated with the event');
    return;
  }
  
  const notification = snapshot.data();
  const recipientUid = notification.recipientUid;
  
  if (!recipientUid) {
    console.log('No recipientUid found in notification');
    return;
  }

  const db = admin.firestore();
  const userDoc = await db.collection('users').doc(recipientUid).get();
  
  if (!userDoc.exists) {
    console.log('User not found:', recipientUid);
    return;
  }

  const user = userDoc.data();
  const tokens = user.fcmTokens || [];

  if (tokens.length === 0) {
    console.log('No FCM tokens for user:', recipientUid);
    return;
  }

  // Compter les notifications non lues pour le badge iOS
  const unreadSnapshot = await db
    .collection('notifications')
    .where('recipientUid', '==', recipientUid)
    .where('read', '==', false)
    .count()
    .get();
  const unreadCount = unreadSnapshot.data().count;

  const payload = {
    notification: {
      title: notification.title || 'Nouvelle notification',
      body: notification.body || '',
    },
    android: {
      notification: {
        channelId: 'amily_high_importance_channel',
        priority: 'high',
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: unreadCount,
        },
      },
    },
    data: {
      type: notification.type || 'unknown',
      id: snapshot.id,
      contractId: notification.contractId || '',
      conversationId: notification.conversationId || '',
    }
  };

  try {
    const response = await admin.messaging().sendEachForMulticast({
      tokens: tokens,
      notification: payload.notification,
      android: payload.android,
      apns: payload.apns,
      data: payload.data,
    });
    
    console.log(`Successfully sent message. Success count: ${response.successCount}, Failure count: ${response.failureCount}`);
    
    if (response.failureCount > 0) {
      const failedTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
        }
      });
      if (failedTokens.length > 0) {
        await userDoc.ref.update({
          fcmTokens: admin.firestore.FieldValue.arrayRemove(...failedTokens)
        });
        console.log('Removed failed tokens:', failedTokens);
      }
    }
  } catch (error) {
    console.error('Error sending push notification:', error);
  }
});

// ──────────────────────────────────────────────
// Stripe Connect
// ──────────────────────────────────────────────

const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const STRIPE_WEBHOOK_SECRET = functions.defineSecret('stripe_webhook_secret');

/**
 * Crée un lien d'onboarding Stripe Connect Express pour une assmat.
 * Appelé par le client Flutter (assmat_invoice_page).
 */
exports.createStripeOnboardingLink = functions.onCall(
  { secrets: [] },
  async (request) => {
    const { assmatUid } = request.data;
    if (!assmatUid) {
      throw new functions.HttpsError('invalid-argument', 'assmatUid requis');
    }

    const db = admin.firestore();
    const usersRef = db.collection('users').doc(assmatUid);
    const userSnap = await usersRef.get();
    const email = userSnap.data()?.email;

    // Créer ou récupérer le compte Stripe Connect existant
    const assmatRef = db.collection('assmats').doc(assmatUid);
    const assmatSnap = await assmatRef.get();
    let stripeAccountId = assmatSnap.data()?.stripeAccountId;

    if (!stripeAccountId) {
      const account = await stripe.accounts.create({
        type: 'express',
        email,
        capabilities: {
          transfers: { requested: true },
        },
        business_type: 'individual',
      });
      stripeAccountId = account.id;
      await assmatRef.update({ stripeAccountId });
    }

    // Générer le lien d'onboarding
    const accountLink = await stripe.accountLinks.create({
      account: stripeAccountId,
      refresh_url: 'https://ami-ly.app/reauth',
      return_url: 'https://ami-ly.app/dashboard',
      type: 'account_onboarding',
    });

    return { url: accountLink.url };
  }
);

/**
 * Vérifie si le compte Stripe Connect d'une assmat est actif.
 */
exports.checkStripeAccountStatus = functions.onCall(
  { secrets: [] },
  async (request) => {
    const { assmatUid } = request.data;
    if (!assmatUid) {
      throw new functions.HttpsError('invalid-argument', 'assmatUid requis');
    }

    const db = admin.firestore();
    const assmatRef = db.collection('assmats').doc(assmatUid);
    const assmatSnap = await assmatRef.get();
    const stripeAccountId = assmatSnap.data()?.stripeAccountId;

    if (!stripeAccountId) {
      return { connected: false };
    }

    try {
      const account = await stripe.accounts.retrieve(stripeAccountId);
      const connected = account.charges_enabled && account.payouts_enabled;
      if (connected !== assmatSnap.data()?.stripeConnected) {
        await assmatRef.update({ stripeConnected: connected });
      }
      return { connected };
    } catch (e) {
      console.error('checkStripeAccountStatus error:', e);
      return { connected: false };
    }
  }
);

/**
 * Crée un PaymentIntent Stripe, sauvegarde le client_secret dans Firestore,
 * et configure le transfert vers le compte Stripe Connect de l'assmat.
 */
exports.createPaymentIntent = functions.onCall(
  { secrets: [] },
  async (request) => {
    const { invoiceId } = request.data;
    if (!invoiceId) {
      throw new functions.HttpsError('invalid-argument', 'invoiceId requis');
    }

    const db = admin.firestore();
    const invoiceRef = db.collection('invoices').doc(invoiceId);
    const invoiceSnap = await invoiceRef.get();

    if (!invoiceSnap.exists) {
      throw new functions.HttpsError('not-found', 'Facture introuvable');
    }

    const invoice = invoiceSnap.data();
    const assmatRef = db.collection('assmats').doc(invoice.assmatUid);
    const assmatSnap = await assmatRef.get();
    const stripeAccountId = assmatSnap.data()?.stripeAccountId;

    if (!stripeAccountId) {
      throw new functions.HttpsError(
        'failed-precondition',
        "L'assmat n'a pas de compte Stripe Connect"
      );
    }

    const amountCents = Math.round(invoice.totalAmount * 100);

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency: 'eur',
      automatic_payment_methods: { enabled: true },
      transfer_data: {
        destination: stripeAccountId,
      },
      metadata: {
        invoiceId,
        assmatUid: invoice.assmatUid,
      },
    });

    await invoiceRef.update({
      stripePaymentIntentId: paymentIntent.id,
      stripeClientSecret: paymentIntent.client_secret,
    });

    return {
      clientSecret: paymentIntent.client_secret,
    };
  }
);

/**
 * Webhook Stripe : écoute les événements payment_intent.succeeded/failed
 * et met à jour le statut de la facture dans Firestore.
 */
exports.stripeWebhook = functions.onRequest(
  { secrets: [STRIPE_WEBHOOK_SECRET] },
  async (req, res) => {
    const sig = req.headers['stripe-signature'];
    let event;

    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig,
        process.env.STRIPE_WEBHOOK_SECRET
      );
    } catch (err) {
      console.error('Webhook signature verification failed:', err.message);
      res.status(400).send(`Webhook Error: ${err.message}`);
      return;
    }

    const db = admin.firestore();

    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object;
        const invoiceId = paymentIntent.metadata.invoiceId;

        await db.collection('invoices').doc(invoiceId).update({
          status: 'paid',
          paidAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Notification pour l'assmat
        const invoiceSnap = await db.collection('invoices').doc(invoiceId).get();
        const invoiceData = invoiceSnap.data();
        if (invoiceData?.assmatUid) {
          await db.collection('notifications').add({
            recipientUid: invoiceData.assmatUid,
            type: 'invoicePaid',
            title: 'Facture payée !',
            body: `La famille ${invoiceData.familyName ?? ''} a réglé la facture de ${(paymentIntent.amount / 100).toFixed(2)} €.`,
            read: false,
            invoiceId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        break;
      }

      case 'payment_intent.payment_failed': {
        const paymentIntent = event.data.object;
        const invoiceId = paymentIntent.metadata.invoiceId;

        await db.collection('invoices').doc(invoiceId).update({
          status: 'failed',
        });

        // Notification pour l'assmat
        const invoiceSnap = await db.collection('invoices').doc(invoiceId).get();
        const invoiceData = invoiceSnap.data();
        if (invoiceData?.assmatUid) {
          await db.collection('notifications').add({
            recipientUid: invoiceData.assmatUid,
            type: 'invoicePaymentFailed',
            title: 'Paiement échoué',
            body: `Le paiement de la facture pour ${invoiceData.familyName ?? ''} a échoué.`,
            read: false,
            invoiceId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        break;
      }

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  }
);
