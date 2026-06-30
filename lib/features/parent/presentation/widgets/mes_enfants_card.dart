import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/child_model.dart';
import '../pages/child_diary_page.dart';
import '../providers/parent_providers.dart';

/// Grande carte blanche "Mes enfants" du dashboard parent.
///
/// Header : icône + titre à gauche, lien "Documents →" à droite.
/// Affiche la liste des enfants connectés avec un bouton raccourci pour leur
/// journal respectif, ou l'état vide si aucun enfant n'est enregistré.
class MesEnfantsCard extends ConsumerWidget {
  const MesEnfantsCard({
    super.key,
    required this.onFindAssmatTap,
    required this.onDocumentsTap,
  });

  final VoidCallback onFindAssmatTap;
  final VoidCallback onDocumentsTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenProvider);

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
          childrenAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(
              child: Text(
                'Impossible de charger les enfants.\n$e',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            data: (children) => children.isEmpty
                ? _EmptyState(onFindAssmatTap: onFindAssmatTap)
                : _ChildrenList(children: children),
          ),
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

class _ChildrenList extends StatelessWidget {
  const _ChildrenList({required this.children});
  final List<ChildModel> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children) ...[
          _ChildRow(child: child),
          if (child != children.last) const Divider(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

class _ChildRow extends StatelessWidget {
  const _ChildRow({required this.child});
  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    final age = child.ageLabel;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.secondary,
          child: const Icon(
            Icons.child_care_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                child.firstName,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (age.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  age,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChildDiaryPage(
                  childName: child.firstName,
                ),
              ),
            );
          },
          icon: const Icon(Icons.menu_book_rounded, size: 16),
          label: const Text('Journal'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
        ),
      ],
    );
  }
}
