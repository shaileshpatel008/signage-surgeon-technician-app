import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/repositories/auth_repository.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = Get.find();

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Minimum splash duration purely for brand presence — not a loading
    // gate. The real gate is the session restore below.
    final minDelay = Future.delayed(const Duration(milliseconds: 900));

    try {
      final admin = await _authRepository.restoreSession();
      await minDelay;

      if (admin != null) {
        Get.offAllNamed(Routes.dashboard);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } catch (e, st) {
      logger.error('Splash bootstrap failed', e, st);
      await minDelay;
      Get.offAllNamed(Routes.login);
    }
  }
}
