import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../parent/presentation/widgets/filter_checkbox_tile.dart';
import '../../../parent/presentation/widgets/personal_info_card.dart';
import '../../../parent/presentation/widgets/profile_form_field.dart';

/// Page "Mon profil" de l'Assistante Maternelle.
///
/// Affiche les informations visibles par les parents et la PMI, avec :
///   - Header standard (back + logo AMiLY)
///   - Titre + sous-titre + bouton CTA "Passer à Pro"
///   - Chips de statut (disponibilité, agrément, identité)
///   - Sections : Infos perso / Disponibilité / Pratiques / Services /
///     Horaires / Diplômes / Tarifs
///   - Barre d'actions fixe : Annuler + Enregistrer le profil
class AssMatProfilePage extends StatelessWidget {
  const AssMatProfilePage({super.key});

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _ProfileHeader(),

            // ---- Contenu scrollable ----
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitleSection(
                      onPassPro: () => _stub(context, 'Passer à Pro'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _StatusChips(),
                    const SizedBox(height: AppSpacing.lg),
                    PersonalInfoCard(
                      firstName: 'Marie',
                      lastName: 'Lefèvre',
                      phone: '06 12 34 56 78',
                      email: 'marie.lefevre@email.com',
                      address: '12 rue des Lilas, 75015 Paris',
                      onChangePhoto: () => _stub(context, 'Changer la photo'),
                      // Variante avatar assmat : cercle vert tinté + initiales primary.
                      avatarBg: AppColors.secondary,
                      avatarFg: AppColors.primary,
                      descriptionLabel: 'Description / Présentation',
                      descriptionHint:
                          'Parlez-nous de votre expérience et de votre cadre d\'accueil…',
                      descriptionValue:
                          'Assistante maternelle agréée depuis 8 ans, j\'accueille les enfants dans un environnement chaleureux et stimulant. Mon appartement dispose d\'un grand espace de jeux sécurisé et d\'un jardin partagé…',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _AvailabilityCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _PracticalInfoCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _ServicesOfferedCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _FlexibilityCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _DiplomasCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _HomePhotosCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _AccreditationCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _ImportantContactsCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _IdentityVerificationCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _SpecialitiesCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _DigitalVaultCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _PersonalDataCard(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),

            // ---- Barre d'actions fixe ----
            _BottomActionBar(
              onCancel: () => Navigator.of(context).maybePop(),
              onSave: () {
                _stub(context, 'Profil enregistré');
                Navigator.of(context).maybePop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Header : back + carré brun logo + "AMiLY".
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 28,
              color: AppColors.primaryText,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Retour',
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
            child: const Icon(
              Icons.face_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'AMiLY',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Titre "Mon profil" + sous-titre + bouton "Passer à Pro" en accent.
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
              Text(
                'Mon profil',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Gérez vos informations visibles par les parents et la PMI',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.secondaryText,
                ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

/// Rangée de chips de statut (Wrap pour gérer les écrans étroits).
class _StatusChips extends StatelessWidget {
  const _StatusChips();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _StatusChip(
          icon: Icons.check_circle_rounded,
          label: '1 place(s) disponible(s)',
          filled: true,
        ),
        _StatusChip(
          icon: Icons.shield_outlined,
          label: 'Agrément valide',
          filled: false,
        ),
        _StatusChip(
          icon: Icons.verified_user_outlined,
          label: 'Identité vérifiée',
          filled: false,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// Carte de disponibilité
// -----------------------------------------------------------------

/// Carte de contrôle de la visibilité du profil dans les recherches des
/// parents. Toggle on/off + date de disponibilité optionnelle.
class _AvailabilityCard extends StatefulWidget {
  const _AvailabilityCard();

  @override
  State<_AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<_AvailabilityCard> {
  bool _isAvailable = true;
  DateTime _availableFrom = DateTime(2025, 5, 1);

  static const _months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
  ];

  String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${_months[d.month - 1]}/${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _availableFrom,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12, 31),
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
          color: _isAvailable
              ? AppColors.primary
              : AppColors.divider,
          width: _isAvailable ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header : pastille + titre/sous-titre + switch
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pastille verte
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isAvailable
                      ? AppColors.primary
                      : AppColors.secondaryText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Titre + sous-titre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isAvailable
                          ? 'Disponible — J\'accueille de nouveaux enfants'
                          : 'Indisponible — Je n\'accueille pas',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _isAvailable
                          ? 'Votre profil est visible par les parents en recherche'
                          : 'Votre profil est masqué des recherches',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch(
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),

          // Section date — affichée seulement si disponible
          if (_isAvailable) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Disponible à partir du',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _format(_availableFrom),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: AppColors.secondaryText,
                    ),
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

// -----------------------------------------------------------------
// Informations pratiques
// -----------------------------------------------------------------

/// Carte "Informations pratiques" : tabac, formation 1ers secours,
/// animal au domicile, nombre de places max (agrément).
class _PracticalInfoCard extends StatefulWidget {
  const _PracticalInfoCard();

  @override
  State<_PracticalInfoCard> createState() => _PracticalInfoCardState();
}

class _PracticalInfoCardState extends State<_PracticalInfoCard> {
  String _tobacco = 'Non fumeur';
  String _firstAid = 'PSC1 validé';
  String _pet = 'Pas d\'animal';

  static const _tobaccoOptions = ['Non fumeur', 'Fumeur (extérieur)', 'Fumeur'];
  static const _firstAidOptions = [
    'PSC1 validé',
    'SST validé',
    'Aucune formation',
  ];
  static const _petOptions = [
    'Pas d\'animal',
    'Chat',
    'Chien',
    'Autre animal',
  ];

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
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.home_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Informations pratiques',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ces informations sont visibles par les parents',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Dropdowns avec icône labélisée
          _IconLabeledDropdown(
            icon: Icons.smoking_rooms_rounded,
            label: 'Tabac au domicile',
            value: _tobacco,
            options: _tobaccoOptions,
            onChanged: (v) => setState(() => _tobacco = v ?? 'Non fumeur'),
          ),
          const SizedBox(height: AppSpacing.md),
          _IconLabeledDropdown(
            icon: Icons.monitor_heart_outlined,
            label: 'Formation 1ers secours',
            value: _firstAid,
            options: _firstAidOptions,
            onChanged: (v) => setState(() => _firstAid = v ?? 'PSC1 validé'),
          ),
          const SizedBox(height: AppSpacing.md),
          _IconLabeledDropdown(
            icon: Icons.pets_rounded,
            label: 'Animal au domicile',
            value: _pet,
            options: _petOptions,
            onChanged: (v) => setState(() => _pet = v ?? 'Pas d\'animal'),
          ),
          const SizedBox(height: AppSpacing.md),

          // Places max : input numérique simple
          const ProfileFormField(
            label: 'Places max (agrément)',
            initialValue: '4',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),

          // Enfants accueillis actuellement
          const ProfileFormField(
            label: 'Enfants accueillis actuellement',
            initialValue: '3',
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

// -----------------------------------------------------------------
// Cartes à checkboxes : Services proposés + Horaires & Flexibilité
// -----------------------------------------------------------------

/// Carte générique : header icône+titre+sous-titre + liste de checkboxes.
/// Utilisée pour "Services proposés" et "Horaires & Flexibilité" — chaque
/// carte gère son propre état via sa Map initiale.
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
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(widget.title, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Checkboxes
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

/// Carte "Services proposés" — thin wrapper sur [_ChecklistCard] avec
/// la spec services.
class _ServicesOfferedCard extends StatelessWidget {
  const _ServicesOfferedCard();

  @override
  Widget build(BuildContext context) {
    return _ChecklistCard(
      icon: Icons.volunteer_activism_rounded,
      title: 'Services proposés',
      subtitle: 'Indiquez les services que vous proposez aux familles',
      initialItems: const {
        'Exerce en maison d\'assistants maternels': false,
        'Peut accueillir des enfants en situation de handicap': true,
        'Peut véhiculer les enfants': false,
        'Peut fournir des produits d\'hygiène': true,
        'Peut fournir les repas': true,
      },
    );
  }
}

/// Carte "Horaires & Flexibilité" — disponibilités horaires de l'assmat.
class _FlexibilityCard extends StatelessWidget {
  const _FlexibilityCard();

  @override
  Widget build(BuildContext context) {
    return _ChecklistCard(
      icon: Icons.access_time_rounded,
      title: 'Horaires & Flexibilité',
      subtitle: 'Précisez vos disponibilités horaires',
      initialItems: const {
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

// -----------------------------------------------------------------
// Diplômes & Expérience
// -----------------------------------------------------------------

/// Carte "Diplômes & Expérience" : liste de diplômes (chips beige avec
/// close icon + bouton "+ Ajouter") et textarea parcours professionnel.
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

  void _removeDiploma(String d) {
    setState(() => _diplomas.remove(d));
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
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.school_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Diplômes & Expérience',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section Diplômes & Formations
          Text(
            'Diplômes & Formations',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section Parcours professionnel
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.work_outline_rounded,
                color: AppColors.primaryText,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Parcours professionnel',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
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

/// Chip diplôme : pill beige avec texte + croix de suppression.
/// Style différent de [InterestTagChip] (vert) pour distinguer
/// les diplômes côté assmat.
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
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          InkWell(
            onTap: onRemove,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                color: AppColors.primaryText,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// Photos du domicile
// -----------------------------------------------------------------

/// Données d'une photo mockée (label + couleur de fond).
class _PhotoData {
  const _PhotoData({required this.label, required this.color});
  final String label;
  final Color color;
}

/// Carte "Photos du domicile" : grille 2 colonnes, vignettes avec légende
/// semi-transparente + slot tiretés "Ajouter".
class _HomePhotosCard extends StatefulWidget {
  const _HomePhotosCard();

  @override
  State<_HomePhotosCard> createState() => _HomePhotosCardState();
}

class _HomePhotosCardState extends State<_HomePhotosCard> {
  final List<_PhotoData> _photos = const [
    _PhotoData(
      label: 'Espace de jeux principal',
      color: Color(0xFFE0E0E0),
    ),
    _PhotoData(
      label: 'Chambre sieste',
      color: Color(0xFFE0E0E0),
    ),
    _PhotoData(
      label: 'Jardin partagé',
      color: Color(0xFFE0E0E0),
    ),
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
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.home_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Photos du domicile', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ajoutez des photos de votre espace d\'accueil',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Grille 2 colonnes
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppSpacing.md;
              final tileWidth = (constraints.maxWidth - spacing) / 2;
              // Ratio ~4/3 pour les vignettes.
              final tileHeight = tileWidth * 0.82;

              // On construit les tuiles photos + le slot "Ajouter" à la suite.
              final photoTiles = _photos
                  .map(
                    (p) => _PhotoTile(
                      label: p.label,
                      bgColor: p.color,
                      width: tileWidth,
                      height: tileHeight,
                    ),
                  )
                  .toList();

              final addTile = _AddPhotoTile(
                width: tileWidth,
                height: tileHeight,
                onTap: _addPhoto,
              );

              final allTiles = [...photoTiles, addTile];

              // On dispose manuellement en rangées de 2.
              final rows = <Widget>[];
              for (var i = 0; i < allTiles.length; i += 2) {
                final left = allTiles[i];
                final right = i + 1 < allTiles.length ? allTiles[i + 1] : null;
                rows.add(
                  Row(
                    children: [
                      left,
                      const SizedBox(width: spacing),
                      right ?? SizedBox(width: tileWidth),
                    ],
                  ),
                );
                if (i + 2 < allTiles.length) {
                  rows.add(const SizedBox(height: spacing));
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rows,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Vignette photo : fond gris + icône image centrée + overlay sombre
/// avec le nom de la photo en bas.
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
            // Fond photo (mock gris)
            Container(
              color: bgColor,
              alignment: Alignment.center,
              child: Icon(
                Icons.image_outlined,
                size: width * 0.18,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),

            // Overlay légende en bas
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xCC1A1A1A), // ~80 % opaque noir
                      Color(0x001A1A1A), // transparent
                    ],
                    stops: [0.0, 1.0],
                  ),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slot "Ajouter" : bordure tiretée via CustomPaint + icône + texte.
class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({
    required this.width,
    required this.height,
    required this.onTap,
  });

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
                Icon(
                  Icons.add_rounded,
                  size: width * 0.22,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ajouter',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Peint une bordure tiretée arrondie (rayon = AppRadii.md).
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
        dashedPath.addPath(
          metric.extractPath(distance, end),
          Offset.zero,
        );
        distance += dashLen + gapLen;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------
// Numéro d'agrément
// -----------------------------------------------------------------

/// Carte "Numéro d'agrément" :
///   - Champ numéro d'agrément (texte libre)
///   - Champ date d'expiration (date picker)
///   - Section "Photo de l'agrément" : vignette pleine largeur avec badge
///     "Visible parents & PMI" en overlay bas.
class _AccreditationCard extends StatefulWidget {
  const _AccreditationCard();

  @override
  State<_AccreditationCard> createState() => _AccreditationCardState();
}

class _AccreditationCardState extends State<_AccreditationCard> {
  DateTime _expiresOn = DateTime(2026, 12, 31);
  bool _isCertified = true;

  static const _months = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12',
  ];

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${_months[d.month - 1]}/${d.year}';

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresOn,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040, 12, 31),
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
          // ── Header ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Numéro d\'agrément', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Numéro d'agrément ──
          const ProfileFormField(
            label: 'Numéro d\'agrément',
            initialValue: 'PMI-2024-75015-0042',
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Date d'expiration ──
          _DatePickerField(
            label: 'Date d\'expiration',
            value: _fmt(_expiresOn),
            onTap: _pickExpiry,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Section photo de l'agrément ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primaryText,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Photo de l\'agrément',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Cette photo sera visible par les parents et la PMI pour vérification.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Vignette photo pleine largeur ──
          GestureDetector(
            onTap: _changePhoto,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fond photo mock (gris neutre)
                    Container(
                      color: const Color(0xFFD0CCCA),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),

                    // Badge "Visible parents & PMI" en bas centré
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadii.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Visible parents & PMI',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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

          // ── Bloc certification ──
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
                  // Checkbox
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _isCertified,
                      onChanged: (v) =>
                          setState(() => _isCertified = v ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Texte
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Je certifie que ce numéro d\'agrément est valide',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Toute fausse déclaration peut entraîner la '
                          'suspension de votre compte',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Code PMI ──
          Text(
            'Code PMI (fourni par votre PMI)',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const ProfileFormField(
            label: '',
            initialValue: 'PMI-75015',
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ce code vous rattache à votre PMI de secteur',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Champ date cliquable : label + conteneur tappable avec icône calendrier.
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

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
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.primaryText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// Contacts importants
// -----------------------------------------------------------------

/// Carte "Contacts importants" : contacts professionnels d'urgence
/// et de référence. Chaque contact est affiché dans une sous-section
/// avec icône, champs Nom + Téléphone, et un bouton de contact rapide.
class _ImportantContactsCard extends StatelessWidget {
  const _ImportantContactsCard();

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
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.phone_in_talk_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Contacts importants', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Vos contacts professionnels d\'urgence et de référence',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // PMI
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

          // Relais Petite Enfance (RPE)
          _ContactSection(
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

          // Centre antipoison
          _ContactSection(
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

          // Tiers à contacter
          _ContactSection(
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

          // Numéros d'urgence
          const _EmergencyNumbersSection(),
        ],
      ),
    );
  }

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Section "Numéros d'urgence" : 3 numéros fixes (fond rose pâle, chiffre
/// rouge) + champ "Autre numéro personnalisé" éditable.
class _EmergencyNumbersSection extends StatelessWidget {
  const _EmergencyNumbersSection();

  // Fond rose très pâle des cartes urgence.
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
        // En-tête
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.phone_outlined,
              color: AppColors.error,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Numéros d\'urgence',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Cartes fixes — fond rose pâle, séparées
        for (final item in _numbers) ...[
          _EmergencyRow(
            label: item.label,
            number: item.number,
            bg: _rowBg,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.xs),

        // Champ personnalisé
        Text(
          'Autre numéro personnalisé',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
          label: '',
          initialValue: '01 45 67 00 00',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

/// Carte d'un numéro d'urgence : label à gauche + numéro rouge à droite,
/// fond coloré configurable.
class _EmergencyRow extends StatelessWidget {
  const _EmergencyRow({
    required this.label,
    required this.number,
    required this.bg,
  });

  final String label;
  final String number;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryText,
              ),
            ),
          ),
          Text(
            number,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sous-section d'un contact : icône + label + 1 ou 2 champs + bouton
/// optionnel. Générique pour PMI, RPE, Centre antipoison, etc.
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

  // Premier champ (toujours affiché)
  final String firstFieldLabel;
  final String firstFieldMock;
  final TextInputType firstKeyboard;

  // Second champ (optionnel)
  final String? secondFieldLabel;
  final String? secondFieldMock;
  final TextInputType secondKeyboard;

  // Bouton d'action rapide (optionnel)
  final String? callLabel;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // En-tête de sous-section
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Premier champ
        ProfileFormField(
          label: firstFieldLabel,
          initialValue: firstFieldMock,
          keyboardType: firstKeyboard,
        ),

        // Second champ (si renseigné)
        if (secondFieldLabel != null && secondFieldMock != null) ...[
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
            label: secondFieldLabel!,
            initialValue: secondFieldMock!,
            keyboardType: secondKeyboard,
          ),
        ],

        // Bouton de contact rapide (si renseigné)
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
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// -----------------------------------------------------------------
// Vérification d'identité
// -----------------------------------------------------------------

/// Carte "Vérification d'identité" :
///   - Statut "Identité vérifiée" avec icône checkmark vert + date
///   - Note RGPD fond amber pâle avec icône cadenas
class _IdentityVerificationCard extends StatelessWidget {
  const _IdentityVerificationCard();

  // Fond amber très pâle pour la note RGPD.
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
          // ── Header ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.credit_card_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Vérification d\'identité',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Statut vérifié ──
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Identité vérifiée',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Vérification effectuée le 2024-01-15',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Note RGPD ──
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
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryText,
                    ),
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

// -----------------------------------------------------------------
// Spécialités & compétences
// -----------------------------------------------------------------

/// Carte "Spécialités & compétences" : chips beige supprimables + bouton
/// "+ Ajouter" inline dans le même Wrap.
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
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_border_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Spécialités & compétences',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Chips + bouton Ajouter dans le même Wrap
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final tag in _tags)
                _DiplomaChip(label: tag, onRemove: () => _remove(tag)),

              // Bouton + Ajouter inline
              InkWell(
                onTap: _onAdd,
                borderRadius: BorderRadius.circular(AppRadii.full),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: AppColors.primaryText,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Ajouter',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
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

// -----------------------------------------------------------------
// Coffre-fort numérique
// -----------------------------------------------------------------

/// Un document dans le coffre-fort d'une famille.
class _VaultDoc {
  const _VaultDoc({
    required this.title,
    required this.signedOn,
    required this.signers,
    required this.icon,
  });
  final String title;
  final String signedOn;
  final String signers;
  final IconData icon;
}

/// Données d'une famille dans le coffre-fort (avec ses documents).
class _FamilyVaultData {
  const _FamilyVaultData({
    required this.name,
    required this.subtitle,
    required this.docs,
  });
  final String name;
  final String subtitle;
  final List<_VaultDoc> docs;
  int get docCount => docs.length;
}

/// Carte "Coffre-fort numérique" : barre RGPD + familles expandables.
/// Tap sur une famille → affiche/masque la liste de documents.
class _DigitalVaultCard extends StatefulWidget {
  const _DigitalVaultCard();

  @override
  State<_DigitalVaultCard> createState() => _DigitalVaultCardState();
}

class _DigitalVaultCardState extends State<_DigitalVaultCard> {
  // Index de la famille ouverte (null = tout replié).
  int? _expandedIndex = 0; // Dupont ouvert par défaut.

  static final List<_FamilyVaultData> _families = [
    _FamilyVaultData(
      name: 'Famille Dupont',
      subtitle: 'Lucas & Chloé',
      docs: const [
        _VaultDoc(
          title: 'Contrat de garde',
          signedOn: '01/09/2025',
          signers: 'Sophie Dupont, Marie Lefèvre',
          icon: Icons.description_outlined,
        ),
        _VaultDoc(
          title: 'Engagement qualité',
          signedOn: '20/08/2025',
          signers: 'Sophie Dupont, Marie Lefèvre',
          icon: Icons.task_outlined,
        ),
        _VaultDoc(
          title: 'Droit à l\'image',
          signedOn: '01/09/2025',
          signers: 'Sophie Dupont',
          icon: Icons.visibility_outlined,
        ),
        _VaultDoc(
          title: 'Autorisation de sortie',
          signedOn: '01/09/2025',
          signers: 'Sophie Dupont',
          icon: Icons.shield_outlined,
        ),
        _VaultDoc(
          title: 'Fiche santé Lucas',
          signedOn: '01/09/2025',
          signers: 'Sophie Dupont',
          icon: Icons.shield_outlined,
        ),
        _VaultDoc(
          title: 'Fiche santé Chloé',
          signedOn: '01/09/2025',
          signers: 'Sophie Dupont',
          icon: Icons.shield_outlined,
        ),
        _VaultDoc(
          title: 'Carnet de vaccination Lucas',
          signedOn: '01/09/2025',
          signers: 'Sophie Dupont',
          icon: Icons.shield_outlined,
        ),
        _VaultDoc(
          title: 'Carnet de vaccination Chloé',
          signedOn: '01/09/2025',
          signers: 'Sophie Dupont',
          icon: Icons.shield_outlined,
        ),
        _VaultDoc(
          title: 'Fiche de paie Janvier',
          signedOn: '05/01/2026',
          signers: 'Sophie Dupont',
          icon: Icons.receipt_long_outlined,
        ),
        _VaultDoc(
          title: 'Fiche de paie Février',
          signedOn: '05/02/2026',
          signers: 'Sophie Dupont',
          icon: Icons.receipt_long_outlined,
        ),
        _VaultDoc(
          title: 'Fiche de paie Mars',
          signedOn: '05/03/2026',
          signers: 'Sophie Dupont',
          icon: Icons.receipt_long_outlined,
        ),
      ],
    ),
    _FamilyVaultData(
      name: 'Famille Martin',
      subtitle: 'Emma',
      docs: const [
        _VaultDoc(
          title: 'Contrat de garde',
          signedOn: '15/01/2026',
          signers: 'Julie Martin, Marie Lefèvre',
          icon: Icons.description_outlined,
        ),
        _VaultDoc(
          title: 'Droit à l\'image',
          signedOn: '15/01/2026',
          signers: 'Julie Martin',
          icon: Icons.visibility_outlined,
        ),
        _VaultDoc(
          title: 'Fiche santé Emma',
          signedOn: '15/01/2026',
          signers: 'Julie Martin',
          icon: Icons.shield_outlined,
        ),
        _VaultDoc(
          title: 'Fiche de paie Mars',
          signedOn: '05/03/2026',
          signers: 'Julie Martin',
          icon: Icons.receipt_long_outlined,
        ),
        _VaultDoc(
          title: 'Fiche de paie Avril',
          signedOn: '05/04/2026',
          signers: 'Julie Martin',
          icon: Icons.receipt_long_outlined,
        ),
      ],
    ),
  ];

  int get _totalDocs => _families.fold(0, (s, f) => s + f.docCount);

  void _toggle(int index) {
    setState(() => _expandedIndex = _expandedIndex == index ? null : index);
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
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Coffre-fort numérique', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Dossiers complets par famille — contrats, documents et '
            'fiches de paie signés',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Barre info RGPD
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: AppColors.divider,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.circle_outlined,
                  size: 14,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Stockage chiffré • Conforme RGPD • '
                    '$_totalDocs document(s) archivé(s) • '
                    '${_families.length} famille(s)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Familles expandables
          for (var i = 0; i < _families.length; i++) ...[
            _FamilyVaultRow(
              family: _families[i],
              isExpanded: i == _expandedIndex,
              onTap: () => _toggle(i),
            ),
            if (i < _families.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Ligne famille expandable — StatefulWidget pour tracker le doc sélectionné.
class _FamilyVaultRow extends StatefulWidget {
  const _FamilyVaultRow({
    required this.family,
    required this.isExpanded,
    required this.onTap,
  });

  final _FamilyVaultData family;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  State<_FamilyVaultRow> createState() => _FamilyVaultRowState();
}

class _FamilyVaultRowState extends State<_FamilyVaultRow> {
  int? _selectedDoc; // index du document sélectionné (null = aucun)

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── En-tête famille ──
        InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: widget.isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.assmatIconBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.child_care_rounded,
                    size: 22,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.family.name} —\n${widget.family.subtitle}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${widget.family.docCount} document(s)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    '${widget.family.docCount}',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Liste documents animée ──
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
                  // Ligne verticale timeline
                  Container(
                    width: 2,
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    color: AppColors.divider,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0;
                            i < widget.family.docs.length;
                            i++) ...[
                          _VaultDocRow(
                            doc: widget.family.docs[i],
                            isSelected: i == _selectedDoc,
                            onTap: () => setState(() =>
                                _selectedDoc = _selectedDoc == i ? null : i),
                            onView: () => _stub(
                                'Voir ${widget.family.docs[i].title}'),
                            onDownload: () => _stub(
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

/// Ligne d'un document : icône + titre + date/signataires.
/// Quand [isSelected] : fond gris + boutons Voir + Télécharger (orange).
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
            // Icône document
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

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Signé le ${doc.signedOn} •\n${doc.signers}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Boutons d'action (visibles seulement si sélectionné)
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: onView,
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.primaryText,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Bouton télécharger — carré orange arrondi
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
                  child: const Icon(
                    Icons.file_download_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// Mes données personnelles
// -----------------------------------------------------------------

/// Carte "Mes données personnelles" : note RGPD + bouton télécharger +
/// bouton supprimer compte (rouge) + lien politique de confidentialité.
class _PersonalDataCard extends StatelessWidget {
  const _PersonalDataCard();

  static const _rgpdBg = Color(0xFFF5F5F5);

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront '
          'définitivement supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      _stub(context, 'Compte supprimé');
    }
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
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Mes données personnelles',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gérez vos données conformément au RGPD',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Note RGPD hébergement UE
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
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Bouton Télécharger mes données
          OutlinedButton.icon(
            onPressed: () => _stub(context, 'Télécharger mes données'),
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text('Télécharger mes données'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Bouton Supprimer mon compte (rouge)
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

          // Lien politique de confidentialité
          GestureDetector(
            onTap: () => _stub(context, 'Politique de confidentialité'),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
                children: const [
                  TextSpan(
                    text: 'Pour plus d\'informations, consultez notre ',
                  ),
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

// -----------------------------------------------------------------
// Barre d'actions fixe
// -----------------------------------------------------------------

/// Barre fixe en bas de l'écran : Annuler (outlined) + Enregistrer (filled).
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onCancel,
    required this.onSave,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                child: const Text(
                  'Annuler',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 18),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Enregistrer le profil',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// Statut chips
// -----------------------------------------------------------------

/// Pill de statut : variante `filled` (primary vert plein) ou outlined
/// (fond blanc avec border).
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(
          color: filled ? AppColors.primary : AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: filled ? AppColors.onPrimary : AppColors.primaryText,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: filled ? AppColors.onPrimary : AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
