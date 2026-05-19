import 'dart:convert';

import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:dio/dio.dart';

/// Custom Dio interceptor that logs HTTP requests and responses as grouped
/// entries.
///
/// Unlike the default [LogInterceptor] which logs each piece of information
/// separately, this interceptor collects all relevant data and logs it as a
/// single grouped message for better readability.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    this.requestHeader = false,
    this.requestBody = true,
    this.responseHeader = false,
    this.responseBody = true,
    this.maxBodyLength = 1000,
  });

  /// Whether to log request headers.
  final bool requestHeader;

  /// Whether to log request body.
  final bool requestBody;

  /// Whether to log response headers.
  final bool responseHeader;

  /// Whether to log response body.
  final bool responseBody;

  /// Maximum length of body to log (truncates if longer).
  final int maxBodyLength;

  static const _tag = 'HTTP';
  static const _divider = '─────────────────────────────────────────────────';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌$_divider')
      ..writeln('│ REQUEST')
      ..writeln('├$_divider')
      ..writeln('│ ${options.method} ${options.uri}');

    if (requestHeader) {
      buffer.writeln('│ Headers:');
      options.headers.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }

    if (requestBody && options.data != null) {
      buffer.writeln('│ Body:');
      final body = _formatBody(options.data);
      for (final line in body.split('\n')) {
        buffer.writeln('│   $line');
      }
    }

    buffer.write('└$_divider');

    AppLogger.d(buffer.toString(), tag: _tag);

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final buffer = StringBuffer()
      ..writeln('┌$_divider')
      ..writeln('│ RESPONSE [${response.statusCode}]')
      ..writeln('├$_divider')
      ..writeln('│ ${response.requestOptions.method} '
          '${response.requestOptions.uri}');

    if (responseHeader) {
      buffer.writeln('│ Headers:');
      response.headers.forEach((key, values) {
        buffer.writeln('│   $key: ${values.join(', ')}');
      });
    }

    if (responseBody && response.data != null) {
      buffer.writeln('│ Body:');
      final body = _formatBody(response.data);
      for (final line in body.split('\n')) {
        buffer.writeln('│   $line');
      }
    }

    buffer.write('└$_divider');

    AppLogger.d(buffer.toString(), tag: _tag);

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌$_divider')
      ..writeln('│ ERROR [${err.response?.statusCode ?? 'N/A'}]')
      ..writeln('├$_divider')
      ..writeln('│ ${err.requestOptions.method} ${err.requestOptions.uri}')
      ..writeln('│ Type: ${err.type}')
      ..writeln('│ Message: ${err.message}');

    if (err.response?.data != null) {
      buffer.writeln('│ Response Body:');
      final body = _formatBody(err.response?.data);
      for (final line in body.split('\n')) {
        buffer.writeln('│   $line');
      }
    }

    buffer.write('└$_divider');

    AppLogger.e(buffer.toString(), tag: _tag, error: err);

    handler.next(err);
  }

  String _formatBody(dynamic data) {
    try {
      if (data is Map || data is List) {
        final jsonString = const JsonEncoder.withIndent('  ').convert(data);
        return _truncate(jsonString);
      } else if (data is FormData) {
        final fields =
            data.fields.map((e) => '${e.key}: ${e.value}').join(', ');
        final files =
            data.files.map((e) => '${e.key}: ${e.value.filename}').join(', ');
        return 'FormData(fields: {$fields}, files: {$files})';
      } else {
        return _truncate(data.toString());
      }
    } catch (e) {
      return data.toString();
    }
  }

  String _truncate(String text) {
    if (text.length <= maxBodyLength) return text;
    return '${text.substring(0, maxBodyLength)}\n'
        '... [truncated ${text.length - maxBodyLength} chars]';
  }
}
