// ignore_for_file: public_member_api_docs

import 'package:core/core.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

/// Service for finding journey options between two cities
/// across the pilgrimage route network.
///
/// Builds a route connectivity graph from junction data and
/// provides BFS-based path finding with city ordering
/// validation.
///
/// Must have [JunctionService.initialize] called before use.
class RoutePathFinder {
  RoutePathFinder({
    required Repository repository,
    required JunctionService junctionService,
    double junctionMaxDistanceMeters = _defaultJunctionMaxDistanceMeters,
  })  : _repository = repository,
        _junctionService = junctionService,
        _junctionMaxDistanceMeters = junctionMaxDistanceMeters;

  final Repository _repository;
  final JunctionService _junctionService;

  /// Maximum distance (meters) between the two routes'
  /// touching points at a shared city for the city to
  /// qualify as a junction. Beyond this, walking between
  /// the routes would require an impractical detour.
  double _junctionMaxDistanceMeters;

  /// Default touching-point threshold: 1 km.
  static const double _defaultJunctionMaxDistanceMeters = 1000;

  /// Current threshold in meters.
  double get junctionMaxDistanceMeters => _junctionMaxDistanceMeters;

  /// Update the junction distance threshold. Clears the
  /// cached graph so the next [buildGraph] call rebuilds
  /// with the new threshold.
  void setJunctionMaxDistanceMeters(double meters) {
    _junctionMaxDistanceMeters = meters;
    clearCache();
  }

  RouteGraph? _cachedGraph;

  /// Build the route connectivity graph from junction data.
  ///
  /// Uses cached city-route mappings and ordered city lists
  /// to determine which routes share non-terminus junction
  /// cities. The result is cached for subsequent queries.
  Future<RouteGraph> buildGraph() async {
    if (_cachedGraph != null) return _cachedGraph!;

    final allRoutes = await _repository.getRoutesFromDb();
    final routeIndex = <int, RouteEntity>{
      for (final route in allRoutes) route.id: route,
    };

    final cityRouteMap =
        await _repository.getCityRouteMapping();

    // Load touching-point mappings so we can filter out
    // "shared" cities where the two routes actually enter/
    // exit the city far apart from each other. If the
    // mapping is empty (e.g., incomplete data or fresh
    // install that hasn't populated city_route_points),
    // fall back to the legacy behavior and skip filtering.
    final crpMap =
        await _repository.getAllCityRoutePointMappings();
    if (crpMap.isEmpty) {
      AppLogger.w(
        'RoutePathFinder: city_route_points mapping is '
        'empty — junction touching-point filter disabled',
      );
    }

    // Index route points by id for fast lat/lng lookups.
    // One flat map is simpler than per-route nesting and
    // avoids duplicate storage.
    final allPoints = await _repository.getRoutePointsFromDb();
    final pointsById = <int, RoutePointEntity>{
      for (final p in allPoints) p.id: p,
    };

    // Pre-load all route city lists, build terminus sets,
    // and index city positions per route.
    // A terminus is the first or last city on a route.
    final routeTermini = <int, Set<int>>{};
    final routeCityIndex = <int, Map<int, int>>{};
    for (final route in allRoutes) {
      final cities = await _junctionService.getCitiesForRoute(
        route.id,
      );
      if (cities.length >= 2) {
        routeTermini[route.id] = {
          cities.first.id,
          cities.last.id,
        };
      } else if (cities.length == 1) {
        routeTermini[route.id] = {cities.first.id};
      }
      // Map city ID -> index for position lookups.
      final indexMap = <int, int>{};
      for (var i = 0; i < cities.length; i++) {
        indexMap[cities[i].id] = i;
      }
      routeCityIndex[route.id] = indexMap;
    }

    // Build adjacency list.
    // For each city with 2+ routes, check that the city is
    // not a terminus on ALL participating routes. A junction
    // is valid if at least two routes have the city as a
    // non-terminus stop.
    final adjacency = <int, List<RouteConnection>>{};
    final cityNames = <int, String>{};
    var filteredByDistance = 0;

    for (final entry in cityRouteMap.entries) {
      final cityId = entry.key;
      final routeIds = entry.value;
      if (routeIds.length < 2) continue;

      // Filter to routes where this city is not a terminus.
      final nonTerminusRoutes = routeIds.where((routeId) {
        final termini = routeTermini[routeId];
        if (termini == null) return false;
        return !termini.contains(cityId);
      }).toList();

      if (nonTerminusRoutes.length < 2) continue;

      // Lazily resolve the city name.
      if (!cityNames.containsKey(cityId)) {
        try {
          final cities =
              await _junctionService.getCitiesForRoute(
            nonTerminusRoutes.first,
          );
          final city = cities.where((c) => c.id == cityId);
          if (city.isNotEmpty) {
            cityNames[cityId] = city.first.name;
          }
        } catch (_) {
          // City name resolution is best-effort.
        }
      }
      final cityName = cityNames[cityId] ?? 'City $cityId';

      // Add edges only at TRUE divergence points.
      // Two routes sharing city X are only a junction if
      // the NEXT city on route A is NOT on route B (i.e.,
      // the routes actually split here).
      for (final routeA in nonTerminusRoutes) {
        final idxOnA = routeCityIndex[routeA]?[cityId];
        // Skip if the city isn't in the route's ordered
        // city list (exists in city_routes but not in
        // route point associations).
        if (idxOnA == null) continue;

        // Find the next city on route A after this one.
        final routeACities = routeCityIndex[routeA] ?? {};
        // Invert the map to get city ID at index.
        int? nextCityOnA;
        for (final e in routeACities.entries) {
          if (e.value == idxOnA + 1) {
            nextCityOnA = e.key;
            break;
          }
        }

        for (final routeB in nonTerminusRoutes) {
          if (routeA == routeB) continue;
          // Also skip if the city isn't in the target
          // route's ordered city list.
          final idxOnB = routeCityIndex[routeB]?[cityId];
          if (idxOnB == null) continue;

          // Divergence check: if the next city on route A
          // also exists on route B, the routes are still
          // overlapping — not a true junction from A to B.
          if (nextCityOnA != null) {
            final nextOnAExistsOnB =
                routeCityIndex[routeB]?.containsKey(
                      nextCityOnA,
                    ) ??
                    false;
            if (nextOnAExistsOnB) continue;
          }

          // Touching-point distance filter.
          //
          // Look up the route-point ids of the shared city
          // on each route and compute the haversine
          // distance between them. If the two routes enter/
          // exit the city more than the threshold apart,
          // skip this junction — a pilgrim can't actually
          // switch routes here without a significant
          // detour.
          //
          // If the mapping is empty or either point is
          // missing, fall back to the legacy behavior
          // (don't filter).
          if (crpMap.isNotEmpty) {
            final pointIdA = crpMap[(cityId, routeA)];
            final pointIdB = crpMap[(cityId, routeB)];
            if (pointIdA != null && pointIdB != null) {
              final pointA = pointsById[pointIdA];
              final pointB = pointsById[pointIdB];
              if (pointA != null && pointB != null) {
                final metersApart = calculateDistance(
                  pointA.latitude,
                  pointA.longitude,
                  pointB.latitude,
                  pointB.longitude,
                );
                if (metersApart > _junctionMaxDistanceMeters) {
                  filteredByDistance++;
                  continue;
                }
              }
            }
          }

          final edges = adjacency.putIfAbsent(
            routeA,
            () => <RouteConnection>[],
          );

          // Avoid duplicate edges to the same target via
          // the same junction city.
          final alreadyExists = edges.any(
            (e) =>
                e.targetRouteId == routeB &&
                e.junctionCityId == cityId,
          );
          if (!alreadyExists) {
            edges.add(
              RouteConnection(
                targetRouteId: routeB,
                junctionCityId: cityId,
                junctionCityName: cityName,
                junctionIndexOnSource: idxOnA,
              ),
            );
          }
        }
      }
    }

    final graph = RouteGraph(
      adjacency: adjacency,
      routeIndex: routeIndex,
      cityRouteIndex: cityRouteMap,
      routeCityIndex: routeCityIndex,
    );
    _cachedGraph = graph;

    AppLogger.d(
      'RoutePathFinder: built graph with '
      '${adjacency.length} nodes, '
      '${adjacency.values.fold<int>(0, (s, e) => s + e.length)}'
      ' edges',
    );
    AppLogger.d(
      'RoutePathFinder: filtered $filteredByDistance '
      'junctions as too far apart (> '
      '${_junctionMaxDistanceMeters.toStringAsFixed(0)} m)',
    );

    return graph;
  }

  /// Find all journey options between two cities.
  ///
  /// Returns a sorted list of [JourneyOption]s ranked by
  /// junction count (ascending), then by first route's
  /// order key.
  ///
  /// Returns an empty list if no paths exist or either city
  /// is not found in the route network.
  Future<List<JourneyOption>> findJourneyOptions({
    required int startCityId,
    required int endCityId,
  }) async {
    final graph = await buildGraph();

    // Look up which routes each city belongs to.
    final startRouteIds =
        graph.cityRouteIndex[startCityId] ?? <int>{};
    final endRouteIds =
        graph.cityRouteIndex[endCityId] ?? <int>{};

    AppLogger.d(
      'findJourneyOptions: start=$startCityId routes=$startRouteIds, '
      'end=$endCityId routes=$endRouteIds',
    );

    if (startRouteIds.isEmpty || endRouteIds.isEmpty) {
      AppLogger.d('findJourneyOptions: no routes for city');
      return const [];
    }

    // Compute the start city's index on each of its
    // routes so BFS can skip junctions behind it.
    final startCityIndices = <int, int>{};
    for (final routeId in startRouteIds) {
      final cities =
          await _junctionService.getCitiesForRoute(routeId);
      final idx = cities.indexWhere(
        (c) => c.id == startCityId,
      );
      if (idx >= 0) {
        startCityIndices[routeId] = idx;
      }
    }

    // Compute the end city's index on each of its
    // routes so BFS can skip junctions after it.
    final endCityIndices = <int, int>{};
    for (final routeId in endRouteIds) {
      final cities =
          await _junctionService.getCitiesForRoute(routeId);
      final idx = cities.indexWhere(
        (c) => c.id == endCityId,
      );
      if (idx >= 0) {
        endCityIndices[routeId] = idx;
      }
    }

    // Find all candidate paths via BFS.
    final paths = graph.findPaths(
      startRouteIds: startRouteIds,
      endRouteIds: endRouteIds,
      startCityIndices: startCityIndices,
      endCityIndices: endCityIndices,
    );

    AppLogger.d(
      'findJourneyOptions: BFS found ${paths.length} paths',
    );

    if (paths.isEmpty) return const [];

    // Validate city ordering on each path and build
    // JourneyOption for valid ones (without distance —
    // distance is deferred to avoid slow DB queries for
    // every candidate).
    final options = <JourneyOption>[];

    for (final path in paths) {
      final option = await _validateAndBuildOption(
        graph: graph,
        path: path,
        startCityId: startCityId,
        endCityId: endCityId,
        computeDistance: false,
      );
      if (option != null) {
        options.add(option);
      }
    }

    // Sort: by junction count ascending, then by first
    // route's order key ascending.
    options.sort((a, b) {
      final junctionCompare = a.path.junctionCount.compareTo(
        b.path.junctionCount,
      );
      if (junctionCompare != 0) return junctionCompare;

      final aOrderKey = a.routes.firstOrNull?.orderKey ?? 0;
      final bOrderKey = b.routes.firstOrNull?.orderKey ?? 0;
      return aOrderKey.compareTo(bOrderKey);
    });

    // Compute distance only for the top 10 results.
    final topN = options.take(10).toList();
    final rest = options.skip(10).toList();
    final enriched = <JourneyOption>[];
    for (final option in topN) {
      final distKm = await _estimateDistanceKm(
        option.path.routeIds
            .asMap()
            .entries
            .map((e) {
          final i = e.key;
          final routeId = e.value;
          final startId = i == 0
              ? startCityId
              : option.path.junctionCityIds[i - 1];
          final endId =
              i == option.path.routeIds.length - 1
                  ? endCityId
                  : option.path.junctionCityIds[i];
          return (routeId, startId, endId);
        }).toList(),
      );
      enriched.add(
        JourneyOption(
          path: option.path,
          routes: option.routes,
          junctionCities: option.junctionCities,
          startCityId: option.startCityId,
          endCityId: option.endCityId,
          startCityName: option.startCityName,
          endCityName: option.endCityName,
          estimatedDistanceKm: distKm,
          cityCount: option.cityCount,
        ),
      );
    }

    return [...enriched, ...rest];
  }

  /// Check if a destination city is reachable from a start
  /// city via the route network.
  Future<bool> isReachable(
    int startCityId,
    int endCityId,
  ) async {
    if (startCityId == endCityId) return true;
    final options = await findJourneyOptions(
      startCityId: startCityId,
      endCityId: endCityId,
    );
    return options.isNotEmpty;
  }

  /// Get all cities across all routes, deduplicated by ID.
  ///
  /// Useful for populating city search UI. Cities are
  /// returned in no particular order.
  Future<List<CityEntity>> getAllCities() async {
    final graph = await buildGraph();
    final seen = <int>{};
    final cities = <CityEntity>[];

    for (final routeId in graph.routeIndex.keys) {
      final routeCities =
          await _junctionService.getCitiesForRoute(routeId);
      for (final city in routeCities) {
        if (seen.add(city.id)) {
          cities.add(city);
        }
      }
    }

    return cities;
  }

  /// Clears the cached graph. Call after data sync.
  void clearCache() {
    _cachedGraph = null;
  }

  /// Validates city ordering on [path] and builds a
  /// [JourneyOption] if valid.
  ///
  /// For each route segment, verifies that the start city
  /// (or junction) appears before the end city (or next
  /// junction) in the route's ordered city list.
  ///
  /// Also computes the estimated total distance in km by
  /// summing haversine distances between consecutive route
  /// points across all segments.
  ///
  /// Returns null if ordering is invalid on any segment.
  Future<JourneyOption?> _validateAndBuildOption({
    required RouteGraph graph,
    required RoutePath path,
    required int startCityId,
    required int endCityId,
    bool computeDistance = true,
  }) async {
    final routes = <RouteEntity>[];
    final junctionCities = <CityEntity>[];
    var totalCityCount = 0;

    // Collect segment anchors for distance computation
    // after validation passes.
    final segmentAnchors = <(int, int, int)>[];

    for (var i = 0; i < path.routeIds.length; i++) {
      final routeId = path.routeIds[i];
      final route = graph.routeIndex[routeId];
      if (route == null) return null;
      routes.add(route);

      // Determine the start and end anchors for this
      // segment.
      final segmentStartCityId = i == 0
          ? startCityId
          : path.junctionCityIds[i - 1];

      final segmentEndCityId =
          i == path.routeIds.length - 1
              ? endCityId
              : path.junctionCityIds[i];

      // Use the graph's pre-built city index for fast
      // position lookups. Falls back to getCitiesForRoute
      // for city entity resolution.
      final cityIndex =
          graph.routeCityIndex[routeId] ?? {};

      final startIdx = cityIndex[segmentStartCityId];
      final endIdx = cityIndex[segmentEndCityId];

      // Both cities must exist on the route and be in
      // walking order.
      if (startIdx == null ||
          endIdx == null ||
          endIdx <= startIdx) {
        return null;
      }

      // Count cities in this segment (inclusive).
      totalCityCount += endIdx - startIdx + 1;

      segmentAnchors.add(
        (routeId, segmentStartCityId, segmentEndCityId),
      );

      // Resolve junction city entity (if not last segment).
      if (i < path.junctionCityIds.length) {
        final junctionId = path.junctionCityIds[i];
        final cities =
            await _junctionService.getCitiesForRoute(
          routeId,
        );
        final junctionCity = cities.where(
          (c) => c.id == junctionId,
        );
        if (junctionCity.isNotEmpty) {
          junctionCities.add(junctionCity.first);
        }
      }
    }

    // Subtract double-counted junction cities (each junction
    // city appears in both adjacent segments).
    totalCityCount -= path.junctionCityIds.length;

    // Compute estimated distance across all segments
    // (skipped when computeDistance is false for perf).
    final distanceKm = computeDistance
        ? await _estimateDistanceKm(segmentAnchors)
        : null;

    // Resolve start and end city names.
    String startCityName;
    String endCityName;
    try {
      final firstCities =
          await _junctionService.getCitiesForRoute(
        path.routeIds.first,
      );
      startCityName = firstCities
          .firstWhere((c) => c.id == startCityId)
          .name;
    } catch (_) {
      startCityName = 'City $startCityId';
    }

    try {
      final lastCities =
          await _junctionService.getCitiesForRoute(
        path.routeIds.last,
      );
      endCityName = lastCities
          .firstWhere((c) => c.id == endCityId)
          .name;
    } catch (_) {
      endCityName = 'City $endCityId';
    }

    return JourneyOption(
      path: path,
      routes: routes,
      junctionCities: junctionCities,
      startCityId: startCityId,
      endCityId: endCityId,
      startCityName: startCityName,
      endCityName: endCityName,
      estimatedDistanceKm: distanceKm,
      cityCount: totalCityCount,
    );
  }

  /// Sums haversine distances between consecutive route
  /// points for each segment, returning total in km.
  ///
  /// Each segment is a (routeId, startCityId, endCityId)
  /// tuple. Route points are cached per route ID to avoid
  /// redundant DB queries when multiple segments share a
  /// route.
  ///
  /// Returns null if route points cannot be loaded.
  Future<double?> _estimateDistanceKm(
    List<(int, int, int)> segments,
  ) async {
    try {
      var totalMeters = 0.0;

      for (final (routeId, startCityId, endCityId)
          in segments) {
        final points =
            await _repository.getRoutePointsByRouteIdFromDb(
          routeId: routeId,
          startingCityId: startCityId,
          destCityId: endCityId,
        );
        totalMeters += _sumPointDistances(points);
      }

      return totalMeters / 1000;
    } catch (e) {
      AppLogger.w(
        'RoutePathFinder: distance estimation failed: $e',
      );
      return null;
    }
  }

  /// Sums haversine distances between consecutive route
  /// points in meters.
  static double _sumPointDistances(
    List<RoutePointEntity> points,
  ) {
    if (points.length < 2) return 0;
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += calculateDistance(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
    }
    return total;
  }
}
