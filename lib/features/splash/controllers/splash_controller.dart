import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/repositories/auth_repository.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = Get.find();

  /// Guards against `Get.offAllNamed` firing twice — once from the normal
  /// bootstrap path and once from the manual tap fallback, if both land
  /// close together.
  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Minimum splash duration purely for brand presence — not a loading
    // gate. The real gate is the session restore below. Always waited out
    // in full even when the session restore finishes sooner, so the splash
    // never flashes by in well under a second on a fast connection.
    final minDelay = Future.delayed(const Duration(seconds: 3));

    try {
      // `restoreSession()` reads Firestore for a previously-signed-in
      // user. With no timeout, a stalled read (flaky connection, cold
      // start on a spotty network) leaves this screen waiting forever
      // with no way forward — a hard ceiling guarantees the app always
      // lands somewhere.
      final admin = await _authRepository.restoreSession().timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              logger.warning('Splash: restoreSession timed out, treating as signed out');
              return null;
            },
          );
      await minDelay;
      _goNext(admin != null);
    } catch (e, st) {
      logger.error('Splash bootstrap failed', e, st);
      await minDelay;
      _goNext(false);
    }
  }

  void _goNext(bool hasSession) {
    if (_navigated) return;
    _navigated = true;
    Get.offAllNamed(hasSession ? Routes.dashboard : Routes.login);
  }

  /// Manual fallback — tapping the splash screen sends you to Login
  /// immediately instead of waiting out the bootstrap/timeout. Session
  /// restore continues in the background regardless; if it resolves
  /// first, this is a no-op (see [_navigated]).
  void skipToLogin() => _goNext(false);
}
