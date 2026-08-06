import 'package:amily/app/theme/app_colors.dart';
import 'package:amily/features/parent/presentation/widgets/verification_banner_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BoxDecoration bannerDecoration(WidgetTester tester) {
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(VerificationBannerCard),
            matching: find.byType(Container),
          )
          .first,
    );
    return container.decoration! as BoxDecoration;
  }

  group('VerificationBannerCard', () {
    testWidgets('affiche le bandeau vérifié quand isVerified est vrai',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBannerCard(isVerified: true),
          ),
        ),
      );

      expect(find.text('Profil vérifié'), findsOneWidget);
      expect(
        find.text('Identité, agrément et casier judiciaire contrôlés'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_bottom_rounded), findsNothing);

      final deco = bannerDecoration(tester);
      expect(deco.color, AppColors.secondary);
      final border = deco.border as Border;
      expect(border.top.color, AppColors.primary);
    });

    testWidgets('affiche la date de vérification quand elle est fournie',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerificationBannerCard(
              isVerified: true,
              verifiedAt: DateTime(2026, 5, 12),
            ),
          ),
        ),
      );

      expect(find.text('Vérifié le 12/05/2026'), findsOneWidget);
    });

    testWidgets('affiche le bandeau en cours de vérification quand isVerified '
        'est faux', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBannerCard(isVerified: false),
          ),
        ),
      );

      expect(find.text('Profil en cours de vérification'), findsOneWidget);
      expect(
        find.text(
          'Cette assistante maternelle complète actuellement son dossier '
          'de vérification',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.hourglass_bottom_rounded), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsNothing);

      final deco = bannerDecoration(tester);
      expect(deco.color, AppColors.statYellowBg);
      final border = deco.border as Border;
      expect(border.top.color, AppColors.accent);
    });
  });
}
