import 'dart:async';

import 'package:camino_ninja_flutter/app/app.dart';
import 'package:camino_ninja_flutter/app_env.dart';
import 'package:camino_ninja_flutter/bootstrap.dart';
import 'package:camino_ninja_flutter/di/dependency_injection.dart';
import 'package:camino_ninja_flutter/services/deep_link_service.dart';
import 'package:camino_ninja_flutter/services/notification_service.dart';
import 'package:chottu_link/chottu_link.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/sync_manager.dart';
import 'package:camino_ninja_flutter/utils/app_check_utils.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/network_util.dart';
import 'package:camino_ninja_flutter/utils/offline_map_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage/storage.dart';

/// Top-level background message handler for FCM.
///
/// Must be a top-level function (not a class method) so the
/// Flutter engine can invoke it when the app is in the background
/// or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();
  AppLogger.d(
    'Background message: ${message.messageId}',
    tag: 'FCM',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NetworkUtil().initialize();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  AppConfig.setFlavor(Flavor.production);
  await Firebase.initializeApp();

  await AppEnv.load(Flavor.production);
  await OfflineMapService.configureTileStore();
  MapboxOptions.setAccessToken(AppEnv.mapboxAccessToken);
  await GoogleSignIn.instance.initialize(
    serverClientId: AppEnv.googleWebClientId,
  );
  await ChottuLink.init(apiKey: AppEnv.chottuLinkApiKey);

  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode
        ? AppleProvider.debug
        : AppleProvider.appAttestWithDeviceCheckFallback,
  );

  await FirebaseAnalytics.instance
      .setAnalyticsCollectionEnabled(!kDebugMode);

  // Enable Firebase auto-refresh for optimal token
  // management. Errors here must NOT crash the app.
  String? appCheckToken = 'x';
  try {
    await FirebaseAppCheck.instance
        .setTokenAutoRefreshEnabled(true);
    appCheckToken =
        await FirebaseAppCheck.instance.getToken();
  } catch (e, stack) {
    AppLogger.e(
      'Error getting app check token',
      error: e,
    );
    unawaited(
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        fatal: false,
      ),
    );
  }

  // Listen for token-refresh errors and record them as
  // non-fatal so they don't reach PlatformDispatcher.
  FirebaseAppCheck.instance.onTokenChange.listen(
    (_) {
      // Token refreshed successfully — nothing to do.
    },
    onError: (Object error, StackTrace stack) {
      AppLogger.e(
        'App Check token refresh error (non-fatal)',
        error: error,
        stackTrace: stack,
      );
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: false,
      );
    },
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance
        .recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't
  // handled by the Flutter framework to Crashlytics.
  // App Check / Play Integrity errors are recorded as
  // non-fatal to prevent them from appearing as crashes.
  PlatformDispatcher.instance.onError = (error, stack) {
    if (isAppCheckError(error)) {
      AppLogger.e(
        'App Check async error (non-fatal)',
        error: error,
        stackTrace: stack,
      );
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: false,
      );
      return true;
    }
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
    );
    return true;
  };

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  setupDependencies(
    appCheckToken: appCheckToken,
    baseUrl: AppEnv.baseUrl,
  );

  GetIt.instance
    ..registerLazySingleton<NotificationService>(
      () => NotificationService(router: appRouter),
      dispose: (service) => service.dispose(),
    )
    ..registerLazySingleton<DeepLinkService>(
      () => DeepLinkService(router: appRouter),
      dispose: (service) => service.dispose(),
    );

  const key = 'hasRunBefore';
  final prefs = await SharedPreferences.getInstance();

  if (prefs.getBool(key) != true) {
    await GetIt.instance<AppPreferences>().clearAll();
    await prefs.setBool(key, true);
  }

  GetIt.instance<SyncManager>().start();
  await GetIt.instance<NotificationService>().initListeners();
  GetIt.instance<DeepLinkService>().initListeners();

  await bootstrap(App.new);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    GetIt.instance<DeepLinkService>().markReady();
  });
}
