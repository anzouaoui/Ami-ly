import 'dart:math' as math;

import '../../../../features/auth/data/models/assmat_profile_model.dart';
import '../../../../features/auth/data/models/parent_profile_model.dart';
import '../../../../core/services/firebase_service.dart';
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
}

/// Résultat intermédiaire pour le scoring côté assmat.
class _ScoredParent {
  const _ScoredParent({
    required this.parent,
    required this.score,
    required this.reasons,
  });

  final ParentProfileModel parent;
  final double score;
  final List<MatchReason> reasons;
}

/// Interface d'accès aux données pour le matching entre parents et assmats.
class MatchingDatasource {
  MatchingDatasource(this._firebase);

  final FirebaseService _firebase;

  static const _maxDistanceDefault = 15.0;

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
      double score = 0.0;
      final reasons = <MatchReason>[];

      double distance = double.infinity;
      if (assmat.location != null) {
        distance = _haversine(
            lat, lon, assmat.location!.latitude, assmat.location!.longitude);
        if (distance <= _maxDistanceDefault) {
          score += 20;
          reasons.add(MatchReason.locationProximity);
        }
      }

      if (childAgesMonths.isNotEmpty) {
        final allMatch = childAgesMonths.every((childAge) {
          return childAge >= assmat.ageGroupMin &&
              (assmat.ageGroupMax <= 0 || childAge <= assmat.ageGroupMax);
        });
        if (allMatch) {
          score += 25;
          reasons.add(MatchReason.ageCompatibility);
        }
      } else {
        score += 12;
      }

      if (assmat.services.isNotEmpty) {
        score += 15;
        reasons.add(MatchReason.serviceMatch);
      }

      if (assmat.schedules.isNotEmpty) {
        score += 10;
        reasons.add(MatchReason.scheduleMatch);
      }

      if (assmat.availableSlots > 0) {
        score += 15;
        reasons.add(MatchReason.availabilityMatch);
      }

      if (favoriteIds.contains(assmat.uid)) {
        score += 15;
        reasons.add(MatchReason.favorite);
      }

      if (reasons.isNotEmpty) {
        scored.add(_ScoredAssmat(
          assmat: assmat,
          score: score / 100.0,
          reasons: reasons,
          distanceKm: distance.isFinite ? distance : null,
        ));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final results = scored.take(20).toList();

    await _persistSuggestions(parentUid, results);

    return results.map((s) => MatchSuggestion(
      assmatUid: s.assmat.uid,
      parentUid: parentUid,
      score: s.score,
      reasons: s.reasons,
      assmatProfile: s.assmat,
      distanceKm: s.distanceKm,
      generatedAt: DateTime.now(),
    )).toList();
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

      final distance = _haversine(
          lat, lon, parent.location!.latitude, parent.location!.longitude);
      if (distance > _maxDistanceDefault) continue;

      final reasons = <MatchReason>[MatchReason.locationProximity];

      if (assmatProfile.services.isNotEmpty) {
        reasons.add(MatchReason.serviceMatch);
      }

      if (assmatProfile.availableSlots > 0) {
        reasons.add(MatchReason.availabilityMatch);
      }

      final score = reasons.length / 3.0;

      scored.add(_ScoredParent(
        parent: parent,
        score: score,
        reasons: reasons,
      ));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final top = scored.take(20).toList();

    await _persistAssmatSuggestions(assmatUid, top, lat, lon);

    return top.map((s) => MatchSuggestion(
      assmatUid: assmatUid,
      parentUid: s.parent.uid,
      score: s.score,
      reasons: s.reasons,
      parentProfile: s.parent.firstName,
      distanceKm: s.parent.location != null
          ? _haversine(
              lat, lon, s.parent.location!.latitude, s.parent.location!.longitude)
          : null,
      generatedAt: DateTime.now(),
    )).toList();
  }

  /// Suggestions persistées pour un parent, en temps réel.
  Stream<List<MatchSuggestion>> watchParentMatches(String parentUid) {
    return _firebase.firestore
        .collection('suggestions')
        .where('parentUid', isEqualTo: parentUid)
        .orderBy('score', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MatchSuggestion.fromFirestore(d)).toList());
  }

  /// Suggestions persistées pour une assmat, en temps réel.
  Stream<List<MatchSuggestion>> watchAssmatMatches(String assmatUid) {
    return _firebase.firestore
        .collection('suggestions')
        .where('assmatUid', isEqualTo: assmatUid)
        .orderBy('score', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MatchSuggestion.fromFirestore(d)).toList());
  }

  Future<Set<String>> _loadFavoriteIds(String parentUid) async {
    try {
      final snap = await _firebase.favoritesCollection(parentUid).get();
      return snap.docs.map((d) => d.id).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _persistSuggestions(
      String parentUid, List<_ScoredAssmat> scored) async {
    final batch = _firebase.firestore.batch();

    final existing = await _firebase.firestore
        .collection('suggestions')
        .where('parentUid', isEqualTo: parentUid)
        .get();

    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    for (final s in scored) {
      final ref = _firebase.firestore.collection('suggestions').doc();
      final suggestion = MatchSuggestion(
        assmatUid: s.assmat.uid,
        parentUid: parentUid,
        score: s.score,
        reasons: s.reasons,
        assmatProfile: s.assmat,
        distanceKm: s.distanceKm,
        generatedAt: DateTime.now(),
      );
      batch.set(ref, suggestion.toFirestore());
    }

    await batch.commit();
  }

  Future<void> _persistAssmatSuggestions(
    String assmatUid,
    List<_ScoredParent> scored,
    double lat,
    double lon,
  ) async {
    final batch = _firebase.firestore.batch();

    final existing = await _firebase.firestore
        .collection('suggestions')
        .where('assmatUid', isEqualTo: assmatUid)
        .get();

    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    for (final s in scored) {
      final ref = _firebase.firestore.collection('suggestions').doc();
      final distanceKm = s.parent.location != null
          ? _haversine(
              lat, lon, s.parent.location!.latitude, s.parent.location!.longitude)
          : null;
      final suggestion = MatchSuggestion(
        assmatUid: assmatUid,
        parentUid: s.parent.uid,
        score: s.score,
        reasons: s.reasons,
        parentProfile: s.parent.firstName,
        distanceKm: distanceKm,
        generatedAt: DateTime.now(),
      );
      batch.set(ref, suggestion.toFirestore());
    }

    await batch.commit();
  }
}
