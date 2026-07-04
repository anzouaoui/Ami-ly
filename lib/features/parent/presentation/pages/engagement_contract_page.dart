import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../contract/data/models/contract_form_data.dart';
import '../../../contract/data/models/signature_audit_model.dart';
import '../../../contract/data/services/contract_service.dart';
import '../../../contract/presentation/widgets/in_app_signature_widget.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../auth/data/models/assmat_profile_model.dart';
import '../../../auth/data/models/parent_profile_model.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../parent/data/models/child_model.dart';
import '../../presentation/providers/parent_providers.dart';
import '../widgets/profile_form_field.dart';

/// Données initiales pour pré-remplir le formulaire de l'étape 2.
class _Step2InitialData {
  const _Step2InitialData({
    required this.parentFirstName,
    required this.parentLastName,
    required this.parentAddress,
    required this.parentPhone,
    required this.parentEmail,
    required this.assmatFirstName,
    required this.assmatLastName,
    required this.assmatAddress,
    required this.children,
  });

  final String parentFirstName;
  final String parentLastName;
  final String parentAddress;
  final String parentPhone;
  final String parentEmail;
  final String assmatFirstName;
  final String assmatLastName;
  final String assmatAddress;
  final List<ChildModel> children;
}

/// Écran de création de l'engagement réciproque en 6 étapes.
class EngagementContractPage extends ConsumerStatefulWidget {
  const EngagementContractPage({
    super.key,
    this.assmatUid = '',
    this.assmatName,
    this.assmatPhotoUrl,
  });

  final String assmatUid;
  final String? assmatName;
  final String? assmatPhotoUrl;

  @override
  ConsumerState<EngagementContractPage> createState() => _EngagementContractPageState();
}

class _EngagementContractPageState extends ConsumerState<EngagementContractPage> {
  int _step = 1;
  bool _isSigning = false;
  ContractFormData? _contractFormData;

  @override
  void dispose() {
    super.dispose();
  }

  void _next() {
    if (_step < 6) {
      setState(() => _step++);
    }
  }

  void _onStep2Preview(ContractFormData data) {
    _contractFormData = data;
    _next();
  }

  Future<void> _onSignatureComplete(SignatureResult result) async {
    if (_contractFormData == null) return;
    setState(() => _isSigning = true);

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final service = ContractService(firebaseService: firebaseService);

      final pdfBytes = await service.generateContractPdf(_contractFormData!);
      final pdfHash = service.computePdfHash(pdfBytes);
      final ip = await ContractService.getPublicIp();

      final contractId = await service.getOrCreateContract(
        parentUid: ref.read(currentUserProvider).valueOrNull?.uid ?? '',
        assmatUid: widget.assmatUid,
      );

      String? pdfUrl;
      try {
        pdfUrl = await service.uploadPdf(
          contractId: contractId,
          pdfBytes: pdfBytes,
        );
      } catch (_) {
        // Storage désactivé — le PDF sera uploadé plus tard
      }

      await service.finalizeParentSignature(
        contractId: contractId,
        formData: _contractFormData!,
        signedName: result.signedName,
        pdfUrl: pdfUrl ?? '',
        pdfHash: pdfHash,
        ipAddress: ip,
      );

      final audit = SignatureAuditModel(
        uid: ref.read(currentUserProvider).valueOrNull?.uid ?? '',
        role: 'parent',
        signedName: result.signedName,
        ipAddress: ip,
        method: result.smsVerified ? 'sms' : 'typed_name',
        consentText: result.consentText,
      );
      await service.saveSignature(contractId: contractId, audit: audit);

      if (mounted) {
        setState(() => _isSigning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contrat signé avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
        _next();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSigning = false);
        _showError('Erreur lors de la signature : $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.accent),
    );
  }

  String _loadingError(
    ParentProfileModel? parentProfile,
    AppUser? currentUser,
    AssmatProfileModel? assmatProfile,
    String assmatUid,
  ) {
    if (currentUser == null) return 'Connexion requise. Veuillez vous reconnecter.';
    if (parentProfile == null) return 'Profil parent introuvable. Complétez votre profil.';
    if (assmatUid.isEmpty) return 'Identifiant de l\'assistante maternelle manquant.';
    if (assmatProfile == null) return 'Profil de l\'assistante maternelle introuvable.';
    return 'Chargement...';
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
        final parentAsync = ref.watch(parentProfileProvider);
        final userAsync = ref.watch(currentUserProvider);
        final assmatAsync = widget.assmatUid.isNotEmpty
            ? ref.watch(assmatProfileByUidProvider(widget.assmatUid))
            : null;
        final childrenAsync = ref.watch(childrenProvider);

        if (parentAsync.isLoading || userAsync.isLoading || childrenAsync.isLoading || (assmatAsync?.isLoading ?? false)) {
          return const Center(child: CircularProgressIndicator());
        }

        final parentProfile = parentAsync.valueOrNull;
        final currentUser = userAsync.valueOrNull;
        final assmatProfile = assmatAsync?.valueOrNull;
        final children = childrenAsync.valueOrNull ?? <ChildModel>[];

        if (parentProfile == null || currentUser == null || assmatProfile == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                _loadingError(parentProfile, currentUser, assmatProfile, widget.assmatUid),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return _Step2(
          assmatName: widget.assmatName ?? 'l\'assistante maternelle',
          onPreview: _onStep2Preview,
          initialData: _Step2InitialData(
            parentFirstName: parentProfile.firstName,
            parentLastName: parentProfile.lastName,
            parentAddress: parentProfile.address,
            parentPhone: parentProfile.phoneNumber,
            parentEmail: currentUser.email,
            assmatFirstName: assmatProfile.firstName,
            assmatLastName: assmatProfile.lastName,
            assmatAddress: assmatProfile.address,
            children: children,
          ),
        );
      case 3:
        final parentProfile = ref.read(parentProfileProvider).valueOrNull;
        final currentUser = ref.read(currentUserProvider).valueOrNull;
        if (parentProfile == null || currentUser == null || _contractFormData == null) {
          return Center(
            child: Text(
              'Données du contrat introuvables.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _isSigning
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Signature en cours…'),
                    ],
                  ),
                )
              : InAppSignatureWidget(
                  parentFirstName: parentProfile.firstName,
                  parentLastName: parentProfile.lastName,
                  parentUid: currentUser.uid,
                  assmatName: widget.assmatName ?? 'l\'assistante maternelle',
                  contractFormData: _contractFormData!,
                  onSigned: _onSignatureComplete,
                  onError: _showError,
                ),
        );
      case 4:
        return _Step4(
          contractData: _contractFormData,
          assmatName: widget.assmatName ?? "l'assistante maternelle",
          onSign: _next,
        );
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

// ─── Step 2 : Engagement — Formulaire URSSAF ──────────────────────────────────

class _Step2 extends StatefulWidget {
  const _Step2({
    required this.assmatName,
    required this.onPreview,
    this.initialData,
  });

  final String assmatName;
  final ValueChanged<ContractFormData> onPreview;
  final _Step2InitialData? initialData;

  @override
  State<_Step2> createState() => _Step2State();
}

class _Step2State extends State<_Step2> {
  // Futur employeur
  String _civiliteEmployeur = 'M.';
  String _typeEmployeur = 'Père';
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _cpCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Futur salarié
  String _civiliteSalarie = 'Mme';
  final _nomSalarieCtrl = TextEditingController();
  final _prenomSalarieCtrl = TextEditingController();
  final _adresseSalarieCtrl = TextEditingController();
  final _villeSalarieCtrl = TextEditingController();
  final _cpSalarieCtrl = TextEditingController();
  final _telSalarieCtrl = TextEditingController();
  final _emailSalarieCtrl = TextEditingController();

  // Enfant
  String? _selectedChild;
  List<ChildModel> _children = [];

  // Preview
  bool _showPreview = false;

  // Condition d'accueil & Rémunération
  final _dateDebutCtrl = TextEditingController();
  final _heuresSemaineCtrl = TextEditingController();
  final _heuresMoisCtrl = TextEditingController();
  final _semainesAnCtrl = TextEditingController();
  final _salaireMensuelCtrl = TextEditingController();
  final _salaireHoraireCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    if (d != null) {
      _nomCtrl.text = d.parentLastName;
      _prenomCtrl.text = d.parentFirstName;
      _adresseCtrl.text = d.parentAddress;
      _telCtrl.text = d.parentPhone;
      _emailCtrl.text = d.parentEmail;
      _nomSalarieCtrl.text = d.assmatLastName;
      _prenomSalarieCtrl.text = d.assmatFirstName;
      _adresseSalarieCtrl.text = d.assmatAddress;
      _children = d.children;
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _adresseCtrl.dispose();
    _villeCtrl.dispose();
    _cpCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _nomSalarieCtrl.dispose();
    _prenomSalarieCtrl.dispose();
    _adresseSalarieCtrl.dispose();
    _villeSalarieCtrl.dispose();
    _cpSalarieCtrl.dispose();
    _telSalarieCtrl.dispose();
    _emailSalarieCtrl.dispose();
    _dateDebutCtrl.dispose();
    _heuresSemaineCtrl.dispose();
    _heuresMoisCtrl.dispose();
    _semainesAnCtrl.dispose();
    _salaireMensuelCtrl.dispose();
    _salaireHoraireCtrl.dispose();
    super.dispose();
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        InputDecorator(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                isExpanded: true,
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.bodySmall))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ProfileFormField(
        controller: controller,
        label: label,
        required: required,
        keyboardType: keyboardType,
        hintText: hintText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showPreview) return _buildPreview();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Carte info URSSAF ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Document basé sur le modèle officiel URSSAF — '
                    'Engagement réciproque Assistant maternel agréé',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Futur employeur ────────────────────────────────────
          _buildSectionCard(
            title: 'Futur employeur',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Civilité',
                      value: _civiliteEmployeur,
                      items: ['M.', 'Mme', 'Mlle'],
                      onChanged: (v) {
                        if (v != null) setState(() => _civiliteEmployeur = v);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Type',
                      value: _typeEmployeur,
                      items: ['Père', 'Mère', 'Tuteur', 'Autre'],
                      onChanged: (v) {
                        if (v != null) setState(() => _typeEmployeur = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildTextField(controller: _nomCtrl, label: 'Nom', required: true),
              _buildTextField(controller: _prenomCtrl, label: 'Prénom', required: true),
              _buildTextField(controller: _adresseCtrl, label: 'Adresse'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(controller: _villeCtrl, label: 'Ville'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildTextField(controller: _cpCtrl, label: 'Code postal'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _telCtrl, label: 'Téléphone',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildTextField(
                      controller: _emailCtrl, label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Futur salarié ──────────────────────────────────────
          _buildSectionCard(
            title: 'Futur salarié',
            children: [
              _buildDropdown(
                label: 'Civilité',
                value: _civiliteSalarie,
                items: ['M.', 'Mme', 'Mlle'],
                onChanged: (v) {
                  if (v != null) setState(() => _civiliteSalarie = v);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'Assistante maternelle agréée',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildTextField(controller: _nomSalarieCtrl, label: 'Nom', required: true),
              _buildTextField(controller: _prenomSalarieCtrl, label: 'Prénom', required: true),
              _buildTextField(controller: _adresseSalarieCtrl, label: 'Adresse'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(controller: _villeSalarieCtrl, label: 'Ville'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildTextField(controller: _cpSalarieCtrl, label: 'Code postal'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _telSalarieCtrl, label: 'Téléphone',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildTextField(
                      controller: _emailSalarieCtrl, label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Enfant ─────────────────────────────────────────────
          _buildSectionCard(
            title: 'Enfant',
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enfant concerné',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedChild,
                        isDense: true,
                        isExpanded: true,
                        hint: const Text('Sélectionnez un enfant'),
                        items: [
                          for (final c in _children)
                            DropdownMenuItem(
                              value: c.id,
                              child: Text(c.firstName),
                            ),
                        ],
                        onChanged: (v) => setState(() => _selectedChild = v),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Condition d'accueil & Rémunération ─────────────────
          _buildSectionCard(
            title: "Condition d'accueil & Rémunération",
            children: [
              _buildTextField(
                controller: _dateDebutCtrl,
                label: 'Date de début de contrat',
                hintText: 'JJ/MM/AAAA',
                required: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Condition d'accueil",
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _heuresSemaineCtrl,
                      label: 'Heures / Semaine',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildTextField(
                      controller: _heuresMoisCtrl,
                      label: 'Heures / Mois',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildTextField(
                controller: _semainesAnCtrl,
                label: 'Semaines / An',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Salaire',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _salaireMensuelCtrl,
                      label: 'Salaire mensuel brut (€)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildTextField(
                      controller: _salaireHoraireCtrl,
                      label: 'Salaire horaire brut (€)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Bouton Aperçu ──────────────────────────────────────
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => setState(() => _showPreview = true),
              icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
              label: const Text('Aperçu de l\'engagement'),
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
    );
  }

  Widget _buildPreview() {
    final selectedChild = _selectedChild != null
        ? _children.where((c) => c.id == _selectedChild).firstOrNull
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Carte info URSSAF ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Récapitulatif de votre engagement réciproque',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Récap Employeur ────────────────────────────────────
          _buildPreviewSection(
            icon: Icons.person,
            title: 'Futur employeur ($_civiliteEmployeur $_typeEmployeur)',
            items: [
              if (_nomCtrl.text.isNotEmpty || _prenomCtrl.text.isNotEmpty)
                _buildPreviewRow('Nom complet', '${_prenomCtrl.text} ${_nomCtrl.text}'.trim()),
              if (_adresseCtrl.text.isNotEmpty)
                _buildPreviewRow('Adresse', _adresseCtrl.text),
              if (_villeCtrl.text.isNotEmpty || _cpCtrl.text.isNotEmpty)
                _buildPreviewRow('Ville / CP', '${_villeCtrl.text} ${_cpCtrl.text}'.trim()),
              if (_telCtrl.text.isNotEmpty)
                _buildPreviewRow('Téléphone', _telCtrl.text),
              if (_emailCtrl.text.isNotEmpty)
                _buildPreviewRow('Email', _emailCtrl.text),
            ],
          ),

          // ── Récap Salarié ──────────────────────────────────────
          _buildPreviewSection(
            icon: Icons.badge_outlined,
            title: 'Futur salarié — Assistante maternelle ($_civiliteSalarie)',
            items: [
              if (_nomSalarieCtrl.text.isNotEmpty || _prenomSalarieCtrl.text.isNotEmpty)
                _buildPreviewRow('Nom complet', '${_prenomSalarieCtrl.text} ${_nomSalarieCtrl.text}'.trim()),
              if (_adresseSalarieCtrl.text.isNotEmpty)
                _buildPreviewRow('Adresse', _adresseSalarieCtrl.text),
              if (_villeSalarieCtrl.text.isNotEmpty || _cpSalarieCtrl.text.isNotEmpty)
                _buildPreviewRow('Ville / CP', '${_villeSalarieCtrl.text} ${_cpSalarieCtrl.text}'.trim()),
              if (_telSalarieCtrl.text.isNotEmpty)
                _buildPreviewRow('Téléphone', _telSalarieCtrl.text),
              if (_emailSalarieCtrl.text.isNotEmpty)
                _buildPreviewRow('Email', _emailSalarieCtrl.text),
            ],
          ),

          // ── Récap Enfant ───────────────────────────────────────
          _buildPreviewSection(
            icon: Icons.child_care_outlined,
            title: 'Enfant concerné',
            items: [
              if (selectedChild != null)
                _buildPreviewRow('Prénom', selectedChild.firstName),
              if (_selectedChild == null)
                _buildPreviewRow('', 'Aucun enfant sélectionné'),
            ],
          ),

          // ── Récap Condition d'accueil & Rémunération ───────────
          _buildPreviewSection(
            icon: Icons.calendar_today_outlined,
            title: "Condition d'accueil & Rémunération",
            items: [
              if (_dateDebutCtrl.text.isNotEmpty)
                _buildPreviewRow('Date de début', _dateDebutCtrl.text),
              if (_heuresSemaineCtrl.text.isNotEmpty)
                _buildPreviewRow('Heures / Semaine', '${_heuresSemaineCtrl.text} h'),
              if (_heuresMoisCtrl.text.isNotEmpty)
                _buildPreviewRow('Heures / Mois', '${_heuresMoisCtrl.text} h'),
              if (_semainesAnCtrl.text.isNotEmpty)
                _buildPreviewRow('Semaines / An', '${_semainesAnCtrl.text} sem.'),
              if (_salaireMensuelCtrl.text.isNotEmpty)
                _buildPreviewRow('Salaire mensuel', '${_salaireMensuelCtrl.text} € brut'),
              if (_salaireHoraireCtrl.text.isNotEmpty)
                _buildPreviewRow('Salaire horaire', '${_salaireHoraireCtrl.text} € brut'),
            ],
          ),

          // ── Boutons ────────────────────────────────────────────
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showPreview = false),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Modifier'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _onSign,
              icon: const Icon(Icons.draw_outlined, size: 18),
              label: const Text('Signer l\'engagement'),
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
    );
  }

  void _onSign() {
    final selectedChild = _selectedChild != null
        ? _children.where((c) => c.id == _selectedChild).firstOrNull
        : null;

    final data = ContractFormData(
      civiliteEmployeur: _civiliteEmployeur,
      typeEmployeur: _typeEmployeur,
      nomEmployeur: _nomCtrl.text,
      prenomEmployeur: _prenomCtrl.text,
      adresseEmployeur: _adresseCtrl.text,
      villeEmployeur: _villeCtrl.text,
      cpEmployeur: _cpCtrl.text,
      telEmployeur: _telCtrl.text,
      emailEmployeur: _emailCtrl.text,
      civiliteSalarie: _civiliteSalarie,
      nomSalarie: _nomSalarieCtrl.text,
      prenomSalarie: _prenomSalarieCtrl.text,
      adresseSalarie: _adresseSalarieCtrl.text,
      villeSalarie: _villeSalarieCtrl.text,
      cpSalarie: _cpSalarieCtrl.text,
      telSalarie: _telSalarieCtrl.text,
      emailSalarie: _emailSalarieCtrl.text,
      childId: _selectedChild,
      childFirstName: selectedChild?.firstName ?? '',
      dateDebut: _dateDebutCtrl.text,
      heuresSemaine: _heuresSemaineCtrl.text,
      heuresMois: _heuresMoisCtrl.text,
      semainesAn: _semainesAnCtrl.text,
      salaireMensuel: _salaireMensuelCtrl.text,
      salaireHoraire: _salaireHoraireCtrl.text,
    );

    widget.onPreview(data);
  }

  Widget _buildPreviewSection({
    required IconData icon,
    required String title,
    required List<Widget> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...items,
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3 : Signature électronique ──────────────────────────────────────────
// Remplacé par InAppSignatureWidget (voir le builder case 3 ci-dessus)

// ─── Step 4 : Contrat de travail ──────────────────────────────────────────────

class _Step4 extends StatelessWidget {
  const _Step4({
    required this.contractData,
    required this.assmatName,
    required this.onSign,
  });

  final ContractFormData? contractData;
  final String assmatName;
  final VoidCallback onSign;

  @override
  Widget build(BuildContext context) {
    final data = contractData;
    if (data == null) {
      return Center(
        child: Text(
          'Données de l\'engagement introuvables.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBanner(context),
        const SizedBox(height: AppSpacing.md),
        _buildContractCard(context, data),
        const SizedBox(height: AppSpacing.lg),
        _buildSignButton(context),
      ],
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Toutes les données ont été reprises automatiquement '
              'de l\'engagement réciproque.',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractCard(BuildContext context, ContractFormData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Contrat de travail CDI',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Convention collective IDCC 3239',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Carte Employeur
          _buildPersonCard(
            icon: Icons.business_outlined,
            title: 'Employeur',
            name: '${data.prenomEmployeur} ${data.nomEmployeur}'.trim(),
            address: [
              data.adresseEmployeur,
              if (data.villeEmployeur.isNotEmpty || data.cpEmployeur.isNotEmpty)
                '${data.cpEmployeur} ${data.villeEmployeur}'.trim(),
            ].where((s) => s.isNotEmpty).join('\n'),
          ),
          const SizedBox(height: AppSpacing.md),
          // Carte Salarié
          _buildPersonCard(
            icon: Icons.badge_outlined,
            title: 'Salarié(e)',
            name: '${data.prenomSalarie} ${data.nomSalarie}'.trim(),
            address: [
              data.adresseSalarie,
              if (data.villeSalarie.isNotEmpty || data.cpSalarie.isNotEmpty)
                '${data.cpSalarie} ${data.villeSalarie}'.trim(),
            ].where((s) => s.isNotEmpty).join('\n'),
          ),
          const SizedBox(height: AppSpacing.md),
          // Infos contrat
          _buildInfoRow('Date de début', data.dateDebut),
          _buildInfoRow('Type de contrat', 'CDI'),
          _buildInfoRow('Heures / Semaine', '${data.heuresSemaine} h'),
          _buildInfoRow('Heures / Mois', '${data.heuresMois} h'),
          const SizedBox(height: AppSpacing.md),
          // Carte Salaire
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salaire',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _buildSalaryItem(
                        label: 'Horaire brut',
                        value: '${data.salaireHoraire} €',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildSalaryItem(
                        label: 'Mensuel brut',
                        value: '${data.salaireMensuel} €',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard({
    required IconData icon,
    required String title,
    required String name,
    required String address,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            name,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              address,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onSign,
        icon: const Icon(Icons.draw_outlined, size: 20),
        label: const Text('Signer le contrat'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
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

// ─── Yousign API Service ──────────────────────────────────────────────────────────
// Supprimé — remplacé par la signature in-app via InAppSignatureWidget + ContractService
