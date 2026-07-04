import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_service.dart';

class NotificationService {
  NotificationService({required FirebaseService firebaseService})
      : _firestore = firebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Future<void> createNotification({
    required String recipientUid,
    required String type,
    required String title,
    required String body,
    String? contractId,
    String? senderUid,
  }) async {
    await _notifications.add({
      'recipientUid': recipientUid,
      'senderUid': senderUid ?? '',
      'type': type,
      'contractId': contractId ?? '',
      'title': title,
      'body': body,
      'read': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> unreadStream(String uid) =>
      _notifications
          .where('recipientUid', isEqualTo: uid)
          .where('read', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots();

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
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return NotificationService(firebaseService: firebaseService);
});
