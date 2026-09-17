import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text styles built on Poppins — the same `--font-poppins` family the web
/// app loads via `next/font/google`.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.brandNavy,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle h1 = _base(size: 24, weight: FontWeight.w800);
  static TextStyle h2 = _base(size: 20, weight: FontWeight.w800);
  static TextStyle h3 = _base(size: 17, weight: FontWeight.w700);
  static TextStyle h4 = _base(size: 15, weight: FontWeight.w700);

  static TextStyle bodyLarge = _base(size: 15, weight: FontWeight.w500);
  static TextStyle body = _base(size: 13.5, weight: FontWeight.w400);
  static TextStyle bodyMedium = _base(size: 13, weight: FontWeight.w600);
  static TextStyle bodySmall = _base(size: 12, weight: FontWeight.w500, color: AppColors.brandGray);

  static TextStyle caption = _base(size: 11, weight: FontWeight.w700, color: AppColors.brandGray, letterSpacing: 0.4);
  static TextStyle overline = _base(
    size: 10.5,
    weight: FontWeight.w700,
    color: AppColors.mutedText,
    letterSpacing: 0.5,
  );

  static TextStyle buttonText = _base(size: 14, weight: FontWeight.w700, color: AppColors.white);
  static TextStyle buttonTextOutline = _base(size: 12.5, weight: FontWeight.w700, color: AppColors.brandNavy);

  static TextStyle link = _base(size: 12.5, weight: FontWeight.w700, color: AppColors.brandRed);
}
