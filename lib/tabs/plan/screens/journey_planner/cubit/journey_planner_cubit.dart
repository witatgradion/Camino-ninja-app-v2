import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'journey_planner_state.dart';

/// Cubit that drives the "Plan a Journey" wizard.
///
/// State machine:
///   initial -> loadingCities -> startCitySelection
///   -> destinationCitySelection -> loadingRoutes
///   -> routeOptions
///
/// Users pick a start city, then a destination city, and
/// the cubit computes journey options via [RoutePathFinder].
class JourneyPlannerCubit extends Cubit<JourneyPlannerState>
    with SafeEmitMixin {
  JourneyPlannerCubit() : super(const JourneyPlannerState());

  final RoutePathFinder _pathFinder = GetIt.instance<RoutePathFinder>();
  final JunctionService _junctionService = GetIt.instance<JunctionService>();
  final AppPreferences _appPreferences =
      GetIt.instance<AppPreferences>();
  final IAnalyticsService _analytics =
      GetIt.instance<IAnalyticsService>();

  static const _tag = 'JourneyPlannerCubit';

  /// Guard so we only apply the persisted threshold once
  /// per app lifetime (subsequent `init()` calls during
  /// reset must not reload from prefs).
  static bool _persistedThresholdApplied = false;

  /// Whether the app is in dark mode. Set from the widget
  /// layer so color resolution picks the right variant.
  bool isDark = false;

  // ── Public API ──────────────────────────────────────

  /// Loads all cities and routes, builds the graph, and
  /// transitions to start city selection.
  Future<void> init() async {
    try {
      safeEmit(
        state.copyWith(
          status: JourneyPlannerStatus.loadingCities,
        ),
      );

      await _junctionService.initialize();

      // Apply persisted junction distance threshold once
      // per app lifetime, before building the graph so the
      // first build honors the user's override.
      if (!_persistedThresholdApplied) {
        _persistedThresholdApplied = true;
        try {
          final persisted =
              await _appPreferences.getJunctionMaxDistanceMeters();
          if (persisted != null) {
            _pathFinder.setJunctionMaxDistanceMeters(persisted);
          }
        } catch (e, st) {
          AppLogger.w(
            'Failed to load persisted junction threshold',
            tag: _tag,
            error: e,
            stackTrace: st,
          );
        }
      }

      final graph = await _pathFinder.buildGraph();
      final allRoutes = graph.routeIndex.values.toList();

      // Collect all cities deduplicated, with route
      // names and route IDs.
      final cityMap = <int, CityEntity>{};
      final cityRouteNames = <int, List<String>>{};
      final cityRouteIds = <int, Set<int>>{};

      for (final route in allRoutes) {
        final cities = await _junctionService.getCitiesForRoute(route.id);
        for (final city in cities) {
          cityMap[city.id] = city;
          cityRouteNames.putIfAbsent(city.id, () => []).add(route.routeName);
          cityRouteIds.putIfAbsent(city.id, () => <int>{}).add(route.id);
        }
      }

      final allCities = cityMap.values.toList()
        ..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

      safeEmit(
        state.copyWith(
          status: JourneyPlannerStatus.startCitySelection,
          allCities: allCities,
          allRoutes: allRoutes,
          cityRouteNames: cityRouteNames,
          cityRouteIds: cityRouteIds,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Error initializing journey planner',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      safeEmit(
        state.copyWith(
          status: JourneyPlannerStatus.failure,
          errorMessage: () => '$e',
        ),
      );
    }
  }

  /// User selects a start city. Computes the sets of
  /// forward-reachable cities (direct and via-junction)
  /// and transitions to destination city selection.
  ///
  /// Reachability is position-aware:
  /// - "Direct" cities are those that come AFTER the
  ///   start city on a shared route.
  /// - "Via junction" cities lie on routes reachable by
  ///   taking a junction ahead of the start city. This
  ///   set is an approximation — the final path-finder
  ///   may still reject some cases, which surface as
  ///   "No routes found" after selection.
  Future<void> selectStartCity(CityEntity city) async {
    _analytics.track(
      JourneyPlannerStartCitySelectedEvent(cityId: city.id),
    );

    // Routes the start city is directly on.
    final direct = state.cityRouteIds[city.id] ?? const <int>{};

    // Cache city lists per route to avoid repeat lookups.
    final routeCities = <int, List<CityEntity>>{};

    Future<List<CityEntity>> citiesFor(int routeId) async {
      final cached = routeCities[routeId];
      if (cached != null) return cached;
      final cities = await _junctionService.getCitiesForRoute(routeId);
      routeCities[routeId] = cities;
      return cities;
    }

    // Compute start city index on each of its routes so
    // reachability BFS only follows forward junctions.
    final startCityIndices = <int, int>{};
    for (final routeId in direct) {
      try {
        final cities = await citiesFor(routeId);
        final idx = cities.indexWhere((c) => c.id == city.id);
        if (idx >= 0) {
          startCityIndices[routeId] = idx;
        }
      } catch (_) {
        // Best-effort; if lookup fails, that route
        // will use unconstrained reachability.
      }
    }

    // Map of routeId -> route name for quick lookup.
    final routeNameById = <int, String>{
      for (final r in state.allRoutes) r.id: r.routeName,
    };

    // Per-destination forward-walkable route names.
    final destinationRouteNames = <int, List<String>>{};

    void addRouteNameForCity(int cityId, int routeId) {
      final name = routeNameById[routeId];
      if (name == null) return;
      final list = destinationRouteNames.putIfAbsent(cityId, () => []);
      if (!list.contains(name)) list.add(name);
    }

    // Directly reachable: cities AFTER the start city on
    // each shared route (forward walking only).
    final directCities = <int>{};
    for (final routeId in direct) {
      final startIdx = startCityIndices[routeId];
      if (startIdx == null) continue;
      try {
        final cities = await citiesFor(routeId);
        for (var i = startIdx + 1; i < cities.length; i++) {
          final cityId = cities[i].id;
          directCities.add(cityId);
          addRouteNameForCity(cityId, routeId);
        }
      } catch (_) {
        // Skip this route on failure.
      }
    }

    // Routes reachable via a forward junction from the
    // start city's routes (BFS on ~20-30 nodes).
    Set<int> reachableRoutes;
    try {
      final graph = await _pathFinder.buildGraph();
      reachableRoutes = graph.findReachableRoutes(
        direct,
        startCityIndices: startCityIndices,
      );
    } catch (e, st) {
      AppLogger.w(
        'Error computing reachable routes',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      reachableRoutes = direct;
    }

    // Via-junction cities: every city on a non-direct
    // reachable route, excluding directly-reachable ones.
    // Approximation: doesn't verify junction-on-target is
    // before the city. False positives surface later as
    // "No routes found", which is acceptable UX.
    final viaJunctionCities = <int>{};
    final nonDirectRoutes = reachableRoutes.difference(direct);
    for (final routeId in nonDirectRoutes) {
      try {
        final cities = await citiesFor(routeId);
        for (final c in cities) {
          if (c.id == city.id) continue;
          if (!directCities.contains(c.id)) {
            viaJunctionCities.add(c.id);
          }
          // Pragmatic: include this route's name for any
          // city on it (matches the via-junction badge
          // approximation).
          addRouteNameForCity(c.id, routeId);
        }
      } catch (_) {
        // Skip this route on failure.
      }
    }

    safeEmit(
      state.copyWith(
        status: JourneyPlannerStatus.destinationCitySelection,
        startCity: () => city,
        endCity: () => null,
        journeyOptions: const [],
        directlyReachableCityIds: directCities,
        viaJunctionReachableCityIds: viaJunctionCities,
        destinationRouteNames: destinationRouteNames,
      ),
    );
  }

  /// User selects a destination city. Computes journey
  /// options via [RoutePathFinder] and transitions to
  /// route options display.
  Future<void> selectDestinationCity(
    CityEntity city,
  ) async {
    _analytics.track(
      JourneyPlannerDestinationSelectedEvent(cityId: city.id),
    );

    try {
      safeEmit(
        state.copyWith(
          status: JourneyPlannerStatus.loadingRoutes,
          endCity: () => city,
        ),
      );

      final options = await _pathFinder.findJourneyOptions(
        startCityId: state.startCity!.id,
        endCityId: city.id,
      );

      safeEmit(
        state.copyWith(
          status: JourneyPlannerStatus.routeOptions,
          journeyOptions: options,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Error computing journey options',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      safeEmit(
        state.copyWith(
          status: JourneyPlannerStatus.failure,
          errorMessage: () => '$e',
        ),
      );
    }
  }

  /// Builds a [MultiRouteTrail] from the selected
  /// [JourneyOption].
  Future<MultiRouteTrail?> buildTrailFromOption(
    JourneyOption option,
  ) async {
    _analytics.track(
      JourneyPlannerRouteOptionSelectedEvent(
        optionType: _optionTypeFor(option),
        positionIndex: state.journeyOptions.indexOf(option),
      ),
    );

    try {
      final segments = <TrailSegment>[];

      for (var i = 0; i < option.routes.length; i++) {
        final route = option.routes[i];

        // Determine segment boundaries.
        final segStartCityId =
            i == 0 ? option.startCityId : option.path.junctionCityIds[i - 1];
        final segEndCityId = i == option.routes.length - 1
            ? option.endCityId
            : option.path.junctionCityIds[i];

        final cities = await _junctionService.getCitiesForRoute(route.id);
        final startIdx = cities.indexWhere(
          (c) => c.id == segStartCityId,
        );
        final endIdx = cities.indexWhere(
          (c) => c.id == segEndCityId,
        );
        if (startIdx < 0 || endIdx < 0) return null;

        final lo = startIdx < endIdx ? startIdx : endIdx;
        final hi = startIdx < endIdx ? endIdx : startIdx;
        final segmentCities = cities.sublist(lo, hi + 1);

        segments.add(
          TrailSegment(
            routeId: route.id,
            routeName: route.routeName,
            routeSubName: route.routeSubName,
            colorValue: parseRouteColorValue(
              route,
              isDark: isDark,
            ),
            cityIds: segmentCities.map((c) => c.id).toList(),
            junctionCityId: i > 0 ? segStartCityId : null,
          ),
        );
      }

      if (segments.isEmpty) return null;
      return MultiRouteTrail(segments: segments);
    } catch (e, st) {
      AppLogger.e(
        'Error building trail from option',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Selects a journey option by index for map
  /// highlighting. Pass null to deselect.
  void selectOption(int? index) {
    safeEmit(
      state.copyWith(
        selectedOptionIndex: () => index,
      ),
    );
  }

  /// Goes back to start city selection, clearing the
  /// selected start city and reachability sets.
  void backToStartCity() {
    safeEmit(
      state.copyWith(
        status: JourneyPlannerStatus.startCitySelection,
        startCity: () => null,
        endCity: () => null,
        journeyOptions: const [],
        directlyReachableCityIds: const {},
        viaJunctionReachableCityIds: const {},
        destinationRouteNames: const {},
      ),
    );
  }

  /// Goes back to destination selection, clearing the
  /// end city and journey options.
  void backToDestination() {
    safeEmit(
      state.copyWith(
        status: JourneyPlannerStatus.destinationCitySelection,
        endCity: () => null,
        journeyOptions: const [],
        selectedOptionIndex: () => null,
      ),
    );
  }

  /// Resets the wizard to the initial loading state.
  Future<void> reset() async {
    safeEmit(const JourneyPlannerState());
    await init();
  }

  /// Current junction distance threshold (meters).
  double get currentThreshold =>
      _pathFinder.junctionMaxDistanceMeters;

  /// Maps a [JourneyOption]'s path to the analytics
  /// `option_type` vocabulary: `direct` for zero-junction
  /// paths, `via_junction` for one-junction paths, and
  /// `multi_trail` for two or more.
  String _optionTypeFor(JourneyOption option) {
    final junctions = option.path.junctionCount;
    if (junctions == 0) return 'direct';
    if (junctions == 1) return 'via_junction';
    return 'multi_trail';
  }

  /// Dev/staging only: updates the junction distance
  /// threshold, persists it, rebuilds the graph, and
  /// re-computes journey options for the currently
  /// selected start/end cities.
  Future<void> updateJunctionDistanceThreshold(
    double meters,
  ) async {
    try {
      await _appPreferences.setJunctionMaxDistanceMeters(meters);
    } catch (e, st) {
      AppLogger.w(
        'Failed to persist junction threshold',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
    }
    _pathFinder.setJunctionMaxDistanceMeters(meters);

    // If the user is on the route options screen, surface
    // a brief loading state and recompute options.
    final start = state.startCity;
    final end = state.endCity;
    if (start == null || end == null) return;

    try {
      safeEmit(
        state.copyWith(
          status: JourneyPlannerStatus.loadingRoutes,
          journeyOptions: const [],
          selectedOptionIndex: () => null,
        ),
      );

      final options = await _pathFinder.findJourneyOptions(
        startCityId: start.id,
        endCityId: end.id,
      );

      safeEmit(
        state.copyWith(
          status: JourneyPlannerStatus.routeOptions,
          journeyOptions: options,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Error recomputing journey options after '
        'threshold change',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      safeEmit(
        state.copyWith(
          status: JourneyPlannerStatus.failure,
          errorMessage: () => '$e',
        ),
      );
    }
  }
}
