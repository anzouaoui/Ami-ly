import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/action_list_button.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/mes_enfants_card.dart';
import '../widgets/notifications_card.dart';
import '../widgets/stat_card.dart';

/// Dashboard du parent connecté.
///
/// Correspond aux frames "Dashboard Parent" + "Dashboard Parent 2" du
/// design system :
///   - Header custom (menu + logo AMiLY à gauche, notifications à droite)
///   - Welcome "Bonjour, {displayName} 👋"
///   - Grille 2x2 de stats (contrats, enfants, RDV, paiement)
///   - Carte "Mes enfants" avec empty state + CTA "Trouver une assmat"
///   - Carte "Informations" (notifications)
///   - Action list : Envoyer un message / Journal / Paiements / Documents
///
/// Toutes les stats sont pour l'instant à 0 / "—" — elles seront branchées
/// sur Firestore quand la couche data Contrats/Enfants sera prête.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final displayName = user?.displayName ?? 'là';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const _ParentDrawer(),
      // Builder nécessaire pour obtenir un context enfant du Scaffold
      // qui sait ouvrir le drawer.
      body: Builder(
        builder: (scaffoldCtx) => SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DashboardAppBar(
                  onMenuTap: () => Scaffold.of(scaffoldCtx).openDrawer(),
                  onNotificationsTap: () => _onNotifications(context),
                ),
                _WelcomeHeader(displayName: displayName),
                _StatsGrid(),
                const SizedBox(height: AppSpacing.md),

                // Mes enfants (empty state pour l'instant)
                MesEnfantsCard(
                  onFindAssmatTap: () => _onFindAssmat(context),
                  onDocumentsTap: () => _onDocuments(context),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Informations / notifications
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: NotificationsCard(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Action list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _ActionList(
                    onMessage: () => _onStub(context, 'Envoyer un message'),
                    onJournal: () => _onStub(context, 'Voir le journal'),
                    onPayments: () => _onStub(context, 'Mes paiements'),
                    onDocuments: () => _onDocuments(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onFindAssmat(BuildContext context) {
    // TODO: naviguer vers l'écran de recherche d'assistantes maternelles.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recherche d\'assmat — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onDocuments(BuildContext context) {
    // TODO: naviguer vers l'écran documents.
    _onStub(context, 'Documents');
  }

  void _onNotifications(BuildContext context) {
    // TODO: naviguer vers l'écran / drawer de notifications.
    _onStub(context, 'Notifications');
  }

  void _onStub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// "Bonjour, {name} 👋" + "Bienvenue sur votre espace parent".
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.displayName});
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, $displayName 👋',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bienvenue sur votre espace parent',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grille 2x2 de [StatCard] : contrats / enfants / RDV / paiement.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: const [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.description_rounded,
                  iconBg: AppColors.secondary,
                  iconColor: AppColors.primary,
                  value: '0',
                  label: 'Contrats actifs',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  icon: Icons.face_rounded,
                  iconBg: AppColors.secondary,
                  iconColor: AppColors.primary,
                  value: '0',
                  label: 'Enfants accueillis',
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.calendar_today_rounded,
                  iconBg: AppColors.statBlueBg,
                  iconColor: AppColors.statBlueColor,
                  value: '—',
                  label: 'Prochain RDV',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  icon: Icons.credit_card_rounded,
                  iconBg: AppColors.statYellowBg,
                  iconColor: AppColors.accent,
                  value: '—',
                  label: 'Prochain paiement',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Liste d'actions rapides : Message (primary) + Journal / Paiements /
/// Documents (outlined).
class _ActionList extends StatelessWidget {
  const _ActionList({
    required this.onMessage,
    required this.onJournal,
    required this.onPayments,
    required this.onDocuments,
  });

  final VoidCallback onMessage;
  final VoidCallback onJournal;
  final VoidCallback onPayments;
  final VoidCallback onDocuments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionListButton.primary(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Envoyer un message',
          onTap: onMessage,
        ),
        const SizedBox(height: AppSpacing.md),
        ActionListButton.outlined(
          icon: Icons.assignment_rounded,
          label: 'Voir le journal',
          onTap: onJournal,
        ),
        const SizedBox(height: AppSpacing.md),
        ActionListButton.outlined(
          icon: Icons.payments_rounded,
          label: 'Mes paiements',
          onTap: onPayments,
        ),
        const SizedBox(height: AppSpacing.md),
        ActionListButton.outlined(
          icon: Icons.description_rounded,
          label: 'Mes documents',
          onTap: onDocuments,
        ),
      ],
    );
  }
}

/// Drawer minimaliste du dashboard (sera enrichi plus tard avec sa propre
/// spec design). Contient au moins de quoi tester la déconnexion.
class _ParentDrawer extends ConsumerWidget {
  const _ParentDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.secondary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    user?.displayName ?? 'Utilisateur',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            // TODO: enrichir le menu avec une vraie spec design
            // (profil, contrats, recherche, facturation...).
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Mon profil'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Mes contrats'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Paramètres'),
              onTap: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            const Divider(height: 1, color: AppColors.divider),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text(
                'Se déconnecter',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                // L'AuthWrapper va rebasculer sur la WelcomePage via le stream.
              },
            ),
          ],
        ),
      ),
    );
  }
}
