import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/child_profile_card.dart';
import '../widgets/document_vault_card.dart';
import '../widgets/family_description_section.dart';
import '../widgets/personal_data_card.dart';
import '../widgets/personal_info_card.dart';
import '../widgets/search_status_card.dart';

/// Écran "Mon profil" du parent, composition des frames Parent Profile 1→6
/// du design system.
///
/// Sections (de haut en bas) :
///   - Header (menu + logo centré, sans notifications)
///   - Titre "Mon profil" + sous-titre
///   - Informations personnelles (avatar + form)
///   - Search Status (toggle "Ne recherche plus")
///   - Description de la famille (textarea + compteur)
///   - Cartes enfants (Lucas, Chloé) + bouton "Ajouter un enfant"
///   - Coffre-fort numérique (liste documents signés)
///   - Mes données personnelles (RGPD + actions)
///   - Bottom action bar fixe : Annuler / Enregistrer le profil
///
/// 100% mock UI pour l'instant — aucune donnée n'est persistée. Les
/// boutons stubs affichent un SnackBar.
class ParentProfilePage extends ConsumerStatefulWidget {
  const ParentProfilePage({super.key});

  @override
  ConsumerState<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends ConsumerState<ParentProfilePage> {
  // État local mocké (design preview uniquement).
  bool _isPaused = true;

  final List<ChildProfileData> _children = [
    const ChildProfileData(
      name: 'Lucas',
      age: '2 ans',
      description:
          'Lucas est un petit garçon très curieux et plein d\'énergie.',
      interests: ['Peinture', 'Jeux de construction', 'Histoires', 'Parc'],
    ),
    const ChildProfileData(
      name: 'Chloé',
      age: '6 mois',
      description: 'Chloé est une petite fille calme et souriante.',
      interests: [],
    ),
  ];

  static final _documents = <DocumentEntry>[
    DocumentEntry(
      title: 'Fiche de paie — Mars',
      subtitle: 'Signé le 05/03/2026 • Sophie Dupont',
      icon: Icons.receipt_long_rounded,
      iconBg: AppColors.parentIconBg,
      iconColor: AppColors.primary,
    ),
    DocumentEntry(
      title: 'Fiche de paie — Avril',
      subtitle: 'Signé le 05/04/2026 • Sophie Dupont',
      icon: Icons.receipt_long_rounded,
      iconBg: AppColors.parentIconBg,
      iconColor: AppColors.primary,
    ),
    DocumentEntry(
      title: 'Droit à l\'image',
      subtitle: 'Signé le 01/09/2025 • Sophie Dupont',
      icon: Icons.visibility_rounded,
      iconBg: AppColors.statBlueBg,
      iconColor: AppColors.statBlueColor,
    ),
    DocumentEntry(
      title: 'Autorisation de sortie',
      subtitle: 'Signé le 01/09/2025 • Sophie Dupont',
      icon: Icons.verified_user_rounded,
      iconBg: AppColors.secondary,
      iconColor: AppColors.primary,
    ),
    DocumentEntry(
      title: 'Fiche santé',
      subtitle: 'Signé le 01/09/2025 • Sophie Dupont',
      icon: Icons.medical_services_rounded,
      iconBg: AppColors.secondary,
      iconColor: AppColors.primary,
    ),
    DocumentEntry(
      title: 'Carnet de vaccination',
      subtitle: 'Signé le 01/09/2025 • Sophie Dupont',
      icon: Icons.vaccines_rounded,
      iconBg: AppColors.secondary,
      iconColor: AppColors.primary,
    ),
    DocumentEntry(
      title: 'Contrat de garde',
      subtitle: 'Signé le 15/01/2026 • Sophie Dupont, Marie Lefèvre',
      icon: Icons.description_rounded,
      iconBg: AppColors.divider,
      iconColor: AppColors.secondaryText,
    ),
    DocumentEntry(
      title: 'Droit à l\'image — bis',
      subtitle: 'Signé le 15/01/2026 • Sophie Dupont',
      icon: Icons.visibility_rounded,
      iconBg: AppColors.statBlueBg,
      iconColor: AppColors.statBlueColor,
    ),
  ];

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
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
            const _ProfileAppBar(),

            // ---- Scrollable content ----
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text('Mon profil', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Gérez votre profil familial',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Personal info
                    PersonalInfoCard(
                      firstName: 'Sophie',
                      lastName: 'Dupont',
                      phone: '06 98 76 54 32',
                      email: 'sophie.dupont@email.com',
                      address: '25 rue de Vaugirard, 75015 Paris',
                      onChangePhoto: () => _stub('Changer la photo'),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Search status toggle
                    SearchStatusCard(
                      isPaused: _isPaused,
                      onChanged: (v) => setState(() => _isPaused = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Family description
                    const FamilyDescriptionSection(
                      initialValue:
                          'Nous sommes une famille bienveillante et attentive. Nous recherchons un environnement chaleureux et stimulant pour nos enfants avec des activités d\'éveil.',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Children
                    for (final child in _children) ...[
                      ChildProfileCard(
                        child: child,
                        onRemove: () => _removeChild(child),
                        onAddInterest: () => _stub('Ajouter un centre d\'intérêt'),
                        onRemoveInterest: (tag) => _removeInterest(child, tag),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // "+ Ajouter un enfant"
                    OutlinedButton.icon(
                      onPressed: () => _stub('Ajouter un enfant'),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Ajouter un enfant'),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Document vault
                    DocumentVaultCard(
                      documents: _documents,
                      onDocumentTap: (d) => _stub(d.title),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Personal data (RGPD)
                    PersonalDataCard(
                      onDownload: () => _stub('Télécharger mes données'),
                      onDelete: _confirmDeleteAccount,
                      onPrivacyPolicy: () => _stub('Politique de confidentialité'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),

            // ---- Bottom action bar fixe ----
            _BottomActionBar(
              onCancel: () => Navigator.of(context).maybePop(),
              onSave: () {
                _stub('Profil enregistré');
                Navigator.of(context).maybePop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeChild(ChildProfileData child) {
    setState(() => _children.remove(child));
  }

  void _removeInterest(ChildProfileData child, String tag) {
    setState(() {
      final idx = _children.indexOf(child);
      if (idx == -1) return;
      _children[idx] = ChildProfileData(
        name: child.name,
        age: child.age,
        description: child.description,
        interests: List.of(child.interests)..remove(tag),
      );
    });
  }

  Future<void> _confirmDeleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront effacées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) _stub('Compte supprimé');
  }
}

/// Header custom : menu + logo AMiLY centré (pas de notifications ici).
class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();

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
          // Logo centré
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
          // Balance pour centrer visuellement le logo
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

/// Barre d'actions fixe en bas de page : Annuler / Enregistrer.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.onCancel, required this.onSave});
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                child: const Text(
                  'Annuler',
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text(
                  'Enregistrer le profil',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
