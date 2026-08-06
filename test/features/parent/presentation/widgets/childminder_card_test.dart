import 'package:amily/features/parent/presentation/widgets/childminder_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const summary = ChildminderSummary(
    uid: 'uid-1',
    initials: 'JD',
    name: 'Jane Doe',
    location: 'Lyon',
    distance: '2 km',
    experience: '5 ans',
    places: '2 places',
    date: 'Dispo demain',
    cert: 'Agréée',
    photoUrl: 'https://example.com/photo.jpg',
  );

  Widget buildCard(ChildminderSummary data) {
    return MaterialApp(
      home: Scaffold(
        body: ChildminderCard(data: data, onTap: () {}),
      ),
    );
  }

  group('ChildminderCard - photo de profil', () {
    testWidgets("n'affiche plus l'icône cadenas sur la photo de profil",
        (tester) async {
      await tester.pumpWidget(buildCard(summary));
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });

    testWidgets('affiche les initiales quand aucune photo de profil',
        (tester) async {
      await tester.pumpWidget(
        buildCard(
          const ChildminderSummary(
            uid: 'uid-2',
            initials: 'JD',
            name: 'Jane Doe',
            location: 'Lyon',
            distance: '2 km',
            experience: '5 ans',
            places: '2 places',
            date: 'Dispo demain',
            cert: 'Agréée',
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });

    testWidgets('affiche la coche vérifié sans icône cadenas', (tester) async {
      await tester.pumpWidget(
        buildCard(
          const ChildminderSummary(
            uid: 'uid-3',
            initials: 'JD',
            name: 'Jane Doe',
            location: 'Lyon',
            distance: '2 km',
            experience: '5 ans',
            places: '2 places',
            date: 'Dispo demain',
            cert: 'Agréée',
            isVerified: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });
  });
}
