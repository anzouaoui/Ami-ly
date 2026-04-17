import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'interest_tag_chip.dart';
import 'profile_form_field.dart';

/// Données d'un enfant pour l'écran de profil (mock UI uniquement).
///
/// Remplacer par une vraie entité `Child` quand la couche data sera prête.
class ChildProfileData {
  const ChildProfileData({
    required this.name,
    required this.age,
    required this.description,
    required this.interests,
  });

  final String name;
  final String age;
  final String description;
  final List<String> interests;
}

/// Carte d'un enfant : header (icône + nom + suppression), sous-titre,
/// form fields, et section "Ce qu'il/elle aime" avec tags + "+ Ajouter".
class ChildProfileCard extends StatelessWidget {
  const ChildProfileCard({
    super.key,
    required this.child,
    required this.onRemove,
    required this.onAddInterest,
    required this.onRemoveInterest,
  });

  final ChildProfileData child;
  final VoidCallback onRemove;
  final VoidCallback onAddInterest;
  final ValueChanged<String> onRemoveInterest;

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
          // Header : icône + nom + bouton close
          Row(
            children: [
              const Icon(
                Icons.child_care_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(child.name, style: AppTextStyles.titleMedium),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.secondaryText,
                  size: 22,
                ),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Retirer',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Informations et centres d\'intérêt',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Fields
          ProfileFormField(
            label: 'Prénom de l\'enfant',
            initialValue: child.name,
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(label: 'Âge', initialValue: child.age),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
            label: 'Description',
            initialValue: child.description,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),

          // "Ce qu'il/elle aime" + tags + Ajouter
          Row(
            children: [
              const Icon(
                Icons.favorite_rounded,
                color: AppColors.accent,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Ce qu\'il/elle aime',
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final tag in child.interests)
                InterestTagChip(
                  label: tag,
                  onRemove: () => onRemoveInterest(tag),
                ),
              _AddInterestButton(onTap: onAddInterest),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bouton "+ Ajouter" dans la liste de tags (même taille qu'un [InterestTagChip]).
class _AddInterestButton extends StatelessWidget {
  const _AddInterestButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_rounded,
              size: 16,
              color: AppColors.secondaryText,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Ajouter',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
