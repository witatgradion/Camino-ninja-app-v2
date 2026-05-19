part of 'stage_planner_database.dart';

/// Data validation operations for StagePlannerDatabase
extension StagePlannerDatabaseValidation on StagePlannerDatabase {
  /// Validate that all referenced IDs exist in the main database
  Future<Map<String, List<int>>> validateStagePlanData(int stagePlanId) async {
    final db = await database;
    final mainDb = AppDatabase();

    return await db.transaction((txn) async {
      // Get all stages for this plan
      final stages = await txn.query(
        'stages',
        where: 'stage_plan_id = ?',
        whereArgs: [stagePlanId],
      );

      final invalidRouteIds = <int>[];
      final invalidCityIds = <int>[];
      final invalidAlbergueIds = <int>[];

      // Get the stage plan to check route ID
      final stagePlanResult = await txn.query(
        'stage_plans',
        where: 'id = ?',
        whereArgs: [stagePlanId],
        limit: 1,
      );

      if (stagePlanResult.isNotEmpty) {
        final routeId = stagePlanResult.first['route_id'] as int;
        // Check if route exists in main database
        try {
          await mainDb.getRouteById(routeId: routeId);
        } catch (e) {
          invalidRouteIds.add(routeId);
        }
      }

      // Check city and albergue IDs
      for (final stage in stages) {
        final startCityId = stage['start_city_id'] as int;
        final endCityId = stage['end_city_id'] as int;
        final startAlbergueId = stage['start_albergue_id'] as int?;
        final endAlbergueId = stage['end_albergue_id'] as int?;

        // Check start city
        try {
          await mainDb.getCityById(cityId: startCityId);
        } catch (e) {
          invalidCityIds.add(startCityId);
        }

        // Check end city
        try {
          await mainDb.getCityById(cityId: endCityId);
        } catch (e) {
          invalidCityIds.add(endCityId);
        }

        // Check start albergue if provided
        if (startAlbergueId != null) {
          try {
            final albergues = await mainDb.getAlberguesWithNestedObjects(
              albergueId: startAlbergueId,
            );
            if (albergues.isEmpty) {
              invalidAlbergueIds.add(startAlbergueId);
            }
          } catch (e) {
            invalidAlbergueIds.add(startAlbergueId);
          }
        }

        // Check end albergue if provided
        if (endAlbergueId != null) {
          try {
            final albergues = await mainDb.getAlberguesWithNestedObjects(
              albergueId: endAlbergueId,
            );
            if (albergues.isEmpty) {
              invalidAlbergueIds.add(endAlbergueId);
            }
          } catch (e) {
            invalidAlbergueIds.add(endAlbergueId);
          }
        }
      }

      return {
        'invalid_route_ids': invalidRouteIds,
        'invalid_city_ids': invalidCityIds,
        'invalid_albergue_ids': invalidAlbergueIds,
      };
    });
  }

  /// Clean up invalid references in stage plans
  Future<void> cleanupInvalidReferences(AppDatabase mainDb) async {
    final db = await database;

    await db.transaction((txn) async {
      // Get all non-deleted stage plans
      final stagePlans = await txn.query(
        'stage_plans',
        where: 'deleted_at IS NULL',
      );

      for (final plan in stagePlans) {
        final planId = plan['id'] as int;
        final routeId = plan['route_id'] as int;

        // Check if route still exists
        final routeExists = await mainDb.routeExists(routeId);
        if (!routeExists) {
          // Route doesn't exist, delete the entire stage plan
          await txn.delete(
            'stage_plans',
            where: 'id = ?',
            whereArgs: [planId],
          );
          continue;
        }

        // Get stages for this plan
        final stages = await txn.query(
          'stages',
          where: 'stage_plan_id = ?',
          whereArgs: [planId],
        );

        for (final stage in stages) {
          final stageId = stage['id'] as int;
          final startCityId = stage['start_city_id'] as int;
          final endCityId = stage['end_city_id'] as int;
          final startAlbergueId = stage['start_albergue_id'] as int?;
          final endAlbergueId = stage['end_albergue_id'] as int?;

          // Check if cities exist AND are still on the route
          final startCityValid =
              await mainDb.cityExistsOnRoute(startCityId, routeId);
          final endCityValid =
              await mainDb.cityExistsOnRoute(endCityId, routeId);
          // If cities are invalid or no longer on route, delete the stage
          if (!startCityValid || !endCityValid) {
            await txn.delete(
              'stages',
              where: 'id = ?',
              whereArgs: [stageId],
            );
            continue;
          }

          // Check albergues - if they don't exist, set to null (don't delete)

          if (startAlbergueId != null) {
            try {
              final startAlbergueExists =
                  await mainDb.albergueExists(startAlbergueId);
              if (!startAlbergueExists) {
                await _clearAlbergueReference(
                    txn, stageId, 'start_albergue_id');
              }
            } catch (e) {
              await _clearAlbergueReference(txn, stageId, 'start_albergue_id');
            }
          }

          if (endAlbergueId != null) {
            try {
              final endAlbergueExists =
                  await mainDb.albergueExists(endAlbergueId);
              if (!endAlbergueExists) {
                await _clearAlbergueReference(txn, stageId, 'end_albergue_id');
              }
            } catch (e) {
              await _clearAlbergueReference(txn, stageId, 'end_albergue_id');
            }
          }
        }
      }
    });
  }

  /// Helper to clear an albergue reference from a stage
  Future<void> _clearAlbergueReference(
    Transaction txn,
    int stageId,
    String columnName,
  ) async {
    await txn.update(
      'stages',
      {
        columnName: null,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [stageId],
    );
  }
}
