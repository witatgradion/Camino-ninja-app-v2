import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:storage/src/stage_planner_database.dart';
import 'package:storage/src/models/stage_entity.dart';

void main() {
  // Initialize FFI for desktop testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Close and delete database before each test for isolation
    await StagePlannerDatabase().closeDatabase();
    
    // Delete the database file to ensure clean state
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final file = File(path.join(dbPath, 'stage_planner_database.db'));
    if (await file.exists()) {
      await file.delete();
    }
  });

  tearDown(() async {
    // Close and reset the database after each test
    await StagePlannerDatabase().closeDatabase();
  });

  group('StagePlannerDatabase', () {
    group('Stage Plan CRUD Operations', () {
      test('createStagePlan creates a new stage plan with valid routeId', () async {
        final db = StagePlannerDatabase();
        
        final id = await db.createStagePlan(routeId: 1);
        
        expect(id, isPositive);
        
        final stagePlan = await db.getStagePlanById(id);
        expect(stagePlan, isNotNull);
        expect(stagePlan!.routeId, equals(1));
        expect(stagePlan.stages, isEmpty);
      });

      test('getStagePlansByRouteId returns all plans for a route', () async {
        final db = StagePlannerDatabase();
        
        // Create multiple stage plans for the same route
        await db.createStagePlan(routeId: 1);
        await db.createStagePlan(routeId: 1);
        await db.createStagePlan(routeId: 2);
        
        final plansForRoute1 = await db.getStagePlansByRouteId(1);
        final plansForRoute2 = await db.getStagePlansByRouteId(2);
        
        expect(plansForRoute1.length, equals(2));
        expect(plansForRoute2.length, equals(1));
      });

      test('getStagePlanById returns plan with stages', () async {
        final db = StagePlannerDatabase();
        
        final planId = await db.createStagePlan(routeId: 1);
        
        // Add stages to the plan
        await db.createStage(
          stagePlanId: planId,
          routeId: 1,
          date: DateTime(2024, 1, 1),
          startCityId: 1,
          endCityId: 2,
        );
        await db.createStage(
          stagePlanId: planId,
          routeId: 1,
          date: DateTime(2024, 1, 2),
          startCityId: 2,
          endCityId: 3,
        );
        
        final stagePlan = await db.getStagePlanById(planId);
        
        expect(stagePlan, isNotNull);
        expect(stagePlan!.stages.length, equals(2));
        // Stages should be ordered by stage number
        expect(stagePlan.stages[0].date, equals(DateTime(2024, 1, 1)));
        expect(stagePlan.stages[1].date, equals(DateTime(2024, 1, 2)));
      });

      test('updateStagePlan updates the updated_at timestamp', () async {
        final db = StagePlannerDatabase();
        
        final planId = await db.createStagePlan(routeId: 1);
        final originalPlan = await db.getStagePlanById(planId);
        
        // Wait a bit to ensure timestamp difference
        await Future.delayed(const Duration(milliseconds: 10));
        
        await db.updateStagePlan(stagePlanId: planId);
        final updatedPlan = await db.getStagePlanById(planId);
        
        expect(updatedPlan!.updatedAt, isNotNull);
        expect(originalPlan!.updatedAt, isNull);
      });

      test('deleteStagePlan soft-deletes the plan', () async {
        // deleteStagePlan is a soft-delete: it sets
        // deleted_at + updated_at but leaves the row in
        // place. getStagePlanById intentionally does NOT
        // filter by deleted_at IS NULL because sync needs
        // to push tombstones to the server.
        final db = StagePlannerDatabase();

        final planId = await db.createStagePlan(routeId: 1);

        await db.deleteStagePlan(planId);

        final stagePlan = await db.getStagePlanById(planId);
        expect(stagePlan, isNotNull);
        expect(stagePlan!.deletedAt, isNotNull);
        expect(stagePlan.updatedAt, isNotNull);
      });

      test('soft-delete preserves associated stages', () async {
        // Soft-delete does not cascade. Stages remain in
        // place until hardDeleteSyncedPlans runs after a
        // successful sync.
        final db = StagePlannerDatabase();

        final planId = await db.createStagePlan(routeId: 1);
        final stageId = await db.createStage(
          stagePlanId: planId,
          routeId: 1,
          date: DateTime(2024, 1, 1),
          startCityId: 1,
          endCityId: 2,
        );

        await db.deleteStagePlan(planId);

        final stageAfter = await db.getStageById(stageId);
        expect(stageAfter, isNotNull);
        expect(stageAfter!.id, equals(stageId));
      });

      test(
        'hardDeleteSyncedPlans removes soft-deleted plans '
        'and their stages while preserving live ones',
        () async {
          final db = StagePlannerDatabase();

          // Plan A: will be soft-deleted then hard-deleted.
          final deletedPlanId = await db.createStagePlan(routeId: 1);
          final deletedStageId = await db.createStage(
            stagePlanId: deletedPlanId,
            routeId: 1,
            date: DateTime(2024, 1, 1),
            startCityId: 1,
            endCityId: 2,
          );

          // Plan B: stays live, must survive hard delete.
          final livePlanId = await db.createStagePlan(routeId: 1);
          final liveStageId = await db.createStage(
            stagePlanId: livePlanId,
            routeId: 1,
            date: DateTime(2024, 1, 1),
            startCityId: 3,
            endCityId: 4,
          );

          await db.deleteStagePlan(deletedPlanId);
          await db.hardDeleteSyncedPlans();

          // Soft-deleted plan + its stage are gone.
          expect(await db.getStagePlanById(deletedPlanId), isNull);
          expect(await db.getStageById(deletedStageId), isNull);

          // Live plan + its stage survive.
          final livePlan = await db.getStagePlanById(livePlanId);
          expect(livePlan, isNotNull);
          expect(livePlan!.id, equals(livePlanId));
          final liveStage = await db.getStageById(liveStageId);
          expect(liveStage, isNotNull);
          expect(liveStage!.id, equals(liveStageId));
        },
      );
    });

    group('Stage CRUD Operations', () {
      late int stagePlanId;

      setUp(() async {
        final db = StagePlannerDatabase();
        stagePlanId = await db.createStagePlan(routeId: 1);
      });

      test('createStage creates a stage with all required fields', () async {
        final db = StagePlannerDatabase();
        
        final stageId = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
        );
        
        expect(stageId, isPositive);
        
        final stage = await db.getStageById(stageId);
        expect(stage, isNotNull);
        expect(stage!.stagePlanId, equals(stagePlanId));
        expect(stage.routeId, equals(1));
        expect(stage.stageUuid, isNotNull);
        expect(stage.stageUuid!.isNotEmpty, isTrue);
        expect(stage.date!.year, equals(2024));
        expect(stage.date!.month, equals(6));
        expect(stage.date!.day, equals(15));
        expect(stage.startCityId, equals(10));
        expect(stage.endCityId, equals(20));
      });

      test('createStage creates a stage with optional fields', () async {
        final db = StagePlannerDatabase();
        
        final stageId = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
          startAlbergueId: 100,
          endAlbergueId: 200,
          customStartNotes: 'Start notes',
          customEndNotes: 'End notes',
          stageNotes: 'Stage notes',
        );
        
        final stage = await db.getStageById(stageId);
        
        expect(stage!.startAlbergueId, equals(100));
        expect(stage.endAlbergueId, equals(200));
        expect(stage.customStartNotes, equals('Start notes'));
        expect(stage.customEndNotes, equals('End notes'));
        expect(stage.stageNotes, equals('Stage notes'));
      });

      test('getStagesByStagePlanId returns stages ordered by stage number', () async {
        final db = StagePlannerDatabase();

        // Insert stages with explicit stage_number values
        // assigned out-of-order to actually exercise the
        // ORDER BY stage_number ASC clause. Without this,
        // createStage would auto-assign stage_number in
        // insertion order, which would conflate insertion
        // order with stage_number ordering.
        await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          stageNumber: 2,
          date: DateTime(2024, 6, 16),
          startCityId: 2,
          endCityId: 3,
        );
        await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          stageNumber: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 1,
          endCityId: 2,
        );
        await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          stageNumber: 3,
          date: DateTime(2024, 6, 17),
          startCityId: 3,
          endCityId: 4,
        );

        final stages = await db.getStagesByStagePlanId(stagePlanId);

        expect(stages.length, equals(3));
        expect(stages[0].stageNumber, equals(1));
        expect(stages[0].date!.day, equals(15));
        expect(stages[1].stageNumber, equals(2));
        expect(stages[1].date!.day, equals(16));
        expect(stages[2].stageNumber, equals(3));
        expect(stages[2].date!.day, equals(17));
      });

      test('updateStagePartial updates only provided fields', () async {
        final db = StagePlannerDatabase();
        
        final stageId = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
          stageNotes: 'Original notes',
        );
        
        await db.updateStagePartial(
          stageId: stageId,
          stageNotes: 'Updated notes',
        );
        
        final stage = await db.getStageById(stageId);
        
        // Only stageNotes should be updated
        expect(stage!.stageNotes, equals('Updated notes'));
        expect(stage.startCityId, equals(10)); // Unchanged
        expect(stage.endCityId, equals(20)); // Unchanged
        expect(stage.updatedAt, isNotNull);
      });

      test(
        'updateStagePartial with clearStageNotes writes NULL and '
        'stamps updated_at',
        () async {
        final db = StagePlannerDatabase();

        final stageId = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
          stageNotes: 'Original notes',
        );

        final before = await db.getStageById(stageId);
        expect(before!.stageNotes, equals('Original notes'));

        // Ensure updated_at changes even though createdAt was just now.
        await Future<void>.delayed(const Duration(milliseconds: 10));

        await db.updateStagePartial(
          stageId: stageId,
          clearStageNotes: true,
        );

        final after = await db.getStageById(stageId);

        // stage_notes should now be NULL regardless of any stageNotes arg.
        expect(after!.stageNotes, isNull);
        // Other fields should remain untouched.
        expect(after.startCityId, equals(10));
        expect(after.endCityId, equals(20));
        // updated_at must be stamped so the next sync picks up the clear.
        expect(after.updatedAt, isNotNull);
      });

      test(
        'updateStagePartial with stageNotes:null (no flag) does NOT '
        'clear the note',
        () async {
        final db = StagePlannerDatabase();

        final stageId = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
          stageNotes: 'Preserved',
        );

        // Without clearStageNotes, passing null means "don't update"
        // (preserves existing sync semantics).
        await db.updateStagePartial(
          stageId: stageId,
          startAlbergueId: 100,
        );

        final after = await db.getStageById(stageId);
        expect(after!.stageNotes, equals('Preserved'));
        expect(after.startAlbergueId, equals(100));
      });

      test('updateStagePartial can update multiple fields', () async {
        final db = StagePlannerDatabase();
        
        final stageId = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
        );
        
        await db.updateStagePartial(
          stageId: stageId,
          date: DateTime(2024, 7, 1),
          startCityId: 30,
          endCityId: 40,
          startAlbergueId: 100,
        );
        
        final stage = await db.getStageById(stageId);
        
        expect(stage!.date!.month, equals(7));
        expect(stage.date!.day, equals(1));
        expect(stage.startCityId, equals(30));
        expect(stage.endCityId, equals(40));
        expect(stage.startAlbergueId, equals(100));
      });

      test('updateStage updates the entire stage', () async {
        final db = StagePlannerDatabase();
        
        final stageId = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
        );
        
        final originalStage = await db.getStageById(stageId);
        
        final updatedStage = StageEntity(
          id: stageId,
          stagePlanId: stagePlanId,
          routeId: 1,
          stageUuid: originalStage!.stageUuid,
          date: DateTime(2024, 7, 20),
          startCityId: 50,
          endCityId: 60,
          startAlbergueId: 500,
          endAlbergueId: 600,
          customStartNotes: 'New start notes',
          customEndNotes: 'New end notes',
          stageNotes: 'New stage notes',
          createdAt: originalStage.createdAt,
        );
        
        await db.updateStage(updatedStage);
        
        final stage = await db.getStageById(stageId);
        
        expect(stage!.date!.month, equals(7));
        expect(stage.startCityId, equals(50));
        expect(stage.endCityId, equals(60));
        expect(stage.startAlbergueId, equals(500));
        expect(stage.endAlbergueId, equals(600));
        expect(stage.customStartNotes, equals('New start notes'));
        expect(stage.customEndNotes, equals('New end notes'));
        expect(stage.stageNotes, equals('New stage notes'));
      });

      test('deleteStage removes the stage', () async {
        final db = StagePlannerDatabase();
        
        final stageId = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
        );
        
        await db.deleteStage(stageId);
        
        final stage = await db.getStageById(stageId);
        expect(stage, isNull);
      });

      test('deleteStage does not affect other stages', () async {
        final db = StagePlannerDatabase();

        final stageId1 = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
        );
        final stageId2 = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 16),
          startCityId: 20,
          endCityId: 30,
        );

        await db.deleteStage(stageId1);

        final stage2 = await db.getStageById(stageId2);
        expect(stage2, isNotNull);
      });

      test(
          'deleteStage renumbers surviving stages to '
          'contiguous 1..N (middle delete)', () async {
        final db = StagePlannerDatabase();

        // Create 5 stages with stage_numbers 1..5.
        final ids = <int>[];
        for (var i = 1; i <= 5; i++) {
          final id = await db.createStage(
            stagePlanId: stagePlanId,
            routeId: 1,
            stageNumber: i,
            date: DateTime(2024, 6, 14 + i),
            startCityId: i * 10,
            endCityId: i * 10 + 5,
          );
          ids.add(id);
        }

        // Delete the stage with stage_number = 3.
        await db.deleteStage(ids[2]);

        final survivors = await db.getStagesByStagePlanId(stagePlanId);
        expect(
          survivors.map((s) => s.stageNumber).toList(),
          equals(<int>[1, 2, 3, 4]),
        );
        // Identity check: former #4/#5 are now #3/#4.
        expect(survivors[2].id, equals(ids[3]));
        expect(survivors[3].id, equals(ids[4]));
      });

      test('deleteStage compacts when first stage is deleted',
          () async {
        final db = StagePlannerDatabase();

        final ids = <int>[];
        for (var i = 1; i <= 3; i++) {
          final id = await db.createStage(
            stagePlanId: stagePlanId,
            routeId: 1,
            stageNumber: i,
            date: DateTime(2024, 6, 14 + i),
            startCityId: i * 10,
            endCityId: i * 10 + 5,
          );
          ids.add(id);
        }

        // Delete the stage with stage_number = 1.
        await db.deleteStage(ids[0]);

        final survivors = await db.getStagesByStagePlanId(stagePlanId);
        expect(
          survivors.map((s) => s.stageNumber).toList(),
          equals(<int>[1, 2]),
        );
        // Former #2/#3 are now #1/#2.
        expect(survivors[0].id, equals(ids[1]));
        expect(survivors[1].id, equals(ids[2]));
      });

      test(
          'deleteStage on last stage leaves remaining numbers '
          'untouched', () async {
        final db = StagePlannerDatabase();

        final plan = await db.getStagePlanById(stagePlanId);
        final originalUpdatedAt = plan!.updatedAt;

        final ids = <int>[];
        for (var i = 1; i <= 3; i++) {
          final id = await db.createStage(
            stagePlanId: stagePlanId,
            routeId: 1,
            stageNumber: i,
            date: DateTime(2024, 6, 14 + i),
            startCityId: i * 10,
            endCityId: i * 10 + 5,
          );
          ids.add(id);
        }

        // Ensure timestamp will move forward.
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Delete the last stage (stage_number = 3).
        await db.deleteStage(ids[2]);

        final survivors = await db.getStagesByStagePlanId(stagePlanId);
        expect(
          survivors.map((s) => s.stageNumber).toList(),
          equals(<int>[1, 2]),
        );

        // stage_plans.updated_at should still bump even when no
        // per-row UPDATEs were necessary.
        final updatedPlan = await db.getStagePlanById(stagePlanId);
        expect(updatedPlan!.updatedAt, isNot(equals(originalUpdatedAt)));
      });

      test(
          'deleteStage on a plan with pre-existing gaps compacts '
          'to 1..N', () async {
        final db = StagePlannerDatabase();

        // Seed three stages with auto stage_number 1, 2, 3.
        final id1 = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
        );
        final id2 = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 16),
          startCityId: 20,
          endCityId: 30,
        );
        final id3 = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 17),
          startCityId: 30,
          endCityId: 40,
        );

        // Force non-contiguous stage_numbers {1, 5, 10} via the
        // public storage extension method.
        await db.updateStageNumbers(
          stagePlanId: stagePlanId,
          stageIdToNumber: {id1: 1, id2: 5, id3: 10},
        );

        // Sanity-check the gappy precondition.
        final gapped = await db.getStagesByStagePlanId(stagePlanId);
        expect(
          gapped.map((s) => s.stageNumber).toList(),
          equals(<int>[1, 5, 10]),
        );

        // Delete the middle stage (the one with stage_number = 5).
        await db.deleteStage(id2);

        // Survivors should be re-numbered to a contiguous 1..N
        // even though the input wasn't contiguous to begin with.
        final survivors = await db.getStagesByStagePlanId(stagePlanId);
        expect(
          survivors.map((s) => s.stageNumber).toList(),
          equals(<int>[1, 2]),
        );
        expect(survivors[0].id, equals(id1));
        expect(survivors[1].id, equals(id3));
      });

      test('deleteStage on the only stage in a plan succeeds',
          () async {
        final db = StagePlannerDatabase();

        final stageId = await db.createStage(
          stagePlanId: stagePlanId,
          routeId: 1,
          date: DateTime(2024, 6, 15),
          startCityId: 10,
          endCityId: 20,
        );

        // Should not throw, even with N=0 survivors to renumber.
        await db.deleteStage(stageId);

        final survivors = await db.getStagesByStagePlanId(stagePlanId);
        expect(survivors, isEmpty);

        // Plan itself should still exist.
        final plan = await db.getStagePlanById(stagePlanId);
        expect(plan, isNotNull);
        expect(plan!.stages, isEmpty);
      });

    });

    group('Database Lifecycle', () {
      test('closeDatabase closes and resets the database', () async {
        final db = StagePlannerDatabase();
        
        // Access database to initialize it
        await db.createStagePlan(routeId: 1);
        
        // Close the database
        await db.closeDatabase();
        
        // Database should be re-initialized on next access
        final newPlanId = await db.createStagePlan(routeId: 2);
        expect(newPlanId, isPositive);
      });

      test('factory returns singleton instance', () {
        final db1 = StagePlannerDatabase();
        final db2 = StagePlannerDatabase();
        
        expect(identical(db1, db2), isTrue);
      });
    });
  });
}

