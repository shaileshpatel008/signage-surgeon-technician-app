import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/bluetooth_service.dart';
import '../../../shared/widgets/proposed_addition_banner.dart';
import '../controllers/bluetooth_controller.dart';

class BluetoothView extends GetView<BluetoothController> {
  const BluetoothView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandOffwhite,
      appBar: AppBar(title: const Text('Device Diagnostics')),
      body: Column(
        children: [
          const ProposedAdditionBanner(),
          Container(
            width: double.infinity,
            color: const Color(0xFFFFF4D6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: const [
                Icon(Icons.science_outlined, size: 12, color: AppColors.warning),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Scanning & connecting are real. Diagnostic readings below are SIMULATED until the signage controller\'s BLE protocol is provided.',
                    style: TextStyle(fontSize: 9.5, color: AppColors.warning, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isConnected) return _ConnectedPanel(controller: controller);
              return _ScanPanel(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}

class _ScanPanel extends StatelessWidget {
  final BluetoothController controller;
  const _ScanPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.adapterStatus.value;
      final ready = status == BleStatus.ready;

      return ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (!ready)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
              child: Text(
                BluetoothAdapterService.instance.describeStatus(status),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.brandRed),
              ),
            ),
          if (ready) ...[
            Center(
              child: Column(
                children: [
                  Obx(
                    () => controller.scanning.value
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(color: AppColors.brandRed, strokeWidth: 2.5),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton.icon(
                              onPressed: controller.startScan,
                              icon: const Icon(Icons.bluetooth_searching_rounded, size: 16),
                              label: const Text('Scan for Controllers'),
                              style: ElevatedButton.styleFrom(minimumSize: const Size(220, 46)),
                            ),
                          ),
                  ),
                  Text('Keep your phone within 5–10m of the signage box', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.devices.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DEVICES FOUND (${controller.devices.length})', style: AppTextStyles.caption),
                  const SizedBox(height: 10),
                  ...controller.devices.map(
                    (device) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => controller.connect(device),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bluetooth, color: Color(0xFF2563EB)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(device.name, style: AppTextStyles.bodyMedium),
                                    Text('RSSI ${device.rssi} dBm', style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              Obx(
                                () => controller.connecting.value
                                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text('Connect', style: AppTextStyles.link),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      );
    });
  }
}

class _ConnectedPanel extends StatelessWidget {
  final BluetoothController controller;
  const _ConnectedPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bluetooth_connected_rounded, color: AppColors.success),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.connectedDeviceId.value ?? '', style: AppTextStyles.bodyMedium),
                    const Text('Connected', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              OutlinedButton(onPressed: controller.disconnect, child: const Text('Disconnect')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (controller.loadingDiagnostics.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: AppColors.brandRed)),
            );
          }
          final snapshot = controller.diagnostics.value;
          if (snapshot == null) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LIVE READINGS', style: AppTextStyles.caption),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.6,
                  children: [
                    _Reading('Firmware', snapshot.firmwareVersion),
                    _Reading('Battery Backup', '${snapshot.batteryBackupPercent}%'),
                    _Reading('Power Draw', '${snapshot.powerDrawWatts} W'),
                    _Reading('LED Channels', '${snapshot.ledChannelsOk} / ${snapshot.ledChannelsTotal} OK'),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Reading extends StatelessWidget {
  final String label;
  final String value;
  const _Reading(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
