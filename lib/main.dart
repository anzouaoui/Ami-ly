import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'core/config/app_env.dart';
import 'core/services/firebase_service.dart';
import 'core/services/stripe_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("Handling a background message: ${message.messageId}");
}

void _registerBackgroundMessageHandler() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Échec explicite si une variable d'environnement obligatoire est absente.
  AppEnv.validateOrThrow();
  AppEnv.logWarnings(debugPrint);

  await FirebaseService.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Échec explicite si STRIPE_PUBLISHABLE_KEY est absente.
  StripeService.initStripe();

  runApp(
    const ProviderScope(
      child: AmilyApp(),
    ),
  );

  SchedulerBinding.instance.addPostFrameCallback((_) {
    _registerBackgroundMessageHandler();
  });
}
