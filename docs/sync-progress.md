# Cloud Sync Feature — Progress Tracker

**Branch:** `develop` (work in progress, not yet committed)
**Last Updated:** 2026-02-19
**Status:** Phase 1 & Phase 2 COMPLETE

---

## Phase 1: Foundation — COMPLETE

All data layer, API integration, and manual sync button are implemented and compiling.

### What Was Done

#### 1. Database Migration (v3 → v4)
**File:** `packages/storage/lib/src/stage_planner_database.dart`
- Added `uuid TEXT`, `plan_uuid TEXT`, `deleted_at TEXT` to `stage_plans`
- Added `stage_number INTEGER` to `stages`
- Migration auto-generates UUIDs for existing plans (SQLite `randomblob`)
- Migration auto-populates `stage_number` from date-sorted order
- Index on `stage_plans(uuid)`

#### 2. Storage Entity Updates
- `packages/storage/lib/src/models/stage_plan_entity.dart` — added `uuid`, `planUuid`, `deletedAt`
- `packages/storage/lib/src/models/stage_entity.dart` — added `stageNumber`
- `.g.dart` files regenerated

#### 3. Repository Model Updates
- `packages/repository/lib/src/models/stage_plan_model.dart` — added `uuid`, `planUuid`, `deletedAt`, `clearDeletedAt` in copyWith
- `packages/repository/lib/src/models/stage_model.dart` — added `stageNumber`

#### 4. Sync API Models (NEW files)
- `packages/remote_data/lib/src/models/sync/sync_stage_planner_request.dart`
  - `SyncStagePlannerRequest`, `SyncPlanRequest`, `SyncStageRequest`
  - Includes `deleted_at` for soft-delete communication
- `packages/remote_data/lib/src/models/sync/sync_stage_planner_response.dart`
  - `SyncStagePlannerResponse`, `SyncPlanResponse`, `SyncStageResponse`
- `packages/remote_data/lib/src/models/models.dart` — added sync exports
- `.g.dart` files generated

#### 5. API Client & Network Service
- `packages/remote_data/lib/src/api_client.dart` — added `syncStagePlanner()` Retrofit endpoint
- `packages/remote_data/lib/src/network_service.dart` — added `syncStagePlanner()` wrapper returning `ApiResult<SyncStagePlannerResponse>`

#### 6. Stage Planner Database CRUD Changes
- `createStagePlan()` — auto-generates UUID v4
- `createStage()` — auto-calculates `stage_number` (MAX+1)
- `deleteStagePlan()` — changed to **soft-delete** (sets `deleted_at`)
- `getAllStagePlans()` — filters `WHERE deleted_at IS NULL`
- New sync methods: `upsertStagePlanFromSync()`, `upsertStageFromSync()`, `replaceStagesForPlan()`, `hardDeleteSyncedPlans()`, `deleteLocalPlansNotInUuids()`, `getAllStagePlansIncludingDeleted()`

#### 7. Repository Sync Orchestration
- `packages/repository/lib/src/stage_plan_repository.dart`
  - Constructor now takes 4 deps: `_appDatabase`, `_stagePlannerDatabase`, `_networkService`, `_appPreferences`
  - Updated all entity→model mappings for new fields
  - Added `syncPlans()`: builds request → calls API → applies smart merge response
  - Added `_applySyncResponse()`: upsert plans, replace stages, delete removed plans, hard-delete synced soft-deletes

#### 8. Device ID & Name
- `packages/storage/lib/src/app_preferences.dart`
  - `getDeviceId()` — persistent UUID v4 in FlutterSecureStorage
  - `getDeviceName()` — actual device model via `device_info_plus` (async, cached)

#### 9. Dependency Updates
- `packages/storage/pubspec.yaml` — added `uuid: ^4.0.0`, `device_info_plus: ^12.3.0`
- `lib/di/dependency_injection.dart` — `StagePlanRepository` now gets 4 args: `getIt(), getIt(), getIt(), getIt()`

#### 10. UI: Manual Sync Button
- `lib/tabs/plan/cubit/plan_cubit.dart` — added `syncPlans()` method with `isSyncing` state
- `lib/tabs/plan/cubit/plan_state.dart` — added `isSyncing` field
- `lib/tabs/plan/plan_screen.dart` — sync IconButton in app bar (shows spinner while syncing)
  - **Note:** `CaminoNinjaAppBar` has `foregroundColor: Colors.transparent` by default, so icon color must be set explicitly
- `lib/widgets/top_notification_overlay.dart` — added `syncSuccess` / `syncFailure` types with green/red styling
- `lib/l10n/arb/app_en.arb` — added `syncSuccessTitle`, `syncSuccessDescription`, `syncFailureTitle`, `syncFailureDescription`

#### 11. Documentation
- `docs/sync-stage-planner.md` — Full API spec
- `docs/sync-implementation-plan.md` — Phase 1 implementation plan
- `docs/stage-planner-sync.postman_collection.json` — 10 Postman test scenarios

---

## Pre-Existing Changes (also uncommitted on this branch)

These changes were made before the sync work and are mixed in:
- **Plan naming dialog** — `lib/tabs/plan/widgets/name_plan_dialog.dart` (NEW)
- **Plan name in various screens** — `expandable_plan_card.dart`, `plan_detail_screen.dart`, `plan_detail_cubit.dart`, `add_edit_stage_screen.dart`, `add_edit_stage_cubit.dart`, `add_edit_stage_state.dart`, `stage_select_route_screen.dart`
- **DB v2→v3 migration** — added `name` column to `stage_plans`, `updated_at` to `stages`

---

## All Modified Files

### Edited (tracked)
```
lib/di/dependency_injection.dart
lib/l10n/arb/app_en.arb + all generated app_localizations_*.dart
lib/tabs/plan/cubit/plan_cubit.dart
lib/tabs/plan/cubit/plan_state.dart
lib/tabs/plan/plan_screen.dart
lib/tabs/plan/screens/add_edit_stage/add_edit_stage_screen.dart
lib/tabs/plan/screens/add_edit_stage/cubit/add_edit_stage_cubit.dart
lib/tabs/plan/screens/add_edit_stage/cubit/add_edit_stage_state.dart
lib/tabs/plan/screens/plan_detail/cubit/plan_detail_cubit.dart
lib/tabs/plan/screens/plan_detail/plan_detail_screen.dart
lib/tabs/plan/screens/select_route/stage_select_route_screen.dart
lib/tabs/plan/widgets/expandable_plan_card.dart
lib/widgets/top_notification_overlay.dart
packages/remote_data/lib/src/api_client.dart + .g.dart
packages/remote_data/lib/src/models/models.dart
packages/remote_data/lib/src/network_service.dart
packages/repository/lib/src/models/stage_model.dart
packages/repository/lib/src/models/stage_plan_model.dart
packages/repository/lib/src/stage_plan_repository.dart
packages/storage/lib/src/app_preferences.dart
packages/storage/lib/src/models/stage_entity.dart + .g.dart
packages/storage/lib/src/models/stage_plan_entity.dart + .g.dart
packages/storage/lib/src/stage_planner_database.dart
packages/storage/pubspec.yaml
pubspec.lock
```

### New (untracked)
```
lib/tabs/plan/widgets/name_plan_dialog.dart
packages/remote_data/lib/src/models/sync/sync_stage_planner_request.dart + .g.dart
packages/remote_data/lib/src/models/sync/sync_stage_planner_response.dart + .g.dart
docs/sync-stage-planner.md
docs/sync-implementation-plan.md
docs/stage-planner-sync.postman_collection.json
```

---

## Tested

- App builds and runs without errors (`flutter analyze` passes — info only)
- Sync button visible on Plan tab, triggers API call
- API request sent correctly with UUID, device headers, plan data
- Server responded successfully (confirmed in debug logs)

---

## Phase 2: UX & Automation — COMPLETE

1. **SyncManager service** — `lib/tabs/plan/services/sync_manager.dart` — Singleton with 3-second debounce timer, queued follow-up syncs, auto-triggers on app resume and connectivity restore
2. **Auto-trigger on mutations** — `StagePlanRepository` fires `_notifySyncNeeded()` after every mutation (6 methods: delete plan, update plan name, create/update/delete stage)
3. **"Sign in to sync" UI** — `plan_screen.dart` `_buildSignInToSyncBanner()` — tappable banner shown for guest users, navigates to login
4. **Sync status indicator** — `lib/widgets/sync_indicator_pill.dart` — global overlay in `RootScreen` with slide animation, shows syncing/success/failure states, auto-resets after 2s
5. **Connectivity check** — `lib/utils/network_util.dart` — dual check (connectivity_plus + internet_connection_checker_plus), sync skips silently when offline, auto-triggers on reconnect
6. **Handle conflict plans in UI** — `expandable_plan_card.dart` — "Synced copy" badge when `plan_uuid` is not null
7. **Test coverage** — Deferred; QR codec tests exist in `packages/repository/test/stage_plan_codec_test.dart`

---

## Key Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Sync strategy | Background + debounce (Phase 2) | Don't block UI |
| Offline behavior | Skip silently | No retry queue needed |
| Stage ordering | `stage_number` in DB | Primary ordering field |
| Auth requirement | Logged-in only | Guests can't sync |
| Merge strategy | Smart merge by UUID | Match, upsert, delete removed |
| Deletion | Soft-delete locally, send `deleted_at` in request | Server processes deletion |
| Device ID | Persistent UUID in FlutterSecureStorage | Survives app restart |
| Device name | `device_info_plus` (actual model) | Better than generic "Android Device" |
