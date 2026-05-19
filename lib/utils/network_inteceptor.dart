import 'dart:async';
import 'dart:ui' show VoidCallback;

import 'package:camino_ninja_flutter/utils/app_check_interceptor.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:remote_data/remote_data.dart';
import 'package:storage/storage.dart';

class NetworkInterceptor extends Interceptor {
  NetworkInterceptor({
    required Dio dio,
    required this.refreshInvoker,
    required this.getCredentialInvoker,
    this.logoutInvoker,
    this.notifyAuthChangedInvoker,
  }) : _dio = dio;

  final Future<LoginResponse?> Function(String refreshToken)
      refreshInvoker;
  final Future<CredentialEntity?> Function()
      getCredentialInvoker;

  /// Called when a refresh-token request itself fails,
  /// indicating the session is no longer valid.
  final Future<void> Function()? logoutInvoker;

  /// Called after a forced logout to notify the UI layer.
  final VoidCallback? notifyAuthChangedInvoker;

  final Dio _dio;

  // Ensures only a single refresh is performed when
  // multiple requests hit 401/expired
  static Completer<void>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final hasExplicitAuthHeader =
          options.headers['Authorization'] != null;

      // If caller sets Authorization (e.g., refresh call),
      // don't run refresh flow
      if (!hasExplicitAuthHeader) {
        final credential =
            await getCredentialInvoker.call();
        if (credential?.accessToken != null &&
            !credential.isAccessTokenValid) {
          await _refreshTokenSingleFlight();
        }
      }

      // If caller already set Authorization, don't override
      if (!hasExplicitAuthHeader) {
        final latestToken =
            (await getCredentialInvoker.call())?.accessToken;
        if (latestToken != null) {
          options.headers['Authorization'] =
              'Bearer $latestToken';
          options.headers.remove(appCheckHeader);
        }
      }
      handler.next(options);
    } catch (e) {
      handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If unauthorized, attempt a single-flight refresh
    // then retry once
    final statusCode = err.response?.statusCode;
    final alreadyRetried =
        err.requestOptions.extra['__ret'] == true;
    // Skip retry for the refresh call itself (to avoid infinite loop).
    // All other authenticated requests should attempt a refresh on 401.
    final isRefreshCall =
        err.requestOptions.path.contains('/refresh');
    if (statusCode == 401 &&
        !alreadyRetried &&
        !isRefreshCall) {
      try {
        await _refreshTokenSingleFlight();

        final newToken =
            (await getCredentialInvoker.call())?.accessToken;
        final failedRequest = err.requestOptions;
        failedRequest.headers['Authorization'] =
            newToken != null
                ? 'Bearer $newToken'
                : failedRequest.headers['Authorization'];
        failedRequest.headers.remove(appCheckHeader);
        failedRequest.extra['__ret'] = true;

        final response =
            await _dio.fetch<dynamic>(failedRequest);
        handler.resolve(response);
        return;
      } catch (e) {
        // Fall through to default error handling
      }
    }
    handler.next(err);
  }

  Future<void> _refreshTokenSingleFlight() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<void>();
    try {
      await _refreshTokenViaCallback();
      _refreshCompleter!.complete();
    } catch (e, _) {
      if (!_refreshCompleter!.isCompleted) {
        _refreshCompleter!.completeError(e);
      }
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> _refreshTokenViaCallback() async {
    final rt =
        (await getCredentialInvoker.call())?.refreshToken;
    if (rt == null) {
      return;
    }
    final result = await refreshInvoker(rt);

    // If refreshInvoker returns null, the refresh endpoint
    // returned 401/failure — force logout.
    if (result == null) {
      AppLogger.w(
        'Refresh token rejected — forcing logout',
      );
      await logoutInvoker?.call();
      notifyAuthChangedInvoker?.call();
      // Throw so the caller does NOT retry with cleared credentials
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/refresh'),
        type: DioExceptionType.unknown,
        error: 'Session expired — user logged out',
      );
    }
  }
}
