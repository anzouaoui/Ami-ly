import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/auth/data/repositories/fake_auth_repository.dart';
import 'features/auth/domain/entities/app_user.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

// --- Mode dev UI : Firebase désactivé ---
// Tout passe par [FakeAuthRepository] (en mémoire).
//
// Pour rebrancher Firebase plus tard :
//   1. Restaurer les imports `firebase_options.dart` + `firebase_service.dart`
//   2. `await FirebaseService.initialize(options: DefaultFirebaseOptions.currentPlatform);`
//   3. Retirer l'override de `authRepositoryProvider` ci-dessous.
//
// --- Comptes de test pré-enregistrés ---
// Ces deux comptes canoniques sont disponibles en permanence :
//
//   Parent   → anouk@test.com / password  (DisplayName: Anouk)
//   Assmat   → marie@test.com / password  (DisplayName: Marie)
//
// Se connecter avec ces emails depuis la LoginPage te donnera le bon profil
// avec les bonnes données. Dans les drawers, les boutons "Vue Assistante" /
// "Vue Parent" basculent instantanément entre les deux comptes.
//
// --- Auto-login au démarrage ---
// Changer [_devInitialUser] pour contrôler l'état au boot :
//   - `DevUsers.parent()` → boot direct sur ParentHomeScreen (par défaut)
//   - `DevUsers.assmat()` → boot direct sur AssMatHomePage
//   - `null`              → flow complet Welcome → Login / Signup
final _devInitialUser = DevUsers.parent();

/// Comptes canoniques exposés dans le FakeAuthRepository. Toute connexion
/// via la LoginPage avec un de ces emails renverra l'AppUser correspondant
/// (avec le bon displayName et le bon rôle).
Map<String, AppUser> _registeredDevAccounts() => {
      'anouk@test.com': DevUsers.parent(),
      'marie@test.com': DevUsers.assmat(),
    };

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final fakeAuth = FakeAuthRepository(
    initialUser: _devInitialUser,
    registeredUsers: _registeredDevAccounts(),
  );

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
      ],
      child: const AmilyApp(),
    ),
  );
}
