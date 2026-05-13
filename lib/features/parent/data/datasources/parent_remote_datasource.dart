import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/child_model.dart';

/// Couche data dédiée aux opérations parent (hors auth).
///
/// Pour l'instant limitée à la gestion des enfants. D'autres
/// opérations (planning, contrats…) viendront s'ajouter ici.
class ParentRemoteDataSource {
  ParentRemoteDataSource(this._firebase);
  final FirebaseService _firebase;

  // ── Enfants ────────────────────────────────────────────────────────────────

  /// Stream temps réel de la sous-collection `parents/{parentUid}/children`,
  /// triée par date de création (ordre d'ajout).
  Stream<List<ChildModel>> watchChildren(String parentUid) {
    return _firebase
        .childrenCollection(parentUid)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ChildModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Crée un nouveau document enfant et retourne l'ID Firestore généré.
  Future<String> addChild(String parentUid, ChildModel child) async {
    try {
      final ref = await _firebase
          .childrenCollection(parentUid)
          .add(child.toFirestore());
      return ref.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(
          e.message ?? "Erreur lors de l'ajout de l'enfant.");
    }
  }

  /// Met à jour un document enfant existant.
  /// Lève [FirestoreException] si [child.id] est null.
  Future<void> updateChild(String parentUid, ChildModel child) async {
    if (child.id == null) {
      throw FirestoreException('ID enfant manquant pour la mise à jour.');
    }
    try {
      await _firebase.childDoc(parentUid, child.id!).update({
        ...child.toFirestore(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
          e.message ?? "Erreur lors de la mise à jour de l'enfant.");
    }
  }

  /// Supprime définitivement un document enfant.
  Future<void> deleteChild(String parentUid, String childId) async {
    try {
      await _firebase.childDoc(parentUid, childId).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          e.message ?? "Erreur lors de la suppression de l'enfant.");
    }
  }
}
