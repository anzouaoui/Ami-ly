import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/profile_form_field.dart';

/// Écran de création de l'engagement réciproque en 6 étapes.
class EngagementContractPage extends StatefulWidget {
  const EngagementContractPage({super.key});

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
    super.dispose();
  }

  void _next() {
    if (_step < 6) {
      setState(() => _step++);
    }
  }

  void _prev() {
    if (_step > 1) {
      setState(() => _step--);
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  '$_step/6',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildStepContent(),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return _Step1(controllers: _Step1Controllers(
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
      case 2:
        return _Step2(controllers: _Step2Controllers(
          nom: _nomAmCtrl,
          prenom: _prenomAmCtrl,
          agrement: _agrementCtrl,
        ));
      case 3:
        return _Step3(controllers: _Step3Controllers(
          nomEnfant: _nomEnfantCtrl,
          prenomEnfant: _prenomEnfantCtrl,
          dateNaissance: _dateNaissanceCtrl,
        ));
      case 4:
        return _Step4(controllers: _Step4Controllers(
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

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (_step > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _prev,
                child: const Text('Précédent'),
              ),
            ),
          if (_step > 1) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: FilledButton(
              onPressed: _step < 6 ? _next : () {},
              child: Text(_step < 6 ? 'Suivant' : 'Finaliser'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1 : Particulier employeur ──────────────────────────────────────────────

class _Step1Controllers {
  _Step1Controllers({
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

class _Step1 extends StatelessWidget {
  const _Step1({required this.controllers});
  final _Step1Controllers controllers;

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

// ─── Step 2 : Assistant maternel ───────────────────────────────────────────────

class _Step2Controllers {
  _Step2Controllers({
    required this.nom,
    required this.prenom,
    required this.agrement,
  });
  final TextEditingController nom;
  final TextEditingController prenom;
  final TextEditingController agrement;
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

// ─── Step 3 : Enfant & engagement ──────────────────────────────────────────────

class _Step3Controllers {
  _Step3Controllers({
    required this.nomEnfant,
    required this.prenomEnfant,
    required this.dateNaissance,
  });
  final TextEditingController nomEnfant;
  final TextEditingController prenomEnfant;
  final TextEditingController dateNaissance;
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
          'Enfant & engagement',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Identité de l\'enfant concerné par l\'engagement',
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
      ],
    );
  }
}

// ─── Step 4 : Dates du contrat ─────────────────────────────────────────────────

class _Step4Controllers {
  _Step4Controllers({
    required this.dateEmbauche,
    required this.finContrat,
    required this.periodeEssai,
  });
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
          'Durée et horaires d\'accueil',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Dates et période d\'essai du contrat',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
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
