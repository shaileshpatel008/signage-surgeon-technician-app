import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'logger_service.dart';

/// Adapter-level Bluetooth concerns: is the radio on, is it supported,
/// stream of state changes. Device scanning/connection/GATT operations
/// live in [BleService] — this class only answers "is Bluetooth usable
/// right now".
class BluetoothAdapterService {
  BluetoothAdapterService._();
  static final BluetoothAdapterService instance = BluetoothAdapterService._();

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  Stream<BleStatus> get statusStream => _ble.statusStream;

  Future<BleStatus> currentStatus() async {
    // statusStream emits the current status immediately on listen.
    return _ble.statusStream.first;
  }

  bool isReady(BleStatus status) => status == BleStatus.ready;

  String describeStatus(BleStatus status) {
    switch (status) {
      case BleStatus.ready:
        return 'Bluetooth is on and ready.';
      case BleStatus.poweredOff:
        return 'Turn on Bluetooth to scan for signage controllers.';
      case BleStatus.unauthorized:
        return 'Grant Bluetooth permission in Settings to continue.';
      case BleStatus.locationServicesDisabled:
        return 'Turn on Location Services — Android requires this for BLE scanning.';
      case BleStatus.unsupported:
        return 'This device does not support Bluetooth Low Energy.';
      case BleStatus.unknown:
        return 'Checking Bluetooth status…';
    }
  }

  void log(String message) => logger.debug('[BLE Adapter] $message');
}
