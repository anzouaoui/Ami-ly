import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Bouton de la liste d'actions rapides du dashboard parent.
///
/// Deux variantes :
///   - [ActionListButton.primary]  : fond vert, texte + icône blancs
///     (utilisé pour l'action principale, ex: "Envoyer un message")
///   - [ActionListButton.outlined] : fond blanc, bordure divider,
///     icône primary, texte dark
///
/// Layout : icône à gauche, label aligné à gauche (Expanded), hauteur
/// confortable pour un tap target mobile.
class ActionListButton extends StatelessWidget {
  const ActionListButton.primary({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : _isPrimary = true;

  const ActionListButton.outlined({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : _isPrimary = false;

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool _isPrimary;

  @override
  Widget build(BuildContext context) {
    final bg = _isPrimary ? AppColors.primary : AppColors.surface;
    final iconColor = _isPrimary ? AppColors.onPrimary : AppColors.primary;
    final textColor = _isPrimary ? AppColors.onPrimary : AppColors.primaryText;
    final borderColor = _isPrimary ? AppColors.primary : AppColors.divider;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.titleMedium.copyWith(color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
