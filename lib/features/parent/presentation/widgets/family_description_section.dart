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
    this.label = 'Description de la famille',
    this.hintText = 'Parlez-nous de votre famille…',
  });

  final String initialValue;
  final int maxLength;

  /// Libellé au-dessus du textarea. Défaut parent : "Description de la famille".
  /// Pour l'assmat : "Description / Présentation".
  final String label;

  /// Placeholder du textarea.
  final String hintText;

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
          widget.label,
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
          decoration: InputDecoration(
            hintText: widget.hintText,
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
