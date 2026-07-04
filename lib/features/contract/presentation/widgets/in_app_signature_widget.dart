import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/contract_form_data.dart';

class SignatureResult {
  const SignatureResult({
    required this.signedName,
    required this.consentText,
  });

  final String signedName;
  final bool smsVerified = false;
  final String consentText;
}

class InAppSignatureWidget extends StatefulWidget {
  const InAppSignatureWidget({
    super.key,
    required this.parentFirstName,
    required this.parentLastName,
    required this.parentUid,
    required this.assmatName,
    required this.contractFormData,
    required this.onSigned,
    this.onError,
    this.customTitle,
    this.customDescription,
  });

  final String parentFirstName;
  final String parentLastName;
  final String parentUid;
  final String assmatName;
  final ContractFormData contractFormData;
  final ValueChanged<SignatureResult> onSigned;
  final void Function(String message)? onError;
  final String? customTitle;
  final String? customDescription;

  @override
  State<InAppSignatureWidget> createState() => _InAppSignatureWidgetState();
}

class _InAppSignatureWidgetState extends State<InAppSignatureWidget> {
  bool _consentChecked = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _expectedName =>
      '${widget.parentFirstName} ${widget.parentLastName}'.trim();

  bool get _nameMatches =>
      _nameController.text.trim().toLowerCase() == _expectedName.toLowerCase();

  bool get _canSign => _consentChecked && _nameMatches;

  void _sign() {
    if (!_canSign) return;

    final result = SignatureResult(
      signedName: _nameController.text.trim(),
      consentText:
          'Je reconnais avoir pris connaissance du contrat '
          "d'engagement réciproque et l'accepter sans réserve.",
    );
    widget.onSigned(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              const Icon(Icons.edit_note_rounded, size: 64, color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.customTitle ?? 'Signature du parent',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.customDescription ??
                    "En signant, vous acceptez les termes de l'engagement "
                    'réciproque avec ${widget.assmatName}.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Zone de signature : nom tapé
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(
                    color: _nameMatches
                        ? AppColors.success
                        : AppColors.divider,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tapez votre nom complet pour signer',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: _expectedName,
                        border: InputBorder.none,
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondaryText.withValues(alpha: 0.5),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_nameController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _nameMatches
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              size: 14,
                              color: _nameMatches
                                  ? AppColors.success
                                  : AppColors.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _nameMatches
                                  ? 'Nom correct'
                                  : 'Le nom ne correspond pas',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _nameMatches
                                    ? AppColors.success
                                    : AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Case à cocher consentement
              Material(
                type: MaterialType.transparency,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _consentChecked,
                  onChanged: (v) => setState(() => _consentChecked = v ?? false),
                  title: Text(
                    "Je reconnais avoir pris connaissance du contrat "
                    "d'engagement réciproque et l'accepter sans réserve.",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Bouton Signer
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canSign ? _sign : null,
                  icon: const Icon(Icons.draw_outlined, size: 20),
                  label: const Text("Signer l'engagement"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
