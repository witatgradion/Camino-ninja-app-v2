import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Dio interceptor that logs network errors to Firebase Crashlytics.
/// Only logs safe, non-sensitive information (path, method, status code).
class CrashlyticsInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e(
      'Network request error: ${err.requestOptions.path}',
      tag: 'CrashlyticsInterceptor',
      error: err,
    );
    FirebaseCrashlytics.instance.recordError(
      err,
      err.stackTrace,
      reason: 'API Error: ${err.requestOptions.path}',
      information: [
        'Path: ${err.requestOptions.path}',
        'Method: ${err.requestOptions.method}',
        'Status Code: ${err.response?.statusCode ?? "N/A"}',
        'Error Type: ${err.type.name}',
        'Error Message: ${err.message ?? "No message"}',
      ],
    );
    handler.next(err);
  }
}
