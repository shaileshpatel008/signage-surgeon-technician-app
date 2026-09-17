import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/proposed_addition_banner.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandOffwhite,
      appBar: AppBar(title: const Text('App Settings')),
      body: Column(
        children: [
          const ProposedAdditionBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text('PERMISSIONS', style: AppTextStyles.caption),
                const SizedBox(height: 10),
                _Card(
                  children: [
                    Obx(
                      () => _SwitchRow(
                        icon: Icons.place_outlined,
                        label: 'Location Access',
                        value: controller.locationGranted.value,
                        onChanged: controller.toggleLocation,
                      ),
                    ),
                    Obx(
                      () => _SwitchRow(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera Access',
                        value: controller.cameraGranted.value,
                        onChanged: controller.toggleCamera,
                      ),
                    ),
                    Obx(
                      () => _SwitchRow(
                        icon: Icons.bluetooth,
                        label: 'Bluetooth Access',
                        value: controller.bluetoothGranted.value,
                        onChanged: controller.toggleBluetooth,
                      ),
                    ),
                    Obx(
                      () => _SwitchRow(
                        icon: Icons.notifications_outlined,
                        label: 'Push Notifications',
                        value: controller.notificationsGranted.value,
                        onChanged: controller.toggleNotifications,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('PREFERENCES', style: AppTextStyles.caption),
                const SizedBox(height: 10),
                _Card(
                  children: [
                    Obx(
                      () => _SwitchRow(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark Mode',
                        value: controller.darkMode.value,
                        onChanged: controller.toggleDarkMode,
                      ),
                    ),
                    _NavRow(
                      icon: Icons.bluetooth_searching_rounded,
                      label: 'Device Diagnostics',
                      onTap: () => Get.toNamed(Routes.bluetoothDiagnostics),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('ABOUT', style: AppTextStyles.caption),
                const SizedBox(height: 10),
                _Card(
                  children: [
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.hasData
                            ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                            : '—';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Text('App Version', style: AppTextStyles.bodyMedium),
                              const Spacer(),
                              Text(version, style: AppTextStyles.bodySmall),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.brandRed),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}
