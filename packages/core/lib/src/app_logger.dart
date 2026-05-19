import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Application-wide logger utility using the logger package.
/// Provides colored console output with log levels.
///
/// Usage:
/// ```dart
/// AppLogger.d('Debug message');
/// AppLogger.i('Info message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message', error: e, stackTrace: st);
/// ```
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
    ),
    level: kDebugMode ? Level.debug : Level.warning,
  );

  /// Log a debug message (only in debug mode)
  static void d(String message, {String? tag}) {
    _logger.d(_formatMessage(tag, message));
  }

  /// Log an info message
  static void i(String message, {String? tag}) {
    _logger.i(_formatMessage(tag, message));
  }

  /// Log a warning message with optional error and stack trace
  static void w(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(
      _formatMessage(tag, message),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an error message with optional error and stack trace
  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(
      _formatMessage(tag, message),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _formatMessage(String? tag, String message) {
    if (tag != null) {
      return '[$tag] $message';
    }
    return message;
  }
}
