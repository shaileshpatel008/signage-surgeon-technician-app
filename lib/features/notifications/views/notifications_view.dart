import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../shared/widgets/proposed_addition_banner.dart';
import '../controllers/notifications_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart' show LoadStatus;

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandOffwhite,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: const Text('Mark all read', style: TextStyle(color: AppColors.brandRed, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          const ProposedAdditionBanner(),
          Expanded(
            child: Obx(() {
              switch (controller.status.value) {
                case LoadStatus.loading:
                  return const AppLoader();
                case LoadStatus.error:
                  return AppErrorWidget(message: "Couldn't load notifications.", onRetry: controller.refresh);
                case LoadStatus.empty:
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView(
                      children: const [
                        SizedBox(height: 60),
                        AppEmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: "You're all caught up",
                          subtitle: "New job assignments and updates will show up here.",
                        ),
                      ],
                    ),
                  );
                case LoadStatus.loaded:
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = controller.notifications[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.read ? AppColors.white : AppColors.dangerBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title, style: AppTextStyles.bodyMedium),
                                    const SizedBox(height: 3),
                                    Text(n.body, style: AppTextStyles.bodySmall),
                                    const SizedBox(height: 5),
                                    Text(AppDateUtils.timeAgo(n.createdAt), style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              if (!n.read) ...[
                                const SizedBox(width: 8),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(color: AppColors.brandRed, shape: BoxShape.circle),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
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
