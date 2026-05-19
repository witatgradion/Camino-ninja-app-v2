part of 'app_database.dart';

/// Route and RoutePoint operations for AppDatabase
extension AppDatabaseRoutes on AppDatabase {
  /// Get route by ID
  Future<RouteEntity> getRouteById({required int routeId}) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.query(
        'routes',
        where: 'id = ?',
        whereArgs: [routeId],
      );
      return RouteEntity.fromJson(result.first);
    });
  }

  /// Get route points by route ID ordered by order_key
  Future<List<RoutePointEntity>> getRoutePointsByRouteId({
    required int routeId,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.query(
        'route_points',
        where: 'route_id = ?',
        whereArgs: [routeId],
        orderBy: 'order_key ASC',
      );
      return result.map(RoutePointEntity.fromJson).toList();
    });
  }

  /// Get alt route points with their values for a given route
  Future<List<AltRoutePointEntity>> getAltRoutePointsWithValues({
    required int routeId,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      var query = '''
      SELECT a.*,
      av.id as alt_route_points_value_id,
      av.order_key,
      av.alt_route_points_id,
      av.latitude,
      av.longitude
      FROM alt_route_points a
      LEFT JOIN alt_route_points_values av ON a.id = av.alt_route_points_id
      WHERE a.route_id = ?
      ORDER BY a.order_key ASC
      ''';

      final result = await txn.rawQuery(query, [routeId]);
      final Map<int, AltRoutePointEntity> altRoutePointMap = {};

      for (final row in result) {
        final altRoutePointId = row['id'] as int;
        if (!altRoutePointMap.containsKey(altRoutePointId)) {
          altRoutePointMap[altRoutePointId] = AltRoutePointEntity.fromJson(row);
        }

        if (row['alt_route_points_value_id'] != null) {
          final altRoutePointValue = AltRoutePointValueEntity.fromJson(row);
          altRoutePointMap[altRoutePointId]!.values.add(altRoutePointValue);
        }
      }
      return altRoutePointMap.values.toList();
    });
  }

  /// Check if route exists - wrapped in transaction to ensure fresh read
  Future<bool> routeExists(int routeId) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.query(
        'routes',
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [routeId],
        limit: 1,
      );
      return result.isNotEmpty;
    });
  }
}
