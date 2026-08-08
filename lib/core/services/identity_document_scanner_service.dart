import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Fournit une instance de capture du document d'identité.
final identityDocumentScannerServiceProvider =
    Provider<IdentityDocumentScannerService>(
  (_) => MlKitIdentityDocumentScannerService(),
);

/// Service de capture d'une pièce d'identité (CNI / passeport).
///
/// Sur Android, [scanWithMlKit] lance le scanner de documents de Google
/// (cadrage visuel, détection automatique des bords, rognage et rotation).
/// Sur les autres plateformes, [captureImage] retombe sur l'appareil photo /
/// la galerie puis un rognage manuel.
abstract class IdentityDocumentScannerService {
  /// `true` si le scanner ML Kit est disponible sur la plateforme courante
  /// (Android uniquement — API encore en bêta chez Google).
  bool get supportsMlKitScanner;

  /// Lance le scanner ML Kit : UI native avec cadrage visuel, détection
  /// automatique des bords et rognage du document. Retourne le chemin de
  /// l'image recadrée, ou `null` si l'utilisateur annule.
  ///
  /// Lève [UnsupportedError] si [supportsMlKitScanner] est `false`.
  Future<String?> scanWithMlKit();

  /// Capture une image depuis [source] (caméra ou galerie) puis propose un
  /// rognage manuel. Retourne le chemin de l'image, ou `null` si annulé.
  Future<String?> captureImage({required ImageSource source});
}

class MlKitIdentityDocumentScannerService
    implements IdentityDocumentScannerService {
  @override
  bool get supportsMlKitScanner => !kIsWeb && Platform.isAndroid;

  @override
  Future<String?> scanWithMlKit() async {
    if (!supportsMlKitScanner) {
      throw UnsupportedError(
        'Le scanner ML Kit n\'est pas disponible sur cette plateforme.',
      );
    }
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        mode: ScannerMode.full,
        pageLimit: 1,
        isGalleryImport: true,
      ),
    );
    try {
      final result = await scanner.scanDocument();
      final images = result.images ?? const <String>[];
      return images.isEmpty ? null : images.first;
    } finally {
      scanner.close();
    }
  }

  @override
  Future<String?> captureImage({required ImageSource source}) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (picked == null) return null;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer la pièce d\'identité',
          toolbarColor: const Color(0xFFC8860A),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Recadrer la pièce d\'identité',
          aspectRatioLockEnabled: false,
          resetButtonHidden: false,
        ),
      ],
    );
    return cropped?.path ?? picked.path;
  }
}
