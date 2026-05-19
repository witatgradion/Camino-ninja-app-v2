import 'dart:async';
import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/sync_manager.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/camino_util.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppCubit extends Cubit<AppState> with SafeEmitMixin {
  AppCubit() : super(const AppState());

  final Repository _repository = GetIt.instance<Repository>();
  final StagePlanRepository _stagePlanRepository =
      GetIt.instance<StagePlanRepository>();
  final AppDatabase _databaseHelper = GetIt.instance<AppDatabase>();

  Stream<bool> get shouldShowAppReviewStream =>
      stream.map((s) => s.shouldShowAppReview).distinct();

  Future<void> notifyAuthChanged() async {
    final isLoggedIn = await _repository.isAuthenticated();
    safeEmit(
      state.copyWithNoNull(
        authChangedAt: DateTime.now(),
        isLoggedIn: isLoggedIn,
      ),
    );

    // Trigger stage planner cloud sync regardless of which tab
    // is active — ensures sync happens immediately after login.
    unawaited(GetIt.instance<SyncManager>().syncIfNeeded());
    unawaited(refreshNotificationsBadge());
  }

  Future<void> refreshNotificationsBadge() async {
    try {
      final announcements = await _repository.getAnnouncements();
      final readIds = await _repository.getAnnouncementReadIds();
      final unreadAnnouncements = announcements
          .where((a) => !readIds.contains(a.id))
          .length;

      final credential = await _repository.getCredential();
      final loggedIn = credential?.accessToken != null &&
          credential!.accessToken!.isNotEmpty;

      var unreadInbox = 0;
      if (loggedIn) {
        try {
          unreadInbox = await _repository.getUserNotificationsUnreadCount();
        } catch (e, stackTrace) {
          AppLogger.e(
            'Error refreshing inbox unread count for badge',
            tag: 'AppCubit',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      final total = unreadAnnouncements + unreadInbox;
      safeEmit(
        state.copyWithNoNull(
          unreadNotificationsBadgeCount: total,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error refreshing notifications badge',
        tag: 'AppCubit',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> onChangeLanguage({
    required String language,
  }) async {
    await _repository.setLanguage(language);
    safeEmit(
      state.copyWith(
        language: language,
        selectedStartingPoint: state.selectedStartingPoint,
        selectedDestination: state.selectedDestination,
        plannedRoute: state.plannedRoute,
        routeStats: state.routeStats,
        routePoints: state.routePoints,
        selectedRoutePoints: state.selectedRoutePoints,
        altRoutePoints: state.altRoutePoints,
        dataUpdateAvailable: state.dataUpdateAvailable,
      ),
    );
  }

  Future<void> onSelectRoute({
    required int routeId,
  }) async {
    final route = await _repository.getRouteById(routeId);
    await _repository.setSelectedRoute(routeId);
    await _repository.clearSelectedStartCity();
    await _repository.clearSelectedEndCity();

    final routePoints = await _repository.getRoutePointsByRouteIdFromDb(
      routeId: routeId,
    );
    final altRoutePoints =
        await _repository.getAltRoutePointsWithValueByRouteId(
      routeId: routeId,
    );

    GetIt.instance<IAnalyticsService>().track(
      RouteSelectedEvent(
        routeId: route.id,
        routeName: route.routeName,
        routeSubName: route.routeSubName,
      ),
    );

    safeEmit(
      state.copyWith(
        selectedRoute: route,
        routeStats: route.calculateRouteStatistics(
          currentRoutePoints: routePoints,
        ),
        routePoints: routePoints,
        selectedRoutePoints: [],
        altRoutePoints: altRoutePoints,
        dataUpdateAvailable: state.dataUpdateAvailable,
      ),
    );
  }

  Future<void> onSelectStartingPoint({
    required int cityId,
  }) async {
    final city = await _repository.getCityByIdFromDb(
      cityId,
    );
    await _repository.setSelectedStartCity(cityId);
    await _repository.clearSelectedEndCity();
    GetIt.instance<IAnalyticsService>().track(
      StartingCitySelectedEvent(
        cityId: city.id,
        cityName: city.name,
      ),
    );
    safeEmit(
      state.copyWith(
        selectedStartingPoint: city,
        routeStats: state.selectedRoute!.calculateRouteStatistics(
          startingCity: city,
          currentRoutePoints: state.routePoints,
        ),
        routePoints: state.routePoints,
        selectedRoutePoints: [],
        altRoutePoints: state.altRoutePoints,
        dataUpdateAvailable: state.dataUpdateAvailable,
      ),
    );
  }

  Future<void> onSelectDestination({
    required int cityId,
    bool isFromCachedData = false,
  }) async {
    final city = await _repository.getCityByIdFromDb(
      cityId,
    );
    await _repository.setSelectedEndCity(cityId);
    final citiesOnRoute =
        await _repository.getCitiesByRouteIdFromDb(state.selectedRoute!.id);

    final filteredDestinations = citiesOnRoute.sublist(
      citiesOnRoute.indexWhere((c) => c.id == state.selectedStartingPoint!.id),
      citiesOnRoute.indexWhere((c) => c.id == city.id) + 1,
    );

    GetIt.instance<IAnalyticsService>().track(
      RoutePointsAtSelectDestinationEvent(
        routeId: state.selectedRoute!.id,
        routeName: state.selectedRoute!.routeName,
        routeSubName: state.selectedRoute?.routeSubName,
        cityId: city.id,
        cityName: city.name,
        routePointsCount: state.routePoints?.length,
      ),
    );

    var routePoints = state.routePoints ?? [];
    final routeId = state.selectedRoute?.id;
    if (routePoints.isEmpty && routeId != null) {
      // Try to reload route points
      routePoints = await _repository.getRoutePointsByRouteIdFromDb(
        routeId: routeId,
      );
      final altRoutePoints =
          await _repository.getAltRoutePointsWithValueByRouteId(
        routeId: routeId,
      );
      safeEmit(
        state.copyWith(
          routePoints: routePoints,
          altRoutePoints: altRoutePoints,
          dataUpdateAvailable: state.dataUpdateAvailable,
        ),
      );
    }

    final destinationData = await calculateCityDistances(
      filteredDestinations,
      state.routePoints ?? [],
      _databaseHelper,
    );

    GetIt.instance<IAnalyticsService>().track(
      DestinationCitySelectedEvent(
        cityId: city.id,
        cityName: city.name,
      ),
    );

    // Check if the user should show the app review after selecting the destination
    var shouldShowAppReview = false;
    final doNotAskInAppReview = await _repository.getDoNotAskInAppReview();
    if (!isFromCachedData) {
      final isDestinationCheckPoints =
          await _repository.getSelectDestinationCheckPoints();
      if (isDestinationCheckPoints == null) {
        await _repository.setSelectDestinationCheckPoints(
          DateTime.now(),
        );
      } else {
        shouldShowAppReview = await isEligibleForReview();
      }
    }
    shouldShowAppReview = shouldShowAppReview && !doNotAskInAppReview;

    final selectedRoutePoints = await _repository.getRoutePointsByRouteIdFromDb(
      routeId: state.selectedRoute!.id,
      startingCityId: state.selectedStartingPoint!.id,
      destCityId: cityId,
    );

    safeEmit(
      state.copyWith(
        selectedStartingPoint: state.selectedStartingPoint,
        selectedDestination: city,
        plannedRoute: destinationData,
        routeStats: state.selectedRoute!.calculateRouteStatistics(
          startingCity: state.selectedStartingPoint,
          destCity: city,
          currentRoutePoints: state.routePoints,
        ),
        routePoints: state.routePoints,
        selectedRoutePoints: selectedRoutePoints,
        altRoutePoints: state.altRoutePoints,
        dataUpdateAvailable: state.dataUpdateAvailable,
        shouldShowAppReview: shouldShowAppReview,
      ),
    );
  }

  Future<void> checkDataForUpdates() async {
    var hasNetwork = false;
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile)) {
        hasNetwork = true;
        final dataUpdate = await _repository.getLatestDataUpdate();
        final updateAvailable = dataUpdate.shouldUpdateRoutes ||
            dataUpdate.shouldUpdateRoutePoints ||
            dataUpdate.shouldUpdateAltRoutePoints ||
            dataUpdate.shouldUpdateCities ||
            dataUpdate.shouldUpdateAlbergues ||
            dataUpdate.shouldUpdateAlbergueUserImages;
        safeEmit(
          state.copyWithNoNull(
            dataUpdateAvailable: updateAvailable,
            language: state.language,
          ),
        );
      }
    } catch (e) {
      AppLogger.e('Error checking data for updates', tag: 'AppCubit', error: e);
    } finally {
      await _repository.updateCityAlbergueStatus();

      if (hasNetwork) {
        await _repository.fetchAndSaveAlberguesRating();
      }
    }
  }

  /// Helper to execute a fetch operation with progress tracking.
  /// Returns true if successful, false if failed.
  /// Always increments progress regardless of outcome.
  Future<bool> _fetchWithProgress(Future<void> Function() fetchFn) async {
    try {
      await fetchFn();
      return true;
    } catch (e) {
      AppLogger.e('Fetch operation failed', tag: 'AppCubit', error: e);
      return false;
    } finally {
      safeEmit(
        state.copyWithNoNull(
          loadingTotal: state.loadingTotal,
          loadingProgress: state.loadingProgress + 1,
        ),
      );
    }
  }

  Future<void> onFetchRoutes() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile)) {
        safeEmit(state.copyWithNoNull(
          updatingData: true,
          loadingTotal: 0,
          loadingProgress: 0,
        ),);

        try {
          final dataUpdate = await _repository.getLatestDataUpdate();

          final needOrdered = dataUpdate.shouldUpdateRoutes ||
              dataUpdate.shouldUpdateRoutePoints ||
              dataUpdate.shouldUpdateCities;
          var totalTasks = 0;
          if (needOrdered) totalTasks++;
          if (dataUpdate.shouldUpdateAltRoutePoints) totalTasks++;
          if (dataUpdate.shouldUpdateAlbergues) totalTasks++;
          if (dataUpdate.shouldUpdateAlbergueUserImages) {
            totalTasks++;
          }

          if (totalTasks == 0) {
            safeEmit(state.copyWithNoNull(
              loadingData: false,
              updatingData: false,
              dataUpdateAvailable: false,
              dataFetchCompletedAt: DateTime.now(),
            ),);
          } else {
            safeEmit(state.copyWithNoNull(
              loadingTotal: totalTasks,
              loadingProgress: 0,
            ),);

            // Launch all tasks in parallel —
            // _fetchWithProgress catches errors per-task
            // so Future.wait won't throw.
            final orderedFuture = needOrdered
                ? _fetchWithProgress(
                    () => _repository
                        .fetchAndSaveRoutesRoutePointsAndCitiesAtomically(
                      shouldUpdateRoutes: needOrdered,
                      shouldUpdateRoutePoints: needOrdered,
                      shouldUpdateCities: needOrdered,
                    ),
                  )
                : Future.value(true);
            final altRoutePointsFuture =
                dataUpdate.shouldUpdateAltRoutePoints
                    ? _fetchWithProgress(
                        _repository.fetchAndSaveAltRoutePoints,
                      )
                    : Future.value(true);
            final alberguesFuture =
                dataUpdate.shouldUpdateAlbergues
                    ? _fetchWithProgress(
                        _repository.fetchAndSaveAlbergues,
                      )
                    : Future.value(true);
            final albergueImagesFuture =
                dataUpdate.shouldUpdateAlbergueUserImages
                    ? _fetchWithProgress(
                        _repository.fetchAndSaveAlbergueUserImages,
                      )
                    : Future.value(true);

            final results = await Future.wait([
              orderedFuture,
              altRoutePointsFuture,
              alberguesFuture,
              albergueImagesFuture,
            ]);

            final orderedSuccess = results[0];
            final altRoutePointsSuccess = results[1];
            final alberguesSuccess = results[2];
            final albergueImagesSuccess = results[3];
            final allSucceeded = results.every((s) => s);
            final anySucceeded = results.any((s) => s);

            safeEmit(
              state.copyWithNoNull(
                loadingData: false,
                updatingData: false,
                dataUpdateAvailable: !allSucceeded,
                dataFetchCompletedAt: DateTime.now(),
              ),
            );

            // Post-sync cleanup in microtask
            await Future.microtask(() async {
              if (anySucceeded) {
                try {
                  _stagePlanRepository.clearCache();
                  await _stagePlanRepository
                      .validateStagePlanner();
                } catch (e, stackTrace) {
                  await _logException(e, stackTrace);
                }
              }

              try {
                if (allSucceeded) {
                  await _repository
                      .updateLatestDataUpdate();
                } else if (anySucceeded) {
                  await _repository
                      .updateLatestDataUpdatePartial(
                    routes:
                        orderedSuccess && needOrdered,
                    routePoints:
                        orderedSuccess && needOrdered,
                    cities:
                        orderedSuccess && needOrdered,
                    altRoutePoints:
                        altRoutePointsSuccess &&
                        dataUpdate
                            .shouldUpdateAltRoutePoints,
                    albergues:
                        alberguesSuccess &&
                        dataUpdate.shouldUpdateAlbergues,
                    albergueUserImages:
                        albergueImagesSuccess &&
                        dataUpdate
                            .shouldUpdateAlbergueUserImages,
                  );
                }
              } catch (e, stackTrace) {
                await _logException(e, stackTrace);
              }

              if (anySucceeded) {
                try {
                  await _repository
                      .updateCityAlbergueStatus();
                } catch (e, stackTrace) {
                  await _logException(e, stackTrace);
                }
                try {
                  await _validateCurrentAppState();
                } catch (e, stackTrace) {
                  await _logException(e, stackTrace);
                }
                try {
                  await _databaseHelper.analyze();
                } catch (e, stackTrace) {
                  await _logException(e, stackTrace);
                }
              }
            });
          }
        } catch (e, stackTrace) {
          await _logException(e, stackTrace);
          safeEmit(
            state.copyWithNoNull(
              loadingData: false,
              updatingData: false,
              dataUpdateAvailable: true,
            ),
          );
        }
      } else {
        if (await _repository.isDatabaseEmpty()) {
          safeEmit(
            state.copyWithNoNull(
              loadingData: false,
              updatingData: false,
              offlineAndNoData: true,
            ),
          );
          return;
        }
        safeEmit(
          state.copyWithNoNull(
            loadingData: false,
            updatingData: false,
          ),
        );
      }

      if (state.loadingData || state.updatingData) {
        safeEmit(
          state.copyWithNoNull(
            loadingData: false,
            updatingData: false,
            dataFetchCompletedAt: DateTime.now(),
          ),
        );
      }
    } catch (e, stackTrace) {
      await _logException(e, stackTrace);
      safeEmit(
        state.copyWithNoNull(
          loadRoutesError: e.toString(),
          loadingData: false,
          updatingData: false,
        ),
      );
    }
  }

  Future<void> onLoadCachedData() async {
    await loadShowNewLabelOnPlanTab();
    final cachedData = await _repository.loadCachedData();

    final analytics = GetIt.instance<IAnalyticsService>();
    final isLoggedIn = await _repository.isAuthenticated();
    safeEmit(state.copyWithNoNull(isLoggedIn: isLoggedIn));
    if (isLoggedIn) {
      final credential = await _repository.getCredential();
      analytics.setUserId(
        userId: credential?.user?.id?.toString(),
      );
    }

    var planCount = 0;
    var favoriteCount = 0;
    try {
      final planResult =
          await _stagePlanRepository.getAllStagePlans();
      planCount = planResult.completePlans.length +
          planResult.incompletePlans.length;
    } catch (e) {
      AppLogger.e('Error loading plan count', tag: 'AppCubit', error: e);
    }
    try {
      final favorites =
          await _databaseHelper.getFavoriteAlbergues();
      favoriteCount = favorites.length;
    } catch (e) {
      AppLogger.e('Error loading favorite count', tag: 'AppCubit', error: e);
    }
    final packageInfo = await PackageInfo.fromPlatform();

    analytics.setUserProperties({
      'language': cachedData.language ?? 'en',
      'unit_preference': cachedData.unit ?? 'km',
      'theme': cachedData.theme ?? 'system',
      'is_authenticated': isLoggedIn,
      'plan_count': planCount,
      'favorite_albergue_count': favoriteCount,
      'app_version': packageInfo.version,
    });

    await _loadCachedRoute(cachedData);
    await _loadCachedLanguage(cachedData);
    await _loadCachedUnit(cachedData);
    await _loadCachedTheme(cachedData);
    await checkDataForUpdates();
  }

  Future<void> _loadCachedLanguage(PreferenceData cachedData) async {
    if (cachedData.language != null) {
      await onChangeLanguage(language: cachedData.language!);
    }
  }

  Future<void> clearCache() async {
    await _repository.clearCache();
    safeEmit(const AppState());
  }

  Future<void> _loadCachedRoute(PreferenceData cachedData) async {
    final routeId = cachedData.selectedRouteId;
    if (routeId == null) return;
    final isRouteValid = await _repository.isRouteValid(routeId);
    if (!isRouteValid) {
      await _repository.clearSelectedRoute();
      await _repository.clearSelectedStartCity();
      await _repository.clearSelectedEndCity();
      return;
    }

    await onSelectRoute(routeId: routeId);
    await _loadCachedStartingPoint(cachedData, routeId);
  }

  Future<void> _loadCachedStartingPoint(
      PreferenceData cachedData, int routeId,) async {
    final startCityId = cachedData.selectedStartCityId;
    if (startCityId == null) return;

    final isStartCityValid = await _repository.cityExistsOnRoute(
      startCityId,
      routeId,
    );
    if (!isStartCityValid) {
      await _repository.clearSelectedStartCity();
      await _repository.clearSelectedEndCity();
      return;
    }

    final isStartPointOnRoute = await _isPointOnRoute(
      cachedData.selectedRouteId!,
      startCityId,
    );

    if (!isStartPointOnRoute) {
      await _repository.clearSelectedStartCity();
      await _repository.clearSelectedEndCity();
      return;
    }

    await onSelectStartingPoint(cityId: startCityId);
    await _loadCachedDestination(cachedData, routeId);
  }

  Future<void> _loadCachedDestination(
      PreferenceData cachedData, int routeId,) async {
    final endCityId = cachedData.selectedEndCityId;
    if (endCityId == null) return;

    final isEndCityValid = await _repository.cityExistsOnRoute(
      endCityId,
      routeId,
    );
    if (!isEndCityValid) {
      await _repository.clearSelectedEndCity();
      return;
    }

    final isEndPointOnRoute = await _isPointOnRoute(
      cachedData.selectedRouteId!,
      endCityId,
    );
    final isEndPointAfterStart = await _isEndAfterStart(
      cachedData.selectedRouteId!,
      cachedData.selectedStartCityId!,
      endCityId,
    );

    if (isEndPointOnRoute && isEndPointAfterStart) {
      await onSelectDestination(
        cityId: endCityId,
        isFromCachedData: true,
      );
    } else {
      await _repository.clearSelectedEndCity();
    }
  }

  Future<bool> _isPointOnRoute(int routeId, int cityId) async {
    final citiesOnRoute = await _repository.getCitiesByRouteIdFromDb(routeId);
    return citiesOnRoute.any((c) => c.id == cityId);
  }

  Future<bool> _isEndAfterStart(
      int routeId, int startCityId, int endCityId,) async {
    try {
      final citiesOnRoute = await _repository.getCitiesByRouteIdFromDb(routeId);
      final startCityIndex =
          citiesOnRoute.indexWhere((c) => c.id == startCityId);
      final endCityIndex = citiesOnRoute.indexWhere((c) => c.id == endCityId);
      return startCityIndex < endCityIndex;
    } catch (e) {
      return false;
    }
  }

  Future<void> onChangeUnit({
    required UnitEnum unit,
  }) async {
    await _repository.setUnit(unit.name);
    safeEmit(
      state.copyWith(
        unit: unit,
        selectedStartingPoint: state.selectedStartingPoint,
        selectedDestination: state.selectedDestination,
        plannedRoute: state.plannedRoute,
        routeStats: state.routeStats,
        routePoints: state.routePoints,
        selectedRoutePoints: state.selectedRoutePoints,
        altRoutePoints: state.altRoutePoints,
        dataUpdateAvailable: state.dataUpdateAvailable,
      ),
    );
  }

  Future<void> _loadCachedUnit(PreferenceData cachedData) async {
    final unit = UnitEnum.fromString(cachedData.unit);
    await onChangeUnit(unit: unit);
  }

  Future<void> onChangeTheme({
    required AppTheme theme,
  }) async {
    await _repository.setTheme(theme.name);
    safeEmit(
      state.copyWith(
        theme: theme,
        selectedStartingPoint: state.selectedStartingPoint,
        selectedDestination: state.selectedDestination,
        plannedRoute: state.plannedRoute,
        routeStats: state.routeStats,
        routePoints: state.routePoints,
        selectedRoutePoints: state.selectedRoutePoints,
        altRoutePoints: state.altRoutePoints,
        dataUpdateAvailable: state.dataUpdateAvailable,
      ),
    );
  }

  Future<void> _loadCachedTheme(PreferenceData cachedData) async {
    final theme = AppTheme.fromString(cachedData.theme);
    await onChangeTheme(theme: theme);
  }

  // If select destination check points is set, and the select destination
  // action in on next day, then the user is eligible for review
  Future<bool> isEligibleForReview() async {
    final selectDestinationCheckPoints =
        await _repository.getSelectDestinationCheckPoints();
    final showTimes = await _repository.getInAppReviewShowTimes();
    if (selectDestinationCheckPoints == null) return false;

    final customFibonacci = CaminoUtil.calculateCustomFibonacci(showTimes ?? 0);

    final now = DateTime.now();
    final nowDate = DateTime(
      now.year,
      now.month,
      now.day,
    );
    final checkPointDate = DateTime(
      selectDestinationCheckPoints.year,
      selectDestinationCheckPoints.month,
      selectDestinationCheckPoints.day + customFibonacci - 1,
    );
    // Check if current date is after the checkpoint date
    final isTheDayAfter = nowDate.isAfter(checkPointDate);
    return isTheDayAfter;
  }

  Future<void> loadShowNewLabelOnPlanTab() async {
    final showNewLabelOnPlanTab = await _repository.getShowNewLabelOnPlanTab();
    safeEmit(
      state.copyWithNoNull(
        showNewLabelOnPlanTab: showNewLabelOnPlanTab,
        dataUpdateAvailable: state.dataUpdateAvailable,
        loadingTotal: state.loadingTotal,
        loadingProgress: state.loadingProgress,
      ),
    );
  }

  Future<void> _validateCurrentAppState() async {
    final selectedRouteId = state.selectedRoute?.id;
    if (selectedRouteId == null) return;

    final isRouteValid = await _repository.isRouteValid(selectedRouteId);
    if (!isRouteValid) {
      await _repository.clearSelectedRoute();
      await _repository.clearSelectedStartCity();
      await _repository.clearSelectedEndCity();
      safeEmit(
        AppState(
          dataUpdateAvailable: state.dataUpdateAvailable,
          theme: state.theme,
          unit: state.unit,
          language: state.language,
          loadingData: state.loadingData,
          shouldShowAppReview: state.shouldShowAppReview,
          showNewLabelOnPlanTab: state.showNewLabelOnPlanTab,
          unreadNotificationsBadgeCount: state.unreadNotificationsBadgeCount,
        ),
      );
      return;
    }

    final selectedStartCityId = state.selectedStartingPoint?.id;
    if (selectedStartCityId == null) return;

    final isStartCityValid = await _repository.cityExistsOnRoute(
      selectedStartCityId,
      selectedRouteId,
    );
    if (!isStartCityValid) {
      await _clearStartEndCity();
      return;
    }
    final isStartCityOnRoute = await _isPointOnRoute(
      selectedRouteId,
      selectedStartCityId,
    );
    if (!isStartCityOnRoute) {
      await _clearStartEndCity();
      return;
    }

    final selectedEndCityId = state.selectedDestination?.id;
    if (selectedEndCityId == null) return;

    final isEndCityValid = await _repository.cityExistsOnRoute(
      selectedEndCityId,
      selectedRouteId,
    );
    if (!isEndCityValid) {
      await _clearEndCity();
      return;
    }
    final isEndCityOnRoute = await _isPointOnRoute(
      selectedRouteId,
      selectedEndCityId,
    );
    final isEndCityAfterStart = await _isEndAfterStart(
      selectedRouteId,
      selectedStartCityId,
      selectedEndCityId,
    );
    if (!isEndCityOnRoute || !isEndCityAfterStart) {
      await _clearEndCity();
      return;
    }
  }

  Future<void> _clearStartEndCity() async {
    await _repository.clearSelectedStartCity();
    await _repository.clearSelectedEndCity();
    safeEmit(
      state.copyWith(
        routeStats: state.selectedRoute!.calculateRouteStatistics(),
        routePoints: state.routePoints,
        altRoutePoints: state.altRoutePoints,
        dataUpdateAvailable: state.dataUpdateAvailable,
      ),
    );
  }

  Future<void> _clearEndCity() async {
    await _repository.clearSelectedEndCity();
    safeEmit(
      state.copyWith(
        routeStats: state.selectedRoute!.calculateRouteStatistics(),
        selectedStartingPoint: state.selectedStartingPoint,
        routePoints: state.routePoints,
        altRoutePoints: state.altRoutePoints,
        dataUpdateAvailable: state.dataUpdateAvailable,
      ),
    );
  }

  Future<void> _logException(Object e, StackTrace stackTrace) async {
    GetIt.instance<IAnalyticsService>().track(
      DataSyncExceptionEvent(
        error: e.toString(),
        stackTrace: stackTrace.toString(),
      ),
    );
  }
}
