import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../parent/presentation/providers/parent_providers.dart';
import '../../data/datasources/matching_datasource.dart';
import '../../data/models/match_suggestion.dart';

final matchingDatasourceProvider = Provider<MatchingDatasource>((ref) {
  return MatchingDatasource(ref.watch(firebaseServiceProvider));
});

/// Suggestions de match pour le parent connecté.
///
/// Émet une liste vide tant que le calcul n'a pas été déclenché
/// via [triggerParentMatching].
final parentMatchesProvider =
    StreamProvider.autoDispose<List<MatchSuggestion>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(matchingDatasourceProvider).watchParentMatches(uid);
});

/// Suggestions de match pour l'assmat connectée.
///
/// Émet une liste vide tant que le calcul n'a pas été déclenché
/// via [triggerAssmatMatching].
final assmatMatchesProvider =
    StreamProvider.autoDispose<List<MatchSuggestion>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(matchingDatasourceProvider).watchAssmatMatches(uid);
});

/// Déclenche le calcul des suggestions de match pour le parent connecté.
///
/// À appeler après la connexion ou quand les critères changent.
Future<void> triggerParentMatching(WidgetRef ref) async {
  final uid = ref.read(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return;

  final parentProfile =
      ref.read(parentProfileProvider).valueOrNull;
  if (parentProfile == null) return;

  final children = ref.read(childrenProvider).valueOrNull ?? [];

  final childAges = children
      .where((c) => c.birthDate != null)
      .map((c) {
        final now = DateTime.now();
        return ((now.year - c.birthDate!.year) * 12 +
            now.month - c.birthDate!.month);
      })
      .toList();

  final datasource = ref.read(matchingDatasourceProvider);
  await datasource.calculateParentMatches(
    parentUid: uid,
    parentProfile: parentProfile,
    childAgesMonths: childAges,
  );
}

/// Déclenche le calcul des suggestions de match pour l'assmat connectée.
Future<void> triggerAssmatMatching(WidgetRef ref) async {
  final uid = ref.read(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return;

  final assmatProfile =
      ref.read(assmatProfileProvider).valueOrNull;
  if (assmatProfile == null) return;

  final datasource = ref.read(matchingDatasourceProvider);
  await datasource.calculateAssmatMatches(
    assmatUid: uid,
    assmatProfile: assmatProfile,
  );
}
