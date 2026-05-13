import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle Firestore pour le document `parents/{uid}`.
///
/// Créé à l'inscription avec des valeurs vides, complété lors de l'onboarding.
/// Ne dépend d'aucune entité domaine — c'est la couche data pure.
class ParentProfileModel {
  const ParentProfileModel({
    required this.uid,
    required this.createdAt,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.address = '',
    this.familyDescription = '',
    this.searchPaused = false,
    this.subscriptionPlan = 'free',
    this.updatedAt,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;
  final String familyDescription;
  final bool searchPaused;

  /// `'free'` | `'pro'`
  final String subscriptionPlan;

  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory ParentProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ParentProfileModel(
      uid: doc.id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      address: data['address'] as String? ?? '',
      familyDescription: data['familyDescription'] as String? ?? '',
      searchPaused: data['searchPaused'] as bool? ?? false,
      subscriptionPlan: data['subscriptionPlan'] as String? ?? 'free',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'address': address,
        'familyDescription': familyDescription,
        'searchPaused': searchPaused,
        'subscriptionPlan': subscriptionPlan,
        'createdAt': Timestamp.fromDate(createdAt),
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      };

  // ── Factory helpers ────────────────────────────────────────────────────────

  /// Document minimal créé automatiquement lors de l'inscription.
  factory ParentProfileModel.initial({
    required String uid,
    String firstName = '',
    String lastName = '',
  }) =>
      ParentProfileModel(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
      );

  ParentProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? familyDescription,
    bool? searchPaused,
    String? subscriptionPlan,
    DateTime? updatedAt,
  }) =>
      ParentProfileModel(
        uid: uid,
        createdAt: createdAt,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        address: address ?? this.address,
        familyDescription: familyDescription ?? this.familyDescription,
        searchPaused: searchPaused ?? this.searchPaused,
        subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
