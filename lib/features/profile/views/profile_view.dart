import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/common_utils.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../data/models/admin_user_model.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/proposed_addition_banner.dart';
import '../controllers/profile_controller.dart';
import 'change_password_sheet.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandOffwhite,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            const ProposedAdditionBanner(),
            Expanded(
              child: Obx(() {
                if (controller.loading.value) return const AppLoader();
                final admin = controller.admin.value;
                if (admin == null) return const SizedBox.shrink();

                return ListView(
                  children: [
                    Container(
                      width: double.infinity,
                      color: AppColors.brandNavy,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 37,
                            backgroundColor: AppColors.brandRed,
                            child: Text(
                              CommonUtils.initials(admin.name),
                              style: AppTextStyles.h1.copyWith(color: AppColors.white),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(admin.name, style: AppTextStyles.h3.copyWith(color: AppColors.white)),
                          const SizedBox(height: 3),
                          Text('Technician', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoCard(admin: admin),
                          const SizedBox(height: 18),
                          Text('ACCOUNT', style: AppTextStyles.caption),
                          const SizedBox(height: 10),
                          _MenuCard(
                            children: [
                              _MenuRow(
                                icon: Icons.person_outline_rounded,
                                label: 'Edit Profile',
                                onTap: () => Get.toNamed(Routes.editProfile),
                              ),
                              _MenuRow(
                                icon: Icons.lock_outline_rounded,
                                label: 'Change Password',
                                onTap: () => showChangePasswordSheet(context, controller),
                              ),
                              _MenuRow(
                                icon: Icons.notifications_outlined,
                                label: 'Notifications',
                                onTap: () => Get.toNamed(Routes.notifications),
                              ),
                              _MenuRow(
                                icon: Icons.settings_outlined,
                                label: 'App Settings',
                                onTap: () => Get.toNamed(Routes.settings),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: controller.signOut,
                            icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.brandRed),
                            label: const Text('Log Out', style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.brandRed),
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AdminUserModel admin;
  const _InfoCard({required this.admin});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _MenuRow(icon: Icons.mail_outline_rounded, label: admin.email, onTap: null),
          _MenuRow(icon: Icons.phone_outlined, label: CommonUtils.orDash(admin.phone), onTap: null),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.brandNavy),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            if (onTap != null) const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}
