/// The technician app has no backend of its own for auth OTPs — it calls
/// the exact same Next.js API routes the web admin login uses
/// (`src/app/api/admin/send-otp` / `verify-otp` in the web repo), so a
/// technician's OTP flow is byte-for-byte identical on both platforms.
///
/// Override at build/run time for a staging backend, e.g.:
///   flutter run --dart-define=API_BASE_URL=https://staging.thesignagesurgeon.com
abstract class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://www.thesignagesurgeon.com',
  );

  static const String sendOtp = '/api/admin/send-otp';
  static const String verifyOtp = '/api/admin/verify-otp';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
