import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Font Families
  static const fontRunic = 'Orkun';
  static const fontDisplay = 'CinzelDecorative';
  static const fontBody = 'Roboto'; // System default

  // Runic (Old Turkic)
  static TextStyle get runicLg => TextStyle(
    fontFamily: fontRunic,
    fontSize: 26,
    height: 1.3,
    color: AppColors.fgPrimary,
    shadows: [Shadow(blurRadius: 10, color: Colors.black.withValues(alpha: AppColors.isDarkMode ? 0.9 : 0.25))],
  );

  static TextStyle get runicMd => TextStyle(
    fontFamily: fontRunic,
    fontSize: 22,
    height: 1.3,
    color: AppColors.fgPrimary,
    shadows: [Shadow(blurRadius: 10, color: Colors.black.withValues(alpha: AppColors.isDarkMode ? 0.9 : 0.25))],
  );

  static TextStyle get runicSm => TextStyle(
    fontFamily: fontRunic,
    fontSize: 20,
    height: 1.3,
    color: AppColors.fgPrimary,
  );

  // Display (CinzelDecorative)
  static TextStyle get displayXl => TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    letterSpacing: 1.5,
    color: AppColors.fgPrimary,
    shadows: [Shadow(blurRadius: 10, color: Colors.black.withValues(alpha: AppColors.isDarkMode ? 0.9 : 0.25))],
  );

  static TextStyle get displayLg => TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    letterSpacing: 1.5,
    color: AppColors.amber500,
  );

  static TextStyle get displayMd => TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    letterSpacing: 1.5,
    color: AppColors.fgPrimary,
  );

  static TextStyle get displaySm => TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    letterSpacing: 1.5,
    color: AppColors.fgPrimary,
  );

  static TextStyle get displayXs => TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    letterSpacing: 1.5,
    color: AppColors.fgPrimary,
  );

  // Menu Label (ALL CAPS)
  static TextStyle get menuLabel => TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    letterSpacing: 1.5,
    color: AppColors.fgPrimary,
    shadows: [Shadow(blurRadius: 5, color: Colors.black.withValues(alpha: AppColors.isDarkMode ? 0.85 : 0.2))],
  );

  // Body
  static TextStyle get bodyLg => TextStyle(
    fontSize: 18,
    height: 1.5,
    color: AppColors.fgPrimary,
  );

  static TextStyle get bodyMd => TextStyle(
    fontSize: 16,
    height: 1.5,
    color: AppColors.fgPrimary,
  );

  static TextStyle get bodySm => TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.fgSecondary,
  );

  static TextStyle get bodyXs => TextStyle(
    fontSize: 12,
    height: 1.5,
    color: AppColors.fgSecondary,
  );

  // Special
  static TextStyle get bodyItalic => TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: AppColors.fgSecondary,
  );

  static TextStyle get labelAmber => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.amber200,
  );

  static TextStyle get labelCyan => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.cyanSpecial,
  );
}
