import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../pages/assistant_page.dart';
import '../pages/book_year_page.dart';
import '../pages/child_diary_page.dart';
import '../pages/contract_page.dart';
import '../pages/documents_page.dart';
import '../pages/find_childminder_page.dart';
import '../pages/messages_page.dart';
import '../pages/parent_profile_page.dart';
import '../pages/payments_page.dart';
import '../pages/planning_page.dart';

class ParentNavigationDrawer extends ConsumerStatefulWidget {
  const ParentNavigationDrawer({super.key});

  @override
  ConsumerState<ParentNavigationDrawer> createState() =>
      _ParentNavigationDrawerState();
}

class _ParentNavigationDrawerState
    extends ConsumerState<ParentNavigationDrawer> {
  static const _logoBg = Color(0xFF4A3B33);

  final _expanded = <String>{'MON ENFANT'};

  void _toggle(String section) =>
      setState(() => _expanded.contains(section)
          ? _expanded.remove(section)
          : _expanded.add(section));

  void _go(Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label — à venir'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      width: 300,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.divider, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _logoBg,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.family_restroom,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('AMiLY',
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.w800)),
                        Text('Espace Parent',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.secondaryText)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.secondaryText, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // ── Sections ────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                children: [
                  // ── MON ENFANT ──
                  _SectionHeader(
                    label: 'MON ENFANT',
                    expanded: _expanded.contains('MON ENFANT'),
                    onTap: () => _toggle('MON ENFANT'),
                  ),
                  if (_expanded.contains('MON ENFANT')) ...[
                    _DrawerItem(
                      icon: Icons.grid_view_rounded,
                      label: 'Tableau de bord',
                      isActive: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    _DrawerItem(
                      icon: Icons.assignment_outlined,
                      label: 'Journal quotidien',
                      onTap: () => _go(const ChildDiaryPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.fact_check_outlined,
                      label: 'Feuilles de présence',
                      onTap: () => _stub('Feuilles de présence'),
                    ),
                    _DrawerItem(
                      icon: Icons.calendar_month_outlined,
                      label: 'Planning annuel',
                      onTap: () => _go(const PlanningPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.menu_book_outlined,
                      label: "Livre de l'année",
                      onTap: () => _go(const BookYearPage()),
                    ),
                  ],

                  // ── TROUVER UNE ASSISTANTE ──
                  _SectionHeader(
                    label: 'TROUVER UNE ASSISTANTE',
                    expanded: _expanded.contains('TROUVER'),
                    onTap: () => _toggle('TROUVER'),
                  ),
                  if (_expanded.contains('TROUVER')) ...[
                    _DrawerItem(
                      icon: Icons.search_rounded,
                      label: 'Recherche',
                      badgeCount: 2,
                      onTap: () => _go(const FindChildminderPage()),
                    ),
                  ],

                  // ── GESTION ADMINISTRATIVE ──
                  _SectionHeader(
                    label: 'GESTION ADMINISTRATIVE',
                    expanded: _expanded.contains('GESTION'),
                    onTap: () => _toggle('GESTION'),
                  ),
                  if (_expanded.contains('GESTION')) ...[
                    _DrawerItem(
                      icon: Icons.article_outlined,
                      label: 'Contrat & Pajemploi',
                      onTap: () => _go(const ContractPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.credit_card_outlined,
                      label: 'Paiements',
                      onTap: () => _go(const PaymentsPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.description_outlined,
                      label: 'Documents signés',
                      onTap: () => _go(const DocumentsPage()),
                    ),
                  ],

                  // ── COMMUNICATION ──
                  _SectionHeader(
                    label: 'COMMUNICATION',
                    expanded: _expanded.contains('COMMUNICATION'),
                    onTap: () => _toggle('COMMUNICATION'),
                  ),
                  if (_expanded.contains('COMMUNICATION')) ...[
                    _DrawerItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Messages',
                      onTap: () => _go(const MessagesPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.smart_toy_outlined,
                      label: 'Assistant AMiLY',
                      onTap: () => _go(const AssistantPage()),
                    ),
                  ],

                  // ── COMPTE ──
                  _SectionHeader(
                    label: 'COMPTE',
                    expanded: _expanded.contains('COMPTE'),
                    onTap: () => _toggle('COMPTE'),
                  ),
                  if (_expanded.contains('COMPTE')) ...[
                    _DrawerItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Mon profil',
                      onTap: () => _go(const ParentProfilePage()),
                    ),
                    _DrawerItem(
                      icon: Icons.sell_outlined,
                      label: 'Tarifs & abonnement',
                      onTap: () => _stub('Tarifs & abonnement'),
                    ),
                  ],
                ],
              ),
            ),

            // ── Déconnexion — épinglé en bas ─────────
            const Divider(height: 1, color: AppColors.divider),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Déconnexion',
              isSpecial: true,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Se déconnecter ?'),
                    content: const Text(
                      'Vous devrez vous reconnecter pour accéder à votre compte.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annuler'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Se déconnecter'),
                      ),
                    ],
                  ),
                );
                if (!context.mounted) return;
                Navigator.of(context).pop(); // ferme le drawer
                if (confirm == true) {
                  await ref.read(authRepositoryProvider).signOut();
                }
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
            _UserCard(
              displayName: ref.watch(currentUserProvider).valueOrNull?.displayName ?? 'Utilisateur',
              role: 'Parent',
              photoUrl: ref.watch(parentProfileProvider).valueOrNull?.photoUrl,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.expanded,
    required this.onTap,
  });
  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_right_rounded,
              size: 18,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Drawer item ──────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isSpecial = false,
    this.badgeCount,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isSpecial;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final fg = isActive
        ? AppColors.primary
        : isSpecial
            ? AppColors.accent
            : AppColors.primaryText;
    final iconColor = isActive
        ? AppColors.primary
        : isSpecial
            ? AppColors.accent
            : AppColors.secondaryText;
    final bg = isActive
        ? AppColors.primary.withValues(alpha: 0.08)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: fg,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (badgeCount != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    alignment: Alignment.center,
                    child: Text(
                      '$badgeCount',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── User card ───────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({required this.displayName, required this.role, this.photoUrl});
  final String displayName;
  final String role;
  final String? photoUrl;

  String get _initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                role,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    const bg = Color(0xFFF5C6B8);
    const fg = Color(0xFF8B4A35);
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initialsWidget(bg, fg),
          errorWidget: (_, __, ___) => _initialsWidget(bg, fg),
        ),
      );
    }
    return _initialsWidget(bg, fg);
  }

  Widget _initialsWidget(Color bg, Color fg) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTextStyles.labelLarge.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
