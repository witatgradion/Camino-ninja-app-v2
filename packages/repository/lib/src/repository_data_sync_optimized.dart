part of 'repository.dart';

/// Data synchronization operations for Repository
extension RepositoryDataSyncOptimized on Repository {
  /// Chunk size for bulk inserts; smaller = more yields to UI, larger = fewer round-trips.
  static const int _bulkInsertChunkSize = 250;

  /// Fetches routes, route_points, cities in parallel then parses in isolates
  /// and saves all in one transaction.
  Future<void> fetchAndSaveRoutesRoutePointsAndCitiesAtomically({
    required bool shouldUpdateRoutes,
    required bool shouldUpdateRoutePoints,
    required bool shouldUpdateCities,
  }) async {
    if (!shouldUpdateRoutes &&
        !shouldUpdateRoutePoints &&
        !shouldUpdateCities) {
      return;
    }
    final routesBytesFuture = shouldUpdateRoutes
        ? _networkService.getRoutesOnlyProtoBytes()
        : Future<ApiResult<Uint8List>>.value(ApiSuccess(Uint8List(0)));
    final routePointsBytesFuture = shouldUpdateRoutePoints
        ? _networkService.getRoutePointsProtoBytes()
        : Future<ApiResult<Uint8List>>.value(ApiSuccess(Uint8List(0)));
    final citiesBytesFuture = shouldUpdateCities
        ? _networkService.getCitiesProtoBytes()
        : Future<ApiResult<Uint8List>>.value(ApiSuccess(Uint8List(0)));

    final results = await Future.wait([
      routesBytesFuture,
      routePointsBytesFuture,
      citiesBytesFuture,
    ]);

    Uint8List? routeBytes;
    Uint8List? routePointBytes;
    Uint8List? cityBytes;

    switch (results[0]) {
      case ApiSuccess(data: final data):
        routeBytes = shouldUpdateRoutes && data.isNotEmpty ? data : null;
      case ApiFailure(message: final m):
        if (shouldUpdateRoutes) throw Exception(m);
        routeBytes = null;
    }
    switch (results[1]) {
      case ApiSuccess(data: final data):
        routePointBytes =
            shouldUpdateRoutePoints && data.isNotEmpty ? data : null;
      case ApiFailure(message: final m):
        if (shouldUpdateRoutePoints) throw Exception(m);
        routePointBytes = null;
    }
    switch (results[2]) {
      case ApiSuccess(data: final data):
        cityBytes = shouldUpdateCities && data.isNotEmpty ? data : null;
      case ApiFailure(message: final m):
        if (shouldUpdateCities) throw Exception(m);
        cityBytes = null;
    }

    if (routeBytes == null && routePointBytes == null && cityBytes == null) {
      return;
    }

    final parseFutures = <Future<List<Map<String, dynamic>>>?>[
      if (routeBytes != null)
        compute(parseRoutesProtoToMaps, routeBytes)
      else
        null,
      if (routePointBytes != null)
        compute(parseRoutePointsProtoToMaps, routePointBytes)
      else
        null,
      if (cityBytes != null)
        compute(parseCitiesProtoToMaps, cityBytes)
      else
        null,
    ];
    final parsed = await Future.wait([
      parseFutures[0] ?? Future.value(<Map<String, dynamic>>[]),
      parseFutures[1] ?? Future.value(<Map<String, dynamic>>[]),
      parseFutures[2] ?? Future.value(<Map<String, dynamic>>[]),
    ]);
    final routeMaps = routeBytes != null ? parsed[0] : null;
    final routePointMaps = routePointBytes != null ? parsed[1] : null;
    final cityMaps = cityBytes != null ? parsed[2] : null;

    if (routeMaps == null && routePointMaps == null && cityMaps == null) {
      return;
    }

    final db = await _appDatabase.database;
    await db.transaction((txn) async {
      if (routeMaps != null && routeMaps.isNotEmpty) {
        await _saveRoutesFromMaps(txn, routeMaps);
      }
      if (routePointMaps != null && routePointMaps.isNotEmpty) {
        await _saveRoutePointsFromMaps(txn, routePointMaps);
      }
      if (cityMaps != null && cityMaps.isNotEmpty) {
        await _saveCitiesFromMaps(txn, cityMaps);
      }
    });
  }

  Future<void> _saveRoutesFromMaps(
      dynamic txn, List<Map<String, dynamic>> routeMaps,) async {
    final newIds = routeMaps.map((m) => m['id'] as int).toSet();
    final batch = txn.batch();
    for (final map in routeMaps) {
      batch.insert('routes', map, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    await _deleteObsoleteInTable(txn, 'routes', 'id', newIds);
  }

  Future<void> _saveRoutePointsFromMaps(
      dynamic txn, List<Map<String, dynamic>> routePointMaps,) async {
    final newIds = routePointMaps.map((m) => m['id'] as int).toSet();
    for (var i = 0; i < routePointMaps.length; i += _bulkInsertChunkSize) {
      final end = (i + _bulkInsertChunkSize < routePointMaps.length)
          ? i + _bulkInsertChunkSize
          : routePointMaps.length;
      final batch = txn.batch();
      for (var j = i; j < end; j++) {
        batch.insert(
          'route_points',
          routePointMaps[j],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      if (end < routePointMaps.length) {
        await Future<void>.delayed(Duration.zero);
      }
    }
    await _deleteObsoleteInTable(txn, 'route_points', 'id', newIds);
  }

  Future<void> _saveCitiesFromMaps(
      dynamic txn, List<Map<String, dynamic>> cityMaps,) async {
    final newCityIds = cityMaps.map((m) => m['id'] as int).toSet();
    for (var i = 0; i < cityMaps.length; i += _bulkInsertChunkSize) {
      final end = (i + _bulkInsertChunkSize < cityMaps.length)
          ? i + _bulkInsertChunkSize
          : cityMaps.length;
      final batch = txn.batch();
      for (var j = i; j < end; j++) {
        final city = cityMaps[j];
        final row = Map<String, dynamic>.from(city)
          ..remove('route_ids')
          ..remove('route_point_ids');
        batch.insert('cities', row,
            conflictAlgorithm: ConflictAlgorithm.replace,);
        final routeIds = city['route_ids'] as List<dynamic>? ?? [];
        final routePointIds = city['route_point_ids'] as List<dynamic>? ?? [];
        final cityId = city['id'] as int;
        for (final id in routeIds) {
          batch.insert(
            'city_routes',
            {'city_id': cityId, 'route_id': id},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (final id in routePointIds) {
          batch.insert(
            'city_route_points',
            {'city_id': cityId, 'route_point_id': id},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      await batch.commit(noResult: true);
      if (end < cityMaps.length) await Future<void>.delayed(Duration.zero);
    }
    await _deleteObsoleteInTable(
        txn, 'city_route_points', 'city_id', newCityIds,);
    await _deleteObsoleteInTable(txn, 'city_routes', 'city_id', newCityIds);
    await _deleteObsoleteInTable(txn, 'cities', 'id', newCityIds);
  }

  Future<void> _deleteObsoleteInTable(
    dynamic txn,
    String table,
    String idColumn,
    Set<int> keepIds,
  ) async {
    if (keepIds.isEmpty) return;
    if (keepIds.length > 500) {
      await _deleteObsoleteWithTempTable(txn, table, idColumn, keepIds);
    } else {
      final idList = keepIds.toList();
      final placeholders = List.filled(idList.length, '?').join(',');
      await txn.delete(
        table,
        where: '$idColumn NOT IN ($placeholders)',
        whereArgs: idList,
      );
    }
  }

  Future<void> _deleteObsoleteWithTempTable(
    dynamic txn,
    String table,
    String idColumn,
    Set<int> keepIds,
  ) async {
    await txn.execute('''
      CREATE TEMP TABLE IF NOT EXISTS temp_keep_ids (
        keep_id INTEGER PRIMARY KEY
      )
    ''');
    await txn.delete('temp_keep_ids');
    final batch = txn.batch();
    for (final id in keepIds) {
      batch.insert('temp_keep_ids', {'keep_id': id});
    }
    await batch.commit(noResult: true);
    await txn.execute('''
      DELETE FROM $table
      WHERE $idColumn NOT IN (SELECT keep_id FROM temp_keep_ids)
    ''');
    await txn.delete('temp_keep_ids');
  }
}
