import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../notifications/presentation/pages/notifications_page.dart' as real_notif;
import '../../../notifications/presentation/providers/notifications_providers.dart';

/// Header custom du dashboard parent.
///
/// Disposition (spec "Dashboard Parent 2") :
///   - À gauche : icône menu + logo AMiLY (carré vert + texte) côte à côte
///   - À droite : icône notifications avec badge du nombre de contrats en
///     attente de signature de l'assistante maternelle.
///
/// Contrairement à une `AppBar` Material classique, ce widget vit **dans**
/// le scroll du body — il défile avec le contenu.
class DashboardAppBar extends ConsumerWidget {
  const DashboardAppBar({
    super.key,
    required this.onMenuTap,
    this.parentUid,
  });

  final VoidCallback onMenuTap;
  final String? parentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Bloc gauche : menu + logo ---
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  size: 28,
                  color: AppColors.primaryText,
                ),
                onPressed: onMenuTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Menu',
              ),
              const SizedBox(width: AppSpacing.md),
              // Logo (carré vert + texte AMiLY)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                alignment: Alignment.center,
                // TODO: remplacer par l'asset du logo réel.
                child: const Icon(
                  Icons.child_care_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AMiLY',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          // --- Bloc droite : notifications ---
          _ParentNotificationBell(parentUid: parentUid, ref: ref),
        ],
      ),
    );
  }
}

/// Icône de cloche avec badge du nombre de notifications non lues.
class _ParentNotificationBell extends StatelessWidget {
  const _ParentNotificationBell({required this.parentUid, required this.ref});

  final String? parentUid;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 24,
                color: AppColors.primaryText,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const real_notif.NotificationsPage(),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              tooltip: 'Notifications',
            ),
          ),
          if (count > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
