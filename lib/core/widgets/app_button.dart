import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

enum AppButtonVariant { primary, outline, text }

/// Reusable button with a built-in loading spinner so every async action
/// in the app shows the same disabled/loading affordance.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onPressed == null;

    final child = isLoading
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation(AppColors.white)),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: AppDimensions.iconMd), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(onPressed: disabled ? null : onPressed, child: child),
      AppButtonVariant.outline => OutlinedButton(onPressed: disabled ? null : onPressed, child: child),
      AppButtonVariant.text => TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(foregroundColor: AppColors.brandRed),
          child: child,
        ),
    };

    return SizedBox(width: width, height: AppDimensions.buttonHeight, child: button);
  }
}
