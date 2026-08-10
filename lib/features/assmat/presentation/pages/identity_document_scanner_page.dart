import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/identity_document_extractor.dart';
import '../../../../core/services/identity_document_scanner_service.dart';
import '../../../auth/data/models/assmat_profile_model.dart';

/// Résultat retourné par [IdentityDocumentScannerPage] après validation :
/// l'image recadrée du document + les données (éventuellement corrigées).
class IdentityDocumentScanResult {
  const IdentityDocumentScanResult({
    required this.imagePath,
    required this.extracted,
  });

  /// Chemin local de l'image recadrée (scan ML Kit ou rognage manuel).
  final String imagePath;

  /// Données extraites par l'OCR, pré-remplies puis corrigées par l'utilisateur.
  final IdentityExtractedData extracted;
}

enum _ScanPhase { capture, review }

/// Interface de capture de la pièce d'identité (CNI / passeport).
///
/// Phase 1 — Cadrage visuel : l'utilisateur positionne le document dans le
/// cadre ; le scan ML Kit (Android) détecte automatiquement les bords,
/// recadre et corrige la rotation (sinon appareil photo / galerie + rognage
/// manuel).
/// Phase 2 — Relecture : l'OCR on-device pré-remplit les champs du formulaire
/// (nom, prénom, numéro, naissance, expiration) ; l'utilisateur peut les
/// corriger avant de valider.
class IdentityDocumentScannerPage extends ConsumerStatefulWidget {
  const IdentityDocumentScannerPage({
    super.key,
    this.side = 'front',
    this.documentType = IdentityDocumentType.cni,
  });

  /// Côté du document scanné : `'front'` (recto) ou `'back'` (verso).
  final String side;

  /// Type de pièce d'identité sélectionné dans le profil.
  final IdentityDocumentType documentType;

  /// Ouvre la page et retourne un [IdentityDocumentScanResult] validé par
  /// l'utilisateur, ou `null` si la page est fermée sans validation.
  static Route<IdentityDocumentScanResult?> route({
    String side = 'front',
    IdentityDocumentType documentType = IdentityDocumentType.cni,
  }) {
    return MaterialPageRoute<IdentityDocumentScanResult>(
      builder: (_) => IdentityDocumentScannerPage(
        side: side,
        documentType: documentType,
      ),
    );
  }

  @override
  ConsumerState<IdentityDocumentScannerPage> createState() =>
      _IdentityDocumentScannerPageState();
}

class _IdentityDocumentScannerPageState
    extends ConsumerState<IdentityDocumentScannerPage> {
  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _documentNumberCtrl = TextEditingController();

  _ScanPhase _phase = _ScanPhase.capture;
  bool _isProcessing = false;
  String? _error;
  String? _imagePath;
  IdentityExtractedData _extracted = const IdentityExtractedData.empty();
  DateTime? _birthDate;
  DateTime? _expiryDate;

  IdentityDocumentScannerService get _scanner =>
      ref.read(identityDocumentScannerServiceProvider);

  @override
  void dispose() {
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _documentNumberCtrl.dispose();
    super.dispose();
  }

  bool get _isFront => widget.side != 'back';

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Lance le scan : scanner ML Kit sur Android (détection auto des bords et
  /// rognage), sinon appareil photo.
  Future<void> _startScan() async {
    final scanner = _scanner;
    if (scanner.supportsMlKitScanner) {
      await _runCapture(scanner.scanWithMlKit);
    } else {
      await _takePhoto();
    }
  }

  Future<void> _takePhoto() =>
      _runCapture(() => _scanner.captureImage(source: ImageSource.camera));

  Future<void> _importFromGallery() =>
      _runCapture(() => _scanner.captureImage(source: ImageSource.gallery));

  Future<void> _runCapture(Future<String?> Function() capture) async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    try {
      final path = await capture();
      if (path == null || !mounted) return;
      await _analyze(path);
    } catch (e) {
      debugPrint('[Scanner] Échec de la capture du document : $e');
      if (mounted) {
        setState(() {
          _error = 'Impossible de capturer le document. Réessayez.';
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Exécute l'OCR on-device puis pré-remplit le formulaire de relecture.
  Future<void> _analyze(String path) async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    try {
      final data = await ref
          .read(identityDocumentExtractorProvider)
          .extract(path);
      if (!mounted) return;
      setState(() {
        _imagePath = path;
        _extracted = data;
        _lastNameCtrl.text = data.lastName ?? '';
        _firstNameCtrl.text = data.firstName ?? '';
        _documentNumberCtrl.text = data.documentNumber ?? '';
        _birthDate = data.birthDate;
        _expiryDate = data.expiryDate;
        _phase = _ScanPhase.review;
      });
    } catch (e) {
      debugPrint('[Scanner] Échec de l\'analyse OCR : $e');
      if (mounted) {
        setState(() {
          _error = 'Impossible d\'analyser le document. Réessayez.';
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null && mounted) setState(() => _birthDate = picked);
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365 * 5)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040, 12, 31),
      locale: const Locale('fr', 'FR'),
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null && mounted) setState(() => _expiryDate = picked);
  }

  void _rescan() {
    setState(() {
      _phase = _ScanPhase.capture;
      _imagePath = null;
      _error = null;
    });
  }

  void _validate() {
    if (_imagePath == null) return;
    final result = IdentityDocumentScanResult(
      imagePath: _imagePath!,
      extracted: IdentityExtractedData(
        lastName: _lastNameCtrl.text.trim().isEmpty
            ? null
            : _lastNameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim().isEmpty
            ? null
            : _firstNameCtrl.text.trim(),
        documentNumber: _documentNumberCtrl.text.trim().isEmpty
            ? null
            : _documentNumberCtrl.text.trim(),
        birthDate: _birthDate,
        expiryDate: _expiryDate,
      ),
    );
    Navigator.of(context).pop(result);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _isFront ? 'Scanner ma pièce d\'identité' : 'Scanner le verso',
          style: AppTextStyles.titleMedium,
        ),
      ),
      body: _phase == _ScanPhase.capture
          ? _buildCapturePhase()
          : _buildReviewPhase(),
    );
  }

  // ── Phase 1 : cadrage visuel + capture ─────────────────────────────────────

  Widget _buildCapturePhase() {
    final scanner = _scanner;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card_rounded,
                            color: AppColors.onSecondary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${widget.documentType.label} — ${_isFront ? 'recto' : 'verso'}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.onSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AspectRatio(
                    aspectRatio: 85 / 54,
                    child: CustomPaint(
                      key: ValueKey('identity_framing_guide'),
                      painter: _DocumentFramePainter(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Cadrez votre pièce d\'identité dans le cadre',
                    style: AppTextStyles.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'La détection automatique des bords recadre et redresse '
                    'le document. L\'analyse est effectuée sur votre '
                    'appareil, rien n\'est envoyé à un tiers.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                    textAlign: TextAlign.center,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Text(
                        _error!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: _isProcessing ? null : _startScan,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.document_scanner_outlined, size: 20),
                  label: Text(
                    scanner.supportsMlKitScanner
                        ? 'Scanner le document'
                        : 'Prendre une photo',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _takePhoto,
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: const Text('Appareil photo'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _importFromGallery,
                        icon: const Icon(Icons.photo_library_outlined,
                            size: 18),
                        label: const Text('Choisir une image'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Phase 2 : relecture + pré-remplissage OCR + correction ────────────────

  Widget _buildReviewPhase() {
    final found = _extracted.foundCount;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: AppColors.divider),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(
                      File(_imagePath!),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined,
                            size: 40, color: AppColors.hint),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          found > 0
                              ? Icons.check_circle_outline_rounded
                              : Icons.info_outline_rounded,
                          color: AppColors.onSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            found > 0
                                ? '$found information(s) détectée(s) par OCR — '
                                    'vérifiez et corrigez si besoin.'
                                : 'Aucune information détectée — '
                                    'renseignez les champs manuellement.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Vérification des informations',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Les champs ont été pré-remplis automatiquement. '
                    'Corrigez les valeurs si nécessaire avant de valider.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _lastNameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _firstNameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _documentNumberCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de document',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DateField(
                    key: const ValueKey('birth_date_field'),
                    label: 'Date de naissance',
                    value: _birthDate != null
                        ? _formatDate(_birthDate!)
                        : 'Sélectionner une date',
                    onTap: _pickBirthDate,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DateField(
                    key: const ValueKey('expiry_date_field'),
                    label: 'Date d\'expiration',
                    value: _expiryDate != null
                        ? _formatDate(_expiryDate!)
                        : 'Sélectionner une date',
                    onTap: _pickExpiryDate,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: _validate,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Valider'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: _rescan,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Scanner à nouveau'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cadrage visuel : zone sombre en-dehors du document, liseré et cornières
/// pour guider le positionnement de la pièce d'identité.
class _DocumentFramePainter extends CustomPainter {
  const _DocumentFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final margin = size.width * 0.06;
    final rect = Rect.fromLTWH(
      margin,
      size.height * 0.06,
      size.width - 2 * margin,
      size.height * 0.88,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(AppRadii.md),
    );

    // Assombrit tout sauf le document (effet « fenêtre »).
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.55);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(rrect),
      ),
      dim,
    );

    // Liseré blanc du cadre.
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, border);

    // Cornières ambre pour matérialiser les coins.
    final bracket = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const len = 24.0;
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + len)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.left + len, rect.top),
      bracket,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - len, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.top + len),
      bracket,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.right, rect.bottom - len)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.right - len, rect.bottom),
      bracket,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.left + len, rect.bottom)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.bottom - len),
      bracket,
    );
  }

  @override
  bool shouldRepaint(covariant _DocumentFramePainter oldDelegate) => false;
}

/// Champ date non éditable : affiche [value] et ouvre un date picker au tap.
class _DateField extends StatelessWidget {
  const _DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: value.startsWith('Sélectionner')
                ? AppColors.hint
                : AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}
