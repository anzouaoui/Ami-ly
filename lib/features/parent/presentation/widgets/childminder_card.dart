import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Résumé d'une assistante maternelle affichée dans la liste de résultats.
class ChildminderSummary {
  const ChildminderSummary({
    required this.uid,
    required this.initials,
    required this.name,
    required this.location,
    required this.distance,
    required this.experience,
    required this.places,
    required this.date,
    required this.cert,
    this.photoUrl,
  });

  /// UID Firestore — utilisé pour naviguer vers le profil complet.
  final String uid;
  final String initials;
  final String name;
  final String location;
  final String distance;
  final String experience;
  final String places;
  final String date;
  final String cert;

  /// URL de la photo de profil (Firebase Storage). Null si non définie.
  final String? photoUrl;
}

/// Carte compacte listée dans la page "Trouver une assistante maternelle".
///
/// Layout :
///   - Avatar initiales pêche en haut à gauche
///   - Nom + localisation + distance + icône favori en haut à droite
///   - Grille 2x2 de pastilles : cert / expérience / places / date
///   - "Voir le profil →" en bas (primary, CTA)
class ChildminderCard extends StatelessWidget {
  const ChildminderCard({
    super.key,
    required this.data,
    required this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final ChildminderSummary data;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
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
            boxShadow: AppShadows.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header : avatar + nom + loc + favori
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(initials: data.initials, photoUrl: data.photoUrl),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.name, style: AppTextStyles.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                '${data.location} • ${data.distance}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onToggleFavorite != null)
                    GestureDetector(
                      onTap: onToggleFavorite,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 22,
                          color: isFavorite
                              ? Colors.redAccent
                              : AppColors.secondaryText,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Grid 2x2 d'infos
              Row(
                children: [
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.workspace_premium_rounded,
                      label: data.cert,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.history_rounded,
                      label: data.experience,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.group_rounded,
                      label: data.places,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.event_rounded,
                      label: data.date,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // CTA
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, this.photoUrl});
  final String initials;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    const bg = AppColors.assmatIconBg;
    const fg = AppColors.primaryText;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initials(bg, fg),
          errorWidget: (_, __, ___) => _initials(bg, fg),
        ),
      );
    }
    return _initials(bg, fg);
  }

  Widget _initials(Color bg, Color fg) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.labelLarge.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondaryText),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primaryText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
