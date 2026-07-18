import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../features/parent/presentation/pages/childminder_profile_page.dart';
import '../../../../features/parent/presentation/providers/favorites_provider.dart';
import '../../../../features/parent/presentation/widgets/childminder_card.dart';
import '../providers/matching_providers.dart';
import 'match_reason_chip.dart';

/// Carte "Suggestions personnalisées" pour le dashboard parent.
class ParentMatchSuggestionsCard extends ConsumerWidget {
  const ParentMatchSuggestionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(parentMatchesProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider).valueOrNull ?? {};

    return suggestions.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        // Ne pas filtrer les vides ici pour montrer l'empty state
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(onRefresh: () => triggerParentMatching(ref)),
                if (list.isEmpty)
                  const _EmptyState()
                else
                  ...list.take(5).map((s) => Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
                    ),
                    child: MatchSuggestionCard(
                      suggestion: s,
                      isFavorite: favoriteIds.contains(s.assmatUid),
                      onToggleFavorite: () =>
                          toggleFavoriteWithFeedback(ref, s.assmatUid, context),
                      onTap: () {
                        if (s.assmatProfile == null) return;
                        final summary = ChildminderSummary(
                          uid: s.assmatUid,
                          initials: s.assmatProfile!.firstName.isNotEmpty
                              ? s.assmatProfile!.firstName[0].toUpperCase()
                              : '?',
                          name: '${s.assmatProfile!.firstName} ${s.assmatProfile!.lastName}'.trim(),
                          location: s.assmatProfile!.address,
                          distance: s.distanceKm != null
                              ? '${s.distanceKm!.toStringAsFixed(1)} km'
                              : '—',
                          experience: s.assmatProfile!.yearsExperience > 0
                              ? '${s.assmatProfile!.yearsExperience} an${s.assmatProfile!.yearsExperience > 1 ? 's' : ''}'
                              : 'Exp. non renseignée',
                          places: s.assmatProfile!.availableSlots > 0
                              ? '${s.assmatProfile!.availableSlots} place${s.assmatProfile!.availableSlots > 1 ? 's' : ''}'
                              : 'Complet',
                          date: s.assmatProfile!.availableSlots > 0
                              ? 'Disponible'
                              : 'Complet',
                          cert: '—',
                          photoUrl: s.assmatProfile!.photoUrl,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChildminderProfilePage(data: summary),
                          ),
                        );
                      },
                    ),
                  )),
                if (list.length > 5)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const _AllSuggestionsPage(),
                          ),
                        );
                      },
                      child: const Text('Voir toutes les suggestions'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 20, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child:             Text(
              'Suggestions personnalisées',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              padding: EdgeInsets.zero,
              tooltip: 'Actualiser',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: AppColors.secondaryText,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Aucune suggestion pour le moment',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complétez votre profil et activez la recherche pour recevoir des suggestions.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AllSuggestionsPage extends ConsumerWidget {
  const _AllSuggestionsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(parentMatchesProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider).valueOrNull ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Suggestions')),
      body: suggestions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: _EmptyState(),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) {
              final s = list[i];
              return MatchSuggestionCard(
                suggestion: s,
                isFavorite: favoriteIds.contains(s.assmatUid),
                onToggleFavorite: () =>
                    toggleFavoriteWithFeedback(ref, s.assmatUid, context),
                onTap: () {
                  // Similar navigation as above
                },
              );
            },
          );
        },
      ),
    );
  }
}
