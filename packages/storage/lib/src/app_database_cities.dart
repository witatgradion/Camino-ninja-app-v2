part of 'app_database.dart';

/// City operations for AppDatabase
extension AppDatabaseCities on AppDatabase {
  /// Get cities by route ID with route points, ordered by route_point_order
  Future<List<CityEntity>> getCitiesByRouteId({
    required int routeId,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.rawQuery('''
        WITH RankedCities AS (
          SELECT DISTINCT c.*,
            GROUP_CONCAT(DISTINCT cr.route_id) as route_ids,
            GROUP_CONCAT(DISTINCT crp.route_point_id) as route_point_ids,
            MIN(rp.order_key) as route_point_order
          FROM cities c 
          INNER JOIN city_route_points crp ON c.id = crp.city_id 
          INNER JOIN route_points rp ON rp.id = crp.route_point_id 
          INNER JOIN city_routes cr ON c.id = cr.city_id
          WHERE rp.route_id = ? AND cr.route_id = ?
          GROUP BY c.id
        )
        SELECT * FROM RankedCities
        ORDER BY route_point_order ASC
      ''', [routeId, routeId]);

      return Future.wait(result.map((row) => CityEntity.fromDatabaseRow(
            row,
            (routeIds) => _fetchRoutesByIds(txn, routeIds),
            (routePointIds) => _fetchRoutePointsByIds(txn, routePointIds),
          )));
    });
  }

  /// Get city by ID with its related routes and route points
  Future<CityEntity> getCityById({required int cityId}) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.rawQuery('''
        SELECT c.*, 
        GROUP_CONCAT(DISTINCT cr.route_id) as route_ids,
        GROUP_CONCAT(DISTINCT crp.route_point_id) as route_point_ids
        FROM cities c
        LEFT JOIN city_routes cr ON c.id = cr.city_id
        LEFT JOIN city_route_points crp ON c.id = crp.city_id
        WHERE c.id = ?
        GROUP BY c.id
      ''', [cityId]);

      if (result.isEmpty) {
        throw Exception('City not found');
      }

      return CityEntity.fromDatabaseRow(
        result.first,
        (routeIds) => _fetchRoutesByIds(txn, routeIds),
        (routePointIds) => _fetchRoutePointsByIds(txn, routePointIds),
      );
    });
  }

  /// First [route_id] linked to [city] in [city_routes] (stable order).
  Future<int?> getFirstRouteIdForCity(int cityId) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT route_id FROM city_routes
      WHERE city_id = ?
      ORDER BY route_id ASC
      LIMIT 1
      ''',
      [cityId],
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['route_id'];
    if (raw == null) return null;
    final id = raw is int ? raw : int.tryParse(raw.toString());
    if (id == null || id <= 0) return null;
    return id;
  }

  /// Check if a city has any albergues
  Future<bool> cityHasAlbergues({required int cityId}) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.query(
        'albergues',
        where: 'city_id = ?',
        whereArgs: [cityId],
        limit: 1,
      );
      return result.isNotEmpty;
    });
  }

  /// Helper: Fetch routes by IDs in batch
  Future<List<RouteEntity>> _fetchRoutesByIds(
    Transaction txn,
    List<int> routeIds,
  ) async {
    if (routeIds.isEmpty) return [];
    final placeholders = List.filled(routeIds.length, '?').join(',');
    final rows = await txn.rawQuery(
      'SELECT * FROM routes WHERE id IN ($placeholders)',
      routeIds,
    );
    return rows.map(RouteEntity.fromJson).toList();
  }

  /// Helper: Fetch route points by IDs in batch
  Future<List<RoutePointEntity>> _fetchRoutePointsByIds(
    Transaction txn,
    List<int> routePointIds,
  ) async {
    if (routePointIds.isEmpty) return [];
    final placeholders = List.filled(routePointIds.length, '?').join(',');
    final rows = await txn.rawQuery(
      'SELECT * FROM route_points WHERE id IN ($placeholders) '
      'ORDER BY id ASC',
      routePointIds,
    );
    return rows.map(RoutePointEntity.fromJson).toList();
  }

  /// Check if city exists AND is associated with a specific route
  Future<bool> cityExistsOnRoute(int cityId, int routeId) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.rawQuery('''
        SELECT c.id FROM cities c
        INNER JOIN city_routes cr ON c.id = cr.city_id
        WHERE c.id = ? AND cr.route_id = ?
        LIMIT 1
      ''', [cityId, routeId]);
      return result.isNotEmpty;
    });
  }

  /// Returns a map of `(cityId, routeId) -> routePointId`
  /// for the city's touching point on that route.
  ///
  /// Used to compute the actual distance between where two
  /// routes enter/exit a shared city, so the junction graph
  /// can filter out "shared" cities that are actually too
  /// far apart to walk between without a detour.
  ///
  /// `city_route_points` only stores `(city_id, route_point_id)`;
  /// the route id is joined in from `route_points.route_id`.
  Future<Map<(int cityId, int routeId), int>>
      getAllCityRoutePointMappings() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT crp.city_id AS city_id,
             rp.route_id AS route_id,
             crp.route_point_id AS route_point_id
      FROM city_route_points crp
      INNER JOIN route_points rp ON rp.id = crp.route_point_id
      WHERE rp.route_id IS NOT NULL
    ''');

    final map = <(int, int), int>{};
    for (final row in rows) {
      final cityId = row['city_id'] as int?;
      final routeId = row['route_id'] as int?;
      final pointId = row['route_point_id'] as int?;
      if (cityId != null && routeId != null && pointId != null) {
        map[(cityId, routeId)] = pointId;
      }
    }
    return map;
  }

  /// Batch fetch cities by IDs using pre-fetched route points (no nested DB queries)
  Future<Map<int, CityEntity>> getCitiesByIds(
    List<int> cityIds,
    List<RoutePointEntity> allRoutePoints,
  ) async {
    if (cityIds.isEmpty) return {};

    final db = await database;
    final uniqueIds = cityIds.toSet().toList();
    final placeholders = List.filled(uniqueIds.length, '?').join(',');

    final result = await db.rawQuery('''
      SELECT c.*, 
      GROUP_CONCAT(DISTINCT crp.route_point_id) as route_point_ids
      FROM cities c
      LEFT JOIN city_route_points crp ON c.id = crp.city_id
      WHERE c.id IN ($placeholders)
      GROUP BY c.id
    ''', uniqueIds);

    final Map<int, CityEntity> cityMap = {};
    for (final row in result) {
      final city = CityEntity.fromDatabaseRowLite(row, allRoutePoints);
      cityMap[city.id] = city;
    }
    return cityMap;
  }
}
