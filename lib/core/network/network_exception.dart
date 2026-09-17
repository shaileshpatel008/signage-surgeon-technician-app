import 'package:dio/dio.dart';

/// A normalized failure type every repository throws instead of leaking
/// raw Dio/Firebase exceptions up to the UI layer.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(this.message, {this.statusCode});

  factory NetworkException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('The request timed out. Check your connection and try again.');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection. Check your connection and try again.');
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        final serverMessage = data is Map && data['error'] is String ? data['error'] as String : null;
        return NetworkException(
          serverMessage ?? 'Something went wrong. Please try again.',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled.');
      default:
        return const NetworkException('Something went wrong. Please try again.');
    }
  }

  @override
  String toString() => message;
}

/// Thrown by [AuthRepository] for domain-specific auth failures (wrong
/// password, unrecognized role, etc.) — kept separate from
/// [NetworkException] since these are not transport-layer failures.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
