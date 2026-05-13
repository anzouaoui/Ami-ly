import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle Firestore pour un document `parents/{uid}/children/{childId}`.
///
/// [id] est null pour un enfant créé localement qui n'a pas encore été
/// persisté dans Firestore (ajout en cours d'édition).
class ChildModel {
  const ChildModel({
    this.id,
    required this.firstName,
    this.birthDate,
    this.description = '',
    this.interests = const [],
    required this.createdAt,
    this.updatedAt,
  });

  /// ID du document Firestore. `null` pour un nouvel enfant non encore sauvegardé.
  final String? id;
  final String firstName;
  final DateTime? birthDate;
  final String description;
  final List<String> interests;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Âge calculé à partir de [birthDate]. Retourne '' si non renseigné.
  String get ageLabel {
    if (birthDate == null) return '';
    final now = DateTime.now();
    final totalMonths =
        (now.year - birthDate!.year) * 12 + now.month - birthDate!.month;
    if (totalMonths < 0) return '';
    if (totalMonths == 0) return '< 1 mois';
    if (totalMonths < 24) return '$totalMonths mois';
    final years = totalMonths ~/ 12;
    return '$years an${years > 1 ? 's' : ''}';
  }

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory ChildModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ChildModel(
      id: doc.id,
      firstName: data['firstName'] as String? ?? '',
      birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
      description: data['description'] as String? ?? '',
      interests: List<String>.from(data['interests'] as List? ?? []),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'firstName': firstName,
        if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
        'description': description,
        'interests': interests,
        'createdAt': Timestamp.fromDate(createdAt),
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      };

  // ── Factory helpers ────────────────────────────────────────────────────────

  /// Nouvel enfant vide, sans ID Firestore.
  factory ChildModel.create({required String firstName, DateTime? birthDate}) =>
      ChildModel(
        firstName: firstName,
        birthDate: birthDate,
        createdAt: DateTime.now(),
      );

  ChildModel copyWith({
    String? id,
    String? firstName,
    Object? birthDate = _sentinel, // sentinel pour permettre birthDate = null
    String? description,
    List<String>? interests,
    DateTime? updatedAt,
  }) =>
      ChildModel(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        birthDate: identical(birthDate, _sentinel)
            ? this.birthDate
            : birthDate as DateTime?,
        description: description ?? this.description,
        interests: interests ?? this.interests,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

const _sentinel = Object();
