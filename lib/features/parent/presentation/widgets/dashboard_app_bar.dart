import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Header custom du dashboard parent.
///
/// Disposition (spec "Dashboard Parent 2") :
///   - À gauche : icône menu + logo AMiLY (carré vert + texte) côte à côte
///   - À droite : icône notifications
///
/// Contrairement à une `AppBar` Material classique, ce widget vit **dans**
/// le scroll du body — il défile avec le contenu.
class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({
    super.key,
    required this.onMenuTap,
    required this.onNotificationsTap,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 24,
              color: AppColors.primaryText,
            ),
            onPressed: onNotificationsTap,
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}
