import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_role.dart';
import '../entities/app_user.dart';

/// Contrat abstrait : la couche presentation ne dépend QUE de cette interface,
/// jamais de Firebase directement. L'implémentation vit dans `data/repositories/`.
abstract class AuthRepository {
  /// Stream de l'utilisateur connecté (profil Firestore inclus).
  /// Emet `null` quand déconnecté.
  Stream<AppUser?> watchCurrentUser();

  /// Snapshot synchrone du user courant (lecture rapide, sans Firestore).
  AppUser? get currentUserSnapshot;

  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required UserRole role,
    String? firstName,
    String? lastName,
  });

  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);

  /// Complète le profil parent après l'inscription et passe
  /// `isProfileComplete` à `true` dans `users/{uid}`.
  Future<Either<Failure, Unit>> completeParentOnboarding({
    required String uid,
    required String address,
    String familyDescription = '',
  });

  Future<Either<Failure, Unit>> signOut();
}
