import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/profile_form_field.dart';

/// Écran de création de l'engagement réciproque en 6 étapes.
class EngagementContractPage extends StatefulWidget {
  const EngagementContractPage({
    super.key,
    this.assmatName,
    this.assmatPhotoUrl,
  });

  final String? assmatName;
  final String? assmatPhotoUrl;

  @override
  State<EngagementContractPage> createState() => _EngagementContractPageState();
}

class _EngagementContractPageState extends State<EngagementContractPage> {
  int _step = 1;

  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _dateNaissanceCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _cpCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nPajemploiCtrl = TextEditingController();
  final _nomAmCtrl = TextEditingController();
  final _prenomAmCtrl = TextEditingController();
  final _agrementCtrl = TextEditingController();
  final _dateEmbaucheCtrl = TextEditingController();
  final _finContratCtrl = TextEditingController();
  final _periodeEssaiCtrl = TextEditingController();
  final _nomEnfantCtrl = TextEditingController();
  final _prenomEnfantCtrl = TextEditingController();
  final _dateNaissanceEnfantCtrl = TextEditingController();

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _dateNaissanceCtrl.dispose();
    _adresseCtrl.dispose();
    _cpCtrl.dispose();
    _villeCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _nPajemploiCtrl.dispose();
    _nomAmCtrl.dispose();
    _prenomAmCtrl.dispose();
    _agrementCtrl.dispose();
    _dateEmbaucheCtrl.dispose();
    _finContratCtrl.dispose();
    _periodeEssaiCtrl.dispose();
    _nomEnfantCtrl.dispose();
    _prenomEnfantCtrl.dispose();
    _dateNaissanceEnfantCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 6) {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engagement & Contrat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 24),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return _Step1(
          assmatName: widget.assmatName ?? 'l\'assistante maternelle',
          assmatPhotoUrl: widget.assmatPhotoUrl,
          onCreateEngagement: _next,
        );
      case 2:
        return _Step2(controllers: _Step2Controllers(
          nom: _nomCtrl,
          prenom: _prenomCtrl,
          dateNaissance: _dateNaissanceCtrl,
          adresse: _adresseCtrl,
          cp: _cpCtrl,
          ville: _villeCtrl,
          tel: _telCtrl,
          email: _emailCtrl,
          nPajemploi: _nPajemploiCtrl,
        ));
      case 3:
        return _Step3(controllers: _Step3Controllers(
          nom: _nomAmCtrl,
          prenom: _prenomAmCtrl,
          agrement: _agrementCtrl,
        ));
      case 4:
        return _Step4(controllers: _Step4Controllers(
          nomEnfant: _nomEnfantCtrl,
          prenomEnfant: _prenomEnfantCtrl,
          dateNaissance: _dateNaissanceEnfantCtrl,
          dateEmbauche: _dateEmbaucheCtrl,
          finContrat: _finContratCtrl,
          periodeEssai: _periodeEssaiCtrl,
        ));
      case 5:
        return _Step5();
      case 6:
        return _Step6();
      default:
        return const SizedBox.shrink();
    }
  }

  static const _steps = <_StepMeta>[
    _StepMeta(icon: Icons.favorite, label: 'Match'),
    _StepMeta(icon: Icons.handshake_outlined, label: 'Engagement'),
    _StepMeta(icon: Icons.edit_note_rounded, label: 'Signature'),
    _StepMeta(icon: Icons.description_outlined, label: 'Contrat'),
    _StepMeta(icon: Icons.edit_note_rounded, label: 'Signature'),
    _StepMeta(icon: Icons.check_circle_outlined, label: 'Actif'),
  ];

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: AppColors.surface,
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final prev = i ~/ 2;
            final done = prev < _step;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? AppColors.success : AppColors.divider,
              ),
            );
          }
          final idx = i ~/ 2;
          final step = _steps[idx];
          final isActive = idx + 1 == _step;
          final isDone = idx + 1 < _step;
          return _StepCircle(
            icon: step.icon,
            label: step.label,
            isActive: isActive,
            isDone: isDone,
          );
        }),
      ),
    );
  }

}

// ─── Step 1 : Match confirmé ──────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  const _Step1({
    required this.assmatName,
    this.assmatPhotoUrl,
    required this.onCreateEngagement,
  });

  final String assmatName;
  final String? assmatPhotoUrl;
  final VoidCallback onCreateEngagement;

  String get _initials {
    final parts = assmatName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return assmatName.isNotEmpty ? assmatName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Match confirmé !',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Vous et $assmatName avez validé la mise en relation.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        // ── Carte récapitulatif assmat ──────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  // Photo / initiales
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.secondary,
                    backgroundImage: assmatPhotoUrl != null
                        ? NetworkImage(assmatPhotoUrl!)
                        : null,
                    child: assmatPhotoUrl == null
                        ? Text(
                            _initials,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assmatName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Assistante maternelle agréée',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge match validé
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          'Match',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onCreateEngagement,
            icon: const Icon(Icons.handshake_outlined, size: 18),
            label: const Text('Créer l\'engagement réciproque'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 2 : Engagement — Particulier employeur ─────────────────────────────

class _Step2Controllers {
  _Step2Controllers({
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.adresse,
    required this.cp,
    required this.ville,
    required this.tel,
    required this.email,
    required this.nPajemploi,
  });
  final TextEditingController nom;
  final TextEditingController prenom;
  final TextEditingController dateNaissance;
  final TextEditingController adresse;
  final TextEditingController cp;
  final TextEditingController ville;
  final TextEditingController tel;
  final TextEditingController email;
  final TextEditingController nPajemploi;
}

class _Step2 extends StatelessWidget {
  const _Step2({required this.controllers});
  final _Step2Controllers controllers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Particulier employeur',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Renseignez vos informations en tant que parent employeur',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfileFormField(
          controller: controllers.nom,
          label: 'Nom',
          required: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.prenom,
          label: 'Prénom',
          required: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.dateNaissance,
          label: 'Date de naissance',
          hintText: 'JJ/MM/AAAA',
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.adresse,
          label: 'Adresse',
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: ProfileFormField(
                controller: controllers.cp,
                label: 'Code postal',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ProfileFormField(
                controller: controllers.ville,
                label: 'Ville',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: ProfileFormField(
                controller: controllers.tel,
                label: 'Téléphone',
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ProfileFormField(
                controller: controllers.email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.nPajemploi,
          label: 'N° Pajemploi',
        ),
      ],
    );
  }
}

// ─── Step 3 : Signature — Assistant maternel ──────────────────────────────────

class _Step3Controllers {
  _Step3Controllers({
    required this.nom,
    required this.prenom,
    required this.agrement,
  });
  final TextEditingController nom;
  final TextEditingController prenom;
  final TextEditingController agrement;
}

class _Step3 extends StatelessWidget {
  const _Step3({required this.controllers});
  final _Step3Controllers controllers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assistant maternel',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Informations de l\'assistante maternelle',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfileFormField(
          controller: controllers.nom,
          label: 'Nom',
          required: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.prenom,
          label: 'Prénom',
          required: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.agrement,
          label: "Numéro d'agrément",
          hintText: 'Ex: 12345',
        ),
      ],
    );
  }
}

// ─── Step 4 : Contrat — Enfant & Dates ────────────────────────────────────────

class _Step4Controllers {
  _Step4Controllers({
    required this.nomEnfant,
    required this.prenomEnfant,
    required this.dateNaissance,
    required this.dateEmbauche,
    required this.finContrat,
    required this.periodeEssai,
  });
  final TextEditingController nomEnfant;
  final TextEditingController prenomEnfant;
  final TextEditingController dateNaissance;
  final TextEditingController dateEmbauche;
  final TextEditingController finContrat;
  final TextEditingController periodeEssai;
}

class _Step4 extends StatelessWidget {
  const _Step4({required this.controllers});
  final _Step4Controllers controllers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enfant & engagement',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Identité de l\'enfant et dates du contrat',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfileFormField(
          controller: controllers.nomEnfant,
          label: "Nom de l'enfant",
          required: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.prenomEnfant,
          label: "Prénom de l'enfant",
          required: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.dateNaissance,
          label: 'Date de naissance',
          hintText: 'JJ/MM/AAAA',
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Dates du contrat',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.dateEmbauche,
          label: "Date d'embauche",
          hintText: 'JJ/MM/AAAA',
          required: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.finContrat,
          label: 'Fin prévue',
          hintText: 'JJ/MM/AAAA (optionnel)',
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          controller: controllers.periodeEssai,
          label: 'Durée période d\'essai',
          hintText: 'Ex: 3 mois',
        ),
      ],
    );
  }
}

// ─── Step 5 : Rémunération ─────────────────────────────────────────────────────

class _Step5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rémunération',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Les informations de rémunération seront disponibles dans une prochaine version',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

// ─── Step 6 : Récapitulatif ────────────────────────────────────────────────────

/// Métadonnée d'une étape dans le wizard.
class _StepMeta {
  const _StepMeta({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Cercle d'étape avec icône et label.
class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (isActive) {
      color = AppColors.success;
    } else if (isDone) {
      color = AppColors.success;
    } else {
      color = AppColors.divider;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive || isDone
                  ? color
                  : Colors.transparent,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isActive || isDone ? Colors.white : AppColors.divider,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive
                  ? AppColors.success
                  : isDone
                      ? AppColors.success
                      : AppColors.secondaryText,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Step6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Récapitulatif',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Vérifiez vos informations avant de finaliser l\'engagement',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
