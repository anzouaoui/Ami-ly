import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/firebase_service.dart';
import 'firebase_options.dart';

// ─── Mode de démarrage ────────────────────────────────────────────────────────
//
// true  → FakeAuthRepository en mémoire (aucun appel Firebase, dev UI rapide).
// false → Firebase réel (Auth + Firestore). Mode par défaut.
//
// Pour revenir en mode dev UI, passer à `true` et décommenter le bloc fake ci-dessous.
const _useFakeAuth = false;

// ─── Imports dev (décommentés uniquement quand _useFakeAuth = true) ───────────
// import 'features/auth/data/repositories/fake_auth_repository.dart';
// import 'features/auth/domain/entities/app_user.dart';
// import 'features/auth/presentation/providers/auth_providers.dart';
//
// final _devInitialUser = DevUsers.parent();
// Map<String, AppUser> _registeredDevAccounts() => {
//       'anouk@test.com': DevUsers.parent(),
//       'marie@test.com': DevUsers.assmat(),
//     };

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!_useFakeAuth) {
    await FirebaseService.initialize(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    const ProviderScope(
      // Pas d'override → authRepositoryProvider utilise AuthRepositoryImpl
      // branché sur FirebaseService (voir auth_providers.dart).
      child: AmilyApp(),
    ),
  );
}
