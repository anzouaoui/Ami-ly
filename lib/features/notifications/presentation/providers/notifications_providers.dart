import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/services/notification_service.dart';

/// Stream de toutes les notifications de l'utilisateur connecté.
final notificationsProvider =
    StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(notificationServiceProvider).notificationsStream(uid);
});

/// Stream des notifications non lues (utile pour les badges).
final unreadNotificationsCountProvider = StreamProvider.autoDispose<int>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(0);
  return ref.read(notificationServiceProvider).unreadCountStream(uid);
});

/// Stream des notifications d'un type spécifique.
final notificationsByTypeProvider = StreamProvider.autoDispose
    .family<List<NotificationModel>, NotificationType>((ref, type) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(notificationServiceProvider).byTypeStream(uid, type);
});
