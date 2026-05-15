import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/favorites_datasource.dart';

final _favoritesDatasourceProvider = Provider<FavoritesDatasource>((ref) {
  return FavoritesDatasource(ref.watch(firebaseServiceProvider));
});

/// Stream des UID d'assmats favorites du parent connecté.
///
/// Émet un [Set] vide si le parent n'est pas connecté.
final favoriteIdsProvider = StreamProvider.autoDispose<Set<String>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(_favoritesDatasourceProvider).watchFavoriteIds(uid);
});

/// Bascule le statut favori d'une assmat pour le parent connecté.
///
/// Retourne silencieusement si le parent n'est pas authentifié.
Future<void> toggleFavorite(WidgetRef ref, String assmatUid) async {
  final uid = ref.read(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return;
  final ds = ref.read(_favoritesDatasourceProvider);
  final ids = ref.read(favoriteIdsProvider).valueOrNull ?? {};
  if (ids.contains(assmatUid)) {
    await ds.removeFavorite(uid, assmatUid);
  } else {
    await ds.addFavorite(uid, assmatUid);
  }
}
