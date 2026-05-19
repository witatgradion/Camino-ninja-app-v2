## Parent PRD

`issues/prd.md`

## What to build

Wire `trail_route_ids` through the sync request and response models and the repository sync code path. Per parent PRD sections "Chunk plan / C8" and "Sync API contract".

Add `trail_route_ids` (nullable `String?`) to `SyncPlanRequest` and `SyncPlanResponse` in `packages/remote_data/lib/src/models/sync/`. Use `@JsonKey(name: 'trail_route_ids')`. Regenerate `.g.dart` files.

Wire push path: `stage_plan_repository` includes `trailRouteIds` in the sync request payload for every plan that has it. Wire pull path: server-returned `trail_route_ids` is persisted to local `stage_plans.trail_route_ids` column. Conflict resolution follows the existing device-that-pushed-wins semantics locked in by `stage_plan_sync_test.dart` (no change in behavior).

Add integration tests in `packages/repository/test/integration/stage_plan_sync_test.dart` covering:
- Round-trip of a multi-trail plan via `FakeNetworkService` (push, server echo, pull, verify trail_route_ids preserved end-to-end)
- Conflict resolution: local edit + server response with different trail_route_ids → device-that-pushed wins
- Downgrade case: previously multi-trail plan, server sends NULL → local trail_route_ids becomes NULL (graceful single-route fallback)

## Acceptance criteria

- [ ] `SyncPlanRequest` and `SyncPlanResponse` have `trail_route_ids` field with correct JSON key
- [ ] Generated `.g.dart` files regenerated
- [ ] Push payload includes `trail_route_ids` for plans where it is non-NULL
- [ ] Pull persists server-returned `trail_route_ids` to local DB
- [ ] Integration test passes for round-trip
- [ ] Integration test passes for conflict resolution
- [ ] Integration test passes for downgrade case
- [ ] All existing sync tests still pass

## Blocked by

- Blocked by `issues/003-db-v10-migration-and-downgrade.md`
- Blocked by `issues/004-backend-trail-route-ids-api-confirmation.md`

## User stories addressed

- User story 7
- User story 19
- User story 28

## Progress note (2026-05-14) — implementation complete; merge gated on issue 004

All acceptance criteria met against the contract spelled out in the parent PRD (nullable `trail_route_ids` string, additive change). Issue 004 (backend round-trip confirmation) is a HITL task — implementation does not depend on its completion since the FakeNetworkService exercises the same contract.

Changes:

- `SyncPlanRequest` and `SyncPlanResponse` gained nullable `trailRouteIds` field with `@JsonKey(name: 'trail_route_ids')`. Generated files regenerated via `dart run build_runner build` in `packages/remote_data/`.
- `StagePlanRepository.syncPlans()` push path now includes `trailRouteIds: plan.trailRouteIds` in every `SyncPlanRequest`.
- `StagePlannerDatabaseStagePlans.upsertStagePlanFromSync` extended with a `trailRouteIds` parameter that is written verbatim (including null) on both insert and update — supports the downgrade semantics where the server can clear a previously-multi-trail plan back to single-route.
- `_applySyncResponse` passes `responsePlan.trailRouteIds` through to the upsert call.
- `FakeNetworkService` + `FakeRemotePlan` extended to carry `trailRouteIds` through the in-memory remote state and echo it on the response.
- 3 new integration tests in `stage_plan_sync_test.dart`: round-trip preservation (push → wipe → pull recovers descriptor); device-that-pushed-wins on `trail_route_ids` conflicts; server-NULL downgrades local to NULL on fresh pull.

Verification:

- `packages/repository`: 138/138 tests pass (3 new + 135 existing).
- `packages/storage`: 126/126 tests pass.
- `flutter test test/` (app-level): 51/51 pass.
- `flutter analyze` on changed files: 0 errors, info-level warnings only (all pre-existing).

Move to `issues/done/` once backend confirms the round-trip in issue 004; until then, leave open as the merge gate.
