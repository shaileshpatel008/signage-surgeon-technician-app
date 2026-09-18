import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/common_utils.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loader.dart';
// Bottom nav hidden for the client demo (needs to track the web flow
// exactly for now) — import kept, not removed.
// import '../../../shared/widgets/app_bottom_nav.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/job_card.dart';

/// Strict web parity — a 1:1 rebuild of `LabourDashboard` in
/// `labour/page.tsx`. Header, grouping, card fields, OTP flow: all match.
/// The only additions (bottom nav, bell icon, card overflow menu) are the
/// client-approved "full app" extras layered *around* this screen, never
/// inside it. The header band itself is presentation only — same "My
/// Work" + technician name data as before, just styled to match the
/// splash/login navy treatment instead of a bare default AppBar.
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.brandOffwhite,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: _DashboardHeader(controller: controller),
        ),
        // Hidden for the client demo (needs to track the web flow exactly
        // for now) — not removed, just commented out.
        // bottomNavigationBar: const AppBottomNav(currentIndex: 0),
        body: SafeArea(
          top: false,
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
      ),
    );
  }
}

/// Navy header band — same data the old plain AppBar showed (greeting +
/// technician name, notifications, sign out), just laid out to match the
/// brand treatment already used on Splash/Login/Profile instead of a bare
/// default AppBar.
class _DashboardHeader extends StatelessWidget {
  final DashboardController controller;
  const _DashboardHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.brandNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppDimensions.radiusXl)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 16, 18),
          child: Obx(() {
            final name = controller.admin.value?.name;
            final firstName = (name == null || name.isEmpty) ? 'Technician' : name.split(' ').first;

            return Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: AppColors.brandRed,
                  child: Text(
                    CommonUtils.initials(name ?? 'T'),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hi, $firstName',
                        style: AppTextStyles.h3.copyWith(color: AppColors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Technician · My Work',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                _HeaderIconButton(
                  icon: Icons.notifications_outlined,
                  tooltip: 'Notifications',
                  onTap: () => Get.toNamed(Routes.notifications),
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.logout_rounded,
                  tooltip: 'Sign Out',
                  onTap: controller.signOut,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(icon, size: 18, color: AppColors.white),
        ),
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
