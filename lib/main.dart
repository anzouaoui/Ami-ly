import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/auth/data/repositories/fake_auth_repository.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

// --- Mode dev UI : Firebase désactivé ---
// Tout passe par [FakeAuthRepository] (en mémoire).
//
// Pour rebrancher Firebase plus tard :
//   1. Restaurer les imports `firebase_options.dart` + `firebase_service.dart`
//   2. `await FirebaseService.initialize(options: DefaultFirebaseOptions.currentPlatform);`
//   3. Retirer l'override de `authRepositoryProvider` ci-dessous.
//
// --- Auto-login en dev ---
// Changer [_devInitialUser] pour contrôler l'état au démarrage :
//   - `DevUsers.parent()` → boot direct sur ParentHomeScreen
//   - `DevUsers.assmat()` → boot direct sur AssMatHomePage
//   - `null`              → flow complet Welcome → Signup / Login
//
// Se déconnecter via le Drawer → retour WelcomePage (le FakeAuthRepository
// garde l'état en mémoire pour la session en cours).
final _devInitialUser = DevUsers.parent();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final fakeAuth = FakeAuthRepository(initialUser: _devInitialUser);

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
      ],
      child: const AmilyApp(),
    ),
  );
}
