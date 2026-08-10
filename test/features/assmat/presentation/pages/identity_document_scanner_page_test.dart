import 'dart:io';
import 'dart:typed_data';

import 'package:amily/core/services/identity_document_extractor.dart';
import 'package:amily/core/services/identity_document_scanner_service.dart';
import 'package:amily/features/assmat/presentation/pages/identity_document_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

/// PNG 1×1 transparent pour donner une image lisible à `Image.file`.
final Uint8List _kTransparentPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

class _FakeScannerService implements IdentityDocumentScannerService {
  _FakeScannerService(this.capturePath);

  final String capturePath;
  String? lastSource;

  @override
  bool get supportsMlKitScanner => false;

  @override
  Future<String?> scanWithMlKit() =>
      throw UnsupportedError('Non testé sur cette plateforme.');

  @override
  Future<String?> captureImage({required ImageSource source}) async {
    lastSource = source.name;
    return capturePath;
  }
}

class _FakeExtractor extends IdentityDocumentExtractor {
  _FakeExtractor(this.data);

  final IdentityExtractedData data;

  @override
  Future<IdentityExtractedData> extract(String imagePath, {DateTime? now}) async {
    return data;
  }
}

void main() {
  late File imageFile;

  setUp(() {
    imageFile = File(
      '${Directory.systemTemp.path}/identity_document_scanner_test.png',
    );
    imageFile.writeAsBytesSync(_kTransparentPng);
  });

  tearDown(() {
    if (imageFile.existsSync()) imageFile.deleteSync();
  });

  ProviderScope buildPage(
    IdentityDocumentScannerService service,
    IdentityExtractedData data,
  ) {
    return ProviderScope(
      overrides: [
        identityDocumentScannerServiceProvider.overrideWithValue(service),
        identityDocumentExtractorProvider.overrideWithValue(
          _FakeExtractor(data),
        ),
      ],
      child: const MaterialApp(
        home: IdentityDocumentScannerPage(side: 'front'),
      ),
    );
  }

  testWidgets('affiche le cadre de capture avec les actions disponibles',
      (tester) async {
    await tester.pumpWidget(buildPage(
      _FakeScannerService(imageFile.path),
      const IdentityExtractedData.empty(),
    ));

    expect(find.byKey(const ValueKey('identity_framing_guide')),
        findsOneWidget);
    expect(find.text('Cadrez votre pièce d\'identité dans le cadre'),
        findsOneWidget);
    expect(find.text('Scanner le document'), findsNothing);
    expect(find.text('Prendre une photo'), findsOneWidget);
    expect(find.text('Appareil photo'), findsOneWidget);
    expect(find.text('Choisir une image'), findsOneWidget);
  });

  testWidgets('pré-remplit les champs du formulaire après l\'OCR',
      (tester) async {
    final service = _FakeScannerService(imageFile.path);
    final data = IdentityExtractedData(
      lastName: 'Dupont',
      firstName: 'Andrea',
      documentNumber: '2201234565',
      birthDate: DateTime(1990, 1, 1),
      expiryDate: DateTime(2031, 1, 1),
    );

    await tester.pumpWidget(buildPage(service, data));
    await tester.tap(find.text('Prendre une photo'));
    await tester.pumpAndSettle();

    expect(service.lastSource, ImageSource.camera.name);
    expect(find.text('Vérification des informations'), findsOneWidget);

    final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields[0].controller!.text, 'Dupont');
    expect(fields[1].controller!.text, 'Andrea');
    expect(fields[2].controller!.text, '2201234565');
    expect(find.text('01/01/1990'), findsOneWidget);
    expect(find.text('01/01/2031'), findsOneWidget);
    expect(
      find.textContaining('information(s) détectée(s) par OCR'),
      findsOneWidget,
    );
  });

  testWidgets('la validation retourne l\'image et les données corrigées',
      (tester) async {
    IdentityDocumentScanResult? captured;
    final service = _FakeScannerService(imageFile.path);
    final data = IdentityExtractedData(
      lastName: 'Dupont',
      firstName: 'Andrea',
      documentNumber: '2201234565',
      birthDate: DateTime(1990, 1, 1),
      expiryDate: DateTime(2031, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          identityDocumentScannerServiceProvider.overrideWithValue(service),
          identityDocumentExtractorProvider.overrideWithValue(
            _FakeExtractor(data),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    captured =
                        await Navigator.of(context).push<IdentityDocumentScanResult?>(
                      IdentityDocumentScannerPage.route(side: 'front'),
                    );
                  },
                  child: const Text('ouvrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prendre une photo'));
    await tester.pumpAndSettle();

    // L'utilisateur corrige le prénom avant de valider.
    await tester.enterText(
      find.byType(TextField).at(1),
      'Marie-Anne',
    );
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.imagePath, imageFile.path);
    expect(captured!.extracted.lastName, 'Dupont');
    expect(captured!.extracted.firstName, 'Marie-Anne');
    expect(captured!.extracted.documentNumber, '2201234565');
    expect(captured!.extracted.birthDate, DateTime(1990, 1, 1));
    expect(captured!.extracted.expiryDate, DateTime(2031, 1, 1));
  });

  testWidgets('« Scanner à nouveau » revient au cadre de capture',
      (tester) async {
    final service = _FakeScannerService(imageFile.path);
    const data = IdentityExtractedData(lastName: 'Dupont');

    await tester.pumpWidget(buildPage(service, data));
    await tester.tap(find.text('Prendre une photo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scanner à nouveau'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('identity_framing_guide')),
        findsOneWidget);
    expect(find.text('Vérification des informations'), findsNothing);
  });
}
