import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Point d'entrée unique pour tous les services Firebase d'Ami-ly.
///
/// Évite de disperser `FirebaseAuth.instance` / `FirebaseFirestore.instance`
/// un peu partout dans le code : on passe toujours par ce singleton,
/// injecté via Riverpod ([firebaseServiceProvider]).
///
/// Cela facilite :
///  - le mock en tests (on override le provider),
///  - le changement de projet Firebase (prod / dev / staging),
///  - l'ajout futur de réglages (region Firestore, émulateurs locaux...).
class FirebaseService {
  FirebaseService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  /// À appeler UNE SEULE FOIS dans `main()` avant `runApp`.
  /// Nécessite que `flutterfire configure` ait généré `firebase_options.dart`.
  static Future<void> initialize({FirebaseOptions? options}) async {
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp(options: options);
  }

  /// Branche les émulateurs locaux (`firebase emulators:start`).
  /// À appeler en dev uniquement, juste après [initialize].
  Future<void> useEmulators({String host = 'localhost'}) async {
    await auth.useAuthEmulator(host, 9099);
    firestore.useFirestoreEmulator(host, 8080);
    await storage.useStorageEmulator(host, 9199);
  }

  // --- Raccourcis pratiques ---

  /// Utilisateur Firebase courant (peut être `null`).
  User? get currentUser => auth.currentUser;

  /// Stream des changements d'authentification (login / logout / refresh token).
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Collection `users/{uid}` — source de vérité pour le profil + le rôle.
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      usersCollection.doc(uid);

  /// Collection `parents/{uid}` — profil étendu du parent.
  CollectionReference<Map<String, dynamic>> get parentsCollection =>
      firestore.collection('parents');

  DocumentReference<Map<String, dynamic>> parentDoc(String uid) =>
      parentsCollection.doc(uid);

  /// Collection `assmats/{uid}` — profil étendu de l'assistante maternelle.
  CollectionReference<Map<String, dynamic>> get assmatsCollection =>
      firestore.collection('assmats');

  DocumentReference<Map<String, dynamic>> assmatDoc(String uid) =>
      assmatsCollection.doc(uid);

  /// Sous-collection `parents/{parentUid}/children` — enfants du parent.
  CollectionReference<Map<String, dynamic>> childrenCollection(
          String parentUid) =>
      parentDoc(parentUid).collection('children');

  DocumentReference<Map<String, dynamic>> childDoc(
          String parentUid, String childId) =>
      childrenCollection(parentUid).doc(childId);

  /// Sous-collection `parents/{parentUid}/favorites` — assmats favorites.
  CollectionReference<Map<String, dynamic>> favoritesCollection(
          String parentUid) =>
      parentDoc(parentUid).collection('favorites');

  DocumentReference<Map<String, dynamic>> favoriteDoc(
          String parentUid, String assmatUid) =>
      favoritesCollection(parentUid).doc(assmatUid);
}

/// Provider Riverpod exposant le singleton [FirebaseService] à toute l'app.
///
/// En test : `container.override(firebaseServiceProvider.overrideWith(...))`.
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
