import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../features/auth/presentation/widgets/auth_wrapper.dart';
import 'theme/app_theme.dart';

/// Shell de l'application : thème + localisation + point d'entrée [AuthWrapper].
///
/// NB : si tu veux passer à `go_router` plus tard (déjà en dépendance),
/// remplace `home: AuthWrapper()` par `MaterialApp.router(routerConfig: ...)`.
class AmilyApp extends StatelessWidget {
  const AmilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const AuthWrapper(),
    );
  }
}
