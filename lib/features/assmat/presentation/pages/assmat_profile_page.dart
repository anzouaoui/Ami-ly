import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/address_suggestion.dart';
import '../../../../shared/widgets/address_autocomplete_field.dart';
import '../../../auth/data/models/assmat_profile_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../parent/presentation/widgets/document_vault_card.dart';
import '../../../parent/presentation/widgets/filter_checkbox_tile.dart';
import '../../../parent/presentation/widgets/profile_form_field.dart';
import '../../../parent/presentation/widgets/personal_info_card.dart';
import 'assmat_home_page.dart';

/// Page "Mon profil" de l'Assistante Maternelle.
class AssMatProfilePage extends ConsumerStatefulWidget {
  const AssMatProfilePage({super.key});

  @override
  ConsumerState<AssMatProfilePage> createState() => _AssMatProfilePageState();
}

class _AssMatProfilePageState extends ConsumerState<AssMatProfilePage> {
  // ── Contrôleurs texte ──────────────────────────────────────────────────────
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  // Ville seule, extraite de l'adresse sélectionnée — c'est elle (et non
  // l'adresse complète) qui est affichée aux parents dans la liste.
  String _city = '';
  final _bioCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _maxChildrenCtrl = TextEditingController();
  final _availableSlotsCtrl = TextEditingController();
  final _parcoursProCtrl = TextEditingController();
  final _accreditationNumberCtrl = TextEditingController();
  final _pmiCodeCtrl = TextEditingController();
  final _contactPmiNameCtrl = TextEditingController();
  final _contactPmiPhoneCtrl = TextEditingController();
  final _contactRpeNameCtrl = TextEditingController();
  final _contactRpePhoneCtrl = TextEditingController();
  final _contactAntipoisonPhoneCtrl = TextEditingController();
  final _contactTiersNameCtrl = TextEditingController();
  final _contactTiersPhoneCtrl = TextEditingController();
  final _emergencyPhoneCustomCtrl = TextEditingController();

  // ── État booléen / géoloc / disponibilité ─────────────────────────────────
  bool _isSearchable = true;
  GeoPoint? _location;
  bool _locationCleared = false;
  DateTime _availableFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);

  // ── Services & horaires (wirés Firestore) ──────────────────────────────────
  final Map<String, bool> _services = {
    'Exerce en maison d\'assistants maternels': false,
    'Peut accueillir des enfants en situation de handicap': false,
    'Peut véhiculer les enfants': false,
    'Peut fournir des produits d\'hygiène': false,
    'Peut fournir les repas': false,
  };

  final Map<String, bool> _schedules = {
    'Peut être flexible sur les horaires': false,
    'Peut accueillir les enfants la nuit': false,
    'Peut accueillir les enfants le week-end': false,
    'Peut accueillir les enfants les jours fériés': false,
    'Travaille pendant les vacances scolaires': false,
    'Peut répondre aux accueils d\'urgence': false,
  };

  // Nouveaux états réels
  String _tobacco = 'Non fumeur';
  String _firstAid = 'PSC1 validé';
  String _pet = 'Pas d\'animal';
  List<String> _diplomas = [];
  List<String> _specialities = [];
  List<String> _homePhotos = [];
  DateTime? _accreditationExpiry;
  String? _accreditationPhotoUrl;
  bool _isAccreditationCertified = true;
  bool _isIdentityVerified = false;
  DateTime? _identityVerifiedAt;

  // ── Cycle de vie ──────────────────────────────────────────────────────────
  bool _initialized = false;
  AssmatProfileModel? _loadedProfile;
  bool _saving = false;
  String? _photoUrl;
  bool _uploadingPhoto = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    _maxChildrenCtrl.dispose();
    _availableSlotsCtrl.dispose();
    _parcoursProCtrl.dispose();
    _accreditationNumberCtrl.dispose();
    _pmiCodeCtrl.dispose();
    _contactPmiNameCtrl.dispose();
    _contactPmiPhoneCtrl.dispose();
    _contactRpeNameCtrl.dispose();
    _contactRpePhoneCtrl.dispose();
    _contactAntipoisonPhoneCtrl.dispose();
    _contactTiersNameCtrl.dispose();
    _contactTiersPhoneCtrl.dispose();
    _emergencyPhoneCustomCtrl.dispose();
    super.dispose();
  }

  // ── Init helpers ───────────────────────────────────────────────────────────

  void _initFromProfile(AssmatProfileModel profile, String email) {
    _loadedProfile = profile;
    _firstNameCtrl.text = profile.firstName;
    _lastNameCtrl.text = profile.lastName;
    _addressCtrl.text = profile.address;
    _city = profile.city;
    _bioCtrl.text = profile.bio;
    _emailCtrl.text = email;
    _maxChildrenCtrl.text = profile.maxChildren.toString();
    _availableSlotsCtrl.text = profile.availableSlots.toString();
    _isSearchable = profile.isSearchable;
    _location = profile.location;
    _locationCleared = false;
    _photoUrl = profile.photoUrl;
    if (profile.availableFrom != null) {
      _availableFrom = profile.availableFrom!;
    }
    for (final key in _services.keys) {
      _services[key] = profile.services.contains(key);
    }
    for (final key in _schedules.keys) {
      _schedules[key] = profile.schedules.contains(key);
    }

    // Nouveaux champs
    _tobacco = profile.tobacco;
    _firstAid = profile.firstAid;
    _pet = profile.pet;
    _diplomas = List<String>.from(profile.diplomas);
    _parcoursProCtrl.text = profile.parcoursProfessionnel;
    _accreditationNumberCtrl.text = profile.accreditationNumber;
    _accreditationExpiry = profile.accreditationExpiry;
    _accreditationPhotoUrl = profile.accreditationPhotoUrl;
    _pmiCodeCtrl.text = profile.pmiCode;
    _isAccreditationCertified = profile.isAccreditationCertified;
    _specialities = List<String>.from(profile.specialities);
    _contactPmiNameCtrl.text = profile.contactPmiName;
    _contactPmiPhoneCtrl.text = profile.contactPmiPhone;
    _contactRpeNameCtrl.text = profile.contactRpeName;
    _contactRpePhoneCtrl.text = profile.contactRpePhone;
    _contactAntipoisonPhoneCtrl.text = profile.contactAntipoisonPhone;
    _contactTiersNameCtrl.text = profile.contactTiersName;
    _contactTiersPhoneCtrl.text = profile.contactTiersPhone;
    _emergencyPhoneCustomCtrl.text = profile.emergencyPhoneCustom;
    _isIdentityVerified = profile.isIdentityVerified;
    _identityVerifiedAt = profile.identityVerifiedAt;
    _homePhotos = List<String>.from(profile.homePhotos);

    _initialized = true;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _cancel() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      final email = ref.read(currentUserProvider).valueOrNull?.email ?? '';
      if (_loadedProfile != null) {
        setState(() => _initFromProfile(_loadedProfile!, email));
      }
    }
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final savedMaxChildren = int.tryParse(_maxChildrenCtrl.text.trim()) ??
          (_loadedProfile?.maxChildren ?? 1);
      final savedAvailableSlots =
          int.tryParse(_availableSlotsCtrl.text.trim()) ??
              (_loadedProfile?.availableSlots ?? 0);

      await ref.read(authRemoteDataSourceProvider).updateAssmatProfile(
            uid: user.uid,
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            city: _city.trim(),
            bio: _bioCtrl.text.trim(),
            isSearchable: _isSearchable,
            maxChildren: savedMaxChildren,
            availableSlots: savedAvailableSlots,
            services: _services.entries
                .where((e) => e.value)
                .map((e) => e.key)
                .toList(),
            schedules: _schedules.entries
                .where((e) => e.value)
                .map((e) => e.key)
                .toList(),
            location: _location,
            clearLocation: _locationCleared,
            availableFrom: _isSearchable ? _availableFrom : null,
            clearAvailableFrom: !_isSearchable,
            // Nouveaux champs
            tobacco: _tobacco,
            firstAid: _firstAid,
            pet: _pet,
            diplomas: _diplomas,
            parcoursProfessionnel: _parcoursProCtrl.text.trim(),
            accreditationNumber: _accreditationNumberCtrl.text.trim(),
            accreditationExpiry: _accreditationExpiry,
            clearAccreditationExpiry: _accreditationExpiry == null,
            accreditationPhotoUrl: _accreditationPhotoUrl,
            clearAccreditationPhotoUrl: _accreditationPhotoUrl == null,
            pmiCode: _pmiCodeCtrl.text.trim(),
            isAccreditationCertified: _isAccreditationCertified,
            specialities: _specialities,
            contactPmiName: _contactPmiNameCtrl.text.trim(),
            contactPmiPhone: _contactPmiPhoneCtrl.text.trim(),
            contactRpeName: _contactRpeNameCtrl.text.trim(),
            contactRpePhone: _contactRpePhoneCtrl.text.trim(),
            contactAntipoisonPhone: _contactAntipoisonPhoneCtrl.text.trim(),
            contactTiersName: _contactTiersNameCtrl.text.trim(),
            contactTiersPhone: _contactTiersPhoneCtrl.text.trim(),
            emergencyPhoneCustom: _emergencyPhoneCustomCtrl.text.trim(),
            homePhotos: _homePhotos,
          );

      _loadedProfile = _loadedProfile?.copyWith(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _city.trim(),
        bio: _bioCtrl.text.trim(),
        isSearchable: _isSearchable,
        maxChildren: savedMaxChildren,
        availableSlots: savedAvailableSlots,
        location: _locationCleared ? null : _location,
        clearLocation: _locationCleared,
        availableFrom: _isSearchable ? _availableFrom : null,
        clearAvailableFrom: !_isSearchable,
        tobacco: _tobacco,
        firstAid: _firstAid,
        pet: _pet,
        diplomas: _diplomas,
        parcoursProfessionnel: _parcoursProCtrl.text.trim(),
        accreditationNumber: _accreditationNumberCtrl.text.trim(),
        accreditationExpiry: _accreditationExpiry,
        clearAccreditationExpiry: _accreditationExpiry == null,
        accreditationPhotoUrl: _accreditationPhotoUrl,
        clearAccreditationPhotoUrl: _accreditationPhotoUrl == null,
        pmiCode: _pmiCodeCtrl.text.trim(),
        isAccreditationCertified: _isAccreditationCertified,
        specialities: _specialities,
        contactPmiName: _contactPmiNameCtrl.text.trim(),
        contactPmiPhone: _contactPmiPhoneCtrl.text.trim(),
        contactRpeName: _contactRpeNameCtrl.text.trim(),
        contactRpePhone: _contactRpePhoneCtrl.text.trim(),
        contactAntipoisonPhone: _contactAntipoisonPhoneCtrl.text.trim(),
        contactTiersName: _contactTiersNameCtrl.text.trim(),
        contactTiersPhone: _contactTiersPhoneCtrl.text.trim(),
        emergencyPhoneCustom: _emergencyPhoneCustomCtrl.text.trim(),
        homePhotos: _homePhotos,
      );
      _locationCleared = false;

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

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final ds = ref.read(authRemoteDataSourceProvider);
      final url = await ds.uploadAssmatPhoto(user.uid, File(picked.path));
      await ds.updateAssmatPhotoUrl(user.uid, url);
      if (mounted) {
        setState(() => _photoUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo mise à jour'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _changeAccreditationPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final ds = ref.read(authRemoteDataSourceProvider);
      final url = await ds.uploadAccreditationPhoto(user.uid, File(picked.path));
      if (mounted) {
        setState(() => _accreditationPhotoUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Photo de l'agrément mise à jour"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addHomePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final ds = ref.read(authRemoteDataSourceProvider);
      final url = await ds.uploadHomePhoto(user.uid, File(picked.path));
      if (mounted) {
        setState(() {
          _homePhotos.add(url);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Photo du domicile ajoutée"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _removeHomePhoto(String url) {
    setState(() {
      _homePhotos.remove(url);
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(assmatProfileProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final email = currentUser?.email ?? '';
    final userUid = currentUser?.uid ?? '';

    if (!_initialized) {
      profileAsync.whenData((profile) {
        if (profile != null) _initFromProfile(profile, email);
      });
    }

    ref.listen<AsyncValue<AssmatProfileModel?>>(
      assmatProfileProvider,
      (_, next) {
        if (_initialized) return;
        next.whenData((profile) {
          if (profile != null && mounted) {
            setState(() => _initFromProfile(profile, email));
          }
        });
      },
    );

    final isLoading = profileAsync.isLoading && !_initialized;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AssMatDrawer(),
      body: Builder(
        builder: (scaffoldCtx) => SafeArea(
          child: Column(
            children: [
              _ProfileHeader(
                  onMenuTap: () => Scaffold.of(scaffoldCtx).openDrawer()),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : profileAsync.hasError
                        ? Center(
                            child: Text(
                              'Impossible de charger le profil.\n'
                              '${profileAsync.error}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.error),
                            ),
                          )
                        : _buildContent(userUid),
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

  Widget _buildContent(String userUid) {
    final availableSlots =
        int.tryParse(_availableSlotsCtrl.text) ??
        (_loadedProfile?.availableSlots ?? 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleSection(onPassPro: () => _stub('Passer à Pro')),
          const SizedBox(height: AppSpacing.lg),

          _StatusChips(
            availableSlots: availableSlots,
            isSearchable: _isSearchable,
          ),
          const SizedBox(height: AppSpacing.lg),

          PersonalInfoCard(
            firstName: _firstNameCtrl.text,
            lastName: _lastNameCtrl.text,
            phone: '',
            email: _emailCtrl.text,
            address: _addressCtrl.text,
            photoUrl: _photoUrl,
            uploadingPhoto: _uploadingPhoto,
            firstNameController: _firstNameCtrl,
            lastNameController: _lastNameCtrl,
            emailController: _emailCtrl,
            descriptionController: _bioCtrl,
            descriptionLabel: 'Description / Présentation',
            descriptionHint:
                'Parlez-nous de votre expérience et de votre cadre d\'accueil…',
            onChangePhoto: _changePhoto,
            avatarBg: AppColors.secondary,
            avatarFg: AppColors.primary,
            addressWidget: AddressAutocompleteField(
              controller: _addressCtrl,
              label: 'Adresse',
              onSelected: (AddressSuggestion s) => setState(() {
                _location = GeoPoint(s.lat, s.lon);
                _locationCleared = false;
                _city = s.city ?? '';
              }),
              onClearLocation: () => setState(() {
                _location = null;
                _locationCleared = true;
                _city = '';
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _AvailabilityCard(
            isAvailable: _isSearchable,
            availableFrom: _availableFrom,
            onAvailabilityChanged: (v) => setState(() => _isSearchable = v),
            onAvailableFromChanged: (d) => setState(() => _availableFrom = d),
          ),
          const SizedBox(height: AppSpacing.lg),

          _PracticalInfoCard(
            maxChildrenController: _maxChildrenCtrl,
            availableSlotsController: _availableSlotsCtrl,
            tobacco: _tobacco,
            firstAid: _firstAid,
            pet: _pet,
            onTobaccoChanged: (v) => setState(() => _tobacco = v ?? _tobacco),
            onFirstAidChanged: (v) => setState(() => _firstAid = v ?? _firstAid),
            onPetChanged: (v) => setState(() => _pet = v ?? _pet),
          ),
          const SizedBox(height: AppSpacing.lg),

          _ChecklistCard(
            icon: Icons.volunteer_activism_rounded,
            title: 'Services proposés',
            subtitle: 'Indiquez les services que vous proposez aux familles',
            items: _services,
            onChanged: (k, v) => setState(() => _services[k] = v),
          ),
          const SizedBox(height: AppSpacing.lg),

          _ChecklistCard(
            icon: Icons.access_time_rounded,
            title: 'Horaires & Flexibilité',
            subtitle: 'Précisez vos disponibilités horaires',
            items: _schedules,
            onChanged: (k, v) => setState(() => _schedules[k] = v),
          ),
          const SizedBox(height: AppSpacing.lg),

          _DiplomasCard(
            diplomas: _diplomas,
            parcoursProController: _parcoursProCtrl,
            onAddDiploma: (d) => setState(() => _diplomas.add(d)),
            onRemoveDiploma: (d) => setState(() => _diplomas.remove(d)),
          ),
          const SizedBox(height: AppSpacing.lg),

          _HomePhotosCard(
            homePhotos: _homePhotos,
            onAddPhoto: _addHomePhoto,
            onRemovePhoto: _removeHomePhoto,
          ),
          const SizedBox(height: AppSpacing.lg),

          _AccreditationCard(
            accreditationNumberController: _accreditationNumberCtrl,
            accreditationExpiry: _accreditationExpiry,
            onAccreditationExpiryChanged: (d) => setState(() => _accreditationExpiry = d),
            accreditationPhotoUrl: _accreditationPhotoUrl,
            onChangePhoto: _changeAccreditationPhoto,
            pmiCodeController: _pmiCodeCtrl,
            isCertified: _isAccreditationCertified,
            onCertifiedChanged: (v) => setState(() => _isAccreditationCertified = v),
          ),
          const SizedBox(height: AppSpacing.lg),

          _ImportantContactsCard(
            contactPmiNameController: _contactPmiNameCtrl,
            contactPmiPhoneController: _contactPmiPhoneCtrl,
            contactRpeNameController: _contactRpeNameCtrl,
            contactRpePhoneController: _contactRpePhoneCtrl,
            contactAntipoisonPhoneController: _contactAntipoisonPhoneCtrl,
            contactTiersNameController: _contactTiersNameCtrl,
            contactTiersPhoneController: _contactTiersPhoneCtrl,
            emergencyPhoneCustomController: _emergencyPhoneCustomCtrl,
          ),
          const SizedBox(height: AppSpacing.lg),

          _IdentityVerificationCard(
            isVerified: _isIdentityVerified,
            verifiedAt: _identityVerifiedAt,
          ),
          const SizedBox(height: AppSpacing.lg),

          _SpecialitiesCard(
            tags: _specialities,
            onAddTag: (tag) => setState(() => _specialities.add(tag)),
            onRemoveTag: (tag) => setState(() => _specialities.remove(tag)),
          ),
          const SizedBox(height: AppSpacing.lg),

          _SignedContractsVault(userUid: userUid),
          const SizedBox(height: AppSpacing.lg),

          _PersonalDataCard(onStub: _stub),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── App bar ─────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onMenuTap});
  final VoidCallback onMenuTap;

  static const _logoBg = Color(0xFF4A3B33);

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                size: 28, color: AppColors.primaryText),
            onPressed: onMenuTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Menu',
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _logoBg,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.face_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('AMiLY',
              style:
                  AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ─── Titre + bouton Pro ───────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.onPassPro});
  final VoidCallback onPassPro;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mon profil',
                  style: AppTextStyles.headlineMedium
                      .copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Gérez vos informations visibles par les parents et la PMI',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton.icon(
          onPressed: onPassPro,
          icon: const Icon(Icons.star_rounded, size: 18),
          label: const Text('Passer à Pro'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(0, 44),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
        ),
      ],
    );
  }
}

// ─── Chips de statut ─────────────────────────────────────────────────────────

class _StatusChips extends StatelessWidget {
  const _StatusChips({
    required this.availableSlots,
    required this.isSearchable,
  });

  final int availableSlots;
  final bool isSearchable;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _StatusChip(
          icon: isSearchable
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          label: isSearchable
              ? '$availableSlots place(s) disponible(s)'
              : 'Indisponible',
          filled: isSearchable,
        ),
        const _StatusChip(
          icon: Icons.shield_outlined,
          label: 'Agrément valide',
          filled: false,
        ),
        const _StatusChip(
          icon: Icons.verified_user_outlined,
          label: 'Identité vérifiée',
          filled: false,
        ),
      ],
    );
  }
}

// ─── Carte disponibilité ──────────────────────────────────────────────────────

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.isAvailable,
    required this.availableFrom,
    required this.onAvailabilityChanged,
    required this.onAvailableFromChanged,
  });

  final bool isAvailable;
  final DateTime availableFrom;
  final ValueChanged<bool> onAvailabilityChanged;
  final ValueChanged<DateTime> onAvailableFromChanged;

  static const _months = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12',
  ];

  String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${_months[d.month - 1]}/${d.year}';

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: availableFrom,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
      locale: const Locale('fr', 'FR'),
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null) onAvailableFromChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: isAvailable ? AppColors.primary : AppColors.divider,
          width: isAvailable ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? AppColors.primary
                      : AppColors.secondaryText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAvailable
                          ? 'Disponible — J\'accueille de nouveaux enfants'
                          : 'Indisponible — Je n\'accueille pas',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isAvailable
                          ? 'Votre profil est visible par les parents en recherche'
                          : 'Votre profil est masqué des recherches',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch(
                value: isAvailable,
                onChanged: onAvailabilityChanged,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          if (isAvailable) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),
            Text('Disponible à partir du', style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_format(availableFrom),
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.primaryText)),
                    ),
                    const Icon(Icons.calendar_today_rounded,
                        size: 20, color: AppColors.secondaryText),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Informations pratiques ───────────────────────────────────────────────────

class _PracticalInfoCard extends StatelessWidget {
  const _PracticalInfoCard({
    required this.maxChildrenController,
    required this.availableSlotsController,
    required this.tobacco,
    required this.firstAid,
    required this.pet,
    required this.onTobaccoChanged,
    required this.onFirstAidChanged,
    required this.onPetChanged,
  });

  final TextEditingController maxChildrenController;
  final TextEditingController availableSlotsController;
  final String tobacco;
  final String firstAid;
  final String pet;
  final ValueChanged<String?> onTobaccoChanged;
  final ValueChanged<String?> onFirstAidChanged;
  final ValueChanged<String?> onPetChanged;

  static const _tobaccoOptions = ['Non fumeur', 'Fumeur (extérieur)', 'Fumeur'];
  static const _firstAidOptions = ['PSC1 validé', 'SST validé', 'Aucune formation'];
  static const _petOptions = ['Pas d\'animal', 'Chat', 'Chien', 'Autre animal'];

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Informations pratiques', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Ces informations sont visibles par les parents',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.lg),

          _IconLabeledDropdown(
            icon: Icons.smoking_rooms_rounded,
            label: 'Tabac au domicile',
            value: tobacco,
            options: _tobaccoOptions,
            onChanged: onTobaccoChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          _IconLabeledDropdown(
            icon: Icons.monitor_heart_outlined,
            label: 'Formation 1ers secours',
            value: firstAid,
            options: _firstAidOptions,
            onChanged: onFirstAidChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          _IconLabeledDropdown(
            icon: Icons.pets_rounded,
            label: 'Animal au domicile',
            value: pet,
            options: _petOptions,
            onChanged: onPetChanged,
          ),
          const SizedBox(height: AppSpacing.md),

          ProfileFormField(
            label: 'Places max (agrément)',
            controller: maxChildrenController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
            label: 'Enfants accueillis actuellement',
            controller: availableSlotsController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

/// Dropdown avec un label "icône + texte" au-dessus du champ.
class _IconLabeledDropdown extends StatelessWidget {
  const _IconLabeledDropdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryText, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTextStyles.labelMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: value,
          items: [
            for (final opt in options)
              DropdownMenuItem(value: opt, child: Text(opt)),
          ],
          onChanged: onChanged,
          isExpanded: true,
        ),
      ],
    );
  }
}

// ─── Carte à checkboxes (wirée) ───────────────────────────────────────────────

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Map<String, bool> items;
  final void Function(String key, bool value) onChanged;

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.md),
          for (final entry in items.entries)
            FilterCheckboxTile(
              label: entry.key,
              value: entry.value,
              onChanged: (v) => onChanged(entry.key, v),
            ),
        ],
      ),
    );
  }
}

// ─── Diplômes & Expérience ────────────────────────────────────────────────────

class _DiplomasCard extends StatelessWidget {
  const _DiplomasCard({
    required this.diplomas,
    required this.parcoursProController,
    required this.onAddDiploma,
    required this.onRemoveDiploma,
  });

  final List<String> diplomas;
  final TextEditingController parcoursProController;
  final ValueChanged<String> onAddDiploma;
  final ValueChanged<String> onRemoveDiploma;

  @override
  Widget build(BuildContext context) {
    void _showAddDialog() {
      final textCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ajouter un diplôme'),
          content: TextField(
            controller: textCtrl,
            decoration: const InputDecoration(
              hintText: 'Nom du diplôme (ex: CAP Petite Enfance)',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final text = textCtrl.text.trim();
                if (text.isNotEmpty) {
                  onAddDiploma(text);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      );
    }

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Diplômes & Expérience', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Diplômes & Formations',
              style:
                  AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          if (diplomas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Aucun diplôme renseigné',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryText, fontStyle: FontStyle.italic),
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final d in diplomas)
                  _DiplomaChip(label: d, onRemove: () => onRemoveDiploma(d)),
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.work_outline_rounded,
                  color: AppColors.primaryText, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text('Parcours professionnel',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: parcoursProController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Décrivez votre parcours professionnel…',
            ),
          ),
        ],
      ),
    );
  }
}

class _DiplomaChip extends StatelessWidget {
  const _DiplomaChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.assmatIconBg,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.primaryText)),
          const SizedBox(width: AppSpacing.sm),
          InkWell(
            onTap: onRemove,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close_rounded,
                  color: AppColors.primaryText, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Photos du domicile ───────────────────────────────────────────────────────

class _HomePhotosCard extends StatelessWidget {
  const _HomePhotosCard({
    required this.homePhotos,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  final List<String> homePhotos;
  final VoidCallback onAddPhoto;
  final ValueChanged<String> onRemovePhoto;

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Photos du domicile', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Ajoutez des photos de votre espace d\'accueil',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppSpacing.md;
              final tileWidth = (constraints.maxWidth - spacing) / 2;
              final tileHeight = tileWidth * 0.82;
              final photoTiles = homePhotos
                  .map((url) => _PhotoTile(
                        url: url,
                        width: tileWidth,
                        height: tileHeight,
                        onRemove: () => onRemovePhoto(url),
                      ))
                  .toList();
              final addTile = _AddPhotoTile(
                  width: tileWidth, height: tileHeight, onTap: onAddPhoto);
              final allTiles = [...photoTiles, addTile];
              final rows = <Widget>[];
              for (var i = 0; i < allTiles.length; i += 2) {
                final right =
                    i + 1 < allTiles.length ? allTiles[i + 1] : null;
                rows.add(Row(children: [
                  allTiles[i],
                  const SizedBox(width: spacing),
                  right ?? SizedBox(width: tileWidth),
                ]));
                if (i + 2 < allTiles.length) {
                  rows.add(const SizedBox(height: spacing));
                }
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: rows);
            },
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.url,
    required this.width,
    required this.height,
    required this.onRemove,
  });

  final String url;
  final double width;
  final double height;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.divider,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile(
      {required this.width, required this.height, required this.onTap});
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded,
                    size: width * 0.22, color: AppColors.secondaryText),
                const SizedBox(height: 4),
                Text('Ajouter',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = AppRadii.md;
    const dashLen = 6.0;
    const gapLen = 5.0;
    final paint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLen).clamp(0.0, metric.length);
        dashedPath.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashLen + gapLen;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Numéro d'agrément ────────────────────────────────────────────────────────

class _AccreditationCard extends StatelessWidget {
  const _AccreditationCard({
    required this.accreditationNumberController,
    required this.accreditationExpiry,
    required this.onAccreditationExpiryChanged,
    required this.accreditationPhotoUrl,
    required this.onChangePhoto,
    required this.pmiCodeController,
    required this.isCertified,
    required this.onCertifiedChanged,
  });

  final TextEditingController accreditationNumberController;
  final DateTime? accreditationExpiry;
  final ValueChanged<DateTime> onAccreditationExpiryChanged;
  final String? accreditationPhotoUrl;
  final VoidCallback onChangePhoto;
  final TextEditingController pmiCodeController;
  final bool isCertified;
  final ValueChanged<bool> onCertifiedChanged;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickExpiry(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: accreditationExpiry ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040, 12, 31),
      locale: const Locale('fr', 'FR'),
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null) onAccreditationExpiryChanged(picked);
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Numéro d\'agrément', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileFormField(
              label: 'Numéro d\'agrément',
              controller: accreditationNumberController),
          const SizedBox(height: AppSpacing.md),
          _DatePickerField(
              label: 'Date d\'expiration',
              value: accreditationExpiry != null ? _fmt(accreditationExpiry!) : 'Sélectionner une date',
              onTap: () => _pickExpiry(context)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primaryText, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text('Photo de l\'agrément',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Cette photo sera visible par les parents et la PMI pour vérification.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onChangePhoto,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (accreditationPhotoUrl != null && accreditationPhotoUrl!.isNotEmpty)
                      Image.network(
                        accreditationPhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFD0CCCA),
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_rounded, size: 48, color: Color(0xFFAAAAAA)),
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFFD0CCCA),
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined,
                            size: 48, color: Color(0xFFAAAAAA)),
                      ),
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppRadii.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 16),
                              const SizedBox(width: AppSpacing.xs),
                              Text('Visible parents & PMI',
                                  style: AppTextStyles.labelMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: () => onCertifiedChanged(!isCertified),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isCertified,
                      onChanged: (v) =>
                          onCertifiedChanged(v ?? false),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Je certifie que ce numéro d\'agrément est valide',
                          style: AppTextStyles.bodyLarge
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Toute fausse déclaration peut entraîner la '
                          'suspension de votre compte',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Code PMI (fourni par votre PMI)',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(label: '', controller: pmiCodeController),
          const SizedBox(height: AppSpacing.xs),
          Text('Ce code vous rattache à votre PMI de secteur',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(value,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primaryText)),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.primaryText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Contacts importants ──────────────────────────────────────────────────────

class _ImportantContactsCard extends StatelessWidget {
  const _ImportantContactsCard({
    required this.contactPmiNameController,
    required this.contactPmiPhoneController,
    required this.contactRpeNameController,
    required this.contactRpePhoneController,
    required this.contactAntipoisonPhoneController,
    required this.contactTiersNameController,
    required this.contactTiersPhoneController,
    required this.emergencyPhoneCustomController,
  });

  final TextEditingController contactPmiNameController;
  final TextEditingController contactPmiPhoneController;
  final TextEditingController contactRpeNameController;
  final TextEditingController contactRpePhoneController;
  final TextEditingController contactAntipoisonPhoneController;
  final TextEditingController contactTiersNameController;
  final TextEditingController contactTiersPhoneController;
  final TextEditingController emergencyPhoneCustomController;

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('$label — à venir'),
          behavior: SnackBarBehavior.floating),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_in_talk_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Contacts importants', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Vos contacts professionnels d\'urgence et de référence',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.lg),
          _ContactSection(
            icon: Icons.domain_outlined,
            iconColor: AppColors.primary,
            label: 'PMI',
            firstFieldLabel: 'Nom',
            firstFieldController: contactPmiNameController,
            secondFieldLabel: 'Téléphone',
            secondFieldController: contactPmiPhoneController,
            secondKeyboard: TextInputType.phone,
            callLabel: 'Contacter la PMI',
            onCall: () => _stub(context, 'Contacter la PMI'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _ContactSection(
            icon: Icons.domain_outlined,
            iconColor: AppColors.accent,
            label: 'Relais Petite Enfance (RPE)',
            firstFieldLabel: 'Nom',
            firstFieldController: contactRpeNameController,
            secondFieldLabel: 'Téléphone',
            secondFieldController: contactRpePhoneController,
            secondKeyboard: TextInputType.phone,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _ContactSection(
            icon: Icons.warning_amber_outlined,
            iconColor: AppColors.accent,
            label: 'Centre antipoison',
            firstFieldLabel: 'Numéro',
            firstFieldController: contactAntipoisonPhoneController,
            firstKeyboard: TextInputType.phone,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _ContactSection(
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.secondaryText,
            label: 'Tiers à contacter',
            firstFieldLabel: 'Nom',
            firstFieldController: contactTiersNameController,
            secondFieldLabel: 'Téléphone',
            secondFieldController: contactTiersPhoneController,
            secondKeyboard: TextInputType.phone,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _EmergencyNumbersSection(
            emergencyPhoneCustomController: emergencyPhoneCustomController,
          ),
        ],
      ),
    );
  }
}

class _EmergencyNumbersSection extends StatelessWidget {
  const _EmergencyNumbersSection({required this.emergencyPhoneCustomController});

  final TextEditingController emergencyPhoneCustomController;

  static const _rowBg = Color(0xFFFFF0EE);
  static const _numbers = [
    (label: 'Urgences européennes', number: '112'),
    (label: 'SAMU', number: '15'),
    (label: 'Pompiers', number: '18'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_outlined, color: AppColors.error, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text('Numéros d\'urgence',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final item in _numbers) ...[
          _EmergencyRow(label: item.label, number: item.number, bg: _rowBg),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text('Autre numéro personnalisé',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: AppSpacing.sm),
        ProfileFormField(
            label: '',
            controller: emergencyPhoneCustomController,
            keyboardType: TextInputType.phone),
      ],
    );
  }
}

class _EmergencyRow extends StatelessWidget {
  const _EmergencyRow(
      {required this.label, required this.number, required this.bg});
  final String label;
  final String number;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border:
            Border.all(color: AppColors.error.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.primaryText)),
          ),
          Text(number,
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.icon,
    required this.label,
    required this.firstFieldLabel,
    required this.firstFieldController,
    this.iconColor = AppColors.primary,
    this.firstKeyboard = TextInputType.text,
    this.secondFieldLabel,
    this.secondFieldController,
    this.secondKeyboard = TextInputType.text,
    this.callLabel,
    this.onCall,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String firstFieldLabel;
  final TextEditingController firstFieldController;
  final TextInputType firstKeyboard;
  final String? secondFieldLabel;
  final TextEditingController? secondFieldController;
  final TextInputType secondKeyboard;
  final String? callLabel;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(label,
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ProfileFormField(
            label: firstFieldLabel,
            controller: firstFieldController,
            keyboardType: firstKeyboard),
        if (secondFieldLabel != null && secondFieldController != null) ...[
          const SizedBox(height: AppSpacing.md),
          ProfileFormField(
              label: secondFieldLabel!,
              controller: secondFieldController!,
              keyboardType: secondKeyboard),
        ],
        if (callLabel != null && onCall != null) ...[
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(callLabel!),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Vérification d'identité ──────────────────────────────────────────────────

class _IdentityVerificationCard extends StatelessWidget {
  const _IdentityVerificationCard({
    required this.isVerified,
    required this.verifiedAt,
  });

  final bool isVerified;
  final DateTime? verifiedAt;

  static const _rgpdBg = Color(0xFFFFF8E1);

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.credit_card_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Vérification d\'identité',
                  style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(
                  isVerified ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                  color: isVerified ? AppColors.primary : AppColors.secondaryText,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVerified ? 'Identité vérifiée' : 'Identité non vérifiée',
                        style: AppTextStyles.bodyLarge.copyWith(
                            color: isVerified ? AppColors.primary : AppColors.secondaryText,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isVerified && verifiedAt != null
                            ? 'Vérification effectuée le ${_fmt(verifiedAt!)}'
                            : 'Veuillez contacter le support pour valider votre pièce d\'identité.',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _rgpdBg,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Vos données sont traitées conformément au RGPD. '
                    'La photo n\'est pas conservée après vérification.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryText),
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

// ─── Spécialités & compétences ────────────────────────────────────────────────

class _SpecialitiesCard extends StatelessWidget {
  const _SpecialitiesCard({
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  final List<String> tags;
  final ValueChanged<String> onAddTag;
  final ValueChanged<String> onRemoveTag;

  @override
  Widget build(BuildContext context) {
    void _showAddDialog() {
      final textCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ajouter une spécialité'),
          content: TextField(
            controller: textCtrl,
            decoration: const InputDecoration(
              hintText: 'Spécialité (ex: Éveil musical)',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final text = textCtrl.text.trim();
                if (text.isNotEmpty) {
                  onAddTag(text);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      );
    }

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_border_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Spécialités & compétences',
                  style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (tags.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Aucune spécialité renseignée',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryText, fontStyle: FontStyle.italic),
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final tag in tags)
                  _DiplomaChip(label: tag, onRemove: () => onRemoveTag(tag)),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Coffre-fort numérique ────────────────────────────────────────────────────

class _SignedContractsVault extends StatelessWidget {
  const _SignedContractsVault({required this.userUid});

  final String userUid;

  @override
  Widget build(BuildContext context) {
    if (userUid.isEmpty) return const SizedBox.shrink();

    final contractsQuery = FirebaseFirestore.instance
        .collection('contracts')
        .where('assmatUid', isEqualTo: userUid)
        .where('status', isEqualTo: 'active');

    return StreamBuilder<QuerySnapshot>(
      stream: contractsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data?.docs ?? [];
        final entries = <DocumentEntry>[];

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final contractData = data['contractData'] as Map<String, dynamic>?;
          final employer = contractData?['employeur'] as Map<String, dynamic>?;
          final enfant = contractData?['enfant'] as Map<String, dynamic>?;
          final parentName = '${employer?['prenom'] ?? ''} ${employer?['nom'] ?? ''}'.trim();
          final childName = enfant?['prenom'] as String? ?? '';
          final signedAt = (data['finalizedAt'] as String?) ??
              (data['updatedAt'] as String?) ?? '';
          final subtitle = signedAt.isNotEmpty
              ? 'Signé le ${_formatDate(signedAt)}'
              : 'Actif';
          final label = parentName.isNotEmpty ? parentName : childName;

          final pdfUrl = data['pdfUrl'] as String?;
          final finalPdfUrl = data['finalPdfUrl'] as String?;

          if (pdfUrl != null && pdfUrl.isNotEmpty) {
            entries.add(DocumentEntry(
              title: label.isNotEmpty
                  ? 'Engagement — $label'
                  : "Contrat d'engagement",
              subtitle: subtitle,
              icon: Icons.handshake_rounded,
              iconBg: AppColors.secondary,
              iconColor: AppColors.primary,
              url: pdfUrl,
            ));
          }

          if (finalPdfUrl != null && finalPdfUrl.isNotEmpty) {
            entries.add(DocumentEntry(
              title: label.isNotEmpty
                  ? 'Contrat CDI — $label'
                  : 'Contrat de travail CDI',
              subtitle: subtitle,
              icon: Icons.description_rounded,
              iconBg: AppColors.parentIconBg,
              iconColor: AppColors.primary,
              url: finalPdfUrl,
            ));
          }
        }

        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_rounded,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text('Coffre-fort numérique',
                          style: AppTextStyles.titleMedium),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Icon(Icons.folder_open_rounded, size: 48,
                    color: AppColors.secondaryText),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Aucun document signé pour le moment',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        return DocumentVaultCard(
          documents: entries,
          onDocumentTap: (d) {
            if (d.url != null) {
              launchUrl(Uri.parse(d.url!),
                  mode: LaunchMode.externalApplication);
            }
          },
        );
      },
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

// ─── Mes données personnelles ─────────────────────────────────────────────────

class _PersonalDataCard extends StatelessWidget {
  const _PersonalDataCard({required this.onStub});
  final void Function(String) onStub;

  static const _rgpdBg = Color(0xFFF5F5F5);

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
            'Cette action est irréversible. Toutes vos données seront définitivement supprimées.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final uid = user.uid;
          await FirebaseFirestore.instance.collection('users').doc(uid).delete();
          await FirebaseFirestore.instance.collection('assmats').doc(uid).delete();
          await user.delete();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Compte supprimé définitivement')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression du compte : $e')),
          );
        }
      }
    }
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Mes données personnelles',
                  style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Gérez vos données conformément au RGPD',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _rgpdBg,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Vos données sont hébergées dans l\'Union européenne '
                    'et protégées conformément au RGPD.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryText),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => onStub('Télécharger mes données'),
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text('Télécharger mes données'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48)),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Supprimer mon compte'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => onStub('Politique de confidentialité'),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.secondaryText),
                children: const [
                  TextSpan(
                      text: 'Pour plus d\'informations, consultez notre '),
                  TextSpan(
                    text: 'Politique de confidentialité',
                    style: TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Barre d'actions fixe ─────────────────────────────────────────────────────

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
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
                        horizontal: AppSpacing.sm)),
                child: const Text('Annuler',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
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

// ─── Pill de statut ───────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.filled,
  });
  final IconData icon;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(
            color: filled ? AppColors.primary : AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: filled ? AppColors.onPrimary : AppColors.primaryText,
              size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(label,
              style: AppTextStyles.labelMedium.copyWith(
                  color:
                      filled ? AppColors.onPrimary : AppColors.primaryText)),
        ],
      ),
    );
  }
}
