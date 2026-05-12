import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/auth_providers.dart';

/// Écran "Mot de passe oublié".
///
/// L'utilisateur entre son adresse e-mail ; on appelle
/// [AuthRepository.sendPasswordResetEmail] et on affiche une confirmation.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(authRepositoryProvider)
        .sendPasswordResetEmail(_emailCtrl.text.trim());

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _loading = false;
      }),
      (_) => setState(() {
        _sent = true;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _sent ? _SuccessView(email: _emailCtrl.text.trim()) : _FormView(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            loading: _loading,
            errorMessage: _errorMessage,
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

// ── Form view ──────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.loading,
    required this.errorMessage,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icône
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Titre + description
        Text(
          'Mot de passe oublié ?',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Entrez votre adresse e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Form
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Email', style: AppTextStyles.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  hintText: 'marie@exemple.fr',
                ),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'E-mail invalide' : null,
              ),

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

              const SizedBox(height: AppSpacing.lg),

              FilledButton(
                onPressed: loading ? null : onSubmit,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Envoyer le lien'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Success view ───────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 36,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'E-mail envoyé !',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Un lien de réinitialisation a été envoyé à\n$email\n\nVérifiez vos spams si vous ne le trouvez pas.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryText,
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Retour à la connexion'),
        ),
      ],
    );
  }
}
