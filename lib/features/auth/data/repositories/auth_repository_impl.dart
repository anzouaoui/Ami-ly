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
    // On combine authStateChanges + watchUserProfile :
    // - pas de user Firebase  → null
    // - user Firebase connecté → on écoute son doc Firestore en temps réel
    //   (permet au routeur de réagir à `isPro` ou `isProfileComplete`).
    return _remote.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) {
        _cachedUser = null;
        return Stream<AppUser?>.value(null);
      }
      return _remote.watchUserProfile(firebaseUser.uid).map((model) {
        final entity = model.toEntity();
        _cachedUser = entity;
        return entity;
      }).handleError((Object _) {
        // Doc pas encore créé (inscription en cours) ou déconnexion en parallèle.
        _cachedUser = null;
        return null;
      });
    });
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
    String? displayName,
  }) async {
    try {
      final model = await _remote.signUpWithEmail(
        email: email,
        password: password,
        role: role,
        displayName: displayName,
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
