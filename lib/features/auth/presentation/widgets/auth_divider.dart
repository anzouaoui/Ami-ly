import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Séparateur horizontal avec un label centré, type "─── OU ───".
///
/// Utilisé sur les écrans d'auth pour séparer les méthodes sociales
/// (Google, Apple, ...) de la saisie manuelle email/mot de passe.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Divider(color: AppColors.divider, height: 1, thickness: 1),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.hint),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: Divider(color: AppColors.divider, height: 1, thickness: 1),
        ),
      ],
    );
  }
}
