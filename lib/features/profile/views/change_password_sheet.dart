import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/profile_controller.dart';

void showChangePasswordSheet(BuildContext context, ProfileController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            Text('Change Password', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Current Password',
              controller: controller.currentPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'New Password',
              controller: controller.newPasswordController,
              obscureText: true,
              hint: 'At least 6 characters',
            ),
            const SizedBox(height: 20),
            Obx(
              () => AppButton(
                label: 'Update Password',
                isLoading: controller.changingPassword.value,
                onPressed: controller.changePassword,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
