import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/badge_service.dart';
import '../../../../core/widgets/app_error_screen.dart';
import '../../../../core/widgets/app_splash_screen.dart';
import '../../../../shared/models/user_role.dart';
import '../../../assmat/presentation/pages/assmat_shell.dart';
import '../pages/login_page.dart';
import '../../../parent/presentation/pages/parent_onboarding_page.dart';
import '../../../parent/presentation/pages/parent_shell.dart';
import '../providers/auth_providers.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/helpers/notification_navigation_helper.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../../app/app.dart';

/// Widget racine qui décide quoi afficher selon l'état d'authentification
/// et le rôle de l'utilisateur stocké dans Firestore.
///
/// Flow :
///   1. Au boot, [currentUserProvider] émet `AsyncLoading` → [AppSplashScreen].
///   2. Pas d'utilisateur Firebase     → [LoginPage].
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
    ref.listen(currentUserProvider, (previous, next) {
      final user = next.valueOrNull;
      final prevUser = previous?.valueOrNull;

      if (user != null && (prevUser == null || prevUser.uid != user.uid)) {
        ref.read(pushNotificationServiceProvider).initialize(user.uid);
      } else if (user == null && prevUser != null) {
        ref.read(pushNotificationServiceProvider).removeToken(prevUser.uid);
      }
    });

    PushNotificationService.onNotificationTap = (data) {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      
      final type = data['type'] as String?;
      if (type == null) return;
      
      final context = globalNavigatorKey.currentContext;
      if (context == null) return;

      if (['newMessage', 'visioProposalReceived', 'visioProposalResponse'].contains(type)) {
        final convId = data['conversationId'] as String?;
        if (convId != null) {
          NotificationNavigationHelper.navigateToConversation(context, convId, user.uid);
        }
      } else if (['contractSignatureRequest', 'contractSigned', 'contractStatusChanged'].contains(type)) {
        final contractId = data['contractId'] as String?;
        if (contractId != null) {
          NotificationNavigationHelper.navigateToContract(context, contractId, user.uid);
        }
      }
    };

    // ── App icon badge ────────────────────────────────────────────────────────
    ref.listen(unreadNotificationsCountProvider, (previous, next) {
      final count = next.valueOrNull ?? 0;
      BadgeService.setCount(count);
    });

    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const AppSplashScreen(),
      error: (err, _) => AppErrorScreen(
        message: 'Impossible de charger votre profil.\n$err',
        onRetry: () => ref.invalidate(currentUserProvider),
      ),
      data: (user) {
        if (user == null) return const LoginPage();

        switch (user.role) {
          case UserRole.parent:
            if (!user.isProfileComplete) return const ParentOnboardingPage();
            return const ParentShell();
          case UserRole.assmat:
            return const AssMatShell();
        }
      },
    );
  }
}
