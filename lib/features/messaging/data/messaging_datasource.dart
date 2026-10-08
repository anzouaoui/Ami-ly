import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';
import '../../../core/utils/french_date_format.dart';
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

  /// Vérifie si une conversation existe entre un parent et une assmat.
  Future<bool> conversationExists(String parentUid, String assmatUid) async {
    final convId = ConversationModel.buildId(parentUid, assmatUid);
    try {
      final snap = await _firebase.conversationDoc(convId).get();
      return snap.exists;
    } catch (e) {
      return false;
    }
  }

  // ── Conversations ──────────────────────────────────────────────────────────

  Stream<List<ConversationModel>> watchConversationsForParent(
          String parentUid) =>
      _watchConversationsWhere('parentUid', parentUid);

  Stream<List<ConversationModel>> watchConversationsForAssmat(
          String assmatUid) =>
      _watchConversationsWhere('assmatUid', assmatUid);

  /// Conversations dont [field] vaut [uid], de la plus récente à la plus
  /// ancienne.
  Stream<List<ConversationModel>> _watchConversationsWhere(
    String field,
    String uid,
  ) {
    return _firebase.conversationsCollection
        .where(field, isEqualTo: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ConversationModel.fromFirestore).toList());
  }

  /// Retourne l'ID de conversation et un booléen indiquant si elle vient d'être créée.
  ///
  /// N'utilise pas de `get()` préalable pour éviter une erreur de règle Firestore
  /// sur les documents inexistants (`resource == null`).
  /// `mergeFields` garantit que les champs d'état (unreadAssmat, lastMessage…)
  /// ne sont pas écrasés si la conversation existe déjà.
  Future<({String convId, bool isNew})> getOrCreateConversation({
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
        return (convId: convId, isNew: false);
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

    return (convId: convId, isNew: true);
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
      'type': 'text',
    });

    // 2. Résumé conversation : lastMessage + incrément non-lus du destinataire
    batch.update(
      convRef,
      _conversationSummaryUpdate(
        lastMessage: text,
        sentAt: now,
        senderIsParent: senderIsParent,
      ),
    );

    await batch.commit();
  }

  /// Envoie une proposition de visio et met à jour le résumé de la conversation.
  Future<void> sendVisioProposal({
    required String convId,
    required String senderUid,
    required DateTime visioDate,
    required bool senderIsParent,
  }) async {
    final now = DateTime.now();
    final msgRef = _firebase.messagesCollection(convId).doc();
    final convRef = _firebase.conversationDoc(convId);

    final day = formatFrenchLongDate(visioDate);
    final hour = formatHourMinute(visioDate);
    final text = '📹 Visio proposée le $day à $hour';

    final batch = _firebase.firestore.batch();

    batch.set(msgRef, {
      'senderUid': senderUid,
      'text': text,
      'sentAt': Timestamp.fromDate(now),
      'type': 'visio_proposal',
      'visioDate': Timestamp.fromDate(visioDate),
      'visioStatus': 'pending',
    });

    batch.update(
      convRef,
      _conversationSummaryUpdate(
        lastMessage: text,
        sentAt: now,
        senderIsParent: senderIsParent,
      ),
    );

    await batch.commit();
  }

  /// Crée un message de réponse à une proposition de visio (acceptée / refusée).
  /// On ne modifie PAS le message original (interdit par les règles Firestore),
  /// on crée un nouveau message de type `visio_response` lié via [visioProposalId].
  Future<void> respondToVisio({
    required String convId,
    required String msgId,
    required VisioStatus status,
    required bool responderIsParent,
    required String responderUid,
    String? callId,
  }) async {
    final now = DateTime.now();
    final newMsgRef = _firebase.messagesCollection(convId).doc();
    final convRef = _firebase.conversationDoc(convId);

    final actor = responderIsParent ? 'le parent' : "l\u0027assistante maternelle";
    final text = switch (status) {
      VisioStatus.accepted => 'Visio acceptée par $actor',
      VisioStatus.refused => 'Visio refusée par $actor',
      VisioStatus.completed => 'Visio terminée par $actor',
      VisioStatus.match => 'Match validé par $actor',
      VisioStatus.reflection => 'En réflexion par $actor',
      VisioStatus.rejected => 'Match refusé par $actor',
      VisioStatus.expired => 'Proposition de visio expirée',
      _ => 'Visio : $status',
    };

    final batch = _firebase.firestore.batch();

    // 1. Nouveau message de réponse (type visio_response)
    final Map<String, dynamic> msgData = {
      'senderUid': responderUid,
      'text': text,
      'sentAt': Timestamp.fromDate(now),
      'type': 'visio_response',
      'visioStatus': status.name,
      'visioProposalId': msgId,
    };
    if (status == VisioStatus.reflection) {
      msgData['reflectionDeadline'] =
          Timestamp.fromDate(now.add(const Duration(days: 10)));
    }
    if (callId != null) {
      msgData['callId'] = callId;
    }
    batch.set(newMsgRef, msgData);

    // 2. Résumé conversation
    batch.update(
      convRef,
      _conversationSummaryUpdate(
        lastMessage: text,
        sentAt: now,
        senderIsParent: responderIsParent,
      ),
    );

    await batch.commit();
  }

  /// Champs de résumé mis à jour à chaque nouveau message : dernier message,
  /// date, et incrément du compteur de non-lus du destinataire.
  Map<String, dynamic> _conversationSummaryUpdate({
    required String lastMessage,
    required DateTime sentAt,
    required bool senderIsParent,
  }) {
    return {
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(sentAt),
      if (senderIsParent)
        'unreadAssmat': FieldValue.increment(1)
      else
        'unreadParent': FieldValue.increment(1),
    };
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
