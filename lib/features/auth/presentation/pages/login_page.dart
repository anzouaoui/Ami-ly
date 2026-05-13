import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_method_button.dart';
import 'forgot_password_page.dart';

/// Écran de connexion email/password + Google.
///
/// Correspond à la frame "Login Screen" du design system :
///   - Hero : "Bon retour !" + "Connectez-vous à votre compte AMiLY"
///   - Bouton Google (placeholder tant que Firebase n'est pas branché)
///   - Divider "OU PAR EMAIL"
///   - Form : email + mot de passe (toggle visibilité) + "Mot de passe oublié ?"
///     + bouton primary "Se connecter"
///   - Footer : "Pas encore de compte ? S'inscrire"
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await ref.read(authRepositoryProvider).signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _loading = false;
      }),
      // Succès : l'AuthWrapper prendra le relai automatiquement via le stream.
      (_) => setState(() => _loading = false),
    );
  }

  void _onGoogleTap() {
    // TODO: brancher Google Sign-In.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion Google — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
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
    // Retour à la racine (WelcomePage via AuthWrapper) pour choisir un rôle
    // avant de s'inscrire.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Dès que le stream émet un utilisateur connecté, on remonte à la racine
    // pour laisser AuthWrapper afficher ParentShell / AssMatShell.
    ref.listen(currentUserProvider, (_, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    });

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
                onTap: _onGoogleTap,
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
                    _FieldLabel('Email'),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        hintText: 'marie@exemple.fr',
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'E-mail invalide'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password
                    _FieldLabel('Mot de passe'),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
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
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Min. 6 caractères'
                          : null,
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

                    // Bouton primary "Se connecter"
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
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

/// Placeholder logo Google — un "G" stylisé.
/// TODO: remplacer par l'asset officiel Google (SVG multicolore).
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
