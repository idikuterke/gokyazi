import 'package:flutter/material.dart';

class AppColors {
  static bool isDarkMode = true;

  // Base Canvas
  static Color get bgCosmos =>
      isDarkMode ? const Color(0xFF0C0A18) : const Color(0xFFF5F5F5);
  static Color get bgIndigoLift =>
      isDarkMode ? const Color(0xFF14122C) : const Color(0xFFEBE9F5);
  static Color get bgCard =>
      isDarkMode ? const Color(0xCC14122C) : const Color(0xFFFFFFFF);
  static Color get bgCardSoft =>
      isDarkMode ? const Color(0x80000000) : const Color(0xFFF9FAFB);
  static Color get bgScrim =>
      isDarkMode ? const Color(0x80000000) : const Color(0x4D000000);
  static Color get bgScrimHeavy =>
      isDarkMode ? const Color(0xB3000000) : const Color(0x80000000);
  static Color get bgPressWell =>
      isDarkMode ? const Color(0x33000000) : const Color(0x1F000000);
  static Color get bgInputDim =>
      isDarkMode ? const Color(0x66000000) : const Color(0x0D000000);

  // Accent
  static Color get amber700 =>
      isDarkMode ? const Color(0xFFFFA000) : const Color(0xFFB45309);
  static Color get amber500 =>
      isDarkMode ? const Color(0xFFFFC107) : const Color(0xFFD97706);
  static Color get amber200 =>
      isDarkMode ? const Color(0xFFFFE082) : const Color(0xFFFBBF24);
  static Color get cyanGlow =>
      isDarkMode ? const Color(0x9900FFFF) : const Color(0x4D06B6D4);
  static Color get cyanSpecial =>
      isDarkMode ? const Color(0xFF4DD0E1) : const Color(0xFF0891B2);
  static const Color deepPurpleSeed = Color(0xFF673AB7);

  // Text
  static Color get fgPrimary =>
      isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
  static Color get fgSecondary =>
      isDarkMode ? const Color(0xB3FFFFFF) : const Color(0xFF6B7280);
  static Color get fgTertiary =>
      isDarkMode ? const Color(0x80FFFFFF) : const Color(0xFF9CA3AF);
  static Color get fgDisabled =>
      isDarkMode ? const Color(0x4DFFFFFF) : const Color(0xFFD1D5DB);
  static Color get fgDivider =>
      isDarkMode ? const Color(0x3DFFFFFF) : const Color(0xFFE5E7EB);
  static Color get fgOnAmber =>
      isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

  // Borders
  static Color get borderHairline =>
      isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x1F000000);
  static Color get borderCard =>
      isDarkMode ? const Color(0x33FFFFFF) : const Color(0x4DD4A017);
  static Color get borderAmber =>
      isDarkMode ? const Color(0x80FFC107) : const Color(0x99D97706);
  static Color get borderInput =>
      isDarkMode ? const Color(0x80FFFFFF) : const Color(0x400F0C24);

  // Semantic
  static Color get danger =>
      isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
  static Color get success =>
      isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669);
  static Color get warning =>
      isDarkMode ? const Color(0xFFF59E0B) : const Color(0xFFD97706);

  // Background Gradients
  static List<Color> get primaryBgGradient => isDarkMode
      ? const [Color(0xFF2D1B69), Color(0xFF1A1332), Color(0xFF0C0A18)]
      : const [Color(0xFFEDE9FE), Color(0xFFF3F1FA), Color(0xFFF9F9FC)];

  static List<Color> get greenBgGradient => isDarkMode
      ? const [Color(0x3386EFAC), Color(0xFF0C0A18)]
      : const [Color(0xFFE8F7EE), Color(0xFFF6FAF8)];

  static List<Color> get violetBgGradient => isDarkMode
      ? const [Color(0x33A78BFA), Color(0xFF0C0A18)]
      : const [Color(0xFFEFEBFD), Color(0xFFF8F6FD)];

  static List<Color> get pinkBgGradient => isDarkMode
      ? const [Color(0x33F472B6), Color(0xFF0C0A18)]
      : const [Color(0xFFFDF0F6), Color(0xFFFAF5F8)];

  static List<Color> get blueBgGradient => isDarkMode
      ? const [Color(0x3360A5FA), Color(0xFF0C0A18)]
      : const [Color(0xFFEDF4FE), Color(0xFFF5F9FD)];

  // Shadow / Glow
  static BoxShadow get glowCyan => BoxShadow(
        color: cyanGlow,
        blurRadius: 25,
        spreadRadius: 3,
      );

  static Shadow get textShadowSm => Shadow(
        color: Colors.black.withValues(alpha: isDarkMode ? 0.85 : 0.15),
        blurRadius: 5,
      );

  static Shadow get textShadowMd => Shadow(
        color: Colors.black.withValues(alpha: isDarkMode ? 0.9 : 0.2),
        blurRadius: 10,
      );
}
