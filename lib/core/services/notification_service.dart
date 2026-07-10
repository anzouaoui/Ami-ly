import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/notification_model.dart';
import 'firebase_service.dart';

class NotificationService {
  NotificationService({required FirebaseService firebaseService})
      : _firestore = firebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection(AppConstants.notificationsCollection);

  // ── Création ────────────────────────────────────────────────────────────────

  Future<void> createNotification({
    required String recipientUid,
    required NotificationType type,
    required String title,
    required String body,
    String? senderUid,
    String? contractId,
    String? conversationId,
    String? visioProposalId,
    Map<String, dynamic>? metadata,
  }) async {
    await _notifications.add(
      NotificationModel(
        id: '',
        recipientUid: recipientUid,
        type: type,
        title: title,
        body: body,
        read: false,
        createdAt: DateTime.now(),
        senderUid: senderUid,
        contractId: contractId,
        conversationId: conversationId,
        visioProposalId: visioProposalId,
        metadata: metadata,
      ).toFirestore(),
    );
  }

  // ── Lecture ──────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> _queryByRecipient(String uid,
          {bool? read, NotificationType? type, int? limit}) =>
      _notifications
          .where('recipientUid', isEqualTo: uid)
          .where('read', isEqualTo: read)
          .orderBy('createdAt', descending: true)
          .limit(limit ?? 100)
          .snapshots();

  /// Toutes les notifications (non lues + lues).
  Stream<List<NotificationModel>> notificationsStream(String uid) =>
      _notifications
          .where('recipientUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .map((snap) => snap.docs
              .map(NotificationModel.fromFirestore)
              .toList());

  /// Notifications non lues uniquement.
  Stream<List<NotificationModel>> unreadStream(String uid) =>
      _queryByRecipient(uid, read: false)
          .map((snap) => snap.docs
              .map(NotificationModel.fromFirestore)
              .toList());

  /// Nombre de non-lues (utile pour les badges).
  Stream<int> unreadCountStream(String uid) => _queryByRecipient(uid, read: false)
      .map((snap) => snap.docs.length);

  /// Notifications par type (ex: uniquement les messages).
  Stream<List<NotificationModel>> byTypeStream(
          String uid, NotificationType type) =>
      _notifications
          .where('recipientUid', isEqualTo: uid)
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snap) => snap.docs
              .map(NotificationModel.fromFirestore)
              .toList());

  /// Une seule notification par ID.
  Future<NotificationModel?> getById(String notificationId) async {
    final doc = await _notifications.doc(notificationId).get();
    if (!doc.exists) return null;
    return NotificationModel.fromFirestore(doc);
  }

  // ── Mise à jour ─────────────────────────────────────────────────────────────

  Future<void> markAsRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'read': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final unread = await _notifications
        .where('recipientUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  // ── Suppression ─────────────────────────────────────────────────────────────

  Future<void> delete(String notificationId) async {
    await _notifications.doc(notificationId).delete();
  }

  Future<void> deleteAll(String uid) async {
    final all = await _notifications
        .where('recipientUid', isEqualTo: uid)
        .get();
    final batch = _firestore.batch();
    for (final doc in all.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return NotificationService(firebaseService: firebaseService);
});
