import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Styles typographiques du design system Ami-ly.
///
/// - Primary (titres, labels) : **Plus Jakarta Sans**
/// - Secondary (corps) : **Inter**
///
/// `google_fonts` télécharge les polices au premier lancement (cache local).
/// Pour du pur offline, baker les `.ttf` dans `assets/fonts/` et les déclarer
/// dans `pubspec.yaml` → `GoogleFonts` les détectera automatiquement.
class AppTextStyles {
  AppTextStyles._();

  // --- Headlines (Plus Jakarta Sans) ---
  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.primaryText,
      );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.primaryText,
      );

  // --- Titles (Plus Jakarta Sans) ---
  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.primaryText,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.primaryText,
      );

  // --- Body (Inter) ---
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.primaryText,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.primaryText,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.primaryText,
      );

  // --- Labels (Plus Jakarta Sans) ---
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.primaryText,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.primaryText,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.primaryText,
      );
}
