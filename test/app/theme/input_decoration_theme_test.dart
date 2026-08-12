import 'package:amily/app/theme/app_colors.dart';
import 'package:amily/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ratio de contraste WCAG entre deux couleurs.
double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('inputDecorationTheme — light', () {
    testWidgets('le fond des champs est le blanc neutre de la charte '
        '(pas de noir)', (tester) async {
      final theme = AppTheme.light();
      final fill = theme.inputDecorationTheme.fillColor!;
      expect(fill, AppColors.surface);
      expect(fill, isNot(AppColors.darkSurface));
      expect(fill, isNot(Colors.black));
      expect(fill.computeLuminance(), greaterThan(0.5));
    });

    testWidgets('le hint/placeholder reste dans les couleurs de la charte',
        (tester) async {
      final theme = AppTheme.light();
      expect(theme.inputDecorationTheme.hintStyle?.color, AppColors.hint);
    });

    testWidgets('le label des champs est en texte primaire lisible',
        (tester) async {
      final theme = AppTheme.light();
      expect(theme.inputDecorationTheme.labelStyle?.color,
          AppColors.primaryText);
    });

    testWidgets('le curseur est ambre et lisible sur le fond blanc',
        (tester) async {
      final theme = AppTheme.light();
      expect(theme.textSelectionTheme.cursorColor, AppColors.primary);
      // Un curseur est un composant d'interface : le seuil WCAG 1.4.11
      // (contraste non-textuel) est de 3:1, pas 4.5:1.
      expect(
        _contrastRatio(
            theme.textSelectionTheme.cursorColor!, AppColors.surface),
        greaterThanOrEqualTo(3),
      );
    });

    testWidgets('texte saisi et fond respectent un contraste suffisant',
        (tester) async {
      expect(
        _contrastRatio(AppColors.primaryText, AppColors.surface),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('inputDecorationTheme — dark', () {
    testWidgets('le fond des champs reste clair : jamais de champ noir',
        (tester) async {
      final theme = AppTheme.dark();
      final fill = theme.inputDecorationTheme.fillColor!;
      expect(fill, AppColors.surface);
      expect(fill, isNot(theme.colorScheme.surface));
      expect(fill.computeLuminance(), greaterThan(0.5));
    });

    testWidgets('le curseur reste ambre, bien visible', (tester) async {
      final theme = AppTheme.dark();
      expect(theme.textSelectionTheme.cursorColor, AppColors.primary);
    });
  });

  group('champs de formulaire', () {
    Widget buildField(ThemeData theme) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              decoration: const InputDecoration(hintText: 'marie@exemple.fr'),
            ),
          ),
        ),
      );
    }

    testWidgets('un champ sans style explicite applique le fond et le texte '
        'de la charte en clair', (tester) async {
      await tester.pumpWidget(buildField(AppTheme.light()));

      final decorator =
          tester.widget<InputDecorator>(find.byType(InputDecorator));
      expect(decorator.decoration.fillColor, AppColors.surface);

      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.style.color, isNotNull);
      expect(editable.style.color, AppColors.primaryText);
      expect(editable.cursorColor, AppColors.primary);

      // Lisibilité : le contraste texte/fond dépasse 4.5:1.
      expect(
        _contrastRatio(editable.style.color!, AppColors.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('aucun champ ne reçoit un fond sombre en mode dark',
        (tester) async {
      await tester.pumpWidget(buildField(AppTheme.dark()));

      final decorator =
          tester.widget<InputDecorator>(find.byType(InputDecorator));
      expect(decorator.decoration.fillColor, AppColors.surface);

      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(
        _contrastRatio(editable.style.color!, AppColors.surface),
        greaterThanOrEqualTo(4.5),
      );
    });
  });
}
