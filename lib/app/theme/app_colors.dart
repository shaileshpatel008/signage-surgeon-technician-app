import 'package:flutter/material.dart';

/// Brand palette — sampled 1:1 from the web app's `globals.css`
/// (`--brand-*` custom properties) so the technician app matches the
/// admin panel and public site exactly.
class AppColors {
  AppColors._();

  static const Color brandRed = Color(0xFFC92223);
  static const Color brandRedDark = Color(0xFFA91B1C);
  static const Color brandYellow = Color(0xFFFECC00);
  static const Color brandYellowDark = Color(0xFFE3B700);
  static const Color brandNavy = Color(0xFF0A1628);
  static const Color brandNavySoft = Color(0xFF16233D);
  static const Color brandOffwhite = Color(0xFFFAF9F6);
  static const Color brandGray = Color(0xFF6B7280);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0x1A16A34A);
  static const Color warning = Color(0xFF8A6D00);
  static const Color warningBg = Color(0x1FFECC00);
  static const Color danger = brandRed;
  static const Color dangerBg = Color(0x1AC92223);

  static const Color borderLight = Color(0x0F0A1628); // black/6% over navy
  static const Color mutedText = Color(0xFF9AA1AD);

  // Dark mode surfaces (Settings screen tweak — proposed addition)
  static const Color darkBg = Color(0xFF0E1420);
  static const Color darkSurface = Color(0xFF16233D);
}
