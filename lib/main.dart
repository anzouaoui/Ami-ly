import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase avant tout accès aux services (Auth / Firestore / Storage).
  //
  // ÉTAPE SUIVANTE À FAIRE :
  //   1. Installer la CLI FlutterFire : `dart pub global activate flutterfire_cli`
  //   2. Lancer `flutterfire configure` à la racine du projet.
  //   3. Ça génère `lib/firebase_options.dart` — importe-le puis passe
  //      `options: DefaultFirebaseOptions.currentPlatform` à `initialize()`.
  //
  // Exemple une fois configuré :
  //   import 'firebase_options.dart';
  //   await FirebaseService.initialize(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  await FirebaseService.initialize();

  // Décommente pour brancher les émulateurs locaux en dev :
  //   final service = FirebaseService();
  //   await service.useEmulators();

  runApp(
    const ProviderScope(
      child: AmilyApp(),
    ),
  );
}
