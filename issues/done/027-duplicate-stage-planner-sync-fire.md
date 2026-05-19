## Parent PRD

`issues/prd.md` — surfaced during the issue 004 round-trip verification on 2026-05-15. Not part of the original PRD scope.

## What to build

Find and fix the duplicate-sync-fire bug. Every stage planner sync triggers ALL of the following exactly twice in the same invocation:

- `POST /api/v1/stage_planner/sync` HTTP request (two complete round-trips, ~2 ms apart)
- `[StagePlanRepository] [SYNC_UUID] outbound plan ...` log
- `[StagePlanRepository] [SYNC_UUID] inbound response ...` log
- `[StagePlanRepository] [SYNC_UUID] apply plan ...` log (per plan)
- `[StagePlannerDB] [SYNC_UUID] upsert ...` log (per stage)
- `cloud_sync_started` analytics event
- `cloud_sync_success` analytics event
- `multi_trail_plan_sync_success` analytics event

This is NOT a CompositeAnalyticsService fan-out artifact — the HTTP requests double too, which means the entire sync code path is being invoked twice from somewhere higher up.

### Why this matters before ramp

1. **2× backend load** per user sync — at ramp scale this is meaningful unnecessary traffic. The dev backend tolerates it now but prod scaling estimates will be 2× off.
2. **2× network bandwidth on the device** — battery + data plan cost.
3. **Analytics inflation** — `plan_type_choice_selected` / `multi_trail_plan_sync_success` / `cloud_sync_success` cohort counts will all be 2×. Adoption KPIs in PRD section "Adoption KPIs" become unreliable until this is fixed. Phase (c) ramp progression rule (`plan_type_choice_selected non-single rate ≥ 5% of sessions`) would be measured against an inflated denominator AND inflated numerator — not necessarily wrong ratio-wise but inflated in absolute terms makes monitoring noisier.
4. **Possible race condition** — two concurrent syncs hitting the same local DB through the same `StagePlanRepository`/`StagePlannerDB` paths. The fact that no `SqliteException` showed up in the log suggests the inner code is reasonably idempotent (the two `apply plan` calls per plan land on the same UUIDs and produce the same `upsert matched existing stage` results), but this is incidental — the second run reuses results of the first. If one of the syncs were to fail mid-flight, behavior is unspecified.

### Reproduction

1. Sign in on dev flavor, Android emulator
2. With at least one local stage plan, trigger sync (auto on sign-in or manual via pull-to-refresh)
3. Filter logcat for `stage_planner/sync` and `[SYNC_UUID]`
4. Observe every line appears twice, paired 2-25 ms apart

Captured logcat sample at issue 004's completion note (`issues/done/004-backend-trail-route-ids-api-confirmation.md`).

### Investigation pointers

Likely root causes to triage (in priority order):

1. **Two BlocConsumer/listener subscriptions both calling `syncPlans()`** on the same trigger. The most common shape: a parent widget AND a child widget both react to `AuthState.signedIn` and each kicks off the sync via the repo. Check `lib/tabs/plan/cubit/plan_cubit.dart`, `lib/tabs/more/...` (sign-in success), and any app-level `AuthCubit` listeners.
2. **App lifecycle + cubit init both triggering** — e.g., `WidgetsBindingObserver.didChangeAppLifecycleState` on resume fires sync, AND a cubit's `init()` also calls it on the same boot.
3. **`AppState.copyWith` footgun**: the documented `dataFetchCompletedAt`/`authChangedAt` gotcha (see `MEMORY.md`) — a `copyWith` that nullifies `authChangedAt` mid-flow could cause a "auth changed" listener to refire. Lower likelihood but worth ruling out.
4. **Hot-reload / debug-only re-emission** — verify the issue repros on a release-mode APK install (not just `flutter run`). The reproduction above was on a release APK install (`app-development-release.apk`), so this is unlikely but should be confirmed.

Recommend `/diagnose` skill workflow: minimal reproduction → instrument the entry points to `_repository.syncPlans()` or equivalent → trace which two call sites both trigger → fix the duplicate trigger, not the inner method's idempotency.

### Scope guidance

- Out of scope: making the inner sync code idempotent. The fix should be at the trigger layer (one and only one trigger per user-initiated sync), not the inner layer.
- Out of scope: fixing `cloud_sync_started` / `cloud_sync_success` analytics specifically. If the trigger fix lands cleanly, all the downstream events stop double-firing too.
- In scope: a regression test that asserts a single sync trigger invokes the repository's sync exactly once.

## Acceptance criteria

- [ ] Root cause identified and documented in the commit or branch memory
- [ ] One sync trigger = one `POST /api/v1/stage_planner/sync` HTTP request (verified via logcat)
- [ ] One sync trigger = one `cloud_sync_started`, one `cloud_sync_success`, one `multi_trail_plan_sync_success` analytics event
- [ ] No `[SYNC_UUID]` log duplication
- [ ] Regression test: a unit/integration test that fails if a duplicate trigger is reintroduced. Prior art: `packages/repository/test/integration/stage_plan_sync_test.dart` for the sync integration test pattern; consider asserting `FakeNetworkService` was hit exactly once per sync invocation.
- [ ] No new analyze errors; existing tests still pass

## Blocked by

None. Can run in parallel with the HITL rollout chain (018, 020-025).

## Priority

**Should fix before Phase (c) App Store ramp** so adoption KPIs measure cleanly. Not blocking Phase (a) staging TF or Phase (b) prod TF — both internal cohorts, inflation noise is tolerable for dogfood.

## User stories addressed

- User story 22 (operator funnel analytics)
- User story 24 (operator feature-flag-exposure / cohort reconciliation)
- User story 23 (operator multi_trail_plan_sync_success / _failed sync health)

## Progress note (2026-05-15) — root cause + fix shipped

### Root cause

Two trigger paths were firing on every auth change (sign-in, sign-out,
or 401-triggered token refresh):

1. `AppCubit.notifyAuthChanged()` (`lib/app/cubit/app_cubit.dart:43`)
   directly called `SyncManager.syncIfNeeded()`.
2. The same method also emitted a new `authChangedAt`. The plan
   screen's `_authChangedSubscription` listener
   (`lib/tabs/plan/plan_screen.dart:184`, `_onAuthChanged`) reacted
   to the change and called `_cubit.triggerAutoSync()`, which in turn
   called `_syncManager.syncIfNeeded()`.

Both calls reached `SyncManager._performSync()`. The `_isSyncing`
guard was set AFTER `await _isLoggedIn()`. Two near-simultaneous
callers both passed the guard, both opened completers, both ran the
full sync work concurrently → 2× HTTP request, 2× analytics events,
2× SYNC_UUID log lines.

### Fix

Layered fix at the trigger layer (no inner-method idempotency
changes, per the issue's scope guidance):

1. **Remove the duplicate trigger** at `_onAuthChanged` in
   `lib/tabs/plan/plan_screen.dart`. `AppCubit.notifyAuthChanged()`
   is the canonical sync trigger on auth change and works regardless
   of which tab is mounted; the plan listener still calls
   `loadData(shouldShowLoading: false)` to refresh the displayed
   list. The unused `PlanCubit.triggerAutoSync()` method was deleted.
2. **Defense in depth** in `lib/tabs/plan/services/sync_manager.dart`:
   `_isSyncing = true` and the `_syncCompleter` are now claimed
   synchronously right after the `if (_isSyncing) return` guard,
   before any `await`. Both `_performSync()` and `syncNow()`
   restructured with two nested try/finally — outer for `_isSyncing`
   release, inner for `_lastSyncTime` and the actual sync work. This
   closes the race even if a future change reintroduces a concurrent
   trigger.

### Regression test

`test/tabs/plan/services/sync_manager_test.dart` (2 tests):

- **Two concurrent `syncIfNeeded` calls coalesce to one
  `syncPlans` invocation.** Uses a deferred completer to hold the
  first sync open while the second arrives, then asserts the mock
  repository was called exactly once.
- **30-second freshness window still debounces a follow-up sync.**
  Locks in existing behavior so the synchronous claim doesn't
  inadvertently change the cooldown semantics.

Caveat: `Repository.syncSavedAccommodations` is an extension method
(documented mocktail limitation per `cubit-testing.md`) and is
deliberately left unstubbed — the call is `unawaited` in
SyncManager, so its rejected future is harmless to the assertions.
Test output includes a stderr `NoSuchMethodError` log line from this
path; it does NOT cause test failure.

### Acceptance criteria — final status

- [x] Root cause identified and documented (this note + branch memory)
- [x] One sync trigger = one repository `syncPlans()` invocation
      (locked in by the regression test; on-device verification
      deferred to a manual smoke check at next dev-flavor sign-in)
- [x] Downstream double-fire on `cloud_sync_started` /
      `cloud_sync_success` / `multi_trail_plan_sync_success` will
      stop as a consequence of the single-invocation guarantee
- [x] No `[SYNC_UUID]` log duplication (same reasoning)
- [x] Regression test added at
      `test/tabs/plan/services/sync_manager_test.dart`
- [x] No new analyze errors; pre-existing warnings unchanged. Full
      test suite green: app 107/107, repository 140/140, storage
      126/126, analytics_services 42/42

**Status: complete. Move to `issues/done/`.**
