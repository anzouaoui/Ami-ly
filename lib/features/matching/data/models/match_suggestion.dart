import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../features/auth/data/models/assmat_profile_model.dart';
import '../../../../features/parent/data/models/child_model.dart';
import 'match_reason.dart';

/// Suggestion de matching entre un parent et une assistante maternelle.
class MatchSuggestion {
  const MatchSuggestion({
    required this.assmatUid,
    required this.parentUid,
    required this.score,
    required this.reasons,
    this.assmatProfile,
    this.parentProfile,
    this.children,
    this.distanceKm,
    this.generatedAt,
  });

  final String assmatUid;
  final String parentUid;
  final double score;

  /// Raisons du match (ordonnées par pertinence).
  final List<MatchReason> reasons;

  /// Profil de l'assmat (peut être null si pas encore chargé).
  final AssmatProfileModel? assmatProfile;

  /// Nom du parent (peut être null si pas encore chargé).
  final String? parentProfile;

  /// Enfants du parent.
  final List<ChildModel>? children;

  /// Distance en km entre parent et assmat.
  final double? distanceKm;

  /// Date de génération de la suggestion.
  final DateTime? generatedAt;

  factory MatchSuggestion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    final reasonsRaw = List<String>.from(d['reasons'] as List? ?? []);
    return MatchSuggestion(
      assmatUid: d['assmatUid'] as String? ?? '',
      parentUid: d['parentUid'] as String? ?? '',
      score: (d['score'] as num?)?.toDouble() ?? 0.0,
      reasons: reasonsRaw
          .map((r) => MatchReason.values.firstWhere(
                (e) => e.name == r,
                orElse: () => MatchReason.locationProximity,
              ))
          .toList(),
      distanceKm: (d['distanceKm'] as num?)?.toDouble(),
      generatedAt: (d['generatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'assmatUid': assmatUid,
        'parentUid': parentUid,
        'score': score,
        'reasons': reasons.map((r) => r.name).toList(),
        if (distanceKm != null) 'distanceKm': distanceKm,
        'generatedAt': generatedAt ?? FieldValue.serverTimestamp(),
      };

  MatchSuggestion copyWith({
    String? assmatUid,
    String? parentUid,
    double? score,
    List<MatchReason>? reasons,
    AssmatProfileModel? assmatProfile,
    String? parentProfile,
    List<ChildModel>? children,
    double? distanceKm,
    DateTime? generatedAt,
    bool clearAssmatProfile = false,
    bool clearParentProfile = false,
    bool clearChildren = false,
  }) =>
      MatchSuggestion(
        assmatUid: assmatUid ?? this.assmatUid,
        parentUid: parentUid ?? this.parentUid,
        score: score ?? this.score,
        reasons: reasons ?? this.reasons,
        assmatProfile:
            clearAssmatProfile ? null : (assmatProfile ?? this.assmatProfile),
        parentProfile:
            clearParentProfile ? null : (parentProfile ?? this.parentProfile),
        children: clearChildren ? null : (children ?? this.children),
        distanceKm: distanceKm ?? this.distanceKm,
        generatedAt: generatedAt ?? this.generatedAt,
      );
}
