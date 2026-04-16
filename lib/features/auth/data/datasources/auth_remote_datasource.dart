import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../shared/models/user_role.dart';
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
  Stream<UserModel> watchUserProfile(String uid) {
    return _firebase.userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        throw FirestoreException('Profil $uid introuvable.');
      }
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
    String? displayName,
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

      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }

      // Crée le document Firestore `users/{uid}` — source de vérité du rôle.
      final model = UserModel(
        uid: user.uid,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        displayName: displayName,
      );
      await _firebase.userDoc(user.uid).set(model.toFirestore());

      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur lors de la création du profil.');
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
