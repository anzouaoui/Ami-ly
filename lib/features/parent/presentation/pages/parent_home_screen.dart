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
import '../widgets/parent_navigation_drawer.dart';
import '../widgets/stat_card.dart';
import 'child_diary_page.dart';
import 'documents_page.dart';
import 'find_childminder_page.dart';
import 'messages_page.dart';
import 'payments_page.dart';

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
      drawer: const ParentNavigationDrawer(),
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
                    onMessage: () => _goToMessages(context),
                    onJournal: () => _goToJournal(context),
                    onPayments: () => _goToPayments(context),
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FindChildminderPage()),
    );
  }

  void _goToMessages(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MessagesPage()),
    );
  }

  void _goToPayments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaymentsPage()),
    );
  }

  void _goToJournal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChildDiaryPage()),
    );
  }

  void _onDocuments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DocumentsPage()),
    );
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

