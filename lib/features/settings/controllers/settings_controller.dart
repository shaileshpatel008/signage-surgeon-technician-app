import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/storage_constants.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/storage/local_storage.dart';

class SettingsController extends GetxController {
  final PermissionService _permissionService = PermissionService.instance;
  final LocalStorage _storage = LocalStorage.instance;

  final RxBool locationGranted = false.obs;
  final RxBool cameraGranted = false.obs;
  final RxBool bluetoothGranted = false.obs;
  final RxBool notificationsGranted = false.obs;
  final RxBool darkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    darkMode.value = _storage.getBool(StorageKeys.themeMode, defaultValue: false);
    _refreshPermissionStatuses();
  }

  Future<void> _refreshPermissionStatuses() async {
    locationGranted.value = (await Permission.locationWhenInUse.status).isGranted;
    cameraGranted.value = (await Permission.camera.status).isGranted;
    bluetoothGranted.value = (await Permission.bluetoothScan.status).isGranted;
    notificationsGranted.value = (await Permission.notification.status).isGranted;
  }

  Future<void> toggleLocation(bool value) async {
    if (value) {
      locationGranted.value = await _permissionService.requestLocation();
    } else {
      await _permissionService.openSettings();
      await _refreshPermissionStatuses();
    }
  }

  Future<void> toggleCamera(bool value) async {
    if (value) {
      cameraGranted.value = await _permissionService.requestCamera();
    } else {
      await _permissionService.openSettings();
      await _refreshPermissionStatuses();
    }
  }

  Future<void> toggleBluetooth(bool value) async {
    if (value) {
      bluetoothGranted.value = await _permissionService.requestBluetooth();
    } else {
      await _permissionService.openSettings();
      await _refreshPermissionStatuses();
    }
  }

  Future<void> toggleNotifications(bool value) async {
    if (value) {
      notificationsGranted.value = await _permissionService.requestNotifications();
    } else {
      await _permissionService.openSettings();
      await _refreshPermissionStatuses();
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    darkMode.value = value;
    await _storage.setBool(StorageKeys.themeMode, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}
