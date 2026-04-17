import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Carte "Statut de recherche" : pastille rouge + texte + toggle.
///
/// Quand le toggle est ON (défaut), le parent n'apparaît plus dans les
/// recherches des assistantes maternelles. Carte teintée rouge clair
/// pour signaler l'état "inactif".
class SearchStatusCard extends StatelessWidget {
  const SearchStatusCard({
    super.key,
    required this.isPaused,
    required this.onChanged,
  });

  final bool isPaused;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pastille rouge
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Titre + sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ne recherche plus',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Vous n\'apparaissez plus dans les recherches',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Toggle rouge
          Switch(
            value: isPaused,
            onChanged: onChanged,
            activeColor: AppColors.error,
            activeTrackColor: AppColors.error.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
