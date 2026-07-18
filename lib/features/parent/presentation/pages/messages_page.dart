import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/models/conversation_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../messaging/providers/messaging_providers.dart';
import '../widgets/parent_navigation_drawer.dart';
import 'engagement_contract_page.dart';
import 'find_childminder_page.dart';
import 'parent_chat_page.dart';

class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ParentNavigationDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Expanded(
              child: ref.watch(parentConversationsProvider).when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Impossible de charger les messages.\n$e',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    data: (conversations) => conversations.isEmpty
                        ? _EmptyState(
                            onFindAssmat: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const FindChildminderPage()),
                            ),
                          )
                        : _ConversationListView(
                            conversations: conversations),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded,
                  size: 28, color: AppColors.primaryText),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Menu',
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.child_care_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('AMiLY',
                  style: AppTextStyles.titleLarge
                      .copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onFindAssmat});
  final VoidCallback onFindAssmat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.divider),
          boxShadow: AppShadows.md,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                size: 80, color: AppColors.secondaryText),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune conversation',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primaryText, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Contactez une assistante maternelle depuis son profil pour démarrer une discussion.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onFindAssmat,
              child: const Text('Rechercher une assistante maternelle'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Conversation list ────────────────────────────────────────────────────────

class _ConversationListView extends ConsumerWidget {
  const _ConversationListView({required this.conversations});
  final List<ConversationModel> conversations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    if (currentUser == null) {
      return const Center(child: Text('Utilisateur non connecté'));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes messages',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('contracts')
                  .where('parentUid', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, contractSnap) {
                final contractByAssmat =
                    <String, Map<String, dynamic>>{};
                if (contractSnap.hasData) {
                  for (final doc in contractSnap.data!.docs) {
                    final d = doc.data() as Map<String, dynamic>;
                    final assmatUid = d['assmatUid'] as String? ?? '';
                    if (assmatUid.isNotEmpty) {
                      contractByAssmat[assmatUid] = d;
                    }
                  }
                }

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: AppShadows.sm,
                  ),
                  child: ListView.separated(
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (_, i) => _ConversationTile(
                      conv: conversations[i],
                      contractData: contractByAssmat[conversations[i].assmatUid],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Conversation tile ────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conv,
    this.contractData,
  });
  final ConversationModel conv;
  final Map<String, dynamic>? contractData;

  @override
  Widget build(BuildContext context) {
    final initials = conv.assmatName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final unread = conv.unreadParent;
    final timeLabel = _timeLabel(conv.lastMessageAt);

    final status = contractData?['status'] as String? ?? '';
    final (statusLabel, statusColor, actionLabel) = _contractStatusInfo(status);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ParentChatPage(
            assmatUid: conv.assmatUid,
            assmatName: conv.assmatName,
          ),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    initials,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.assmatName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: unread > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeLabel.isNotEmpty)
                        Text(
                          timeLabel,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: unread > 0
                                ? AppColors.primary
                                : AppColors.secondaryText,
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  if (conv.lastMessage.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      conv.lastMessage,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: unread > 0
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (status.isNotEmpty && status != 'active') ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: SizedBox(
                            height: 28,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EngagementContractPage(
                                    assmatUid: conv.assmatUid,
                                    assmatName: conv.assmatName,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                textStyle: const TextStyle(fontSize: 11),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(actionLabel, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color, String) _contractStatusInfo(String status) {
    switch (status) {
      case 'draft':
        return ('Brouillon', AppColors.secondary, 'Reprendre');
      case 'pendingAssmat':
        return ('En attente signature', AppColors.accent, 'Voir');
      case 'pendingParent':
        return ('À signer', AppColors.primary, 'Signer');
      case 'active':
        return ('Contrat actif', AppColors.success, 'Voir');
      default:
        return ('', Colors.transparent, '');
    }
  }

  static String _timeLabel(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat('HH:mm').format(dt);
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Hier';
    }
    if (now.difference(dt).inDays < 7) {
      return DateFormat('EEE', 'fr_FR').format(dt);
    }
    return DateFormat('dd/MM').format(dt);
  }
}
