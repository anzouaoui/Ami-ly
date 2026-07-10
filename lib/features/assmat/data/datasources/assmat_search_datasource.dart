import '../../../../core/services/firebase_service.dart';
import '../../../auth/data/models/parent_profile_model.dart';
import '../../../parent/data/models/child_model.dart';
import '../models/parent_with_children.dart';

/// Accès Firestore pour la recherche de parents côté assmat.
class AssmatSearchDatasource {
  AssmatSearchDatasource(this._firebase);
  final FirebaseService _firebase;

  /// Stream temps réel des parents actifs (searchPaused == false)
  /// avec leurs enfants.
  Stream<List<ParentWithChildren>> watchSearchableParents() {
    return _firebase.parentsCollection
        .where('searchPaused', isEqualTo: false)
        .snapshots()
        .asyncMap((snap) async {
      final parents = snap.docs
          .map(ParentProfileModel.fromFirestore)
          .toList();

      final results = <ParentWithChildren>[];
      for (final parent in parents) {
        final childSnap = await _firebase
            .childrenCollection(parent.uid)
            .orderBy('createdAt')
            .get();
        final children = childSnap.docs
            .map(ChildModel.fromFirestore)
            .toList();
        results.add(ParentWithChildren(parent: parent, children: children));
      }
      return results;
    });
  }
}
