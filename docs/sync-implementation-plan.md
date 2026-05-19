# Plan: Stage Planner Sync — Phase 1 (Foundation)

## Context
Adding bidirectional sync for stage plans between mobile and server via `POST /api/v1/stage_planner/sync`. This phase establishes the data layer foundation: DB schema changes, API models, API client method, and a basic sync method in the repository with smart merge logic. Phase 2 (later) will add the background sync manager with debounce, the UI "sign in to sync" indicator, and mutation hooks.

**Decisions made:**
- Sync strategy: Background + debounce (Phase 2)
- Offline: Online-only, skip silently if offline
- Stage ordering: Store `stage_number` in DB (future primary ordering)
- Auth: Logged-in only, show indicator for guests (Phase 2 UI)
- Replace strategy: Smart merge (match by UUID, update in place)
- Deletion: Soft-delete locally (set `deleted_at`), send in sync request so server knows

## API Spec Reference
`docs/sync-stage-planner.md` — `POST /api/v1/stage_planner/sync`

---

## Changes

### 1. Database migration v3 → v4
**File:** `packages/storage/lib/src/stage_planner_database.dart`

Bump `version: 4`. Add to `onUpgrade`:
```
if (oldVersion < 4) {
  - Add `uuid TEXT` to stage_plans (if missing)
  - Add `plan_uuid TEXT` to stage_plans (if missing)
  - Add `deleted_at TEXT` to stage_plans (if missing)
  - Add `stage_number INTEGER` to stages (if missing)
  - Create index on stage_plans(uuid)
}
```

Update `_createTables` to include new columns for fresh installs.

Auto-generate UUID for existing plans (in migration): `UPDATE stage_plans SET uuid = lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-4' || substr(hex(randomblob(2)),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(hex(randomblob(2)),2) || '-' || hex(randomblob(6))) WHERE uuid IS NULL`

Auto-populate `stage_number` for existing stages: computed from date-sorted order per plan.

### 2. Update storage entities
**File:** `packages/storage/lib/src/models/stage_plan_entity.dart`
- Add `String? uuid` field with `@JsonKey(name: 'uuid')`
- Add `String? planUuid` field with `@JsonKey(name: 'plan_uuid')`
- Add `String? deletedAt` field with `@JsonKey(name: 'deleted_at')`

**File:** `packages/storage/lib/src/models/stage_plan_entity.g.dart`
- Regenerate with `dart run build_runner build`

**File:** `packages/storage/lib/src/models/stage_entity.dart`
- Add `int? stageNumber` field with `@JsonKey(name: 'stage_number')`

**File:** `packages/storage/lib/src/models/stage_entity.g.dart`
- Regenerate

### 3. Update repository models
**File:** `packages/repository/lib/src/models/stage_plan_model.dart`
- Add `String? uuid` field
- Add `String? planUuid` field
- Add `String? deletedAt` field
- Update `copyWith`

**File:** `packages/repository/lib/src/models/stage_model.dart`
- Add `int? stageNumber` field
- Update `copyWith`

### 4. Update DB CRUD to handle new fields
**File:** `packages/storage/lib/src/stage_planner_database.dart`
- `createStagePlan()`: generate UUID (using `uuid` package), include in INSERT
- `createStage()`: accept and store `stageNumber`
- `getAllStagePlans()` / `getStagePlanById()`: filter out soft-deleted plans (`WHERE deleted_at IS NULL`)
- `getStagesByStagePlanId()`: return stageNumber field
- Change `deleteStagePlan()`: soft-delete — `UPDATE stage_plans SET deleted_at = <now RFC3339> WHERE id = ?` instead of `DELETE`
- Add method: `getAllStagePlansIncludingDeleted()` — returns all plans (for sync request building)
- Add method: `upsertStagePlanFromSync()` — insert or update plan by UUID
- Add method: `upsertStageFromSync()` — insert or update stage by (stage_plan_id, stage_number)
- Add method: `hardDeleteSyncedPlans()` — permanently remove soft-deleted plans after successful sync
- Add method: `deleteLocalPlansNotInUuids(List<String> uuids)` — for smart merge cleanup

### 5. Update repository mappings
**File:** `packages/repository/lib/src/stage_plan_repository.dart`
- Update `getAllStagePlans()` mapping to include uuid, planUuid
- Update `getStagePlanById()` mapping to include uuid, planUuid
- Update stage mappings to include stageNumber

### 6. Device ID generation and storage
**File:** `packages/storage/lib/src/app_preferences.dart`
- Add `DEVICE_ID` key
- Add `getDeviceId()`: returns stored UUID, or generates + stores one on first call
- Add `getDeviceName()`: returns device model name (use `package_info_plus` or platform channel)

### 7. Create sync request/response models
**New file:** `packages/remote_data/lib/src/models/sync_stage_planner_request.dart`
```dart
class SyncStagePlannerRequest {
  final List<SyncPlanRequest> plans;
}

class SyncPlanRequest {
  final String uuid;        // empty string for new plans
  final int routeId;
  final String? name;
  final bool isImported;
  final List<SyncStageRequest> stages;
  final String updatedAt;   // RFC3339
  final String? deletedAt;  // RFC3339, set when user deletes plan locally
}

class SyncStageRequest {
  final int stageNumber;
  final int routeId;
  final String? date;       // RFC3339
  final int startCityId;
  final int endCityId;
  final int? startAlbergueId;
  final int? endAlbergueId;
  final String? customStartNotes;
  final String? customEndNotes;
  final String? stageNotes;
  final String? createdAt;
  final String? updatedAt;
}
```

**New file:** `packages/remote_data/lib/src/models/sync_stage_planner_response.dart`
```dart
class SyncStagePlannerResponse {
  final List<SyncPlanResponse> plans;
}

class SyncPlanResponse {
  final String uuid;
  final int routeId;
  final String? name;
  final bool isImported;
  final String? planUuid;
  final String? deviceId;
  final String? deviceName;
  final List<SyncStageResponse> stages;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
}

class SyncStageResponse {
  // same fields as SyncStageRequest
}
```

Use `@JsonSerializable()` + `json_annotation` for these. Run `build_runner` to generate `.g.dart` files.

### 8. Add sync endpoint to API client
**File:** `packages/remote_data/lib/src/api_client.dart`
```dart
@POST('/api/v1/stage_planner/sync')
Future<SyncStagePlannerResponse> syncStagePlanner(
  @Header('X-Device-ID') String deviceId,
  @Header('X-Device-Name') String? deviceName,
  @Body() SyncStagePlannerRequest request,
);
```

### 9. Add sync method to NetworkService
**File:** `packages/remote_data/lib/src/network_service.dart`
```dart
Future<ApiResult<SyncStagePlannerResponse>> syncStagePlanner({
  required String deviceId,
  String? deviceName,
  required SyncStagePlannerRequest request,
}) async { ... }
```

### 10. Add sync orchestration to StagePlanRepository
**File:** `packages/repository/lib/src/stage_plan_repository.dart`

New method `syncPlans()`:
1. Check if user is logged in → return early if not
2. Read all local plans including soft-deleted ones (`getAllStagePlansIncludingDeleted()`)
3. Build `SyncStagePlannerRequest` — include soft-deleted plans with their `deleted_at` set, compute stage_number from date-sorted order for plans without one
4. Get device ID from AppPreferences
5. Call `networkService.syncStagePlanner()`
6. On success → **smart merge**:
   a. Collect all UUIDs from response
   b. For each response plan:
      - If UUID matches a local plan → update local plan fields + stages
      - If no match → insert as new local plan
   c. Delete local plans whose UUID is not in response (server deleted them)
   d. For each plan's stages: match by stage_number, upsert accordingly
   e. Hard-delete soft-deleted plans from local DB (sync confirmed server received them)
7. On failure → silently return (soft-deleted plans stay in DB, will be retried next sync)

### 11. Add `uuid` package dependency
**File:** `packages/storage/pubspec.yaml`
- Add `uuid: ^4.0.0` dependency (for generating UUIDs on plan creation)

---

## Files Summary

| File | Action |
|------|--------|
| `packages/storage/lib/src/stage_planner_database.dart` | **Edit** — migration v4, new columns, upsert methods |
| `packages/storage/lib/src/models/stage_plan_entity.dart` | **Edit** — add uuid, planUuid fields |
| `packages/storage/lib/src/models/stage_plan_entity.g.dart` | **Regenerate** |
| `packages/storage/lib/src/models/stage_entity.dart` | **Edit** — add stageNumber field |
| `packages/storage/lib/src/models/stage_entity.g.dart` | **Regenerate** |
| `packages/storage/lib/src/app_preferences.dart` | **Edit** — add device ID methods |
| `packages/storage/pubspec.yaml` | **Edit** — add uuid dependency |
| `packages/repository/lib/src/models/stage_plan_model.dart` | **Edit** — add uuid, planUuid |
| `packages/repository/lib/src/models/stage_model.dart` | **Edit** — add stageNumber |
| `packages/repository/lib/src/stage_plan_repository.dart` | **Edit** — update mappings, add syncPlans() |
| `packages/remote_data/lib/src/models/sync_stage_planner_request.dart` | **Create** |
| `packages/remote_data/lib/src/models/sync_stage_planner_response.dart` | **Create** |
| `packages/remote_data/lib/src/api_client.dart` | **Edit** — add sync endpoint |
| `packages/remote_data/lib/src/network_service.dart` | **Edit** — add sync method |

## Verification
1. Run `dart run build_runner build` in `packages/storage` and `packages/remote_data` to regenerate `.g.dart` files
2. Run `flutter analyze` to verify no lint issues
3. Run `flutter test` to verify no regressions
4. Manual test: create plans, verify uuid is generated and stored
5. Manual test: call syncPlans() and verify request format matches API spec
6. Manual test: verify smart merge correctly handles insert/update/delete scenarios

## What Phase 2 will add (not in this plan)
- SyncManager service with debounce timer + queue
- Hook into plan/stage mutations to trigger sync
- "Sign in to sync" UI indicator for guests
- Subtle sync status indicator (spinner/checkmark)
- Connectivity check before syncing
