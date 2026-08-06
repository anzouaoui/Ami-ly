import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Tuile « document signé » : contrat final signé par DocuSign, accessible en
/// visualisation et en téléchargement.
///
/// Utilisée côté Parent ET côté Assistante maternelle dans les vues de gestion
/// des documents (« Mon Profil » / « Documents »). `onOpen` est injectable
/// pour les tests (évite d'appeler url_launcher).
class SignedContractPdfTile extends StatelessWidget {
  const SignedContractPdfTile({
    super.key,
    required this.title,
    required this.url,
    this.subtitle,
    this.onOpen,
  });

  /// Libellé du document (ex : « Contrat de travail CDI »).
  final String title;

  /// URL de téléchargement du PDF signé (finalPdfUrl).
  final String url;

  /// Métadonnée affichée sous le titre (ex : « Signé le 06/08/2026 »).
  final String? subtitle;

  /// Callback d'ouverture/téléchargement, injectable pour les tests.
  final Future<void> Function(String url)? onOpen;

  Future<void> _defaultOpen(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final open = onOpen ?? _defaultOpen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: 'Voir / télécharger le document',
            onPressed: () => open(url),
            icon: const Icon(
              Icons.download_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
