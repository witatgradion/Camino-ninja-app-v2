part of 'stage_planner_database.dart';

/// Stage Plan CRUD operations for StagePlannerDatabase
extension StagePlannerDatabaseStagePlans on StagePlannerDatabase {
  /// Create a new stage plan
  Future<int> createStagePlan({
    required int routeId,
    bool isImported = false,
    String? name,
    String? trailRouteIds,
    String? startingDate,
  }) async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();

    return await db.transaction((txn) async {
      final id = await txn.insert(
        'stage_plans',
        {
          'route_id': routeId,
          'created_at': now,
          'is_imported': isImported ? 1 : 0,
          'name': name,
          'starting_date': startingDate,
          'uuid': _uuid.v4(),
          'trail_route_ids': trailRouteIds,
        },
      );
      return id;
    });
  }

  /// Get all stage plans for a route
  Future<List<StagePlanEntity>> getStagePlansByRouteId(int routeId) async {
    final db = await database;
    return await db.transaction((txn) async {
      final result = await txn.query(
        'stage_plans',
        where: 'route_id = ? AND deleted_at IS NULL',
        whereArgs: [routeId],
        orderBy: 'created_at DESC',
      );

      return result.map((row) => StagePlanEntity.fromJson(row)).toList();
    });
  }

  /// Get a specific stage plan with its stages
  Future<StagePlanEntity?> getStagePlanById(int stagePlanId) async {
    final db = await database;
    return await db.transaction((txn) async {
      // Get stage plan
      final stagePlanResult = await txn.query(
        'stage_plans',
        where: 'id = ?',
        whereArgs: [stagePlanId],
        limit: 1,
      );

      if (stagePlanResult.isEmpty) return null;

      final stagePlan = StagePlanEntity.fromJson(stagePlanResult.first);

      // Get stages for this plan
      final stagesResult = await txn.query(
        'stages',
        where: 'stage_plan_id = ?',
        whereArgs: [stagePlanId],
        orderBy: 'stage_number ASC',
      );

      final stages = stagesResult
          .map((row) => StageEntity.fromJson(row))
          .toList();

      return StagePlanEntity(
        id: stagePlan.id,
        routeId: stagePlan.routeId,
        createdAt: stagePlan.createdAt,
        updatedAt: stagePlan.updatedAt,
        stages: stages,
        isImported: stagePlan.isImported,
        name: stagePlan.name,
        startingDate: stagePlan.startingDate,
        uuid: stagePlan.uuid,
        planUuid: stagePlan.planUuid,
        deletedAt: stagePlan.deletedAt,
        trailRouteIds: stagePlan.trailRouteIds,
      );
    });
  }

  /// Update a stage plan
  Future<void> updateStagePlan({
    required int stagePlanId,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      await txn.update(
        'stage_plans',
        updateData,
        where: 'id = ?',
        whereArgs: [stagePlanId],
      );
    });
  }

  /// Soft-delete a stage plan (sets deleted_at instead of removing the row)
  Future<void> deleteStagePlan(int stagePlanId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'stage_plans',
        {
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [stagePlanId],
      );
    });
  }

  /// Get the number of non-deleted stage plans.
  Future<int> getStagePlanCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM stage_plans '
      'WHERE deleted_at IS NULL',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get all stage plans that need validation (for batch processing)
  Future<List<int>> getAllStagePlanIds() async {
    final db = await database;
    return await db.transaction((txn) async {
      final result = await txn.query(
        'stage_plans',
        columns: ['id'],
        where: 'deleted_at IS NULL',
      );
      return result.map((row) => row['id'] as int).toList();
    });
  }

  /// Get all stage plans (entities) — excludes soft-deleted
  Future<List<StagePlanEntity>> getAllStagePlans() async {
    final db = await database;
    return await db.transaction((txn) async {
      final result = await txn.query(
        'stage_plans',
        where: 'deleted_at IS NULL',
        orderBy: 'created_at DESC',
      );
      return result.map((row) => StagePlanEntity.fromJson(row)).toList();
    });
  }

  /// Returns the starting date of the user's "active" plan as a single-row
  /// SQL lookup, or `null` when no non-deleted plan has a starting_date.
  ///
  /// Semantic: prefer the soonest upcoming plan (starting_date >= today);
  /// fall back to the most recent past plan only if no future plan exists.
  /// Implemented as an `ORDER BY ... LIMIT 1` query so it does not load
  /// every plan into Dart.
  Future<DateTime?> getActivePlanStartingDate() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT starting_date
      FROM stage_plans
      WHERE starting_date IS NOT NULL
        AND deleted_at IS NULL
      ORDER BY
        CASE WHEN date(starting_date) >= date('now') THEN 0 ELSE 1 END ASC,
        CASE WHEN date(starting_date) >= date('now')
             THEN julianday(starting_date)
             ELSE -julianday(starting_date)
        END ASC
      LIMIT 1
    ''');
    if (result.isEmpty) return null;
    final raw = result.first['starting_date'] as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Update the isImported flag of a stage plan
  Future<void> updateStagePlanIsImported({
    required int stagePlanId,
    required bool isImported,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'stage_plans',
        {
          'is_imported': isImported ? 1 : 0,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [stagePlanId],
      );
    });
  }

  /// Sets server-side identifiers after import (e.g. shared deep link).
  Future<void> updateStagePlanUuids({
    required int stagePlanId,
    required String uuid,
    String? planUuid,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'stage_plans',
        {
          'uuid': uuid,
          'plan_uuid': planUuid,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [stagePlanId],
      );
    });
  }

  /// Update the name of a stage plan
  Future<void> updateStagePlanName({
    required int stagePlanId,
    String? name,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'stage_plans',
        {
          'name': name,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [stagePlanId],
      );
    });
  }

  /// Update the starting date of a stage plan
  Future<void> updateStagePlanStartingDate({
    required int stagePlanId,
    String? startingDate,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'stage_plans',
        {
          'starting_date': startingDate,
          'updated_at':
              DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [stagePlanId],
      );
    });
  }

  // Sync Operations

  /// Get all stage plans including soft-deleted ones (for sync)
  Future<List<StagePlanEntity>> getAllStagePlansIncludingDeleted() async {
    final db = await database;
    return await db.transaction((txn) async {
      final result = await txn.query(
        'stage_plans',
        orderBy: 'created_at DESC',
      );
      final plans = <StagePlanEntity>[];
      for (final row in result) {
        final plan = StagePlanEntity.fromJson(row);
        final stages = await txn.query(
          'stages',
          where: 'stage_plan_id = ?',
          whereArgs: [plan.id],
          orderBy: 'stage_number ASC',
        );
        plans.add(StagePlanEntity(
          id: plan.id,
          routeId: plan.routeId,
          createdAt: plan.createdAt,
          updatedAt: plan.updatedAt,
          stages:
              stages.map((s) => StageEntity.fromJson(s)).toList(),
          isImported: plan.isImported,
          name: plan.name,
          startingDate: plan.startingDate,
          uuid: plan.uuid,
          planUuid: plan.planUuid,
          deletedAt: plan.deletedAt,
          trailRouteIds: plan.trailRouteIds,
        ));
      }
      return plans;
    });
  }

  /// Upsert a stage plan from sync response (insert or update by UUID).
  ///
  /// `trail_route_ids` is written verbatim — including null. This matches
  /// the "device-that-pushed wins" semantics: a server response carrying
  /// NULL for a previously-multi-trail plan downgrades the local row
  /// gracefully to single-route.
  Future<int> upsertStagePlanFromSync({
    required String uuid,
    required int routeId,
    String? name,
    bool isImported = false,
    String? planUuid,
    String? startingDate,
    String? createdAt,
    String? updatedAt,
    String? trailRouteIds,
  }) async {
    final db = await database;
    return await db.transaction((txn) async {
      final existing = await txn.query(
        'stage_plans',
        where: 'uuid = ?',
        whereArgs: [uuid],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        final id = existing.first['id'] as int;
        await txn.update(
          'stage_plans',
          {
            'route_id': routeId,
            'name': name,
            'is_imported': isImported ? 1 : 0,
            'plan_uuid': planUuid,
            'starting_date': startingDate,
            'updated_at': updatedAt ??
                DateTime.now().toUtc().toIso8601String(),
            'deleted_at': null,
            'trail_route_ids': trailRouteIds,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        return id;
      } else {
        return await txn.insert(
          'stage_plans',
          {
            'uuid': uuid,
            'route_id': routeId,
            'name': name,
            'is_imported': isImported ? 1 : 0,
            'plan_uuid': planUuid,
            'starting_date': startingDate,
            'created_at': createdAt ??
                DateTime.now().toUtc().toIso8601String(),
            'updated_at': updatedAt,
            'trail_route_ids': trailRouteIds,
          },
        );
      }
    });
  }

  /// Hard-delete soft-deleted plans (after successful sync)
  Future<void> hardDeleteSyncedPlans() async {
    final db = await database;
    await db.transaction((txn) async {
      // First delete stages for soft-deleted plans
      final deletedPlans = await txn.query(
        'stage_plans',
        columns: ['id'],
        where: 'deleted_at IS NOT NULL',
      );
      for (final plan in deletedPlans) {
        await txn.delete(
          'stages',
          where: 'stage_plan_id = ?',
          whereArgs: [plan['id']],
        );
      }
      // Then delete the plans themselves
      await txn.delete(
        'stage_plans',
        where: 'deleted_at IS NOT NULL',
      );
    });
  }

  /// Delete local plans whose UUID is not in the given list
  Future<void> deleteLocalPlansNotInUuids(List<String> uuids) async {
    final db = await database;
    await db.transaction((txn) async {
      if (uuids.isEmpty) {
        // Delete all plans and stages
        await txn.delete('stages');
        await txn.delete('stage_plans');
        return;
      }
      final placeholders = uuids.map((_) => '?').join(',');
      // Delete stages for plans not in the UUID list
      await txn.rawDelete('''
        DELETE FROM stages WHERE stage_plan_id IN (
          SELECT id FROM stage_plans WHERE uuid NOT IN ($placeholders) AND deleted_at IS NULL
        )
      ''', uuids);
      // Delete the plans themselves
      await txn.rawDelete(
        'DELETE FROM stage_plans WHERE uuid NOT IN ($placeholders) AND deleted_at IS NULL',
        uuids,
      );
    });
  }
}
