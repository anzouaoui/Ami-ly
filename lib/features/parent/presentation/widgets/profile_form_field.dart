import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Champ de formulaire du profil : label au-dessus + TextField outlined.
///
/// Utilise l'initialValue plutôt qu'un controller externe pour alléger
/// les pages mockées (pas de dispose à gérer). Quand on branchera la
/// persistance, on passera à un [TextEditingController] externe.
class ProfileFormField extends StatelessWidget {
  const ProfileFormField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.enabled = true,
    this.onChanged,
    this.prefixIcon,
    this.required = false,
  });

  final String label;
  final String? initialValue;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  /// Icône optionnelle affichée à gauche dans le champ.
  final IconData? prefixIcon;

  /// Ajoute un astérisque `*` rouge à côté du label pour signaler un
  /// champ requis (cosmétique uniquement — pas de validation attachée).
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primaryText,
            ),
            children: required
                ? [
                    TextSpan(
                      text: ' *',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ]
                : const [],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.secondaryText)
                : null,
          ),
        ),
      ],
    );
  }
}
