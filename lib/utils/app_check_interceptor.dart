import 'dart:async';

import 'package:camino_ninja_flutter/app_env.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/jwt_util.dart';
import 'package:dio/dio.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

const String defaultAppCheckToken = 'x';
const String appCheckHeader = 'x-firebase-appcheck';
const String byPassAppCheckHeader = 'x-firebase-appcheck-b';

class AppCheckInterceptor extends Interceptor {
  AppCheckInterceptor({
    required this.isAuthenticatedInvoker,
    this.appCheckToken,
  });

  final Future<bool> Function() isAuthenticatedInvoker;
  final String? appCheckToken;

  // Current token (updated after refresh)
  String? _currentToken;

  // Single-flight pattern to prevent multiple concurrent refreshes
  static Completer<String?>? _refreshCompleter;

  // Cooldown after refresh failure to avoid hammering Play Integrity
  static const _refreshCooldown = Duration(seconds: 60);
  static DateTime? _lastRefreshFailureAt;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final isAuthenticated = await isAuthenticatedInvoker.call();
      if (isAuthenticated) {
        handler.next(options);
        return;
      }

      // Use current token or fallback to initial token
      var token = _currentToken ?? appCheckToken;

      // If we have a token, check if it's expired
      if (token != null && token != defaultAppCheckToken) {
        if (_isTokenExpired(token)) {
          AppLogger.d('App Check token expired, refreshing...');
          final refreshedToken = await _refreshTokenSingleFlight();
          if (refreshedToken != null) {
            _currentToken = refreshedToken;
            token = refreshedToken;
          }
        }
      }

      // Set the token (or 'x' if null/expired)
      options.headers[appCheckHeader] =
          token ?? defaultAppCheckToken;
    } catch (e) {
      AppLogger.e(
        'Error in App Check interceptor',
        error: e,
      );
      options.headers[appCheckHeader] = defaultAppCheckToken;
    }
    options.headers[byPassAppCheckHeader] = AppEnv.byPassAppCheck;
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    // Only handle 401/403 for unauthenticated requests (App Check).
    // Authenticated requests (with Authorization header) are handled
    // by NetworkInterceptor — don't interfere.
    final hasAuthHeader =
        err.requestOptions.headers['Authorization'] != null;
    if ((statusCode == 401 || statusCode == 403) &&
        !hasAuthHeader &&
        !_isRefreshInProgress()) {
      final alreadyRetried =
          err.requestOptions.extra['__app_check_ret'] == true;

      if (!alreadyRetried) {
        try {
          AppLogger.d(
            '401/403 error received, '
            'refreshing App Check token...',
          );
          final refreshedToken =
              await _refreshTokenSingleFlight();

          // Update current token
          if (refreshedToken != null) {
            _currentToken = refreshedToken;
          }

          // Retry the request with fresh token
          final failedRequest = err.requestOptions;
          if (refreshedToken != null) {
            failedRequest.headers[appCheckHeader] =
                refreshedToken;
          }
          failedRequest.extra['__app_check_ret'] = true;

          final response =
              await Dio().fetch<dynamic>(failedRequest);
          handler.resolve(response);
          return;
        } catch (e) {
          AppLogger.e(
            'App Check token refresh failed',
            error: e,
          );
          // Fall through to default error handling
        }
      }
    }

    handler.next(err);
  }

  /// Check if token is expired by extracting JWT expiration
  bool _isTokenExpired(String token) {
    try {
      final expiration = JwtUtil.getTokenExpiration(token);
      if (expiration == null) return true;

      // Check if token expires within 60 seconds
      final now = DateTime.now();
      final bufferTime =
          now.add(const Duration(seconds: 60));

      return bufferTime.isAfter(expiration);
    } catch (e) {
      AppLogger.e(
        'Error checking token expiration',
        error: e,
      );
      return true; // Assume expired if we can't check
    }
  }

  /// Whether we are still within the cooldown period after
  /// a previous refresh failure.
  bool _isInCooldown() {
    if (_lastRefreshFailureAt == null) return false;
    return DateTime.now().difference(_lastRefreshFailureAt!)
        < _refreshCooldown;
  }

  /// Check if refresh is in progress
  bool _isRefreshInProgress() {
    return _refreshCompleter != null &&
        !_refreshCompleter!.isCompleted;
  }

  /// Single-flight token refresh with cooldown on failure.
  Future<String?> _refreshTokenSingleFlight() async {
    // Skip refresh if we recently failed (cooldown)
    if (_isInCooldown()) {
      AppLogger.d(
        'App Check refresh skipped — '
        'cooldown active after recent failure',
      );
      return _currentToken ?? appCheckToken;
    }

    if (_refreshCompleter != null) {
      // Wait for ongoing refresh and return the result
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();
    try {
      // Force refresh the token
      final newToken =
          await FirebaseAppCheck.instance.getToken(true);
      _refreshCompleter!.complete(newToken);
      _lastRefreshFailureAt = null; // Reset on success
      AppLogger.d('App Check token refreshed successfully');
      return newToken;
    } catch (e) {
      _lastRefreshFailureAt = DateTime.now();
      AppLogger.e(
        'Error refreshing App Check token',
        error: e,
      );
      if (!_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(null);
      }
      // Return existing token instead of rethrowing to
      // avoid cascading failures
      return _currentToken ?? appCheckToken;
    } finally {
      _refreshCompleter = null;
    }
  }
}
