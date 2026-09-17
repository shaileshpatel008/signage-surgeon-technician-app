import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'logger_service.dart';

/// Device diagnostics is a **proposed addition** — nothing like it exists
/// in the web app today, and no signage-controller BLE protocol (service /
/// characteristic UUIDs) has been provided yet. This class implements the
/// real, generic parts (scanning, connecting, disconnecting) against
/// `flutter_reactive_ble` so the permission + connection flow genuinely
/// works on a device. [readDiagnostics] is a clearly-labeled placeholder
/// until real UUIDs are supplied — see the TODO below.
class BleService {
  BleService._();
  static final BleService instance = BleService._();

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<ConnectionStateUpdate>? _connectionSub;

  /// Devices are filtered by a name prefix so the scan list only shows
  /// signage controllers, not every nearby BLE device. Adjust once the
  /// hardware team confirms the real advertised name / service UUID.
  static const String deviceNamePrefix = 'SS-CTRL';

  Stream<DiscoveredDevice> scanForDevices() {
    logger.debug('[BLE] starting scan (prefix=$deviceNamePrefix)');
    return _ble.scanForDevices(withServices: const [], scanMode: ScanMode.balanced).where(
          (device) => device.name.isNotEmpty && device.name.toUpperCase().startsWith(deviceNamePrefix),
        );
  }

  Stream<ConnectionStateUpdate> connect(String deviceId) {
    logger.debug('[BLE] connecting to $deviceId');
    final stream = _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    );
    return stream;
  }

  Future<void> disconnect() async {
    await _connectionSub?.cancel();
    _connectionSub = null;
  }

  /// TODO(hardware-protocol): once the signage controller's real GATT
  /// service/characteristic UUIDs are known, replace this with actual
  /// `_ble.readCharacteristic(...)` calls. Until then this intentionally
  /// returns placeholder values — never present these as live telemetry
  /// in the UI without the "diagnostic data is simulated" notice.
  Future<BleDiagnosticsSnapshot> readDiagnostics(String deviceId) async {
    logger.warning('[BLE] readDiagnostics is a placeholder — no hardware protocol wired yet');
    await Future.delayed(const Duration(milliseconds: 400));
    return const BleDiagnosticsSnapshot(
      firmwareVersion: 'v2.3.1',
      batteryBackupPercent: 86,
      powerDrawWatts: 42.5,
      ledChannelsOk: 12,
      ledChannelsTotal: 12,
      isSimulated: true,
    );
  }
}

class BleDiagnosticsSnapshot {
  final String firmwareVersion;
  final int batteryBackupPercent;
  final double powerDrawWatts;
  final int ledChannelsOk;
  final int ledChannelsTotal;

  /// Always true until the real hardware protocol is wired — the UI must
  /// keep showing the "simulated" badge while this is true.
  final bool isSimulated;

  const BleDiagnosticsSnapshot({
    required this.firmwareVersion,
    required this.batteryBackupPercent,
    required this.powerDrawWatts,
    required this.ledChannelsOk,
    required this.ledChannelsTotal,
    required this.isSimulated,
  });
}
