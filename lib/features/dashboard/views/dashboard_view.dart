import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/job_card.dart';

/// Strict web parity — a 1:1 rebuild of `LabourDashboard` in
/// `labour/page.tsx`. Header, grouping, card fields, OTP flow: all match.
/// The only additions (bottom nav, bell icon, card overflow menu) are the
/// client-approved "full app" extras layered *around* this screen, never
/// inside it.
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandOffwhite,
      appBar: AppBar(
        title: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Work'),
                  Text(
                    controller.admin.value?.name ?? '',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.notifications),
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: controller.signOut,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(
        child: Obx(() {
          switch (controller.status.value) {
            case LoadStatus.loading:
              return const AppLoader(message: 'Loading your assigned work…');
            case LoadStatus.error:
              return AppErrorWidget(message: controller.errorMessage.value ?? 'Something went wrong.', onRetry: controller.refresh);
            case LoadStatus.empty:
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  children: const [
                    AppEmptyState(icon: Icons.work_outline_rounded, title: 'No jobs assigned to you right now.'),
                  ],
                ),
              );
            case LoadStatus.loaded:
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _WorkGroup(title: 'Today', jobs: controller.todayJobs, controller: controller),
                    _WorkGroup(title: 'Upcoming', jobs: controller.upcomingJobs, controller: controller),
                    _WorkGroup(title: 'Completed', jobs: controller.completedJobs, controller: controller, muted: true),
                  ],
                ),
              );
          }
        }),
      ),
    );
  }
}

class _WorkGroup extends StatelessWidget {
  final String title;
  final List jobs;
  final DashboardController controller;
  final bool muted;

  const _WorkGroup({required this.title, required this.jobs, required this.controller, this.muted = false});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title (${jobs.length})', style: AppTextStyles.caption),
          const SizedBox(height: 10),
          ...jobs.map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobCard(job: job, controller: controller, muted: muted),
            ),
          ),
        ],
      ),
    );
  }
}
