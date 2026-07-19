import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants/app_constants.dart';
import '../features/auth/presentation/widgets/auth_wrapper.dart';
import '../features/video_call/presentation/widgets/incoming_call_listener.dart';
import 'theme/app_theme.dart';

/// Shell de l'application : thème + localisation + point d'entrée [AuthWrapper].
///
/// NB : si tu veux passer à `go_router` plus tard (déjà en dépendance),
/// remplace `home: AuthWrapper()` par `MaterialApp.router(routerConfig: ...)`.
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

class AmilyApp extends StatelessWidget {
  const AmilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Localisation française pour les widgets Material (date picker, etc.)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
      builder: (context, child) => IncomingCallListener(child: child ?? const SizedBox.shrink()),
      home: const AuthWrapper(),
    );
  }
}
