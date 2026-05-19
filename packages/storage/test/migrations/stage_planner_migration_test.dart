import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' show Database, Sqflite;
import 'package:storage/src/stage_planner_database.dart';

import 'migration_test_harness.dart';

const _stagePlansFullColumns = {
  'id',
  'route_id',
  'created_at',
  'updated_at',
  'is_imported',
  'name',
  'uuid',
  'plan_uuid',
  'deleted_at',
  'starting_date',
  'trail_route_ids',
};

const _stagesFullColumns = {
  'id',
  'stage_plan_id',
  'route_id',
  'stage_uuid',
  'date',
  'start_city_id',
  'end_city_id',
  'start_albergue_id',
  'end_albergue_id',
  'custom_start_notes',
  'custom_end_notes',
  'stage_notes',
  'created_at',
  'updated_at',
  'stage_number',
  'days_to_stay',
};

/// Common post-migration assertions applied after every upgrade
/// path. Keeps test bodies short by checking the invariants every
/// migrated DB should satisfy at the current version.
Future<void> _assertCurrentSchemaInvariants(
  MigrationTestHarness harness,
  Database db, {
  required int expectedPlanCount,
  required int expectedStageCount,
}) async {
  await harness.expectFkValid(db);
  await harness.expectTableSchema(db, 'stage_plans', _stagePlansFullColumns);
  await harness.expectTableSchema(db, 'stages', _stagesFullColumns);

  expect(
    await harness.indexExists(db, 'idx_stage_plans_uuid'),
    isTrue,
    reason: 'idx_stage_plans_uuid should exist post-migration',
  );
  expect(
    await harness.indexExists(db, 'idx_stages_plan_stage_uuid'),
    isTrue,
    reason: 'unique idx_stages_plan_stage_uuid should exist post-migration',
  );

  expect(
    await harness.rowCount(db, 'stage_plans'),
    expectedPlanCount,
    reason: 'plan count should be preserved across migration',
  );
  expect(
    await harness.rowCount(db, 'stages'),
    expectedStageCount,
    reason:
        'stage count should equal expected (orphans dropped, '
        'rest preserved)',
  );

  // Every stage must have a non-empty stage_uuid.
  final missingUuid = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM stages '
          "WHERE stage_uuid IS NULL OR TRIM(stage_uuid) = ''",
        ),
      ) ??
      0;
  expect(missingUuid, 0, reason: 'no stage should be missing stage_uuid');

  // Every plan must have a non-empty uuid.
  final missingPlanUuid = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM stage_plans '
          "WHERE uuid IS NULL OR TRIM(uuid) = ''",
        ),
      ) ??
      0;
  expect(missingPlanUuid, 0, reason: 'no plan should be missing uuid');

  // days_to_stay must be >= 1 everywhere.
  final badDays = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM stages WHERE days_to_stay < 1',
        ),
      ) ??
      0;
  expect(badDays, 0, reason: 'days_to_stay must always be >= 1');
}

void main() {
  late MigrationTestHarness harness;

  setUp(() {
    harness = MigrationTestHarness();
  });

  tearDown(() async {
    await harness.disposeAll();
  });

  group('stage_planner v2 -> current', () {
    test('migrates clean, drops orphan, preserves plans', () async {
      final seed = await harness.openAt('stage_planner_v2.db', 2);
      await harness.seedFromSql(
        seed,
        'test/migrations/fixtures/stage_planner/v2.sql',
      );
      await seed.close();

      final db = await harness.reopenAtCurrent(
        'stage_planner_v2.db',
        currentVersion: stagePlannerDatabaseVersion,
        onConfigure: stagePlannerOnConfigure,
        onUpgrade: stagePlannerOnUpgrade,
      );

      // v2 fixture: 2 plans, 5 non-orphan stages (3 in plan 1,
      // 2 in plan 2). Orphan id=99 must be dropped.
      await _assertCurrentSchemaInvariants(
        harness,
        db,
        expectedPlanCount: 2,
        expectedStageCount: 5,
      );

      // stage_number should be populated for every stage.
      final nullStageNumber = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM stages WHERE stage_number IS NULL',
            ),
          ) ??
          0;
      expect(nullStageNumber, 0);

      // stage_number must be assigned per-plan as 1..N in date order.
      // v2 fixture: plan 1 has 3 stages, plan 2 has 2 stages.
      final plan1Numbers = (await db.query(
        'stages',
        columns: ['stage_number'],
        where: 'stage_plan_id = ?',
        whereArgs: [1],
        orderBy: 'stage_number ASC',
      ))
          .map((r) => r['stage_number'] as int)
          .toList();
      expect(plan1Numbers, equals([1, 2, 3]),
          reason: 'plan 1 should have stage_numbers {1, 2, 3}');

      final plan2Numbers = (await db.query(
        'stages',
        columns: ['stage_number'],
        where: 'stage_plan_id = ?',
        whereArgs: [2],
        orderBy: 'stage_number ASC',
      ))
          .map((r) => r['stage_number'] as int)
          .toList();
      expect(plan2Numbers, equals([1, 2]),
          reason: 'plan 2 should have stage_numbers {1, 2}');

      // starting_date populated for plans that had stages with dates.
      final missingStartDate = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM stage_plans '
              'WHERE starting_date IS NULL',
            ),
          ) ??
          0;
      expect(missingStartDate, 0);

      // Orphan stage (id=99) should be gone.
      final orphanStill = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM stages WHERE id = 99',
            ),
          ) ??
          0;
      expect(orphanStill, 0, reason: 'orphan stage must be dropped');
    });
  });

  group('stage_planner v3 -> current', () {
    test('migrates clean, drops orphan, preserves plans', () async {
      final seed = await harness.openAt('stage_planner_v3.db', 3);
      await harness.seedFromSql(
        seed,
        'test/migrations/fixtures/stage_planner/v3.sql',
      );
      await seed.close();

      final db = await harness.reopenAtCurrent(
        'stage_planner_v3.db',
        currentVersion: stagePlannerDatabaseVersion,
        onConfigure: stagePlannerOnConfigure,
        onUpgrade: stagePlannerOnUpgrade,
      );

      // v3 fixture: 2 plans, 4 non-orphan stages.
      await _assertCurrentSchemaInvariants(
        harness,
        db,
        expectedPlanCount: 2,
        expectedStageCount: 4,
      );
    });
  });

  group('stage_planner v4 -> current', () {
    test('normalizes ISO dates + backfills + drops orphan', () async {
      final seed = await harness.openAt('stage_planner_v4.db', 4);
      await harness.seedFromSql(
        seed,
        'test/migrations/fixtures/stage_planner/v4.sql',
      );
      await seed.close();

      final db = await harness.reopenAtCurrent(
        'stage_planner_v4.db',
        currentVersion: stagePlannerDatabaseVersion,
        onConfigure: stagePlannerOnConfigure,
        onUpgrade: stagePlannerOnUpgrade,
      );

      // v4 fixture: 2 plans, 5 non-orphan stages.
      await _assertCurrentSchemaInvariants(
        harness,
        db,
        expectedPlanCount: 2,
        expectedStageCount: 5,
      );

      // All dates should now be yyyy-MM-dd, no 'T' characters.
      final isoDateCount = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM stages WHERE date LIKE '%T%'",
            ),
          ) ??
          0;
      expect(isoDateCount, 0,
          reason: 'v5 migration should strip time component from dates');

      // Pin the exact post-migration format for a specific row.
      // Stage id=10 had date '2024-07-05T09:00:00.000Z' in the
      // v4 fixture; after v5's toLocal() + strip, it must be a
      // yyyy-MM-dd string with no T component. The exact calendar
      // day can shift by ±1 depending on the test runner's TZ, so
      // we pin the format (not the day) to avoid TZ flakiness.
      final stage10 = await db.query(
        'stages',
        columns: ['date'],
        where: 'id = ?',
        whereArgs: [10],
        limit: 1,
      );
      expect(stage10, hasLength(1));
      final stage10Date = stage10.first['date'] as String?;
      expect(stage10Date, isNotNull);
      expect(
        stage10Date,
        matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
        reason: 'stage id=10 date must be exactly yyyy-MM-dd '
            '(got "$stage10Date")',
      );
    });
  });

  group('stage_planner v5 -> current', () {
    test(
      'adds starting_date, days_to_stay, stage_uuid; drops orphan',
      () async {
        final seed = await harness.openAt('stage_planner_v5.db', 5);
        await harness.seedFromSql(
          seed,
          'test/migrations/fixtures/stage_planner/v5.sql',
        );
        await seed.close();

        final db = await harness.reopenAtCurrent(
          'stage_planner_v5.db',
          currentVersion: stagePlannerDatabaseVersion,
          onConfigure: stagePlannerOnConfigure,
          onUpgrade: stagePlannerOnUpgrade,
        );

        // v5 fixture: 3 plans, 6 non-orphan stages (3 + 2 + 1).
        await _assertCurrentSchemaInvariants(
          harness,
          db,
          expectedPlanCount: 3,
          expectedStageCount: 6,
        );

        // Plan 2 had stages 3 days apart, so stage (id=10) should
        // have days_to_stay = 3.
        final stage10 = await db.query(
          'stages',
          where: 'id = ?',
          whereArgs: [10],
          limit: 1,
        );
        expect(stage10, hasLength(1));
        expect(stage10.first['days_to_stay'], 3);

        // Plan 3 had no uuid — backfill must populate.
        final plan3 = await db.query(
          'stage_plans',
          where: 'id = ?',
          whereArgs: [3],
          limit: 1,
        );
        expect(plan3, hasLength(1));
        final plan3Uuid = plan3.first['uuid'] as String?;
        expect(plan3Uuid, isNotNull);
        expect(plan3Uuid!.trim(), isNotEmpty);

        // Plan 1 starting_date should be populated from the first
        // stage date.
        final plan1 = await db.query(
          'stage_plans',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        );
        expect(plan1.first['starting_date'], '2024-06-15');

        // Unique index on (stage_plan_id, stage_uuid) must hold:
        // no two stages in the same plan share a uuid.
        final dupCount = Sqflite.firstIntValue(
              await db.rawQuery('''
                SELECT COUNT(*) FROM (
                  SELECT stage_plan_id, stage_uuid, COUNT(*) AS c
                  FROM stages
                  GROUP BY stage_plan_id, stage_uuid
                  HAVING c > 1
                )
              '''),
            ) ??
            0;
        expect(dupCount, 0,
            reason: 'unique (stage_plan_id, stage_uuid) invariant broken');
      },
    );
  });

  group('stage_planner v8 -> current', () {
    test('v9 records pending backfill count to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final seed = await harness.openAt(
        'stage_planner_v8_prefs.db',
        8,
        onConfigure: stagePlannerOnConfigure,
      );
      await harness.seedFromSql(
        seed,
        'test/migrations/fixtures/stage_planner/v8.sql',
      );
      await seed.close();

      await harness.reopenAtCurrent(
        'stage_planner_v8_prefs.db',
        currentVersion: stagePlannerDatabaseVersion,
        onConfigure: stagePlannerOnConfigure,
        onUpgrade: stagePlannerOnUpgrade,
      );

      // v8 fixture has 2 rows with NULL/blank stage_uuid (ids 10, 20).
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getInt(pendingStageUuidV9BackfillCountKey);
      expect(
        pending,
        equals(2),
        reason: 'v9 must persist the backfill count for the higher '
            'layer to fire StageUuidBackfillEvent on next startup',
      );
    });

    test(
        'v9 does not write a prefs entry when nothing needs backfill',
        () async {
      SharedPreferences.setMockInitialValues({});

      // Seed a clean v8 DB where every stage already has a uuid.
      final seed = await harness.openAt(
        'stage_planner_v8_prefs_clean.db',
        8,
        onConfigure: stagePlannerOnConfigure,
      );
      await seed.transaction((txn) async {
        await txn.execute('''
          CREATE TABLE stage_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            route_id INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT,
            is_imported INTEGER NOT NULL DEFAULT 0,
            name TEXT,
            uuid TEXT,
            plan_uuid TEXT,
            deleted_at TEXT,
            starting_date TEXT
          )
        ''');
        await txn.execute('''
          CREATE TABLE stages (
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
        await txn.rawInsert(
          'INSERT INTO stage_plans '
          '(id, route_id, created_at, uuid, starting_date) '
          "VALUES (1, 10, '2024-06-10T08:00:00.000Z', "
          "'plan-uuid-1', '2024-06-15')",
        );
        await txn.rawInsert(
          'INSERT INTO stages '
          '(id, stage_plan_id, route_id, stage_uuid, '
          ' start_city_id, end_city_id, created_at, '
          ' stage_number, days_to_stay) '
          "VALUES (1, 1, 10, 'stage-uuid-1', 101, 102, "
          "'2024-06-10T08:00:00.000Z', 1, 1)",
        );
      });
      await seed.close();

      await harness.reopenAtCurrent(
        'stage_planner_v8_prefs_clean.db',
        currentVersion: stagePlannerDatabaseVersion,
        onConfigure: stagePlannerOnConfigure,
        onUpgrade: stagePlannerOnUpgrade,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getInt(pendingStageUuidV9BackfillCountKey),
        isNull,
        reason: 'no-op v9 must not leave a pending count behind',
      );
    });

    test('v9 backfills NULL/blank stage_uuid rows', () async {
      // FK enforcement is passed via onConfigure to match the
      // production open path. The v8 fixture is already FK-clean.
      final seed = await harness.openAt(
        'stage_planner_v8.db',
        8,
        onConfigure: stagePlannerOnConfigure,
      );
      await harness.seedFromSql(
        seed,
        'test/migrations/fixtures/stage_planner/v8.sql',
      );
      await seed.close();

      final db = await harness.reopenAtCurrent(
        'stage_planner_v8.db',
        currentVersion: stagePlannerDatabaseVersion,
        onConfigure: stagePlannerOnConfigure,
        onUpgrade: stagePlannerOnUpgrade,
      );

      // v8 fixture: 3 plans, 6 stages (3 + 2 + 1). Two of those
      // stages had a NULL/blank stage_uuid pre-migration. v9 must
      // backfill both without touching anything else.
      await _assertCurrentSchemaInvariants(
        harness,
        db,
        expectedPlanCount: 3,
        expectedStageCount: 6,
      );

      // Stages with valid uuids must not be rewritten.
      final stage1 = await db.query(
        'stages',
        columns: ['stage_uuid'],
        where: 'id = ?',
        whereArgs: [1],
        limit: 1,
      );
      expect(stage1.first['stage_uuid'], 'stage-uuid-0001',
          reason: 'v9 must not rewrite already-valid stage_uuid');

      // Stage 10 had NULL stage_uuid pre-migration — v9 must
      // backfill with a non-empty value.
      final stage10 = await db.query(
        'stages',
        columns: ['stage_uuid'],
        where: 'id = ?',
        whereArgs: [10],
        limit: 1,
      );
      final stage10Uuid = stage10.first['stage_uuid'] as String?;
      expect(stage10Uuid, isNotNull);
      expect(stage10Uuid!.trim(), isNotEmpty);

      // Stage 20 had blank/whitespace stage_uuid — v9 must
      // backfill with a non-empty trimmed value.
      final stage20 = await db.query(
        'stages',
        columns: ['stage_uuid'],
        where: 'id = ?',
        whereArgs: [20],
        limit: 1,
      );
      final stage20Uuid = stage20.first['stage_uuid'] as String?;
      expect(stage20Uuid, isNotNull);
      expect(stage20Uuid!.trim(), isNotEmpty);
    });

    test('v9 is idempotent when no backfill is needed', () async {
      // Seed a v8 DB where every stage already has a valid uuid.
      final seed = await harness.openAt(
        'stage_planner_v8_clean.db',
        8,
        onConfigure: stagePlannerOnConfigure,
      );
      await seed.transaction((txn) async {
        await txn.execute('''
          CREATE TABLE stage_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            route_id INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT,
            is_imported INTEGER NOT NULL DEFAULT 0,
            name TEXT,
            uuid TEXT,
            plan_uuid TEXT,
            deleted_at TEXT,
            starting_date TEXT
          )
        ''');
        await txn.execute('''
          CREATE TABLE stages (
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
        await txn.rawInsert(
          'INSERT INTO stage_plans '
          '(id, route_id, created_at, uuid, starting_date) '
          "VALUES (1, 10, '2024-06-10T08:00:00.000Z', "
          "'plan-uuid-1', '2024-06-15')",
        );
        await txn.rawInsert(
          'INSERT INTO stages '
          '(id, stage_plan_id, route_id, stage_uuid, '
          ' start_city_id, end_city_id, created_at, '
          ' stage_number, days_to_stay) '
          "VALUES (1, 1, 10, 'stage-uuid-1', 101, 102, "
          "'2024-06-10T08:00:00.000Z', 1, 1)",
        );
      });
      // Capture updated_at BEFORE the migration so we can assert
      // the no-backfill path doesn't bump it gratuitously.
      final beforeRows = await seed.query(
        'stages',
        columns: ['id', 'updated_at'],
      );
      await seed.close();

      final db = await harness.reopenAtCurrent(
        'stage_planner_v8_clean.db',
        currentVersion: stagePlannerDatabaseVersion,
        onConfigure: stagePlannerOnConfigure,
        onUpgrade: stagePlannerOnUpgrade,
      );

      // No row should be missing a stage_uuid.
      final missingUuid = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM stages '
              "WHERE stage_uuid IS NULL OR TRIM(stage_uuid) = ''",
            ),
          ) ??
          0;
      expect(missingUuid, 0);

      // Existing uuid preserved.
      final stage1 = await db.query(
        'stages',
        columns: ['stage_uuid', 'updated_at'],
        where: 'id = ?',
        whereArgs: [1],
        limit: 1,
      );
      expect(stage1.first['stage_uuid'], 'stage-uuid-1');
      // updated_at must be unchanged when v9 has nothing to do.
      expect(
        stage1.first['updated_at'],
        beforeRows.first['updated_at'],
        reason: 'idempotent v9 should not bump updated_at when '
            'all rows already have a stage_uuid',
      );
    });
  });

  group('stage_planner v9 -> current', () {
    test(
      'v10 adds trail_route_ids column without rewriting data',
      () async {
        // release/2.2.410 shipped v9 that only backfilled stage_uuid
        // (no trail_route_ids). Users coming from that path must
        // gain the column via v10 with all other data preserved.
        final seed = await harness.openAt(
          'stage_planner_v9_release.db',
          9,
          onConfigure: stagePlannerOnConfigure,
        );
        await harness.seedFromSql(
          seed,
          'test/migrations/fixtures/stage_planner/v9.sql',
        );
        await seed.close();

        final db = await harness.reopenAtCurrent(
          'stage_planner_v9_release.db',
          currentVersion: stagePlannerDatabaseVersion,
          onConfigure: stagePlannerOnConfigure,
          onUpgrade: stagePlannerOnUpgrade,
        );

        // v9 fixture: 3 plans, 6 stages (3 + 2 + 1).
        await _assertCurrentSchemaInvariants(
          harness,
          db,
          expectedPlanCount: 3,
          expectedStageCount: 6,
        );

        // trail_route_ids column must now exist on stage_plans.
        expect(
          await harness.columnExists(db, 'stage_plans', 'trail_route_ids'),
          isTrue,
          reason: 'v10 must add trail_route_ids to stage_plans',
        );

        // Existing rows must have a NULL trail_route_ids — v10 only
        // adds the column, it does not synthesize data.
        final nonNullTrails = Sqflite.firstIntValue(
              await db.rawQuery(
                'SELECT COUNT(*) FROM stage_plans '
                'WHERE trail_route_ids IS NOT NULL',
              ),
            ) ??
            0;
        expect(
          nonNullTrails,
          0,
          reason: 'v10 must leave trail_route_ids NULL for existing rows',
        );

        // Existing stage_uuid values must be preserved verbatim.
        final stage1 = await db.query(
          'stages',
          columns: ['stage_uuid'],
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        );
        expect(stage1.first['stage_uuid'], 'stage-uuid-0001');
      },
    );

    test(
      'v10 round-trips a trail_route_ids descriptor written post-migration',
      () async {
        final seed = await harness.openAt(
          'stage_planner_v9_roundtrip.db',
          9,
          onConfigure: stagePlannerOnConfigure,
        );
        await harness.seedFromSql(
          seed,
          'test/migrations/fixtures/stage_planner/v9.sql',
        );
        await seed.close();

        final db = await harness.reopenAtCurrent(
          'stage_planner_v9_roundtrip.db',
          currentVersion: stagePlannerDatabaseVersion,
          onConfigure: stagePlannerOnConfigure,
          onUpgrade: stagePlannerOnUpgrade,
        );

        // Descriptor format matches MultiRouteTrail.toStorageString():
        // a JSON list of `{"r": routeId[, "j": junctionCityId]}` objects.
        // Written manually here so the storage package doesn't take a
        // dependency on the repository package for tests.
        const trail = '[{"r":1},{"r":3,"j":250}]';

        await db.update(
          'stage_plans',
          {'trail_route_ids': trail},
          where: 'id = ?',
          whereArgs: [1],
        );

        final round = await db.query(
          'stage_plans',
          columns: ['trail_route_ids'],
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        );
        expect(round.first['trail_route_ids'], trail);
      },
    );
  });

  group('stage_planner v7 -> current', () {
    test('adds stage_uuid + unique index + backfills uuids', () async {
      // FK enforcement is passed via onConfigure to match v7's
      // production open path. The v7 fixture contains no orphans
      // (FK was already enforced in production at this point), so
      // seeding under FK ON is safe and mirrors how a real v7 DB
      // would have been written.
      final seed = await harness.openAt(
        'stage_planner_v7.db',
        7,
        onConfigure: stagePlannerOnConfigure,
      );
      await harness.seedFromSql(
        seed,
        'test/migrations/fixtures/stage_planner/v7.sql',
      );
      await seed.close();

      final db = await harness.reopenAtCurrent(
        'stage_planner_v7.db',
        currentVersion: stagePlannerDatabaseVersion,
        onConfigure: stagePlannerOnConfigure,
        onUpgrade: stagePlannerOnUpgrade,
      );

      // v7 fixture: 3 plans, 6 stages total, no orphans (FK was
      // already enforced at this point).
      await _assertCurrentSchemaInvariants(
        harness,
        db,
        expectedPlanCount: 3,
        expectedStageCount: 6,
      );

      // Plan 3 (empty-string uuid) must be backfilled with a
      // non-empty uuid.
      final plan3 = await db.query(
        'stage_plans',
        where: 'id = ?',
        whereArgs: [3],
        limit: 1,
      );
      final uuid = plan3.first['uuid'] as String?;
      expect(uuid, isNotNull);
      expect(uuid!.trim(), isNotEmpty);

      // plan_uuid must NOT be rewritten by v8. Plan 3's fixture
      // does not set plan_uuid (NULL); v8 only touches `uuid`,
      // so `plan_uuid` must be preserved as-is. Locks in current
      // behavior so future migrations don't silently start
      // rewriting plan_uuid.
      expect(
        plan3.first['plan_uuid'],
        isNull,
        reason: 'v8 must not touch plan_uuid — it only backfills uuid',
      );
    });
  });
}
