import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/match_reason.dart';
import '../../data/models/match_suggestion.dart';

const _reasonConfig = <MatchReason, _ReasonConfig>{
  MatchReason.locationProximity: _ReasonConfig(
    Icons.near_me_rounded,
    'Proximité',
    AppColors.primary,
  ),
  MatchReason.ageCompatibility: _ReasonConfig(
    Icons.child_care_rounded,
    'Âge compatible',
    AppColors.success,
  ),
  MatchReason.serviceMatch: _ReasonConfig(
    Icons.task_alt_rounded,
    'Services',
    AppColors.success,
  ),
  MatchReason.scheduleMatch: _ReasonConfig(
    Icons.schedule_rounded,
    'Horaires flexibles',
    AppColors.accent,
  ),
  MatchReason.availabilityMatch: _ReasonConfig(
    Icons.event_available_rounded,
    'Places dispo.',
    AppColors.success,
  ),
  MatchReason.favorite: _ReasonConfig(
    Icons.favorite_rounded,
    'Favori',
    Colors.redAccent,
  ),
};

class _ReasonConfig {
  const _ReasonConfig(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
}

/// Chip affichant la raison du match.
class MatchReasonChip extends StatelessWidget {
  const MatchReasonChip({super.key, required this.reason});

  final MatchReason reason;

  @override
  Widget build(BuildContext context) {
    final cfg = _reasonConfig[reason] ?? _ReasonConfig(
      Icons.check_rounded,
      reason.name,
      AppColors.secondaryText,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 12, color: cfg.color),
          const SizedBox(width: 4),
          Text(
            cfg.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: cfg.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de suggestion de match pour le parent (profil assmat suggéré).
class MatchSuggestionCard extends StatelessWidget {
  const MatchSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final MatchSuggestion suggestion;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  /// Extrait la ville depuis l'adresse complète.
  String _extractCity(String address) {
    if (address.isEmpty) return '';
    final parts = address.split(',');
    return parts.last.trim();
  }

  @override
  Widget build(BuildContext context) {
    final assmat = suggestion.assmatProfile;
    final firstName = assmat != null ? assmat.firstName : '';
    final name = firstName.isNotEmpty ? firstName : 'Assistante maternelle';
    final initials = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
    final city = assmat != null ? _extractCity(assmat.address) : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  // Avatar avec flou
                  ClipOval(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.assmatIconBg,
                          child: Text(
                            initials,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (assmat?.photoUrl != null &&
                            assmat!.photoUrl!.isNotEmpty)
                          Positioned.fill(
                            child: ClipOval(
                              child: Stack(
                                children: [
                                  Image.network(
                                    assmat.photoUrl!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned.fill(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 6, sigmaY: 6),
                                      child: Container(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.lock_outline_rounded,
                                          color:
                                              Colors.white.withValues(alpha: 0.9),
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.titleMedium),
                        if (city.isNotEmpty)
                          Text(
                            city,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onToggleFavorite != null)
                    GestureDetector(
                      onTap: onToggleFavorite,
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: isFavorite
                            ? Colors.redAccent
                            : AppColors.secondaryText,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: suggestion.reasons
                    .map((r) => MatchReasonChip(reason: r))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Voir le profil',
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
            ],
          ),
        ),
      ),
    );
  }
}
