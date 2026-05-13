import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/data/models/assmat_profile_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../parent/presentation/widgets/filter_checkbox_tile.dart';
import '../../../parent/presentation/widgets/profile_form_field.dart';
import '../../../parent/presentation/widgets/personal_info_card.dart';
import 'assmat_home_page.dart';

/// Page "Mon profil" de l'Assistante Maternelle.
///
/// Les champs présents dans [AssmatProfileModel] (firstName, lastName,
/// address, bio, isSearchable, maxChildren, availableSlots) sont wirés
/// à Firestore. Les sections non encore modélisées (tabac, diplômes,
/// spécialités…) conservent un état local en attendant l'extension du modèle.
class AssMatProfilePage extends ConsumerStatefulWidget {
  const AssMatProfilePage({super.key});

  @override
  ConsumerState<AssMatProfilePage> createState() => _AssMatProfilePageState();
}

class _AssMatProfilePageState extends ConsumerState<AssMatProfilePage> {
  // ── Contrôleurs texte ──────────────────────────────────────────────────────
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _maxChildrenCtrl = TextEditingController();
  final _availableSlotsCtrl = TextEditingController();

  // ── État booléen ───────────────────────────────────────────────────────────
  bool _isSearchable = true;

  // ── Cycle de vie ──────────────────────────────────────────────────────────
  bool _initialized = false;
  AssmatProfileModel? _loadedProfile;
  bool _saving = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    _maxChildrenCtrl.dispose();
    _availableSlotsCtrl.dispose();
    super.dispose();
  }

  // ── Init helpers ───────────────────────────────────────────────────────────

  void _initFromProfile(AssmatProfileModel profile, String email) {
    _loadedProfile = profile;
    _firstNameCtrl.text = profile.firstName;
    _lastNameCtrl.text = profile.lastName;
    _addressCtrl.text = profile.address;
    _bioCtrl.text = profile.bio;
    _emailCtrl.text = email;
    _maxChildrenCtrl.text = profile.maxChildren.toString();
    _availableSlotsCtrl.text = profile.availableSlots.toString();
    _isSearchable = profile.isSearchable;
    _initialized = true;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _cancel() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Contexte onglet : réinitialise depuis les dernières valeurs Firestore.
      final email = ref.read(currentUserProvider).valueOrNull?.email ?? '';
      if (_loadedProfile != null) {
        setState(() => _initFromProfile(_loadedProfile!, email));
      }
    }
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final savedMaxChildren = int.tryParse(_maxChildrenCtrl.text.trim()) ??
          (_loadedProfile?.maxChildren ?? 1);
      final savedAvailableSlots =
          int.tryParse(_availableSlotsCtrl.text.trim()) ??
              (_loadedProfile?.availableSlots ?? 0);

      await ref.read(authRemoteDataSourceProvider).updateAssmatProfile(
            uid: user.uid,
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            bio: _bioCtrl.text.trim(),
            isSearchable: _isSearchable,
            maxChildren: savedMaxChildren,
            availableSlots: savedAvailableSlots,
          );

      // Mettre à jour _loadedProfile pour que "Annuler" revienne aux
      // dernières valeurs enregistrées (et non à l'état initial du stream).
      _loadedProfile = _loadedProfile?.copyWith(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        isSearchable: _isSearchable,
        maxChildren: savedMaxChildren,
        availableSlots: savedAvailableSlots,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil enregistré'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(assmatProfileProvider);
    final email = ref.watch(currentUserProvider).valueOrNull?.email ?? '';

    // Initialise les controllers à la première donnée disponible.
    if (!_initialized) {
      profileAsync.whenData((profile) {
        if (profile != null) _initFromProfile(profile, email);
      });
    }

    // Écoute les changements futurs si pas encore initialisé.
    ref.listen<AsyncValue<AssmatProfileModel?>>(
      assmatProfileProvider,
      (_, next) {
        if (_initialized) return;
        next.whenData((profile) {
          if (profile != null && mounted) {
            setState(() => _initFromProfile(profile, email));
          }
        });
      },
    );

    final isLoading = profileAsync.isLoading && !_initialized;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AssMatDrawer(),
      body: Builder(
        builder: (scaffoldCtx) => SafeArea(
          child: Column(
            children: [
              _ProfileHeader(
                  onMenuTap: () => Scaffold.of(scaffoldCtx).openDrawer()),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : profileAsync.hasError
                        ? Center(
                            child: Text(
                              'Impossible de charger le profil.\n'
                              '${profileAsync.error}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.error),
                            ),
                          )
                        : _buildContent(),
              ),
              _BottomActionBar(
                saving: _saving,
                onCancel: _cancel,
                onSave: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final availableSlots =
        int.tryParse(_availableSlotsCtrl.text) ??
        (_loadedProfile?.availableSlots ?? 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleSection(onPassPro: () => _stub('Passer à Pro')),
          const SizedBox(height: AppSpacing.lg),

          // ── Chips de statut ────────────────────────────────────────────────
          _StatusChips(
            availableSlots: availableSlots,
            isSearchable: _isSearchable,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Infos personnelles + bio ───────────────────────────────────────
          PersonalInfoCard(
            firstName: _firstNameCtrl.text,
            lastName: _lastNameCtrl.text,
            phone: '',
            email: _emailCtrl.text,
            address: _addressCtrl.text,
            firstNameController: _firstNameCtrl,
            lastNameController: _lastNameCtrl,
            emailController: _emailCtrl,
            addressController: _addressCtrl,
            descriptionController: _bioCtrl,
            descriptionLabel: 'Description / Présentation',
            descriptionHint:
                'Parlez-nous de votre expérience et de votre cadre d\'accueil…',
            onChangePhoto: () => _stub('Changer la photo'),
            avatarBg: AppColors.secondary,
            avatarFg: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Disponibilité ──────────────────────────────────────────────────
          _AvailabilityCard(
            isAvailable: _isSearchable,
            onAvailabilityChanged: (v) => setState(() => _isSearchable = v),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Informations pratiques ─────────────────────────────────────────
          _PracticalInfoCard(
            maxChildrenController: _maxChildrenCtrl,
            availableSlotsController: _availableSlotsCtrl,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Services proposés ──────────────────────────────────────────────
          const _ServicesOfferedCard(),
          const SizedBox(height: AppSpacing.lg),

          // ── Horaires & Flexibilité ─────────────────────────────────────────
          const _FlexibilityCard(),
          const SizedBox(height: AppSpacing.lg),

          // ── Diplômes & Expérience ──────────────────────────────────────────
          const _DiplomasCard(),
          const SizedBox(height: AppSpacing.lg),

          // ── Photos du domicile ─────────────────────────────────────────────
          const _HomePhotosCard(),
          const SizedBox(height: AppSpacing.lg),

          // ── Numéro d'agrément ──────────────────────────────────────────────
          const _AccreditationCard(),
          const SizedBox(height: AppSpacing.lg),

          // ── Contacts importants ────────────────────────────────────────────
          const _ImportantContactsCard(),
          const SizedBox(height: AppSpacing.lg),

          // ── Vérification d'identité ────────────────────────────────────────
          const _IdentityVerificationCard(),
          const SizedBox(height: AppSpacing.lg),

          // ── Spécialités & compétences ──────────────────────────────────────
          const _SpecialitiesCard(),
          const SizedBox(height: AppSpacing.lg),

          // ── Coffre-fort numérique ──────────────────────────────────────────
          const _DigitalVaultCard(),
          const SizedBox(height: AppSpacing.lg),

          // ── Mes données personnelles ───────────────────────────────────────
          _PersonalDataCard(onStub: _stub),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── App bar ─────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onMenuTap});
  final VoidCallback onMenuTap;

  static const _logoBg = Color(0xFF4A3B33);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                size: 28, color: AppColors.primaryText),
            onPressed: onMenuTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Menu',
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _logoBg,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.face_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('AMiLY',
              style:
                  AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ─── Titre + bouton Pro ───────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.onPassPro});
  final VoidCallback onPassPro;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mon profil',
                  style: AppTextStyles.headlineMedium
                      .copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Gérez vos informations visibles par les parents et la PMI',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton.icon(
          onPressed: onPassPro,
          icon: const Icon(Icons.star_rounded, size: 18),
          label: const Text('Passer à Pro'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(0, 44),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
        ),
      ],
    );
  }
}

// ─── Chips de statut ─────────────────────────────────────────────────────────

class _StatusChips extends StatelessWidget {
  const _StatusChips({
    required this.availableSlots,
    required this.isSearchable,
  });

  final int availableSlots;
  final bool isSearchable;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _StatusChip(
          icon: isSearchable
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          label: isSearchable
              ? '$availableSlots place(s) disponible(s)'
              : 'Indisponible',
          filled: isSearchable,
        ),
        const _StatusChip(
          icon: Icons.shield_outlined,
          label: 'Agrément valide',
          filled: false,
        ),
        const _StatusChip(
          icon: Icons.verified_user_outlined,
          label: 'Identité vérifiée',
          filled: false,
        ),
      ],
    );
  }
}

// ─── Carte disponibilité ──────────────────────────────────────────────────────

class _AvailabilityCard extends StatefulWidget {
  const _AvailabilityCard({
    required this.isAvailable,
    required this.onAvailabilityChanged,
  });

  final bool isAvailable;
  final ValueChanged<bool> onAvailabilityChanged;

  @override
  State<_AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<_AvailabilityCard> {
  // La date reste en état local (pas encore dans AssmatProfileModel).
  late DateTime _availableFrom;

  static const _months = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12',
  ];

  @override
  void initState() {
    super.initState();
    _availableFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${_months[d.month - 1]}/${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _availableFrom,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
      locale: const Locale('fr', 'FR'),
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null) setState(() => _availableFrom = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: widget.isAvailable ? AppColors.primary : AppColors.divider,
          width: widget.isAvailable ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.isAvailable
                      ? AppColors.primary
                      : AppColors.secondaryText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isAvailable
                          ? 'Disponible — J\'accueille de nouveaux enfants'
                          : 'Indisponible — Je n\'accueille pas',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.isAvailable
                          ? 'Votre profil est visible par les parents en recherche'
                          : 'Votre profil est masqué des recherches',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch(
                value: widget.isAvailable,
                onChanged: widget.onAvailabilityChanged,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          if (widget.isAvailable) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),
            Text('Disponible à partir du', style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_format(_availableFrom),
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.primaryText)),
                    ),
                    const Icon(Icons.calendar_today_rounded,
                        size: 20, color: AppColors.secondaryText),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Informations pratiques ───────────────────────────────────────────────────

class _PracticalInfoCard extends StatefulWidget {
  const _PracticalInfoCard({
    required this.maxChildrenController,
    required this.availableSlotsController,
  });

  final TextEditingController maxChildrenController;
  final TextEditingController availableSlotsController;

  @override
  State<_PracticalInfoCard> createState() => _PracticalInfoCardState();
}

class _PracticalInfoCardState extends State<_PracticalInfoCard> {
  // Champs non encore dans le modèle → état local.
  String _tobacco = 'Non fumeur';
  String _firstAid = 'PSC1 validé';
  String _pet = 'Pas d\'animal';

  static const _tobaccoOptions = ['Non fumeur', 'Fumeur (extérieur)', 'Fumeur'];
  static const _firstAidOptions = ['PSC1 validé', 'SST validé', 'Aucune formation'];
  static const _petOptions = ['Pas d\'animal', 'Chat', 'Chien', 'Autre animal'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Informations pratiques', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Ces informations sont visibles par les parents',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.lg),

          _IconLabeledDropdown(
            icon: Icons.smoking_rooms_rounded,
            label: 'Tabac au domicile',
            value: _tobacco,
            options: _tobaccoOptions,
            onChanged: (v) => setState(() => _tobacco = v ?? _tobacco),
          ),
          const SizedBox(height: AppSpacing.md),
          _IconLabeledDropdown(
            icon: Icons.monitor_heart_outlined,
            label: 'Formation 1ers secours',
            value: _firstAid,
            options: _firstAidOptions,
            onChanged: (v) => setState(() => _firstAid = v ?? _firstAid),
          ),
          const SizedBox(height: AppSpacing.md),
          _IconLabeledDropdown(
            icon: Icons.pets_rounded,
            label: 'Animal au domicile',
            value: _pet,
            options: _petOptions,
            onChanged: (v) => setState(() => _pet = v ?? _pet),
          ),
          const SizedBox(height: AppSpacing.md),

          // Champs wirés Firestore
          ProfileFormField(
            label: 'Places max (agrément)',
            controller: widget.maxChildrenController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
            label: 'Enfants accueillis actuellement',
            controller: widget.availableSlotsController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

/// Dropdown avec un label "icône + texte" au-dessus du champ.
class _IconLabeledDropdown extends StatelessWidget {
  const _IconLabeledDropdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryText, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTextStyles.labelMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: [
            for (final opt in options)
              DropdownMenuItem(value: opt, child: Text(opt)),
          ],
          onChanged: onChanged,
          isExpanded: true,
        ),
      ],
    );
  }
}

// ─── Cartes à checkboxes ──────────────────────────────────────────────────────

class _ChecklistCard extends StatefulWidget {
  const _ChecklistCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.initialItems,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Map<String, bool> initialItems;

  @override
  State<_ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<_ChecklistCard> {
  late final Map<String, bool> _items = Map.of(widget.initialItems);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(widget.title, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.subtitle,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.md),
          for (final entry in _items.entries)
            FilterCheckboxTile(
              label: entry.key,
              value: entry.value,
              onChanged: (v) => setState(() => _items[entry.key] = v),
            ),
        ],
      ),
    );
  }
}

class _ServicesOfferedCard extends StatelessWidget {
  const _ServicesOfferedCard();

  @override
  Widget build(BuildContext context) {
    return const _ChecklistCard(
      icon: Icons.volunteer_activism_rounded,
      title: 'Services proposés',
      subtitle: 'Indiquez les services que vous proposez aux familles',
      initialItems: {
        'Exerce en maison d\'assistants maternels': false,
        'Peut accueillir des enfants en situation de handicap': true,
        'Peut véhiculer les enfants': false,
        'Peut fournir des produits d\'hygiène': true,
        'Peut fournir les repas': true,
      },
    );
  }
}

class _FlexibilityCard extends StatelessWidget {
  const _FlexibilityCard();

  @override
  Widget build(BuildContext context) {
    return const _ChecklistCard(
      icon: Icons.access_time_rounded,
      title: 'Horaires & Flexibilité',
      subtitle: 'Précisez vos disponibilités horaires',
      initialItems: {
        'Peut être flexible sur les horaires': true,
        'Peut accueillir les enfants la nuit': false,
        'Peut accueillir les enfants le week-end': false,
        'Peut accueillir les enfants les jours fériés': false,
        'Travaille pendant les vacances scolaires': true,
        'Peut répondre aux accueils d\'urgence': false,
      },
    );
  }
}

// ─── Diplômes & Expérience ────────────────────────────────────────────────────

class _DiplomasCard extends StatefulWidget {
  const _DiplomasCard();

  @override
  State<_DiplomasCard> createState() => _DiplomasCardState();
}

class _DiplomasCardState extends State<_DiplomasCard> {
  final List<String> _diplomas = ['CAP Petite Enfance', 'PSC1'];

  void _onAdd() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ajouter un diplôme — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeDiploma(String d) => setState(() => _diplomas.remove(d));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Diplômes & Expérience', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Diplômes & Formations',
              style:
                  AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final d in _diplomas)
                _DiplomaChip(label: d, onRemove: () => _removeDiploma(d)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.work_outline_rounded,
                  color: AppColors.primaryText, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text('Parcours professionnel',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue:
                '8 ans comme assistante maternelle agréée. Ancienne auxiliaire en crèche pendant 3 ans.',
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Décrivez votre parcours professionnel…',
            ),
          ),
        ],
      ),
    );
  }
}

class _DiplomaChip extends StatelessWidget {
  const _DiplomaChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.assmatIconBg,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.primaryText)),
          const SizedBox(width: AppSpacing.sm),
          InkWell(
            onTap: onRemove,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close_rounded,
                  color: AppColors.primaryText, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Photos du domicile ───────────────────────────────────────────────────────

class _PhotoData {
  const _PhotoData({required this.label, required this.color});
  final String label;
  final Color color;
}

class _HomePhotosCard extends StatefulWidget {
  const _HomePhotosCard();

  @override
  State<_HomePhotosCard> createState() => _HomePhotosCardState();
}

class _HomePhotosCardState extends State<_HomePhotosCard> {
  final List<_PhotoData> _photos = const [
    _PhotoData(label: 'Espace de jeux principal', color: Color(0xFFE0E0E0)),
    _PhotoData(label: 'Chambre sieste', color: Color(0xFFE0E0E0)),
    _PhotoData(label: 'Jardin partagé', color: Color(0xFFE0E0E0)),
  ];

  void _addPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ajouter une photo — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Photos du domicile', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Ajoutez des photos de votre espace d\'accueil',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppSpacing.md;
              final tileWidth = (constraints.maxWidth - spacing) / 2;
              final tileHeight = tileWidth * 0.82;
              final photoTiles = _photos
                  .map((p) => _PhotoTile(
                      label: p.label,
                      bgColor: p.color,
                      width: tileWidth,
                      height: tileHeight))
                  .toList();
              final addTile = _AddPhotoTile(
                  width: tileWidth, height: tileHeight, onTap: _addPhoto);
              final allTiles = [...photoTiles, addTile];
              final rows = <Widget>[];
              for (var i = 0; i < allTiles.length; i += 2) {
                final right =
                    i + 1 < allTiles.length ? allTiles[i + 1] : null;
                rows.add(Row(children: [
                  allTiles[i],
                  const SizedBox(width: spacing),
                  right ?? SizedBox(width: tileWidth),
                ]));
                if (i + 2 < allTiles.length) {
                  rows.add(const SizedBox(height: spacing));
                }
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: rows);
            },
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.label,
    required this.bgColor,
    required this.width,
    required this.height,
  });
  final String label;
  final Color bgColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: bgColor,
              alignment: Alignment.center,
              child: Icon(Icons.image_outlined,
                  size: width * 0.18,
                  color: Colors.white.withValues(alpha: 0.7)),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC1A1A1A), Color(0x001A1A1A)],
                  ),
                ),
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile(
      {required this.width, required this.height, required this.onTap});
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded,
                    size: width * 0.22, color: AppColors.secondaryText),
                const SizedBox(height: 4),
                Text('Ajouter',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = AppRadii.md;
    const dashLen = 6.0;
    const gapLen = 5.0;
    final paint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLen).clamp(0.0, metric.length);
        dashedPath.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashLen + gapLen;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Numéro d'agrément ────────────────────────────────────────────────────────

class _AccreditationCard extends StatefulWidget {
  const _AccreditationCard();

  @override
  State<_AccreditationCard> createState() => _AccreditationCardState();
}

class _AccreditationCardState extends State<_AccreditationCard> {
  DateTime _expiresOn = DateTime(2026, 12, 31);
  bool _isCertified = true;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresOn,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040, 12, 31),
      locale: const Locale('fr', 'FR'),
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null) setState(() => _expiresOn = picked);
  }

  void _changePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changer la photo de l\'agrément — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Numéro d\'agrément', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const ProfileFormField(
              label: 'Numéro d\'agrément',
              initialValue: 'PMI-2024-75015-0042'),
          const SizedBox(height: AppSpacing.md),
          _DatePickerField(
              label: 'Date d\'expiration',
              value: _fmt(_expiresOn),
              onTap: _pickExpiry),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primaryText, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text('Photo de l\'agrément',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Cette photo sera visible par les parents et la PMI pour vérification.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: _changePhoto,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: const Color(0xFFD0CCCA),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined,
                          size: 48, color: Color(0xFFAAAAAA)),
                    ),
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppRadii.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 16),
                              const SizedBox(width: AppSpacing.xs),
                              Text('Visible parents & PMI',
                                  style: AppTextStyles.labelMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: () => setState(() => _isCertified = !_isCertified),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _isCertified,
                      onChanged: (v) =>
                          setState(() => _isCertified = v ?? false),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Je certifie que ce numéro d\'agrément est valide',
                          style: AppTextStyles.bodyLarge
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Toute fausse déclaration peut entraîner la '
                          'suspension de votre compte',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Code PMI (fourni par votre PMI)',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          const ProfileFormField(label: '', initialValue: 'PMI-75015'),
          const SizedBox(height: AppSpacing.xs),
          Text('Ce code vous rattache à votre PMI de secteur',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(value,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primaryText)),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.primaryText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Contacts importants ──────────────────────────────────────────────────────

class _ImportantContactsCard extends StatelessWidget {
  const _ImportantContactsCard();

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('$label — à venir'),
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_in_talk_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Contacts importants', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Vos contacts professionnels d\'urgence et de référence',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.lg),
          _ContactSection(
            icon: Icons.domain_outlined,
            iconColor: AppColors.primary,
            label: 'PMI',
            firstFieldLabel: 'Nom',
            firstFieldMock: 'PMI du 15ème arrondissement',
            secondFieldLabel: 'Téléphone',
            secondFieldMock: '01 45 67 89 00',
            secondKeyboard: TextInputType.phone,
            callLabel: 'Contacter la PMI',
            onCall: () => _stub(context, 'Contacter la PMI'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          const _ContactSection(
            icon: Icons.domain_outlined,
            iconColor: AppColors.accent,
            label: 'Relais Petite Enfance (RPE)',
            firstFieldLabel: 'Nom',
            firstFieldMock: 'RPE Les Petits Pas',
            secondFieldLabel: 'Téléphone',
            secondFieldMock: '01 45 67 89 10',
            secondKeyboard: TextInputType.phone,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          const _ContactSection(
            icon: Icons.warning_amber_outlined,
            iconColor: AppColors.accent,
            label: 'Centre antipoison',
            firstFieldLabel: 'Numéro',
            firstFieldMock: '01 40 05 48 48',
            firstKeyboard: TextInputType.phone,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          const _ContactSection(
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.secondaryText,
            label: 'Tiers à contacter',
            firstFieldLabel: 'Nom',
            firstFieldMock: 'Jean Lefèvre (conjoint)',
            secondFieldLabel: 'Téléphone',
            secondFieldMock: '06 98 76 54 32',
            secondKeyboard: TextInputType.phone,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          const _EmergencyNumbersSection(),
        ],
      ),
    );
  }
}

class _EmergencyNumbersSection extends StatelessWidget {
  const _EmergencyNumbersSection();

  static const _rowBg = Color(0xFFFFF0EE);
  static const _numbers = [
    (label: 'Urgences européennes', number: '112'),
    (label: 'SAMU', number: '15'),
    (label: 'Pompiers', number: '18'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_outlined, color: AppColors.error, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text('Numéros d\'urgence',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final item in _numbers) ...[
          _EmergencyRow(label: item.label, number: item.number, bg: _rowBg),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text('Autre numéro personnalisé',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: AppSpacing.sm),
        const ProfileFormField(
            label: '', initialValue: '01 45 67 00 00',
            keyboardType: TextInputType.phone),
      ],
    );
  }
}

class _EmergencyRow extends StatelessWidget {
  const _EmergencyRow(
      {required this.label, required this.number, required this.bg});
  final String label;
  final String number;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border:
            Border.all(color: AppColors.error.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.primaryText)),
          ),
          Text(number,
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.icon,
    required this.label,
    required this.firstFieldLabel,
    required this.firstFieldMock,
    this.iconColor = AppColors.primary,
    this.firstKeyboard = TextInputType.text,
    this.secondFieldLabel,
    this.secondFieldMock,
    this.secondKeyboard = TextInputType.text,
    this.callLabel,
    this.onCall,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String firstFieldLabel;
  final String firstFieldMock;
  final TextInputType firstKeyboard;
  final String? secondFieldLabel;
  final String? secondFieldMock;
  final TextInputType secondKeyboard;
  final String? callLabel;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(label,
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ProfileFormField(
            label: firstFieldLabel,
            initialValue: firstFieldMock,
            keyboardType: firstKeyboard),
        if (secondFieldLabel != null && secondFieldMock != null) ...[
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
              label: secondFieldLabel!,
              initialValue: secondFieldMock!,
              keyboardType: secondKeyboard),
        ],
        if (callLabel != null && onCall != null) ...[
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(callLabel!),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Vérification d'identité ──────────────────────────────────────────────────

class _IdentityVerificationCard extends StatelessWidget {
  const _IdentityVerificationCard();

  static const _rgpdBg = Color(0xFFFFF8E1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.credit_card_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Vérification d\'identité',
                  style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Identité vérifiée',
                          style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Vérification effectuée le 2024-01-15',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.secondaryText)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _rgpdBg,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Vos données sont traitées conformément au RGPD. '
                    'La photo n\'est pas conservée après vérification.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Spécialités & compétences ────────────────────────────────────────────────

class _SpecialitiesCard extends StatefulWidget {
  const _SpecialitiesCard();

  @override
  State<_SpecialitiesCard> createState() => _SpecialitiesCardState();
}

class _SpecialitiesCardState extends State<_SpecialitiesCard> {
  final List<String> _tags = [
    'Montessori',
    'Éveil musical',
    'Sorties nature',
    'Cuisine avec les enfants',
  ];

  void _remove(String tag) => setState(() => _tags.remove(tag));

  void _onAdd() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Ajouter une spécialité — à venir'),
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_border_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Spécialités & compétences',
                  style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final tag in _tags)
                _DiplomaChip(label: tag, onRemove: () => _remove(tag)),
              InkWell(
                onTap: _onAdd,
                borderRadius: BorderRadius.circular(AppRadii.full),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded,
                          size: 16, color: AppColors.primaryText),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Ajouter',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.primaryText)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Coffre-fort numérique ────────────────────────────────────────────────────

class _VaultDoc {
  const _VaultDoc(
      {required this.title,
      required this.signedOn,
      required this.signers,
      required this.icon});
  final String title;
  final String signedOn;
  final String signers;
  final IconData icon;
}

class _FamilyVaultData {
  const _FamilyVaultData(
      {required this.name, required this.subtitle, required this.docs});
  final String name;
  final String subtitle;
  final List<_VaultDoc> docs;
  int get docCount => docs.length;
}

class _DigitalVaultCard extends StatefulWidget {
  const _DigitalVaultCard();

  @override
  State<_DigitalVaultCard> createState() => _DigitalVaultCardState();
}

class _DigitalVaultCardState extends State<_DigitalVaultCard> {
  int? _expandedIndex = 0;

  static final List<_FamilyVaultData> _families = [
    const _FamilyVaultData(
      name: 'Famille Dupont',
      subtitle: 'Lucas & Chloé',
      docs: [
        _VaultDoc(title: 'Contrat de garde', signedOn: '01/09/2025', signers: 'Sophie Dupont, Marie Lefèvre', icon: Icons.description_outlined),
        _VaultDoc(title: 'Engagement qualité', signedOn: '20/08/2025', signers: 'Sophie Dupont, Marie Lefèvre', icon: Icons.task_outlined),
        _VaultDoc(title: 'Droit à l\'image', signedOn: '01/09/2025', signers: 'Sophie Dupont', icon: Icons.visibility_outlined),
        _VaultDoc(title: 'Fiche de paie Mars', signedOn: '05/03/2026', signers: 'Sophie Dupont', icon: Icons.receipt_long_outlined),
      ],
    ),
    const _FamilyVaultData(
      name: 'Famille Martin',
      subtitle: 'Emma',
      docs: [
        _VaultDoc(title: 'Contrat de garde', signedOn: '15/01/2026', signers: 'Julie Martin, Marie Lefèvre', icon: Icons.description_outlined),
        _VaultDoc(title: 'Fiche de paie Mars', signedOn: '05/03/2026', signers: 'Julie Martin', icon: Icons.receipt_long_outlined),
      ],
    ),
  ];

  int get _totalDocs => _families.fold(0, (s, f) => s + f.docCount);

  void _toggle(int index) =>
      setState(() => _expandedIndex = _expandedIndex == index ? null : index);

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('$label — à venir'),
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Coffre-fort numérique', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Dossiers complets par famille — contrats, documents et fiches de paie signés',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle_outlined,
                    size: 14, color: AppColors.secondaryText),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Stockage chiffré • Conforme RGPD • '
                    '$_totalDocs document(s) archivé(s) • '
                    '${_families.length} famille(s)',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < _families.length; i++) ...[
            _FamilyVaultRow(
              family: _families[i],
              isExpanded: i == _expandedIndex,
              onTap: () => _toggle(i),
              onDocAction: _stub,
            ),
            if (i < _families.length - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FamilyVaultRow extends StatefulWidget {
  const _FamilyVaultRow({
    required this.family,
    required this.isExpanded,
    required this.onTap,
    required this.onDocAction,
  });
  final _FamilyVaultData family;
  final bool isExpanded;
  final VoidCallback onTap;
  final void Function(String) onDocAction;

  @override
  State<_FamilyVaultRow> createState() => _FamilyVaultRowState();
}

class _FamilyVaultRowState extends State<_FamilyVaultRow> {
  int? _selectedDoc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: widget.isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.chevron_right_rounded,
                      size: 22, color: AppColors.primaryText),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: AppColors.assmatIconBg, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.child_care_rounded,
                      size: 22, color: AppColors.accent),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.family.name} —\n${widget.family.subtitle}',
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text('${widget.family.docCount} document(s)',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text('${widget.family.docCount}',
                      style: AppTextStyles.labelMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: widget.isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      width: 2,
                      margin: const EdgeInsets.only(right: AppSpacing.md),
                      color: AppColors.divider),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < widget.family.docs.length; i++) ...[
                          _VaultDocRow(
                            doc: widget.family.docs[i],
                            isSelected: i == _selectedDoc,
                            onTap: () => setState(() =>
                                _selectedDoc = _selectedDoc == i ? null : i),
                            onView: () => widget.onDocAction(
                                'Voir ${widget.family.docs[i].title}'),
                            onDownload: () => widget.onDocAction(
                                'Télécharger ${widget.family.docs[i].title}'),
                          ),
                          if (i < widget.family.docs.length - 1)
                            const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _VaultDocRow extends StatelessWidget {
  const _VaultDocRow({
    required this.doc,
    required this.isSelected,
    required this.onTap,
    required this.onView,
    required this.onDownload,
  });
  final _VaultDoc doc;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onView;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              alignment: Alignment.center,
              child: Icon(doc.icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Signé le ${doc.signedOn} •\n${doc.signers}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: onView,
                icon: const Icon(Icons.visibility_outlined,
                    color: AppColors.primaryText, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onDownload,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.file_download_outlined,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Mes données personnelles ─────────────────────────────────────────────────

class _PersonalDataCard extends StatelessWidget {
  const _PersonalDataCard({required this.onStub});
  final void Function(String) onStub;

  static const _rgpdBg = Color(0xFFF5F5F5);

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
            'Cette action est irréversible. Toutes vos données seront définitivement supprimées.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) onStub('Compte supprimé');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Mes données personnelles',
                  style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Gérez vos données conformément au RGPD',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _rgpdBg,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Vos données sont hébergées dans l\'Union européenne '
                    'et protégées conformément au RGPD.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryText),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => onStub('Télécharger mes données'),
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text('Télécharger mes données'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48)),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Supprimer mon compte'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => onStub('Politique de confidentialité'),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText),
                children: const [
                  TextSpan(
                      text: 'Pour plus d\'informations, consultez notre '),
                  TextSpan(
                    text: 'Politique de confidentialité',
                    style: TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Barre d'actions fixe ─────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onCancel,
    required this.onSave,
    this.saving = false,
  });
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        boxShadow: AppShadows.sm,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: saving ? null : onCancel,
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm)),
                child: const Text('Annuler',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: onSave,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: const Text('Enregistrer le profil',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pill de statut ───────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.filled,
  });
  final IconData icon;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(
            color: filled ? AppColors.primary : AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: filled ? AppColors.onPrimary : AppColors.primaryText,
              size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(label,
              style: AppTextStyles.labelMedium.copyWith(
                  color:
                      filled ? AppColors.onPrimary : AppColors.primaryText)),
        ],
      ),
    );
  }
}
