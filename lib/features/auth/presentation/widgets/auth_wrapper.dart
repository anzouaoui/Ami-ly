import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_error_screen.dart';
import '../../../../core/widgets/app_splash_screen.dart';
import '../../../../shared/models/user_role.dart';
import '../../../assmat/presentation/pages/assmat_shell.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../../../parent/presentation/pages/parent_shell.dart';
import '../providers/auth_providers.dart';

/// Widget racine qui décide quoi afficher selon l'état d'authentification
/// et le rôle de l'utilisateur stocké dans Firestore.
///
/// Flow :
///   1. Au boot, [currentUserProvider] émet `AsyncLoading` → [AppSplashScreen].
///   2. Pas d'utilisateur Firebase     → [WelcomePage] (choix du rôle).
///   3. Utilisateur + rôle `parent`    → [ParentHomePage].
///   4. Utilisateur + rôle `assmat`    → [AssMatHomePage].
///   5. Erreur (profil corrompu, etc.) → [AppErrorScreen] avec retry.
///
/// Le fait d'utiliser un `StreamProvider` fait que toute modification du doc
/// Firestore (ex : Cloud Function qui flippe `isPro` après achat RevenueCat)
/// re-trigger le `build` sans aucune action côté UI.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const AppSplashScreen(),
      error: (err, _) => AppErrorScreen(
        message: 'Impossible de charger votre profil.\n$err',
        onRetry: () => ref.invalidate(currentUserProvider),
      ),
      data: (user) {
        if (user == null) {
          return const WelcomePage();
        }
        switch (user.role) {
          case UserRole.parent:
            return const ParentShell();
          case UserRole.assmat:
            return const AssMatShell();
        }
      },
    );
  }
}
