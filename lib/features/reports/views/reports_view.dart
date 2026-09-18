import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/proposed_addition_banner.dart';
import '../controllers/reports_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart' show LoadStatus;

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandOffwhite,
      appBar: AppBar(title: const Text('My Performance')),
      // Hidden for the client demo — see dashboard_view.dart for why.
      // bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: Column(
        children: [
          const ProposedAdditionBanner(),
          Expanded(
            child: Obx(() {
              switch (controller.status.value) {
                case LoadStatus.loading:
                  return const AppLoader();
                case LoadStatus.error:
                  return AppErrorWidget(message: "Couldn't load your stats.", onRetry: controller.refresh);
                case LoadStatus.empty:
                case LoadStatus.loaded:
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        Row(
                          children: [
                            Expanded(child: _StatTile(value: '${controller.totalAssigned}', label: 'Total Assigned')),
                            const SizedBox(width: 10),
                            Expanded(child: _StatTile(value: '${controller.completedCount}', label: 'Completed')),
                            const SizedBox(width: 10),
                            Expanded(child: _StatTile(value: '${controller.upcomingCount}', label: 'Upcoming')),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('JOBS BY SERVICE TYPE', style: AppTextStyles.caption),
                              const SizedBox(height: 14),
                              if (controller.byService.isEmpty)
                                Text('No jobs assigned yet.', style: AppTextStyles.bodySmall)
                              else
                                ...controller.byService.entries.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 100, child: Text(entry.key, style: AppTextStyles.bodyMedium)),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(999),
                                            child: LinearProgressIndicator(
                                              value: entry.value / controller.maxServiceCount,
                                              minHeight: 8,
                                              backgroundColor: AppColors.borderLight,
                                              valueColor: const AlwaysStoppedAnimation(AppColors.brandRed),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text('${entry.value}', style: AppTextStyles.bodyMedium),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Card(
                          child: Row(
                            children: [
                              const Icon(Icons.star_border_rounded, color: AppColors.mutedText),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Average Rating', style: AppTextStyles.bodyMedium),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Not available yet — ratings aren\'t linked to a technician in the backend today.',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
              }
            }),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h2),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }
}
