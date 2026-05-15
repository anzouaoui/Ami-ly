import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';

/// Accès Firestore pour les favoris d'un parent.
///
/// Chemin : `parents/{parentUid}/favorites/{assmatUid}`
/// Document : `{ addedAt: Timestamp }`
class FavoritesDatasource {
  const FavoritesDatasource(this._firebase);
  final FirebaseService _firebase;

  /// Stream des UID d'assmats mises en favori par [parentUid].
  Stream<Set<String>> watchFavoriteIds(String parentUid) {
    return _firebase
        .favoritesCollection(parentUid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  Future<void> addFavorite(String parentUid, String assmatUid) {
    return _firebase.favoriteDoc(parentUid, assmatUid).set({
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String parentUid, String assmatUid) {
    return _firebase.favoriteDoc(parentUid, assmatUid).delete();
  }
}
