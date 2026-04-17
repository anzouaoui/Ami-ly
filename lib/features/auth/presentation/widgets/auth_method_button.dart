import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Bouton blanc "méthode d'authentification" (Google, Email, Apple...).
///
/// Layout : icône + label centrés horizontalement, fond blanc, bordure subtile,
/// ombre sm pour donner un léger lift. Radius md (16).
class AuthMethodButton extends StatelessWidget {
  const AuthMethodButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  /// Icône libre (Icon, SvgPicture, Image, etc.) — le parent gère sa taille.
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.divider),
            boxShadow: AppShadows.sm,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              icon,
              const SizedBox(width: AppSpacing.md),
              Text(label, style: AppTextStyles.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
