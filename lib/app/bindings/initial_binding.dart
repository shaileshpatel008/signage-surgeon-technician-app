import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/services/ble_service.dart';
import '../../core/services/bluetooth_service.dart';
import '../../core/services/permission_service.dart';
import '../../core/storage/local_storage.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_jobs_datasource.dart';
import '../../data/datasources/otp_api_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/jobs_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/profile_repository.dart';

/// Registered once in `main.dart` before `runApp` — every singleton the
/// app needs (storage, network, repositories) so features only ever
/// `Get.find<T>()` instead of constructing their own dependencies.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core singletons
    Get.put(LocalStorage.instance, permanent: true);
    Get.put(ApiClient.instance, permanent: true);
    Get.put(PermissionService.instance, permanent: true);
    Get.put(BluetoothAdapterService.instance, permanent: true);
    Get.put(BleService.instance, permanent: true);

    // Data sources
    Get.put(FirebaseAuthDataSource(), permanent: true);
    Get.put(FirestoreJobsDataSource(), permanent: true);
    Get.put(OtpApiDataSource(Get.find()), permanent: true);

    // Repositories
    Get.put(
      AuthRepository(authDs: Get.find(), otpDs: Get.find()),
      permanent: true,
    );
    Get.put(JobsRepository(dataSource: Get.find()), permanent: true);
    Get.put(ProfileRepository(), permanent: true);
    Get.put(NotificationsRepository(), permanent: true);
  }
}
