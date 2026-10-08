import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../shared/models/user_role.dart';
import '../models/assmat_profile_model.dart';
import '../models/parent_profile_model.dart';
import '../models/user_model.dart';

/// Couche la plus basse : tape directement sur Firebase Auth + Firestore.
/// Ne connaît pas les notions de `Failure` ni d'`AppUser` (entité domaine).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._firebase);
  final FirebaseService _firebase;

  static const _iosGoogleClientId =
      '483499244920-jn0lbob4tq6chlnevr7kdog48ak4ae9g.apps.googleusercontent.com';

  final _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? _iosGoogleClientId : null,
  );

  Stream<User?> authStateChanges() => _firebase.authStateChanges;

  Future<UserModel> fetchUserProfile(String uid) async {
    try {
      final doc = await _firebase.userDoc(uid).get();
      if (!doc.exists) {
        throw FirestoreException(
          'Profil utilisateur introuvable pour $uid.',
        );
      }
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur Firestore.');
    }
  }

  /// Stream en temps réel du profil utilisateur (utile pour refléter
  /// instantanément un changement de `isPro` depuis RevenueCat ou un
  /// update de profil).
  ///
  /// Émet `null` si le document n'existe pas encore (ex : inscription en cours,
  /// doc Firestore pas encore écrit). L'appelant filtre le null.
  Stream<UserModel?> watchUserProfile(String uid) {
    return _firebase.userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebase.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid == null) {
        throw AuthException('Connexion échouée : aucun utilisateur retourné.');
      }
      return await fetchUserProfile(uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required UserRole role,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final cred = await _firebase.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw AuthException('Inscription échouée.');
      }

      final fullName = [firstName ?? '', lastName ?? '']
          .where((s) => s.isNotEmpty)
          .join(' ');

      if (fullName.isNotEmpty) {
        await user.updateDisplayName(fullName);
      }

      final now = DateTime.now();

      // 1. Document `users/{uid}` — source de vérité du rôle.
      final model = UserModel(
        uid: user.uid,
        email: email,
        role: role,
        createdAt: now,
        displayName: fullName.isNotEmpty ? fullName : null,
      );
      await _firebase.userDoc(user.uid).set(model.toFirestore());

      // 2. Sous-document profil étendu selon le rôle.
      await _createRoleProfile(
        uid: user.uid,
        role: role,
        firstName: firstName ?? '',
        lastName: lastName ?? '',
      );

      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur lors de la création du profil.');
    }
  }

  Stream<ParentProfileModel?> watchParentProfile(String uid) {
    return _firebase.parentDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ParentProfileModel.fromFirestore(doc);
    });
  }

  Future<void> updateParentProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
    required String familyDescription,
    required bool searchPaused,
    GeoPoint? location,
    bool clearLocation = false,
  }) async {
    try {
      await _firebase.parentDoc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'address': address,
        'familyDescription': familyDescription,
        'searchPaused': searchPaused,
        ..._clearableField('location', location, clear: clearLocation),
        'updatedAt': DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur lors de la mise à jour du profil.');
    }
  }

  /// Upload une image de profil parent dans Firebase Storage et retourne l'URL
  /// de téléchargement publique.
  Future<String> uploadParentPhoto(String uid, File imageFile) async {
    return _uploadFile(
      path: 'parents/$uid/profile_photo.jpg',
      file: imageFile,
      contentType: 'image/jpeg',
      errorMessage: 'Erreur lors de l\'upload de la photo.',
    );
  }

  /// Met à jour le champ `photoUrl` dans Firestore.
  Future<void> updateParentPhotoUrl(String uid, String photoUrl) async {
    try {
      await _firebase.parentDoc(uid).update({
        'photoUrl': photoUrl,
        'updatedAt': DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur lors de la mise à jour de la photo.');
    }
  }

  Stream<AssmatProfileModel?> watchAssmatProfile(String uid) {
    return _firebase.assmatDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AssmatProfileModel.fromFirestore(doc);
    });
  }

  /// Stream temps réel de toutes les assmats ayant `isSearchable == true`.
  /// Utilisé par la page de recherche parent.
  Stream<List<AssmatProfileModel>> watchSearchableAssmats() {
    return _firebase.assmatsCollection
        .where('isSearchable', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(AssmatProfileModel.fromFirestore).toList());
  }

  Future<void> updateAssmatProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String address,
    required String city,
    required String bio,
    required bool isSearchable,
    required int maxChildren,
    required int availableSlots,
    required List<String> services,
    required List<String> schedules,
    GeoPoint? location,
    bool clearLocation = false,
    DateTime? availableFrom,
    bool clearAvailableFrom = false,
    // Nouveaux champs
    required String tobacco,
    required String firstAid,
    required String pet,
    required List<String> diplomas,
    required String parcoursProfessionnel,
    required String accreditationNumber,
    DateTime? accreditationExpiry,
    bool clearAccreditationExpiry = false,
    String? accreditationPhotoUrl,
    bool clearAccreditationPhotoUrl = false,
    required String pmiCode,
    required bool isAccreditationCertified,
    required List<String> specialities,
    required String contactPmiName,
    required String contactPmiPhone,
    required String contactRpeName,
    required String contactRpePhone,
    required String contactAntipoisonPhone,
    required String contactTiersName,
    required String contactTiersPhone,
    required String emergencyPhoneCustom,
    required List<String> homePhotos,
    String? verificationStatus,
    // Vérification d'identité & conformité
    String? identityDocumentType,
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
    bool? isIdentityVerified,
    DateTime? identityVerifiedAt,
    bool clearIdentityVerifiedAt = false,
  }) async {
    try {
      await _firebase.assmatDoc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'city': city,
        'bio': bio,
        'isSearchable': isSearchable,
        'maxChildren': maxChildren,
        'availableSlots': availableSlots,
        'services': services,
        'schedules': schedules,
        ..._clearableField('location', location, clear: clearLocation),
        ..._clearableField(
          'availableFrom',
          _timestampOrNull(availableFrom),
          clear: clearAvailableFrom,
        ),
        'updatedAt': DateTime.now(),
        // Nouveaux champs
        'tobacco': tobacco,
        'firstAid': firstAid,
        'pet': pet,
        'diplomas': diplomas,
        'parcoursProfessionnel': parcoursProfessionnel,
        'accreditationNumber': accreditationNumber,
        ..._clearableField(
          'accreditationExpiry',
          _timestampOrNull(accreditationExpiry),
          clear: clearAccreditationExpiry,
        ),
        ..._clearableField(
          'accreditationPhotoUrl',
          accreditationPhotoUrl,
          clear: clearAccreditationPhotoUrl,
        ),
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
        'homePhotos': homePhotos,
        if (verificationStatus != null)
          'verificationStatus': verificationStatus,
        // Vérification d'identité & conformité
        if (identityDocumentType != null)
          'identityDocumentType': identityDocumentType,
        ..._clearableField(
          'identityDocumentUrl',
          identityDocumentUrl,
          clear: clearIdentityDocumentUrl,
        ),
        ..._clearableField(
          'identityDocumentUrlBack',
          identityDocumentUrlBack,
          clear: clearIdentityDocumentUrlBack,
        ),
        ..._clearableField(
          'identityDocumentExpiry',
          _timestampOrNull(identityDocumentExpiry),
          clear: clearIdentityDocumentExpiry,
        ),
        ..._clearableField(
          'criminalRecordUrl',
          criminalRecordUrl,
          clear: clearCriminalRecordUrl,
        ),
        ..._clearableField(
          'criminalRecordUploadedAt',
          _timestampOrNull(criminalRecordUploadedAt),
          clear: clearCriminalRecordUploadedAt,
        ),
        if (isIdentityVerified != null)
          'isIdentityVerified': isIdentityVerified,
        ..._clearableField(
          'identityVerifiedAt',
          _timestampOrNull(identityVerifiedAt),
          clear: clearIdentityVerifiedAt,
        ),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
          e.message ?? 'Erreur lors de la mise à jour du profil.');
    }
  }

  /// Persiste uniquement la section « Vérification & Conformité » :
  /// pièce d'identité (type, recto/verso, expiration), agrément PMI
  /// (numéro, expiration, document, certification) et casier judiciaire.
  Future<void> updateAssmatCompliance({
    required String uid,
    String? identityDocumentType,
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
    String? accreditationNumber,
    DateTime? accreditationExpiry,
    bool clearAccreditationExpiry = false,
    String? accreditationPhotoUrl,
    bool clearAccreditationPhotoUrl = false,
    bool? isAccreditationCertified,
    String? criminalRecordUrl,
    bool clearCriminalRecordUrl = false,
    DateTime? criminalRecordUploadedAt,
    bool clearCriminalRecordUploadedAt = false,
    bool? isIdentityVerified,
    DateTime? identityVerifiedAt,
    bool clearIdentityVerifiedAt = false,
    String? accreditationDocExtractedNumber,
    bool clearAccreditationDocExtractedNumber = false,
    DateTime? accreditationDocExtractedExpiry,
    bool clearAccreditationDocExtractedExpiry = false,
  }) async {
    try {
      await _firebase.assmatDoc(uid).update({
        if (identityDocumentType != null)
          'identityDocumentType': identityDocumentType,
        ..._clearableField(
          'identityDocumentUrl',
          identityDocumentUrl,
          clear: clearIdentityDocumentUrl,
        ),
        ..._clearableField(
          'identityDocumentUrlBack',
          identityDocumentUrlBack,
          clear: clearIdentityDocumentUrlBack,
        ),
        ..._clearableField(
          'identityDocumentExpiry',
          _timestampOrNull(identityDocumentExpiry),
          clear: clearIdentityDocumentExpiry,
        ),
        ..._clearableField(
          'identityDocumentNumber',
          identityDocumentNumber,
          clear: clearIdentityDocumentNumber,
        ),
        ..._clearableField(
          'identityDocumentFirstName',
          identityDocumentFirstName,
          clear: clearIdentityDocumentFirstName,
        ),
        ..._clearableField(
          'identityDocumentLastName',
          identityDocumentLastName,
          clear: clearIdentityDocumentLastName,
        ),
        ..._clearableField(
          'identityDocumentBirthDate',
          _timestampOrNull(identityDocumentBirthDate),
          clear: clearIdentityDocumentBirthDate,
        ),
        if (accreditationNumber != null)
          'accreditationNumber': accreditationNumber,
        ..._clearableField(
          'accreditationExpiry',
          _timestampOrNull(accreditationExpiry),
          clear: clearAccreditationExpiry,
        ),
        ..._clearableField(
          'accreditationPhotoUrl',
          accreditationPhotoUrl,
          clear: clearAccreditationPhotoUrl,
        ),
        if (isAccreditationCertified != null)
          'isAccreditationCertified': isAccreditationCertified,
        ..._clearableField(
          'criminalRecordUrl',
          criminalRecordUrl,
          clear: clearCriminalRecordUrl,
        ),
        ..._clearableField(
          'criminalRecordUploadedAt',
          _timestampOrNull(criminalRecordUploadedAt),
          clear: clearCriminalRecordUploadedAt,
        ),
        if (isIdentityVerified != null)
          'isIdentityVerified': isIdentityVerified,
        ..._clearableField(
          'identityVerifiedAt',
          _timestampOrNull(identityVerifiedAt),
          clear: clearIdentityVerifiedAt,
        ),
        ..._clearableField(
          'accreditationDocExtractedNumber',
          accreditationDocExtractedNumber,
          clear: clearAccreditationDocExtractedNumber,
        ),
        ..._clearableField(
          'accreditationDocExtractedExpiry',
          _timestampOrNull(accreditationDocExtractedExpiry),
          clear: clearAccreditationDocExtractedExpiry,
        ),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
          e.message ?? 'Erreur lors de la mise à jour de la conformité.');
    }
  }

  /// Upload une image de profil assmat dans Firebase Storage et retourne l'URL
  /// de téléchargement publique.
  Future<String> uploadAssmatPhoto(String uid, File imageFile) async {
    return _uploadFile(
      path: 'assmats/$uid/profile_photo.jpg',
      file: imageFile,
      contentType: 'image/jpeg',
      errorMessage: 'Erreur lors de l\'upload de la photo.',
    );
  }

  /// Met à jour le champ `photoUrl` dans le document assmat Firestore.
  Future<void> updateAssmatPhotoUrl(String uid, String photoUrl) async {
    try {
      await _firebase.assmatDoc(uid).update({
        'photoUrl': photoUrl,
        'updatedAt': DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur lors de la mise à jour de la photo.');
    }
  }

  /// Upload la photo/le document d'agrément PMI dans Firebase Storage et
  /// retourne l'URL publique. Le fichier peut être une image (JPEG/PNG),
  /// un PDF ou un Word (doc/docx).
  Future<String> uploadAccreditationPhoto(
    String uid,
    File file, {
    required String contentType,
  }) async {
    return _uploadFile(
      path: 'assmats/$uid/accreditation${_fileExtensionFor(contentType)}',
      file: file,
      contentType: contentType,
      errorMessage: 'Erreur lors de l\'upload de la photo d\'agrément.',
    );
  }

  /// Upload une photo de domicile assmat dans Firebase Storage et retourne l'URL publique.
  Future<String> uploadHomePhoto(String uid, File imageFile) async {
    return _uploadFile(
      path: 'assmats/$uid/home_photos/'
          '${DateTime.now().millisecondsSinceEpoch}.jpg',
      file: imageFile,
      contentType: 'image/jpeg',
      errorMessage: 'Erreur lors de l\'upload de la photo de domicile.',
    );
  }

  /// Upload un document d'identité (CNI ou Passeport) dans Firebase Storage
  /// et retourne l'URL publique.
  ///
  /// Pour une CNI, le recto (`side: 'front'`) et le verso
  /// (`side: 'back'`) doivent être fournis. Le passeport n'a qu'un seul
  /// côté (`side: 'front'`).
  Future<String> uploadIdentityDocument(
    String uid,
    File imageFile, {
    String side = 'front',
  }) async {
    final filename = side == 'back'
        ? 'identity_document_back.jpg'
        : 'identity_document.jpg';
    return _uploadFile(
      path: 'assmats/$uid/$filename',
      file: imageFile,
      contentType: 'image/jpeg',
      errorMessage: 'Erreur lors de l\'upload du document d\'identité.',
    );
  }

  /// Upload un casier judiciaire (bulletin n°3) dans Firebase Storage
  /// et retourne l'URL publique. Le document peut être une image
  /// (JPEG/PNG), un PDF ou un Word (doc/docx).
  Future<String> uploadCriminalRecord(
    String uid,
    File file, {
    required String contentType,
  }) async {
    return _uploadFile(
      path: 'assmats/$uid/criminal_record${_fileExtensionFor(contentType)}',
      file: file,
      contentType: contentType,
      errorMessage: 'Erreur lors de l\'upload du casier judiciaire.',
    );
  }

  /// Entrée d'un `update()` Firestore pour un champ effaçable : suppression
  /// du champ si [clear], nouvelle valeur si [value] est non nul, sinon le
  /// champ n'est pas modifié.
  static Map<String, Object> _clearableField(
    String key,
    Object? value, {
    required bool clear,
  }) =>
      {
        if (clear) key: FieldValue.delete() else if (value != null) key: value,
      };

  static Timestamp? _timestampOrNull(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);

  /// Dépose [file] à [path] dans Storage et retourne son URL de
  /// téléchargement. Les erreurs Firebase sont converties en
  /// [FirestoreException] ([errorMessage] si Firebase n'en fournit pas).
  Future<String> _uploadFile({
    required String path,
    required File file,
    required String contentType,
    required String errorMessage,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: contentType),
      );
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? errorMessage);
    }
  }

  /// Extension de fichier associée au type MIME du document.
  static String _fileExtensionFor(String contentType) => switch (contentType) {
        'application/pdf' => '.pdf',
        'application/msword' => '.doc',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
          '.docx',
        'image/png' => '.png',
        _ => '.jpg',
      };

  Future<void> completeParentOnboarding({
    required String uid,
    required String address,
    String familyDescription = '',
  }) async {
    try {
      final now = DateTime.now();
      // 1. Mise à jour du profil étendu parent.
      await _firebase.parentDoc(uid).update({
        'address': address,
        'familyDescription': familyDescription,
        'updatedAt': now,
      });
      // 2. Marque le profil comme complété dans le document racine.
      await _firebase.userDoc(uid).update({
        'isProfileComplete': true,
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur lors de la sauvegarde du profil.');
    }
  }

  /// Connexion via Google : ouvre le sélecteur de compte, échange les tokens
  /// contre une credential Firebase, puis crée le document Firestore si
  /// l'utilisateur est nouveau (première connexion Google).
  ///
  /// Si [role] est fourni et que l'utilisateur est nouveau, le profil
  /// Firestore (doc `users/{uid}` + sous-doc profil) est créé
  /// automatiquement. Sinon, retourne `null` pour indiquer qu'un choix
  /// de rôle est nécessaire (redirection vers WelcomePage).
  Future<UserModel?> signInWithGoogle({UserRole? role}) async {
    try {
      // 1. Affiche le sélecteur de compte Google.
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // L'utilisateur a annulé la sélection de compte.
        throw AuthException('Connexion annulée.');
      }

      // 2. Récupère les tokens OAuth2.
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Authentification Firebase.
      final cred = await _firebase.auth.signInWithCredential(credential);
      final user = cred.user;
      if (user == null) throw AuthException('Connexion Google échouée.');

      // 4. Vérifie si un profil Firestore existe déjà.
      final doc = await _firebase.userDoc(user.uid).get();
      if (doc.exists) {
        // Utilisateur connu → retourne son profil.
        return UserModel.fromFirestore(doc);
      }

      // 5. Nouvel utilisateur Google.
      //    Si un rôle est fourni, on crée le profil Firestore immédiatement.
      //    Pas d'await : une FirestoreException levée ici doit remonter
      //    telle quelle, sans être convertie par le `catch (e)` ci-dessous.
      if (role != null) {
        // ignore: unawaited_return_in_try_block
        return _createGoogleUserProfile(user: user, role: role);
      }

      //    Sinon, on retourne null : la couche presentation redirigera
      //    vers WelcomePage pour le choix du rôle.
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Erreur lors de la connexion Google : $e');
    }
  }

  /// Crée le profil Firestore pour un nouvel utilisateur Google.
  ///
  /// Écrit le doc `users/{uid}` (rôle + email) et le sous-doc profil
  /// correspondant (`parents/{uid}` ou `assmats/{uid}`).
  Future<UserModel> _createGoogleUserProfile({
    required User user,
    required UserRole role,
  }) async {
    try {
      final now = DateTime.now();
      final email = user.email ?? '';
      final displayName = user.displayName ?? '';

      // 1. Document `users/{uid}` — source de vérité du rôle.
      final model = UserModel(
        uid: user.uid,
        email: email,
        role: role,
        createdAt: now,
        displayName: displayName.isNotEmpty ? displayName : null,
        photoUrl: user.photoURL,
      );
      await _firebase.userDoc(user.uid).set(model.toFirestore());

      // 2. Sous-document profil étendu selon le rôle.
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      await _createRoleProfile(
        uid: user.uid,
        role: role,
        firstName: firstName,
        lastName: lastName,
      );

      return model;
    } on FirebaseException catch (e) {
      throw FirestoreException(
          e.message ?? 'Erreur lors de la création du profil Google.');
    }
  }

  /// Crée le profil étendu initial propre au rôle : `parents/{uid}` ou
  /// `assmats/{uid}`.
  Future<void> _createRoleProfile({
    required String uid,
    required UserRole role,
    required String firstName,
    required String lastName,
  }) async {
    if (role == UserRole.parent) {
      final profile = ParentProfileModel.initial(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
      );
      await _firebase.parentDoc(uid).set(profile.toFirestore());
    } else {
      final profile = AssmatProfileModel.initial(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
      );
      await _firebase.assmatDoc(uid).set(profile.toFirestore());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebase.auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebase.auth.signOut(),
      // Déconnecte aussi du compte Google pour forcer le sélecteur
      // au prochain signIn (évite la reconnexion silencieuse).
      _googleSignIn.signOut(),
    ]);
  }

  /// Traduit les codes Firebase en messages lisibles côté UI.
  String _mapAuthError(FirebaseAuthException e) => switch (e.code) {
        'invalid-email' => 'Adresse e-mail invalide.',
        'user-disabled' => 'Ce compte a été désactivé.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Identifiants incorrects.',
        'email-already-in-use' => 'Un compte existe déjà avec cet e-mail.',
        'weak-password' => 'Mot de passe trop faible (6 caractères minimum).',
        'network-request-failed' => 'Pas de connexion internet.',
        _ => e.message ?? 'Erreur d\'authentification.',
      };
}
