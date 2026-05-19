part of 'repository.dart';

/// Database query operations for Repository
extension RepositoryQueries on Repository {
  /// Get albergue images by albergue ID
  Future<List<ImageEntity>> getAlbergueImagesByAlbergueId(
    int albergueId,
  ) async {
    return _appDatabase.getAllAlbergueImages(albergueId: albergueId);
  }

  /// Get route by ID
  Future<RouteEntity> getRouteById(int id) async {
    return _appDatabase.getRouteById(routeId: id);
  }

  /// Get all routes from database
  Future<List<RouteEntity>> getRoutesFromDb() async {
    final result = await _appDatabase.queryList(table: 'routes');
    return result.map(RouteEntity.fromJson).toList();
  }

  /// Get all route points from database
  Future<List<RoutePointEntity>> getRoutePointsFromDb() async {
    final result = await _appDatabase.queryList(table: 'route_points');
    return result.map(RoutePointEntity.fromJson).toList();
  }

  /// Get alt route points with values by route ID
  Future<List<AltRoutePointEntity>> getAltRoutePointsWithValueByRouteId({
    required int routeId,
  }) async {
    return _appDatabase.getAltRoutePointsWithValues(routeId: routeId);
  }

  /// Get route points by route ID, optionally filtered by start and end cities
  Future<List<RoutePointEntity>> getRoutePointsByRouteIdFromDb({
    required int routeId,
    int? startingCityId,
    int? destCityId,
  }) async {
    final routePoints = await _appDatabase.getRoutePointsByRouteId(
      routeId: routeId,
    );
    if (startingCityId != null && destCityId != null) {
      final startingCity = await getCityByIdFromDb(startingCityId);
      final destCity = await getCityByIdFromDb(destCityId);

      final startingRoutePoint = startingCity.routePoints.firstWhere(
        (rp) => rp.routeId == routeId,
        orElse: () => startingCity.routePoints.first,
      );
      final destRoutePoint = destCity.routePoints.firstWhere(
        (rp) => rp.routeId == routeId,
        orElse: () => destCity.routePoints.first,
      );

      final startingPoint = routePoints.indexWhere(
        (element) => element.id == startingRoutePoint.id,
      );
      final destPoint = routePoints.indexWhere(
        (element) => element.id == destRoutePoint.id,
      );

      // Defensive: if either index is invalid (e.g. orElse
      // picked a route point from a different route), return
      // the full unsliced list rather than crashing.
      if (startingPoint < 0 ||
          destPoint < 0 ||
          destPoint < startingPoint) {
        return routePoints;
      }
      return routePoints.sublist(startingPoint, destPoint + 1);
    }
    return routePoints;
  }

  /// Get cities by route ID
  Future<List<CityEntity>> getCitiesByRouteIdFromDb(int routeId) async {
    return _appDatabase.getCitiesByRouteId(routeId: routeId);
  }

  /// Get city by ID
  Future<CityEntity> getCityByIdFromDb(int cityId) async {
    return _appDatabase.getCityById(cityId: cityId);
  }

  /// [CityEntity] or null if missing / invalid [cityId].
  Future<CityEntity?> tryGetCityByIdFromDb(int? cityId) async {
    if (cityId == null || cityId <= 0) return null;
    try {
      return await _appDatabase.getCityById(cityId: cityId);
    } catch (_) {
      return null;
    }
  }

  /// Fills missing city/route ids from local DB (albergues + city_routes).
  Future<AlbergueNavigationIds> resolveAlbergueNavigationIds({
    required int albergueId,
    int? cityId,
    int? routeId,
  }) async {
    final cid = (cityId != null && cityId > 0) ? cityId : null;
    final rid = (routeId != null && routeId > 0) ? routeId : null;

    var city = cid;
    city ??= await _appDatabase.getCityIdForAlbergue(albergueId);

    var route = rid;
    if (route == null && city != null) {
      route = await _appDatabase.getFirstRouteIdForCity(city);
    }

    return AlbergueNavigationIds(cityId: city, routeId: route);
  }

  /// Check if city has albergues
  Future<bool> cityHasAlbergues(int cityId) async {
    return _appDatabase.cityHasAlbergues(cityId: cityId);
  }

  /// Get albergues with nested objects from database
  Future<List<AlbergueEntity>> getAlberguesWithNestedObjectsFromDb({
    int? cityId,
    int? albergueId,
  }) async {
    return _appDatabase.getAlberguesWithNestedObjects(
      cityId: cityId,
      albergueId: albergueId,
    );
  }

  Future<List<AlbergueEntity>> getAlberguesWithNestedObjectsFromDbByIds(
    List<int> albergueIds,
  ) async {
    if (albergueIds.isEmpty) return [];
    return _appDatabase.getAlberguesWithNestedObjectsByIds(albergueIds);
  }

  /// Check if database is empty
  Future<bool> isDatabaseEmpty() async {
    return _appDatabase.isDatabaseEmpty(await _appDatabase.database);
  }

  /// Check if route is still valid
  Future<bool> isRouteValid(int id) async {
    return _appDatabase.routeExists(id);
  }

  /// Check if city is still valid
  Future<bool> cityExistsOnRoute(int cityId, int routeId) async {
    return _appDatabase.cityExistsOnRoute(cityId, routeId);
  }

  /// Get a mapping of city IDs to all their route IDs
  /// from city_routes.
  Future<Map<int, Set<int>>> getCityRouteMapping() async {
    final rows = await _appDatabase.queryList(
      table: 'city_routes',
    );
    final map = <int, Set<int>>{};
    for (final row in rows) {
      final cityId = row['city_id'] as int;
      final routeId = row['route_id'] as int;
      (map[cityId] ??= <int>{}).add(routeId);
    }
    return map;
  }

  /// Returns `(cityId, routeId) -> routePointId` for every
  /// city-on-route touching point in the DB.
  ///
  /// Used by the route graph builder to compute the actual
  /// distance between the two routes' touching points at a
  /// shared city and filter out junctions where the points
  /// are too far apart to be practical.
  Future<Map<(int cityId, int routeId), int>>
      getAllCityRoutePointMappings() async {
    return _appDatabase.getAllCityRoutePointMappings();
  }

  /// Get city pairs export by start city id
  Future<ApiResult<CityPairsForStartCityResponse>>
      getCityPairsExportByStartCityId(int startCityId) async {
    final cached =
        await _appPreferences.getCityPairsExportCacheIfValid(startCityId);
    if (cached != null) {
      try {
        return ApiSuccess(CityPairsForStartCityResponse.fromJson(cached));
      } catch (_) {
        // Corrupt cache — fall through to network.
        AppLogger.e(
          'Corrupt city pairs export cache for start city $startCityId',
          tag: 'RepositoryQueries',
          error: _,
        );
      }
    }

    final result = await _networkService.getCityPairs(startCityId: startCityId);
    switch (result) {
      case ApiSuccess(data: final response):
        try {
          await _appPreferences.setCityPairsExportCache(
            startCityId,
            <String, dynamic>{
              'startCityId': response.startCityId,
              'startCityName': response.startCityName,
              'totalPlans': response.totalPlans,
              'pairs': response.pairs?.map((e) => e.toJson()).toList(),
            },
          );
        } catch (_) {
          // Best-effort cache; response is still valid.
        }
        return ApiSuccess(response);
      case ApiFailure(message: final errorMessage):
        return ApiFailure(errorMessage);
    }
  }
}
