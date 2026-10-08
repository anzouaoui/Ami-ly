import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../features/parent/presentation/pages/childminder_profile_page.dart';
import '../../../../features/parent/presentation/providers/favorites_provider.dart';
import '../../../../features/parent/presentation/widgets/childminder_card.dart';
import '../../../../shared/utils/assmat_display.dart';
import '../../data/models/match_suggestion.dart';
import '../helpers/match_display.dart';
import '../providers/matching_providers.dart';
import 'match_reason_chip.dart';
import 'match_suggestions_section.dart';

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
      // Ne pas filtrer les vides ici pour montrer l'empty state
      data: (list) => MatchSuggestionsSection(
        headerIcon: Icons.auto_awesome_rounded,
        headerIconColor: AppColors.accent,
        title: 'Suggestions personnalisées',
        onRefresh: () => triggerParentMatching(ref),
        emptyState: const _ParentEmptyState(),
        items: list
            .take(kDashboardSuggestionsLimit)
            .map((s) => MatchSuggestionCard(
                  suggestion: s,
                  isFavorite: favoriteIds.contains(s.assmatUid),
                  onToggleFavorite: () =>
                      toggleFavoriteWithFeedback(ref, s.assmatUid, context),
                  onTap: () => _openChildminderProfile(context, s),
                ))
            .toList(),
        footer: list.length > kDashboardSuggestionsLimit
            ? TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _AllSuggestionsPage(),
                    ),
                  );
                },
                child: const Text('Voir toutes les suggestions'),
              )
            : null,
      ),
    );
  }

  /// Ouvre la fiche de l'assmat suggérée (si son profil est chargé).
  void _openChildminderProfile(BuildContext context, MatchSuggestion s) {
    final assmat = s.assmatProfile;
    if (assmat == null) return;

    final firstName = assmat.firstName;
    final city = cityFromAddress(assmat.address);
    final years = assmat.yearsExperience;
    final slots = assmat.availableSlots;

    final summary = ChildminderSummary(
      uid: s.assmatUid,
      initials: firstNameInitial(firstName),
      name: assmatDisplayName(firstName),
      location: city.isNotEmpty ? city : 'Ville non renseignée',
      distance: s.distanceKm != null
          ? '${s.distanceKm!.toStringAsFixed(1)} km'
          : '—',
      experience: years > 0
          ? '$years an${years > 1 ? 's' : ''}'
          : 'Exp. non renseignée',
      places: slots > 0 ? '$slots place${slots > 1 ? 's' : ''}' : 'Complet',
      date: slots > 0 ? 'Disponible' : 'Complet',
      cert: '—',
      photoUrl: assmat.photoUrl,
      isVerified: assmat.isFullyVerified,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChildminderProfilePage(data: summary),
      ),
    );
  }
}

class _ParentEmptyState extends StatelessWidget {
  const _ParentEmptyState();

  @override
  Widget build(BuildContext context) {
    return const MatchSuggestionsEmptyState(
      icon: Icons.search_off_rounded,
      title: 'Aucune suggestion pour le moment',
      message: 'Complétez votre profil et activez la recherche pour recevoir '
          'des suggestions.',
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
              child: _ParentEmptyState(),
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
                // TODO: navigation vers la fiche non branchée sur cette page
                // (comportement existant conservé lors du refactoring).
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
