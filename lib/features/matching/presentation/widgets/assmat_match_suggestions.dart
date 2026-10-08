import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/match_suggestion.dart';
import '../providers/matching_providers.dart';
import 'match_suggestions_section.dart';

/// Carte "Familles en recherche près de chez vous" pour le dashboard assmat.
class AssmatMatchSuggestionsCard extends ConsumerWidget {
  const AssmatMatchSuggestionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(assmatMatchesProvider);

    return suggestions.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) => MatchSuggestionsSection(
        headerIcon: Icons.people_alt_outlined,
        headerIconColor: AppColors.primary,
        title: 'Familles en recherche près de chez vous',
        onRefresh: () => triggerAssmatMatching(ref),
        emptyState: const MatchSuggestionsEmptyState(
          icon: Icons.people_outline_rounded,
          title: 'Aucune famille trouvée',
          message: 'Activez votre profil dans les paramètres pour apparaître '
              'dans les recherches.',
        ),
        items: list
            .take(kDashboardSuggestionsLimit)
            .map((s) => _AssmatMatchCard(suggestion: s))
            .toList(),
      ),
    );
  }
}

class _AssmatMatchCard extends StatelessWidget {
  const _AssmatMatchCard({required this.suggestion});

  final MatchSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final reasons = suggestion.reasons;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFFF3E0),
                child: const Icon(Icons.person_rounded,
                    size: 18, color: Color(0xFFF57C00)),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Familles en recherche près de chez vous',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (suggestion.distanceKm != null)
                    Text(
                      'À ${suggestion.distanceKm!.toStringAsFixed(1)} km',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                '${(suggestion.score * 100).round()}%',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: reasons.map((r) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  r.name,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
