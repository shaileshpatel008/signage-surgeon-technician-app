import 'package:flutter_test/flutter_test.dart';
import 'package:signage_surgeon_technician/core/utils/validation_utils.dart';

void main() {
  group('ValidationUtils.email', () {
    test('rejects empty and malformed addresses', () {
      expect(ValidationUtils.email(''), isNotNull);
      expect(ValidationUtils.email('not-an-email'), isNotNull);
      expect(ValidationUtils.email('missing@domain'), isNotNull);
    });

    test('accepts a well-formed address', () {
      expect(ValidationUtils.email('tech@example.com'), isNull);
    });
  });

  group('ValidationUtils.password', () {
    test('requires at least 6 characters', () {
      expect(ValidationUtils.password('12345'), isNotNull);
      expect(ValidationUtils.password('123456'), isNull);
    });
  });

  group('ValidationUtils.otp', () {
    test('requires exactly 6 digits', () {
      expect(ValidationUtils.otp('12345'), isNotNull);
      expect(ValidationUtils.otp('1234ab'), isNotNull);
      expect(ValidationUtils.otp('123456'), isNull);
    });
  });
}
