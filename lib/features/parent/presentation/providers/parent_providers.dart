import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/parent_remote_datasource.dart';
import '../../data/models/child_model.dart';

/// Datasource parent injecté via Riverpod.
final parentRemoteDataSourceProvider = Provider<ParentRemoteDataSource>((ref) {
  return ParentRemoteDataSource(ref.watch(firebaseServiceProvider));
});

/// Stream temps réel des enfants du parent connecté
/// (`parents/{uid}/children`, triés par createdAt).
///
/// Émet une liste vide quand l'utilisateur n'est pas connecté.
/// `autoDispose` : se désabonne quand plus aucun widget ne l'écoute.
final childrenProvider =
    StreamProvider.autoDispose<List<ChildModel>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(parentRemoteDataSourceProvider).watchChildren(uid);
});
