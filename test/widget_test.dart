// Smoke test de base pour Ami-ly.
//
// TODO : ajouter de vrais tests unitaires (repositories mockés) et widget
// tests (AuthWrapper avec Firestore fake). Pour l'instant, on vérifie juste
// que l'app boot correctement avec ProviderScope.

import 'package:amily/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Ami-ly app builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AmilyApp()),
    );
    // Un seul pump : Firebase n'est pas init ici, le splash/login peut
    // lever une erreur côté stream — on se contente de vérifier qu'il n'y
    // a pas de crash de build du MaterialApp.
    expect(find.byType(AmilyApp), findsOneWidget);
  });
}
