import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/data/models/parent_profile_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/child_profile_card.dart';
import '../widgets/parent_navigation_drawer.dart';
import '../widgets/document_vault_card.dart';
import '../widgets/personal_info_card.dart';
import '../widgets/personal_data_card.dart';
import '../widgets/search_status_card.dart';

/// Écran "Mon profil" du parent, composition des frames Parent Profile 1→6
/// du design system.
///
/// Lit le profil depuis Firestore via [parentProfileProvider].
/// Les champs sont édités via des [TextEditingController]s initialisés à la
/// première émission du stream. "Enregistrer" appelle [updateParentProfile]
/// sur le datasource et affiche un SnackBar de confirmation.
class ParentProfilePage extends ConsumerStatefulWidget {
  const ParentProfilePage({super.key});

  @override
  ConsumerState<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends ConsumerState<ParentProfilePage> {
  bool _isPaused = false;
  bool _initialized = false;
  bool _saving = false;

  /// Dernière valeur Firestore connue, utilisée pour réinitialiser les
  /// champs quand "Annuler" est pressé dans le contexte onglet (pas de
  /// route à dépiler).
  ParentProfileModel? _loadedProfile;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

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

  static const _documents = <DocumentEntry>[
    DocumentEntry(
      title: 'Fiche de paie — Mars',
      subtitle: 'Signé le 05/03/2026',
      icon: Icons.receipt_long_rounded,
      iconBg: AppColors.parentIconBg,
      iconColor: AppColors.primary,
    ),
    DocumentEntry(
      title: 'Fiche de paie — Avril',
      subtitle: 'Signé le 05/04/2026',
      icon: Icons.receipt_long_rounded,
      iconBg: AppColors.parentIconBg,
      iconColor: AppColors.primary,
    ),
    DocumentEntry(
      title: 'Droit à l\'image',
      subtitle: 'Signé le 01/09/2025',
      icon: Icons.visibility_rounded,
      iconBg: AppColors.statBlueBg,
      iconColor: AppColors.statBlueColor,
    ),
    DocumentEntry(
      title: 'Autorisation de sortie',
      subtitle: 'Signé le 01/09/2025',
      icon: Icons.verified_user_rounded,
      iconBg: AppColors.secondary,
      iconColor: AppColors.primary,
    ),
    DocumentEntry(
      title: 'Contrat de garde',
      subtitle: 'Signé le 15/01/2026',
      icon: Icons.description_rounded,
      iconBg: AppColors.divider,
      iconColor: AppColors.secondaryText,
    ),
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _initFromProfile(ParentProfileModel profile) {
    _loadedProfile = profile;
    _firstNameCtrl.text = profile.firstName;
    _lastNameCtrl.text = profile.lastName;
    _phoneCtrl.text = profile.phoneNumber;
    _addressCtrl.text = profile.address;
    _descriptionCtrl.text = profile.familyDescription;
    _isPaused = profile.searchPaused;
    _initialized = true;
  }

  /// "Annuler" : dépile la page si elle a été poussée via Navigator (ex :
  /// ouverture depuis le drawer). Si la page est un onglet de l'IndexedStack
  /// (aucune route parente à dépiler), réinitialise les champs à la dernière
  /// valeur Firestore sans quitter la page.
  void _cancel() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (_loadedProfile != null) {
      final email = ref.read(currentUserProvider).valueOrNull?.email ?? '';
      setState(() {
        _emailCtrl.text = email;
        _initFromProfile(_loadedProfile!);
      });
    }
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      await ref.read(authRemoteDataSourceProvider).updateParentProfile(
            uid: user.uid,
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            familyDescription: _descriptionCtrl.text.trim(),
            searchPaused: _isPaused,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil enregistré'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
    final profileAsync = ref.watch(parentProfileProvider);
    final email = ref.watch(currentUserProvider).valueOrNull?.email ?? '';

    // Initialise les controllers à la première donnée disponible.
    // Si le stream a déjà émis (cache), on le fait synchronement ici ;
    // sinon ref.listen l'attrape dès la prochaine émission.
    if (!_initialized) {
      profileAsync.whenData((profile) {
        if (profile != null) {
          _emailCtrl.text = email;
          _initFromProfile(profile);
        }
      });
    }

    ref.listen<AsyncValue<ParentProfileModel?>>(
      parentProfileProvider,
      (_, next) {
        if (_initialized) return;
        next.whenData((profile) {
          if (profile != null && mounted) {
            setState(() {
              _emailCtrl.text = email;
              _initFromProfile(profile);
            });
          }
        });
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ParentNavigationDrawer(),
      body: Builder(
        builder: (scaffoldCtx) => SafeArea(
          child: Column(
            children: [
              _ProfileAppBar(
                  onMenuTap: () => Scaffold.of(scaffoldCtx).openDrawer()),

              // ---- Scrollable content ----
              Expanded(
                child: profileAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Text(
                      'Impossible de charger le profil.\n$err',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                  data: (_) => SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text('Mon profil',
                            style: AppTextStyles.headlineMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Gérez votre profil familial',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Personal info + family description
                        PersonalInfoCard(
                          firstName: _firstNameCtrl.text,
                          lastName: _lastNameCtrl.text,
                          phone: _phoneCtrl.text,
                          email: _emailCtrl.text,
                          address: _addressCtrl.text,
                          firstNameController: _firstNameCtrl,
                          lastNameController: _lastNameCtrl,
                          phoneController: _phoneCtrl,
                          emailController: _emailCtrl,
                          addressController: _addressCtrl,
                          descriptionController: _descriptionCtrl,
                          descriptionLabel: 'Description de la famille',
                          descriptionHint:
                              'Ex : Famille de 4 personnes, nous recherchons une assistante attentionnée…',
                          onChangePhoto: () => _stub('Changer la photo'),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Search status toggle
                        SearchStatusCard(
                          isPaused: _isPaused,
                          onChanged: (v) => setState(() => _isPaused = v),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Children
                        for (final child in _children) ...[
                          ChildProfileCard(
                            child: child,
                            onRemove: () => _removeChild(child),
                            onAddInterest: () =>
                                _stub('Ajouter un centre d\'intérêt'),
                            onRemoveInterest: (tag) =>
                                _removeInterest(child, tag),
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
                          onDownload: () =>
                              _stub('Télécharger mes données'),
                          onDelete: _confirmDeleteAccount,
                          onPrivacyPolicy: () =>
                              _stub('Politique de confidentialité'),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),

              // ---- Bottom action bar fixe ----
              _BottomActionBar(
                saving: _saving,
                onCancel: _cancel,
                onSave: _saving ? null : _save,
              ),
            ],
          ),
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

// ─── App bar ─────────────────────────────────────────────────────────────────

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({required this.onMenuTap});
  final VoidCallback onMenuTap;

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
              Icons.menu_rounded,
              size: 28,
              color: AppColors.primaryText,
            ),
            onPressed: onMenuTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Menu',
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
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

// ─── Bottom action bar ────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onCancel,
    required this.onSave,
    this.saving = false,
  });
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
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
                onPressed: saving ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
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
