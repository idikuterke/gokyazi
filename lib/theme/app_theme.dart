import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.bgCosmos,

      // ColorScheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.deepPurpleSeed,
        brightness: brightness,
        primary: AppColors.amber700,
        secondary: AppColors.cyanSpecial,
        surface: AppColors.bgIndigoLift,
        error: AppColors.danger,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.amber500),
        titleTextStyle: AppTypography.displayMd,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayXl,
        displayMedium: AppTypography.displayLg,
        displaySmall: AppTypography.displayMd,
        headlineMedium: AppTypography.displaySm,
        titleLarge: AppTypography.bodyLg,
        bodyLarge: AppTypography.bodyMd,
        bodyMedium: AppTypography.bodySm,
        bodySmall: AppTypography.bodyXs,
      ),

      // Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber700,
          foregroundColor: isDark ? Colors.black : Colors.white,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.rPill),
          ),
          textStyle: AppTypography.bodyLg.copyWith(
            fontFamily: AppTypography.fontDisplay,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rThumb),
          borderSide: BorderSide(color: AppColors.borderInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rThumb),
          borderSide: BorderSide(color: AppColors.borderInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rThumb),
          borderSide: BorderSide(color: AppColors.amber500, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.fgTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space4,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rTile),
          side: BorderSide(color: AppColors.borderCard),
        ),
        elevation: 0,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.fgDivider,
        thickness: 1,
        space: AppSpacing.space6,
      ),
    );
  }

  static ThemeData get darkTheme {
    AppColors.isDarkMode = true;
    return _buildTheme(Brightness.dark);
  }

  static ThemeData get lightTheme {
    AppColors.isDarkMode = false;
    return _buildTheme(Brightness.light);
  }
}
