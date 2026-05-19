import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'trail_builder_state.dart';

class TrailBuilderCubit extends Cubit<TrailBuilderState>
    with SafeEmitMixin {
  TrailBuilderCubit() : super(const TrailBuilderState());

  final Repository _repository =
      GetIt.instance<Repository>();
  final JunctionService _junctionService =
      GetIt.instance<JunctionService>();
  final IAnalyticsService _analytics =
      GetIt.instance<IAnalyticsService>();

  static const _tag = 'TrailBuilderCubit';

  /// Whether the app is in dark mode. Set by the screen
  /// so color resolution picks the correct theme variant.
  bool isDark = false;

  /// Stack of state snapshots taken before each decision,
  /// enabling [undoLastDecision].
  final List<_DecisionSnapshot> _decisionHistory = [];

  final Map<int, List<LatLng>> _routePointsCache = {};
  final Map<int, CityEntity> _cityCache = {};

  // ── Public API ──────────────────────────────────────

  /// Fetches all routes and initializes the junction
  /// service so we can query junctions.
  Future<void> loadRoutes() async {
    try {
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.loading),
      );
      final routes = await _repository.getRoutesFromDb();
      await _junctionService.initialize();
      safeEmit(
        state.copyWith(
          status: TrailBuilderStatus.routeSelection,
          routes: routes,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Error loading routes',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.failure),
      );
    }
  }

  /// User picks a starting route. Loads the route's
  /// cities and transitions to the city selection phase.
  Future<void> selectStartingRoute(int routeId) async {
    try {
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.loading),
      );

      _decisionHistory.clear();

      final cities = await _junctionService
          .getCitiesForRoute(routeId);

      safeEmit(
        state.copyWith(
          status: TrailBuilderStatus.citySelection,
          currentRouteId: () => routeId,
          routeCities: cities,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Error selecting starting route $routeId',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.failure),
      );
    }
  }

  /// User picks a starting city on the selected route.
  /// Loads junctions from that city onward and either
  /// presents the first junction or completes a
  /// single-route trail.
  Future<void> selectStartingCity(int cityId) async {
    try {
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.loading),
      );

      final routeId = state.currentRouteId!;

      final junctions =
          await _junctionService.getJunctionsForRoute(
        routeId: routeId,
        allRoutes: state.routes,
        fromCityId: cityId,
      );

      if (junctions.isEmpty) {
        // No junctions — single-route trail from city.
        final segment = await _buildSegmentToCityId(
          routeId: routeId,
          fromCityId: cityId,
          toCityId: null,
          junctionCityId: null,
        );
        safeEmit(
          state.copyWith(
            status: TrailBuilderStatus.complete,
            currentRouteId: () => routeId,
            segments: [segment],
            routeCities: const [],
            pendingJunctions: const [],
            currentJunctionIndex: 0,
            currentJunction: () => null,
            segmentStartCityId: () => cityId,
          ),
        );
        _analytics.track(TrailBuilderFinalizedEvent());
        return;
      }

      // Present the first junction.
      final junction = await _buildJunctionInfo(
        junctionPoint: junctions.first,
        routeId: routeId,
      );

      final graphData = await _buildJunctionGraphData(
        junctionCity: junctions.first.city,
        currentRouteId: routeId,
        branchRoutes: junctions.first.branchRoutes,
      );

      safeEmit(
        state.copyWith(
          status: TrailBuilderStatus.junction,
          currentRouteId: () => routeId,
          segments: const [],
          routeCities: const [],
          pendingJunctions: junctions,
          currentJunctionIndex: 0,
          currentJunction: () => junction,
          junctionGraphData: () => graphData,
          segmentStartCityId: () => cityId,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Error selecting starting city $cityId',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.failure),
      );
    }
  }

  /// Returns to route selection, clearing the selected
  /// route and its cities.
  void backToRouteSelection() {
    _decisionHistory.clear();
    _routePointsCache.clear();
    _cityCache.clear();
    safeEmit(
      state.copyWith(
        status: TrailBuilderStatus.routeSelection,
        routeCities: const [],
        currentRouteId: () => null,
        segments: const [],
        currentJunction: () => null,
        junctionGraphData: () => null,
        pendingJunctions: const [],
        currentJunctionIndex: 0,
        segmentStartCityId: () => null,
      ),
    );
  }

  /// User chooses to continue on the current route past
  /// the current junction.
  Future<void> continueOnRoute() async {
    try {
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.loading),
      );

      _pushSnapshot();
      _trackJunctionDecision();

      final nextIndex = state.currentJunctionIndex + 1;

      if (nextIndex < state.pendingJunctions.length) {
        // More junctions ahead — present the next one.
        final nextPoint =
            state.pendingJunctions[nextIndex];
        final junction = await _buildJunctionInfo(
          junctionPoint: nextPoint,
          routeId: state.currentRouteId!,
        );
        final graphData = await _buildJunctionGraphData(
          junctionCity: nextPoint.city,
          currentRouteId: state.currentRouteId!,
          branchRoutes: nextPoint.branchRoutes,
        );
        safeEmit(
          state.copyWith(
            status: TrailBuilderStatus.junction,
            currentJunctionIndex: nextIndex,
            currentJunction: () => junction,
            junctionGraphData: () => graphData,
          ),
        );
        return;
      }

      // No more junctions — complete the segment to route
      // end and finish the trail.
      final segment = await _buildSegmentToCityId(
        routeId: state.currentRouteId!,
        fromCityId: state.segmentStartCityId,
        toCityId: null, // route end
        junctionCityId: state.segmentStartCityId,
      );

      safeEmit(
        state.copyWith(
          status: TrailBuilderStatus.complete,
          currentJunction: () => null,
          segments: [...state.segments, segment],
        ),
      );
      _analytics.track(TrailBuilderFinalizedEvent());
    } catch (e, st) {
      AppLogger.e(
        'Error continuing on route',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.failure),
      );
    }
  }

  /// User switches to [newRouteId] at the current
  /// junction. Finalizes the current segment up to the
  /// junction city, then starts a new segment on the
  /// branching route.
  Future<void> switchToRoute(int newRouteId) async {
    try {
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.loading),
      );

      _pushSnapshot();
      _trackJunctionDecision();

      final junctionCityId =
          state.currentJunction!.city.id;

      // Finalize the in-progress segment up to the
      // junction city (inclusive).
      final currentSegment = await _buildSegmentToCityId(
        routeId: state.currentRouteId!,
        fromCityId: state.segmentStartCityId,
        toCityId: junctionCityId,
        junctionCityId: state.segmentStartCityId,
      );

      final updatedSegments = [
        ...state.segments,
        currentSegment,
      ];

      // Load junctions for the new route, starting after
      // the junction city.
      final newJunctions =
          await _junctionService.getJunctionsForRoute(
        routeId: newRouteId,
        allRoutes: state.routes,
        fromCityId: junctionCityId,
      );

      if (newJunctions.isEmpty) {
        // No junctions on the new route — build the final
        // segment from the junction city to the route end.
        final finalSegment = await _buildSegmentToCityId(
          routeId: newRouteId,
          fromCityId: junctionCityId,
          toCityId: null,
          junctionCityId: junctionCityId,
        );
        safeEmit(
          state.copyWith(
            status: TrailBuilderStatus.complete,
            currentRouteId: () => newRouteId,
            segments: [...updatedSegments, finalSegment],
            pendingJunctions: const [],
            currentJunctionIndex: 0,
            currentJunction: () => null,
            segmentStartCityId: () => junctionCityId,
          ),
        );
        _analytics.track(TrailBuilderFinalizedEvent());
        return;
      }

      // Present the first junction on the new route.
      final junction = await _buildJunctionInfo(
        junctionPoint: newJunctions.first,
        routeId: newRouteId,
      );
      final graphData = await _buildJunctionGraphData(
        junctionCity: newJunctions.first.city,
        currentRouteId: newRouteId,
        branchRoutes: newJunctions.first.branchRoutes,
      );

      safeEmit(
        state.copyWith(
          status: TrailBuilderStatus.junction,
          currentRouteId: () => newRouteId,
          segments: updatedSegments,
          pendingJunctions: newJunctions,
          currentJunctionIndex: 0,
          currentJunction: () => junction,
          junctionGraphData: () => graphData,
          segmentStartCityId: () => junctionCityId,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Error switching to route $newRouteId',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.failure),
      );
    }
  }

  /// User ends the trail at the current junction city.
  Future<void> endTrailHere() async {
    try {
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.loading),
      );

      _pushSnapshot();
      _trackJunctionDecision();

      final junctionCityId =
          state.currentJunction!.city.id;

      final segment = await _buildSegmentToCityId(
        routeId: state.currentRouteId!,
        fromCityId: state.segmentStartCityId,
        toCityId: junctionCityId,
        junctionCityId: state.segmentStartCityId,
      );

      safeEmit(
        state.copyWith(
          status: TrailBuilderStatus.complete,
          currentJunction: () => null,
          segments: [...state.segments, segment],
        ),
      );
      _analytics.track(TrailBuilderFinalizedEvent());
    } catch (e, st) {
      AppLogger.e(
        'Error ending trail',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      safeEmit(
        state.copyWith(status: TrailBuilderStatus.failure),
      );
    }
  }

  /// Reverts the last junction decision, restoring the
  /// previous state.
  Future<void> undoLastDecision() async {
    if (_decisionHistory.isEmpty) return;

    _analytics.track(TrailBuilderUndoEvent());

    final snapshot = _decisionHistory.removeLast();

    // Rebuild the junction info from the snapshot so the
    // UI shows the correct junction.
    final junctionPoint = snapshot
        .pendingJunctions[snapshot.currentJunctionIndex];

    final junction = await _buildJunctionInfo(
      junctionPoint: junctionPoint,
      routeId: snapshot.currentRouteId,
    );
    final graphData = await _buildJunctionGraphData(
      junctionCity: junctionPoint.city,
      currentRouteId: snapshot.currentRouteId,
      branchRoutes: junctionPoint.branchRoutes,
    );

    safeEmit(
      state.copyWith(
        status: TrailBuilderStatus.junction,
        segments: snapshot.segments,
        currentRouteId: () => snapshot.currentRouteId,
        pendingJunctions: snapshot.pendingJunctions,
        currentJunctionIndex:
            snapshot.currentJunctionIndex,
        currentJunction: () => junction,
        junctionGraphData: () => graphData,
        segmentStartCityId: () =>
            snapshot.segmentStartCityId,
      ),
    );
  }

  /// Whether the user can undo a decision.
  bool get canUndo => _decisionHistory.isNotEmpty;

  /// Converts the completed segments into a
  /// [MultiRouteTrail] for the stage planner.
  MultiRouteTrail buildTrail() =>
      MultiRouteTrail(segments: state.segments);

  /// Loads route points for all trail routes (finalized
  /// segments + current route). Returns cached data on
  /// subsequent calls. Only fetches uncached routes.
  Future<Map<int, List<LatLng>>>
      getTrailRoutePoints() async {
    final neededRouteIds = <int>{
      ...state.segments.map((s) => s.routeId),
      if (state.currentRouteId != null)
        state.currentRouteId!,
    };

    final uncachedIds = neededRouteIds
        .where((id) => !_routePointsCache.containsKey(id))
        .toList();
    if (uncachedIds.isNotEmpty) {
      final futures = uncachedIds.map(
        (id) => _repository.getRoutePointsByRouteIdFromDb(
          routeId: id,
        ),
      );
      final results = await Future.wait(futures.toList());
      for (var i = 0; i < uncachedIds.length; i++) {
        _routePointsCache[uncachedIds[i]] =
            MapUtil.getLatLngsFromRoutePoints(results[i]);
      }
    }
    return Map.unmodifiable(_routePointsCache);
  }

  /// Loads route points for all branch routes at the
  /// current junction. Returns a map of routeId to points
  /// for the continue route and all branch routes.
  Future<Map<int, List<LatLng>>>
      getBranchRoutePoints() async {
    final junction = state.currentJunction;
    if (junction == null) return {};

    final branchRouteIds = <int>{
      junction.currentRoute.id,
      ...junction.branchRoutes.map((r) => r.id),
    };

    final uncachedIds = branchRouteIds
        .where((id) => !_routePointsCache.containsKey(id))
        .toList();
    if (uncachedIds.isNotEmpty) {
      final futures = uncachedIds.map(
        (id) => _repository.getRoutePointsByRouteIdFromDb(
          routeId: id,
        ),
      );
      final results = await Future.wait(futures.toList());
      for (var i = 0; i < uncachedIds.length; i++) {
        _routePointsCache[uncachedIds[i]] =
            MapUtil.getLatLngsFromRoutePoints(results[i]);
      }
    }

    return {
      for (final id in branchRouteIds)
        if (_routePointsCache.containsKey(id))
          id: _routePointsCache[id]!,
    };
  }

  /// Resolves a city by ID. Populates cache from junction
  /// service city lists.
  Future<CityEntity?> resolveCityById(int cityId) async {
    if (_cityCache.containsKey(cityId)) {
      return _cityCache[cityId];
    }
    final routeIds = <int>{
      ...state.segments.map((s) => s.routeId),
      if (state.currentRouteId != null)
        state.currentRouteId!,
    };
    for (final routeId in routeIds) {
      final cities =
          await _junctionService.getCitiesForRoute(routeId);
      for (final city in cities) {
        _cityCache[city.id] = city;
      }
      if (_cityCache.containsKey(cityId)) {
        return _cityCache[cityId];
      }
    }
    return null;
  }

  /// Resets the builder to route selection, clearing all
  /// decisions.
  void reset() {
    _decisionHistory.clear();
    _routePointsCache.clear();
    _cityCache.clear();
    safeEmit(
      state.copyWith(
        status: TrailBuilderStatus.routeSelection,
        segments: const [],
        routeCities: const [],
        currentRouteId: () => null,
        currentJunction: () => null,
        junctionGraphData: () => null,
        pendingJunctions: const [],
        currentJunctionIndex: 0,
        segmentStartCityId: () => null,
      ),
    );
  }

  // ── Private helpers ─────────────────────────────────

  /// Saves the current state to the decision history
  /// stack so that [undoLastDecision] can restore it.
  void _pushSnapshot() {
    _decisionHistory.add(
      _DecisionSnapshot(
        segments: List.of(state.segments),
        currentRouteId: state.currentRouteId!,
        pendingJunctions: state.pendingJunctions,
        currentJunctionIndex: state.currentJunctionIndex,
        segmentStartCityId: state.segmentStartCityId,
      ),
    );
  }

  /// Emits a [TrailBuilderJunctionDecisionEvent] with the
  /// current decision number. Call after [_pushSnapshot] so
  /// the count reflects the just-committed decision.
  void _trackJunctionDecision() {
    _analytics.track(
      TrailBuilderJunctionDecisionEvent(
        decisionNumber: _decisionHistory.length,
      ),
    );
  }

  /// Builds a [JunctionInfo] for the given
  /// [junctionPoint], resolving the route's end city
  /// name.
  Future<JunctionInfo> _buildJunctionInfo({
    required JunctionPoint junctionPoint,
    required int routeId,
  }) async {
    final route = _lookupRoute(routeId);
    final routeEndCity =
        await _resolveRouteEndCity(routeId);

    return JunctionInfo(
      city: junctionPoint.city,
      branchRoutes: junctionPoint.branchRoutes,
      currentRoute: route,
      routeEndCity: routeEndCity,
    );
  }

  /// Builds the data needed for the mini junction graph.
  Future<JunctionGraphData> _buildJunctionGraphData({
    required CityEntity junctionCity,
    required int currentRouteId,
    required List<RouteEntity> branchRoutes,
  }) async {
    final branches = <JunctionBranch>[];

    // Show 1 city per branch for a clean graph.
    const maxCities = 1;

    // Current route branch (continue).
    final currentCities = await _junctionService
        .getCitiesForRoute(currentRouteId);
    final currentRoute = _lookupRoute(currentRouteId);
    final junctionIdx = currentCities
        .indexWhere((c) => c.id == junctionCity.id);

    if (junctionIdx >= 0 &&
        junctionIdx < currentCities.length - 1) {
      final end = (junctionIdx + 1 + maxCities)
          .clamp(0, currentCities.length);
      branches.add(
        JunctionBranch(
          routeName: currentRoute.routeName,
          colorValue: _parseColorValue(currentRoute),
          cities: currentCities.sublist(
            junctionIdx + 1,
            end,
          ),
          isContinue: true,
        ),
      );
    }

    // Branch routes.
    for (final route in branchRoutes) {
      final cities = await _junctionService
          .getCitiesForRoute(route.id);
      final idx = cities
          .indexWhere((c) => c.id == junctionCity.id);

      if (idx >= 0 && idx < cities.length - 1) {
        final end = (idx + 1 + maxCities)
            .clamp(0, cities.length);
        branches.add(
          JunctionBranch(
            routeName: route.routeName,
            colorValue: _parseColorValue(route),
            cities: cities.sublist(idx + 1, end),
          ),
        );
      }
    }

    return JunctionGraphData(
      junctionCity: junctionCity,
      branches: branches,
    );
  }

  /// Returns the name of the last city on [routeId].
  Future<String?> _resolveRouteEndCity(
    int routeId,
  ) async {
    final cities =
        await _junctionService.getCitiesForRoute(routeId);
    return cities.isNotEmpty ? cities.last.name : null;
  }

  /// Builds a [TrailSegment] from [fromCityId] to
  /// [toCityId] on [routeId].
  ///
  /// - [fromCityId] is exclusive (segment starts after
  ///   this city). Pass null to start from the beginning.
  /// - [toCityId] is inclusive (segment ends at this
  ///   city). Pass null to go to the route end.
  /// - [junctionCityId] is the city where a previous
  ///   segment split to this one (null for first segment).
  Future<TrailSegment> _buildSegmentToCityId({
    required int routeId,
    required int? fromCityId,
    required int? toCityId,
    int? junctionCityId,
  }) async {
    final route = _lookupRoute(routeId);
    final cities =
        await _junctionService.getCitiesForRoute(routeId);

    var startIndex = 0;
    if (fromCityId != null) {
      final idx =
          cities.indexWhere((c) => c.id == fromCityId);
      if (idx >= 0) {
        // For the first segment of a route switch, we
        // include the junction city itself so consecutive
        // segments share the boundary city.
        startIndex = idx;
      }
    }

    var endIndex = cities.length - 1;
    if (toCityId != null) {
      final idx =
          cities.indexWhere((c) => c.id == toCityId);
      if (idx >= 0) endIndex = idx;
    }

    // Guard against invalid ranges.
    if (startIndex > endIndex || cities.isEmpty) {
      return TrailSegment(
        routeId: routeId,
        routeName: route.routeName,
        routeSubName: route.routeSubName,
        colorValue: _parseColorValue(route),
        cityIds: const [],
        junctionCityId: junctionCityId,
      );
    }

    final segmentCities =
        cities.sublist(startIndex, endIndex + 1);

    return TrailSegment(
      routeId: routeId,
      routeName: route.routeName,
      routeSubName: route.routeSubName,
      colorValue: _parseColorValue(route),
      cityIds: segmentCities.map((c) => c.id).toList(),
      junctionCityId: junctionCityId,
    );
  }

  /// Resolves a [RouteEntity] by ID from the loaded
  /// routes list, with a safe fallback.
  RouteEntity _lookupRoute(int routeId) {
    return state.routes.firstWhere(
      (r) => r.id == routeId,
      orElse: () => RouteEntity(
        id: routeId,
        orderKey: 0,
        routeName: 'Route $routeId',
      ),
    );
  }

  /// Parses the route's hex legend color into an int
  /// value, selecting the light or dark variant based on
  /// [isDark]. Delegates to [parseRouteColorValue].
  int _parseColorValue(RouteEntity route) =>
      parseRouteColorValue(route, isDark: isDark);
}
