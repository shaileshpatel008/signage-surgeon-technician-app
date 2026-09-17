import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

/// Centralized dialog/snackbar/toast helpers built on GetX overlays, so
/// controllers never need a BuildContext to surface feedback.
class AppDialog {
  AppDialog._();

  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool danger = false,
  }) async {
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(message, style: AppTextStyles.body),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: cancelLabel,
                      variant: AppButtonVariant.outline,
                      onPressed: () => Get.back(result: false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: confirmLabel,
                      onPressed: () => Get.back(result: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
    return result ?? false;
  }

  static void success(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: AppDimensions.radiusMd,
      icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
    );
  }

  static void error(String message) {
    Get.snackbar(
      'Something went wrong',
      message,
      backgroundColor: AppColors.brandRed,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: AppDimensions.radiusMd,
      icon: const Icon(Icons.error_outline, color: AppColors.white),
      duration: const Duration(seconds: 4),
    );
  }

  static void info(String message) {
    Get.snackbar(
      'Note',
      message,
      backgroundColor: AppColors.brandNavy,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: AppDimensions.radiusMd,
    );
  }
}
