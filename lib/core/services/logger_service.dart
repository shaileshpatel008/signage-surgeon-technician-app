import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logging. Everything funnels through here instead of `print`
/// so it can be redirected to Crashlytics/Sentry later without touching
/// every call site, and so release builds stay quiet by default.
class LoggerService {
  LoggerService._();
  static final LoggerService instance = LoggerService._();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kReleaseMode ? Level.warning : Level.debug,
  );

  void debug(String message, [Object? data]) => _logger.d(data == null ? message : '$message | $data');

  void info(String message, [Object? data]) => _logger.i(data == null ? message : '$message | $data');

  void warning(String message, [Object? data]) => _logger.w(data == null ? message : '$message | $data');

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

final logger = LoggerService.instance;
