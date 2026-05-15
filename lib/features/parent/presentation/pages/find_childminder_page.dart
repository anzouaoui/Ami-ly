import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/data/models/assmat_profile_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/favorites_provider.dart';
import '../widgets/childminder_card.dart';
import '../widgets/filter_checkbox_tile.dart';
import '../widgets/filter_section_title.dart';
import 'childminder_profile_page.dart';

enum _SortOrder { pertinence, distance, places, date }

/// Formate un nombre de mois en label lisible (ex : "18 mois", "2 ans", "2 ans 6 mois").
String _ageLabel(int months) {
  if (months == 0) return 'Pas de filtre';
  if (months < 12) return '$months mois';
  final years = months ~/ 12;
  final rem = months % 12;
  if (rem == 0) return '$years an${years > 1 ? 's' : ''}';
  return '$years an${years > 1 ? 's' : ''} $rem mois';
}

/// Page "Trouver une assistante maternelle" — branchée sur Firestore.
///
/// Source : [searchableAssmatsProvider] (assmats avec `isSearchable == true`).
/// Filtres + tri appliqués côté client.
class FindChildminderPage extends ConsumerStatefulWidget {
  const FindChildminderPage({super.key});

  @override
  ConsumerState<FindChildminderPage> createState() =>
      _FindChildminderPageState();
}

class _FindChildminderPageState extends ConsumerState<FindChildminderPage> {
  // --- Filtres ---
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  double _radiusKm = 5;
  bool _onlyAvailable = false;

  DateTime? _dateFrom;
  DateTime? _dateTo;

  bool _showAdvancedFilters = true;

  // ── Favoris ────────────────────────────────────────────────────────────────
  bool _onlyFavorites = false;

  // ── Tri ────────────────────────────────────────────────────────────────────
  _SortOrder _sortOrder = _SortOrder.pertinence;

  // ── Tranche d'âge (0 = pas de filtre, valeur en mois) ─────────────────────
  int _childAgeMonths = 0;

  // ── GPS ────────────────────────────────────────────────────────────────────
  Position? _gpsPosition;
  bool _gpsLoading = false;

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

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int get _selectedCount {
    final s = _services.values.where((v) => v).length;
    final h = _schedules.values.where((v) => v).length;
    return s +
        h +
        (_onlyAvailable ? 1 : 0) +
        (_dateFrom != null ? 1 : 0) +
        (_onlyFavorites ? 1 : 0) +
        (_childAgeMonths > 0 ? 1 : 0);
  }

  /// Calcul de distance Haversine entre deux points (en km).
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Applique les filtres client-side sur la liste brute Firestore.
  List<AssmatProfileModel> _applyFilters(
    List<AssmatProfileModel> all,
    double? parentLat,
    double? parentLon,
    Set<String> favoriteIds,
  ) {
    return all.where((a) {
      // Filtre favoris uniquement.
      if (_onlyFavorites && !favoriteIds.contains(a.uid)) return false;

      // Filtre texte sur prénom, nom, adresse.
      if (_searchQuery.isNotEmpty) {
        final fullName = '${a.firstName} ${a.lastName}'.toLowerCase();
        final address = a.address.toLowerCase();
        if (!fullName.contains(_searchQuery) &&
            !address.contains(_searchQuery)) {
          return false;
        }
      }

      // Filtre "places disponibles".
      if (_onlyAvailable && a.availableSlots <= 0) return false;

      // Filtre rayon — seulement si parent ET assmat ont des coordonnées.
      if (parentLat != null &&
          parentLon != null &&
          a.location != null) {
        final dist = _haversine(
          parentLat, parentLon,
          a.location!.latitude, a.location!.longitude,
        );
        if (dist > _radiusKm) return false;
      }

      // Filtre disponibilité souhaitée — seulement si une date de début est choisie.
      if (_dateFrom != null && a.availableFrom != null) {
        // L'assmat doit être disponible ≤ la date souhaitée par le parent.
        if (a.availableFrom!.isAfter(_dateFrom!)) return false;
      }

      // Filtre tranche d'âge — ignoré si le parent n'a pas sélectionné d'âge
      // ou si l'assmat n'a pas renseigné sa tranche (ageGroupMax <= ageGroupMin).
      if (_childAgeMonths > 0 && a.ageGroupMax > a.ageGroupMin) {
        if (_childAgeMonths < a.ageGroupMin ||
            _childAgeMonths > a.ageGroupMax) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Trie [filtered] selon [_sortOrder].
  List<AssmatProfileModel> _sortResults(
    List<AssmatProfileModel> filtered,
    double? parentLat,
    double? parentLon,
  ) {
    final list = List<AssmatProfileModel>.from(filtered);
    switch (_sortOrder) {
      case _SortOrder.pertinence:
        return list;
      case _SortOrder.distance:
        if (parentLat == null || parentLon == null) return list;
        list.sort((a, b) {
          final da = a.location != null
              ? _haversine(parentLat, parentLon,
                  a.location!.latitude, a.location!.longitude)
              : double.infinity;
          final db = b.location != null
              ? _haversine(parentLat, parentLon,
                  b.location!.latitude, b.location!.longitude)
              : double.infinity;
          return da.compareTo(db);
        });
        return list;
      case _SortOrder.places:
        list.sort((a, b) => b.availableSlots.compareTo(a.availableSlots));
        return list;
      case _SortOrder.date:
        list.sort((a, b) {
          if (a.availableFrom == null && b.availableFrom == null) return 0;
          if (a.availableFrom == null) return 1;
          if (b.availableFrom == null) return -1;
          return a.availableFrom!.compareTo(b.availableFrom!);
        });
        return list;
    }
  }

  /// Convertit un [AssmatProfileModel] en [ChildminderSummary] pour la carte.
  ChildminderSummary _toSummary(
    AssmatProfileModel a,
    double? parentLat,
    double? parentLon,
  ) {
    final firstName = a.firstName;
    final lastName = a.lastName;
    final initials = [
      if (firstName.isNotEmpty) firstName[0],
      if (lastName.isNotEmpty) lastName[0],
    ].join().toUpperCase();

    final name =
        '${firstName.isEmpty ? '' : firstName} ${lastName.isEmpty ? '' : lastName}'
            .trim();

    final experience = a.yearsExperience > 0
        ? '${a.yearsExperience} an${a.yearsExperience > 1 ? 's' : ''}'
        : 'Exp. non renseignée';

    final slots = a.availableSlots;
    final places = slots > 0
        ? '$slots place${slots > 1 ? 's' : ''}'
        : 'Complet';

    // Distance calculée si les deux GeoPoints sont disponibles.
    String distance = '—';
    if (parentLat != null &&
        parentLon != null &&
        a.location != null) {
      final km = _haversine(
        parentLat, parentLon,
        a.location!.latitude, a.location!.longitude,
      );
      distance = km < 1
          ? '${(km * 1000).round()} m'
          : '${km.toStringAsFixed(1)} km';
    }

    return ChildminderSummary(
      uid: a.uid,
      initials: initials.isEmpty ? '?' : initials,
      name: name.isEmpty ? 'Assistante maternelle' : name,
      location: a.address.isNotEmpty ? a.address : 'Adresse non renseignée',
      distance: distance,
      experience: experience,
      places: places,
      date: slots > 0 ? 'Disponible' : 'Complet',
      cert: '—',
    );
  }

  Future<void> _requestGpsLocation() async {
    setState(() => _gpsLoading = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Les services de localisation sont désactivés.'),
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              permission == LocationPermission.deniedForever
                  ? 'Accès à la localisation définitivement refusé. Activez-le dans les paramètres.'
                  : 'Permission de localisation refusée.',
            ),
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      // Timeout 15 s — évite un blocage indéfini sur emulateur ou signal faible.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          'Délai de localisation dépassé. Vérifiez votre signal GPS.',
        ),
      );
      if (mounted) setState(() => _gpsPosition = position);
    } catch (e) {
      debugPrint('[GPS] _requestGpsLocation error: $e');
      if (mounted) {
        final msg = e.toString().contains('Délai')
            ? 'Délai de localisation dépassé. Vérifiez votre signal GPS.'
            : 'Impossible d\'obtenir votre position.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial =
        isFrom ? (_dateFrom ?? now) : (_dateTo ?? _dateFrom ?? now);
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
          colorScheme: Theme.of(ctx)
              .colorScheme
              .copyWith(primary: AppColors.primary),
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
    final asyncAssmats = ref.watch(searchableAssmatsProvider);
    final parentProfile = ref.watch(parentProfileProvider).valueOrNull;
    final favoriteIds = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
    // Coordonnées : profil sauvegardé en priorité, GPS en fallback.
    final parentLat = parentProfile?.location?.latitude ?? _gpsPosition?.latitude;
    final parentLon = parentProfile?.location?.longitude ?? _gpsPosition?.longitude;
    final hasParentLocation = parentProfile?.location != null;

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
                searchCtrl: _searchCtrl,
                radiusKm: _radiusKm,
                onRadiusChanged: (v) => setState(() => _radiusKm = v),
                onlyAvailable: _onlyAvailable,
                onOnlyAvailableChanged: (v) =>
                    setState(() => _onlyAvailable = v),
                services: _services,
                onServiceChanged: (k, v) =>
                    setState(() => _services[k] = v),
                schedules: _schedules,
                onScheduleChanged: (k, v) =>
                    setState(() => _schedules[k] = v),
                showAdvanced: _showAdvancedFilters,
                onToggleAdvanced: () =>
                    setState(() => _showAdvancedFilters = !_showAdvancedFilters),
                hasParentLocation: hasParentLocation,
                gpsActive: _gpsPosition != null,
                gpsLoading: _gpsLoading,
                onRequestGps: _requestGpsLocation,
                onClearGps: () => setState(() => _gpsPosition = null),
                dateFrom: _dateFrom,
                dateTo: _dateTo,
                onPickFrom: () => _pickDate(isFrom: true),
                onPickTo: () => _pickDate(isFrom: false),
                childAgeMonths: _childAgeMonths,
                onChildAgeChanged: (v) => setState(() => _childAgeMonths = v),
              ),

              // ── Résultats ──────────────────────────────────────────────────
              asyncAssmats.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Erreur : $e',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error),
                  ),
                ),
                data: (all) {
                  final filtered = _applyFilters(all, parentLat, parentLon, favoriteIds);
                  final sorted = _sortResults(filtered, parentLat, parentLon);
                  final results = sorted
                      .map((a) => _toSummary(a, parentLat, parentLon))
                      .toList();
                  final hasLocation =
                      parentLat != null && parentLon != null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ResultsHeader(
                        count: results.length,
                        radiusKm: _radiusKm.round(),
                      ),
                      _SortBar(
                        current: _sortOrder,
                        locationAvailable: hasLocation,
                        onChanged: (o) => setState(() => _sortOrder = o),
                        onlyFavorites: _onlyFavorites,
                        onToggleFavorites: () =>
                            setState(() => _onlyFavorites = !_onlyFavorites),
                      ),
                      if (results.isEmpty)
                        _EmptyState(hasQuery: _searchQuery.isNotEmpty)
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Column(
                            children: [
                              for (final r in results) ...[
                                ChildminderCard(
                                  data: r,
                                  isFavorite: favoriteIds.contains(r.uid),
                                  onToggleFavorite: () =>
                                      toggleFavoriteWithFeedback(ref, r.uid, context),
                                  onTap: () =>
                                      Navigator.of(context).push(
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
                    ],
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.secondaryText),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasQuery
                ? 'Aucune assistante trouvée pour « ${context.findAncestorStateOfType<_FindChildminderPageState>()?._searchCtrl.text ?? ''} »'
                : 'Aucune assistante maternelle disponible pour le moment.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

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
            icon: const Icon(Icons.arrow_back_rounded,
                size: 28, color: AppColors.primaryText),
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
                child: const Icon(Icons.face_6_rounded,
                    color: Color(0xFF8D6E63), size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AMiLY',
                style: AppTextStyles.titleLarge
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ─── Title section ────────────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.selectedFilters});
  final int selectedFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('Trouver une assistante maternelle',
                    style: AppTextStyles.headlineMedium),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$selectedFilters',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Trouvez une professionnelle agréée près de chez vous',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

// ─── Filter card ──────────────────────────────────────────────────────────────

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.searchCtrl,
    required this.radiusKm,
    required this.onRadiusChanged,
    required this.onlyAvailable,
    required this.onOnlyAvailableChanged,
    required this.services,
    required this.onServiceChanged,
    required this.schedules,
    required this.onScheduleChanged,
    required this.showAdvanced,
    required this.onToggleAdvanced,
    required this.hasParentLocation,
    required this.gpsActive,
    required this.gpsLoading,
    required this.onRequestGps,
    required this.onClearGps,
    required this.onPickFrom,
    required this.onPickTo,
    required this.childAgeMonths,
    required this.onChildAgeChanged,
    this.dateFrom,
    this.dateTo,
  });

  final TextEditingController searchCtrl;
  final double radiusKm;
  final ValueChanged<double> onRadiusChanged;
  final bool onlyAvailable;
  final ValueChanged<bool> onOnlyAvailableChanged;
  final Map<String, bool> services;
  final void Function(String key, bool value) onServiceChanged;
  final Map<String, bool> schedules;
  final void Function(String key, bool value) onScheduleChanged;
  final bool showAdvanced;
  final VoidCallback onToggleAdvanced;
  final bool hasParentLocation;
  final bool gpsActive;
  final bool gpsLoading;
  final VoidCallback onRequestGps;
  final VoidCallback onClearGps;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final int childAgeMonths;
  final ValueChanged<int> onChildAgeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
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
                  controller: searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Prénom, nom ou ville…',
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
                    color: (showAdvanced
                            ? AppColors.accent
                            : AppColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                      color: showAdvanced
                          ? AppColors.divider
                          : AppColors.primary,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.tune_rounded,
                      color: showAdvanced
                          ? AppColors.accent
                          : AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Périmètre de recherche
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const FilterSectionTitle(
                icon: Icons.location_searching_rounded,
                title: 'Périmètre de recherche',
              ),
              Text(
                '${radiusKm.round()} km',
                style: AppTextStyles.labelLarge
                    .copyWith(
                      color: (hasParentLocation || gpsActive)
                          ? AppColors.primary
                          : AppColors.secondaryText,
                    ),
              ),
            ],
          ),
          Slider(
            value: radiusKm,
            min: 1,
            max: 30,
            onChanged: onRadiusChanged,
            activeColor: (hasParentLocation || gpsActive)
                ? AppColors.primary
                : AppColors.secondaryText,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 km',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.secondaryText)),
              Text('15 km',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.secondaryText)),
              Text('30 km',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.secondaryText)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _LocationBanner(
            hasParentLocation: hasParentLocation,
            gpsActive: gpsActive,
            gpsLoading: gpsLoading,
            onRequestGps: onRequestGps,
            onClearGps: onClearGps,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Disponibilité souhaitée
          const FilterSectionTitle(
            icon: Icons.calendar_today_rounded,
            title: 'Disponibilité souhaitée',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DateField(
                    hint: 'À partir du…',
                    date: dateFrom,
                    onTap: onPickFrom),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _DateField(
                    hint: 'Jusqu\'au…',
                    date: dateTo,
                    onTap: onPickTo),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Âge de l'enfant
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const FilterSectionTitle(
                icon: Icons.child_friendly_rounded,
                title: "Âge de l'enfant",
              ),
              Text(
                _ageLabel(childAgeMonths),
                style: AppTextStyles.labelLarge.copyWith(
                  color: childAgeMonths > 0
                      ? AppColors.primary
                      : AppColors.secondaryText,
                ),
              ),
            ],
          ),
          Slider(
            value: childAgeMonths.toDouble(),
            min: 0,
            max: 72,
            divisions: 72,
            onChanged: (v) => onChildAgeChanged(v.round()),
            activeColor: childAgeMonths > 0
                ? AppColors.primary
                : AppColors.secondaryText,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Naissance',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.secondaryText)),
              Text('3 ans',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.secondaryText)),
              Text('6 ans',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.secondaryText)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Places disponibles
          InkWell(
            onTap: () => onOnlyAvailableChanged(!onlyAvailable),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.child_care_rounded,
                      color: AppColors.secondaryText, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Places disponibles uniquement',
                            style: AppTextStyles.labelLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Masquer les assistantes dont le planning est complet',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: onlyAvailable,
                      onChanged: (v) =>
                          onOnlyAvailableChanged(v ?? false),
                      activeColor: AppColors.primary,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Filtres avancés — rétractables
          AnimatedCrossFade(
            crossFadeState: showAdvanced
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const FilterSectionTitle(
                  icon: Icons.schedule_rounded,
                  title: 'Horaires',
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final entry in schedules.entries)
                  FilterCheckboxTile(
                    label: entry.key,
                    value: entry.value,
                    onChanged: (v) =>
                        onScheduleChanged(entry.key, v),
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

// ─── Sort bar ─────────────────────────────────────────────────────────────────

class _SortBar extends StatelessWidget {
  const _SortBar({
    required this.current,
    required this.locationAvailable,
    required this.onChanged,
    required this.onlyFavorites,
    required this.onToggleFavorites,
  });

  final _SortOrder current;
  final bool locationAvailable;
  final ValueChanged<_SortOrder> onChanged;
  final bool onlyFavorites;
  final VoidCallback onToggleFavorites;

  static const _options = [
    (order: _SortOrder.pertinence, label: 'Pertinence', icon: Icons.sort_rounded),
    (order: _SortOrder.distance,   label: 'Distance',   icon: Icons.near_me_rounded),
    (order: _SortOrder.places,     label: 'Places dispo', icon: Icons.group_rounded),
    (order: _SortOrder.date,       label: 'Disponible le', icon: Icons.event_available_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Chip favoris — toujours en tête de liste
            _SortChip(
              label: 'Mes favoris',
              icon: onlyFavorites
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              selected: onlyFavorites,
              enabled: true,
              onTap: onToggleFavorites,
            ),
            const SizedBox(width: AppSpacing.sm),
            for (final opt in _options) ...[
              _SortChip(
                label: opt.label,
                icon: opt.icon,
                selected: current == opt.order,
                enabled: opt.order != _SortOrder.distance || locationAvailable,
                onTap: () {
                  if (opt.order == _SortOrder.distance && !locationAvailable) {
                    return;
                  }
                  onChanged(opt.order);
                },
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? (selected ? AppColors.primary : AppColors.secondaryText)
        : AppColors.divider;
    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.1)
        : Colors.transparent;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location banner ──────────────────────────────────────────────────────────

/// Affiché sous le slider "Périmètre de recherche".
///
/// Cas 1 — parent a une adresse sauvegardée : rien à afficher.
/// Cas 2 — GPS actif : badge vert "Position GPS active" + bouton effacer.
/// Cas 3 — aucune localisation : invitation à activer le GPS.
class _LocationBanner extends StatelessWidget {
  const _LocationBanner({
    required this.hasParentLocation,
    required this.gpsActive,
    required this.gpsLoading,
    required this.onRequestGps,
    required this.onClearGps,
  });

  final bool hasParentLocation;
  final bool gpsActive;
  final bool gpsLoading;
  final VoidCallback onRequestGps;
  final VoidCallback onClearGps;

  @override
  Widget build(BuildContext context) {
    // L'adresse du profil suffit — rien à montrer.
    if (hasParentLocation) return const SizedBox.shrink();

    if (gpsActive) {
      // Badge "Position GPS active".
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.my_location_rounded,
                size: 16, color: AppColors.success),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Position GPS active',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),
            InkWell(
              onTap: onClearGps,
              borderRadius: BorderRadius.circular(AppRadii.full),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: AppColors.success),
            ),
          ],
        ),
      );
    }

    // Invitation à activer le GPS.
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_off_rounded,
              size: 16, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adresse non configurée',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Le filtre rayon est désactivé. Utilisez le GPS ou ajoutez votre adresse dans votre profil.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: gpsLoading ? null : onRequestGps,
                    icon: gpsLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded, size: 16),
                    label: Text(gpsLoading
                        ? 'Localisation…'
                        : 'Utiliser ma position GPS'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: BorderSide(
                          color: AppColors.accent.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      textStyle: AppTextStyles.labelMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
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

// ─── Date field ───────────────────────────────────────────────────────────────

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
            Icon(Icons.event_available_rounded,
                size: 18,
                color: hasDate
                    ? AppColors.primary
                    : AppColors.secondaryText),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                hasDate ? _format(date!) : hint,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: hasDate
                      ? AppColors.primary
                      : AppColors.secondaryText,
                  fontWeight:
                      hasDate ? FontWeight.w600 : FontWeight.w400,
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

// ─── Results header ───────────────────────────────────────────────────────────

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.count, required this.radiusKm});
  final int count;
  final int radiusKm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              count == 0
                  ? 'Aucune assistante trouvée'
                  : '$count assistante${count > 1 ? 's' : ''} maternelle${count > 1 ? 's' : ''} trouvée${count > 1 ? 's' : ''}',
              style: AppTextStyles.labelLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'rayon $radiusKm km',
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.secondaryText),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
