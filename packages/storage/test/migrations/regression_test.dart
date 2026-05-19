import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:storage/src/models/stage_entity.dart';
import 'package:storage/src/stage_planner_database.dart';

import 'migration_test_harness.dart';

void main() {
  // The stage-update regression test exercises the real
  // StagePlannerDatabase singleton, which opens its DB at
  // `getDatabasesPath()/stage_planner_database.db`. Installing the
  // FFI factory globally points `getDatabasesPath()` at a
  // test-friendly temp dir. Safe for the whole file since the
  // harness also uses FFI under the hood.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late MigrationTestHarness harness;

  setUp(() {
    harness = MigrationTestHarness();
  });

  tearDown(() async {
    await harness.disposeAll();
  });

  group('DB migration regressions', () {
    test(
      'v5 -> current succeeds with pre-v2.2.364 orphaned stages '
      '(PR #364 regression)',
      () async {
        final seed = await harness.openAt('regression_orphan_v5.db', 5);
        await harness.seedFromSql(
          seed,
          'test/migrations/fixtures/stage_planner/v5.sql',
        );
        await seed.close();

        // The v7 migration previously crashed here because the
        // INSERT INTO stages_new SELECT ... violated the new FK
        // when orphan rows were present. Fix: DELETE orphans
        // before INSERT. This test guards that fix.
        final db = await harness.reopenAtCurrent(
          'regression_orphan_v5.db',
          currentVersion: stagePlannerDatabaseVersion,
          onConfigure: stagePlannerOnConfigure,
          onUpgrade: stagePlannerOnUpgrade,
        );

        await harness.expectFkValid(db);

        // The orphan (id=99, stage_plan_id=9999) must be gone.
        final orphanRows = await db.query(
          'stages',
          where: 'id = ?',
          whereArgs: [99],
        );
        expect(orphanRows, isEmpty,
            reason: 'orphan stage must not be smuggled through');

        // Real plans + stages must survive.
        expect(await harness.rowCount(db, 'stage_plans'), 3);
        // 3 + 2 + 1 = 6 non-orphan stages seeded in v5 fixture.
        expect(await harness.rowCount(db, 'stages'), 6);
      },
    );

    group('stage_number is preserved across updateStage(StageEntity)', () {
      // Exercises the real production extension method
      // StagePlannerDatabase.updateStage(StageEntity). The bug
      // would be: calling updateStage with a StageEntity read from
      // the DB and mutated for a field other than stage_number
      // silently drops stage_number (or shifts it) on other rows.
      //
      // We use the real singleton, so we must close + delete the
      // backing file in setUp/tearDown to keep tests isolated.
      late StagePlannerDatabase db;

      setUp(() async {
        await StagePlannerDatabase().closeDatabase();
        final dbDir = await databaseFactoryFfi.getDatabasesPath();
        final file = File(p.join(dbDir, 'stage_planner_database.db'));
        if (await file.exists()) await file.delete();
        db = StagePlannerDatabase();
      });

      tearDown(() async {
        await StagePlannerDatabase().closeDatabase();
      });

      test(
        'updating the middle stage leaves all stage_numbers intact '
        '(stage-update-bug regression)',
        () async {
          // Seed a plan with 3 stages via the real public API.
          final planId = await db.createStagePlan(routeId: 1);
          for (var i = 1; i <= 3; i++) {
            await db.createStage(
              stagePlanId: planId,
              routeId: 1,
              startCityId: i,
              endCityId: i + 1,
            );
          }

          final before = await db.getStagesByStagePlanId(planId);
          expect(before, hasLength(3));
          expect(
            before.map((s) => s.stageNumber).toList(),
            equals([1, 2, 3]),
            reason: 'createStage should auto-assign 1..N',
          );

          // Update the middle stage through the real production
          // path. Construct a new StageEntity from the persisted
          // one, mutating only startCityId — stage_number is
          // carried across verbatim. If updateStage ever drops
          // stage_number, the assertion below will fail.
          final middle = before[1];
          final updated = StageEntity(
            id: middle.id,
            stagePlanId: middle.stagePlanId,
            routeId: middle.routeId,
            stageUuid: middle.stageUuid,
            startCityId: 999,
            endCityId: middle.endCityId,
            date: middle.date,
            startAlbergueId: middle.startAlbergueId,
            endAlbergueId: middle.endAlbergueId,
            customStartNotes: middle.customStartNotes,
            customEndNotes: middle.customEndNotes,
            stageNotes: middle.stageNotes,
            createdAt: middle.createdAt,
            updatedAt: middle.updatedAt,
            stageNumber: middle.stageNumber,
            daysToStay: middle.daysToStay,
          );
          await db.updateStage(updated);

          final after = await db.getStagesByStagePlanId(planId);
          expect(after, hasLength(3));
          expect(
            after.map((s) => s.stageNumber).toList(),
            equals([1, 2, 3]),
            reason: 'stage_numbers must survive an unrelated '
                'updateStage on the middle stage',
          );
          // Confirm the update actually happened.
          final middleAfter =
              after.firstWhere((s) => s.id == middle.id);
          expect(middleAfter.startCityId, 999);
        },
      );
    });
  });
}
