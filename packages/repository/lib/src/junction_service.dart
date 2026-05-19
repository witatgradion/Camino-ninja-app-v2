// ignore_for_file: public_member_api_docs

import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

/// Shared service for detecting junction cities where
/// routes intersect. Used by both the RouteCityOverview
/// feature and the TrailBuilder.
///
/// Must call [initialize] before using any query methods.
class JunctionService {
  JunctionService(this._repository);

  final Repository _repository;

  /// Full city-to-routes mapping loaded once via
  /// [initialize].
  Map<int, Set<int>> _cityRouteMap = {};

  /// Cache of ordered city lists per route, keyed by
  /// route ID.
  final Map<int, List<CityEntity>> _routeCitiesCache = {};

  bool _isInitialized = false;

  /// Whether [initialize] has been called.
  bool get isInitialized => _isInitialized;

  /// Loads the city-route mapping from the database.
  /// Must be called before any junction queries.
  Future<void> initialize() async {
    _cityRouteMap = await _repository.getCityRouteMapping();
    _routeCitiesCache.clear();
    _isInitialized = true;
  }

  /// Returns the ordered city list for [routeId], using
  /// an internal cache to avoid repeated DB lookups.
  Future<List<CityEntity>> getCitiesForRoute(
    int routeId,
  ) async {
    assert(
      _isInitialized,
      'JunctionService.initialize() must be called first',
    );
    final cached = _routeCitiesCache[routeId];
    if (cached != null) return cached;
    final cities = await _repository.getCitiesByRouteIdFromDb(routeId);
    _routeCitiesCache[routeId] = cities;
    return cities;
  }

  /// Returns the set of all route IDs that pass through
  /// [cityId]. Returns an empty set if the city is not
  /// found in the mapping.
  Set<int> routesForCity(int cityId) {
    assert(
      _isInitialized,
      'JunctionService.initialize() must be called first',
    );
    return _cityRouteMap[cityId] ?? <int>{};
  }

  /// Returns true if [cityId] has forward cities to walk
  /// to on [routeId] -- i.e. the city is NOT the last
  /// city in that route's ordered list.
  Future<bool> hasForwardCities({
    required int cityId,
    required int routeId,
  }) async {
    assert(
      _isInitialized,
      'JunctionService.initialize() must be called first',
    );
    final cities = await getCitiesForRoute(routeId);
    if (cities.isEmpty) return false;
    return cities.last.id != cityId;
  }

  /// Returns an ordered list of junction points on
  /// [routeId], optionally starting after [fromCityId]
  /// (exclusive). If [fromCityId] is null, starts from
  /// the beginning of the route.
  ///
  /// Each [JunctionPoint] contains the junction city and
  /// the routes available for branching (excluding the
  /// current route).
  ///
  /// [allRoutes] is needed to resolve route IDs into
  /// [RouteEntity] objects. Pass the full list of routes
  /// from the database.
  Future<List<JunctionPoint>> getJunctionsForRoute({
    required int routeId,
    required List<RouteEntity> allRoutes,
    int? fromCityId,
  }) async {
    assert(
      _isInitialized,
      'JunctionService.initialize() must be called first',
    );
    final cities = await getCitiesForRoute(routeId);
    if (cities.isEmpty) return const [];

    var startIndex = 0;
    if (fromCityId != null) {
      final idx = cities.indexWhere((c) => c.id == fromCityId);
      if (idx >= 0) startIndex = idx + 1;
    }

    final segmentCities = startIndex > 0 ? cities.sublist(startIndex) : cities;

    if (segmentCities.isEmpty) return const [];

    final junctions = <JunctionPoint>[];

    for (var i = 0; i < segmentCities.length; i++) {
      final city = segmentCities[i];
      final allRouteIds = _cityRouteMap[city.id] ?? <int>{};
      final otherRouteIds = allRouteIds.where((id) => id != routeId).toSet();

      // Last city is never a junction (route ends here).
      if (otherRouteIds.isEmpty || i == segmentCities.length - 1) {
        continue;
      }

      // Filter out routes that also exist at the next
      // city -- they're still overlapping with the current
      // route and haven't actually split yet.
      final nextCityRoutes =
          _cityRouteMap[segmentCities[i + 1].id] ?? <int>{};
      final nextOther =
          nextCityRoutes.where((id) => id != routeId).toSet();

      final divergingRouteIds =
          otherRouteIds.where((id) => !nextOther.contains(id)).toSet();

      if (divergingRouteIds.isEmpty) continue;

      // Filter out routes where this city is the last
      // city -- splitting there would mean walking
      // backward with no forward cities.
      final forwardRouteIds = <int>[];
      for (final otherId in divergingRouteIds) {
        final hasForward = await hasForwardCities(
          cityId: city.id,
          routeId: otherId,
        );
        if (hasForward) {
          forwardRouteIds.add(otherId);
        }
      }

      if (forwardRouteIds.isEmpty) continue;

      final branchRoutes = forwardRouteIds
          .map(
            (id) => allRoutes.firstWhere(
              (r) => r.id == id,
              orElse: () => RouteEntity(
                id: id,
                orderKey: 0,
                routeName: 'Route $id',
              ),
            ),
          )
          .toList();

      junctions.add(
        JunctionPoint(
          city: city,
          branchRoutes: branchRoutes,
        ),
      );
    }

    return junctions;
  }

  /// Clears the internal city list cache. Call this when
  /// the underlying data may have changed (e.g. after a
  /// data sync).
  void clearCache() {
    _routeCitiesCache.clear();
  }
}
