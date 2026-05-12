import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Page de complétion du profil parent — affichée une seule fois après
/// l'inscription, tant que [AppUser.isProfileComplete] est `false`.
///
/// Collecte :
///   - Adresse (requise — utilisée pour la recherche de proximité)
///   - Description de la famille (optionnelle — visible par les assmats)
///
/// À la soumission, `completeParentOnboarding` met à jour `parents/{uid}`
/// et passe `isProfileComplete = true` dans `users/{uid}`.
/// Le stream [currentUserProvider] réagit et [AuthWrapper] navigue vers
/// [ParentShell] automatiquement.
class ParentOnboardingPage extends ConsumerStatefulWidget {
  const ParentOnboardingPage({super.key});

  @override
  ConsumerState<ParentOnboardingPage> createState() =>
      _ParentOnboardingPageState();
}

class _ParentOnboardingPageState extends ConsumerState<ParentOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(authRepositoryProvider)
        .completeParentOnboarding(
          uid: user.uid,
          address: _addressCtrl.text.trim(),
          familyDescription: _descriptionCtrl.text.trim(),
        );

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _loading = false;
      }),
      // Succès : watchCurrentUser émet le user avec isProfileComplete = true,
      // AuthWrapper bascule vers ParentShell automatiquement.
      (_) => setState(() => _loading = false),
    );
  }

  String get _firstName {
    final displayName =
        ref.read(currentUserProvider).valueOrNull?.displayName ?? '';
    if (displayName.isEmpty) return '';
    return displayName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              _Header(firstName: _firstName),
              const SizedBox(height: AppSpacing.xl),
              _StepIndicator(current: 1, total: 1),
              const SizedBox(height: AppSpacing.xl),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Adresse ──────────────────────────────────────────────
                    _FieldLabel(
                      label: 'Votre adresse',
                      hint: 'Utilisée pour trouver des assistantes proches de chez vous',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _addressCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.streetAddress,
                      autofillHints: const [AutofillHints.fullStreetAddress],
                      decoration: const InputDecoration(
                        hintText: '12 rue des Lilas, 75011 Paris',
                      ),
                      validator: (v) => (v == null || v.trim().length < 5)
                          ? 'Adresse requise'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Description ───────────────────────────────────────────
                    _FieldLabel(
                      label: 'Présentez votre famille',
                      hint: 'Optionnel — visible par les assistantes maternelles',
                      icon: Icons.favorite_outline_rounded,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _descriptionCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: const InputDecoration(
                        hintText:
                            'Ex : Famille de 4 personnes, nous recherchons une assistante attentionnée pour notre fille de 18 mois...',
                        alignLabelWithHint: true,
                      ),
                    ),

                    // ── Erreur ────────────────────────────────────────────────
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // ── Bouton ────────────────────────────────────────────────
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Commencer'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets locaux ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.family_restroom_rounded,
            size: 36,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          firstName.isNotEmpty
              ? 'Bienvenue, $firstName !'
              : 'Bienvenue sur AMiLY !',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Complétez votre profil pour trouver\nune assistante maternelle près de chez vous.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryText,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i + 1 == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
        );
      }),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.hint,
    required this.icon,
  });
  final String label;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              const SizedBox(height: 2),
              Text(
                hint,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
