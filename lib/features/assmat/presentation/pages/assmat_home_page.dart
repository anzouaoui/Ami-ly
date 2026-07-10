import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../contract/data/models/contract_model.dart';
import '../../../parent/presentation/widgets/action_list_button.dart';
import '../../../parent/presentation/widgets/stat_card.dart';
import 'assmat_invoice_page.dart';
import 'assmat_holidays_page.dart';
import 'assmat_day_journey_page.dart';
import 'assmat_between_page.dart';
import 'assmat_pro_page.dart';
import 'assmat_documents_page.dart';
import 'assmat_sign_contract_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import 'assmat_messages_page.dart';
import 'assmat_converter_page.dart';
import 'assmat_legal_consultation_page.dart';
import '../widgets/invite_parent_dialog.dart';
import '../../../parent/presentation/pages/assistant_page.dart';
import 'assmat_planning_page.dart';
import 'assmat_profile_page.dart';
import 'search_parents_page.dart';

/// Dashboard de l'Assistante Maternelle.
///
/// Affiche le header (menu + logo AMiLY), un message de bienvenue
/// personnalisé, et une grille 2x2 des 4 KPIs de l'activité : contrats
/// actifs, revenu mensuel, enfants accueillis, heures ce mois.
class AssMatHomePage extends ConsumerWidget {
  const AssMatHomePage({super.key});

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final displayName = user?.displayName ?? 'là';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AssMatDrawer(),
      body: Builder(
        builder: (scaffoldCtx) => SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AssMatHeader(
                  onMenuTap: () => Scaffold.of(scaffoldCtx).openDrawer(),
                  assmatUid: user?.uid,
                ),
                _WelcomeHeader(displayName: displayName),
                _PendingSignatureBanner(assmatUid: user?.uid),
                const _StatsGrid(),
                const SizedBox(height: AppSpacing.lg),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _ChildrenCard(),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _RecentActivityCard(),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _InviteParentCard(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: _LegalAdviceCard(
                    onRequest: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AssMatLegalConsultationPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: _QuickActionsCard(
                    onNewReport: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AssMatDayJourneyPage()),
                    ),
                    onContracts: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AssMatDocumentsPage()),
                    ),
                    onMessage: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AssMatMessagesPage()),
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
}

/// Header custom assmat : menu + logo brun + "AMiLY" + icône notifications.
class _AssMatHeader extends StatelessWidget {
  const _AssMatHeader({required this.onMenuTap, this.assmatUid});
  final VoidCallback onMenuTap;
  final String? assmatUid;

  static const _logoBg = Color(0xFF4A3B33);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              size: 28,
              color: AppColors.primaryText,
            ),
            onPressed: onMenuTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Menu',
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _logoBg,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.face_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'AMiLY',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _NotificationBell(assmatUid: assmatUid),
        ],
      ),
    );
  }
}

/// Icône de cloche avec badge du nombre de contrats en attente.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.assmatUid});

  final String? assmatUid;

  @override
  Widget build(BuildContext context) {
    if (assmatUid == null) {
      return const SizedBox(width: 40);
    }

    final stream = FirebaseFirestore.instance
        .collection('contracts')
        .where('assmatUid', isEqualTo: assmatUid)
        .where('status', whereIn: [ContractStatus.pendingAssmat.name])
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: AppColors.primaryText,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  tooltip: 'Notifications',
                ),
              ),
              if (count > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Pending signature banner ─────────────────────────────────────────────────

class _PendingSignatureBanner extends StatelessWidget {
  const _PendingSignatureBanner({required this.assmatUid});

  final String? assmatUid;

  @override
  Widget build(BuildContext context) {
    if (assmatUid == null) return const SizedBox.shrink();

    final stream = FirebaseFirestore.instance
        .collection('contracts')
        .where('assmatUid', isEqualTo: assmatUid)
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
                    Icons.edit_note_rounded,
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
                        "Cliquez pour signer l'engagement réciproque",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 100,
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AssmatSignContractPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Signer'),
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

/// "Bonjour, {name} 👋" + sous-titre d'accueil.
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
            'Voici le résumé de votre activité',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grille 2x2 des 4 KPIs : contrats, revenu, enfants, heures.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.description_rounded,
                  iconBg: AppColors.secondary,
                  iconColor: AppColors.primary,
                  value: '-',
                  label: 'Contrats actifs',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  icon: Icons.euro_rounded,
                  iconBg: AppColors.secondary,
                  iconColor: AppColors.primary,
                  value: '-',
                  label: 'Revenu mensuel',
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.groups_rounded,
                  iconBg: AppColors.statBlueBg,
                  iconColor: AppColors.statBlueColor,
                  value: '-',
                  label: 'Enfants accueillis',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  icon: Icons.calendar_month_rounded,
                  iconBg: AppColors.assmatIconBg,
                  iconColor: AppColors.assmatIconColor,
                  value: '-',
                  label: 'Heures ce mois',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Données mock d'un enfant accueilli.
class _ChildData {
  const _ChildData({required this.name, required this.status});
  final String name;
  final String status;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

/// Carte "Enfants accueillis" : header + lien "Tout voir" + liste des
/// enfants avec avatar + nom + statut + lien "Journal".
class _ChildrenCard extends StatelessWidget {
  const _ChildrenCard();

  static const _children = <_ChildData>[];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.face_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Enfants accueillis',
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _LinkAction(
                label: 'Tout voir',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AssMatDocumentsPage())),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Liste
          for (var i = 0; i < _children.length; i++) ...[
            _ChildRow(
              child: _children[i],
              onJournal: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AssMatDayJourneyPage()),
              ),
            ),
            if (i < _children.length - 1)
              const Divider(height: AppSpacing.md, color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Ligne d'un enfant : avatar beige + nom + statut + lien "Journal".
class _ChildRow extends StatelessWidget {
  const _ChildRow({required this.child, required this.onJournal});
  final _ChildData child;
  final VoidCallback onJournal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar initial
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.assmatIconBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            child.initial,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Nom + statut
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                child.name,
                style: AppTextStyles.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                child.status,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _LinkAction(label: 'Journal', onTap: onJournal),
      ],
    );
  }
}

/// Lien d'action en fin de row : texte primary + chevron droit.
class _LinkAction extends StatelessWidget {
  const _LinkAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Événement d'activité récente (mock UI).
class _ActivityItem {
  const _ActivityItem({
    required this.emoji,
    required this.label,
    required this.timestamp,
  });

  final String emoji;
  final String label;
  final String timestamp;
}

/// Carte "Activité récente" : 4 événements chronologiques avec emoji,
/// libellé et horodatage.
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  static const _items = <_ActivityItem>[];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.accent,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Activité récente',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Liste d'items
          for (var i = 0; i < _items.length; i++) ...[
            _ActivityRow(item: _items[i]),
            if (i < _items.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Ligne d'un événement : emoji + label + timestamp (stack vertical).
class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});
  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.timestamp,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// Inviter un parent
// -----------------------------------------------------------------

/// Statut d'une invitation envoyée à un parent.
enum _InvitationStatus { contratActif, inscrit, expire }

/// Données mock d'une invitation.
class _InvitationData {
  const _InvitationData({
    required this.name,
    required this.subtitle,
    required this.status,
  });

  final String name;
  final String subtitle;
  final _InvitationStatus status;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

/// Carte "Inviter un parent" : promo 1 mois offert + liste des invitations
/// envoyées avec leur statut.
class _InviteParentCard extends StatelessWidget {
  const _InviteParentCard();

  static const _invitations = <_InvitationData>[];

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Inviter un parent',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Promo banner
          const _PromoBanner(),
          const SizedBox(height: AppSpacing.lg),

          // Section header : titre + bouton inviter
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invitations parents',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_invitations.length} invitations',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => showInviteParentDialog(context),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Inviter'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Liste invitations
          for (var i = 0; i < _invitations.length; i++) ...[
            _InvitationRow(
              invitation: _invitations[i],
              onTap: () => _stub(context, _invitations[i].name),
            ),
            if (i < _invitations.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Bannière promo "1 mois offert" — fond vert clair + icône cadeau.
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎁 1 mois offert !',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '1 parent actif = 1 mois AMiLY Pro gratuit',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne d'une invitation : avatar pêche + nom + sous-titre + pilule statut.
class _InvitationRow extends StatelessWidget {
  const _InvitationRow({required this.invitation, required this.onTap});

  final _InvitationData invitation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar initial
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.assmatIconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  invitation.initial,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Nom + sous-titre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.name,
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      invitation.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _InvitationStatusPill(status: invitation.status),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pilule de statut : 3 variantes (vert contrat actif / bleu inscrit /
/// rouge expiré).
class _InvitationStatusPill extends StatelessWidget {
  const _InvitationStatusPill({required this.status});
  final _InvitationStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, label, fg, bg) = switch (status) {
      _InvitationStatus.contratActif => (
          Icons.check_circle_rounded,
          'Contrat actif',
          AppColors.primary,
          AppColors.secondary,
        ),
      _InvitationStatus.inscrit => (
          Icons.check_circle_rounded,
          'Inscrit',
          AppColors.statBlueColor,
          AppColors.statBlueBg,
        ),
      _InvitationStatus.expire => (
          Icons.cancel_rounded,
          'Expiré',
          AppColors.error,
          Color.alphaBlend(
            AppColors.error.withValues(alpha: 0.12),
            AppColors.surface,
          ),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// Consulter un avocat
// -----------------------------------------------------------------

/// Carte "Consulter un avocat" : icône scales + titre + subtitle +
/// bouton primary "Demander".
class _LegalAdviceCard extends StatelessWidget {
  const _LegalAdviceCard({required this.onRequest});
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icône justice dans un carré tinté
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.divider.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.balance_rounded,
              color: AppColors.primaryText,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Titre + sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consulter un avocat',
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '30 min au téléphone — barreau partenaire',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: onRequest,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
            ),
            child: const Text('Demander'),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// Actions rapides
// -----------------------------------------------------------------

/// Liste d'actions rapides (rapport, contrats, message) — réutilise
/// [ActionListButton] de la feature parent.
class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.onNewReport,
    required this.onContracts,
    required this.onMessage,
  });

  final VoidCallback onNewReport;
  final VoidCallback onContracts;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActionListButton.primary(
            icon: Icons.edit_note_rounded,
            label: 'Nouveau rapport',
            onTap: onNewReport,
          ),
          const SizedBox(height: AppSpacing.sm),
          ActionListButton.outlined(
            icon: Icons.description_outlined,
            label: 'Mes contrats',
            onTap: onContracts,
          ),
          const SizedBox(height: AppSpacing.sm),
          ActionListButton.outlined(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Envoyer un message',
            onTap: onMessage,
          ),
        ],
      ),
    );
  }
}

class AssMatDrawer extends ConsumerStatefulWidget {
  const AssMatDrawer();

  @override
  ConsumerState<AssMatDrawer> createState() => AssMatDrawerState();
}

class AssMatDrawerState extends ConsumerState<AssMatDrawer> {
  static const _logoBg = Color(0xFF4A3B33);

  final _expanded = <String>{'ACTIVITÉ'};

  void _toggle(String section) =>
      setState(() => _expanded.contains(section)
          ? _expanded.remove(section)
          : _expanded.add(section));

  void _go(Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label — à venir'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Drawer(
      backgroundColor: AppColors.background,
      width: 300,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.divider, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _logoBg,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.family_restroom,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('AMiLY',
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.w800)),
                        Text('Espace Assistante',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.secondaryText)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.secondaryText, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // ── Sections ────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                children: [
                  // ── ACTIVITÉ ──
                  _SectionHeader(
                    label: 'ACTIVITÉ',
                    expanded: _expanded.contains('ACTIVITÉ'),
                    onTap: () => _toggle('ACTIVITÉ'),
                  ),
                  if (_expanded.contains('ACTIVITÉ')) ...[
                    _DrawerItem(
                      icon: Icons.grid_view_rounded,
                      label: 'Tableau de bord',
                      isActive: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    _DrawerItem(
                      icon: Icons.assignment_outlined,
                      label: 'Journal quotidien',
                      onTap: () => _go(const AssMatDayJourneyPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.fact_check_outlined,
                      label: 'Feuilles de présence',
                      onTap: () => _stub('Feuilles de présence'),
                    ),
                  ],

                  // ── DÉVELOPPER MON ACTIVITÉ ──
                  _SectionHeader(
                    label: 'DÉVELOPPER MON ACTIVITÉ',
                    expanded: _expanded.contains('DÉVELOPPER'),
                    onTap: () => _toggle('DÉVELOPPER'),
                  ),
                  if (_expanded.contains('DÉVELOPPER')) ...[
                    _DrawerItem(
                      icon: Icons.search_rounded,
                      label: 'Parents en recherche',
                      badgeCount: 2,
                      onTap: () => _go(const SearchParentsPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.map_outlined,
                      label: 'Carte des familles',
                      onTap: () => _stub('Carte des familles'),
                    ),
                    _DrawerItem(
                      icon: Icons.star_outline_rounded,
                      label: 'AMiLY Pro',
                      onTap: () => _go(const AssMatProPage()),
                    ),
                  ],

                  // ── GESTION ──
                  _SectionHeader(
                    label: 'GESTION',
                    expanded: _expanded.contains('GESTION'),
                    onTap: () => _toggle('GESTION'),
                  ),
                  if (_expanded.contains('GESTION')) ...[
                    _DrawerItem(
                      icon: Icons.article_outlined,
                      label: 'Contrats',
                      onTap: () => _go(const AssMatDocumentsPage()),
                    ),
                    _PendingContractBadge(
                      uid: currentUser?.uid,
                      onTap: () => _go(const AssmatSignContractPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.request_quote_outlined,
                      label: 'Facturation',
                      onTap: () => _go(const AssMatInvoicePage()),
                    ),
                    _DrawerItem(
                      icon: Icons.calendar_month_outlined,
                      label: 'Planning',
                      onTap: () => _go(const AssMatPlanningPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.beach_access_outlined,
                      label: 'Congés',
                      onTap: () => _go(const AssMatHolidaysPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.folder_outlined,
                      label: 'Documents',
                      onTap: () => _go(const AssMatDocumentsPage()),
                    ),
                  ],

                  // ── COMMUNICATION ──
                  _SectionHeader(
                    label: 'COMMUNICATION',
                    expanded: _expanded.contains('COMMUNICATION'),
                    onTap: () => _toggle('COMMUNICATION'),
                  ),
                  if (_expanded.contains('COMMUNICATION')) ...[
                    _DrawerItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Messages',
                      badgeCount: 3,
                      onTap: () => _go(const AssMatMessagesPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.people_outline_rounded,
                      label: 'Entre Ass Mat',
                      badgeCount: 1,
                      onTap: () => _go(const AssMatBetweenPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.domain_outlined,
                      label: 'Messagerie PMI',
                      onTap: () => _stub('Messagerie PMI'),
                    ),
                    _DrawerItem(
                      icon: Icons.smart_toy_outlined,
                      label: 'Assistant AMiLY',
                      onTap: () => _go(const AssistantPage()),
                    ),
                  ],

                  // ── COMPTE ──
                  _SectionHeader(
                    label: 'COMPTE',
                    expanded: _expanded.contains('COMPTE'),
                    onTap: () => _toggle('COMPTE'),
                  ),
                  if (_expanded.contains('COMPTE')) ...[
                    _DrawerItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Mon profil',
                      onTap: () => _go(const AssMatProfilePage()),
                    ),
                    _DrawerItem(
                      icon: Icons.sell_outlined,
                      label: 'Tarifs & abonnement',
                      onTap: () => _stub('Tarifs & abonnement'),
                    ),
                    _DrawerItem(
                      icon: Icons.schedule_outlined,
                      label: "Convertisseur d'heures",
                      onTap: () => _go(const AssMatConverterPage()),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.divider),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Déconnexion',
              isSpecial: true,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Se déconnecter ?'),
                    content: const Text(
                      'Vous devrez vous reconnecter pour accéder à votre compte.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(false),
                        child: const Text('Annuler'),
                      ),
                      FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pop(true),
                        child: const Text('Se déconnecter'),
                      ),
                    ],
                  ),
                );
                if (!context.mounted) return;
                Navigator.of(context).pop(); // ferme le drawer
                if (confirm == true) {
                  await ref.read(authRepositoryProvider).signOut();
                }
              },
            ),
            _UserCard(
              displayName: ref.watch(currentUserProvider).valueOrNull?.displayName ?? 'Utilisateur',
              role: 'Assistante maternelle',
              photoUrl: ref.watch(assmatProfileProvider).valueOrNull?.photoUrl,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.expanded,
    required this.onTap,
  });
  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_right_rounded,
              size: 18,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Drawer item ──────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isSpecial = false,
    this.badgeCount,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isSpecial;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final fg = isActive
        ? AppColors.primary
        : isSpecial
            ? AppColors.accent
            : AppColors.primaryText;
    final iconColor = isActive
        ? AppColors.primary
        : isSpecial
            ? AppColors.accent
            : AppColors.secondaryText;
    final bg = isActive
        ? AppColors.primary.withValues(alpha: 0.08)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: fg,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (badgeCount != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    alignment: Alignment.center,
                    child: Text(
                      '$badgeCount',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pending contract badge ───────────────────────────────────────────────────

class _PendingContractBadge extends StatelessWidget {
  const _PendingContractBadge({required this.uid, required this.onTap});

  final String? uid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return _DrawerItem(
        icon: Icons.edit_note_rounded,
        label: 'Signature en attente',
        onTap: onTap,
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('contracts')
        .where('assmatUid', isEqualTo: uid)
        .where('status', whereIn: [ContractStatus.pendingAssmat.name])
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _DrawerItem(
          icon: Icons.edit_note_rounded,
          label: 'Signature en attente',
          badgeCount: count > 0 ? count : null,
          onTap: onTap,
        );
      },
    );
  }
}

// ─── User card ────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.displayName,
    required this.role,
    this.photoUrl,
  });

  final String displayName;
  final String role;
  final String? photoUrl;

  String get _initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                role,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    const bg = Color(0xFFD4EDD4); // vert clair assmat
    const fg = AppColors.primary;
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initialsWidget(bg, fg),
          errorWidget: (_, __, ___) => _initialsWidget(bg, fg),
        ),
      );
    }
    return _initialsWidget(bg, fg);
  }

  Widget _initialsWidget(Color bg, Color fg) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTextStyles.labelLarge.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

