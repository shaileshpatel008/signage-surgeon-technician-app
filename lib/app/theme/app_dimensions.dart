/// Centralized spacing / radius / sizing scale used across the app.
/// Keep every screen pulling from here instead of hardcoding magic numbers,
/// so density changes happen in one place.
class AppDimensions {
  AppDimensions._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 40;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusPill = 999;

  static const double iconSm = 14;
  static const double iconMd = 18;
  static const double iconLg = 24;

  static const double buttonHeight = 50;
  static const double inputHeight = 48;
  static const double touchTargetMin = 44;

  static const double cardElevation = 0; // flat cards w/ hairline border, matches web
}
