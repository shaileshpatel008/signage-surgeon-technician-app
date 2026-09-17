import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/notifications_repository.dart';
import '../../dashboard/controllers/dashboard_controller.dart' show LoadStatus;

class NotificationsController extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final NotificationsRepository _notificationsRepository = Get.find();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final Rx<LoadStatus> status = LoadStatus.loading.obs;

  String? _uid;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    status.value = LoadStatus.loading;
    final admin = await _authRepository.restoreSession();
    _uid = admin?.uid;
    if (_uid == null) {
      status.value = LoadStatus.error;
      return;
    }

    final result = await _notificationsRepository.fetchNotifications(_uid!);
    result.when(
      success: (items) {
        notifications.assignAll(items);
        status.value = items.isEmpty ? LoadStatus.empty : LoadStatus.loaded;
      },
      failure: (_) => status.value = LoadStatus.error,
    );
  }

  Future<void> refresh() => _load();

  Future<void> markAllRead() async {
    if (_uid == null) return;
    await _notificationsRepository.markAllRead(_uid!);
    notifications.assignAll(notifications.map((n) => n.read ? n : NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          createdAt: n.createdAt,
          read: true,
          relatedCollection: n.relatedCollection,
          relatedRequestId: n.relatedRequestId,
        )));
  }
}
