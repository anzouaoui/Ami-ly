import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_role.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implémentation concrète : orchestre le datasource et convertit
/// les exceptions en [Failure] pour la couche presentation.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);
  final AuthRemoteDataSource _remote;

  AppUser? _cachedUser;

  @override
  AppUser? get currentUserSnapshot => _cachedUser;

  @override
  Stream<AppUser?> watchCurrentUser() {
    // switchMap manuel : on annule le listener Firestore précédent à chaque
    // changement d'état Firebase Auth.
    //
    // asyncExpand() ne convient pas ici : il met en pause le stream externe
    // tant que le stream interne (snapshots Firestore, infini) est actif.
    // Résultat : authStateChanges(null) après signOut n'est jamais traité.
    final controller = StreamController<AppUser?>();
    StreamSubscription<dynamic>? innerSub;

    // Met à jour le cache puis publie l'utilisateur (null = déconnecté ou
    // profil absent).
    void emit(AppUser? user) {
      _cachedUser = user;
      controller.add(user);
    }

    final outerSub = _remote.authStateChanges().listen(
      (firebaseUser) {
        innerSub?.cancel();
        innerSub = null;

        if (firebaseUser == null) {
          emit(null);
          return;
        }

        innerSub = _remote.watchUserProfile(firebaseUser.uid).listen(
          (model) {
            emit(model?.toEntity());
          },
          // Permission Firestore révoquée (ex : après signOut en cours).
          onError: (Object _) => emit(null),
        );
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    controller.onCancel = () {
      innerSub?.cancel();
      outerSub.cancel();
    };

    return controller.stream;
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => _remote.signInWithEmail(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, AppUser?>> signInWithGoogle({UserRole? role}) {
    return _guard(() async {
      final model = await _remote.signInWithGoogle(role: role);
      // Nouvel utilisateur Google sans profil Firestore → rôle à choisir.
      if (model == null) return null;
      return _cache(model.toEntity());
    });
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required UserRole role,
    String? firstName,
    String? lastName,
  }) {
    return _authenticate(
      () => _remote.signUpWithEmail(
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> completeParentOnboarding({
    required String uid,
    required String address,
    String familyDescription = '',
  }) {
    return _guard(() async {
      await _remote.completeParentOnboarding(
        uid: uid,
        address: address,
        familyDescription: familyDescription,
      );
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) {
    return _guard(() async {
      await _remote.sendPasswordResetEmail(email);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remote.signOut();
      _cachedUser = null;
      return const Right(unit);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  /// Exécute une connexion / inscription et met en cache l'utilisateur
  /// obtenu.
  Future<Either<Failure, AppUser>> _authenticate(
    Future<UserModel> Function() action,
  ) {
    return _guard(() async => _cache((await action()).toEntity()));
  }

  AppUser _cache(AppUser user) => _cachedUser = user;

  /// Convertit les exceptions du datasource en [Failure].
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
