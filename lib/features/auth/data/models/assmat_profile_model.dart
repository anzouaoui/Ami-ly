import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle Firestore pour le document `assmats/{uid}`.
///
/// Créé à l'inscription avec des valeurs vides, complété lors de l'onboarding.
/// Ne dépend d'aucune entité domaine — c'est la couche data pure.
class AssmatProfileModel {
  const AssmatProfileModel({
    required this.uid,
    required this.createdAt,
    this.firstName = '',
    this.lastName = '',
    this.address = '',
    this.bio = '',
    this.yearsExperience = 0,
    this.maxChildren = 1,
    this.ageGroupMin = 0,
    this.ageGroupMax = 3,
    this.hourlyRate = 0.0,
    this.availableSlots = 0,
    this.isSearchable = true,
    this.subscriptionPlan = 'free',
    this.location,
    this.availableFrom,
    this.updatedAt,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String address;

  /// Présentation libre (biographie).
  final String bio;

  final int yearsExperience;
  final int maxChildren;

  /// Tranche d'âge acceptée (mois).
  final int ageGroupMin;
  final int ageGroupMax;

  final double hourlyRate;

  /// Nombre de places disponibles actuellement.
  final int availableSlots;

  /// `true` → visible dans la recherche parents.
  final bool isSearchable;

  /// `'free'` | `'pro'`
  final String subscriptionPlan;

  /// Coordonnées géographiques de l'adresse (stockées lors de la sélection
  /// via l'autocomplétion BAN). Null si l'adresse n'a jamais été géocodée.
  final GeoPoint? location;

  /// Date à partir de laquelle l'assmat est disponible.
  final DateTime? availableFrom;

  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory AssmatProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AssmatProfileModel(
      uid: doc.id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      address: data['address'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      yearsExperience: data['yearsExperience'] as int? ?? 0,
      maxChildren: data['maxChildren'] as int? ?? 1,
      ageGroupMin: data['ageGroupMin'] as int? ?? 0,
      ageGroupMax: data['ageGroupMax'] as int? ?? 3,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      availableSlots: data['availableSlots'] as int? ?? 0,
      isSearchable: data['isSearchable'] as bool? ?? true,
      subscriptionPlan: data['subscriptionPlan'] as String? ?? 'free',
      location: data['location'] as GeoPoint?,
      availableFrom: (data['availableFrom'] as Timestamp?)?.toDate(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'bio': bio,
        'yearsExperience': yearsExperience,
        'maxChildren': maxChildren,
        'ageGroupMin': ageGroupMin,
        'ageGroupMax': ageGroupMax,
        'hourlyRate': hourlyRate,
        'availableSlots': availableSlots,
        'isSearchable': isSearchable,
        'subscriptionPlan': subscriptionPlan,
        if (location != null) 'location': location,
        if (availableFrom != null)
          'availableFrom': Timestamp.fromDate(availableFrom!),
        'createdAt': Timestamp.fromDate(createdAt),
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      };

  // ── Factory helpers ────────────────────────────────────────────────────────

  /// Document minimal créé automatiquement lors de l'inscription.
  factory AssmatProfileModel.initial({
    required String uid,
    String firstName = '',
    String lastName = '',
  }) =>
      AssmatProfileModel(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
      );

  AssmatProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? address,
    String? bio,
    int? yearsExperience,
    int? maxChildren,
    int? ageGroupMin,
    int? ageGroupMax,
    double? hourlyRate,
    int? availableSlots,
    bool? isSearchable,
    String? subscriptionPlan,
    GeoPoint? location,
    DateTime? availableFrom,
    DateTime? updatedAt,
    bool clearLocation = false,
    bool clearAvailableFrom = false,
  }) =>
      AssmatProfileModel(
        uid: uid,
        createdAt: createdAt,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        address: address ?? this.address,
        bio: bio ?? this.bio,
        yearsExperience: yearsExperience ?? this.yearsExperience,
        maxChildren: maxChildren ?? this.maxChildren,
        ageGroupMin: ageGroupMin ?? this.ageGroupMin,
        ageGroupMax: ageGroupMax ?? this.ageGroupMax,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        availableSlots: availableSlots ?? this.availableSlots,
        isSearchable: isSearchable ?? this.isSearchable,
        subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
        location: clearLocation ? null : (location ?? this.location),
        availableFrom: clearAvailableFrom
            ? null
            : (availableFrom ?? this.availableFrom),
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
