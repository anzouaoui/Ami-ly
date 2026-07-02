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
  FakeAuthRepository({
    AppUser? initialUser,
    Map<String, AppUser>? registeredUsers,
  })  : _current = initialUser,
        _registeredUsers = {
          for (final entry
              in (registeredUsers ?? const <String, AppUser>{}).entries)
            entry.key.toLowerCase(): entry.value,
        };

  AppUser? _current;
  final _controller = StreamController<AppUser?>.broadcast();

  /// Comptes connus avec un displayName + rôle pré-définis — permet de se
  /// logger avec des emails canoniques ("anouk@test.com", "marie@test.com"…)
  /// et d'avoir le bon profil sans passer par le signup. Clés en lowercase.
  final Map<String, AppUser> _registeredUsers;

  /// Basculer instantanément vers un user donné (dev only). Utilisé par les
  /// raccourcis "Vue Parent" / "Vue Assistante" dans les drawers.
  void loginAs(AppUser user) => _emit(user);

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

    // 1. Compte canonique pré-enregistré : utilise l'AppUser fourni
    //    (displayName propre, uid stable, etc.).
    final registered = _registeredUsers[email.toLowerCase()];
    if (registered != null) {
      _emit(registered);
      return Right(registered);
    }

    // 2. Fallback : user dérivé de l'email. Rôle déduit par heuristique
    //    (email contient "assmat" → assmat, sinon parent).
    final user = AppUser(
      uid: 'fake-${email.hashCode}',
      email: email,
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
  Future<Either<Failure, AppUser?>> signInWithGoogle() async {
    await _simulateLatency();
    // Stub : simule une connexion Google avec un user parent fictif.
    final user = AppUser(
      uid: 'fake-google-user',
      email: 'google.user@gmail.com',
      role: UserRole.parent,
      createdAt: DateTime(2024, 1, 1),
      displayName: 'Utilisateur Google',
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
    String? firstName,
    String? lastName,
  }) async {
    await _simulateLatency();

    if (!email.contains('@')) {
      return const Left(AuthFailure('E-mail invalide.'));
    }
    if (password.length < 6) {
      return const Left(AuthFailure('Mot de passe trop court (min. 6).'));
    }

    final fullName = [firstName ?? '', lastName ?? '']
        .where((s) => s.isNotEmpty)
        .join(' ');

    final user = AppUser(
      uid: 'fake-${email.hashCode}',
      email: email,
      role: role,
      createdAt: DateTime.now(),
      displayName: fullName.isNotEmpty ? fullName : _displayNameFromEmail(email),
      isProfileComplete: false,
    );

    _emit(user);
    return Right(user);
  }

  @override
  Future<Either<Failure, Unit>> completeParentOnboarding({
    required String uid,
    required String address,
    String familyDescription = '',
  }) async {
    await _simulateLatency(ms: 300);
    // Met à jour le user en mémoire avec isProfileComplete = true.
    if (_current != null && _current!.uid == uid) {
      _emit(_current!.copyWith(isProfileComplete: true));
    }
    return const Right(unit);
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
