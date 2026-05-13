import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'family_description_section.dart';
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
    this.firstNameController,
    this.lastNameController,
    this.phoneController,
    this.emailController,
    this.addressController,
    this.descriptionController,
    this.avatarBg,
    this.avatarFg,
    this.addressWidget,
    this.descriptionValue,
    this.descriptionLabel,
    this.descriptionHint,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final VoidCallback onChangePhoto;

  /// Controllers optionnels — quand fournis, prennent la main sur les
  /// [initialValue] correspondants (nécessaire pour les données Firestore
  /// chargées de façon asynchrone).
  final TextEditingController? firstNameController;
  final TextEditingController? lastNameController;
  final TextEditingController? phoneController;
  final TextEditingController? emailController;
  final TextEditingController? addressController;
  final TextEditingController? descriptionController;

  /// Couleurs optionnelles de l'avatar — défaut : pêche (parent).
  /// Passer `secondary` / `primary` pour la variante assmat (vert).
  final Color? avatarBg;
  final Color? avatarFg;

  /// Si non null, remplace le [ProfileFormField] de l'adresse par ce widget
  /// (typiquement un [AddressAutocompleteField]).
  final Widget? addressWidget;

  /// Si non null, affiche une section textarea "description" après
  /// le champ Adresse avec compteur de caractères.
  final String? descriptionValue;
  final String? descriptionLabel;
  final String? descriptionHint;

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
              _Avatar(
                initials: _initials,
                bg: avatarBg ?? AppColors.assmatIconBg,
                fg: avatarFg ?? AppColors.primaryText,
              ),
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
          ProfileFormField(
            label: 'Prénom',
            controller: firstNameController,
            initialValue: firstNameController == null ? firstName : null,
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
            label: 'Nom',
            controller: lastNameController,
            initialValue: lastNameController == null ? lastName : null,
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
            label: 'Téléphone',
            controller: phoneController,
            initialValue: phoneController == null ? phone : null,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
            label: 'Email',
            controller: emailController,
            initialValue: emailController == null ? email : null,
            keyboardType: TextInputType.emailAddress,
            enabled: emailController == null,
          ),
          const SizedBox(height: AppSpacing.md),
          addressWidget ??
              ProfileFormField(
                label: 'Adresse',
                controller: addressController,
                initialValue: addressController == null ? address : null,
              ),
          if (descriptionValue != null || descriptionController != null) ...[
            const SizedBox(height: AppSpacing.lg),
            FamilyDescriptionSection(
              controller: descriptionController,
              initialValue: descriptionValue ?? '',
              label: descriptionLabel ?? 'Description',
              hintText: descriptionHint ?? 'Parlez-nous de vous…',
            ),
          ],
        ],
      ),
    );
  }
}

/// Avatar circulaire avec initiales — bg et fg configurables.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.bg,
    required this.fg,
  });

  final String initials;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.titleLarge.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
