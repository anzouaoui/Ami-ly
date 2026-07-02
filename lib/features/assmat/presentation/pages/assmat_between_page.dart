import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'assmat_chat_between_page.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _Peer {
  const _Peer({
    required this.name,
    required this.initials,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.avatarColor,
  });
  final String name;
  final String initials;
  final String lastMessage;
  final String time;
  final int unread;
  final Color? avatarColor;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatBetweenPage extends StatefulWidget {
  const AssMatBetweenPage({super.key});

  @override
  State<AssMatBetweenPage> createState() => _AssMatBetweenPageState();
}

class _AssMatBetweenPageState extends State<AssMatBetweenPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  final List<_Peer> _peers = [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Peer> get _filtered => _peers
      .where((p) =>
          _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entre Ass Mat',
                          style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w800, fontSize: 28)),
                      const SizedBox(height: 4),
                      Text('Messagerie entre assistantes maternelles',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: () => _showAddFriendSheet(context),
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Ajouter ami'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    textStyle: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // ── List card ────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  // Search
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.hint),
                        prefixIcon: const Icon(Icons.search_rounded,
                            size: 18, color: AppColors.secondaryText),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadii.full),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadii.full),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadii.full),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // Peers list
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(
                            child: Text('Aucun résultat',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.secondaryText)),
                          )
                        : ListView.separated(
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, indent: 72),
                            itemBuilder: (_, i) =>
                                _PeerTile(peer: _filtered[i]),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  void _showAddFriendSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md,
            AppSpacing.md, MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Ajouter une collègue',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Entrez le nom ou l\'email de votre collègue assistante maternelle.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: ctrl,
              autofocus: true,
              style: AppTextStyles.bodySmall,
              decoration: InputDecoration(
                hintText: 'Nom ou email...',
                hintStyle:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.hint),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invitation envoyée'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                child: Text('Envoyer l\'invitation',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Peer tile ────────────────────────────────────────────────────────────────

class _PeerTile extends StatelessWidget {
  const _PeerTile({required this.peer});
  final _Peer peer;

  @override
  Widget build(BuildContext context) {
    final avatarBg = peer.avatarColor?.withValues(alpha: 0.15) ??
        AppColors.divider.withValues(alpha: 0.5);
    final avatarFg = peer.avatarColor ?? AppColors.secondaryText;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AssMatChatBetweenPage(
            peerName: peer.name,
            peerInitials: peer.initials,
            peerAvatarColor: peer.avatarColor,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarBg,
                  child: Text(
                    peer.initials,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: avatarFg, fontWeight: FontWeight.w700),
                  ),
                ),
                if (peer.unread > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE07830),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${peer.unread}',
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
                          peer.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: peer.unread > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        peer.time,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: peer.unread > 0
                              ? const Color(0xFFE07830)
                              : AppColors.secondaryText,
                          fontWeight: peer.unread > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    peer.lastMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: peer.unread > 0
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
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
