import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Full-body loading state — used while a controller's first fetch is
/// in flight (`RxStatus.loading()`).
class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.brandRed),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(message!, style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Small inline spinner for buttons/rows that shouldn't block the screen.
class AppInlineLoader extends StatelessWidget {
  final double size;
  const AppInlineLoader({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandRed),
    );
  }
}
