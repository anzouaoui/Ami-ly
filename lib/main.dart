import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
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

void _initDeferredServices() {
  StripeService.initStripe();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: AmilyApp(),
    ),
  );

  SchedulerBinding.instance.addPostFrameCallback((_) {
    _initDeferredServices();
  });
}
