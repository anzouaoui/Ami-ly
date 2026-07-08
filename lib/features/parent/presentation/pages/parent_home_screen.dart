import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../contract/data/models/contract_model.dart';
import '../widgets/action_list_button.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/notifications_card.dart';
import '../widgets/mes_enfants_card.dart';
import '../widgets/parent_navigation_drawer.dart';
import '../widgets/stat_card.dart';
import 'child_diary_page.dart';
import 'documents_page.dart';
import 'find_childminder_page.dart';
import 'messages_page.dart';
import 'payments_page.dart';
import '../../../assmat/presentation/pages/assmat_legal_consultation_page.dart';
import '../providers/parent_providers.dart';

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
                  parentUid: user?.uid,
                ),
                _WelcomeHeader(displayName: displayName),
                _PendingSignatureBanner(parentUid: user?.uid),
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
                const SizedBox(height: AppSpacing.lg),

                // Consulter un avocat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _LegalAdviceCard(
                    onRequest: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AssMatLegalConsultationPage(),
                      ),
                    ),
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
class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenCount = ref.watch(childrenProvider).when(
          data: (list) => list.length.toString(),
          loading: () => '...',
          error: (_, __) => '0',
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: StatCard(
                  icon: Icons.description_rounded,
                  iconBg: AppColors.secondary,
                  iconColor: AppColors.primary,
                  value: '0',
                  label: 'Contrats actifs',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  icon: Icons.face_rounded,
                  iconBg: AppColors.secondary,
                  iconColor: AppColors.primary,
                  value: childrenCount,
                  label: 'Enfants accueillis',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: const [
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

// ─── Legal advice card ────────────────────────────────────────────────────────

class _LegalAdviceCard extends StatelessWidget {
  const _LegalAdviceCard({required this.onRequest});
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.balance_outlined,
                size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Consulter un avocat',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                Text('30 min au téléphone — …',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: onRequest,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            child: const Text('Demander'),
          ),
        ],
      ),
    );
  }
}

// ─── Pending signature banner ─────────────────────────────────────────────────

class _PendingSignatureBanner extends StatelessWidget {
  const _PendingSignatureBanner({required this.parentUid});

  final String? parentUid;

  @override
  Widget build(BuildContext context) {
    if (parentUid == null) return const SizedBox.shrink();

    final stream = FirebaseFirestore.instance
        .collection('contracts')
        .where('parentUid', isEqualTo: parentUid)
        .where('status', whereIn: [ContractStatus.pendingAssmat.name])
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        if (count == 0) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: const Icon(
                    Icons.hourglass_bottom_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        count == 1
                            ? '1 contrat en attente de signature'
                            : '$count contrats en attente de signature',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "En attente de la signature de l'assistante maternelle",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
