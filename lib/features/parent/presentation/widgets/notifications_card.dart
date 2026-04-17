import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Carte "Informations" du dashboard — liste des notifications du parent.
///
/// Header : icône cloche orange + titre "Informations".
/// Empty state : grosse cloche grise + message.
///
/// TODO: quand la couche data notifications sera prête, afficher la liste
/// à la place de l'empty state.
class NotificationsCard extends StatelessWidget {
  const NotificationsCard({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header : cloche orange + "Informations"
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Informations', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Empty state
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.hint,
                  size: 64,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Aucune notification pour le moment',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
