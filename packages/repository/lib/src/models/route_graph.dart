// ignore_for_file: public_member_api_docs

import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:storage/storage.dart';

/// An edge in the route connectivity graph, representing a
/// connection from one route to another at a specific
/// junction city.
class RouteConnection extends Equatable {
  const RouteConnection({
    required this.targetRouteId,
    required this.junctionCityId,
    required this.junctionCityName,
    required this.junctionIndexOnSource,
  });

  /// The route reachable via this connection.
  final int targetRouteId;

  /// The city where the two routes meet.
  final int junctionCityId;

  /// Display name of the junction city.
  final String junctionCityName;

  /// Zero-based index of the junction city in the source
  /// route's ordered city list. Used for position-aware
  /// path finding (e.g., filtering junctions that are
  /// behind the start city).
  final int junctionIndexOnSource;

  @override
  List<Object?> get props => [
        targetRouteId,
        junctionCityId,
        junctionCityName,
        junctionIndexOnSource,
      ];
}

/// A candidate path through the route graph, representing
/// an ordered sequence of routes connected at junction
/// cities.
class RoutePath extends Equatable {
  const RoutePath({
    required this.routeIds,
    required this.junctionCityIds,
  });

  /// Ordered sequence of route IDs from start to end.
  final List<int> routeIds;

  /// Junction city IDs between consecutive routes.
  /// Length is always `routeIds.length - 1`.
  final List<int> junctionCityIds;

  /// Number of junctions (route transitions) in this path.
  int get junctionCount => junctionCityIds.length;

  /// Whether this path uses a single route with no
  /// junctions.
  bool get isDirect => junctionCityIds.isEmpty;

  @override
  List<Object?> get props => [routeIds, junctionCityIds];
}

/// A displayable journey suggestion containing resolved
/// entities for a path between two cities.
class JourneyOption extends Equatable {
  const JourneyOption({
    required this.path,
    required this.routes,
    required this.junctionCities,
    required this.startCityId,
    required this.endCityId,
    required this.startCityName,
    required this.endCityName,
    this.estimatedDistanceKm,
    this.cityCount,
  });

  /// The underlying route path.
  final RoutePath path;

  /// Full route entities in path order.
  final List<RouteEntity> routes;

  /// Junction city entities between consecutive routes.
  final List<CityEntity> junctionCities;

  /// Starting city ID.
  final int startCityId;

  /// Ending city ID.
  final int endCityId;

  /// Starting city display name.
  final String startCityName;

  /// Ending city display name.
  final String endCityName;

  /// Estimated total distance in km (null in Phase 1).
  final double? estimatedDistanceKm;

  /// Total number of cities across all route segments.
  final int? cityCount;

  @override
  List<Object?> get props => [
        path,
        routes,
        junctionCities,
        startCityId,
        endCityId,
        startCityName,
        endCityName,
        estimatedDistanceKm,
        cityCount,
      ];
}

/// The route connectivity graph built from junction data.
///
/// Edges connect routes that share a non-terminus junction
/// city. Provides BFS-based path finding between route sets.
class RouteGraph {
  const RouteGraph({
    required this.adjacency,
    required this.routeIndex,
    required this.cityRouteIndex,
    this.routeCityIndex = const {},
  });

  /// Adjacency list: route ID -> outgoing connections.
  final Map<int, List<RouteConnection>> adjacency;

  /// Lookup of route ID -> RouteEntity.
  final Map<int, RouteEntity> routeIndex;

  /// Mapping of city ID -> set of route IDs that pass
  /// through it.
  final Map<int, Set<int>> cityRouteIndex;

  /// Mapping of route ID -> (city ID -> index in ordered
  /// city list). Used for position lookups.
  final Map<int, Map<int, int>> routeCityIndex;

  /// Returns the set of all route IDs reachable from
  /// [startRouteIds] via BFS on the adjacency graph.
  ///
  /// Includes the start routes themselves. Useful for fast
  /// reachability checks without full path computation.
  ///
  /// When [startCityIndices] is provided, the first hop from
  /// each start route only follows junctions whose index on
  /// the source route is strictly greater than the start
  /// city's index (junctions ahead in walking order).
  /// Subsequent hops are unconstrained.
  /// Map keys are route IDs, values are city indices.
  Set<int> findReachableRoutes(
    Set<int> startRouteIds, {
    Map<int, int>? startCityIndices,
  }) {
    final visited = <int>{...startRouteIds};
    final isStartRoute = <int>{...startRouteIds};
    final queue = Queue<int>.from(startRouteIds);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final edges = adjacency[current];
      if (edges == null) continue;

      for (final edge in edges) {
        // On a start route, only follow junctions that
        // are ahead of the start city.
        if (startCityIndices != null &&
            isStartRoute.contains(current)) {
          final minIdx = startCityIndices[current];
          if (minIdx != null &&
              edge.junctionIndexOnSource <= minIdx) {
            continue;
          }
        }

        if (visited.add(edge.targetRouteId)) {
          queue.add(edge.targetRouteId);
        }
      }
    }

    return visited;
  }

  /// Finds all paths from any route in [startRouteIds] to
  /// any route in [endRouteIds] using breadth-first search.
  ///
  /// When [startCityIndices] is provided, only junctions
  /// AFTER the start city on each start route are considered
  /// for the first hop (junction index > start city index).
  ///
  /// When [endCityIndices] is provided, a route is only
  /// considered a valid goal if it has at least one incoming
  /// junction BEFORE the end city (junction index < end city
  /// index). For direct routes (start == end route), the
  /// end city just needs to come after the start city.
  ///
  /// [maxDepth] limits the number of route transitions
  /// (junctions) allowed. Defaults to 3.
  ///
  /// Returns an empty list if no paths exist within the
  /// depth limit.
  List<RoutePath> findPaths({
    required Set<int> startRouteIds,
    required Set<int> endRouteIds,
    Map<int, int>? startCityIndices,
    Map<int, int>? endCityIndices,
    int maxDepth = 3,
  }) {
    final results = <RoutePath>[];

    // BFS state: each entry is (current route, path of
    // route IDs so far, junction city IDs so far,
    // last junction's index on current route — used to
    // ensure the next junction is further along).
    final queue =
        Queue<(int, List<int>, List<int>, int?)>();

    for (final startId in startRouteIds) {
      // For start routes, the "last junction index" is
      // the start city's index (next junction must be after).
      final startIdx = startCityIndices?[startId];
      queue.add((startId, [startId], const [], startIdx));
    }

    while (queue.isNotEmpty) {
      final (currentRoute, routePath, junctions,
          lastJunctionIdxOnCurrent) = queue.removeFirst();

      // Check if we reached a goal route.
      if (endRouteIds.contains(currentRoute)) {
        // For multi-route paths, validate that the last
        // junction comes BEFORE the end city on this route.
        if (junctions.isNotEmpty && endCityIndices != null) {
          final endIdx = endCityIndices[currentRoute];
          if (endIdx != null &&
              lastJunctionIdxOnCurrent != null &&
              lastJunctionIdxOnCurrent >= endIdx) {
            // Junction is at or after the end city —
            // user would need to walk backward.
            continue;
          }
        }

        results.add(
          RoutePath(
            routeIds: routePath,
            junctionCityIds: junctions,
          ),
        );
        // Cap results to avoid combinatorial explosion
        // when the destination is on many routes.
        if (results.length >= 50) return results;
        // Keep expanding from goal routes so we discover
        // multi-route alternatives, but respect depth limit.
      }

      // Depth limit: number of junctions so far.
      if (junctions.length >= maxDepth) continue;

      final edges = adjacency[currentRoute];
      if (edges == null) continue;

      for (final edge in edges) {
        // Avoid cycles: skip routes already in the path.
        if (routePath.contains(edge.targetRouteId)) {
          continue;
        }

        // Only follow junctions that are AFTER the last
        // junction (or start city) on the current route.
        if (lastJunctionIdxOnCurrent != null &&
            edge.junctionIndexOnSource <=
                lastJunctionIdxOnCurrent) {
          continue;
        }

        // Compute the junction's index on the TARGET
        // route for the next hop's forward check.
        final junctionIdxOnTarget =
            routeCityIndex[edge.targetRouteId]
                ?[edge.junctionCityId];

        queue.add(
          (
            edge.targetRouteId,
            [...routePath, edge.targetRouteId],
            [...junctions, edge.junctionCityId],
            junctionIdxOnTarget,
          ),
        );
      }
    }

    return results;
  }
}
