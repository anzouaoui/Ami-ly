import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Page "Documents" — contrats et documents administratifs.
///
/// Frames "Documents" + "Documents 2" du design system. Affiche :
///   - Deux info cards (RGPD vert / pas de contrat jaune)
///   - Liste de 8 documents à préparer avec badge "Brouillon"
///
/// Toutes les données sont mockées, les taps déclenchent un SnackBar.
class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  static const _documents = <_DocumentData>[
    _DocumentData(
      icon: Icons.assignment_rounded,
      iconBg: Color(0xFFE3F2FD),
      iconColor: Color(0xFF2196F3),
      title: 'Contrat de garde',
      subtitle: 'Contrat d\'accueil de l\'enfant',
    ),
    _DocumentData(
      icon: Icons.vaccines_rounded,
      iconBg: Color(0xFFFFEBEE),
      iconColor: Color(0xFFE53935),
      title: 'Copie vaccinations',
      subtitle: 'Photos du carnet de santé',
    ),
    _DocumentData(
      icon: Icons.photo_camera_rounded,
      iconBg: Color(0xFFF3E5F5),
      iconColor: Color(0xFF9C27B0),
      title: 'Autorisation droit à l\'image',
      subtitle: 'Autorisation parentale',
    ),
    _DocumentData(
      icon: Icons.local_hospital_rounded,
      iconBg: Color(0xFFE8F5E9),
      iconColor: Color(0xFF43A047),
      title: 'Fiche santé enfant',
      subtitle: 'Informations médicales',
    ),
    _DocumentData(
      icon: Icons.medication_rounded,
      iconBg: Color(0xFFFFF3E0),
      iconColor: Color(0xFFFB8C00),
      title: 'Autorisation administration soins',
      subtitle: 'Autorisation d\'administration',
    ),
    _DocumentData(
      icon: Icons.groups_rounded,
      iconBg: Color(0xFFE0F7FA),
      iconColor: Color(0xFF00897B),
      title: 'Autorisation départ',
      subtitle: 'Personnes autorisées',
    ),
    _DocumentData(
      icon: Icons.park_rounded,
      iconBg: Color(0xFFF1F8E9),
      iconColor: Color(0xFF689F38),
      title: 'Autorisation activités',
      subtitle: 'Autorisation pour les sorties',
    ),
    _DocumentData(
      icon: Icons.directions_car_rounded,
      iconBg: Color(0xFFEDE7F6),
      iconColor: Color(0xFF5E35B1),
      title: 'Autorisation transport',
      subtitle: 'Autorisation de transport',
    ),
  ];

  void _onTap(BuildContext context, _DocumentData doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${doc.title} — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Text(
                  'Contrats, autorisations et documents administratifs',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),

              // Info cards
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _InfoCard(
                  icon: Icons.shield_rounded,
                  iconColor: AppColors.primary,
                  bgColor: AppColors.secondary,
                  borderColor: AppColors.primary,
                  text:
                      'Vos documents sont stockés de manière sécurisée et conformément au RGPD. Seuls les parties au contrat y ont accès.',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _InfoCard(
                  icon: Icons.notifications_active_rounded,
                  iconColor: AppColors.accent,
                  bgColor: AppColors.statYellowBg,
                  borderColor: AppColors.accent,
                  text:
                      'Aucun contrat actif pour le moment. Vous pouvez consulter et préparer vos documents en avance.',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Documents list card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _DocumentsListCard(
                  documents: _documents,
                  onTap: (doc) => _onTap(context, doc),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header : back + logo "AMiLY" + spacer.
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

/// Carte d'information teintée (RGPD en vert, alerte en jaune).
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

/// Grande carte blanche contenant le titre "Documents à préparer" + liste.
class _DocumentsListCard extends StatelessWidget {
  const _DocumentsListCard({
    required this.documents,
    required this.onTap,
  });

  final List<_DocumentData> documents;
  final ValueChanged<_DocumentData> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.description_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Documents à préparer',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Liste
          for (var i = 0; i < documents.length; i++) ...[
            _DocumentRow(
              doc: documents[i],
              onTap: () => onTap(documents[i]),
            ),
            if (i < documents.length - 1)
              const Divider(
                height: AppSpacing.md,
                color: AppColors.divider,
              ),
          ],
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.doc, required this.onTap});
  final _DocumentData doc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: doc.iconBg,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              alignment: Alignment.center,
              child: Icon(doc.icon, color: doc.iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    doc.subtitle,
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
            const _DraftBadge(),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pastille "Brouillon" (gris clair + petit icône document).
class _DraftBadge extends StatelessWidget {
  const _DraftBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 14,
            color: AppColors.secondaryText,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Brouillon',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Données d'une ligne document (mock UI).
class _DocumentData {
  const _DocumentData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
}
