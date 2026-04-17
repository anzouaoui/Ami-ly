import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'profile_form_field.dart';

/// Carte "Informations personnelles" du profil parent.
///
/// Contient : header icône+titre, avatar avec bouton "Changer la photo",
/// et les champs Prénom / Nom / Téléphone / Email / Adresse.
class PersonalInfoCard extends StatelessWidget {
  const PersonalInfoCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.onChangePhoto,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final VoidCallback onChangePhoto;

  String get _initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.sm,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Informations personnelles',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Avatar + bouton changer photo
          Row(
            children: [
              _Avatar(initials: _initials),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton(
                      onPressed: onChangePhoto,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      child: const Text('Changer la photo'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'JPG, PNG. 5 Mo max.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Form fields
          ProfileFormField(label: 'Prénom', initialValue: firstName),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(label: 'Nom', initialValue: lastName),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
            label: 'Téléphone',
            initialValue: phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
            label: 'Email',
            initialValue: email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(label: 'Adresse', initialValue: address),
        ],
      ),
    );
  }
}

/// Avatar circulaire pêche avec initiales.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.assmatIconBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
