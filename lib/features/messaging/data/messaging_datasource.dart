import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/models/conversation_model.dart';
import '../../../shared/models/message_model.dart';

/// Couche d'accès Firestore pour la messagerie parent ↔ assmat.
///
/// Structure :
///   conversations/{convId}              — résumé de la conversation
///   conversations/{convId}/messages/    — messages du fil
///
/// L'ID de conversation est déterministe : `${parentUid}_${assmatUid}`,
/// ce qui permet un lookup direct et évite les doublons.
class MessagingDatasource {
  const MessagingDatasource(this._firebase);
  final FirebaseService _firebase;

  // ── Conversations ──────────────────────────────────────────────────────────

  Stream<List<ConversationModel>> watchConversationsForParent(
      String parentUid) {
    return _firebase.conversationsCollection
        .where('parentUid', isEqualTo: parentUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ConversationModel.fromFirestore).toList());
  }

  Stream<List<ConversationModel>> watchConversationsForAssmat(
      String assmatUid) {
    return _firebase.conversationsCollection
        .where('assmatUid', isEqualTo: assmatUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ConversationModel.fromFirestore).toList());
  }

  /// Retourne l'ID de conversation, en créant le document s'il n'existe pas.
  ///
  /// N'utilise pas de `get()` préalable pour éviter une erreur de règle Firestore
  /// sur les documents inexistants (`resource == null`).
  /// `mergeFields` garantit que les champs d'état (unreadAssmat, lastMessage…)
  /// ne sont pas écrasés si la conversation existe déjà.
  Future<String> getOrCreateConversation({
    required String parentUid,
    required String assmatUid,
    required String parentName,
    required String assmatName,
  }) async {
    final convId = ConversationModel.buildId(parentUid, assmatUid);
    final ref = _firebase.conversationDoc(convId);

    try {
      final snap = await ref.get();
      if (snap.exists) {
        return convId;
      }
    } catch (e) {
      // Ce catch gère le cas où les règles Firestore bloquent le get() sur un document inexistant.
      // Dans ce cas, on passe directement à la création/fusion.
      debugPrint('[Chat] getOrCreateConversation get() exception: $e');
    }

    // Crée le document avec les champs de base s'il n'existe pas.
    // En limitant mergeFields aux champs d'identité et de date de création,
    // on s'assure qu'on n'écrase pas l'état existant (unreadParent, lastMessage, etc.)
    // si le document existait déjà (par exemple s'il a été créé en parallèle ou si le get() a échoué).
    await ref.set(
      {
        'parentUid': parentUid,
        'assmatUid': assmatUid,
        'parentName': parentName,
        'assmatName': assmatName,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(mergeFields: [
        'parentUid',
        'assmatUid',
        'parentName',
        'assmatName',
        'createdAt',
      ]),
    );

    return convId;
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  Stream<List<MessageModel>> watchMessages(String convId) {
    return _firebase
        .messagesCollection(convId)
        .orderBy('sentAt')
        .snapshots()
        .map((s) => s.docs.map(MessageModel.fromFirestore).toList());
  }

  /// Envoie un message et met à jour le résumé de la conversation.
  Future<void> sendMessage({
    required String convId,
    required String senderUid,
    required String text,
    required bool senderIsParent,
  }) async {
    final now = DateTime.now();
    final msgRef = _firebase.messagesCollection(convId).doc();
    final convRef = _firebase.conversationDoc(convId);

    final batch = _firebase.firestore.batch();

    // 1. Nouveau message
    batch.set(msgRef, {
      'senderUid': senderUid,
      'text': text,
      'sentAt': Timestamp.fromDate(now),
    });

    // 2. Résumé conversation : lastMessage + incrément non-lus du destinataire
    batch.update(convRef, {
      'lastMessage': text,
      'lastMessageAt': Timestamp.fromDate(now),
      if (senderIsParent)
        'unreadAssmat': FieldValue.increment(1)
      else
        'unreadParent': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Remet à zéro le compteur de non-lus pour l'utilisateur qui ouvre le fil.
  Future<void> markAsRead({
    required String convId,
    required bool readerIsParent,
  }) async {
    await _firebase.conversationDoc(convId).update(
          readerIsParent
              ? {'unreadParent': 0}
              : {'unreadAssmat': 0},
        );
  }
}
