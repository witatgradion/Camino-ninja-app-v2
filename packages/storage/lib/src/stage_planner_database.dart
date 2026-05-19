import 'dart:async';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:storage/src/models/stage_plan_entity.dart';
import 'package:storage/src/models/stage_entity.dart';
import 'package:storage/src/app_database.dart';
import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

part 'stage_planner_database_stage_plans.dart';
part 'stage_planner_database_stages.dart';
part 'stage_planner_database_validation.dart';

/// Stage Planner Database Helper
/// Separate database for stage planner feature to avoid impacting the main database
///
/// Operations are organized into extensions:
/// - [StagePlannerDatabaseStagePlans] - Stage plan CRUD operations
/// - [StagePlannerDatabaseStages] - Stage CRUD operations
/// - [StagePlannerDatabaseValidation] - Data validation operations
const _uuid = Uuid();

/// Current schema version for the stage planner database.
///
/// Exposed as a constant so tests can reopen historical databases
/// at this version without duplicating the number.
const int stagePlannerDatabaseVersion = 10;

/// SharedPreferences key the v9 migration uses to record the number of
/// `stage_uuid` rows it backfilled. A higher layer (e.g. `PlanCubit`)
/// reads this on startup, fires a one-shot
/// `StageUuidBackfillEvent`, and clears the key.
///
/// Migrations cannot reach `GetIt`/analytics directly, so the prefs
/// key is the bridge between the storage layer and the analytics
/// layer for this one-shot diagnostic event.
const String pendingStageUuidV9BackfillCountKey =
    'pending_stage_uuid_v9_backfill_count';

/// Enables foreign key constraints (CASCADE delete support).
///
/// Extracted so the migration test harness can exercise the exact
/// production [onConfigure] path.
Future<void> stagePlannerOnConfigure(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
}

/// Runs schema migrations for the stage planner database.
///
/// Extracted so the migration test harness can exercise the exact
/// production [onUpgrade] path. See inline branches for what each
/// version bump does.
Future<void> stagePlannerOnUpgrade(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  if (oldVersion < 3) {
    await _migrateStagePlannerToV3(db);
  }
  if (oldVersion < 4) {
    await _migrateStagePlannerToV4(db);
  }
  if (oldVersion < 5) {
    await _migrateStagePlannerToV5(db);
  }
  if (oldVersion < 7) {
    await _migrateStagePlannerToV7(db, oldVersion, newVersion);
  }
  if (oldVersion < 8) {
    await _migrateStagePlannerToV8(db, oldVersion, newVersion);
  }
  if (oldVersion < 9) {
    await _migrateStagePlannerToV9(db, oldVersion, newVersion);
  }
  if (oldVersion < 10) {
    await _migrateStagePlannerToV10(db, oldVersion, newVersion);
  }
}

Future<void> _migrateStagePlannerToV3(Database db) async {
  final columns = await db.rawQuery(
    'PRAGMA table_info(stage_plans)',
  );
  final hasIsImported = columns.any(
    (col) => col['name'] == 'is_imported',
  );
  if (!hasIsImported) {
    await db.execute(
      'ALTER TABLE stage_plans ADD COLUMN is_imported INTEGER NOT NULL DEFAULT 0',
    );
  }
  final hasName = columns.any(
    (col) => col['name'] == 'name',
  );
  if (!hasName) {
    await db.execute(
      'ALTER TABLE stage_plans ADD COLUMN name TEXT',
    );
  }
}

Future<void> _migrateStagePlannerToV4(Database db) async {
  // Add new sync columns to stage_plans
  final columns = await db.rawQuery(
    'PRAGMA table_info(stage_plans)',
  );
  if (!columns.any((col) => col['name'] == 'uuid')) {
    await db.execute(
      'ALTER TABLE stage_plans ADD COLUMN uuid TEXT',
    );
  }
  if (!columns.any((col) => col['name'] == 'plan_uuid')) {
    await db.execute(
      'ALTER TABLE stage_plans ADD COLUMN plan_uuid TEXT',
    );
  }
  if (!columns.any((col) => col['name'] == 'deleted_at')) {
    await db.execute(
      'ALTER TABLE stage_plans ADD COLUMN deleted_at TEXT',
    );
  }

  // Add stage_number to stages
  final stageColumns = await db.rawQuery(
    'PRAGMA table_info(stages)',
  );
  if (!stageColumns.any((col) => col['name'] == 'stage_number')) {
    await db.execute(
      'ALTER TABLE stages ADD COLUMN stage_number INTEGER',
    );
  }

  // Auto-populate stage_number for existing stages
  // (date-sorted order per plan)
  final plans = await db.query('stage_plans', columns: ['id']);
  for (final plan in plans) {
    final planId = plan['id'] as int;
    final stages = await db.query(
      'stages',
      where: 'stage_plan_id = ?',
      whereArgs: [planId],
      orderBy: 'date ASC',
    );
    for (var i = 0; i < stages.length; i++) {
      await db.update(
        'stages',
        {'stage_number': i + 1},
        where: 'id = ?',
        whereArgs: [stages[i]['id']],
      );
    }
  }

  // Generate UUIDs for existing plans that don't have one
  final plansWithoutUuid = await db.query(
    'stage_plans',
    columns: ['id'],
    where: 'uuid IS NULL',
  );
  for (final plan in plansWithoutUuid) {
    await db.update(
      'stage_plans',
      {'uuid': _uuid.v4()},
      where: 'id = ?',
      whereArgs: [plan['id']],
    );
  }

  // Create index on uuid
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_stage_plans_uuid ON stage_plans(uuid)',
  );
}

Future<void> _migrateStagePlannerToV5(Database db) async {
  // Normalize stage dates from full datetime to date-only
  // (yyyy-MM-dd). Parse to local time first so UTC dates
  // convert to the correct local calendar date before
  // stripping the time component.
  final stagesV5 = await db.query(
    'stages',
    columns: ['id', 'date'],
  );
  for (final stage in stagesV5) {
    final dateStr = stage['date'] as String?;
    if (dateStr != null && dateStr.contains('T')) {
      final parsed = DateTime.parse(dateStr).toLocal();
      final dateOnly =
          '${parsed.year.toString().padLeft(4, '0')}-'
          '${parsed.month.toString().padLeft(2, '0')}-'
          '${parsed.day.toString().padLeft(2, '0')}';
      await db.update(
        'stages',
        {'date': dateOnly},
        where: 'id = ?',
        whereArgs: [stage['id']],
      );
    }
  }
}

Future<void> _migrateStagePlannerToV7(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  // --- DIAGNOSTIC: migration audit ---
  final prePlanCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM stage_plans',
        ),
      ) ??
      0;
  final preStageCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM stages',
        ),
      ) ??
      0;
  AppLogger.w(
    'DB migration v$oldVersion->$newVersion '
    'starting: '
    '$prePlanCount plans, $preStageCount stages',
    tag: 'StagePlannerDB',
  );

  // Add starting_date column to stage_plans (guard
  // against duplicate if a prior migration attempt
  // partially committed this DDL before rolling back)
  final existingPlanCols = await db.rawQuery(
    'PRAGMA table_info(stage_plans)',
  );
  if (!existingPlanCols.any(
    (col) => col['name'] == 'starting_date',
  )) {
    await db.execute(
      'ALTER TABLE stage_plans '
      'ADD COLUMN starting_date TEXT',
    );
  }

  // Recreate stages table to make date nullable and
  // add days_to_stay column.
  // SQLite cannot ALTER a NOT NULL constraint away, so
  // we must recreate the table.
  await db.execute('DROP TABLE IF EXISTS stages_new');
  await db.execute('''
    CREATE TABLE stages_new (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      stage_plan_id INTEGER NOT NULL,
      route_id INTEGER NOT NULL,
      date TEXT,
      start_city_id INTEGER NOT NULL,
      end_city_id INTEGER NOT NULL,
      start_albergue_id INTEGER,
      end_albergue_id INTEGER,
      custom_start_notes TEXT,
      custom_end_notes TEXT,
      stage_notes TEXT,
      created_at TEXT,
      updated_at TEXT,
      stage_number INTEGER,
      days_to_stay INTEGER NOT NULL DEFAULT 1,
      FOREIGN KEY (stage_plan_id)
        REFERENCES stage_plans(id) ON DELETE CASCADE
    )
  ''');

  // Clean up orphaned stages that would violate FK
  // constraints during table recreation. These can
  // exist from before FK enforcement was enabled.
  final orphanCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM stages '
          'WHERE stage_plan_id NOT IN '
          '(SELECT id FROM stage_plans)',
        ),
      ) ??
      0;
  if (orphanCount > 0) {
    AppLogger.w(
      'DB migration: removing $orphanCount '
      'orphaned stages',
      tag: 'StagePlannerDB',
    );
    await db.execute(
      'DELETE FROM stages '
      'WHERE stage_plan_id NOT IN '
      '(SELECT id FROM stage_plans)',
    );
  }

  await db.execute('''
    INSERT INTO stages_new (
      id, stage_plan_id, route_id, date,
      start_city_id, end_city_id,
      start_albergue_id, end_albergue_id,
      custom_start_notes, custom_end_notes,
      stage_notes, created_at, updated_at,
      stage_number, days_to_stay
    )
    SELECT
      id, stage_plan_id, route_id, date,
      start_city_id, end_city_id,
      start_albergue_id, end_albergue_id,
      custom_start_notes, custom_end_notes,
      stage_notes, created_at, updated_at,
      stage_number, 1
    FROM stages
  ''');

  await db.execute('DROP TABLE IF EXISTS stages');
  await db.execute(
    'ALTER TABLE stages_new RENAME TO stages',
  );

  // Recreate all indexes on the new stages table
  await db.execute(
    'CREATE INDEX IF NOT EXISTS '
    'idx_stages_stage_plan_id '
    'ON stages(stage_plan_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS '
    'idx_stages_route_id '
    'ON stages(route_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS '
    'idx_stages_date ON stages(date)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS '
    'idx_stages_start_city_id '
    'ON stages(start_city_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS '
    'idx_stages_end_city_id '
    'ON stages(end_city_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS '
    'idx_stages_stage_number '
    'ON stages(stage_number)',
  );

  // Data migration: populate starting_date and
  // days_to_stay for existing plans
  final plans = await db.query(
    'stage_plans',
    columns: ['id'],
  );
  for (final plan in plans) {
    final planId = plan['id'] as int;
    final stages = await db.query(
      'stages',
      where: 'stage_plan_id = ?',
      whereArgs: [planId],
      orderBy: 'stage_number ASC',
    );

    if (stages.isEmpty) continue;

    // Set starting_date to first stage's date
    final firstDate = stages.first['date'] as String?;
    if (firstDate != null) {
      await db.update(
        'stage_plans',
        {'starting_date': firstDate},
        where: 'id = ?',
        whereArgs: [planId],
      );
    }

    // Compute days_to_stay for each stage
    for (var i = 0; i < stages.length - 1; i++) {
      final currentDate = stages[i]['date'] as String?;
      final nextDate = stages[i + 1]['date'] as String?;
      if (currentDate != null && nextDate != null) {
        final current = DateTime.parse(currentDate);
        final next = DateTime.parse(nextDate);
        final diff =
            next.difference(current).inDays.clamp(1, 365);
        await db.update(
          'stages',
          {'days_to_stay': diff},
          where: 'id = ?',
          whereArgs: [stages[i]['id']],
        );
      }
    }
    // Last stage keeps days_to_stay = 1 (default)
  }

  // --- DIAGNOSTIC: post-migration audit ---
  final postPlanCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM stage_plans',
        ),
      ) ??
      0;
  final postStageCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM stages',
        ),
      ) ??
      0;
  final plansWithStartDate = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM stage_plans '
          'WHERE starting_date IS NOT NULL',
        ),
      ) ??
      0;
  AppLogger.w(
    'DB migration v$oldVersion->$newVersion '
    'complete: '
    '$postPlanCount plans '
    '($plansWithStartDate with starting_date), '
    '$postStageCount stages '
    '(pre: $prePlanCount plans, '
    '$preStageCount stages)',
    tag: 'StagePlannerDB',
  );
}

Future<void> _migrateStagePlannerToV8(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  final migrationSyncTimestamp =
      DateTime.now().toUtc().toIso8601String();

  final plansMissingUuid = await db.rawQuery(
    'SELECT id FROM stage_plans '
    "WHERE uuid IS NULL OR TRIM(uuid) = ''",
  );
  if (plansMissingUuid.isNotEmpty) {
    for (final row in plansMissingUuid) {
      await db.update(
        'stage_plans',
        {
          'uuid': _uuid.v4(),
          'updated_at': migrationSyncTimestamp,
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }
  AppLogger.i(
    '[SYNC_UUID] DB migration v$oldVersion->$newVersion '
    'plan uuid backfill: ${plansMissingUuid.length} plans updated',
    tag: 'StagePlannerDB',
  );

  final stageColumns = await db.rawQuery(
    'PRAGMA table_info(stages)',
  );
  AppLogger.i(
    '[SYNC_UUID] DB migration v$oldVersion->$newVersion '
    'stage_uuid check: column exists='
    '${stageColumns.any((col) => col['name'] == 'stage_uuid')}',
    tag: 'StagePlannerDB',
  );
  if (!stageColumns.any((col) => col['name'] == 'stage_uuid')) {
    await db.execute(
      'ALTER TABLE stages ADD COLUMN stage_uuid TEXT',
    );
    AppLogger.i(
      '[SYNC_UUID] DB migration v$oldVersion->$newVersion '
      'added stage_uuid column',
      tag: 'StagePlannerDB',
    );
  }

  final stagesMissingUuid = await db.rawQuery(
    'SELECT id, stage_plan_id FROM stages '
    "WHERE stage_uuid IS NULL OR TRIM(stage_uuid) = ''",
  );
  AppLogger.i(
    '[SYNC_UUID] DB migration v$oldVersion->$newVersion '
    'stage_uuid backfill: ${stagesMissingUuid.length} rows missing',
    tag: 'StagePlannerDB',
  );
  final touchedPlanIds = <int>{};
  for (final row in stagesMissingUuid) {
    final stagePlanId = row['stage_plan_id'] as int?;
    if (stagePlanId != null) touchedPlanIds.add(stagePlanId);
    await db.update(
      'stages',
      {
        'stage_uuid': _uuid.v4(),
        'updated_at': migrationSyncTimestamp,
      },
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }
  for (final planId in touchedPlanIds) {
    await db.update(
      'stage_plans',
      {'updated_at': migrationSyncTimestamp},
      where: 'id = ?',
      whereArgs: [planId],
    );
  }
  AppLogger.i(
    '[SYNC_UUID] DB migration v$oldVersion->$newVersion '
    'updated_at bump: ${stagesMissingUuid.length} stages, '
    '${touchedPlanIds.length} parent plans',
    tag: 'StagePlannerDB',
  );

  await db.execute(
    'CREATE UNIQUE INDEX IF NOT EXISTS '
    'idx_stages_plan_stage_uuid '
    'ON stages(stage_plan_id, stage_uuid)',
  );
  final totalStages = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM stages'),
      ) ??
      0;
  final nullUuidStages = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM stages '
          "WHERE stage_uuid IS NULL OR TRIM(stage_uuid) = ''",
        ),
      ) ??
      0;
  // Audit: clean post-backfill is the routine outcome. Leftover
  // missing UUIDs after backfill is the genuinely anomalous path
  // — keep `.w` so it pages someone via log filters.
  if (nullUuidStages > 0) {
    AppLogger.w(
      '[SYNC_UUID] DB migration v$oldVersion->$newVersion '
      'stage_uuid audit anomaly: '
      '$totalStages stages, $nullUuidStages missing uuid '
      'after backfill',
      tag: 'StagePlannerDB',
    );
  } else {
    AppLogger.i(
      '[SYNC_UUID] DB migration v$oldVersion->$newVersion '
      'stage_uuid audit clean: $totalStages stages, '
      '0 missing uuid',
      tag: 'StagePlannerDB',
    );
  }
}

/// v9: Backfill any `stage_uuid` rows that are NULL or blank.
///
/// DB v8 added the `stage_uuid` column but only backfilled rows
/// missing a UUID inside the same migration step — any device whose
/// upgrade path skipped or partially completed v8 (or whose stages
/// were inserted post-v8 with an explicit NULL) could still have
/// blank uuids. Combined with `@JsonKey(includeIfNull: false)` on
/// the sync push payload, those rows persist NULL forever — locally
/// and on the server — which is the upstream cause of the
/// position-based mismatch patched at the sync-merge layer in
/// this PR.
///
/// This migration is idempotent: if every row already has a valid
/// `stage_uuid`, the SELECT returns 0 rows and the loop is a no-op.
Future<void> _migrateStagePlannerToV9(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  // Safety net for users whose DB reached v8 via develop (which added
  // only stage_uuid). The combining-trails branch's v8 added only
  // trail_route_ids. Ensure both columns exist after v9 regardless of
  // upgrade path.
  final planColumns = await db.rawQuery(
    'PRAGMA table_info(stage_plans)',
  );
  if (!planColumns.any(
    (col) => col['name'] == 'trail_route_ids',
  )) {
    await db.execute(
      'ALTER TABLE stage_plans ADD COLUMN trail_route_ids TEXT',
    );
  }

  final migrationSyncTimestamp =
      DateTime.now().toUtc().toIso8601String();

  final stagesMissingUuid = await db.rawQuery(
    'SELECT id, stage_plan_id FROM stages '
    "WHERE stage_uuid IS NULL OR TRIM(stage_uuid) = ''",
  );
  AppLogger.i(
    '[SYNC_UUID] DB migration v$oldVersion->$newVersion '
    'stage_uuid backfill: ${stagesMissingUuid.length} rows missing',
    tag: 'StagePlannerDB',
  );

  if (stagesMissingUuid.isEmpty) return;

  final touchedPlanIds = <int>{};
  for (final row in stagesMissingUuid) {
    final stagePlanId = row['stage_plan_id'] as int?;
    if (stagePlanId != null) touchedPlanIds.add(stagePlanId);
    await db.update(
      'stages',
      {
        'stage_uuid': _uuid.v4(),
        'updated_at': migrationSyncTimestamp,
      },
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }
  for (final planId in touchedPlanIds) {
    await db.update(
      'stage_plans',
      {'updated_at': migrationSyncTimestamp},
      where: 'id = ?',
      whereArgs: [planId],
    );
  }

  AppLogger.i(
    '[SYNC_UUID] DB migration v$oldVersion->$newVersion '
    'backfilled ${stagesMissingUuid.length} stages, '
    'bumped ${touchedPlanIds.length} parent plans',
    tag: 'StagePlannerDB',
  );

  // Persist a one-shot backfill count for the higher layer to fire
  // an analytics event on next startup. Migrations must never throw
  // on analytics persistence failure — the schema upgrade has
  // already succeeded by this point.
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      pendingStageUuidV9BackfillCountKey,
      stagesMissingUuid.length,
    );
  } catch (e, st) {
    AppLogger.w(
      'Failed to persist v9 stage_uuid backfill count to prefs',
      tag: 'StagePlannerDB',
      error: e,
      stackTrace: st,
    );
  }
}

/// v10: Ensure `stage_plans.trail_route_ids` exists.
///
/// Closes the gap where users already on `release/2.2.410`'s v9 (which
/// only backfilled `stage_uuid`) never received the
/// `trail_route_ids` column added by this branch's pre-merge v9. Users
/// upgrading from this branch's pre-merge v9 already have the column;
/// the check makes the migration idempotent for both paths.
Future<void> _migrateStagePlannerToV10(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  final planColumns = await db.rawQuery(
    'PRAGMA table_info(stage_plans)',
  );
  if (!planColumns.any(
    (col) => col['name'] == 'trail_route_ids',
  )) {
    await db.execute(
      'ALTER TABLE stage_plans ADD COLUMN trail_route_ids TEXT',
    );
    AppLogger.i(
      '[MULTI_TRAIL] DB migration v$oldVersion->$newVersion '
      'added trail_route_ids column',
      tag: 'StagePlannerDB',
    );
  } else {
    AppLogger.i(
      '[MULTI_TRAIL] DB migration v$oldVersion->$newVersion '
      'trail_route_ids column already present — no-op',
      tag: 'StagePlannerDB',
    );
  }
}

class StagePlannerDatabase {
  /// StagePlannerDatabase Factory
  factory StagePlannerDatabase() => _instance;

  StagePlannerDatabase._internal();

  static final StagePlannerDatabase _instance =
      StagePlannerDatabase._internal();
  static Database? _database;
  static Completer<Database>? _initCompleter;

  /// Close and reset the database instance
  Future<void> closeDatabase() async {
    final completer = _initCompleter;
    _initCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(
        StateError('Database closed during initialization'),
      );
    }
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    _database = null;
  }

  /// Database instance
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    if (_initCompleter != null) return _initCompleter!.future;

    final completer = Completer<Database>();
    _initCompleter = completer;

    try {
      _database = await _initDatabase();
      completer.complete(_database!);
      return _database!;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _initCompleter = null;
    }
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'stage_planner_database.db');

    final db = await openDatabase(
      path,
      version: stagePlannerDatabaseVersion,
      onConfigure: stagePlannerOnConfigure,
      onCreate: (Database db, int version) async {
        var batch = db.batch();
        _createTables(batch);
        _createIndexes(batch);
        await batch.commit();
      },
      onUpgrade: stagePlannerOnUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
    );

    await _logStageUuidAudit(db);

    return db;
  }

  Future<void> _logStageUuidAudit(Database db) async {
    final totalStages = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM stages'),
        ) ??
        0;
    final missingStageUuid = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM stages '
            "WHERE stage_uuid IS NULL OR TRIM(stage_uuid) = ''",
          ),
        ) ??
        0;
    final duplicatePerPlan = Sqflite.firstIntValue(
          await db.rawQuery('''
            SELECT COUNT(*) FROM (
              SELECT stage_plan_id, stage_uuid, COUNT(*) AS c
              FROM stages
              WHERE stage_uuid IS NOT NULL AND TRIM(stage_uuid) != ''
              GROUP BY stage_plan_id, stage_uuid
              HAVING c > 1
            )
          '''),
        ) ??
        0;
    AppLogger.w(
      '[SYNC_UUID] DB startup stage_uuid audit: '
      '$totalStages stages, $missingStageUuid missing uuid, '
      '$duplicatePerPlan duplicate (plan, uuid) groups',
      tag: 'StagePlannerDB',
    );

    if (missingStageUuid > 0) {
      final missingByPlan = await db.rawQuery('''
        SELECT stage_plan_id, COUNT(*) AS missing_count
        FROM stages
        WHERE stage_uuid IS NULL OR TRIM(stage_uuid) = ''
        GROUP BY stage_plan_id
        ORDER BY missing_count DESC, stage_plan_id ASC
        LIMIT 10
      ''');
      final summary = missingByPlan
          .map(
            (row) =>
                'plan=${row['stage_plan_id']} missing=${row['missing_count']}',
          )
          .join(', ');
      AppLogger.w(
        '[SYNC_UUID] DB startup stage_uuid missing by plan (top10): $summary',
        tag: 'StagePlannerDB',
      );
    }
  }

  /// Backfills starting_date and days_to_stay for legacy
  /// plans that have per-stage dates but no plan-level
  /// starting date.
  ///
  /// This is idempotent — plans that already have a
  /// starting_date are skipped.
  Future<void> normalizeLegacyDates() async {
    final db = await database;
    await db.transaction((txn) async {
      // Find plans with no starting_date that have at least
      // one stage with a non-null date
      final legacyPlans = await txn.rawQuery('''
        SELECT DISTINCT sp.id
        FROM stage_plans sp
        INNER JOIN stages s ON s.stage_plan_id = sp.id
        WHERE sp.starting_date IS NULL
          AND sp.deleted_at IS NULL
          AND s.date IS NOT NULL
      ''');

      AppLogger.w(
        'normalizeLegacyDates: found '
        '${legacyPlans.length} legacy plans to normalize',
        tag: 'StagePlannerDB',
      );

      if (legacyPlans.isEmpty) return;

      for (final plan in legacyPlans) {
        final planId = plan['id'] as int;
        final stages = await txn.query(
          'stages',
          where: 'stage_plan_id = ?',
          whereArgs: [planId],
          orderBy: 'stage_number ASC',
        );

        if (stages.isEmpty) continue;

        // Set starting_date to first non-null stage date
        final firstDate = stages
            .map((s) => s['date'] as String?)
            .firstWhere(
              (d) => d != null,
              orElse: () => null,
            );
        if (firstDate != null) {
          await txn.update(
            'stage_plans',
            {'starting_date': firstDate},
            where: 'id = ?',
            whereArgs: [planId],
          );
        }

        // Compute days_to_stay from consecutive stage dates
        for (var i = 0; i < stages.length - 1; i++) {
          final currentDate =
              stages[i]['date'] as String?;
          final nextDate =
              stages[i + 1]['date'] as String?;
          if (currentDate != null && nextDate != null) {
            final current =
                DateTime.tryParse(currentDate);
            final next = DateTime.tryParse(nextDate);
            if (current == null || next == null) continue;
            final diff = next
                .difference(current)
                .inDays
                .clamp(1, 365);
            await txn.update(
              'stages',
              {'days_to_stay': diff},
              where: 'id = ?',
              whereArgs: [stages[i]['id']],
            );
          }
        }
        // Clear per-stage dates — from now on dates are
        // derived from starting_date + days_to_stay.
        await txn.update(
          'stages',
          {'date': null},
          where: 'stage_plan_id = ?',
          whereArgs: [planId],
        );
      }
    });
  }

  void _createTables(Batch batch) {
    // Stage Plans table
    batch.execute('''
      CREATE TABLE IF NOT EXISTS stage_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_imported INTEGER NOT NULL DEFAULT 0,
        name TEXT,
        uuid TEXT,
        plan_uuid TEXT,
        deleted_at TEXT,
        starting_date TEXT,
        trail_route_ids TEXT
      )
    ''');

    // Stages table
    batch.execute('''
      CREATE TABLE IF NOT EXISTS stages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stage_plan_id INTEGER NOT NULL,
        route_id INTEGER NOT NULL,
        stage_uuid TEXT,
        date TEXT,
        start_city_id INTEGER NOT NULL,
        end_city_id INTEGER NOT NULL,
        start_albergue_id INTEGER,
        end_albergue_id INTEGER,
        custom_start_notes TEXT,
        custom_end_notes TEXT,
        stage_notes TEXT,
        created_at TEXT,
        updated_at TEXT,
        stage_number INTEGER,
        days_to_stay INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (stage_plan_id)
          REFERENCES stage_plans(id) ON DELETE CASCADE
      )
    ''');
  }

  void _createIndexes(Batch batch) {
    // Stage Plans indexes
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_stage_plans_route_id ON stage_plans(route_id)');
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_stage_plans_created_at ON stage_plans(created_at)');
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_stage_plans_uuid ON stage_plans(uuid)');

    // Stages indexes
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_stages_stage_plan_id ON stages(stage_plan_id)');
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_stages_route_id ON stages(route_id)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_stages_date ON stages(date)');
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_stages_start_city_id ON stages(start_city_id)');
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_stages_end_city_id ON stages(end_city_id)');
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_stages_stage_number ON stages(stage_number)');
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_stages_plan_stage_uuid '
      'ON stages(stage_plan_id, stage_uuid)',
    );
  }
}
