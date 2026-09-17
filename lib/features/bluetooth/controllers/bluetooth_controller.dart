import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import '../../../core/services/ble_service.dart';
import '../../../core/services/bluetooth_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/widgets/app_dialog.dart';

class BluetoothController extends GetxController {
  final BluetoothAdapterService _adapter = Get.find();
  final BleService _ble = Get.find();

  final Rx<BleStatus> adapterStatus = BleStatus.unknown.obs;
  final RxBool scanning = false.obs;
  final RxList<DiscoveredDevice> devices = <DiscoveredDevice>[].obs;
  final RxnString connectedDeviceId = RxnString();
  final RxBool connecting = false.obs;
  final Rxn<BleDiagnosticsSnapshot> diagnostics = Rxn<BleDiagnosticsSnapshot>();
  final RxBool loadingDiagnostics = false.obs;

  StreamSubscription<BleStatus>? _statusSub;
  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connectionSub;

  bool get isConnected => connectedDeviceId.value != null;

  @override
  void onInit() {
    super.onInit();
    _statusSub = _adapter.statusStream.listen((s) => adapterStatus.value = s);
    _adapter.currentStatus().then((s) => adapterStatus.value = s);
  }

  @override
  void onClose() {
    _statusSub?.cancel();
    _scanSub?.cancel();
    _connectionSub?.cancel();
    super.onClose();
  }

  Future<void> startScan() async {
    final granted = await PermissionService.instance.requestBluetooth();
    if (!granted) {
      AppDialog.error('Bluetooth permission is required to scan for devices.');
      return;
    }

    devices.clear();
    scanning.value = true;
    await _scanSub?.cancel();
    _scanSub = _ble.scanForDevices().listen(
      (device) {
        if (devices.indexWhere((d) => d.id == device.id) == -1) devices.add(device);
      },
      onError: (_) => scanning.value = false,
    );
  }

  Future<void> stopScan() async {
    await _scanSub?.cancel();
    scanning.value = false;
  }

  Future<void> connect(DiscoveredDevice device) async {
    await stopScan();
    connecting.value = true;
    await _connectionSub?.cancel();

    final completer = Completer<void>();
    _connectionSub = _ble.connect(device.id).listen(
      (update) async {
        if (update.connectionState == DeviceConnectionState.connected) {
          connectedDeviceId.value = device.id;
          connecting.value = false;
          if (!completer.isCompleted) completer.complete();
          await _loadDiagnostics(device.id);
        } else if (update.connectionState == DeviceConnectionState.disconnected) {
          connectedDeviceId.value = null;
          diagnostics.value = null;
        }
      },
      onError: (e) {
        connecting.value = false;
        AppDialog.error("Couldn't connect to ${device.name}.");
        if (!completer.isCompleted) completer.complete();
      },
    );
  }

  Future<void> _loadDiagnostics(String deviceId) async {
    loadingDiagnostics.value = true;
    diagnostics.value = await _ble.readDiagnostics(deviceId);
    loadingDiagnostics.value = false;
  }

  Future<void> disconnect() async {
    await _connectionSub?.cancel();
    connectedDeviceId.value = null;
    diagnostics.value = null;
  }
}
