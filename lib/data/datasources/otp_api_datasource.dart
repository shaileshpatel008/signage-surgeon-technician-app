import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';

/// Talks to the same `/api/admin/send-otp` and `/api/admin/verify-otp`
/// Next.js routes the web admin login uses — see `route.ts` on web:
/// send-otp writes `otps/{purpose}_{email}` and emails a 6-digit code;
/// verify-otp checks it, is one-time-use, and expires after 10 minutes.
class OtpApiDataSource {
  final ApiClient _client;
  const OtpApiDataSource(this._client);

  Future<void> sendLoginOtp(String email) async {
    final response = await _client.post(
      ApiConstants.sendOtp,
      body: {'email': email, 'purpose': AppConstants.otpPurposeLogin},
    );
    if (response['error'] != null) {
      throw Exception(response['error']);
    }
  }

  /// Returns null when valid, otherwise the server's error message.
  Future<String?> verifyLoginOtp({required String email, required String otp}) async {
    final response = await _client.post(
      ApiConstants.verifyOtp,
      body: {'email': email, 'otp': otp, 'purpose': AppConstants.otpPurposeLogin},
    );
    if (response['valid'] == true) return null;
    return (response['error'] as String?) ?? "Couldn't verify code.";
  }
}
