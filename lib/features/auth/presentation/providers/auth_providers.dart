import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/parent_profile_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// --- Câblage DI ---
/// Presentation → AuthRepository → AuthRemoteDataSource → FirebaseService
/// Chaque niveau est injecté via `ref.watch(...)` pour rester testable.

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(firebaseServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

/// Stream de l'utilisateur Ami-ly courant (FirebaseAuth + profil Firestore).
///
/// C'est LE provider que l'AuthWrapper et le router écoutent pour décider
/// de la redirection. Émet :
///   - `AsyncLoading` au démarrage (vérification de la session),
///   - `AsyncData(null)` quand déconnecté,
///   - `AsyncData(AppUser)` quand connecté + profil chargé.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).watchCurrentUser();
});

/// Stream du profil étendu parent (`parents/{uid}`).
///
/// Émet `null` quand l'utilisateur n'est pas connecté ou que le doc
/// n'existe pas encore. Utilisé par [ParentProfilePage].
final parentProfileProvider = StreamProvider.autoDispose<ParentProfileModel?>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(authRemoteDataSourceProvider).watchParentProfile(uid);
});
