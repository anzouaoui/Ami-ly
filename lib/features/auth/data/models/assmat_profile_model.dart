import 'package:cloud_firestore/cloud_firestore.dart';

/// Type de pièce d'identité fournie par l'assistante maternelle.
enum IdentityDocumentType {
  cni,
  passeport;

  String get label => switch (this) {
        IdentityDocumentType.cni => 'Carte nationale d\'identité',
        IdentityDocumentType.passeport => 'Passeport',
      };

  String get key => name;

  static IdentityDocumentType? fromKey(String? key) {
    if (key == null) return null;
    for (final value in values) {
      if (value.key == key) return value;
    }
    return null;
  }
}

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
    this.city = '',
    this.bio = '',
    this.yearsExperience = 0,
    this.maxChildren = 1,
    this.ageGroupMin = 0,
    this.ageGroupMax = 3,
    this.hourlyRate = 0.0,
    this.availableSlots = 0,
    this.isSearchable = true,
    this.subscriptionPlan = 'free',
    this.services = const [],
    this.schedules = const [],
    this.location,
    this.availableFrom,
    this.updatedAt,
    this.photoUrl,
    // Nouveaux champs
    this.tobacco = 'Non fumeur',
    this.firstAid = 'PSC1 validé',
    this.pet = 'Pas d\'animal',
    this.diplomas = const [],
    this.parcoursProfessionnel = '',
    this.accreditationNumber = '',
    this.accreditationExpiry,
    this.accreditationPhotoUrl,
    this.pmiCode = '',
    this.isAccreditationCertified = true,
    this.specialities = const [],
    this.contactPmiName = '',
    this.contactPmiPhone = '',
    this.contactRpeName = '',
    this.contactRpePhone = '',
    this.contactAntipoisonPhone = '',
    this.contactTiersName = '',
    this.contactTiersPhone = '',
    this.emergencyPhoneCustom = '',
    this.isIdentityVerified = false,
    this.identityVerifiedAt,
    this.homePhotos = const [],
    // Vérification d'identité & conformité
    this.identityDocumentType,
    this.identityDocumentUrl,
    this.identityDocumentUrlBack,
    this.identityDocumentExpiry,
    this.criminalRecordUrl,
    this.criminalRecordUploadedAt,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String address;

  /// Ville uniquement (sans numéro/rue) — c'est ce qui est affiché aux
  /// parents dans la liste de résultats, jamais l'adresse complète.
  final String city;

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

  /// Services proposés (liste de clés identiques aux filtres parent).
  final List<String> services;

  /// Flexibilité horaire (liste de clés identiques aux filtres parent).
  final List<String> schedules;

  /// Coordonnées géographiques de l'adresse (stockées lors de la sélection
  /// via l'autocomplétion BAN). Null si l'adresse n'a jamais été géocodée.
  final GeoPoint? location;

  /// Date à partir de laquelle l'assmat est disponible.
  final DateTime? availableFrom;

  final DateTime createdAt;
  final DateTime? updatedAt;

  /// URL de la photo de profil stockée dans Firebase Storage.
  /// Null si l'assistante n'a pas encore défini de photo.
  final String? photoUrl;

  // Nouveaux champs
  final String tobacco;
  final String firstAid;
  final String pet;
  final List<String> diplomas;
  final String parcoursProfessionnel;
  final String accreditationNumber;
  final DateTime? accreditationExpiry;
  final String? accreditationPhotoUrl;
  final String pmiCode;
  final bool isAccreditationCertified;
  final List<String> specialities;
  final String contactPmiName;
  final String contactPmiPhone;
  final String contactRpeName;
  final String contactRpePhone;
  final String contactAntipoisonPhone;
  final String contactTiersName;
  final String contactTiersPhone;
  final String emergencyPhoneCustom;
  final bool isIdentityVerified;
  final DateTime? identityVerifiedAt;
  final List<String> homePhotos;

  // ── Vérification d'identité & conformité ────────────────────────────────────

  /// Type de pièce d'identité (CNI ou Passeport).
  final IdentityDocumentType? identityDocumentType;

  /// URL de la photo/scan du document d'identité dans Firebase Storage.
  final String? identityDocumentUrl;

  /// URL de la photo/scan du verso de la pièce d'identité dans Firebase
  /// Storage. Requis uniquement pour la CNI (recto + verso).
  final String? identityDocumentUrlBack;

  /// Date d'expiration du document d'identité.
  final DateTime? identityDocumentExpiry;

  /// URL de la photo/scan du casier judiciaire (bulletin n°3) dans Firebase Storage.
  // TODO(Seb): Confirmer si le casier judiciaire doit être conservé ou supprimé après vérification.
  final String? criminalRecordUrl;

  /// Date de téléversement du casier judiciaire.
  final DateTime? criminalRecordUploadedAt;

  /// Retourne `true` si le profil est entièrement vérifié :
  /// - Identité vérifiée (`isIdentityVerified`)
  /// - Document d'identité non expiré (recto + verso pour une CNI)
  /// - Agrément PMI valide (date d'expiration dans le futur)
  /// - Casier judiciaire fourni
  bool get isFullyVerified {
    final identityDocumentProvided = identityDocumentUrl != null &&
        identityDocumentUrl!.isNotEmpty;
    final identityDocValid = identityDocumentExpiry != null &&
        identityDocumentExpiry!.isAfter(DateTime.now());
    final accreditationValid = accreditationExpiry != null &&
        accreditationExpiry!.isAfter(DateTime.now());
    final criminalRecordProvided =
        criminalRecordUrl != null && criminalRecordUrl!.isNotEmpty;
    final cniBackProvided = identityDocumentType != IdentityDocumentType.cni ||
        (identityDocumentUrlBack != null &&
            identityDocumentUrlBack!.isNotEmpty);
    return isIdentityVerified &&
        identityDocumentProvided &&
        identityDocValid &&
        accreditationValid &&
        criminalRecordProvided &&
        cniBackProvided;
  }

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
      city: data['city'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      yearsExperience: data['yearsExperience'] as int? ?? 0,
      maxChildren: data['maxChildren'] as int? ?? 1,
      ageGroupMin: data['ageGroupMin'] as int? ?? 0,
      ageGroupMax: data['ageGroupMax'] as int? ?? 3,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      availableSlots: data['availableSlots'] as int? ?? 0,
      isSearchable: data['isSearchable'] as bool? ?? true,
      subscriptionPlan: data['subscriptionPlan'] as String? ?? 'free',
      services: List<String>.from(data['services'] as List? ?? []),
      schedules: List<String>.from(data['schedules'] as List? ?? []),
      location: data['location'] as GeoPoint?,
      availableFrom: (data['availableFrom'] as Timestamp?)?.toDate(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      photoUrl: data['photoUrl'] as String?,
      
      // Nouveaux champs
      tobacco: data['tobacco'] as String? ?? 'Non fumeur',
      firstAid: data['firstAid'] as String? ?? 'PSC1 validé',
      pet: data['pet'] as String? ?? 'Pas d\'animal',
      diplomas: List<String>.from(data['diplomas'] as List? ?? []),
      parcoursProfessionnel: data['parcoursProfessionnel'] as String? ?? '',
      accreditationNumber: data['accreditationNumber'] as String? ?? '',
      accreditationExpiry: (data['accreditationExpiry'] as Timestamp?)?.toDate(),
      accreditationPhotoUrl: data['accreditationPhotoUrl'] as String?,
      pmiCode: data['pmiCode'] as String? ?? '',
      isAccreditationCertified: data['isAccreditationCertified'] as bool? ?? true,
      specialities: List<String>.from(data['specialities'] as List? ?? []),
      contactPmiName: data['contactPmiName'] as String? ?? '',
      contactPmiPhone: data['contactPmiPhone'] as String? ?? '',
      contactRpeName: data['contactRpeName'] as String? ?? '',
      contactRpePhone: data['contactRpePhone'] as String? ?? '',
      contactAntipoisonPhone: data['contactAntipoisonPhone'] as String? ?? '',
      contactTiersName: data['contactTiersName'] as String? ?? '',
      contactTiersPhone: data['contactTiersPhone'] as String? ?? '',
      emergencyPhoneCustom: data['emergencyPhoneCustom'] as String? ?? '',
      isIdentityVerified: data['isIdentityVerified'] as bool? ?? false,
      identityVerifiedAt: (data['identityVerifiedAt'] as Timestamp?)?.toDate(),
      homePhotos: List<String>.from(data['homePhotos'] as List? ?? []),
      // Vérification d'identité & conformité
      identityDocumentType:
          IdentityDocumentType.fromKey(data['identityDocumentType'] as String?),
      identityDocumentUrl: data['identityDocumentUrl'] as String?,
      identityDocumentUrlBack: data['identityDocumentUrlBack'] as String?,
      identityDocumentExpiry:
          (data['identityDocumentExpiry'] as Timestamp?)?.toDate(),
      criminalRecordUrl: data['criminalRecordUrl'] as String?,
      criminalRecordUploadedAt:
          (data['criminalRecordUploadedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'city': city,
        'bio': bio,
        'yearsExperience': yearsExperience,
        'maxChildren': maxChildren,
        'ageGroupMin': ageGroupMin,
        'ageGroupMax': ageGroupMax,
        'hourlyRate': hourlyRate,
        'availableSlots': availableSlots,
        'isSearchable': isSearchable,
        'subscriptionPlan': subscriptionPlan,
        'services': services,
        'schedules': schedules,
        if (location != null) 'location': location,
        if (availableFrom != null)
          'availableFrom': Timestamp.fromDate(availableFrom!),
        'createdAt': Timestamp.fromDate(createdAt),
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
        if (photoUrl != null) 'photoUrl': photoUrl,
        
        // Nouveaux champs
        'tobacco': tobacco,
        'firstAid': firstAid,
        'pet': pet,
        'diplomas': diplomas,
        'parcoursProfessionnel': parcoursProfessionnel,
        'accreditationNumber': accreditationNumber,
        if (accreditationExpiry != null)
          'accreditationExpiry': Timestamp.fromDate(accreditationExpiry!),
        if (accreditationPhotoUrl != null)
          'accreditationPhotoUrl': accreditationPhotoUrl,
        'pmiCode': pmiCode,
        'isAccreditationCertified': isAccreditationCertified,
        'specialities': specialities,
        'contactPmiName': contactPmiName,
        'contactPmiPhone': contactPmiPhone,
        'contactRpeName': contactRpeName,
        'contactRpePhone': contactRpePhone,
        'contactAntipoisonPhone': contactAntipoisonPhone,
        'contactTiersName': contactTiersName,
        'contactTiersPhone': contactTiersPhone,
        'emergencyPhoneCustom': emergencyPhoneCustom,
        'isIdentityVerified': isIdentityVerified,
        if (identityVerifiedAt != null)
          'identityVerifiedAt': Timestamp.fromDate(identityVerifiedAt!),
        'homePhotos': homePhotos,
        // Vérification d'identité & conformité
        if (identityDocumentType != null)
          'identityDocumentType': identityDocumentType!.key,
        if (identityDocumentUrl != null)
          'identityDocumentUrl': identityDocumentUrl,
        if (identityDocumentUrlBack != null)
          'identityDocumentUrlBack': identityDocumentUrlBack,
        if (identityDocumentExpiry != null)
          'identityDocumentExpiry':
              Timestamp.fromDate(identityDocumentExpiry!),
        if (criminalRecordUrl != null)
          'criminalRecordUrl': criminalRecordUrl,
        if (criminalRecordUploadedAt != null)
          'criminalRecordUploadedAt':
              Timestamp.fromDate(criminalRecordUploadedAt!),
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
    String? city,
    String? bio,
    int? yearsExperience,
    int? maxChildren,
    int? ageGroupMin,
    int? ageGroupMax,
    double? hourlyRate,
    int? availableSlots,
    bool? isSearchable,
    String? subscriptionPlan,
    List<String>? services,
    List<String>? schedules,
    GeoPoint? location,
    DateTime? availableFrom,
    DateTime? updatedAt,
    bool clearLocation = false,
    bool clearAvailableFrom = false,
    String? photoUrl,
    bool clearPhotoUrl = false,
    
    // Nouveaux champs
    String? tobacco,
    String? firstAid,
    String? pet,
    List<String>? diplomas,
    String? parcoursProfessionnel,
    String? accreditationNumber,
    DateTime? accreditationExpiry,
    bool clearAccreditationExpiry = false,
    String? accreditationPhotoUrl,
    bool clearAccreditationPhotoUrl = false,
    String? pmiCode,
    bool? isAccreditationCertified,
    List<String>? specialities,
    String? contactPmiName,
    String? contactPmiPhone,
    String? contactRpeName,
    String? contactRpePhone,
    String? contactAntipoisonPhone,
    String? contactTiersName,
    String? contactTiersPhone,
    String? emergencyPhoneCustom,
    bool? isIdentityVerified,
    DateTime? identityVerifiedAt,
    bool clearIdentityVerifiedAt = false,
    List<String>? homePhotos,
    // Vérification d'identité & conformité
    IdentityDocumentType? identityDocumentType,
    bool clearIdentityDocumentType = false,
    String? identityDocumentUrl,
    bool clearIdentityDocumentUrl = false,
    String? identityDocumentUrlBack,
    bool clearIdentityDocumentUrlBack = false,
    DateTime? identityDocumentExpiry,
    bool clearIdentityDocumentExpiry = false,
    String? criminalRecordUrl,
    bool clearCriminalRecordUrl = false,
    DateTime? criminalRecordUploadedAt,
    bool clearCriminalRecordUploadedAt = false,
  }) =>
      AssmatProfileModel(
        uid: uid,
        createdAt: createdAt,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        address: address ?? this.address,
        city: city ?? this.city,
        bio: bio ?? this.bio,
        yearsExperience: yearsExperience ?? this.yearsExperience,
        maxChildren: maxChildren ?? this.maxChildren,
        ageGroupMin: ageGroupMin ?? this.ageGroupMin,
        ageGroupMax: ageGroupMax ?? this.ageGroupMax,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        availableSlots: availableSlots ?? this.availableSlots,
        isSearchable: isSearchable ?? this.isSearchable,
        subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
        services: services ?? this.services,
        schedules: schedules ?? this.schedules,
        location: clearLocation ? null : (location ?? this.location),
        availableFrom: clearAvailableFrom
            ? null
            : (availableFrom ?? this.availableFrom),
        updatedAt: updatedAt ?? this.updatedAt,
        photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
        
        // Nouveaux champs
        tobacco: tobacco ?? this.tobacco,
        firstAid: firstAid ?? this.firstAid,
        pet: pet ?? this.pet,
        diplomas: diplomas ?? this.diplomas,
        parcoursProfessionnel: parcoursProfessionnel ?? this.parcoursProfessionnel,
        accreditationNumber: accreditationNumber ?? this.accreditationNumber,
        accreditationExpiry: clearAccreditationExpiry
            ? null
            : (accreditationExpiry ?? this.accreditationExpiry),
        accreditationPhotoUrl: clearAccreditationPhotoUrl
            ? null
            : (accreditationPhotoUrl ?? this.accreditationPhotoUrl),
        pmiCode: pmiCode ?? this.pmiCode,
        isAccreditationCertified: isAccreditationCertified ?? this.isAccreditationCertified,
        specialities: specialities ?? this.specialities,
        contactPmiName: contactPmiName ?? this.contactPmiName,
        contactPmiPhone: contactPmiPhone ?? this.contactPmiPhone,
        contactRpeName: contactRpeName ?? this.contactRpeName,
        contactRpePhone: contactRpePhone ?? this.contactRpePhone,
        contactAntipoisonPhone: contactAntipoisonPhone ?? this.contactAntipoisonPhone,
        contactTiersName: contactTiersName ?? this.contactTiersName,
        contactTiersPhone: contactTiersPhone ?? this.contactTiersPhone,
        emergencyPhoneCustom: emergencyPhoneCustom ?? this.emergencyPhoneCustom,
        isIdentityVerified: isIdentityVerified ?? this.isIdentityVerified,
        identityVerifiedAt: clearIdentityVerifiedAt
            ? null
            : (identityVerifiedAt ?? this.identityVerifiedAt),
        homePhotos: homePhotos ?? this.homePhotos,
        // Vérification d'identité & conformité
        identityDocumentType: clearIdentityDocumentType
            ? null
            : (identityDocumentType ?? this.identityDocumentType),
        identityDocumentUrl: clearIdentityDocumentUrl
            ? null
            : (identityDocumentUrl ?? this.identityDocumentUrl),
        identityDocumentUrlBack: clearIdentityDocumentUrlBack
            ? null
            : (identityDocumentUrlBack ?? this.identityDocumentUrlBack),
        identityDocumentExpiry: clearIdentityDocumentExpiry
            ? null
            : (identityDocumentExpiry ?? this.identityDocumentExpiry),
        criminalRecordUrl: clearCriminalRecordUrl
            ? null
            : (criminalRecordUrl ?? this.criminalRecordUrl),
        criminalRecordUploadedAt: clearCriminalRecordUploadedAt
            ? null
            : (criminalRecordUploadedAt ?? this.criminalRecordUploadedAt),
      );
}
