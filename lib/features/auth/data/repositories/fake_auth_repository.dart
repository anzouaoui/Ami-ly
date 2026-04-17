import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_role.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implémentation **en mémoire** de [AuthRepository], utilisée pendant le dev UI
/// quand Firebase n'est pas branché.
///
/// Toutes les credentials sont acceptées : tu peux taper n'importe quel e-mail
/// valide et un mot de passe ≥ 6 caractères pour simuler une connexion.
/// L'état (connecté / déconnecté) est conservé tant que l'app tourne.
///
/// Passer un [initialUser] au constructeur pour démarrer l'app déjà connectée
/// (pratique pour itérer sur les écrans post-login sans re-taper un form à
/// chaque hot restart). Voir aussi [DevUsers] pour des factories prêtes à
/// l'emploi.
///
/// À retirer (ou laisser comme mock pour les tests) le jour où Firebase est
/// prêt : il suffit d'enlever l'override dans `main.dart`.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _current = initialUser;

  AppUser? _current;
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  AppUser? get currentUserSnapshot => _current;

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    // Replay de la valeur courante pour tout nouvel abonné (comportement
    // attendu par l'AuthWrapper qui écoute au démarrage).
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _simulateLatency();

    if (!email.contains('@')) {
      return const Left(AuthFailure('E-mail invalide.'));
    }
    if (password.length < 6) {
      return const Left(AuthFailure('Mot de passe trop court (min. 6).'));
    }

    final user = AppUser(
      uid: 'fake-${email.hashCode}',
      email: email,
      // Heuristique simple : si l'e-mail contient "assmat" c'est une ass mat,
      // sinon parent. Pratique pour tester les 2 parcours sans rebuild.
      role: email.toLowerCase().contains('assmat')
          ? UserRole.assmat
          : UserRole.parent,
      createdAt: DateTime.now(),
      displayName: _displayNameFromEmail(email),
      isProfileComplete: false,
    );

    _emit(user);
    return Right(user);
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required UserRole role,
    String? displayName,
  }) async {
    await _simulateLatency();

    if (!email.contains('@')) {
      return const Left(AuthFailure('E-mail invalide.'));
    }
    if (password.length < 6) {
      return const Left(AuthFailure('Mot de passe trop court (min. 6).'));
    }

    final user = AppUser(
      uid: 'fake-${email.hashCode}',
      email: email,
      role: role,
      createdAt: DateTime.now(),
      displayName: displayName ?? _displayNameFromEmail(email),
      isProfileComplete: false,
    );

    _emit(user);
    return Right(user);
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    await _simulateLatency();
    // Stub : on fait comme si l'e-mail était envoyé.
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    await _simulateLatency(ms: 150);
    _emit(null);
    return const Right(unit);
  }

  // --- Helpers ---

  void _emit(AppUser? user) {
    _current = user;
    _controller.add(user);
  }

  Future<void> _simulateLatency({int ms = 400}) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  String _displayNameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'Utilisateur';
    return local[0].toUpperCase() + local.substring(1);
  }
}

/// Factories de users fictifs pour le dev UI.
///
/// Usage dans `main.dart` :
/// ```dart
/// final fakeAuth = FakeAuthRepository(initialUser: DevUsers.parent());
/// ```
class DevUsers {
  DevUsers._();

  static AppUser parent({String name = 'Anouk'}) => AppUser(
        uid: 'dev-parent',
        email: '${name.toLowerCase()}@test.com',
        role: UserRole.parent,
        createdAt: DateTime(2024, 1, 1),
        displayName: name,
      );

  static AppUser assmat({String name = 'Marie'}) => AppUser(
        uid: 'dev-assmat',
        email: '${name.toLowerCase()}@test.com',
        role: UserRole.assmat,
        createdAt: DateTime(2024, 1, 1),
        displayName: name,
      );
}
