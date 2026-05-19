## Parent PRD

`issues/prd.md`

## What to build

Add stage planner DB v10 migration + downgrade handler + migration tests. Per parent PRD sections "Database" and "Chunk plan / C2".

Add `_migrateStagePlannerToV10` helper following release/2.2.410's helper-function pattern. Body: idempotent `ALTER TABLE stage_plans ADD COLUMN trail_route_ids TEXT`, guarded by `PRAGMA table_info(stage_plans)` check (no-op if column exists). Bump `stagePlannerDatabaseVersion` from 9 to 10.

Register `onDowngrade: onDatabaseDowngradeDelete` on the stage planner database `openDatabase` call, matching the `app_database` pattern. A v10 → v9 downgrade resets the stage planner DB cleanly.

Add fixture `packages/storage/test/migrations/fixtures/stage_planner/v9.sql` capturing release/2.2.410's post-`stage_uuid`-backfill state. Extend `packages/storage/test/migrations/stage_planner_migration_test.dart` with tests for v7→v10, v8→v10, v9→v10 paths. Add a regression test that exercises a real multi-stage `MultiRouteTrail` plan through the migration end-to-end and asserts `trail_route_ids` is preserved when pre-existing.

## Acceptance criteria

- [ ] `stagePlannerDatabaseVersion = 10`
- [ ] `_migrateStagePlannerToV10` helper exists and is idempotent (re-running adds nothing)
- [ ] `onDowngrade: onDatabaseDowngradeDelete` registered on stage planner DB
- [ ] Fixture `v9.sql` added under `packages/storage/test/migrations/fixtures/stage_planner/`
- [ ] Migration tests cover v7→v10, v8→v10, v9→v10 paths
- [ ] Regression test passes: real multi-stage plan survives migration
- [ ] All existing storage tests still pass

## Blocked by

- Blocked by `issues/002-atomic-merge-release-2-2-410.md`

## User stories addressed

- User story 14
- User story 15
- User story 16
- User story 18

## Progress note (2026-05-14, completion — absorbed into C1)

Closed by issue 002's merge commit. Product owner approved absorbing C2 into C1 (option "Keep fix; absorb C2 into C1" + v10 hybrid add-on) after Phase B revealed that leaving the v9 → v10 work for a separate commit would either red the test suite or leave the silent-feature-failure gap the PRD warned about.

### What landed (all in issue 002's merge commit)

- [x] `stagePlannerDatabaseVersion = 10`
- [x] `_migrateStagePlannerToV10` exists in `packages/storage/lib/src/stage_planner_database.dart`; idempotent `PRAGMA table_info(stage_plans)` + `ALTER TABLE stage_plans ADD COLUMN trail_route_ids TEXT`
- [x] `onDowngrade: onDatabaseDowngradeDelete` registered on the stage planner DB's `openDatabase` call
- [x] `packages/storage/test/migrations/fixtures/stage_planner/v9.sql` added (3 plans / 6 stages, all `stage_uuid` backfilled, no `trail_route_ids` — mirrors `release/2.2.410`'s v9 state)
- [x] Migration tests cover v9→v10 (column-add no-data-rewrite + descriptor round-trip); v7→v10 + v8→v10 implicitly covered via `_stagePlansFullColumns` update flowing through existing chained tests
- [x] Regression test: hand-written `MultiRouteTrail` descriptor (`[{"r":1},{"r":3,"j":250}]`) round-trips through v9 → v10 migration
- [x] All existing storage tests still pass — 124 → 126

### Belt-and-braces note

A previous flutter-expert (Phase B) added `trail_route_ids` to v9's fresh-create AND made `_migrateStagePlannerToV9` idempotently add the column. That work was left intact when v10 was added on top. Result:
- Users on this branch's pre-merge v9: column already present, v10 migration no-ops
- Users on `release/2.2.410`'s v9: v10 migration adds the column
- Fresh installs: v10 schema includes the column from `CREATE TABLE`

**Status: complete. Move to `issues/done/`.**
