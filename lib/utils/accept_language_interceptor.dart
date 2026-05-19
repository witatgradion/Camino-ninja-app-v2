import 'dart:io';

import 'package:dio/dio.dart';
import 'package:storage/storage.dart';

class AcceptLanguageInterceptor extends Interceptor {
  AcceptLanguageInterceptor({required AppPreferences appPreferences})
      : _appPreferences = appPreferences;

  final AppPreferences _appPreferences;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final language = await _appPreferences.getLanguage();

    final acceptLanguage = (language != null && language.isNotEmpty)
        ? language
        : Platform.localeName.split('_').first;
    if (acceptLanguage.isNotEmpty) {
      options.headers['Accept-Language'] = acceptLanguage;
    }
    handler.next(options);
  }
}
