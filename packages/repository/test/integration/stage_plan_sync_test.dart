// Integration tests for [StagePlanRepository.syncPlans] using real
// in-memory SQLite (via sqflite_common_ffi) and a hand-rolled fake
// at the network boundary. No mocks on the DB side; no mocktail at
// the network boundary.
//
// The five scenarios mirror the real failure modes that have hit
// production over the last two quarters:
//   1. Push then pull (cross-device merge).
//   2. Local + remote edit conflict on the same stage.
//   3. Soft-delete propagation.
//   4. Partial sync failure mid-stage, then recovery.
//   5. Legacy data normalization.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:repository/src/stage_plan_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:storage/src/app_database.dart';
import 'package:storage/src/models/credential_entity.dart';
import 'package:storage/src/stage_planner_database.dart';

import 'fakes/fake_app_preferences.dart';
import 'fakes/fake_network_service.dart';

const _kRouteId = 1;
const _kRouteId2 = 2;

const _loggedInCredential = CredentialEntity(
  accessToken: 'fake-access-token',
  refreshToken: 'fake-refresh-token',
);

Future<void> _resetStagePlannerDatabase() async {
  await StagePlannerDatabase().closeDatabase();
  final dir = await databaseFactoryFfi.getDatabasesPath();
  final file = File(path.join(dir, 'stage_planner_database.db'));
  // ignore: avoid_slow_async_io
  if (await file.exists()) {
    await file.delete();
  }
}

Future<int> _seedLocalPlanWithStages({
  required StagePlannerDatabase db,
  required int routeId,
  int stageCount = 3,
  int? startCityIdBase,
}) async {
  final planId = await db.createStagePlan(
    routeId: routeId,
    name: 'Test Plan',
  );
  final base = startCityIdBase ?? 100;
  for (var i = 0; i < stageCount; i++) {
    await db.createStage(
      stagePlanId: planId,
      routeId: routeId,
      startCityId: base + i,
      endCityId: base + i + 1,
      stageNotes: 'stage ${i + 1} notes',
    );
  }
  return planId;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(_resetStagePlannerDatabase);
  tearDown(_resetStagePlannerDatabase);

  group('StagePlanRepository.syncPlans (integration)', () {
    late StagePlannerDatabase stageDb;
    late AppDatabase appDb;
    late FakeNetworkService fakeNetwork;
    late FakeAppPreferences fakePrefs;
    late StagePlanRepository repo;

    setUp(() {
      // `_legacyDatesNormalized` is a static guard on
      // [StagePlanRepository]. Under random ordering it can leak
      // between tests — reset it so first-run normalization always
      // re-runs for the test that exercises it.
      StagePlanRepository.resetLegacyDatesNormalized();

      stageDb = StagePlannerDatabase();
      appDb = AppDatabase();
      fakeNetwork = FakeNetworkService();
      fakePrefs = FakeAppPreferences(credential: _loggedInCredential);
      repo = StagePlanRepository(appDb, stageDb, fakeNetwork, fakePrefs);
    });

    tearDown(() {
      repo.dispose();
    });

    test('1. push then pull merges cleanly across two sync rounds', () async {
      // Round 1: push local plan with 3 stages.
      final planId = await _seedLocalPlanWithStages(
        db: stageDb,
        routeId: _kRouteId,
      );
      final localPlan = await stageDb.getStagePlanById(planId);
      final planUuid = localPlan!.uuid!;

      final result1 = await repo.syncPlans();
      expect(result1, isA<SyncPlansSuccess>());
      expect(fakeNetwork.recordedRequests, hasLength(1));
      final firstReq = fakeNetwork.recordedRequests.first;
      expect(firstReq.plans, hasLength(1));
      expect(firstReq.plans.first.uuid, equals(planUuid));
      expect(firstReq.plans.first.stages, hasLength(3));

      // Remote should have what we pushed.
      expect(fakeNetwork.remotePlans[planUuid], isNotNull);
      expect(fakeNetwork.remotePlans[planUuid]!.stages, hasLength(3));

      // Round 2: simulate a "second device" — mutate remote state
      // by adding a 4th stage. (Editing existing stage notes from
      // the remote side is a different scenario, covered in test 2;
      // the fake's last-write-wins rule means the local push would
      // overwrite a remote-only edit on the same stage during the
      // request half of the round-trip.)
      final remote = fakeNetwork.remotePlans[planUuid]!;
      remote.stages.add(
        FakeRemoteStage(
          stageNumber: 4,
          startCityId: 200,
          endCityId: 201,
          routeId: _kRouteId,
          stageUuid: 'remote-only-stage-uuid',
          stageNotes: 'remote-only stage',
          updatedAt: DateTime.now().toUtc().toIso8601String(),
          daysToStay: 1,
        ),
      );

      final result2 = await repo.syncPlans();
      expect(result2, isA<SyncPlansSuccess>());

      final stagesAfterPull = await stageDb.getStagesByStagePlanId(planId);
      expect(stagesAfterPull, hasLength(4));
      // Newly pulled remote-only stage exists locally.
      final pulled = stagesAfterPull
          .firstWhere((s) => s.stageUuid == 'remote-only-stage-uuid');
      expect(pulled.stageNumber, equals(4));
      expect(pulled.stageNotes, equals('remote-only stage'));
    });

    test(
        '2. conflict resolution: device-that-pushed wins, AND the '
        'round trip actually mutates local from the response (not '
        'just no-ops on pre-sync local state)', () async {
      // Push initial state.
      final planId = await _seedLocalPlanWithStages(
        db: stageDb,
        routeId: _kRouteId,
        stageCount: 1,
      );
      final localPlan = await stageDb.getStagePlanById(planId);
      final planUuid = localPlan!.uuid!;
      await repo.syncPlans();

      // Locally edit stage 1.
      final stages = await stageDb.getStagesByStagePlanId(planId);
      final stageId = stages.first.id;
      final localStageUuid = stages.first.stageUuid;
      expect(
        localStageUuid,
        isNotNull,
        reason: 'pre-sync local stage must already have a uuid; '
            'otherwise the request -> response match-by-uuid path '
            'we are exercising would not fire',
      );
      await repo.updateStagePartial(
        stageId: stageId,
        stageNotes: 'local-edit-wins',
      );

      // Remotely edit the same stage to a different value, plus a
      // distinct `updatedAt`, so we can tell pre-sync remote state
      // apart from the response sentinel post-merge.
      fakeNetwork.remotePlans[planUuid]!.stages.first
        ..stageNotes = 'remote-edit-loses'
        ..updatedAt = '2020-01-01T00:00:00.000Z';

      // Configure the fake to bump `updated_at` server-side on the
      // merged stage with a recognizable ISO timestamp far in the
      // future. This value exists nowhere in the local DB pre-sync;
      // if it ends up on local rows after sync, the only way it
      // could have arrived is via `_applySyncResponse`. Far-future
      // means it cannot collide with any wall-clock value the test
      // produced earlier (which was DateTime.now()-ish).
      const serverSentinelIso = '2099-12-31T23:59:59.000Z';
      final serverSentinel = DateTime.parse(serverSentinelIso);
      fakeNetwork.serverUpdatedAtSentinel = serverSentinelIso;

      // Sync. Push happens first (request carries local edit); the
      // fake merges request-into-remote with last-write-wins keyed
      // on stage_uuid, so the device-that-pushed clobbers the
      // remote edit on the same UUID. The response then echoes the
      // post-merge remote state — local re-applies it.
      final result = await repo.syncPlans();
      expect(result, isA<SyncPlansSuccess>());

      // (a) Request: the local edit was actually pushed.
      expect(
        fakeNetwork.recordedRequests, isNotEmpty,
        reason: 'request must have been built and sent',
      );
      final lastReq = fakeNetwork.recordedRequests.last;
      final pushedPlan =
          lastReq.plans.firstWhere((p) => p.uuid == planUuid);
      expect(pushedPlan.stages, hasLength(1));
      expect(
        pushedPlan.stages.first.stageNotes,
        equals('local-edit-wins'),
        reason: 'the request must carry the local edit verbatim',
      );

      // (b) Server-side merge: device-that-pushed wins. The pre-sync
      // remote edit ('remote-edit-loses') is gone from remote state
      // entirely; the merged stage has the local-edit value.
      final remoteAfter =
          fakeNetwork.remotePlans[planUuid]!.stages.first;
      expect(
        remoteAfter.stageNotes,
        equals('local-edit-wins'),
        reason: 'fake merge rule (last-write-wins on stage_uuid) '
            'matches observed prod server behavior',
      );

      // (c) Local state: stageNotes still 'local-edit-wins', BUT we
      // also assert a field that ONLY the response could have set —
      // the server sentinel `updated_at`. If `_applySyncResponse`
      // were a no-op, local would still have whatever timestamp the
      // pre-sync local edit produced, never this sentinel.
      final stagesAfter = await stageDb.getStagesByStagePlanId(planId);
      expect(stagesAfter, hasLength(1));
      expect(stagesAfter.first.stageNotes, equals('local-edit-wins'));
      expect(stagesAfter.first.updatedAt, isNotNull,
          reason: 'sync should always write a non-null updated_at locally');
      expect(
        stagesAfter.first.updatedAt!.toUtc(),
        equals(serverSentinel),
        reason: 'local row must carry the server-bumped updated_at; '
            'this is the load-bearing assertion that the response '
            'was actually applied on the local side',
      );
    });

    test('3. soft-delete propagates to the sync request and remote state',
        () async {
      final planId = await _seedLocalPlanWithStages(
        db: stageDb,
        routeId: _kRouteId,
      );
      final localPlan = await stageDb.getStagePlanById(planId);
      final planUuid = localPlan!.uuid!;
      // First sync to get the plan onto the remote.
      await repo.syncPlans();
      fakeNetwork.recordedRequests.clear();

      // Soft-delete locally.
      await repo.deleteStagePlan(planId);

      final result = await repo.syncPlans();
      expect(result, isA<SyncPlansSuccess>());

      // The request must include the deleted_at marker.
      final req = fakeNetwork.recordedRequests.last;
      final pushed = req.plans.firstWhere((p) => p.uuid == planUuid);
      expect(pushed.deletedAt, isNotNull);

      // Remote state reflects the deletion.
      expect(
        fakeNetwork.remotePlans[planUuid]!.deletedAt,
        isNotNull,
      );

      // Local hard-delete after successful sync — plan is gone.
      final remaining = await stageDb.getAllStagePlansIncludingDeleted();
      expect(
        remaining.where((p) => p.uuid == planUuid),
        isEmpty,
      );
    });

    test('4. partial sync failure mid-stage; retry recovers consistency',
        () async {
      // Seed two plans, 3 stages each = 6 total stages.
      final planA = await _seedLocalPlanWithStages(
        db: stageDb,
        routeId: _kRouteId,
        startCityIdBase: 100,
      );
      await _seedLocalPlanWithStages(
        db: stageDb,
        routeId: _kRouteId2,
        startCityIdBase: 200,
      );

      // Configure the fake to merge the first 4 stages, then fail.
      // Plans are pushed in created_at DESC order, so plan B's 3
      // stages process first and only 1 of plan A's stages reaches
      // the (failed) server before the connection drops.
      fakeNetwork.partialFailure(failAtStageIndex: 4);
      final fail = await repo.syncPlans();
      expect(fail, isA<SyncPlansApiError>());
      final planAUuid = (await stageDb.getStagePlanById(planA))!.uuid!;
      expect(
        fakeNetwork.remotePlans[planAUuid]!.stages,
        hasLength(1),
      );

      // Locally everything is still there — no rollback needed; the
      // sync only writes back on success. Plans/stages are intact.
      final allLocal = await stageDb.getAllStagePlansIncludingDeleted();
      expect(allLocal, hasLength(2));
      for (final p in allLocal) {
        expect(p.stages, hasLength(3));
      }

      // Retry with success mode — local state should converge with
      // remote state, no duplicates, no lost rows.
      fakeNetwork.succeed();
      final ok = await repo.syncPlans();
      expect(ok, isA<SyncPlansSuccess>());

      final localPlans = await stageDb.getAllStagePlansIncludingDeleted();
      expect(localPlans, hasLength(2));
      for (final p in localPlans) {
        expect(p.stages, hasLength(3));
        // No duplicate stage numbers.
        final numbers = p.stages.map((s) => s.stageNumber).toList();
        expect(numbers.toSet(), hasLength(numbers.length));
      }
      // Remote should mirror.
      for (final entry in fakeNetwork.remotePlans.entries) {
        expect(entry.value.stages, hasLength(3));
      }
    });

    test('5. legacy data normalization populates starting_date and clears '
        'per-stage dates before sync', () async {
      // Seed a plan in legacy shape: per-stage dates populated, plan
      // starting_date null. We bypass the repo's helper and write
      // directly via raw DB access to mimic v5/v6 data shape.
      final db = await stageDb.database;
      final now = DateTime.now().toUtc().toIso8601String();
      final planId = await db.insert('stage_plans', {
        'route_id': _kRouteId,
        'created_at': now,
        'is_imported': 0,
        'name': 'Legacy plan',
        'uuid': 'legacy-plan-uuid',
        // starting_date intentionally null
      });
      await db.insert('stages', {
        'stage_plan_id': planId,
        'route_id': _kRouteId,
        'date': '2024-06-01',
        'start_city_id': 1,
        'end_city_id': 2,
        'stage_number': 1,
        'days_to_stay': 1,
        'created_at': now,
        'stage_uuid': 'legacy-stage-1',
      });
      await db.insert('stages', {
        'stage_plan_id': planId,
        'route_id': _kRouteId,
        'date': '2024-06-04',
        'start_city_id': 2,
        'end_city_id': 3,
        'stage_number': 2,
        'days_to_stay': 1,
        'created_at': now,
        'stage_uuid': 'legacy-stage-2',
      });
      await db.insert('stages', {
        'stage_plan_id': planId,
        'route_id': _kRouteId,
        'date': '2024-06-05',
        'start_city_id': 3,
        'end_city_id': 4,
        'stage_number': 3,
        'days_to_stay': 1,
        'created_at': now,
        'stage_uuid': 'legacy-stage-3',
      });

      // Run normalization (the same call `getAllStagePlans` makes in
      // production, lazily, on the first read).
      await stageDb.normalizeLegacyDates();

      // Verify normalization happened locally before sync.
      final plan = await stageDb.getStagePlanById(planId);
      expect(plan!.startingDate, equals('2024-06-01'));
      for (final stage in plan.stages) {
        expect(stage.date, isNull);
      }
      // days_to_stay computed: stage1 -> 3 (Jun 1 -> Jun 4), stage2 ->
      // 1 (Jun 4 -> Jun 5), stage3 keeps default 1.
      final byNumber = {for (final s in plan.stages) s.stageNumber: s};
      expect(byNumber[1]!.daysToStay, equals(3));
      expect(byNumber[2]!.daysToStay, equals(1));
      expect(byNumber[3]!.daysToStay, equals(1));

      // Sync — request must contain the normalized shape.
      final result = await repo.syncPlans();
      expect(result, isA<SyncPlansSuccess>());

      final req = fakeNetwork.recordedRequests.last;
      final pushed = req.plans.firstWhere(
        (p) => p.uuid == 'legacy-plan-uuid',
      );
      expect(pushed.startingDate, equals('2024-06-01'));
      // Per-stage dates cleared.
      for (final s in pushed.stages) {
        expect(s.date, isNull);
      }
      // days_to_stay carried through.
      final pushedByNumber = {
        for (final s in pushed.stages) s.stageNumber: s,
      };
      expect(pushedByNumber[1]!.daysToStay, equals(3));
      expect(pushedByNumber[2]!.daysToStay, equals(1));
    });
    test(
        '6. gappy stage_numbers are compacted to 1..N and the result '
        'reports the count for analytics', () async {
      // Seed a plan with deliberately gappy stage_numbers: {1, 2, 4}.
      // Bypass `createStage`'s auto-assignment by writing directly to
      // the DB so we can pin the gap exactly.
      final db = await stageDb.database;
      final now = DateTime.now().toUtc().toIso8601String();
      final planId = await db.insert('stage_plans', {
        'route_id': _kRouteId,
        'created_at': now,
        'is_imported': 0,
        'name': 'Gappy plan',
        'uuid': 'gappy-plan-uuid',
      });
      for (final n in [1, 2, 4]) {
        await db.insert('stages', {
          'stage_plan_id': planId,
          'route_id': _kRouteId,
          'start_city_id': 100 + n,
          'end_city_id': 101 + n,
          'stage_number': n,
          'days_to_stay': 1,
          'created_at': now,
          'stage_uuid': 'gappy-stage-$n',
        });
      }

      final result = await repo.syncPlans();
      expect(result, isA<SyncPlansSuccess>());
      final success = result as SyncPlansSuccess;

      // The third stage (stage_number=4) should have been compacted
      // to 3. {1, 2} were already correct, so only one rewrite.
      expect(
        success.stagesCompacted,
        equals(1),
        reason: 'only the gappy stage (#4 -> #3) gets rewritten',
      );
      expect(
        success.plansAffected,
        equals(1),
        reason: 'exactly one plan had a compacted stage',
      );

      // Local DB should now hold contiguous 1..3.
      final after = await stageDb.getStagesByStagePlanId(planId);
      final numbers = after.map((s) => s.stageNumber).toList()..sort();
      expect(numbers, equals([1, 2, 3]));

      // A second sync round should be a no-op for compaction.
      final result2 = await repo.syncPlans();
      expect(result2, isA<SyncPlansSuccess>());
      final success2 = result2 as SyncPlansSuccess;
      expect(success2.stagesCompacted, equals(0));
      expect(success2.plansAffected, equals(0));
    });
  });

  group('StagePlanRepository.syncPlans trail_route_ids', () {
    late StagePlannerDatabase stageDb;
    late AppDatabase appDb;
    late FakeNetworkService fakeNetwork;
    late FakeAppPreferences fakePrefs;
    late StagePlanRepository repo;

    setUp(() {
      StagePlanRepository.resetLegacyDatesNormalized();
      stageDb = StagePlannerDatabase();
      appDb = AppDatabase();
      fakeNetwork = FakeNetworkService();
      fakePrefs = FakeAppPreferences(credential: _loggedInCredential);
      repo = StagePlanRepository(appDb, stageDb, fakeNetwork, fakePrefs);
    });

    tearDown(() {
      repo.dispose();
    });

    test('round-trip preserves trail_route_ids end-to-end', () async {
      // Seed a local multi-trail plan with a non-NULL trail_route_ids.
      const descriptor = '1:0-3,2:0-2';
      final planId = await stageDb.createStagePlan(
        routeId: _kRouteId,
        name: 'Multi-trail plan',
        trailRouteIds: descriptor,
      );
      await stageDb.createStage(
        stagePlanId: planId,
        routeId: _kRouteId,
        startCityId: 100,
        endCityId: 101,
      );

      final localPlan = await stageDb.getStagePlanById(planId);
      final planUuid = localPlan!.uuid!;
      expect(localPlan.trailRouteIds, equals(descriptor));

      // Round 1: push.
      final pushResult = await repo.syncPlans();
      expect(pushResult, isA<SyncPlansSuccess>());

      // (a) Request payload carries the descriptor.
      final pushed = fakeNetwork.recordedRequests.last.plans
          .firstWhere((p) => p.uuid == planUuid);
      expect(pushed.trailRouteIds, equals(descriptor));

      // (b) Server-side state records the descriptor.
      expect(
        fakeNetwork.remotePlans[planUuid]!.trailRouteIds,
        equals(descriptor),
      );

      // Round 2: simulate fresh device — wipe local DB, sync again to
      // pull from server. This is the real cross-device behavior the
      // PRD's user story 7 cares about.
      await stageDb.closeDatabase();
      final dir = await databaseFactoryFfi.getDatabasesPath();
      final file = File(path.join(dir, 'stage_planner_database.db'));
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        await file.delete();
      }

      final pullResult = await repo.syncPlans();
      expect(pullResult, isA<SyncPlansSuccess>());

      // (c) Local DB now has the descriptor that came back from the server.
      final allPlans = await stageDb.getAllStagePlans();
      final pulledPlan =
          allPlans.firstWhere((p) => p.uuid == planUuid);
      expect(
        pulledPlan.trailRouteIds,
        equals(descriptor),
        reason: 'pull must persist trail_route_ids verbatim — '
            'this is the round-trip invariant',
      );
    });

    test('conflict resolution: device-that-pushed wins on trail_route_ids',
        () async {
      // Seed local multi-trail plan with descriptor A.
      const localDescriptor = '1:0-5,2:0-2';
      final planId = await stageDb.createStagePlan(
        routeId: _kRouteId,
        name: 'Local-edit plan',
        trailRouteIds: localDescriptor,
      );
      await stageDb.createStage(
        stagePlanId: planId,
        routeId: _kRouteId,
        startCityId: 100,
        endCityId: 101,
      );
      final localPlan = await stageDb.getStagePlanById(planId);
      final planUuid = localPlan!.uuid!;

      // First sync to establish the plan on the server.
      await repo.syncPlans();
      expect(
        fakeNetwork.remotePlans[planUuid]!.trailRouteIds,
        equals(localDescriptor),
      );

      // Pre-sync: server now carries a different descriptor (B). The
      // device-that-pushed wins rule means the next round's push
      // overwrites the remote-side value with whatever local has.
      fakeNetwork.remotePlans[planUuid]!.trailRouteIds = '99:0-1';

      // Sync again — local descriptor is still A; the push should
      // clobber the server's B.
      final result = await repo.syncPlans();
      expect(result, isA<SyncPlansSuccess>());

      // Server now reflects local's value.
      expect(
        fakeNetwork.remotePlans[planUuid]!.trailRouteIds,
        equals(localDescriptor),
      );

      // Local is unchanged (still A).
      final localAfter =
          (await stageDb.getStagePlanById(planId))!;
      expect(localAfter.trailRouteIds, equals(localDescriptor));
    });

    test('downgrade: server NULL replaces local trail_route_ids with NULL',
        () async {
      // Local has a multi-trail descriptor.
      const localDescriptor = '1:0-3,2:0-2';
      final planId = await stageDb.createStagePlan(
        routeId: _kRouteId,
        name: 'Downgrade plan',
        trailRouteIds: localDescriptor,
      );
      await stageDb.createStage(
        stagePlanId: planId,
        routeId: _kRouteId,
        startCityId: 100,
        endCityId: 101,
      );
      final localPlan = await stageDb.getStagePlanById(planId);
      final planUuid = localPlan!.uuid!;

      // Simulate a fresh-device pull: wipe local DB and pre-seed the
      // server with the same plan UUID but trail_route_ids = NULL
      // (single-route). On pull, the local row must come back with
      // trail_route_ids = NULL, not the lost local descriptor.
      await stageDb.closeDatabase();
      final dir = await databaseFactoryFfi.getDatabasesPath();
      final file = File(path.join(dir, 'stage_planner_database.db'));
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        await file.delete();
      }

      final now = DateTime.now().toUtc().toIso8601String();
      fakeNetwork.seedRemotePlan(
        FakeRemotePlan(
          uuid: planUuid,
          routeId: _kRouteId,
          createdAt: now,
          updatedAt: now,
          name: 'Downgrade plan',
          stages: [
            FakeRemoteStage(
              stageNumber: 1,
              startCityId: 100,
              endCityId: 101,
              routeId: _kRouteId,
              stageUuid: 'downgrade-stage-uuid',
              daysToStay: 1,
              updatedAt: now,
            ),
          ],
        ),
      );

      final result = await repo.syncPlans();
      expect(result, isA<SyncPlansSuccess>());

      final allPlans = await stageDb.getAllStagePlans();
      final pulledPlan =
          allPlans.firstWhere((p) => p.uuid == planUuid);
      expect(
        pulledPlan.trailRouteIds,
        isNull,
        reason: 'server NULL must downgrade local to single-route',
      );
    });

    test('SyncPlansSuccess.multiTrailRouteCounts reports one entry per '
        'multi-trail plan with its segment count', () async {
      // Plan A: multi-trail with 2 segments (JSON descriptor format).
      final planAId = await stageDb.createStagePlan(
        routeId: _kRouteId,
        name: 'Multi A',
        trailRouteIds: '[{"r":1},{"r":2,"j":100}]',
      );
      await stageDb.createStage(
        stagePlanId: planAId,
        routeId: _kRouteId,
        startCityId: 100,
        endCityId: 101,
      );

      // Plan B: multi-trail with 3 segments (legacy comma-separated format).
      final planBId = await stageDb.createStagePlan(
        routeId: _kRouteId2,
        name: 'Multi B',
        trailRouteIds: '1,2,3',
      );
      await stageDb.createStage(
        stagePlanId: planBId,
        routeId: _kRouteId2,
        startCityId: 200,
        endCityId: 201,
      );

      // Plan C: single-route (NULL trail_route_ids) — must NOT contribute.
      final planCId = await stageDb.createStagePlan(
        routeId: _kRouteId,
        name: 'Single C',
      );
      await stageDb.createStage(
        stagePlanId: planCId,
        routeId: _kRouteId,
        startCityId: 300,
        endCityId: 301,
      );

      final result = await repo.syncPlans();
      expect(result, isA<SyncPlansSuccess>());
      final success = result as SyncPlansSuccess;
      expect(
        success.multiTrailRouteCounts,
        unorderedEquals(const [2, 3]),
        reason: 'one entry per multi-trail plan, valued as segment count; '
            'single-route plans must not contribute',
      );
    });

    test('SyncPlansSuccess.multiTrailRouteCounts is empty when no plans '
        'are multi-trail', () async {
      await _seedLocalPlanWithStages(db: stageDb, routeId: _kRouteId);

      final result = await repo.syncPlans();
      expect(result, isA<SyncPlansSuccess>());
      final success = result as SyncPlansSuccess;
      expect(success.multiTrailRouteCounts, isEmpty);
    });
  });

  group('StagePlanRepository.syncPlans not-logged-in path', () {
    test('returns SyncPlansNotLoggedIn when no credential is stored',
        () async {
      final stageDb = StagePlannerDatabase();
      final appDb = AppDatabase();
      final fakeNetwork = FakeNetworkService();
      final fakePrefs = FakeAppPreferences();
      final repo =
          StagePlanRepository(appDb, stageDb, fakeNetwork, fakePrefs);
      addTearDown(repo.dispose);

      final result = await repo.syncPlans();
      expect(result, isA<SyncPlansNotLoggedIn>());
      expect(fakeNetwork.recordedRequests, isEmpty);
    });
  });
}
