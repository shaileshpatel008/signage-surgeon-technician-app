import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/common_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/job_model.dart';
import '../../../shared/widgets/status_badge.dart';
import '../controllers/dashboard_controller.dart';
import 'otp_sheet.dart';

/// A literal port of `WorkCard` in `labour/page.tsx`: same fields, same
/// conditional actions, same inline (not modal) OTP entry.
class JobCard extends StatelessWidget {
  final JobModel job;
  final DashboardController controller;
  final bool muted;

  const JobCard({super.key, required this.job, required this.controller, this.muted = false});

  void _openDirections() {
    if (job.lat != null && job.lng != null) {
      MapsLauncher.launchCoordinates(job.lat!, job.lng!, job.address);
    } else if (job.address != null && job.address!.isNotEmpty) {
      MapsLauncher.launchQuery(job.address!);
    }
  }

  Future<void> _openPhoto(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: muted ? 0.7 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.brandNavy.withValues(alpha: 0.06)),
          // The old border-only look (6% navy, no shadow) barely read as
          // a card against the off-white background — this gives it real
          // elevation instead.
          boxShadow: [
            BoxShadow(
              color: AppColors.brandNavy.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.brandNavy.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge.forService(job.serviceLabel),
                const SizedBox(width: 8),
                Text(
                  job.visitLabel.toUpperCase(),
                  style: AppTextStyles.overline,
                ),
                const Spacer(),
                Text(CommonUtils.formatStage(job.stage), style: AppTextStyles.bodyMedium),
                // Hidden for the client demo (needs to track the web flow
                // exactly for now) — not removed, _JobMoreMenu below is
                // still there to bring back later.
                // _JobMoreMenu(job: job),
              ],
            ),
            const SizedBox(height: 9),
            Text(job.title, style: AppTextStyles.h4),
            if (job.visitDate != null || job.visitTimeStart != null) ...[
              const SizedBox(height: 5),
              Text(
                [
                  if (job.visitDate != null) AppDateUtils.formatVisitDate(job.visitDate),
                  if (job.visitTimeStart != null)
                    job.visitTimeEnd != null ? '${job.visitTimeStart} – ${job.visitTimeEnd}' : job.visitTimeStart!,
                ].join(' · '),
                style: AppTextStyles.bodyMedium,
              ),
            ],
            if (job.address != null && job.address!.isNotEmpty) ...[
              const SizedBox(height: 7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.place_outlined, size: 13, color: AppColors.brandGray),
                  ),
                  const SizedBox(width: 5),
                  Expanded(child: Text(job.address!, style: AppTextStyles.bodySmall)),
                ],
              ),
            ],
            const SizedBox(height: 11),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (job.address != null || (job.lat != null && job.lng != null))
                  OutlinedButton.icon(
                    onPressed: _openDirections,
                    icon: const Icon(Icons.navigation_outlined, size: 14),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: AppTextStyles.buttonTextOutline,
                    ),
                  ),
                if (job.canMarkArrived)
                  ElevatedButton(
                    onPressed: () => controller.openArrivalOtp(job),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 14)),
                    child: const Text('Mark Arrived', style: TextStyle(fontSize: 11.5)),
                  ),
                if (job.canMarkCompleted)
                  ElevatedButton(
                    onPressed: () => controller.openCompletionOtp(job),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 14)),
                    child: const Text('Mark Work Completed', style: TextStyle(fontSize: 11.5)),
                  ),
              ],
            ),
            if (job.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: job.photoUrls.asMap().entries.map((entry) {
                  return InkWell(
                    onTap: () => _openPhoto(entry.value),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_outlined, size: 13, color: AppColors.brandRed),
                        const SizedBox(width: 5),
                        Text('Photo ${entry.key + 1}', style: AppTextStyles.link),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            Obx(() {
              if (!controller.isOtpOpenFor(job)) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 11),
                child: OtpSheet(job: job, controller: controller),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Entry point into the two per-job **proposed-addition** screens (Photo
/// Upload, Quotation) — the web card has no equivalent menu since neither
/// feature exists there. Kept as a small overflow menu rather than a full
/// "Job Detail" page so the card itself still matches web exactly.
class _JobMoreMenu extends StatelessWidget {
  final JobModel job;
  const _JobMoreMenu({required this.job});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.brandGray),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'photos') Get.toNamed(Routes.photoUpload, arguments: job);
        if (value == 'quotation') Get.toNamed(Routes.quotation, arguments: job);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'photos',
          child: Row(
            children: [
              Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.brandNavy),
              SizedBox(width: 8),
              Text('Upload Work Photos', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        if (job.finalQuotation != null)
          const PopupMenuItem(
            value: 'quotation',
            child: Row(
              children: [
                Icon(Icons.description_outlined, size: 16, color: AppColors.brandNavy),
                SizedBox(width: 8),
                Text('View Quotation', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
      ],
    );
  }
}
