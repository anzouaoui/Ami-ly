// Entry point "preview" pour tester l'UI sur ton téléphone
// SANS avoir besoin de configurer Firebase.
//
// Lance-le avec :
//   flutter run -t lib/main_preview.dart
//
// Ou pour cibler directement ton OnePlus :
//   flutter run -t lib/main_preview.dart -d 74606871
//
// Quand Firebase sera configuré (flutterfire configure), utilise le vrai
// `main.dart` qui passe par l'AuthWrapper.

import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';
import 'features/parent/presentation/pages/parent_home_screen.dart';

void main() {
  runApp(const AmilyPreviewApp());
}

class AmilyPreviewApp extends StatelessWidget {
  const AmilyPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ami-ly (Preview)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ParentHomeScreen(),
    );
  }
}
