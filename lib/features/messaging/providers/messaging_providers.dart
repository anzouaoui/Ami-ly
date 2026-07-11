import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/models/conversation_model.dart';
import '../../../shared/models/message_model.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../data/messaging_datasource.dart';

// ── DI ────────────────────────────────────────────────────────────────────────

final messagingDatasourceProvider = Provider<MessagingDatasource>((ref) {
  return MessagingDatasource(ref.watch(firebaseServiceProvider));
});

// ── Conversations ─────────────────────────────────────────────────────────────

/// Liste des conversations du parent connecté, triées par dernier message.
final parentConversationsProvider =
    StreamProvider.autoDispose<List<ConversationModel>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref
      .watch(messagingDatasourceProvider)
      .watchConversationsForParent(uid);
});

/// Liste des conversations de l'assmat connectée, triées par dernier message.
final assmatConversationsProvider =
    StreamProvider.autoDispose<List<ConversationModel>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref
      .watch(messagingDatasourceProvider)
      .watchConversationsForAssmat(uid);
});

// ── Unread counts ─────────────────────────────────────────────────────────────

/// Nombre total de messages non lus pour le parent connecté.
final parentUnreadMessageCountProvider = Provider.autoDispose<int>((ref) {
  final conversations = ref.watch(parentConversationsProvider);
  return conversations.whenOrNull(
        data: (list) => list.fold<int>(0, (sum, c) => sum + c.unreadParent),
      ) ??
      0;
});

/// Nombre total de messages non lus pour l'assmat connectée.
final assmatUnreadMessageCountProvider = Provider.autoDispose<int>((ref) {
  final conversations = ref.watch(assmatConversationsProvider);
  return conversations.whenOrNull(
        data: (list) => list.fold<int>(0, (sum, c) => sum + c.unreadAssmat),
      ) ??
      0;
});

// ── Messages ──────────────────────────────────────────────────────────────────

/// Messages d'un fil de conversation, triés par date croissante.
final messagesProvider = StreamProvider.autoDispose
    .family<List<MessageModel>, String>((ref, convId) {
  return ref.watch(messagingDatasourceProvider).watchMessages(convId);
});
