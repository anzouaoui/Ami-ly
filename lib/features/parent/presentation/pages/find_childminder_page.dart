import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/childminder_card.dart';
import '../widgets/filter_checkbox_tile.dart';
import '../widgets/filter_section_title.dart';
import 'childminder_profile_page.dart';

/// Page "Trouver une assistante maternelle" — entrée du flow de recherche.
///
/// Frame "Find a Childminder" du design system :
///   - Header (menu + logo)
///   - Titre + chip liens sélectionnés + sous-titre
///   - Grosse carte de filtres (search + slider + dates + 12 checkboxes)
///   - Bandeau "N assistantes maternelles trouvées • rayon X km"
///   - Liste de [ChildminderCard] (3 mocks)
///
/// Toutes les données sont mockées, les filtres maintiennent leur état
/// local via setState — aucune requête réseau.
class FindChildminderPage extends StatefulWidget {
  const FindChildminderPage({super.key});

  @override
  State<FindChildminderPage> createState() => _FindChildminderPageState();
}

class _FindChildminderPageState extends State<FindChildminderPage> {
  // --- Filtres ---
  double _radiusKm = 5;
  bool _onlyMyCommune = false;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  /// Sections de filtres avancés (Services + Horaires). Visibles par défaut,
  /// togglées ensemble par l'icône tune.
  bool _showAdvancedFilters = true;

  final Map<String, bool> _services = {
    'Exerce en maison d\'assistants maternels': false,
    'Peut accueillir des enfants en situation de handicap': false,
    'Peut véhiculer les enfants': false,
    'Peut fournir des produits d\'hygiène': false,
    'Peut fournir les repas': false,
  };

  final Map<String, bool> _schedules = {
    'Peut être flexible sur les horaires': false,
    'Peut accueillir les enfants la nuit': false,
    'Peut accueillir les enfants le week-end': false,
    'Peut accueillir les enfants les jours fériés': false,
    'Travaille pendant les vacances scolaires': false,
    'Peut répondre aux accueils d\'urgence': false,
  };

  // --- Résultats mockés ---
  static const _results = <ChildminderSummary>[
    ChildminderSummary(
      initials: 'ML',
      name: 'Marie L.',
      location: 'Paris 15e',
      distance: '0.8 km',
      experience: '12 ans',
      places: '1 place',
      date: '01/06/2025',
      cert: 'PSC1',
    ),
    ChildminderSummary(
      initials: 'JD',
      name: 'Julie D.',
      location: 'Paris 15e',
      distance: '1.2 km',
      experience: '5 ans',
      places: '2 places',
      date: 'Immédiate',
      cert: 'PSC1',
    ),
    ChildminderSummary(
      initials: 'SC',
      name: 'Sophie C.',
      location: 'Paris 15e',
      distance: '1.5 km',
      experience: '8 ans',
      places: '1 place',
      date: '01/09/2025',
      cert: 'BEP CSS',
    ),
  ];

  int get _selectedCount {
    final s = _services.values.where((v) => v).length;
    final h = _schedules.values.where((v) => v).length;
    return s + h + (_onlyMyCommune ? 1 : 0);
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom
        ? (_dateFrom ?? now)
        : (_dateTo ?? _dateFrom ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: isFrom ? 'Date de début' : 'Date de fin',
      confirmText: 'Valider',
      cancelText: 'Annuler',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
          if (_dateTo != null && _dateTo!.isBefore(picked)) _dateTo = null;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              _TitleSection(selectedFilters: _selectedCount),
              _FilterCard(
                radiusKm: _radiusKm,
                onRadiusChanged: (v) => setState(() => _radiusKm = v),
                onlyMyCommune: _onlyMyCommune,
                onOnlyMyCommuneChanged: (v) =>
                    setState(() => _onlyMyCommune = v),
                services: _services,
                onServiceChanged: (k, v) => setState(() => _services[k] = v),
                schedules: _schedules,
                onScheduleChanged: (k, v) =>
                    setState(() => _schedules[k] = v),
                showAdvanced: _showAdvancedFilters,
                onToggleAdvanced: () => setState(
                  () => _showAdvancedFilters = !_showAdvancedFilters,
                ),
                dateFrom: _dateFrom,
                dateTo: _dateTo,
                onPickFrom: () => _pickDate(isFrom: true),
                onPickTo: () => _pickDate(isFrom: false),
              ),
              _ResultsHeader(
                count: _results.length,
                radiusKm: _radiusKm.round(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    for (final r in _results) ...[
                      ChildminderCard(
                        data: r,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ChildminderProfilePage(data: r),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header : back button + logo "AMiLY" (carré brun) + spacer.
class _Header extends StatelessWidget {
  const _Header();

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5D8),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.face_6_rounded,
                  color: Color(0xFF8D6E63),
                  size: 20,
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
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.selectedFilters});
  final int selectedFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Trouver une assistante maternelle',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Chip : icône link + nombre de filtres actifs
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$selectedFilters',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Trouvez une professionnelle agréée près de chez vous',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.radiusKm,
    required this.onRadiusChanged,
    required this.onlyMyCommune,
    required this.onOnlyMyCommuneChanged,
    required this.services,
    required this.onServiceChanged,
    required this.schedules,
    required this.onScheduleChanged,
    required this.showAdvanced,
    required this.onToggleAdvanced,
    required this.onPickFrom,
    required this.onPickTo,
    this.dateFrom,
    this.dateTo,
  });

  final double radiusKm;
  final ValueChanged<double> onRadiusChanged;
  final bool onlyMyCommune;
  final ValueChanged<bool> onOnlyMyCommuneChanged;
  final Map<String, bool> services;
  final void Function(String key, bool value) onServiceChanged;
  final Map<String, bool> schedules;
  final void Function(String key, bool value) onScheduleChanged;

  /// Visibilité des sections "Services proposés" + "Horaires".
  /// Pilotée par l'icône tune.
  final bool showAdvanced;
  final VoidCallback onToggleAdvanced;

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ligne search + bouton filtres avancés
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Ville, quartier ou spécialité',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              InkWell(
                onTap: onToggleAdvanced,
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (showAdvanced ? AppColors.accent : AppColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                      color: showAdvanced
                          ? AppColors.divider
                          : AppColors.primary,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.tune_rounded,
                    color:
                        showAdvanced ? AppColors.accent : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Périmètre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const FilterSectionTitle(
                icon: Icons.location_searching_rounded,
                title: 'Périmètre de recherche',
              ),
              Text(
                '${radiusKm.round()} km',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: radiusKm,
            min: 1,
            max: 30,
            onChanged: onRadiusChanged,
            activeColor: AppColors.primary,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 km', style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondaryText)),
              Text('15 km', style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondaryText)),
              Text('30 km', style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondaryText)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Disponibilité
          const FilterSectionTitle(
            icon: Icons.calendar_today_rounded,
            title: 'Disponibilité souhaitée',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  hint: 'À partir du...',
                  date: dateFrom,
                  onTap: onPickFrom,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _DateField(
                  hint: 'Jusqu\'au...',
                  date: dateTo,
                  onTap: onPickTo,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // "Ma commune uniquement"
          InkWell(
            onTap: () => onOnlyMyCommuneChanged(!onlyMyCommune),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.home_work_rounded,
                    color: AppColors.secondaryText,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ma commune uniquement',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Afficher uniquement les résultats de votre ville',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: onlyMyCommune,
                      onChanged: (v) => onOnlyMyCommuneChanged(v ?? false),
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Filtres avancés (Services proposés + Horaires) — rétractables
          // via l'icône tune.
          AnimatedCrossFade(
            crossFadeState: showAdvanced
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Services proposés
                const FilterSectionTitle(
                  icon: Icons.task_alt_rounded,
                  title: 'Services proposés',
                  iconColor: AppColors.success,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final entry in services.entries)
                  FilterCheckboxTile(
                    label: entry.key,
                    value: entry.value,
                    onChanged: (v) => onServiceChanged(entry.key, v),
                  ),
                const SizedBox(height: AppSpacing.lg),

                // Horaires
                const FilterSectionTitle(
                  icon: Icons.schedule_rounded,
                  title: 'Horaires',
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final entry in schedules.entries)
                  FilterCheckboxTile(
                    label: entry.key,
                    value: entry.value,
                    onChanged: (v) => onScheduleChanged(entry.key, v),
                  ),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.hint,
    required this.onTap,
    this.date,
  });
  final String hint;
  final VoidCallback onTap;
  final DateTime? date;

  String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: hasDate
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          border: Border.all(
            color: hasDate ? AppColors.primary : AppColors.divider,
            width: hasDate ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 18,
              color: hasDate ? AppColors.primary : AppColors.secondaryText,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                hasDate ? _format(date!) : hint,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: hasDate
                      ? AppColors.primary
                      : AppColors.secondaryText,
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.count, required this.radiusKm});
  final int count;
  final int radiusKm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '$count assistantes maternelles trouvées',
              style: AppTextStyles.labelLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'rayon $radiusKm km',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.secondaryText,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
