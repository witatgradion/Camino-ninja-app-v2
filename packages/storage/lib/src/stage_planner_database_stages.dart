part of 'stage_planner_database.dart';

/// Formats a DateTime as a date-only string (yyyy-MM-dd).
String _toDateOnly(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Stage CRUD operations for StagePlannerDatabase
extension StagePlannerDatabaseStages on StagePlannerDatabase {
  /// Create a new stage
  Future<int> createStage({
    required int stagePlanId,
    required int routeId,
    required int startCityId,
    required int endCityId,
    DateTime? date,
    int daysToStay = 1,
    int? startAlbergueId,
    int? endAlbergueId,
    String? customStartNotes,
    String? customEndNotes,
    String? stageNotes,
    int? stageNumber,
  }) async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();

    return await db.transaction((txn) async {
      // Auto-calculate stage_number if not provided
      var finalStageNumber = stageNumber;
      if (finalStageNumber == null) {
        final existing = await txn.rawQuery(
          'SELECT MAX(stage_number) as max_num '
          'FROM stages WHERE stage_plan_id = ?',
          [stagePlanId],
        );
        final maxNum = existing.first['max_num'] as int?;
        finalStageNumber = (maxNum ?? 0) + 1;
      }

      final id = await txn.insert(
        'stages',
        {
          'stage_plan_id': stagePlanId,
          'route_id': routeId,
          'stage_uuid': _uuid.v4(),
          if (date != null) 'date': _toDateOnly(date),
          'days_to_stay': daysToStay,
          'start_city_id': startCityId,
          'end_city_id': endCityId,
          'start_albergue_id': startAlbergueId,
          'end_albergue_id': endAlbergueId,
          'custom_start_notes': customStartNotes,
          'custom_end_notes': customEndNotes,
          'stage_notes': stageNotes,
          'created_at': now,
          'stage_number': finalStageNumber,
        },
      );
      await txn.update(
        'stage_plans',
        {'updated_at': now},
        where: 'id = ?',
        whereArgs: [stagePlanId],
      );
      return id;
    });
  }

  /// Get all stages for a stage plan
  Future<List<StageEntity>> getStagesByStagePlanId(int stagePlanId) async {
    final db = await database;
    return await db.transaction((txn) async {
      final result = await txn.query(
        'stages',
        where: 'stage_plan_id = ?',
        whereArgs: [stagePlanId],
        orderBy: 'stage_number ASC',
      );

      return result.map((row) => StageEntity.fromJson(row)).toList();
    });
  }

  /// Get a specific stage
  Future<StageEntity?> getStageById(int stageId) async {
    final db = await database;
    return await db.transaction((txn) async {
      final result = await txn.query(
        'stages',
        where: 'id = ?',
        whereArgs: [stageId],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return StageEntity.fromJson(result.first);
    });
  }

  /// Resolve a stage by stable stage_uuid within a plan.
  Future<StageEntity?> getStageByPlanAndUuid({
    required int stagePlanId,
    required String stageUuid,
  }) async {
    final trimmed = stageUuid.trim();
    if (trimmed.isEmpty) return null;
    final db = await database;
    final rows = await db.query(
      'stages',
      where: 'stage_plan_id = ? AND stage_uuid = ?',
      whereArgs: [stagePlanId, trimmed],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StageEntity.fromJson(rows.first);
  }

  /// Update a stage with partial data
  Future<void> updateStagePartial({
    required int stageId,
    DateTime? date,
    int? daysToStay,
    int? startCityId,
    int? endCityId,
    int? startAlbergueId,
    int? endAlbergueId,
    String? customStartNotes,
    String? customEndNotes,
    String? stageNotes,
    bool clearStageNotes = false,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      if (date != null) {
        updateData['date'] = _toDateOnly(date);
      }
      if (daysToStay != null) {
        updateData['days_to_stay'] = daysToStay;
      }
      if (startCityId != null) updateData['start_city_id'] = startCityId;
      if (endCityId != null) updateData['end_city_id'] = endCityId;
      if (startAlbergueId != null) {
        updateData['start_albergue_id'] = startAlbergueId;
      }
      if (endAlbergueId != null) updateData['end_albergue_id'] = endAlbergueId;
      if (customStartNotes != null) {
        updateData['custom_start_notes'] = customStartNotes;
      }
      if (customEndNotes != null) {
        updateData['custom_end_notes'] = customEndNotes;
      }
      if (clearStageNotes) {
        updateData['stage_notes'] = null;
      } else if (stageNotes != null) {
        updateData['stage_notes'] = stageNotes;
      }

      await txn.update(
        'stages',
        updateData,
        where: 'id = ?',
        whereArgs: [stageId],
      );
      await txn.rawUpdate(
        'UPDATE stage_plans SET updated_at = ? '
        'WHERE id = (SELECT stage_plan_id FROM stages WHERE id = ?)',
        [updateData['updated_at'], stageId],
      );
    });
  }

  /// Update a stage with full entity data
  Future<void> updateStage(StageEntity stage) async {
    final db = await database;
    await db.transaction((txn) async {
      final updatedData = stage.toJson();
      updatedData['updated_at'] =
          DateTime.now().toUtc().toIso8601String();
      updatedData['date'] = stage.date != null
          ? _toDateOnly(stage.date!)
          : null;
      updatedData['days_to_stay'] = stage.daysToStay;

      await txn.update(
        'stages',
        updatedData,
        where: 'id = ?',
        whereArgs: [stage.id],
      );
      await txn.update(
        'stage_plans',
        {'updated_at': updatedData['updated_at']},
        where: 'id = ?',
        whereArgs: [stage.stagePlanId],
      );
    });
  }

  /// Delete a stage
  ///
  /// After deletion, surviving stages in the same plan are renumbered
  /// to a contiguous `1..N` sequence in the same transaction. This
  /// prevents the `stage_number` gaps that would otherwise accumulate
  /// across middle deletes (combined with the `MAX+1` allocator in
  /// [createStage]) and break position-based sync matching.
  Future<void> deleteStage(int stageId) async {
    final db = await database;
    await db.transaction((txn) async {
      final stageResult = await txn.query(
        'stages',
        columns: ['stage_plan_id'],
        where: 'id = ?',
        whereArgs: [stageId],
        limit: 1,
      );
      await txn.delete(
        'stages',
        where: 'id = ?',
        whereArgs: [stageId],
      );
      if (stageResult.isNotEmpty) {
        final stagePlanId = stageResult.first['stage_plan_id'] as int;

        // Renumber survivors to a contiguous 1..N sequence so that
        // future deletes/inserts don't accumulate stage_number gaps.
        // Skip the per-row UPDATE when stage_number is already
        // correct so no-op deletions (e.g. last-stage delete) don't
        // hammer the DB.
        final survivors = await txn.query(
          'stages',
          columns: ['id', 'stage_number'],
          where: 'stage_plan_id = ?',
          whereArgs: [stagePlanId],
          orderBy: 'stage_number ASC, id ASC',
        );
        for (var i = 0; i < survivors.length; i++) {
          final desired = i + 1;
          final current = survivors[i]['stage_number'] as int?;
          if (current != desired) {
            await txn.update(
              'stages',
              {'stage_number': desired},
              where: 'id = ?',
              whereArgs: [survivors[i]['id']],
            );
          }
        }

        await txn.update(
          'stage_plans',
          {'updated_at': DateTime.now().toUtc().toIso8601String()},
          where: 'id = ?',
          whereArgs: [stagePlanId],
        );
      }
    });
  }

  /// Shift stage numbers to make room for insertion.
  /// All stages with stage_number > [afterStageNumber]
  /// get incremented by 1.
  Future<void> shiftStageNumbersAfter({
    required int stagePlanId,
    required int afterStageNumber,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE stages SET stage_number = stage_number + 1 '
        'WHERE stage_plan_id = ? AND stage_number > ?',
        [stagePlanId, afterStageNumber],
      );
    });
  }

  // Sync Operations

  /// Upsert a stage from sync response
  Future<int> upsertStageFromSync({
    required int stagePlanId,
    required int stageNumber,
    required int routeId,
    required int startCityId,
    required int endCityId,
    String? date,
    int? daysToStay,
    int? startAlbergueId,
    int? endAlbergueId,
    String? customStartNotes,
    String? customEndNotes,
    String? stageNotes,
    String? createdAt,
    String? updatedAt,
    String? serverStageUuid,
    String? sentLocalStageUuid,
    Set<int>? seenStageNumbers,
  }) async {
    if (seenStageNumbers != null &&
        seenStageNumbers.contains(stageNumber)) {
      AppLogger.w(
        'Duplicate stage_number=$stageNumber in '
        'plan=$stagePlanId during sync upsert; '
        'keeping first-seen row',
        tag: 'StagePlannerDb',
      );
      return -1;
    }
    seenStageNumbers?.add(stageNumber);

    final db = await database;
    return db.transaction((txn) async {
      Map<String, Object?>? existing;
      var matchSource = 'none';

      Future<void> tryMatchByUuid(String? raw) async {
        if (existing != null) return;
        final uuid = raw?.trim();
        if (uuid == null || uuid.isEmpty) return;
        final rows = await txn.query(
          'stages',
          where: 'stage_plan_id = ? AND stage_uuid = ?',
          whereArgs: [stagePlanId, uuid],
          limit: 1,
        );
        if (rows.isNotEmpty) {
          existing = rows.first;
          matchSource = 'uuid:$uuid';
        }
      }

      // Prefer UUID matches to preserve SQLite row id.
      await tryMatchByUuid(serverStageUuid);
      await tryMatchByUuid(sentLocalStageUuid);

      // Fallback to stage_number for backward compatibility.
      if (existing == null) {
        final rows = await txn.query(
          'stages',
          where: 'stage_plan_id = ? AND stage_number = ?',
          whereArgs: [stagePlanId, stageNumber],
          limit: 1,
        );
        if (rows.isNotEmpty) {
          existing = rows.first;
          matchSource = 'stage_number:$stageNumber';
        }
      }

      final data = <String, Object?>{
        'stage_plan_id': stagePlanId,
        'stage_number': stageNumber,
        'route_id': routeId,
        'date': date?.split('T').first,
        'days_to_stay': (daysToStay ?? 1).clamp(1, 365),
        'start_city_id': startCityId,
        'end_city_id': endCityId,
        'start_albergue_id': startAlbergueId,
        'end_albergue_id': endAlbergueId,
        'custom_start_notes': customStartNotes,
        'custom_end_notes': customEndNotes,
        'stage_notes': stageNotes,
        'updated_at':
            updatedAt ?? DateTime.now().toUtc().toIso8601String(),
      };

      final matched = existing;
      if (matched != null) {
        final existingId = matched['id'] as int;
        final existingUuid = matched['stage_uuid'] as String?;
        var assignedUuid = existingUuid;
        if (existingUuid == null || existingUuid.trim().isEmpty) {
          final fromServer = serverStageUuid?.trim();
          final fromSent = sentLocalStageUuid?.trim();
          if (fromServer != null && fromServer.isNotEmpty) {
            data['stage_uuid'] = fromServer;
            assignedUuid = fromServer;
          } else if (fromSent != null && fromSent.isNotEmpty) {
            data['stage_uuid'] = fromSent;
            assignedUuid = fromSent;
          } else {
            final generated = _uuid.v4();
            data['stage_uuid'] = generated;
            assignedUuid = generated;
          }
        }
        await txn.update(
          'stages',
          data,
          where: 'id = ?',
          whereArgs: [existingId],
        );
        AppLogger.d(
          '[SYNC_UUID] upsert matched existing stage: '
          'planId=$stagePlanId stageNumber=$stageNumber '
          'localStageId=$existingId matchSource=$matchSource '
          'serverUuid=${serverStageUuid ?? '-'} '
          'sentUuid=${sentLocalStageUuid ?? '-'} '
          'storedUuid=${assignedUuid ?? '-'}',
          tag: 'StagePlannerDB',
        );
        return existingId;
      } else {
        data['created_at'] =
            createdAt ?? DateTime.now().toUtc().toIso8601String();
        final fromServer = serverStageUuid?.trim();
        final fromSent = sentLocalStageUuid?.trim();
        String finalUuid;
        if (fromServer != null && fromServer.isNotEmpty) {
          finalUuid = fromServer;
        } else if (fromSent != null && fromSent.isNotEmpty) {
          finalUuid = fromSent;
        } else {
          finalUuid = _uuid.v4();
        }
        data['stage_uuid'] = finalUuid;
        final insertedId = await txn.insert('stages', data);
        AppLogger.d(
          '[SYNC_UUID] upsert inserted new stage: '
          'planId=$stagePlanId stageNumber=$stageNumber '
          'newLocalStageId=$insertedId assignedUuid=$finalUuid '
          'serverUuid=${serverStageUuid ?? '-'} '
          'sentUuid=${sentLocalStageUuid ?? '-'}',
          tag: 'StagePlannerDB',
        );
        return insertedId;
      }
    });
  }

  /// Update the days_to_stay value for a single stage
  Future<void> updateStageDaysToStay({
    required int stageId,
    required int daysToStay,
  }) async {
    final clampedDays = daysToStay.clamp(1, 30);
    final db = await database;
    await db.transaction((txn) async {
      final now = DateTime.now().toUtc().toIso8601String();
      await txn.update(
        'stages',
        {
          'days_to_stay': clampedDays,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [stageId],
      );
      // Also update parent plan's updated_at
      await txn.rawUpdate(
        'UPDATE stage_plans SET updated_at = ? '
        'WHERE id = (SELECT stage_plan_id '
        'FROM stages WHERE id = ?)',
        [now, stageId],
      );
    });
  }

  /// Update stage numbers for reordering.
  Future<void> updateStageNumbers({
    required int stagePlanId,
    required Map<int, int> stageIdToNumber,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final entry in stageIdToNumber.entries) {
        await txn.update(
          'stages',
          {'stage_number': entry.value},
          where: 'id = ?',
          whereArgs: [entry.key],
        );
      }
      await txn.update(
        'stage_plans',
        {
          'updated_at':
              DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [stagePlanId],
      );
    });
  }

  /// Delete all stages for a plan and replace with new ones
  Future<void> replaceStagesForPlan(int stagePlanId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'stages',
        where: 'stage_plan_id = ?',
        whereArgs: [stagePlanId],
      );
    });
  }

  /// Delete local stages for a plan whose id is not in [localIds].
  Future<void> deleteStagesNotInIds({
    required int stagePlanId,
    required List<int> localIds,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      if (localIds.isEmpty) {
        await txn.delete(
          'stages',
          where: 'stage_plan_id = ?',
          whereArgs: [stagePlanId],
        );
        return;
      }
      final placeholders = localIds.map((_) => '?').join(',');
      await txn.rawDelete(
        'DELETE FROM stages WHERE stage_plan_id = ? '
        'AND id NOT IN ($placeholders)',
        [stagePlanId, ...localIds],
      );
    });
  }

  /// Heal stages with null stage_number by assigning the
  /// next available number (max + 1, continuing upward).
  /// Returns the count of stages that were healed.
  ///
  /// Null stage_number values cause position-based fallback
  /// in sync serialization, which can collide with other
  /// stages and cause silent data loss on re-sync.
  Future<int> healMissingStageNumbers(int stagePlanId) async {
    final db = await database;
    return db.transaction<int>((txn) async {
      final rows = await txn.query(
        'stages',
        columns: ['id', 'stage_number'],
        where: 'stage_plan_id = ?',
        whereArgs: [stagePlanId],
      );
      final existing = rows
          .where((r) => r['stage_number'] != null)
          .map((r) => r['stage_number']! as int)
          .toList();
      final nullRows = rows
          .where((r) => r['stage_number'] == null)
          .toList();
      if (nullRows.isEmpty) return 0;
      var next = (existing.isEmpty
              ? 0
              : existing.reduce((a, b) => a > b ? a : b)) +
          1;
      final now = DateTime.now().toUtc().toIso8601String();
      for (final row in nullRows) {
        await txn.update(
          'stages',
          {'stage_number': next, 'updated_at': now},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
        next++;
      }
      await txn.update(
        'stage_plans',
        {'updated_at': now},
        where: 'id = ?',
        whereArgs: [stagePlanId],
      );
      AppLogger.w(
        'Healed ${nullRows.length} stages with null '
        'stageNumber in plan=$stagePlanId',
        tag: 'StagePlannerDb',
      );
      return nullRows.length;
    });
  }
}