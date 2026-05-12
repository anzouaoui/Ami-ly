import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_role.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

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

    final outerSub = _remote.authStateChanges().listen(
      (firebaseUser) {
        innerSub?.cancel();
        innerSub = null;

        if (firebaseUser == null) {
          _cachedUser = null;
          controller.add(null);
          return;
        }

        innerSub = _remote.watchUserProfile(firebaseUser.uid).listen(
          (model) {
            if (model == null) {
              _cachedUser = null;
              controller.add(null);
              return;
            }
            final entity = model.toEntity();
            _cachedUser = entity;
            controller.add(entity);
          },
          onError: (Object _) {
            // Permission Firestore révoquée (ex : après signOut en cours).
            _cachedUser = null;
            controller.add(null);
          },
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
  }) async {
    try {
      final model = await _remote.signInWithEmail(
        email: email,
        password: password,
      );
      final entity = model.toEntity();
      _cachedUser = entity;
      return Right(entity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required UserRole role,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final model = await _remote.signUpWithEmail(
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
      );
      final entity = model.toEntity();
      _cachedUser = entity;
      return Right(entity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> completeParentOnboarding({
    required String uid,
    required String address,
    String familyDescription = '',
  }) async {
    try {
      await _remote.completeParentOnboarding(
        uid: uid,
        address: address,
        familyDescription: familyDescription,
      );
      return const Right(unit);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    try {
      await _remote.sendPasswordResetEmail(email);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
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
}
