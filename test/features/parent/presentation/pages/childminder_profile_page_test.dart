import 'package:amily/features/auth/data/models/assmat_profile_model.dart';
import 'package:amily/features/auth/presentation/providers/auth_providers.dart';
import 'package:amily/features/parent/presentation/pages/childminder_profile_page.dart';
import 'package:amily/features/parent/presentation/providers/favorites_provider.dart';
import 'package:amily/features/parent/presentation/widgets/childminder_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  );

  AssmatProfileModel buildProfile({String? photoUrl}) {
    return AssmatProfileModel(
      uid: summary.uid,
      firstName: 'Jane',
      lastName: 'Doe',
      createdAt: DateTime(2025, 1, 1),
      photoUrl: photoUrl,
    );
  }

  Widget buildPage(AssmatProfileModel profile) {
    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(null)),
        favoriteIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
        assmatProfileByUidProvider
            .overrideWith((ref, uid) => Stream.value(profile)),
      ],
      child: const MaterialApp(
        home: ChildminderProfilePage(data: summary),
      ),
    );
  }

  group('ChildminderProfilePage - photo de profil', () {
    testWidgets("n'affiche plus l'icône cadenas sur la photo de profil",
        (tester) async {
      await tester.pumpWidget(
        buildPage(buildProfile(photoUrl: 'https://example.com/photo.jpg')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });

    testWidgets('affiche les initiales sans cadenas quand aucune photo',
        (tester) async {
      await tester.pumpWidget(buildPage(buildProfile()));
      await tester.pumpAndSettle();

      expect(find.text('JD'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });
  });
}
