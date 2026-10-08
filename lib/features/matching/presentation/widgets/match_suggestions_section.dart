import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Nombre de suggestions affichées directement sur les dashboards.
const kDashboardSuggestionsLimit = 5;

/// Cadre commun aux cartes de suggestions des dashboards parent et assmat :
/// en-tête (icône, titre, bouton "Actualiser"), puis soit [items], soit un
/// état vide si [items] est vide, puis [footer] éventuel.
class MatchSuggestionsSection extends StatelessWidget {
  const MatchSuggestionsSection({
    super.key,
    required this.headerIcon,
    required this.headerIconColor,
    required this.title,
    required this.onRefresh,
    required this.emptyState,
    required this.items,
    this.footer,
  });

  final IconData headerIcon;
  final Color headerIconColor;
  final String title;
  final VoidCallback onRefresh;
  final Widget emptyState;
  final List<Widget> items;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
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
            _SectionHeader(
              icon: headerIcon,
              iconColor: headerIconColor,
              title: title,
              onRefresh: onRefresh,
            ),
            if (items.isEmpty)
              emptyState
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
                  ),
                  child: item,
                ),
              ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onRefresh,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
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

/// État vide d'une [MatchSuggestionsSection] : icône, titre et explication.
class MatchSuggestionsEmptyState extends StatelessWidget {
  const MatchSuggestionsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.secondaryText),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
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
