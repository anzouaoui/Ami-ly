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

/// Écran d'inscription — adapté selon le rôle pré-sélectionné depuis la
/// [SignUpMethodPage] (parent ou assmat).
///
/// Structure :
///   - Hero : titre + sous-titre contextualisé
///   - Bouton Google (placeholder)
///   - Divider "OU PAR EMAIL"
///   - Form : prénom, nom, email, mot de passe (toggle visibilité)
///   - Disclaimer + footer "Déjà un compte ?"
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key, this.initialRole});

  /// Rôle pré-sélectionné quand on arrive depuis la [WelcomePage] /
  /// [SignUpMethodPage]. Laisse `null` pour afficher un sélecteur de rôle.
  final UserRole? initialRole;

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late UserRole _role = widget.initialRole ?? UserRole.parent;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
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

    final result = await ref.read(authRepositoryProvider).signUpWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _role,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
        );

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _loading = false;
      }),
      // Succès : l'AuthWrapper prend le relai via le stream.
      (_) => setState(() => _loading = false),
    );
  }

  void _onGoogleTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion Google — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onLogin() {
    Navigator.of(context).pop();
  }

  String get _heroTitle =>
      _role == UserRole.assmat ? 'Rejoindre AMiLY' : 'Créer mon compte';

  String get _heroSubtitle => _role == UserRole.assmat
      ? 'Créez votre profil d\'assistante maternelle'
      : 'Gérez la garde de votre enfant en toute simplicité';

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
              _Hero(title: _heroTitle, subtitle: _heroSubtitle),
              const SizedBox(height: AppSpacing.xl),

              // ---- Sélecteur de rôle (si non pré-sélectionné) ----
              if (widget.initialRole == null) ...[
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                      value: UserRole.parent,
                      label: Text('Parent'),
                      icon: Icon(Icons.family_restroom_rounded),
                    ),
                    ButtonSegment(
                      value: UserRole.assmat,
                      label: Text('Ass. Mat.'),
                      icon: Icon(Icons.child_care_rounded),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) =>
                      setState(() => _role = s.first),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // ---- Google ----
              AuthMethodButton(
                icon: const _GoogleIcon(),
                label: 'Continuer avec Google',
                onTap: _onGoogleTap,
              ),
              const SizedBox(height: AppSpacing.md),
              const AuthDivider(label: 'OU PAR EMAIL'),
              const SizedBox(height: AppSpacing.md),

              // ---- Form ----
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Prénom + Nom (côte à côte)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Prénom'),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _firstNameCtrl,
                                textCapitalization:
                                    TextCapitalization.words,
                                autofillHints: const [
                                  AutofillHints.givenName,
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'Marie',
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Requis'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Nom'),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _lastNameCtrl,
                                textCapitalization:
                                    TextCapitalization.words,
                                autofillHints: const [
                                  AutofillHints.familyName,
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'Dupont',
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Requis'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

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
                      validator: (v) =>
                          (v == null || !v.contains('@'))
                              ? 'E-mail invalide'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Mot de passe
                    _FieldLabel('Mot de passe'),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
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

                    // Erreur
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

                    const SizedBox(height: AppSpacing.lg),

                    // Bouton primary
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
                          : const Text('Créer mon compte'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ---- Disclaimer ----
              Text(
                'En créant un compte, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.',
                textAlign: TextAlign.center,
                maxLines: 3,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---- Footer ----
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
                  GhostButton(label: 'Se connecter', onTap: _onLogin),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets locaux ─────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.labelMedium);
  }
}

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
            color: Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
