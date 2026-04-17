import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Carte "Mes données personnelles" : RGPD + actions (télécharger, supprimer).
class PersonalDataCard extends StatelessWidget {
  const PersonalDataCard({
    super.key,
    required this.onDownload,
    required this.onDelete,
    required this.onPrivacyPolicy,
  });

  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final VoidCallback onPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.sm,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header : bouclier vert + titre
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Mes données personnelles',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Info box RGPD (cadenas jaune)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Vos données sont hébergées dans l\'UE et protégées conformément au RGPD.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Télécharger
          OutlinedButton.icon(
            onPressed: onDownload,
            icon: const Icon(Icons.download_rounded, size: 20),
            label: const Text('Télécharger mes données'),
          ),
          const SizedBox(height: AppSpacing.md),

          // Supprimer (rouge)
          FilledButton.icon(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.onError,
              size: 20,
            ),
            label: const Text(
              'Supprimer mon compte',
              style: TextStyle(color: AppColors.onError),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Lien politique de confidentialité
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
              ),
              children: [
                const TextSpan(text: 'Consultez notre '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: onPrivacyPolicy,
                    child: Text(
                      'Politique de confidentialité',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
