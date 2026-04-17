import 'package:flutter/material.dart';

/// Élévations / ombres du design system Ami-ly.
///
/// À utiliser dans `BoxDecoration.boxShadow` plutôt que `Material.elevation`
/// pour garder le contrôle pixel-près et matcher le design.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0,0,0,0.05)
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0,0,0,0.08)
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,0.10)
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x26000000), // rgba(0,0,0,0.15)
      offset: Offset(0, 12),
      blurRadius: 32,
    ),
  ];
}
