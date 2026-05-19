import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/route_junction_graph/models/path_segment.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'route_junction_graph_state.dart';

class RouteJunctionGraphCubit extends Cubit<RouteJunctionGraphState>
    with SafeEmitMixin {
  RouteJunctionGraphCubit() : super(const RouteJunctionGraphState());

  final Repository _repository = GetIt.instance<Repository>();

  static const _tag = 'RouteJunctionGraphCubit';

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

  /// Full city→routes mapping loaded once.
  Map<int, Set<int>> _cityRouteMap = {};

  /// Fetches all routes from the database for the dropdown.
  Future<void> loadRoutes() async {
    try {
      safeEmit(state.copyWith(status: RouteJunctionGraphStatus.loading));
      final routes = await _repository.getRoutesFromDb();
      _cityRouteMap = await _repository.getCityRouteMapping();
      safeEmit(
        state.copyWith(
          status: RouteJunctionGraphStatus.success,
          routes: routes,
        ),
      );
    } catch (e) {
      AppLogger.e('Error loading routes', tag: _tag, error: e);
      safeEmit(
        state.copyWith(status: RouteJunctionGraphStatus.failure),
      );
    }
  }

  /// User selects a starting route — resets the journey and
  /// processes the first segment.
  Future<void> selectRoute(int routeId) async {
    try {
      safeEmit(
        state.copyWith(
          status: RouteJunctionGraphStatus.loading,
          selectedRouteId: routeId,
          path: [],
          resolvedJunctions: [],
          pendingJunction: () => null,
          isComplete: false,
        ),
      );

      final cities = await _repository.getCitiesByRouteIdFromDb(
        routeId,
      );

      _processSegment(
        routeId: routeId,
        cities: cities,
        startIndex: 0,
      );
    } catch (e) {
      AppLogger.e(
        'Error selecting route $routeId',
        tag: _tag,
        error: e,
      );
      safeEmit(
        state.copyWith(status: RouteJunctionGraphStatus.failure),
      );
    }
  }

  /// User chooses a branch at a junction.
  Future<void> chooseBranch(BranchOption branch) async {
    try {
      // Capture before clearing state.
      final currentJunction = state.pendingJunction;
      final junctionCityId = currentJunction?.junctionCity.id;

      // Save the resolved junction.
      final resolved = currentJunction != null
          ? ResolvedJunction(
              junction: currentJunction,
              chosenBranch: branch,
            )
          : null;

      safeEmit(
        state.copyWith(
          status: RouteJunctionGraphStatus.loading,
          resolvedJunctions: resolved != null
              ? [...state.resolvedJunctions, resolved]
              : null,
          pendingJunction: () => null,
        ),
      );

      final cities = await _repository.getCitiesByRouteIdFromDb(
        branch.routeId,
      );

      // Find the junction city's position on the chosen route.
      var startIndex = 0;
      if (junctionCityId != null) {
        final idx = cities.indexWhere(
          (c) => c.id == junctionCityId,
        );
        if (idx >= 0) {
          // Start AFTER the junction city (it's already shown
          // at the end of the previous segment).
          startIndex = idx + 1;
        }
      }

      _processSegment(
        routeId: branch.routeId,
        cities: cities,
        startIndex: startIndex,
      );
    } catch (e) {
      AppLogger.e(
        'Error choosing branch ${branch.routeId}',
        tag: _tag,
        error: e,
      );
      safeEmit(
        state.copyWith(status: RouteJunctionGraphStatus.failure),
      );
    }
  }

  /// Undo the last branch choice — restores the previous
  /// junction as pending.
  void goBack() {
    if (state.resolvedJunctions.isEmpty) return;

    final newResolved = List<ResolvedJunction>.of(
      state.resolvedJunctions,
    )..removeLast();
    final restored = state.resolvedJunctions.last;

    // Remove the last segment (it was added after the choice).
    final newPath = List<PathSegment>.of(state.path)..removeLast();

    safeEmit(
      state.copyWith(
        status: RouteJunctionGraphStatus.success,
        path: newPath,
        resolvedJunctions: newResolved,
        pendingJunction: () => restored.junction,
        isComplete: false,
      ),
    );
  }

  /// Walks [cities] from [startIndex], collects cities into a
  /// segment until a junction is found or the route ends.
  void _processSegment({
    required int routeId,
    required List<CityEntity> cities,
    required int startIndex,
  }) {
    final route = _lookupRoute(routeId);
    final segmentCities = <CityEntity>[];
    JunctionChoice? junction;

    for (var i = startIndex; i < cities.length; i++) {
      final city = cities[i];
      segmentCities.add(city);

      // Check if this city is a junction.
      final allRouteIds = _cityRouteMap[city.id] ?? <int>{};
      final otherRouteIds =
          allRouteIds.where((id) => id != routeId).toSet();

      if (otherRouteIds.isNotEmpty) {
        // If this is the last city on the route, there's no
        // "continue" option — the journey ends here regardless.
        if (i == cities.length - 1) continue;

        // If the next city on this route also belongs to all
        // the branching routes, the routes are still overlapping
        // — skip ahead instead of prompting.
        if (i + 1 < cities.length) {
          final nextCityRoutes =
              _cityRouteMap[cities[i + 1].id] ?? <int>{};
          if (otherRouteIds.every(nextCityRoutes.contains)) {
            continue;
          }
        }
        // Build branch options.
        final branches = <BranchOption>[];

        // Option to continue on current route (if not the
        // last city).
        if (i < cities.length - 1) {
          branches.add(
            BranchOption(
              routeId: routeId,
              routeName: route.routeName,
              routeSubName: route.routeSubName,
              routeColor: _routeColor(route, 0),
              isContinuation: true,
              citiesAhead: cities.length - i - 1,
            ),
          );
        }

        // Other routes branching here.
        for (final otherRouteId in otherRouteIds) {
          final otherRoute = _lookupRoute(otherRouteId);
          branches.add(
            BranchOption(
              routeId: otherRouteId,
              routeName: otherRoute.routeName,
              routeSubName: otherRoute.routeSubName,
              routeColor: _routeColor(
                otherRoute,
                branches.length,
              ),
              isContinuation: false,
              citiesAhead: 0, // we don't know yet
            ),
          );
        }

        junction = JunctionChoice(
          junctionCity: city,
          branches: branches,
        );
        break;
      }
    }

    final segment = PathSegment(
      routeId: routeId,
      routeName: route.routeName,
      routeSubName: route.routeSubName,
      routeColor: _routeColor(route, 0),
      cities: segmentCities,
    );

    safeEmit(
      state.copyWith(
        status: RouteJunctionGraphStatus.success,
        path: [...state.path, segment],
        pendingJunction: () => junction,
        isComplete: junction == null,
      ),
    );
  }

  /// Looks up a route entity by ID.
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

  /// Parses a route's legend color or falls back to palette.
  Color _routeColor(RouteEntity route, int fallbackIndex) {
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

}
