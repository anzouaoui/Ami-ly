import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

enum _DocStatus { brouillon, envoye, signe, recu }

class _Document {
  const _Document({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.status,
    this.childName,
    this.date,
  });
  final String title;
  final String subtitle;
  final String emoji;
  final _DocStatus status;
  final String? childName;
  final String? date;
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kToPrepare = [
  _Document(
    title: 'Contrat de garde',
    subtitle: 'Contrat d\'accueil entre l\'assistante et les parents',
    emoji: '📋',
    status: _DocStatus.brouillon,
  ),
  _Document(
    title: 'Copie vaccination',
    subtitle: 'Photos du carnet de santé et vaccinations',
    emoji: '💉',
    status: _DocStatus.brouillon,
  ),
  _Document(
    title: 'Autorisation droit image',
    subtitle: 'Autorisation parentale pour les photos de l\'enfant',
    emoji: '📷',
    status: _DocStatus.brouillon,
  ),
  _Document(
    title: 'Fiche santé enfant',
    subtitle: 'Informations médicales et contacts urgence',
    emoji: '🏥',
    status: _DocStatus.brouillon,
  ),
];

const _kSigned = [
  _Document(
    title: 'Contrat CDI — Lucas Dupont',
    subtitle: 'Signé le 12 jan. 2026',
    emoji: '📄',
    status: _DocStatus.signe,
    childName: 'Lucas Dupont',
    date: '12 jan. 2026',
  ),
  _Document(
    title: 'Avenant congés 2025',
    subtitle: 'Signé le 3 oct. 2025',
    emoji: '📝',
    status: _DocStatus.signe,
    childName: 'Lucas Dupont',
    date: '3 oct. 2025',
  ),
];

const _kReceived = [
  _Document(
    title: 'Attestation Pajemploi',
    subtitle: 'Reçu le 15 fév. 2026',
    emoji: '🧾',
    status: _DocStatus.recu,
    date: '15 fév. 2026',
  ),
  _Document(
    title: 'Avis d\'imposition 2025',
    subtitle: 'Reçu le 10 jan. 2026',
    emoji: '📊',
    status: _DocStatus.recu,
    date: '10 jan. 2026',
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatDocumentsPage extends StatelessWidget {
  const AssMatDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Ajouter un document',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ajout document — à venir'),
                behavior: SnackBarBehavior.floating,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── Header ──────────────────────────────────
          Text('Mes documents',
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w800, fontSize: 28)),
          const SizedBox(height: 4),
          Text('Contrats, autorisations et documents administratifs',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.md),

          // ── RGPD banner ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security_rounded,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vos documents sont stockés de manière sécurisée et conforme au RGPD. Seuls les parties au contrat y ont accès.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryText, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Documents à préparer ─────────────────────
          _DocSection(
            icon: Icons.assignment_outlined,
            iconColor: AppColors.primary,
            title: 'Documents à préparer',
            docs: _kToPrepare,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Documents signés ─────────────────────────
          _DocSection(
            icon: Icons.verified_outlined,
            iconColor: const Color(0xFF155724),
            title: 'Documents signés',
            docs: _kSigned,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Documents reçus ──────────────────────────
          _DocSection(
            icon: Icons.inbox_outlined,
            iconColor: const Color(0xFF4A90D9),
            title: 'Documents reçus',
            docs: _kReceived,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Section ──────────────────────────────────────────────────────────────────

class _DocSection extends StatelessWidget {
  const _DocSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.docs,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<_Document> docs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Text(title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items
          ...docs.map((doc) => _DocTile(doc: doc)).toList(),
        ],
      ),
    );
  }
}

// ─── Document tile ────────────────────────────────────────────────────────────

class _DocTile extends StatelessWidget {
  const _DocTile({required this.doc});
  final _Document doc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => _showDocSheet(context, doc),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 14),
            child: Row(
              children: [
                // Emoji icon in rounded box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Center(
                    child: Text(doc.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doc.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondaryText, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status badge
                _StatusBadge(doc.status),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.secondaryText),
              ],
            ),
          ),
        ),
        const Divider(height: 1, indent: 68),
      ],
    );
  }

  void _showDocSheet(BuildContext context, _Document doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(doc.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.title,
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text(doc.subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                _StatusBadge(doc.status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _SheetAction(
              icon: Icons.visibility_outlined,
              label: 'Voir le document',
              onTap: () => Navigator.pop(context),
            ),
            _SheetAction(
              icon: Icons.download_outlined,
              label: 'Télécharger',
              onTap: () => Navigator.pop(context),
            ),
            if (doc.status == _DocStatus.brouillon)
              _SheetAction(
                icon: Icons.send_outlined,
                label: 'Envoyer pour signature',
                onTap: () => Navigator.pop(context),
                color: AppColors.primary,
              ),
            _SheetAction(
              icon: Icons.delete_outline_rounded,
              label: 'Supprimer',
              onTap: () => Navigator.pop(context),
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final _DocStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      _DocStatus.brouillon => ('Brouillon', AppColors.divider, AppColors.secondaryText),
      _DocStatus.envoye    => ('Envoyé', const Color(0xFFFFF3CD), const Color(0xFF856404)),
      _DocStatus.signe     => ('Signé ✓', const Color(0xFFD4EDDA), const Color(0xFF155724)),
      _DocStatus.recu      => ('Reçu', const Color(0xFFD1ECF1), const Color(0xFF0C5460)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 11),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(
                  color: fg, fontWeight: FontWeight.w600, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Sheet action ─────────────────────────────────────────────────────────────

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryText;
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: c),
      title: Text(label,
          style: AppTextStyles.bodySmall
              .copyWith(color: c, fontWeight: FontWeight.w500)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
