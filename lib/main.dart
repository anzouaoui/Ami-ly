import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/auth/data/repositories/fake_auth_repository.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

// --- Mode dev UI : Firebase désactivé ---
// Tout passe par [FakeAuthRepository] (en mémoire). Pour rebrancher Firebase :
//   1. Restaurer les imports `firebase_options.dart` + `firebase_service.dart`
//   2. `await FirebaseService.initialize(options: DefaultFirebaseOptions.currentPlatform);`
//   3. Retirer l'override de `authRepositoryProvider` ci-dessous.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
      child: const AmilyApp(),
    ),
  );
}
