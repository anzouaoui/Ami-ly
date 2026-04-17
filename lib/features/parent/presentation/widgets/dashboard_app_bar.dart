import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Header custom du dashboard parent.
///
/// Contenu :
///   - Icône menu (hamburger) à gauche — ouvre le Drawer du Scaffold parent
///   - Logo "AMiLY" centré (carré vert + texte)
///   - SizedBox invisible à droite pour équilibrer optiquement le logo
///
/// Contrairement à une `AppBar` Material classique, ce widget vit **dans**
/// le scroll du body — il défile avec le contenu.
class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

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

          // Logo centré (carré vert + texte AMiLY)
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
                // TODO: remplacer par l'asset du logo réel.
                child: const Icon(
                  Icons.child_care_rounded,
                  color: AppColors.primary,
                  size: 20,
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

          // Balance visuelle du menu à gauche (largeur équivalente)
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}
