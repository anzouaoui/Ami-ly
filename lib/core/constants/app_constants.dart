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

  // --- Abonnement Ami-ly Pro ---
  static const String assmatProEntitlementId = 'amily_pro';

  // Les clés d'API (Stripe, RevenueCat, Agora, Firebase) sont gérées dans
  // lib/core/config/app_env.dart via --dart-define-from-file=.env.
}
