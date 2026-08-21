/// Configuration d'environnement d'Ami-ly.
///
/// Point d'entrée unique pour toutes les valeurs sensibles injectées au
/// moment du build via `--dart-define-from-file=.env` (ou `--dart-define`).
/// Aucune clé ne doit être codée en dur dans le code source : voir
/// `.env.example` à la racine pour la liste des variables attendues.
class AppEnv {
  AppEnv._();

  // --- Firebase (Android) ---
  static const String firebaseApiKeyAndroid = String.fromEnvironment(
    'FIREBASE_API_KEY_ANDROID',
  );
  static const String firebaseAppIdAndroid = String.fromEnvironment(
    'FIREBASE_APP_ID_ANDROID',
  );
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  // --- Firebase (iOS) ---
  static const String firebaseApiKeyIos = String.fromEnvironment(
    'FIREBASE_API_KEY_IOS',
  );
  static const String firebaseAppIdIos = String.fromEnvironment(
    'FIREBASE_APP_ID_IOS',
  );
  static const String firebaseIosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'com.app.amily',
  );

  // --- Stripe (clé publishable uniquement) ---
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  // --- RevenueCat (abonnement Ami-ly Pro) ---
  static const String revenueCatApiKeyAndroid = String.fromEnvironment(
    'REVENUECAT_API_KEY_ANDROID',
  );
  static const String revenueCatApiKeyIos = String.fromEnvironment(
    'REVENUECAT_API_KEY_IOS',
  );

  // --- Agora (visioconférence) ---
  static const String agoraAppId = String.fromEnvironment('AGORA_APP_ID');

  /// Variables obligatoires au démarrage : sans elles, l'application ne
  /// peut pas se connecter à Firebase (auth, Firestore, storage, FCM).
  static const List<(String, String)> _requiredVars = [
    ('FIREBASE_API_KEY_ANDROID', firebaseApiKeyAndroid),
    ('FIREBASE_APP_ID_ANDROID', firebaseAppIdAndroid),
    ('FIREBASE_MESSAGING_SENDER_ID', firebaseMessagingSenderId),
    ('FIREBASE_PROJECT_ID', firebaseProjectId),
    ('FIREBASE_STORAGE_BUCKET', firebaseStorageBucket),
    ('FIREBASE_API_KEY_IOS', firebaseApiKeyIos),
    ('FIREBASE_APP_ID_IOS', firebaseAppIdIos),
  ];

  static List<String> missingRequiredVars() {
    final missing = <String>[];
    for (final (name, value) in _requiredVars) {
      if (value.trim().isEmpty) {
        missing.add(name);
      }
    }
    return missing;
  }

  /// Variables optionnelles au démarrage mais dont l'absence dégrade un
  /// service : averti bruyamment au lancement, erreur claire à l'usage.
  static List<String> missingRecommendedVars() {
    final missing = <String>[];
    if (stripePublishableKey.trim().isEmpty) {
      missing.add('STRIPE_PUBLISHABLE_KEY');
    }
    if (agoraAppId.trim().isEmpty) {
      missing.add('AGORA_APP_ID');
    }
    if (revenueCatApiKeyAndroid.trim().isEmpty &&
        revenueCatApiKeyIos.trim().isEmpty) {
      missing.addAll(['REVENUECAT_API_KEY_ANDROID', 'REVENUECAT_API_KEY_IOS']);
    }
    return missing;
  }

  /// Lève [MissingEnvException] si une variable obligatoire est absente.
  ///
  /// À appeler dans `main()` avant toute initialisation de SDK.
  static void validateOrThrow() {
    final missing = missingRequiredVars();
    if (missing.isEmpty) return;

    throw MissingEnvException(missing);
  }

  /// Affiche les variables recommandées manquantes (paiements, visio...).
  static void logWarnings(void Function(String) log) {
    for (final name in missingRecommendedVars()) {
      log(
        '[Ami-ly] Variable d\'environnement manquante : $name. '
        'Le service associé sera indisponible. '
        'Renseignez-la dans .env (voir .env.example).',
      );
    }
  }
}

/// Levée au démarrage lorsque des variables d'environnement obligatoires
/// sont absentes du build.
class MissingEnvException implements Exception {
  MissingEnvException(this.missingVars);

  final List<String> missingVars;

  @override
  String toString() =>
      'MissingEnvException: variables d\'environnement manquantes '
      '(${missingVars.join(', ')}).\n'
      'Copiez .env.example vers .env, renseignez les valeurs puis relancez :\n'
      '  flutter run --dart-define-from-file=.env';
}
