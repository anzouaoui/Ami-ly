import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Grande carte blanche "Mes enfants" du dashboard parent.
///
/// Header : icône + titre à gauche, lien "Documents →" à droite.
/// Empty state : cercle tinté + icône bébé, message, bouton primary
/// "Trouver une assistante maternelle".
///
/// Quand la liste d'enfants ne sera plus vide, il faudra remplacer
/// l'empty state par une vraie liste (à faire dans une itération data).
class MesEnfantsCard extends StatelessWidget {
  const MesEnfantsCard({
    super.key,
    required this.onFindAssmatTap,
    required this.onDocumentsTap,
  });

  final VoidCallback onFindAssmatTap;
  final VoidCallback onDocumentsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.sm,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(onDocumentsTap: onDocumentsTap),
          const SizedBox(height: AppSpacing.lg),
          _EmptyState(onFindAssmatTap: onFindAssmatTap),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onDocumentsTap});
  final VoidCallback onDocumentsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icône + titre
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.face_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('Mes enfants', style: AppTextStyles.titleMedium),
          ],
        ),
        // Lien "Documents →"
        InkWell(
          onTap: onDocumentsTap,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Documents',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onFindAssmatTap});
  final VoidCallback onFindAssmatTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cercle tinté avec icône bébé
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.face_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Aucun contrat actif pour le moment.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton(
          onPressed: onFindAssmatTap,
          child: const Text('Trouver une assistante maternelle'),
        ),
      ],
    );
  }
}
