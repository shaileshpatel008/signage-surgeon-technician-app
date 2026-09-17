import 'package:permission_handler/permission_handler.dart';
import 'logger_service.dart';

/// Wraps `permission_handler` for the permissions this app actually needs:
/// - Location: "Directions" needs to know where the technician is (and a
///   future live-location share)
/// - Camera + Photos: work-proof photo upload
/// - Bluetooth (scan/connect): BLE device diagnostics
/// - Notifications: proposed push notifications
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  Future<bool> requestLocation() => _request(Permission.locationWhenInUse);

  Future<bool> requestCamera() => _request(Permission.camera);

  Future<bool> requestPhotos() => _request(Permission.photos);

  Future<bool> requestNotifications() => _request(Permission.notification);

  /// Android 12+ needs both scan + connect; iOS needs only the umbrella
  /// `bluetooth` permission. Requesting both is harmless on either OS.
  Future<bool> requestBluetooth() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetooth,
    ].request();
    return statuses.values.every((s) => s.isGranted || s.isLimited);
  }

  Future<bool> _request(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    final result = await permission.request();
    logger.debug('Permission ${permission.toString()} -> $result');
    return result.isGranted || result.isLimited;
  }

  Future<bool> isPermanentlyDenied(Permission permission) async {
    return (await permission.status).isPermanentlyDenied;
  }

  Future<void> openSettings() => openAppSettings();
}
