import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../video_call/domain/entities/call.dart';
import '../../../video_call/presentation/providers/video_call_providers.dart';
import '../../../video_call/presentation/helpers/visio_join_helper.dart';
import '../../../../shared/models/message_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../messaging/providers/messaging_providers.dart';
import '../../../notifications/presentation/providers/notification_triggers.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class ChatContact {
  const ChatContact({required this.name, required this.initials});
  final String name;
  final String initials;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatChatPage extends ConsumerStatefulWidget {
  const AssMatChatPage({
    super.key,
    required this.contact,
    required this.conversationId,
  });

  final ChatContact contact;
  final String conversationId;

  @override
  ConsumerState<AssMatChatPage> createState() => _AssMatChatPageState();
}

class _AssMatChatPageState extends ConsumerState<AssMatChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _markRead();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _markRead() async {
    await ref.read(messagingDatasourceProvider).markAsRead(
          convId: widget.conversationId,
          readerIsParent: false,
        );
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    _msgCtrl.clear();
    await ref.read(messagingDatasourceProvider).sendMessage(
          convId: widget.conversationId,
          senderUid: currentUser.uid,
          text: text,
          senderIsParent: false,
        );

    // Notification in-app pour le parent (convId = parentUid_assmatUid)
    try {
      final parentUid = widget.conversationId.split('_').first;
      ref.read(notificationTriggersProvider).onMessageSent(
            recipientUid: parentUid,
            senderUid: currentUser.uid,
            senderName: currentUser.displayName ?? 'Une assistante maternelle',
            conversationId: widget.conversationId,
            messageText: text,
          );
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final myUid = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      widget.contact.initials,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.contact.name,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Page title ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Messages',
                        style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w800, fontSize: 26)),
                    Text('Communication sécurisée avec les parents',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Bubble list ───────────────────────────────────────────────
            Expanded(
              child: ref
                  .watch(messagesProvider(widget.conversationId))
                  .when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text(
                        'Erreur de chargement\n$e',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    data: (messages) {
                      if (messages.isEmpty) {
                        return Center(
                          child: Text(
                            'Aucun message pour l\'instant.',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.secondaryText),
                          ),
                        );
                      }
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollCtrl.hasClients) {
                          _scrollCtrl
                              .jumpTo(_scrollCtrl.position.maxScrollExtent);
                        }
                      });
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppRadii.md),
                            topRight: Radius.circular(AppRadii.md),
                          ),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppRadii.md),
                            topRight: Radius.circular(AppRadii.md),
                          ),
                          child: ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: messages.length,
                              itemBuilder: (_, i) {
                                final msg = messages[i];
                                if (msg.isVisioProposal) {
                                  final responses = messages.where(
                                    (m) => m.type == MessageType.visioResponse && m.visioProposalId == msg.id,
                                  ).toList();
                                  final lastResponse = responses.isNotEmpty ? responses.last : null;
                                  return _AssmatVisioCard(
                                    message: msg,
                                    responseStatus: lastResponse?.visioStatus,
                                    callId: lastResponse?.callId,
                                    conversationId: widget.conversationId,
                                  );
                                }
                                if (msg.type == MessageType.visioResponse) {
                                  return const SizedBox.shrink();
                                }
                                final isMe = msg.senderUid == myUid;
                                return _BubbleTile(msg: msg, isMe: isMe);
                              },
                          ),
                        ),
                      );
                    },
                  ),
            ),

            // ── Input bar ────────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: AppTextStyles.bodySmall,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Écrire un message',
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.hint),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.full),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.full),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.full),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte d'une proposition de visio côté assmat, avec boutons accepter/refuser.
class _AssmatVisioCard extends ConsumerWidget {
  const _AssmatVisioCard({
    required this.message,
    required this.conversationId,
    this.responseStatus,
    this.callId,
  });

  final MessageModel message;
  final String conversationId;
  final VisioStatus? responseStatus;
  final String? callId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveStatus = responseStatus ?? message.visioStatus;
    final bool isAccepted = effectiveStatus == VisioStatus.accepted;
    final (Color bgColor, Color borderColor, String statusText) =
        switch (effectiveStatus) {
      VisioStatus.accepted => (
          AppColors.secondary,
          AppColors.primary,
          'Vous avez accepté cette visio',
        ),
      VisioStatus.completed => (
          AppColors.primary.withValues(alpha: 0.08),
          AppColors.primary,
          'Visio terminée par le parent',
        ),
      VisioStatus.match => (
          AppColors.success.withValues(alpha: 0.08),
          AppColors.success,
          'Match validé par le parent',
        ),
      VisioStatus.reflection => (
          AppColors.accent.withValues(alpha: 0.08),
          AppColors.accent,
          'En réflexion par le parent',
        ),
      VisioStatus.rejected => (
          AppColors.error.withValues(alpha: 0.08),
          AppColors.error,
          'Match refusé par le parent',
        ),
      VisioStatus.refused => (
          AppColors.error.withValues(alpha: 0.08),
          AppColors.error,
          'Vous avez refusé cette visio',
        ),
      _ => (
          AppColors.secondary,
          AppColors.primary.withValues(alpha: 0.3),
          'En attente de votre réponse',
        ),
    };

    final bool canRespond = effectiveStatus == VisioStatus.pending;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('📹', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proposition de visio',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        message.text,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: borderColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.full),
                        ),
                        child: Text(
                          statusText,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: borderColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (canRespond) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _respond(context, ref, VisioStatus.refused),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Refuser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _respond(context, ref, VisioStatus.accepted),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Accepter'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // ── Visio acceptée : rejoindre / terminer ──────────────────
            if (isAccepted) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _joinVisio(context, ref),
                      icon: const Icon(Icons.videocam_rounded, size: 16),
                      label: const Text('Rejoindre la visio'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _markCompleted(context, ref),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Visio terminée'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: BorderSide.none,
                        backgroundColor: AppColors.success.withValues(alpha: 0.08),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _respond(BuildContext context, WidgetRef ref, VisioStatus status) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    String? createdCallId;

    if (status == VisioStatus.accepted) {
      final parentUid = conversationId.split('_').first;
      String parentName = 'Parent';
      try {
        final doc = await FirebaseFirestore.instance
            .collection('parents')
            .doc(parentUid)
            .get();
        if (doc.exists) {
          final data = doc.data();
          final first = data?['firstName'] as String? ?? '';
          final last = data?['lastName'] as String? ?? '';
          parentName = '$first $last'.trim();
          if (parentName.isEmpty) parentName = 'Parent';
        }
      } catch (_) {}

      final controller = ref.read(videoCallControllerProvider.notifier);
      await controller.startCall(
        callerId: currentUser.uid,
        calleeId: parentUid,
        callerName: currentUser.displayName ?? 'Assistante maternelle',
        calleeName: parentName,
        initialStatus: CallStatus.pending,
      );
      createdCallId = ref.read(videoCallControllerProvider).call?.id;
    }

    await ref.read(messagingDatasourceProvider).respondToVisio(
          convId: conversationId,
          msgId: message.id,
          status: status,
          responderIsParent: false,
          responderUid: currentUser.uid,
          callId: createdCallId,
        );

    // Notification in-app pour le parent
    try {
      final parentUid = conversationId.split('_').first;
      ref.read(notificationTriggersProvider).onVisioResponse(
            recipientUid: parentUid,
            senderUid: currentUser.uid,
            senderName: currentUser.displayName ?? 'Une assistante maternelle',
            conversationId: conversationId,
            status: status,
          );
    } catch (_) {}
  }

  Future<void> _joinVisio(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final parentUid = conversationId.split('_').first;

    String parentName = 'Parent';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentUid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        final first = data?['firstName'] as String? ?? '';
        final last = data?['lastName'] as String? ?? '';
        parentName = '$first $last'.trim();
        if (parentName.isEmpty) parentName = 'Parent';
      }
    } catch (_) {}

    if (!context.mounted) return;

    await joinVisioCall(
      context: context,
      ref: ref,
      convId: conversationId,
      messageId: message.id,
      callId: callId,
      currentUserUid: currentUser.uid,
      currentUserDisplayName: currentUser.displayName ?? 'Assistante maternelle',
      otherUid: parentUid,
      otherName: parentName,
    );
  }

  Future<void> _markCompleted(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final datasource = ref.read(messagingDatasourceProvider);
    try {
      await datasource.respondToVisio(
        convId: conversationId,
        msgId: message.id,
        status: VisioStatus.completed,
        responderIsParent: false,
        responderUid: currentUser.uid,
      );

      // Notification in-app pour le parent
      try {
        final parentUid = conversationId.split('_').first;
        ref.read(notificationTriggersProvider).onVisioResponse(
              recipientUid: parentUid,
              senderUid: currentUser.uid,
              senderName: currentUser.displayName ?? 'Une assistante maternelle',
              conversationId: conversationId,
              status: VisioStatus.completed,
            );
      } catch (_) {}
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }
}

// ─── Bubble tile ──────────────────────────────────────────────────────────────

class _BubbleTile extends StatelessWidget {
  const _BubbleTile({required this.msg, required this.isMe});
  final MessageModel msg;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(msg.sentAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primary
                        : const Color(0xFFF0F0EE),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isMe ? Colors.white : AppColors.primaryText,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.hint, fontSize: 10),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 3),
                      Icon(
                        msg.isRead
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 13,
                        color: msg.isRead
                            ? AppColors.primary
                            : AppColors.secondaryText,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '$h:$m';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Hier $h:$m';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} $h:$m';
  }
}
