/// Constantes globales d'Ami-ly.
class AppConstants {
  AppConstants._();

  static const String appName = 'Ami-ly';

  // --- Firestore collections ---
  static const String usersCollection = 'users';
  static const String conversationsCollection = 'conversations';
  static const String notificationsCollection = 'notifications';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';

  // --- Firebase Storage paths ---
  static const String profilePicturesPath = 'profile_pictures';
  static const String documentsPath = 'documents';

  // --- RevenueCat (à remplir avec tes clés dans .env ou via --dart-define) ---
  static const String revenueCatApiKeyAndroid = String.fromEnvironment(
    'REVENUECAT_API_KEY_ANDROID',
    defaultValue: '',
  );
  static const String revenueCatApiKeyIos = String.fromEnvironment(
    'REVENUECAT_API_KEY_IOS',
    defaultValue: '',
  );
  static const String assmatProEntitlementId = 'amily_pro';

  // --- Stripe ---
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
}
