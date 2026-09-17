import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/logger_service.dart';
import 'network_exception.dart';

/// Thin Dio wrapper for the handful of REST calls this app makes — today
/// that's just the shared OTP endpoints (`/api/admin/send-otp`,
/// `/api/admin/verify-otp`) on the same Next.js backend the web admin
/// panel uses. Everything else (jobs, profile) goes straight through the
/// Firebase SDKs, which don't need this client.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.debug('→ ${options.method} ${options.path}', options.data);
          handler.next(options);
        },
        onResponse: (response, handler) {
          logger.debug('← ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          logger.error('✖ ${error.requestOptions.path}', error.message);
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      return response.data ?? const {};
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }
}
