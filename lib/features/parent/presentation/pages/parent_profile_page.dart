import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/data/models/parent_profile_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/child_model.dart';
import '../providers/parent_providers.dart';
import '../widgets/child_profile_card.dart';
import '../widgets/document_vault_card.dart';
import '../widgets/parent_navigation_drawer.dart';
import '../widgets/personal_data_card.dart';
import '../widgets/personal_info_card.dart';
import '../widgets/search_status_card.dart';

/// Écran "Mon profil" du parent.
///
/// Profil parent (`parents/{uid}`) et enfants (`parents/{uid}/children`)
/// chargés depuis Firestore. "Enregistrer le profil" écrit les deux en une
/// seule passe. "Annuler" :
///   - dépile si la page a été pushée (contexte drawer)
///   - réinitialise les champs si la page est un onglet de [IndexedStack]
class ParentProfilePage extends ConsumerStatefulWidget {
  const ParentProfilePage({super.key});

  @override
  ConsumerState<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends ConsumerState<ParentProfilePage> {
  // ── Profil parent ──────────────────────────────────────────────────────────
  bool _isPaused = false;
  bool _profileInitialized = false;
  ParentProfileModel? _loadedProfile;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // ── Enfants ────────────────────────────────────────────────────────────────
  List<ChildModel> _children = [];
  List<String> _deletedChildIds = [];
  bool _childrenInitialized = false;

  /// Incrémenté lors d'un "Annuler" en mode onglet pour forcer la
  /// reconstruction de toutes les [ChildProfileCard] et réinitialiser
  /// leurs contrôleurs internes.
  int _childResetEpoch = 0;

  // ── Global ─────────────────────────────────────────────────────────────────
  bool _saving = false;

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
      title: "Droit à l'image",
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

  // ── Init helpers ───────────────────────────────────────────────────────────

  void _initFromProfile(ParentProfileModel profile) {
    _loadedProfile = profile;
    _firstNameCtrl.text = profile.firstName;
    _lastNameCtrl.text = profile.lastName;
    _phoneCtrl.text = profile.phoneNumber;
    _addressCtrl.text = profile.address;
    _descriptionCtrl.text = profile.familyDescription;
    _isPaused = profile.searchPaused;
    _profileInitialized = true;
  }

  void _initFromChildren(List<ChildModel> children) {
    _children = List.of(children);
    _deletedChildIds = [];
    _childrenInitialized = true;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _cancel() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Contexte onglet : réinitialise tout depuis les dernières valeurs Firestore.
      final email = ref.read(currentUserProvider).valueOrNull?.email ?? '';
      final loadedChildren =
          ref.read(childrenProvider).valueOrNull ?? [];
      setState(() {
        if (_loadedProfile != null) {
          _emailCtrl.text = email;
          _initFromProfile(_loadedProfile!);
        }
        _initFromChildren(loadedChildren);
        _childResetEpoch++; // force la reconstruction des cartes enfants
      });
    }
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      // 1. Profil parent
      await ref.read(authRemoteDataSourceProvider).updateParentProfile(
            uid: user.uid,
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            familyDescription: _descriptionCtrl.text.trim(),
            searchPaused: _isPaused,
          );

      // 2. Enfants : add / update
      final childDs = ref.read(parentRemoteDataSourceProvider);
      for (final child in _children) {
        if (child.id == null) {
          await childDs.addChild(user.uid, child);
        } else {
          await childDs.updateChild(user.uid, child);
        }
      }

      // 3. Enfants supprimés
      for (final id in _deletedChildIds) {
        await childDs.deleteChild(user.uid, id);
      }
      _deletedChildIds.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil enregistré'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
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

  Future<void> _addChildDialog() async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter un enfant'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration:
              const InputDecoration(hintText: "Prénom de l'enfant"),
          onSubmitted: (_) =>
              Navigator.of(ctx).pop(nameCtrl.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(nameCtrl.text.trim()),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    if (name != null && name.isNotEmpty) {
      setState(() => _children.add(ChildModel.create(firstName: name)));
    }
  }

  void _deleteChild(int index) {
    final child = _children[index];
    if (child.id != null) _deletedChildIds.add(child.id!);
    setState(() => _children.removeAt(index));
  }

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(parentProfileProvider);
    final childrenAsync = ref.watch(childrenProvider);
    final email = ref.watch(currentUserProvider).valueOrNull?.email ?? '';

    // Initialise les controllers profil à la première donnée disponible
    if (!_profileInitialized) {
      profileAsync.whenData((profile) {
        if (profile != null) {
          _emailCtrl.text = email;
          _initFromProfile(profile);
        }
      });
    }

    // Initialise la liste enfants à la première donnée disponible
    if (!_childrenInitialized) {
      childrenAsync.whenData(_initFromChildren);
    }

    // Écoute les changements futurs pour mise à jour si non initialisé
    ref.listen<AsyncValue<ParentProfileModel?>>(
      parentProfileProvider,
      (_, next) {
        if (_profileInitialized) return;
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

    ref.listen<AsyncValue<List<ChildModel>>>(
      childrenProvider,
      (_, next) {
        if (_childrenInitialized) return;
        next.whenData((children) {
          if (mounted) setState(() => _initFromChildren(children));
        });
      },
    );

    final isLoading = profileAsync.isLoading || childrenAsync.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ParentNavigationDrawer(),
      body: Builder(
        builder: (scaffoldCtx) => SafeArea(
          child: Column(
            children: [
              _ProfileAppBar(
                  onMenuTap: () => Scaffold.of(scaffoldCtx).openDrawer()),
              Expanded(
                child: isLoading && !_profileInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : profileAsync.hasError
                        ? Center(
                            child: Text(
                              'Impossible de charger le profil.\n${profileAsync.error}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.error),
                            ),
                          )
                        : _buildContent(),
              ),
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

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mon profil', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gérez votre profil familial',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Informations personnelles + description ─────────────────────
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

          // ── Statut de recherche ─────────────────────────────────────────
          SearchStatusCard(
            isPaused: _isPaused,
            onChanged: (v) => setState(() => _isPaused = v),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Enfants ─────────────────────────────────────────────────────
          for (int i = 0; i < _children.length; i++) ...[
            ChildProfileCard(
              // La clé change à chaque _childResetEpoch pour forcer la
              // reconstruction des contrôleurs internes de la carte.
              key: ValueKey(
                  '${_children[i].id ?? 'new-$i'}_$_childResetEpoch'),
              child: _children[i],
              onChanged: (updated) =>
                  setState(() => _children[i] = updated),
              onDelete: () => _deleteChild(i),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Ajouter un enfant ───────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: _addChildDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Ajouter un enfant'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Coffre-fort numérique ───────────────────────────────────────
          DocumentVaultCard(
            documents: _documents,
            onDocumentTap: (d) => _stub(d.title),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Données personnelles (RGPD) ─────────────────────────────────
          PersonalDataCard(
            onDownload: () => _stub('Télécharger mes données'),
            onDelete: _confirmDeleteAccount,
            onPrivacyPolicy: () => _stub('Politique de confidentialité'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
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
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                size: 28, color: AppColors.primaryText),
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
                child: const Icon(Icons.child_care_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('AMiLY',
                  style: AppTextStyles.titleLarge
                      .copyWith(fontWeight: FontWeight.w800)),
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
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm),
                ),
                child: const Text('Annuler',
                    maxLines: 1, overflow: TextOverflow.visible),
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
                label: const Text('Enregistrer le profil',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
