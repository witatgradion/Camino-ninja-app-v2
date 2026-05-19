import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'route_city_overview_state.dart';

class RouteCityOverviewCubit extends Cubit<RouteCityOverviewState>
    with SafeEmitMixin {
  RouteCityOverviewCubit() : super(const RouteCityOverviewState());

  final Repository _repository = GetIt.instance<Repository>();
  final JunctionService _junctionService = GetIt.instance<JunctionService>();

  static const _tag = 'RouteCityOverviewCubit';

  static const _fallbackColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
  ];

  // ── Public API ────────────────────────────────────────

  /// Fetches all routes and initializes the junction
  /// service.
  Future<void> loadRoutes() async {
    try {
      safeEmit(
        state.copyWith(status: RouteCityOverviewStatus.loading),
      );
      final routes = await _repository.getRoutesFromDb();
      await _junctionService.initialize();
      safeEmit(
        state.copyWith(
          status: RouteCityOverviewStatus.success,
          routes: routes,
        ),
      );
    } catch (e) {
      AppLogger.e('Error loading routes', tag: _tag, error: e);
      safeEmit(
        state.copyWith(status: RouteCityOverviewStatus.failure),
      );
    }
  }

  /// User picks a starting route from the dropdown.
  Future<void> selectRoute(int routeId) async {
    try {
      safeEmit(
        state.copyWith(
          status: RouteCityOverviewStatus.loading,
          selectedRouteId: routeId,
          segments: [],
        ),
      );

      final segment = await _buildSegment(
        routeId: routeId,
        fromCityId: null,
      );

      safeEmit(
        state.copyWith(
          status: RouteCityOverviewStatus.success,
          segments: [segment],
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Error selecting route $routeId',
        tag: _tag,
        error: e,
      );
      safeEmit(
        state.copyWith(status: RouteCityOverviewStatus.failure),
      );
    }
  }

  /// User splits from [junctionCityId] onto [newRouteId].
  Future<void> splitToRoute({
    required int junctionCityId,
    required int newRouteId,
  }) async {
    try {
      safeEmit(
        state.copyWith(
          status: RouteCityOverviewStatus.loading,
        ),
      );

      // Find the segment containing this junction city and
      // trim everything from that point onward.
      final segments = List<OverviewSegment>.of(state.segments);
      var splitSegmentIndex = -1;

      // Search backward — junction cities can exist on
      // multiple routes, so the same city ID may appear in
      // earlier segments' allEntries. We want the most
      // recent (active) segment.
      for (var i = segments.length - 1; i >= 0; i--) {
        final hasCity = segments[i].allEntries.any(
              (e) => e.city.id == junctionCityId,
            );
        if (hasCity) {
          splitSegmentIndex = i;
          break;
        }
      }

      if (splitSegmentIndex < 0) {
        safeEmit(
          state.copyWith(
            status: RouteCityOverviewStatus.success,
          ),
        );
        return;
      }

      // Trim: keep segments 0..splitSegmentIndex, set split
      // point, discard everything after.
      final trimmed = segments.sublist(0, splitSegmentIndex + 1).map((s) {
        if (s == segments[splitSegmentIndex]) {
          return s.copyWith(
            splitAtCityId: () => junctionCityId,
          );
        }
        return s;
      }).toList();

      // Build new segment for the branching route.
      final newSegment = await _buildSegment(
        routeId: newRouteId,
        fromCityId: junctionCityId,
      );

      safeEmit(
        state.copyWith(
          status: RouteCityOverviewStatus.success,
          segments: [...trimmed, newSegment],
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Error splitting to route $newRouteId',
        tag: _tag,
        error: e,
      );
      safeEmit(
        state.copyWith(status: RouteCityOverviewStatus.failure),
      );
    }
  }

  /// Undo the last split — remove last segment and restore
  /// the previous segment to show all its cities.
  void goBack() {
    if (state.segments.length <= 1) return;

    final segments = List<OverviewSegment>.of(state.segments)..removeLast();

    // Restore the now-last segment to show all cities.
    final restored = segments.last.copyWith(
      splitAtCityId: () => null,
    );
    segments[segments.length - 1] = restored;

    safeEmit(
      state.copyWith(
        status: RouteCityOverviewStatus.success,
        segments: segments,
      ),
    );
  }

  /// Parses a route's legend color or falls back to palette.
  Color routeColor(RouteEntity route, int fallbackIndex) {
    final hex = route.legendColor;
    if (hex != null && hex.isNotEmpty) {
      final cleaned = hex.replaceAll('#', '');
      if (cleaned.length == 6) {
        final value = int.tryParse('FF$cleaned', radix: 16);
        if (value != null) return Color(value);
      }
    }
    return _fallbackColors[fallbackIndex % _fallbackColors.length];
  }

  // ── Private helpers ───────────────────────────────────

  /// Builds a segment for [routeId], starting from
  /// [fromCityId] (exclusive) or from the beginning if null.
  ///
  /// When [fromCityId] is at or near the end of the route's
  /// natural city order, the route is traversed in reverse
  /// (the junction is the route's terminus, so the user walks
  /// backward from that point).
  Future<OverviewSegment> _buildSegment({
    required int routeId,
    required int? fromCityId,
  }) async {
    final route = _lookupRoute(routeId);
    final cities = await _junctionService.getCitiesForRoute(routeId);

    var startIndex = 0;
    if (fromCityId != null) {
      final idx = cities.indexWhere((c) => c.id == fromCityId);
      if (idx >= 0) startIndex = idx + 1;
    }

    var segmentCities = startIndex > 0 ? cities.sublist(startIndex) : cities;

    // If the junction city is at or near the end of this
    // route's natural order, segmentCities will be empty.
    // This means the route should be traversed in reverse
    // from the junction point backward.
    var isReversed = false;
    if (segmentCities.isEmpty && fromCityId != null) {
      final idx = cities.indexWhere((c) => c.id == fromCityId);
      if (idx > 0) {
        segmentCities = cities.sublist(0, idx).reversed.toList();
        isReversed = true;
      }
    }

    // If still empty (route has only 1 city or junction not
    // found), return an empty segment gracefully.
    if (segmentCities.isEmpty) {
      return OverviewSegment(
        routeId: routeId,
        routeName: route.routeName,
        routeSubName: route.routeSubName,
        routeColor: _routeColor(route),
        allEntries: const [],
      );
    }

    // Delegate junction detection to JunctionService.
    // For reversed segments, pass fromCityId: null so the
    // service scans the full route. The loop below filters
    // to segmentCities, so extra junctions outside the
    // reversed range are harmlessly ignored.
    final junctions = await _junctionService.getJunctionsForRoute(
      routeId: routeId,
      allRoutes: state.routes,
      fromCityId: isReversed ? null : fromCityId,
    );

    // Build a lookup: cityId → branch routes.
    final junctionMap = <int, List<RouteEntity>>{};
    for (final jp in junctions) {
      junctionMap[jp.city.id] = jp.branchRoutes;
    }

    // Build city entries, annotating junctions.
    final entries = <CityOverviewEntry>[];
    for (var i = 0; i < segmentCities.length; i++) {
      final city = segmentCities[i];
      // Last city in this segment is never a junction
      // (terminus — no meaningful split).
      final isLast = i == segmentCities.length - 1;
      final branchRoutes =
          (!isLast && junctionMap.containsKey(city.id))
              ? junctionMap[city.id]!
              : <RouteEntity>[];
      entries.add(
        CityOverviewEntry(
          city: city,
          junctionRoutes: branchRoutes,
        ),
      );
    }

    // When splitting from a junction, the UI city list
    // (segmentCities) excludes the junction itself, but route
    // points must start FROM the junction to avoid a gap.
    //
    // For reversed segments the natural DB order is opposite
    // to the walking direction, so we pass start/dest in
    // the route's natural order (lower order_key first) and
    // then reverse the result.
    final int routePointStartCityId;
    final int routePointEndCityId;

    if (isReversed) {
      // Natural order: segmentCities.last is earliest in
      // the route, fromCityId is latest.
      routePointStartCityId = segmentCities.last.id;
      routePointEndCityId = fromCityId!;
    } else {
      routePointStartCityId = fromCityId ?? segmentCities.first.id;
      routePointEndCityId = segmentCities.last.id;
    }

    var routePoints = await _repository.getRoutePointsByRouteIdFromDb(
      routeId: routeId,
      startingCityId: routePointStartCityId,
      destCityId: routePointEndCityId,
    );

    if (isReversed) {
      routePoints = routePoints.reversed.toList();
    }

    return OverviewSegment(
      routeId: routeId,
      routeName: route.routeName,
      routeSubName: route.routeSubName,
      routeColor: _routeColor(route),
      allEntries: entries,
      routePoints: routePoints,
    );
  }

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

  Color _routeColor(RouteEntity route) {
    final hex = route.legendColor;
    if (hex != null && hex.isNotEmpty) {
      final cleaned = hex.replaceAll('#', '');
      if (cleaned.length == 6) {
        final value = int.tryParse('FF$cleaned', radix: 16);
        if (value != null) return Color(value);
      }
    }
    return _fallbackColors[route.id % _fallbackColors.length];
  }
}
