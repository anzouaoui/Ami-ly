import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/models/conversation_model.dart';
import '../../../messaging/providers/messaging_providers.dart';
import 'assmat_chat_page.dart';
import 'assmat_home_page.dart';

class AssMatMessagesPage extends ConsumerWidget {
  const AssMatMessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AssMatDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 24),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Messages',
                    style: AppTextStyles.titleLarge
                        .copyWith(fontWeight: FontWeight.w800, fontSize: 28)),
                const SizedBox(height: 4),
                Text('Communication sécurisée avec les parents',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),

          // ── Conversation list ─────────────────────────────────────────
          Expanded(
            child: ref.watch(assmatConversationsProvider).when(
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
                      ? _EmptyState()
                      : _ConversationListCard(conversations: conversations),
                ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                size: 72, color: AppColors.secondaryText),
            const SizedBox(height: AppSpacing.lg),
            Text('Aucun message',
                style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Les parents qui vous contactent apparaîtront ici.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Conversation list card ───────────────────────────────────────────────────

class _ConversationListCard extends StatefulWidget {
  const _ConversationListCard({required this.conversations});
  final List<ConversationModel> conversations;

  @override
  State<_ConversationListCard> createState() => _ConversationListCardState();
}

class _ConversationListCardState extends State<_ConversationListCard> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ConversationModel> get _filtered => widget.conversations
      .where((c) =>
          _query.isEmpty ||
          c.parentName.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: AppTextStyles.bodySmall,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.hint),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 18, color: AppColors.secondaryText),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (_, i) => _ConversationTile(conv: _filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Conversation tile ────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conv});
  final ConversationModel conv;

  @override
  Widget build(BuildContext context) {
    final initials = conv.parentName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final unread = conv.unreadAssmat;
    final timeLabel = _timeLabel(conv.lastMessageAt);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AssMatChatPage(
            contact: ChatContact(
              name: conv.parentName,
              initials: initials,
            ),
            conversationId: conv.id,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 14),
        child: Row(
          children: [
            // Avatar + badge
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
                          color: Color(0xFFE07830),
                          shape: BoxShape.circle),
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
                          conv.parentName,
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
                                ? const Color(0xFFE07830)
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
