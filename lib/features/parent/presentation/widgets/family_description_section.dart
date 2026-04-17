import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Section "Description de la famille" : label + textarea + compteur de
/// caractères.
///
/// [maxLength] contrôle la limite max (500 par défaut). Le compteur est
/// mis à jour à chaque frappe.
class FamilyDescriptionSection extends StatefulWidget {
  const FamilyDescriptionSection({
    super.key,
    this.initialValue = '',
    this.maxLength = 500,
  });

  final String initialValue;
  final int maxLength;

  @override
  State<FamilyDescriptionSection> createState() =>
      _FamilyDescriptionSectionState();
}

class _FamilyDescriptionSectionState extends State<FamilyDescriptionSection> {
  late int _count = widget.initialValue.length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description de la famille',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: widget.initialValue,
          maxLines: 5,
          maxLength: widget.maxLength,
          // On planque le compteur natif pour afficher le nôtre custom.
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
              const SizedBox.shrink(),
          onChanged: (v) => setState(() => _count = v.length),
          decoration: const InputDecoration(
            hintText: 'Parlez-nous de votre famille…',
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$_count/${widget.maxLength} caractères',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}
