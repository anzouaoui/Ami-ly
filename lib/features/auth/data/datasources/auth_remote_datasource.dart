import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      return fetchUserProfile(uid);
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
      if (role == UserRole.parent) {
        final profile = ParentProfileModel.initial(
          uid: user.uid,
          firstName: firstName ?? '',
          lastName: lastName ?? '',
        );
        await _firebase.parentDoc(user.uid).set(profile.toFirestore());
      } else {
        final profile = AssmatProfileModel.initial(
          uid: user.uid,
          firstName: firstName ?? '',
          lastName: lastName ?? '',
        );
        await _firebase.assmatDoc(user.uid).set(profile.toFirestore());
      }

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
        if (clearLocation)
          'location': FieldValue.delete()
        else if (location != null)
          'location': location,
        'updatedAt': DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur lors de la mise à jour du profil.');
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
  }) async {
    try {
      await _firebase.assmatDoc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'bio': bio,
        'isSearchable': isSearchable,
        'maxChildren': maxChildren,
        'availableSlots': availableSlots,
        'services': services,
        'schedules': schedules,
        if (clearLocation)
          'location': FieldValue.delete()
        else if (location != null)
          'location': location,
        if (clearAvailableFrom)
          'availableFrom': FieldValue.delete()
        else if (availableFrom != null)
          'availableFrom': Timestamp.fromDate(availableFrom),
        'updatedAt': DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
          e.message ?? 'Erreur lors de la mise à jour du profil.');
    }
  }

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

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebase.auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<void> signOut() => _firebase.auth.signOut();

  /// Traduit les codes Firebase en messages lisibles côté UI.
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Adresse e-mail invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Identifiants incorrects.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet e-mail.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'network-request-failed':
        return 'Pas de connexion internet.';
      default:
        return e.message ?? 'Erreur d\'authentification.';
    }
  }
}
