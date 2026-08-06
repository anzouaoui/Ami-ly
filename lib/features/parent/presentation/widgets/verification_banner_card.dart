import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Bandeau de statut de vérification d'une assistante maternelle, affiché
/// en haut du profil vu par un parent.
///
/// - [isVerified] == `true` : teinte claire, coche, message "contrôlés" ;
/// - [isVerified] == `false` : teinte ambre, sablier, message "en cours".
class VerificationBannerCard extends StatelessWidget {
  const VerificationBannerCard({
    super.key,
    required this.isVerified,
    this.verifiedAt,
  });

  /// `true` si le profil est entièrement vérifié (identité, agrément, casier).
  final bool isVerified;

  /// Date de vérification (optionnelle) — affichée sur le bandeau si fournie.
  final DateTime? verifiedAt;

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final icon = isVerified
        ? Icons.verified_rounded
        : Icons.hourglass_bottom_rounded;
    final title = isVerified
        ? 'Profil vérifié'
        : 'Profil en cours de vérification';
    final subtitle = isVerified
        ? 'Identité, agrément et casier judiciaire contrôlés'
        : 'Cette assistante maternelle complète actuellement son '
            'dossier de vérification';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isVerified ? AppColors.secondary : AppColors.statYellowBg,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: isVerified ? AppColors.primary : AppColors.accent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isVerified ? AppColors.primary : AppColors.accent)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: isVerified ? AppColors.primary : AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                if (isVerified && verifiedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Vérifié le ${_dateFmt.format(verifiedAt!)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
