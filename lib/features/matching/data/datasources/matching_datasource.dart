import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../features/auth/data/models/assmat_profile_model.dart';
import '../../../../features/auth/data/models/parent_profile_model.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/geo_distance.dart';
import '../models/match_reason.dart';
import '../models/match_suggestion.dart';

/// Résultat intermédiaire pour le scoring côté parent.
class _ScoredAssmat {
  const _ScoredAssmat({
    required this.assmat,
    required this.score,
    required this.reasons,
    this.distanceKm,
  });

  final AssmatProfileModel assmat;
  final double score;
  final List<MatchReason> reasons;
  final double? distanceKm;

  MatchSuggestion toSuggestion(String parentUid) => MatchSuggestion(
        assmatUid: assmat.uid,
        parentUid: parentUid,
        score: score,
        reasons: reasons,
        assmatProfile: assmat,
        distanceKm: distanceKm,
        generatedAt: DateTime.now(),
      );
}

/// Résultat intermédiaire pour le scoring côté assmat.
class _ScoredParent {
  const _ScoredParent({
    required this.parent,
    required this.score,
    required this.reasons,
    required this.distanceKm,
  });

  final ParentProfileModel parent;
  final double score;
  final List<MatchReason> reasons;
  final double distanceKm;

  MatchSuggestion toSuggestion(String assmatUid) => MatchSuggestion(
        assmatUid: assmatUid,
        parentUid: parent.uid,
        score: score,
        reasons: reasons,
        parentProfile: parent.firstName,
        distanceKm: distanceKm,
        generatedAt: DateTime.now(),
      );
}

/// Interface d'accès aux données pour le matching entre parents et assmats.
class MatchingDatasource {
  MatchingDatasource(this._firebase);

  final FirebaseService _firebase;

  static const _maxDistanceDefault = 15.0;

  /// Nombre maximal de suggestions calculées et persistées.
  static const _maxSuggestions = 20;

  /// Nombre de suggestions remontées par les streams.
  static const _watchLimit = 10;

  // Barème du score parent → assmat (total max = 100 points).
  static const _proximityPoints = 20.0;
  static const _ageCompatibilityPoints = 25.0;
  static const _unknownChildAgePoints = 12.0;
  static const _servicesPoints = 15.0;
  static const _schedulesPoints = 10.0;
  static const _availabilityPoints = 15.0;
  static const _favoritePoints = 15.0;

  /// Nombre de raisons possibles côté assmat (proximité, services, places).
  static const _maxAssmatSideReasons = 3.0;

  CollectionReference<Map<String, dynamic>> get _suggestions =>
      _firebase.firestore.collection('suggestions');

  /// Calcule les meilleures suggestions de match pour un parent donné.
  Future<List<MatchSuggestion>> calculateParentMatches({
    required String parentUid,
    required ParentProfileModel parentProfile,
    required List<int> childAgesMonths,
    double? gpsLat,
    double? gpsLon,
  }) async {
    final double lat;
    final double lon;

    if (parentProfile.location != null) {
      lat = parentProfile.location!.latitude;
      lon = parentProfile.location!.longitude;
    } else if (gpsLat != null && gpsLon != null) {
      lat = gpsLat;
      lon = gpsLon;
    } else {
      return [];
    }

    final assmatSnapshot = await _firebase.assmatsCollection
        .where('isSearchable', isEqualTo: true)
        .get();

    final assmats = assmatSnapshot.docs
        .map(AssmatProfileModel.fromFirestore)
        .toList();

    if (assmats.isEmpty) return [];

    final favoriteIds = await _loadFavoriteIds(parentUid);
    final scored = <_ScoredAssmat>[];

    for (final assmat in assmats) {
      final candidate = _scoreAssmat(
        assmat,
        lat: lat,
        lon: lon,
        childAgesMonths: childAgesMonths,
        isFavorite: favoriteIds.contains(assmat.uid),
      );
      if (candidate.reasons.isNotEmpty) scored.add(candidate);
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final results = scored.take(_maxSuggestions).toList();

    await _replaceSuggestions(
      'parentUid',
      parentUid,
      results.map((s) => s.toSuggestion(parentUid)),
    );

    return results.map((s) => s.toSuggestion(parentUid)).toList();
  }

  /// Score (0-1) et raisons du match entre un parent situé en
  /// ([lat], [lon]) et [assmat].
  _ScoredAssmat _scoreAssmat(
    AssmatProfileModel assmat, {
    required double lat,
    required double lon,
    required List<int> childAgesMonths,
    required bool isFavorite,
  }) {
    double score = 0.0;
    final reasons = <MatchReason>[];

    double distance = double.infinity;
    if (assmat.location != null) {
      distance = haversineKm(
          lat, lon, assmat.location!.latitude, assmat.location!.longitude);
      if (distance <= _maxDistanceDefault) {
        score += _proximityPoints;
        reasons.add(MatchReason.locationProximity);
      }
    }

    if (childAgesMonths.isNotEmpty) {
      final allMatch = childAgesMonths.every((childAge) {
        return childAge >= assmat.ageGroupMin &&
            (assmat.ageGroupMax <= 0 || childAge <= assmat.ageGroupMax);
      });
      if (allMatch) {
        score += _ageCompatibilityPoints;
        reasons.add(MatchReason.ageCompatibility);
      }
    } else {
      score += _unknownChildAgePoints;
    }

    if (assmat.services.isNotEmpty) {
      score += _servicesPoints;
      reasons.add(MatchReason.serviceMatch);
    }

    if (assmat.schedules.isNotEmpty) {
      score += _schedulesPoints;
      reasons.add(MatchReason.scheduleMatch);
    }

    if (assmat.availableSlots > 0) {
      score += _availabilityPoints;
      reasons.add(MatchReason.availabilityMatch);
    }

    if (isFavorite) {
      score += _favoritePoints;
      reasons.add(MatchReason.favorite);
    }

    return _ScoredAssmat(
      assmat: assmat,
      score: score / 100.0,
      reasons: reasons,
      distanceKm: distance.isFinite ? distance : null,
    );
  }

  /// Calcule les meilleures suggestions de match pour une assmat donnée.
  Future<List<MatchSuggestion>> calculateAssmatMatches({
    required String assmatUid,
    required AssmatProfileModel assmatProfile,
  }) async {
    if (assmatProfile.location == null) return [];

    final lat = assmatProfile.location!.latitude;
    final lon = assmatProfile.location!.longitude;

    final parentSnapshot = await _firebase.parentsCollection
        .where('searchPaused', isEqualTo: false)
        .get();

    final parents = parentSnapshot.docs
        .map(ParentProfileModel.fromFirestore)
        .toList();

    if (parents.isEmpty) return [];

    final scored = <_ScoredParent>[];

    for (final parent in parents) {
      if (parent.location == null) continue;

      final distance = haversineKm(
          lat, lon, parent.location!.latitude, parent.location!.longitude);
      if (distance > _maxDistanceDefault) continue;

      final reasons = <MatchReason>[MatchReason.locationProximity];

      if (assmatProfile.services.isNotEmpty) {
        reasons.add(MatchReason.serviceMatch);
      }

      if (assmatProfile.availableSlots > 0) {
        reasons.add(MatchReason.availabilityMatch);
      }

      scored.add(_ScoredParent(
        parent: parent,
        score: reasons.length / _maxAssmatSideReasons,
        reasons: reasons,
        distanceKm: distance,
      ));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final top = scored.take(_maxSuggestions).toList();

    await _replaceSuggestions(
      'assmatUid',
      assmatUid,
      top.map((s) => s.toSuggestion(assmatUid)),
    );

    return top.map((s) => s.toSuggestion(assmatUid)).toList();
  }

  /// Suggestions persistées pour un parent, en temps réel.
  Stream<List<MatchSuggestion>> watchParentMatches(String parentUid) =>
      _watchSuggestionsWhere('parentUid', parentUid);

  /// Suggestions persistées pour une assmat, en temps réel.
  Stream<List<MatchSuggestion>> watchAssmatMatches(String assmatUid) =>
      _watchSuggestionsWhere('assmatUid', assmatUid);

  Stream<List<MatchSuggestion>> _watchSuggestionsWhere(
    String field,
    String uid,
  ) {
    return _suggestions
        .where(field, isEqualTo: uid)
        .orderBy('score', descending: true)
        .limit(_watchLimit)
        .snapshots()
        .map((snap) => snap.docs.map(MatchSuggestion.fromFirestore).toList());
  }

  Future<Set<String>> _loadFavoriteIds(String parentUid) async {
    try {
      final snap = await _firebase.favoritesCollection(parentUid).get();
      return snap.docs.map((d) => d.id).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Remplace, dans un même batch, toutes les suggestions dont [field] vaut
  /// [uid] par [suggestions].
  Future<void> _replaceSuggestions(
    String field,
    String uid,
    Iterable<MatchSuggestion> suggestions,
  ) async {
    final batch = _firebase.firestore.batch();

    final existing = await _suggestions.where(field, isEqualTo: uid).get();

    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    for (final suggestion in suggestions) {
      batch.set(_suggestions.doc(), suggestion.toFirestore());
    }

    await batch.commit();
  }
}
