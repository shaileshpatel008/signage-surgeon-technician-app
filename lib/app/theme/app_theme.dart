import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

/// Light + dark ThemeData. Dark mode is a "proposed addition" (Settings
/// screen toggle) — the web app itself has no dark mode, so this is new
/// surface built on top of the same brand palette rather than a port.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _base(
        brightness: Brightness.light,
        scaffoldBg: AppColors.brandOffwhite,
        surface: AppColors.white,
        onSurface: AppColors.brandNavy,
      );

  static ThemeData get dark => _base(
        brightness: Brightness.dark,
        scaffoldBg: AppColors.darkBg,
        surface: AppColors.darkSurface,
        onSurface: AppColors.white,
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color surface,
    required Color onSurface,
  }) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.brandRed,
        secondary: AppColors.brandYellow,
        surface: surface,
        error: AppColors.brandRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          side: BorderSide(color: onSurface.withValues(alpha: 0.06)),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandRed,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: onSurface.withValues(alpha: 0.15), width: 1.5),
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: onSurface.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: onSurface.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.brandRed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.brandRed),
        ),
      ),
      dividerTheme: DividerThemeData(color: onSurface.withValues(alpha: 0.06), thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.brandNavy,
        contentTextStyle: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      ),
    );
  }
}
