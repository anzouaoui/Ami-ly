import 'package:flutter/material.dart';

/// Palette Ami-ly — source unique de couleurs pour toute l'app.
///
/// Charte graphique v2 : fond crème chaud, orange/ambre comme couleur
/// primaire de marque, vert relégué aux états de succès.
class AppColors {
  AppColors._();

  // ---------- Light ----------
  static const primary = Color(0xFFC8860A);        // ambre chaud — couleur de marque
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFFEF3DC);      // ambre très clair (tints)
  static const onSecondary = Color(0xFFC8860A);
  static const accent = Color(0xFFF5A623);         // orange vif — CTA / badges

  static const background = Color(0xFFF7F3EC);     // crème chaud (fond app)
  static const surface = Color(0xFFFFFFFF);        // cartes, sheets
  static const onSurface = Color(0xFF2D3436);

  static const primaryText = Color(0xFF2D3436);    // titres, textes denses
  static const secondaryText = Color(0xFF7F8C8D);  // descriptions, captions
  static const hint = Color(0xFFB2BEC3);           // placeholders

  static const error = Color(0xFFE74C3C);
  static const onError = Color(0xFFFFFFFF);
  static const success = Color(0xFF479073);        // vert — états de succès uniquement

  static const divider = Color(0xFFE8E0D5);        // séparateur légèrement chaud

  // ---------- Role card tints (welcome screen) ----------
  static const parentIconBg = Color(0xFFFFF3E0);   // pêche très doux
  static const assmatIconBg = Color(0xFFFFF3E0);   // pêche très clair (inchangé)
  static const assmatIconColor = Color(0xFFF57C00); // orange soutenu (inchangé)

  // ---------- Stat cards (dashboard) ----------
  static const statBlueBg = Color(0xFFE3F2FD);     // bleu ciel très clair (inchangé)
  static const statBlueColor = Color(0xFF2196F3);  // bleu Material (inchangé)
  static const statYellowBg = Color(0xFFFEF3DC);   // ambre très clair (= secondary)
  // Le jaune/orange du texte réutilise AppColors.accent (#F5A623).

  // ---------- Dark (préparé, pas encore utilisé partout) ----------
  static const darkPrimary = Color(0xFFD4920C);
  static const darkOnPrimary = Color(0xFF000000);
  static const darkSecondary = Color(0xFF3D2E10);
  static const darkOnSecondary = Color(0xFFFFFFFF);
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkOnSurface = Color(0xFFE0E0E0);
  static const darkPrimaryText = Color(0xFFF5F5F5);
  static const darkSecondaryText = Color(0xFFA0A0A0);
  static const darkHint = Color(0xFF636366);
  static const darkError = Color(0xFFCF6679);
  static const darkDivider = Color(0xFF2C2C2C);
}
