import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Titre de section du panneau de filtres : icône colorée + label.
///
/// Utilisé pour "Périmètre de recherche", "Disponibilité souhaitée",
/// "Services proposés", "Horaires", etc.
class FilterSectionTitle extends StatelessWidget {
  const FilterSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
  });

  final IconData icon;
  final String title;

  /// Override optionnel de la couleur d'icône (défaut : primary).
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
