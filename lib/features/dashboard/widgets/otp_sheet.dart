import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
///
/// For a job whose completion is the FINAL "completed" stage (backend
/// contract — see [JobModel.requiresCompletionPhotos]), also shows the
/// completion-photos step below the OTP row; Confirm uploads those photos
/// and writes `completionPhotos` + `trackingStage` together, so the OTP
/// check this panel always did stays exactly as it was.
class OtpSheet extends StatelessWidget {
  final JobModel job;
  final DashboardController controller;

  const OtpSheet({super.key, required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final needsPhotos = controller.otpMode.value == OtpMode.completion && job.requiresCompletionPhotos;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.brandOffwhite, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ask the customer for their ${controller.otpMode.value == OtpMode.arrival ? 'arrival' : 'completion'} code',
              style: AppTextStyles.bodyMedium,
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
                    decoration: InputDecoration(
                      // Was inheriting the input's own bold/letter-spaced
                      // style, which made "Enter code" far wider than this
                      // 130px field and forced an ugly wrap. Own hintStyle,
                      // shorter text, no extra tracking.
                      hintText: 'Code',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedText, letterSpacing: 0, fontWeight: FontWeight.w500),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
            if (needsPhotos) ...[
              const SizedBox(height: 12),
              _CompletionPhotosSection(controller: controller),
            ],
            Obx(() {
              final error = controller.otpError.value;
              return error == null
                  ? const SizedBox.shrink()
                  : Padding(padding: const EdgeInsets.only(top: 8), child: AppInlineError(message: error));
            }),
            if (needsPhotos)
              Obx(() {
                final error = controller.photosError.value;
                return error == null
                    ? const SizedBox.shrink()
                    : Padding(padding: const EdgeInsets.only(top: 8), child: AppInlineError(message: error));
              }),
          ],
        ),
      );
    });
  }
}

class _CompletionPhotosSection extends StatelessWidget {
  final DashboardController controller;
  const _CompletionPhotosSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Completion Photos (min $kMinCompletionPhotos, max $kMaxCompletionPhotos)', style: AppTextStyles.caption),
        const SizedBox(height: 8),
        Obx(() {
          final photos = controller.completionPhotos;
          final atMax = photos.length >= kMaxCompletionPhotos;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < photos.length; i++)
                _PhotoThumb(file: photos[i], onRemove: () => controller.removeCompletionPhoto(i)),
              if (!atMax)
                _AddPhotoButton(icon: Icons.camera_alt_outlined, onTap: () => controller.addCompletionPhoto(ImageSource.camera)),
              if (!atMax)
                _AddPhotoButton(
                  icon: Icons.photo_library_outlined,
                  onTap: () => controller.addCompletionPhoto(ImageSource.gallery),
                ),
            ],
          );
        }),
        Obx(() {
          if (!controller.confirmingOtp.value || controller.uploadProgressTotal.value == 0) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Uploading photo ${controller.uploadProgressDone.value} of ${controller.uploadProgressTotal.value}…',
              style: AppTextStyles.bodySmall,
            ),
          );
        }),
      ],
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  const _PhotoThumb({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: Image.file(file, width: 56, height: 56, fit: BoxFit.cover),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(color: AppColors.brandRed, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, size: 13, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AddPhotoButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(color: AppColors.brandNavy.withValues(alpha: 0.14)),
        ),
        child: Icon(icon, size: 20, color: AppColors.brandNavy.withValues(alpha: 0.6)),
      ),
    );
  }
}
