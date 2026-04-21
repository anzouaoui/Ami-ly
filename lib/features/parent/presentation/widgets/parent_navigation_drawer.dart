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

/// Drawer de navigation latéral de l'espace Parent.
///
/// Correspond à la frame "Navigation Menu" du design system :
///   - Header : logo dark + "AMiLY" / "Espace Parent" + close ×
///   - Liste scrollable de rubriques avec états (actif, badge, spécial)
///   - Divider puis 2 items "Vue Assistante" (spécial) + "Déconnexion"
///
/// Largeur fixe à 320 px pour matcher la spec.
class ParentNavigationDrawer extends ConsumerWidget {
  const ParentNavigationDrawer({super.key});

  void _closeAnd(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.background,
      width: 320,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _NavHeader(),

            // --- Liste scrollable ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Tableau de bord',
                    isActive: true,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Mon profil',
                    onTap: () => _closeAnd(context, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ParentProfilePage(),
                        ),
                      );
                    }),
                  ),
                  _NavItem(
                    icon: Icons.search_rounded,
                    label: 'Trouver une assmat',
                    onTap: () => _closeAnd(context, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FindChildminderPage(),
                        ),
                      );
                    }),
                  ),
                  _NavItem(
                    icon: Icons.menu_book_rounded,
                    label: 'Journal de mon enfant',
                    onTap: () => _closeAnd(context, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChildDiaryPage(),
                        ),
                      );
                    }),
                  ),
                  _NavItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Messages',
                    badgeCount: 1,
                    onTap: () => _closeAnd(context, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MessagesPage(),
                        ),
                      );
                    }),
                  ),
                  _NavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Paiements',
                    onTap: () => _closeAnd(context, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaymentsPage(),
                        ),
                      );
                    }),
                  ),
                  _NavItem(
                    icon: Icons.description_outlined,
                    label: 'Documents',
                    onTap: () => _closeAnd(context, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DocumentsPage(),
                        ),
                      );
                    }),
                  ),
                  _NavItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Planning annuel',
                    onTap: () => _closeAnd(context, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PlanningPage(),
                        ),
                      );
                    }),
                  ),
                  _NavItem(
                    icon: Icons.assignment_outlined,
                    label: 'Contrat & Pajemploi',
                    onTap: () => _closeAnd(context, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ContractPage(),
                        ),
                      );
                    }),
                  ),
                  _NavItem(
                    icon: Icons.auto_stories_outlined,
                    label: 'Livre de l\'année',
                    onTap: () => _closeAnd(context, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BookYearPage(),
                        ),
                      );
                    }),
                  ),
                  _NavItem(
                    icon: Icons.smart_toy_outlined,
                    label: 'Assistant AMiLY',
                    onTap: () => _closeAnd(context, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AssistantPage(),
                        ),
                      );
                    }),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(color: AppColors.divider, height: 1),
                  ),

                  _NavItem(
                    icon: Icons.settings_outlined,
                    label: 'Vue Assistante',
                    isSpecial: true,
                    onTap: () => _closeAnd(
                      context,
                      () => _stub(context, 'Vue Assistante'),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.logout_rounded,
                    label: 'Déconnexion',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await ref.read(authRepositoryProvider).signOut();
                      // L'AuthWrapper rebascule sur la WelcomePage via le stream.
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Header : logo carré foncé + "AMiLY" + "Espace Parent" + bouton close.
class _NavHeader extends StatelessWidget {
  const _NavHeader();

  // Couleur brune spécifique à la frame (pas encore dans la palette du design
  // system). À remplacer par un token AppColors.logoBg quand ce sera défini.
  static const _logoBg = Color(0xFF4A3B33);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _logoBg,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  alignment: Alignment.center,
                  // TODO: remplacer par l'asset du logo "mère + bébé" line-art blanc.
                  child: const Icon(
                    Icons.family_restroom,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AMiLY',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Espace Parent',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.secondaryText,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Fermer',
          ),
        ],
      ),
    );
  }
}

/// Ligne de navigation du drawer.
///
/// États :
///   - Normal : icône + texte secondaires
///   - [isActive] : fond vert clair (secondary) + icône et texte primary
///   - [isSpecial] : icône et texte en accent (orange) — pour les actions
///     distinctives comme "Vue Assistante"
///   - [badgeCount] : pastille rouge avec un nombre à droite
class _NavItem extends StatelessWidget {
  const _NavItem({
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
    final bg = isActive ? AppColors.secondary : Colors.transparent;
    final weight = isActive ? FontWeight.w700 : FontWeight.w500;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: fg,
                      fontWeight: weight,
                    ),
                  ),
                ),
                if (badgeCount != null) _Badge(count: badgeCount!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pastille ronde rouge affichant un compteur (ex: messages non lus).
class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      constraints: const BoxConstraints(minWidth: 20),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
