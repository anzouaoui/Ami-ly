import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../../shared/models/user_role.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_method_button.dart';
import 'login_page.dart';
import 'signup_page.dart';

/// Écran de choix de méthode d'inscription, affiché entre la [WelcomePage]
/// et le [SignUpPage] (form email).
///
/// Flux :
///   - Tap "Continuer avec Google" → Google Sign-In (Firebase)
///   - Tap "S'inscrire avec un email" → [SignUpPage] avec le rôle
///   - Tap "Se connecter" → [LoginPage]
class SignUpMethodPage extends ConsumerStatefulWidget {
  const SignUpMethodPage({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<SignUpMethodPage> createState() => _SignUpMethodPageState();
}

class _SignUpMethodPageState extends ConsumerState<SignUpMethodPage> {
  bool _loading = false;
  String? _errorMessage;

  Future<void> _onGoogleTap() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await ref.read(authRepositoryProvider).signInWithGoogle();

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _loading = false;
      }),
      (user) {
        setState(() => _loading = false);
        if (user == null) {
          // Nouvel utilisateur Google sans profil → profil créé, rediriger
          // vers WelcomePage pour qu'il choisisse (ou re-choisisse) son rôle.
          // En pratique il vient de choisir son rôle ici, mais le doc Firestore
          // n'est pas encore créé. Le stream currentUserProvider gérera la suite.
          // Pour l'instant on ne fait rien : l'AuthWrapper détectera le signIn.
        }
        // Si user != null, le stream currentUserProvider prend le relai.
      },
    );
  }

  void _onEmailTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SignUpPage(initialRole: widget.role)),
    );
  }

  void _onLoginTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dès qu'un utilisateur est connecté, l'AuthWrapper prend le relai.
    ref.listen(currentUserProvider, (_, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar transparente : uniquement pour le bouton back automatique
      // (fourni par Navigator quand il y a une route précédente).
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false, // l'AppBar gère déjà le top
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Hero : badge rôle + titre + sous-titre ----
              _Hero(role: widget.role),
              const SizedBox(height: AppSpacing.xl),

              // ---- Boutons d'auth (Google / Email) ----
              AuthMethodButton(
                icon: const _GoogleIcon(),
                label: 'Continuer avec Google',
                onTap: _loading ? null : () => _onGoogleTap(),
              ),

              // Erreur éventuelle
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),
              const AuthDivider(label: 'OU'),
              const SizedBox(height: AppSpacing.md),
              AuthMethodButton(
                icon: const Icon(
                  Icons.mail_rounded,
                  size: 22,
                  color: AppColors.primaryText,
                ),
                label: 'S\'inscrire avec un email',
                onTap: _onEmailTap,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---- Bas : disclaimer + lien login ----
              Text(
                'En créant un compte, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.',
                textAlign: TextAlign.center,
                maxLines: 3,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Déjà un compte ?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  GhostButton(
                    label: 'Se connecter',
                    onTap: _onLoginTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill de rôle + titre "Créer un compte" + sous-titre.
class _Hero extends StatelessWidget {
  const _Hero({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _RolePillBadge(role: role),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Créer un compte',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Choisissez votre méthode d\'inscription',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

/// Badge pilule aux couleurs du rôle :
///   - Parent : fond vert secondary (#E8F2EE), texte vert primary (#479073)
///   - Assmat : fond pêche (#FFF3E0), texte orange (#F57C00)
class _RolePillBadge extends StatelessWidget {
  const _RolePillBadge({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (role) {
      UserRole.parent => (
          AppColors.secondary,
          AppColors.primary,
          'Parent',
        ),
      UserRole.assmat => (
          AppColors.assmatIconBg,
          AppColors.assmatIconColor,
          'Assistante maternelle',
        ),
    };

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: fg),
      ),
    );
  }
}

/// Logo Google — un "G" stylisé.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4285F4), // bleu Google
          ),
        ),
      ),
    );
  }
}
