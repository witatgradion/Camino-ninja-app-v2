import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/app_env.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/repositories/offline_map_repository.dart';
import 'package:camino_ninja_flutter/services/login_reminder_session.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/stage_plan_share_service.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/sync_manager.dart';
import 'package:camino_ninja_flutter/utils/accept_language_interceptor.dart';
import 'package:camino_ninja_flutter/utils/app_check_interceptor.dart';
import 'package:camino_ninja_flutter/utils/auth_event_bus.dart';
import 'package:camino_ninja_flutter/utils/crashlytics_interceptor.dart';
import 'package:camino_ninja_flutter/utils/logging_interceptor.dart';
import 'package:camino_ninja_flutter/utils/network_inteceptor.dart';
import 'package:camino_ninja_flutter/utils/offline_map_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

final getIt = GetIt.instance;

void setupDependencies({
  required String baseUrl,
  String? appCheckToken,
}) {
  var minimumFetchInterval = const Duration(seconds: 30);
  if (AppConfig.flavor == Flavor.production) {
    minimumFetchInterval = const Duration(minutes: 5);
  }
  // Register Dio
  getIt
    ..registerLazySingleton<AppPreferences>(
      AppPreferences.new,
    )
    ..registerLazySingleton<AuthEventBus>(
      AuthEventBus.new,
      dispose: (bus) => bus.dispose(),
    )
    ..registerLazySingleton<LoginReminderSession>(
      LoginReminderSession.new,
    )
    ..registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      dio.interceptors.add(CrashlyticsInterceptor());
      dio.interceptors.add(
        AcceptLanguageInterceptor(
          appPreferences: getIt<AppPreferences>(),
        ),
      );
      dio.interceptors.add(
        AppCheckInterceptor(
          appCheckToken: appCheckToken,
          isAuthenticatedInvoker: () {
            return getIt<Repository>().isAuthenticated();
          },
        ),
      );
      dio.interceptors.add(
        NetworkInterceptor(
          dio: dio,
          refreshInvoker: (rt) async {
            final resp =
                await getIt<Repository>().refreshToken(
              refreshToken: rt,
            );
            return resp;
          },
          getCredentialInvoker: () =>
              getIt<Repository>().getCredential(),
          logoutInvoker: () =>
              getIt<Repository>().logout(),
          notifyAuthChangedInvoker: () {
            getIt<AuthEventBus>().emit(
              AuthEvent.sessionExpired,
            );
          },
        ),
      );
      if (kDebugMode) {
        dio.interceptors.add(
          LoggingInterceptor(
            requestHeader: true,
            responseHeader: true,
          ),
        );
      }
      return dio;
    })
    ..registerLazySingleton<IAnalyticsService>(
      () {
        final services = <IAnalyticsService>[
          AnalyticsService(
            supportedLocales: AppLocalizations.supportedLocales,
            firebaseAnalytics: FirebaseAnalytics.instance,
            appPreferences: getIt<AppPreferences>(),
          ),
        ];
        if (AppEnv.amplitudeApiKey.isNotEmpty) {
          services.add(
            AmplitudeAnalyticsService(
              apiKey: AppEnv.amplitudeApiKey,
            ),
          );
        }
        return CompositeAnalyticsService(services);
      },
    )
    ..registerLazySingleton<NetworkService>(
      () => NetworkService(getIt<Dio>()),
    )
    ..registerLazySingleton<FirebaseConfigDataSource>(
      () => FirebaseConfigDataSource(minimumFetchInterval),
    )
    ..registerLazySingleton<AppDatabase>(
      AppDatabase.new,
    )
    ..registerLazySingleton<StagePlannerDatabase>(
      StagePlannerDatabase.new,
    )
    ..registerLazySingleton<Repository>(
      () => Repository(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
      ),
    )
    ..registerLazySingleton<JunctionService>(
      () => JunctionService(getIt()),
    )
    ..registerLazySingleton<RoutePathFinder>(
      () => RoutePathFinder(
        repository: getIt(),
        junctionService: getIt(),
      ),
    )
    ..registerLazySingleton<StagePlanRepository>(
      () => StagePlanRepository(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
      ),
    )
    ..registerLazySingleton<StagePlanShareService>(
      () => StagePlanShareService(getIt(), getIt()),
    )
    ..registerLazySingleton<SyncManager>(
      () => SyncManager(getIt(), getIt(), getIt()),
    )
    ..registerLazySingleton<OfflineMapService>(
      OfflineMapService.new,
    )
    ..registerLazySingleton<OfflineMapRepository>(
      () => OfflineMapRepository(getIt()),
    );
}
