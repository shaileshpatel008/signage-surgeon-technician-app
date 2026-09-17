import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../data/models/job_model.dart';
import '../controllers/dashboard_controller.dart';

/// Inline OTP confirmation panel — matches the web card's
/// "Ask the customer for their arrival/completion code" block, including
/// its Confirm/Cancel row and inline error text. Deliberately not a modal:
/// web renders this inside the same card, so this does too.
class OtpSheet extends StatelessWidget {
  final JobModel job;
  final DashboardController controller;

  const OtpSheet({super.key, required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.brandOffwhite, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              'Ask the customer for their ${controller.otpMode.value == OtpMode.arrival ? 'arrival' : 'completion'} code',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              SizedBox(
                width: 130,
                child: TextField(
                  controller: controller.otpTextController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h4.copyWith(letterSpacing: 3),
                  decoration: const InputDecoration(
                    hintText: 'Enter code',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.confirmingOtp.value ? null : () => controller.confirmOtp(job),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
                  child: controller.confirmingOtp.value
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Text('Confirm', style: TextStyle(fontSize: 11.5)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: controller.cancelOtp,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 14)),
                child: const Text('Cancel', style: TextStyle(fontSize: 11.5)),
              ),
            ],
          ),
          Obx(() {
            final error = controller.otpError.value;
            return error == null
                ? const SizedBox.shrink()
                : Padding(padding: const EdgeInsets.only(top: 8), child: AppInlineError(message: error));
          }),
        ],
      ),
    );
  }
}
