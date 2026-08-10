import 'package:cloud_firestore/cloud_firestore.dart';

/// Statut de vérification du profil assmat.
///
/// - [pending] : délai en cours, aucune relance envoyée.
/// - [reminded15] : relance envoyée à J-15.
/// - [reminded2] : relance envoyée à J-2.
/// - [expired] : délai dépassé → profil retiré de la recherche.
/// - [verified] : profil entièrement vérifié → délai levé.
enum VerificationStatus {
  pending,
  reminded15,
  reminded2,
  expired,
  verified,
}

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
  /// Délai laissé à l'assmat pour faire vérifier son profil à partir de
  /// son inscription. Des relances sont envoyées à J-15 et J-2.
  static const verificationDeadlineDuration = Duration(days: 30);
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
    this.verificationDeadline,
    this.verificationStatus = VerificationStatus.pending,
    this.reminded15At,
    this.reminded2At,
    this.expiredAt,
    // Vérification d'identité & conformité
    this.identityDocumentType,
    this.identityDocumentUrl,
    this.identityDocumentUrlBack,
    this.identityDocumentExpiry,
    this.identityDocumentNumber,
    this.identityDocumentFirstName,
    this.identityDocumentLastName,
    this.identityDocumentBirthDate,
    this.criminalRecordUrl,
    this.criminalRecordUploadedAt,
    // Contrôle de conformité de l'agrément
    this.accreditationDocExtractedNumber,
    this.accreditationDocExtractedExpiry,
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

  /// Date limite de vérification du profil (inscription + 30 jours).
  final DateTime? verificationDeadline;

  /// Statut courant du délai de vérification.
  final VerificationStatus verificationStatus;

  /// Horodatages des relances (utilisés pour ne notifier qu'une seule fois).
  final DateTime? reminded15At;
  final DateTime? reminded2At;
  final DateTime? expiredAt;

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

  // ── Métadonnées extraites par le scan OCR de la pièce d'identité ───────────

  /// Numéro de document lu par l'OCR (zone MRZ ou libellé « N° : … »).
  final String? identityDocumentNumber;

  /// Prénom(s) lu(s) par l'OCR (pré-remplis, corrigibles à la main).
  final String? identityDocumentFirstName;

  /// Nom de famille lu par l'OCR.
  final String? identityDocumentLastName;

  /// Date de naissance lue par l'OCR.
  final DateTime? identityDocumentBirthDate;

  /// URL de la photo/scan du casier judiciaire (bulletin n°3) dans Firebase Storage.
  // TODO(Seb): Confirmer si le casier judiciaire doit être conservé ou supprimé après vérification.
  final String? criminalRecordUrl;

  /// Date de téléversement du casier judiciaire.
  final DateTime? criminalRecordUploadedAt;

  // ── Contrôle de conformité de l'agrément ────────────────────────────────────

  /// Numéro d'agrément lu sur le document/photo (OCR). Utilisé pour vérifier
  /// qu'il correspond au numéro saisi.
  final String? accreditationDocExtractedNumber;

  /// Fin de période de validité lue sur le document/photo (OCR). Utilisée
  /// pour vérifier qu'elle correspond à la date d'expiration saisie.
  final DateTime? accreditationDocExtractedExpiry;

  /// `true` si le numéro d'agrément saisi correspond au numéro lu sur le
  /// document d'agrément (mêmes chiffres, indépendamment de la mise en forme).
  bool get isAccreditationNumberMatching {
    final extracted = accreditationDocExtractedNumber;
    if (extracted == null || extracted.isEmpty) return false;
    final entered = accreditationNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final read = extracted.replaceAll(RegExp(r'[^0-9]'), '');
    return entered.isNotEmpty && entered == read;
  }

  /// `true` si la date d'expiration saisie correspond à la fin de période de
  /// validité lue sur le document (même mois / même année).
  bool get isAccreditationExpiryMatching {
    final extracted = accreditationDocExtractedExpiry;
    if (accreditationExpiry == null || extracted == null) return false;
    return accreditationExpiry!.year == extracted.year &&
        accreditationExpiry!.month == extracted.month;
  }

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
      verificationDeadline:
          (data['verificationDeadline'] as Timestamp?)?.toDate(),
      verificationStatus: VerificationStatus.values.firstWhere(
        (s) => s.name == data['verificationStatus'],
        orElse: () => VerificationStatus.pending,
      ),
      reminded15At: (data['reminded15At'] as Timestamp?)?.toDate(),
      reminded2At: (data['reminded2At'] as Timestamp?)?.toDate(),
      expiredAt: (data['expiredAt'] as Timestamp?)?.toDate(),
      // Vérification d'identité & conformité
      identityDocumentType:
          IdentityDocumentType.fromKey(data['identityDocumentType'] as String?),
      identityDocumentUrl: data['identityDocumentUrl'] as String?,
      identityDocumentUrlBack: data['identityDocumentUrlBack'] as String?,
      identityDocumentExpiry:
          (data['identityDocumentExpiry'] as Timestamp?)?.toDate(),
      // Métadonnées extraites par l'OCR
      identityDocumentNumber: data['identityDocumentNumber'] as String?,
      identityDocumentFirstName: data['identityDocumentFirstName'] as String?,
      identityDocumentLastName: data['identityDocumentLastName'] as String?,
      identityDocumentBirthDate:
          (data['identityDocumentBirthDate'] as Timestamp?)?.toDate(),
      criminalRecordUrl: data['criminalRecordUrl'] as String?,
      criminalRecordUploadedAt:
          (data['criminalRecordUploadedAt'] as Timestamp?)?.toDate(),
      // Contrôle de conformité de l'agrément
      accreditationDocExtractedNumber:
          data['accreditationDocExtractedNumber'] as String?,
      accreditationDocExtractedExpiry:
          (data['accreditationDocExtractedExpiry'] as Timestamp?)?.toDate(),
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
        if (verificationDeadline != null)
          'verificationDeadline':
              Timestamp.fromDate(verificationDeadline!),
        'verificationStatus': verificationStatus.name,
        if (reminded15At != null)
          'reminded15At': Timestamp.fromDate(reminded15At!),
        if (reminded2At != null)
          'reminded2At': Timestamp.fromDate(reminded2At!),
        if (expiredAt != null) 'expiredAt': Timestamp.fromDate(expiredAt!),
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
        // Métadonnées extraites par l'OCR
        if (identityDocumentNumber != null)
          'identityDocumentNumber': identityDocumentNumber,
        if (identityDocumentFirstName != null)
          'identityDocumentFirstName': identityDocumentFirstName,
        if (identityDocumentLastName != null)
          'identityDocumentLastName': identityDocumentLastName,
        if (identityDocumentBirthDate != null)
          'identityDocumentBirthDate':
              Timestamp.fromDate(identityDocumentBirthDate!),
        if (criminalRecordUrl != null)
          'criminalRecordUrl': criminalRecordUrl,
        if (criminalRecordUploadedAt != null)
          'criminalRecordUploadedAt':
              Timestamp.fromDate(criminalRecordUploadedAt!),
        // Contrôle de conformité de l'agrément
        if (accreditationDocExtractedNumber != null)
          'accreditationDocExtractedNumber': accreditationDocExtractedNumber,
        if (accreditationDocExtractedExpiry != null)
          'accreditationDocExtractedExpiry':
              Timestamp.fromDate(accreditationDocExtractedExpiry!),
      };

  // ── Factory helpers ────────────────────────────────────────────────────────

  /// Document minimal créé automatiquement lors de l'inscription.
  ///
  /// Positionne aussi `verificationDeadline = createdAt + 30 jours` : c'est
  /// le point de départ du délai de vérification du profil.
  factory AssmatProfileModel.initial({
    required String uid,
    String firstName = '',
    String lastName = '',
  }) {
    final createdAt = DateTime.now();
    return AssmatProfileModel(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      createdAt: createdAt,
      verificationDeadline: createdAt.add(verificationDeadlineDuration),
    );
  }

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
    DateTime? verificationDeadline,
    bool clearVerificationDeadline = false,
    VerificationStatus? verificationStatus,
    DateTime? reminded15At,
    bool clearReminded15At = false,
    DateTime? reminded2At,
    bool clearReminded2At = false,
    DateTime? expiredAt,
    bool clearExpiredAt = false,
    // Vérification d'identité & conformité
    IdentityDocumentType? identityDocumentType,
    bool clearIdentityDocumentType = false,
    String? identityDocumentUrl,
    bool clearIdentityDocumentUrl = false,
    String? identityDocumentUrlBack,
    bool clearIdentityDocumentUrlBack = false,
    DateTime? identityDocumentExpiry,
    bool clearIdentityDocumentExpiry = false,
    String? identityDocumentNumber,
    bool clearIdentityDocumentNumber = false,
    String? identityDocumentFirstName,
    bool clearIdentityDocumentFirstName = false,
    String? identityDocumentLastName,
    bool clearIdentityDocumentLastName = false,
    DateTime? identityDocumentBirthDate,
    bool clearIdentityDocumentBirthDate = false,
    String? criminalRecordUrl,
    bool clearCriminalRecordUrl = false,
    DateTime? criminalRecordUploadedAt,
    bool clearCriminalRecordUploadedAt = false,
    // Contrôle de conformité de l'agrément
    String? accreditationDocExtractedNumber,
    bool clearAccreditationDocExtractedNumber = false,
    DateTime? accreditationDocExtractedExpiry,
    bool clearAccreditationDocExtractedExpiry = false,
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
        verificationDeadline: clearVerificationDeadline
            ? null
            : (verificationDeadline ?? this.verificationDeadline),
        verificationStatus: verificationStatus ?? this.verificationStatus,
        reminded15At:
            clearReminded15At ? null : (reminded15At ?? this.reminded15At),
        reminded2At: clearReminded2At ? null : (reminded2At ?? this.reminded2At),
        expiredAt: clearExpiredAt ? null : (expiredAt ?? this.expiredAt),
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
        identityDocumentNumber: clearIdentityDocumentNumber
            ? null
            : (identityDocumentNumber ?? this.identityDocumentNumber),
        identityDocumentFirstName: clearIdentityDocumentFirstName
            ? null
            : (identityDocumentFirstName ?? this.identityDocumentFirstName),
        identityDocumentLastName: clearIdentityDocumentLastName
            ? null
            : (identityDocumentLastName ?? this.identityDocumentLastName),
        identityDocumentBirthDate: clearIdentityDocumentBirthDate
            ? null
            : (identityDocumentBirthDate ?? this.identityDocumentBirthDate),
        criminalRecordUrl: clearCriminalRecordUrl
            ? null
            : (criminalRecordUrl ?? this.criminalRecordUrl),
        criminalRecordUploadedAt: clearCriminalRecordUploadedAt
            ? null
            : (criminalRecordUploadedAt ?? this.criminalRecordUploadedAt),
        // Contrôle de conformité de l'agrément
        accreditationDocExtractedNumber: clearAccreditationDocExtractedNumber
            ? null
            : (accreditationDocExtractedNumber ??
                this.accreditationDocExtractedNumber),
        accreditationDocExtractedExpiry: clearAccreditationDocExtractedExpiry
            ? null
            : (accreditationDocExtractedExpiry ??
                this.accreditationDocExtractedExpiry),
      );

  // ── Vérification du profil ───────────────────────────────────────────────────

  /// Calcule le prochain [VerificationStatus] à partir de la date limite et
  /// du statut courant.
  ///
  /// Règles (délai de 30 jours) :
  /// - déjà `verified` ou `expired` → état terminal, inchangé ;
  /// - deadline dépassée → `expired` ;
  /// - J-2 (deadline − now ≤ 2 jours) → `reminded2`, uniquement depuis
  ///   `pending` ou `reminded15` ;
  /// - J-15 (deadline − now ≤ 15 jours) → `reminded15`, uniquement depuis
  ///   `pending` ;
  /// - sinon → statut inchangé.
  ///
  /// Fonction pure : testable unitairement sans Firestore.
  static VerificationStatus computeVerificationStatus({
    required DateTime deadline,
    required DateTime now,
    required VerificationStatus current,
  }) {
    if (current == VerificationStatus.verified ||
        current == VerificationStatus.expired) {
      return current;
    }

    if (!now.isBefore(deadline)) {
      return VerificationStatus.expired;
    }

    final daysLeft = deadline.difference(now).inDays;

    if (daysLeft <= 2) {
      if (current == VerificationStatus.pending ||
          current == VerificationStatus.reminded15) {
        return VerificationStatus.reminded2;
      }
      return current;
    }

    if (daysLeft <= 15 && current == VerificationStatus.pending) {
      return VerificationStatus.reminded15;
    }

    return current;
  }
}
