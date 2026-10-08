import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../helpers/auth_form_helpers.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_method_button.dart';
import 'forgot_password_page.dart';

/// Écran de connexion email/password + Google.
///
/// Correspond à la frame "Login Screen" du design system :
///   - Hero : "Bon retour !" + "Connectez-vous à votre compte AMiLY"
///   - Bouton Google
///   - Divider "OU PAR EMAIL"
///   - Form : email + mot de passe (toggle visibilité) + "Mot de passe oublié ?"
///     + bouton primary "Se connecter"
///   - Footer : "Pas encore de compte ? S'inscrire"
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with AuthFormStateMixin<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Succès : l'AuthWrapper prendra le relai automatiquement via le stream.
    await runAuthAction(
      () => ref.read(authRepositoryProvider).signInWithEmail(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          ),
    );
  }

  Future<void> _onGoogleTap() async {
    await runAuthAction(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
      onSuccess: (user) {
        if (user == null) {
          // Nouvel utilisateur Google : doit choisir son rôle.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomePage()),
            (route) => false,
          );
        }
        // Si user != null, le stream currentUserProvider prend le relai.
      },
    );
  }

  void _onForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ForgotPasswordPage(),
      ),
    );
  }

  void _onSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    popToRootWhenSignedIn();

    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar transparente juste pour le back button automatique.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Hero ----
              const _Hero(),
              const SizedBox(height: AppSpacing.xl),

              // ---- Google ----
              AuthMethodButton(
                icon: const _GoogleIcon(),
                label: 'Continuer avec Google',
                onTap: isLoading ? null : () => _onGoogleTap(),
              ),
              const SizedBox(height: AppSpacing.md),
              const AuthDivider(label: 'OU PAR EMAIL'),
              const SizedBox(height: AppSpacing.md),

              // ---- Form email/password ----
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email
                    const _FieldLabel('Email'),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        hintText: 'marie@exemple.fr',
                      ),
                      validator: validateEmail,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password
                    const _FieldLabel('Mot de passe'),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppColors.secondaryText,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: validatePassword,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // "Mot de passe oublié ?"
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _onForgotPassword,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xs,
                          ),
                          child: Text(
                            'Mot de passe oublié ?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Erreur éventuelle
                    if (errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.md),

                    // Bouton primary "Se connecter"
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Se connecter'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ---- Bottom : disclaimer + footer "Pas encore de compte" ----
              Text(
                // NOTE: le DSL reproduit ici le disclaimer signup ; conservé
                // à l'identique. Adapter si besoin ("En vous connectant...").
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
                    'Pas encore de compte ?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  GhostButton(label: 'S\'inscrire', onTap: _onSignUp),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Bon retour !" + "Connectez-vous à votre compte AMiLY".
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Bon retour !',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Connectez-vous à votre compte AMiLY',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

/// Label au-dessus d'un champ (ex: "Email").
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.labelMedium);
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
