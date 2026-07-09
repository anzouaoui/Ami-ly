import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../contract/data/models/contract_model.dart';
import 'engagement_contract_page.dart';

class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : _DocumentsBody(parentUid: user.uid),
      ),
    );
  }
}

class _DocumentsBody extends StatelessWidget {
  const _DocumentsBody({required this.parentUid});

  final String parentUid;

  @override
  Widget build(BuildContext context) {
    final contractsQuery = FirebaseFirestore.instance
        .collection('contracts')
        .where('parentUid', isEqualTo: parentUid)
        .orderBy('updatedAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: contractsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur : ${snapshot.error}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final drafts = docs.where((d) {
          final s = (d.data() as Map<String, dynamic>)['status'] as String?;
          return s == ContractStatus.draft.name;
        }).toList();

        final pending = docs.where((d) {
          final s = (d.data() as Map<String, dynamic>)['status'] as String?;
          return s == ContractStatus.pendingAssmat.name ||
              s == ContractStatus.pendingParent.name;
        }).toList();

        final signed = docs.where((d) {
          final s = (d.data() as Map<String, dynamic>)['status'] as String?;
          return s == ContractStatus.signed.name ||
              s == ContractStatus.active.name;
        }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md,
                ),
                child: Text(
                  'Contrats, autorisations et documents administratifs',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _InfoCard(
                  icon: Icons.shield_rounded,
                  iconColor: AppColors.primary,
                  bgColor: AppColors.secondary,
                  borderColor: AppColors.primary,
                  text: 'Vos documents sont stockés de manière sécurisée '
                      'et conformément au RGPD. Seuls les parties au contrat y ont accès.',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (drafts.isNotEmpty) ...[
                _SectionTitle(title: 'Brouillons'),
                ...drafts.map((d) => _DraftCard(doc: d, parentUid: parentUid)),
                const SizedBox(height: AppSpacing.md),
              ],
              if (pending.isNotEmpty) ...[
                _SectionTitle(title: 'En attente de signature'),
                ...pending.map((d) => _PendingCard(doc: d)),
                const SizedBox(height: AppSpacing.md),
              ],
              if (signed.isNotEmpty) ...[
                _SectionTitle(title: 'Signés'),
                ...signed.map((d) => _SignedCard(doc: d)),
                const SizedBox(height: AppSpacing.md),
              ],
              if (docs.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _InfoCard(
                    icon: Icons.notifications_active_rounded,
                    iconColor: AppColors.accent,
                    bgColor: AppColors.statYellowBg,
                    borderColor: AppColors.accent,
                    text: 'Aucun contrat pour le moment. Vous pouvez '
                        'consulter et préparer vos documents en avance.',
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

String _contractTypeLabel(String? type) {
  return type == 'cdi' ? 'Contrat CDI' : 'Engagement réciproque';
}

IconData _contractTypeIcon(String? type) {
  return type == 'cdi'
      ? Icons.assignment_rounded
      : Icons.handshake_rounded;
}

Color _statusColor(String? status) {
  switch (status) {
    case 'draft':
      return AppColors.secondaryText;
    case 'pendingParent':
    case 'pendingAssmat':
      return AppColors.accent;
    case 'signed':
    case 'active':
      return AppColors.success;
    default:
      return AppColors.secondaryText;
  }
}

String _statusLabel(String? status) {
  switch (status) {
    case 'draft':
      return 'Brouillon';
    case 'pendingParent':
      return 'En attente de votre signature';
    case 'pendingAssmat':
      return 'En attente signature assmat';
    case 'signed':
      return 'Signé';
    case 'active':
      return 'Actif';
    case 'terminated':
      return 'Terminé';
    default:
      return status ?? '';
  }
}

Map<String, String> _extractNames(Map<String, dynamic> data) {
  final contractData = data['contractData'] as Map<String, dynamic>?;
  final salarie = contractData?['salarie'] as Map<String, dynamic>?;
  final enfant = contractData?['enfant'] as Map<String, dynamic>?;
  final assmatName =
      '${salarie?['prenom'] ?? ''} ${salarie?['nom'] ?? ''}'.trim();
  final childName = enfant?['prenom'] as String? ?? 'un enfant';
  return {
    'assmatName': assmatName.isNotEmpty ? assmatName : 'Assistante maternelle',
    'childName': childName,
  };
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({required this.doc, required this.parentUid});
  final QueryDocumentSnapshot doc;
  final String parentUid;

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final contractType = data['contractType'] as String?;
    final typeLabel = _contractTypeLabel(contractType);
    final typeIcon = _contractTypeIcon(contractType);
    final names = _extractNames(data);
    final assmatUid = data['assmatUid'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg)
          .copyWith(bottom: AppSpacing.sm),
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(typeIcon, size: 18, color: AppColors.secondaryText),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryText.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Brouillon',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      typeLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                names['assmatName']!,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Accueil de ${names['childName']}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: assmatUid.isNotEmpty
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EngagementContractPage(
                                assmatUid: assmatUid,
                                assmatName: names['assmatName'],
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Reprendre le brouillon'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.doc});
  final QueryDocumentSnapshot doc;

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final contractType = data['contractType'] as String?;
    final typeLabel = _contractTypeLabel(contractType);
    final typeIcon = _contractTypeIcon(contractType);
    final status = data['status'] as String?;
    final names = _extractNames(data);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg)
          .copyWith(bottom: AppSpacing.sm),
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(
              color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(typeIcon, size: 18, color: _statusColor(status)),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _statusLabel(status),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      typeLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                names['assmatName']!,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Accueil de ${names['childName']}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (data['pdfUrl'] is String && (data['pdfUrl'] as String).isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(data['pdfUrl'] as String),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: Text(
                      typeLabel == 'Engagement réciproque'
                          ? 'Engagement réciproque (signé)'
                          : '$typeLabel (signé)',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignedCard extends StatelessWidget {
  const _SignedCard({required this.doc});
  final QueryDocumentSnapshot doc;

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final contractType = data['contractType'] as String?;
    final typeLabel = _contractTypeLabel(contractType);
    final typeIcon = _contractTypeIcon(contractType);
    final status = data['status'] as String?;
    final names = _extractNames(data);
    final pdfUrl = data['pdfUrl'] as String?;
    final finalPdfUrl = data['finalPdfUrl'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg)
          .copyWith(bottom: AppSpacing.sm),
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(
              color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(typeIcon, size: 18, color: _statusColor(status)),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _statusLabel(status),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      typeLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                names['assmatName']!,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Accueil de ${names['childName']}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              if (pdfUrl != null || finalPdfUrl != null) ...[
                const SizedBox(height: AppSpacing.sm),
                if (pdfUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => launchUrl(
                          Uri.parse(pdfUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.description_outlined, size: 16),
                        label: Text('$typeLabel (signé)'),
                      ),
                    ),
                  ),
                if (finalPdfUrl != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => launchUrl(
                        Uri.parse(finalPdfUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Contrat CDI (signé)'),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 28,
              color: AppColors.primaryText,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Retour',
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.child_care_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AMiLY',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
