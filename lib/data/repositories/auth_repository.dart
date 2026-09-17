import '../../core/network/api_response.dart';
import '../../core/network/network_exception.dart';
import '../../core/services/logger_service.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/otp_api_datasource.dart';
import '../models/admin_user_model.dart';

/// High-level two-step login flow (password -> OTP), matching
/// `admin/login/page.tsx` step for step. Both steps return an
/// [ApiResult] so [LoginController] never needs a try/catch.
class AuthRepository {
  final FirebaseAuthDataSource _authDs;
  final OtpApiDataSource _otpDs;

  AuthRepository({required FirebaseAuthDataSource authDs, required OtpApiDataSource otpDs})
      : _authDs = authDs,
        _otpDs = otpDs;

  /// Step 1: verify password + role, then send the login OTP email.
  Future<ApiResult<AdminUserModel>> sendCredentialsAndOtp({required String email, required String password}) async {
    try {
      final admin = await _authDs.validateCredentials(email: email, password: password);
      await _otpDs.sendLoginOtp(email);
      return ApiResult.success(admin);
    } on AuthException catch (e) {
      return ApiResult.failure(e.message);
    } on NetworkException catch (e) {
      return ApiResult.failure(e.message);
    } catch (e, st) {
      logger.error('sendCredentialsAndOtp failed', e, st);
      return const ApiResult.failure('Something went wrong. Please try again.');
    }
  }

  /// Step 2: verify the OTP, then sign back in for real.
  Future<ApiResult<AdminUserModel>> verifyOtpAndSignIn({
    required String email,
    required String password,
    required String otp,
  }) async {
    try {
      final error = await _otpDs.verifyLoginOtp(email: email, otp: otp);
      if (error != null) return ApiResult.failure(error);

      final admin = await _authDs.completeSignIn(email: email, password: password);
      return ApiResult.success(admin);
    } on AuthException catch (e) {
      return ApiResult.failure(e.message);
    } on NetworkException catch (e) {
      return ApiResult.failure(e.message);
    } catch (e, st) {
      logger.error('verifyOtpAndSignIn failed', e, st);
      return const ApiResult.failure("Something went wrong verifying your code.");
    }
  }

  Future<void> resendOtp(String email) => _otpDs.sendLoginOtp(email);

  Future<void> signOut() => _authDs.signOut();

  Future<AdminUserModel?> restoreSession() => _authDs.getCurrentAdminProfile();
}
