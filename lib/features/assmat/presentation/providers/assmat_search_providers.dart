import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';
import '../../data/datasources/assmat_search_datasource.dart';
import '../../data/models/parent_with_children.dart';

final _assmatSearchDatasourceProvider =
    Provider<AssmatSearchDatasource>((ref) {
  return AssmatSearchDatasource(ref.watch(firebaseServiceProvider));
});

/// Stream temps réel des parents actifs avec leurs enfants.
final searchableParentsWithChildrenProvider =
    StreamProvider.autoDispose<List<ParentWithChildren>>((ref) {
  return ref
      .read(_assmatSearchDatasourceProvider)
      .watchSearchableParents();
});
