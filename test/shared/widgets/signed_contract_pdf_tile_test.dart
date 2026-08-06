import 'package:amily/shared/widgets/signed_contract_pdf_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignedContractPdfTile', () {
    const url = 'https://storage.example.com/contrat_finalise.pdf';

    Widget build(Widget child) {
      return MaterialApp(home: Scaffold(body: child));
    }

    testWidgets('affiche le titre et le sous-titre « Signé le »', (tester) async {
      await tester.pumpWidget(build(
        const SignedContractPdfTile(
          title: 'Contrat de travail CDI',
          subtitle: 'Signé le 06/08/2026',
          url: url,
        ),
      ));

      expect(find.text('Contrat de travail CDI'), findsOneWidget);
      expect(find.text('Signé le 06/08/2026'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });

    testWidgets('n’affiche pas de sous-titre s’il est vide', (tester) async {
      await tester.pumpWidget(build(
        const SignedContractPdfTile(title: 'Contrat', url: url),
      ));

      expect(find.text('Contrat'), findsOneWidget);
      expect(find.text('Signé le'), findsNothing);
    });

    testWidgets('invoque onOpen avec l’URL du PDF au tap', (tester) async {
      String? openedUrl;
      await tester.pumpWidget(build(
        SignedContractPdfTile(
          title: 'Contrat de travail CDI',
          url: url,
          onOpen: (u) async {
            openedUrl = u;
          },
        ),
      ));

      await tester.tap(find.byIcon(Icons.download_rounded));
      await tester.pump();

      expect(openedUrl, url);
    });
  });
}
