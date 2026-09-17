import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

/// Full-body error state with a Retry action — shown whenever a
/// repository call fails (`RxStatus.error()`).
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.dangerBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            child: const Icon(Icons.error_outline_rounded, size: 28, color: AppColors.brandRed),
          ),
          const SizedBox(height: 16),
          Text("Couldn't load this", textAlign: TextAlign.center, style: AppTextStyles.h4),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            AppButton(label: 'Retry', onPressed: onRetry, variant: AppButtonVariant.outline, width: 140),
          ],
        ],
      ),
    );
  }
}

/// Inline (non-full-screen) error banner — used for row-level failures
/// like a failed OTP confirm, matching the web app's red alert boxes.
class AppInlineError extends StatelessWidget {
  final String message;
  const AppInlineError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.brandRed),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: AppTextStyles.body.copyWith(color: AppColors.brandRed))),
        ],
      ),
    );
  }
}
