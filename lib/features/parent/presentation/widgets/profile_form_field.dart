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
  });

  final String label;
  final String? initialValue;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}
