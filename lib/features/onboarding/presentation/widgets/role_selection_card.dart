import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Carte de sélection de rôle utilisée sur la [WelcomePage].
///
/// Layout : icône tintée en haut à gauche, titre, description, CTA
/// "Commencer →" coloré avec la teinte de l'icône.
///
/// Toute la carte est tappable (InkWell) — la ligne "Commencer" est un
/// indicateur visuel, pas un bouton séparé.
class RoleSelectionCard extends StatelessWidget {
  const RoleSelectionCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.divider),
            boxShadow: AppShadows.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône dans carré tinté
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: AppSpacing.md),

              // Titre
              Text(title, style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),

              // Description
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // CTA "Commencer →"
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Commencer',
                    style: AppTextStyles.labelLarge.copyWith(color: iconColor),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.arrow_forward_rounded, color: iconColor, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
