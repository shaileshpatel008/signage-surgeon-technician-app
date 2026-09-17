import 'package:flutter/material.dart';

/// Small responsive/theme helpers so screens don't repeat
/// `MediaQuery.of(context).size` everywhere.
extension ContextExtensions on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isSmallPhone => screenWidth < 360;
  bool get isTablet => screenWidth >= 600;

  EdgeInsets get safePadding => MediaQuery.of(this).padding;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void showSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}
