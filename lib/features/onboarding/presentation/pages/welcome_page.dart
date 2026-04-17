import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/models/user_role.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/signup_page.dart';
import '../widgets/role_selection_card.dart';

/// Premier écran vu par un utilisateur non-connecté.
///
/// Correspond à la frame "Role Selection 5" du design system :
///   - Header : logo AMiLY + lien "Déjà inscrit ? Se connecter"
///   - Hero : "Bienvenue sur AMiLY" + tagline
///   - 2 cartes de sélection de rôle (parent / assistante maternelle)
///   - Footer fixe : "Besoin d'aide ? Contactez-nous"
///
/// Layout : contenu scrollable + footer ancré en bas de l'écran (hors scroll).
/// Les cartes naviguent vers [SignUpPage] avec le rôle pré-sélectionné.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _goToSignUp(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SignUpPage(initialRole: role)),
    );
  }

  void _onContactTap(BuildContext context) {
    // TODO: brancher vers la vraie page contact (email, formulaire, FAQ...).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- Contenu scrollable ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(onLoginTap: () => _goToLogin(context)),
                    const SizedBox(height: AppSpacing.xl),

                    const _HeroTitle(),
                    const SizedBox(height: AppSpacing.xl),

                    // Les 2 cartes de rôle
                    RoleSelectionCard(
                      icon: Icons.favorite_rounded,
                      iconBg: AppColors.parentIconBg,
                      iconColor: AppColors.primary,
                      title: 'Je suis parent',
                      description:
                          'Trouvez une assistante maternelle de confiance près de chez vous.',
                      onTap: () => _goToSignUp(context, UserRole.parent),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RoleSelectionCard(
                      icon: Icons.child_care_rounded,
                      iconBg: AppColors.assmatIconBg,
                      iconColor: AppColors.assmatIconColor,
                      title: 'Je suis assistante maternelle',
                      description:
                          'Gérez vos gardes et trouvez de nouvelles familles pour votre activité.',
                      onTap: () => _goToSignUp(context, UserRole.assmat),
                    ),
                  ],
                ),
              ),
            ),

            // --- Footer fixe (hors scroll) ---
            _HelpFooter(onContactTap: () => _onContactTap(context)),
          ],
        ),
      ),
    );
  }
}

/// Header : logo + CTA "Se connecter".
class _Header extends StatelessWidget {
  const _Header({required this.onLoginTap});
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bloc logo (40x40 vert + texte "AMiLY")
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              alignment: Alignment.center,
              // TODO: remplacer par l'asset du logo réel
              //       (SVG dans assets/images/ + flutter_svg).
              child: const Icon(
                Icons.family_restroom,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'AMiLY',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),

        // Bloc "Déjà inscrit ?  Se connecter"
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Déjà inscrit ?',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _GhostButton(label: 'Se connecter', onTap: onLoginTap),
            ],
          ),
        ),
      ],
    );
  }
}

/// Petit bouton texte discret (ghost) en vert primary.
class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

/// "Bienvenue sur AMiLY" + tagline.
class _HeroTitle extends StatelessWidget {
  const _HeroTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Bienvenue sur',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium,
          ),
          Text(
            'AMiLY',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'La plateforme qui connecte parents et assistantes maternelles en toute confiance.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer fixe en bas de l'écran (hors du scroll) :
/// "Besoin d'aide ?  Contactez-nous" (lien primary souligné).
class _HelpFooter extends StatelessWidget {
  const _HelpFooter({required this.onContactTap});
  final VoidCallback onContactTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Besoin d\'aide ?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          InkWell(
            onTap: onContactTap,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                'Contactez-nous',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
