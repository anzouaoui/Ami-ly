import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

Future<void> showInviteParentDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const _InviteParentDialog(),
  );
}

class _InviteParentDialog extends StatefulWidget {
  const _InviteParentDialog();

  @override
  State<_InviteParentDialog> createState() => _InviteParentDialogState();
}

class _InviteParentDialogState extends State<_InviteParentDialog> {
  final _firstNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _childCtrl = TextEditingController();
  final _firstNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _firstNameFocus.requestFocus());
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _childCtrl.dispose();
    _firstNameFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_firstNameCtrl.text.trim().isEmpty) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Invitation envoyée à ${_firstNameCtrl.text.trim()}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row ────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text('Inviter un parent',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Prénom (required) ─────────────────────
            _FieldLabel(label: 'Prénom du parent', required: true),
            const SizedBox(height: 6),
            _DialogField(
              controller: _firstNameCtrl,
              focusNode: _firstNameFocus,
              hint: 'Marie',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Email ─────────────────────────────────
            _FieldLabel(label: 'Email'),
            const SizedBox(height: 6),
            _DialogField(
              controller: _emailCtrl,
              hint: 'marie@email.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Téléphone ─────────────────────────────
            _FieldLabel(label: 'Téléphone'),
            const SizedBox(height: 6),
            _DialogField(
              controller: _phoneCtrl,
              hint: '06 12 34 56 78',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Nom de l'enfant ───────────────────────
            _FieldLabel(label: 'Nom de l\'enfant (optionnel)'),
            const SizedBox(height: 6),
            _DialogField(
              controller: _childCtrl,
              hint: 'Lucas',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Info ──────────────────────────────────
            Text(
              'Un lien sécurisé sera généré et expire après 7 jours.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Submit ────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Envoyer l\'invitation'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  textStyle: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.required = false});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodySmall
            .copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryText),
        children: [
          TextSpan(text: label),
          if (required)
            const TextSpan(
                text: ' *', style: TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.hint,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });
  final TextEditingController controller;
  final String hint;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: AppTextStyles.bodySmall,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.bodySmall.copyWith(color: AppColors.hint),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
