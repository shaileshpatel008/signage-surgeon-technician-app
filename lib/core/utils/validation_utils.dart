/// Form field validators, returning a user-facing error string or null.
class ValidationUtils {
  ValidationUtils._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required.';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required.';
    if (v.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  static String? otp(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter the 6-digit code.';
    if (v.length != 6 || int.tryParse(v) == null) return 'Enter a valid 6-digit code.';
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if ((value ?? '').trim().isEmpty) return '$field is required.';
    return null;
  }
}
