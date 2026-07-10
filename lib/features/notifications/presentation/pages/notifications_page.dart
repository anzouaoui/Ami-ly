import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../assmat/presentation/pages/assmat_chat_page.dart';
import '../../../parent/presentation/pages/parent_chat_page.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final uid = ref.watch(currentUserProvider).valueOrNull?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (uid != null)
            TextButton(
              onPressed: () async {
                await ref.read(notificationServiceProvider).markAllAsRead(uid);
              },
              child: const Text('Tout marquer lu'),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notifications',
                          style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w800, fontSize: 28)),
                      const SizedBox(height: 4),
                      notificationsAsync.when(
                        data: (notifications) {
                          final unread =
                              notifications.where((n) => !n.read).length;
                          return Text(
                            unread > 0
                                ? '$unread non ${unread > 1 ? 'lues' : 'lue'}'
                                : 'Tout est à jour',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.secondaryText),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                FilterChip(
                  label: Text('Non lues',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600)),
                  selected: _unreadOnly,
                  onSelected: (v) => setState(() => _unreadOnly = v),
                  visualDensity: VisualDensity.compact,
                  selectedColor:
                      AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  side: BorderSide(
                    color: _unreadOnly
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadii.full),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                final filtered = _unreadOnly
                    ? notifications.where((n) => !n.read).toList()
                    : notifications;
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            size: 48,
                            color: AppColors.secondaryText
                                .withValues(alpha: 0.4)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _unreadOnly
                              ? 'Aucune notification non lue'
                              : 'Aucune notification',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => NotificationTile(
                    notification: filtered[i],
                    onTap: () => _onTap(filtered[i]),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Erreur : $e',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(NotificationModel notification) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    // Marquer comme lue
    if (!notification.read) {
      await ref.read(notificationServiceProvider).markAsRead(notification.id);
    }

    if (!mounted) return;

    switch (notification.type) {
      case NotificationType.newMessage:
      case NotificationType.visioProposalReceived:
      case NotificationType.visioProposalResponse:
        await _navigateToConversation(notification, user);

      case NotificationType.contractSignatureRequest:
      case NotificationType.contractSigned:
      case NotificationType.contractStatusChanged:
        // TODO: naviguer vers la page du contrat
        break;

      case NotificationType.childAdded:
      case NotificationType.availabilityUpdated:
        break;
    }
  }

  /// Navigue vers la conversation en chargeant les infos depuis Firestore.
  Future<void> _navigateToConversation(
      NotificationModel notification, dynamic user) async {
    final convId = notification.conversationId;
    if (convId == null) return;

    // Charge la conversation pour obtenir le nom des participants
    final convDoc = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(convId)
        .get();

    if (!convDoc.exists || !mounted) return;

    final data = convDoc.data()!;
    final isParent = data['parentUid'] == user.uid;

    if (isParent) {
      // Côté parent : navigue vers ParentChatPage
      final assmatUid = data['assmatUid'] as String? ?? '';
      final assmatName = data['assmatName'] as String? ?? 'Assistante maternelle';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ParentChatPage(
            assmatUid: assmatUid,
            assmatName: assmatName,
          ),
        ),
      );
    } else {
      // Côté assmat : navigue vers AssMatChatPage
      final parentName = data['parentName'] as String? ?? 'Parent';
      final initials = parentName
          .split(' ')
          .where((w) => w.isNotEmpty)
          .take(2)
          .map((w) => w[0].toUpperCase())
          .join();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AssMatChatPage(
            contact: ChatContact(name: parentName, initials: initials),
            conversationId: convId,
          ),
        ),
      );
    }
  }
}
