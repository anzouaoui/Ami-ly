import 'package:flutter/material.dart';
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
/// Lance une exception si l'écriture Firestore échoue — à capturer à l'appelant.
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

/// Variante de [toggleFavorite] avec affichage d'un [SnackBar] en cas d'erreur.
Future<void> toggleFavoriteWithFeedback(
  WidgetRef ref,
  String assmatUid,
  BuildContext context,
) async {
  try {
    await toggleFavorite(ref, assmatUid);
  } catch (e) {
    debugPrint('[Favorites] toggleFavorite error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Impossible de modifier les favoris.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
