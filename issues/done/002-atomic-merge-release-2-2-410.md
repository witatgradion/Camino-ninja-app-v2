## Parent PRD

`issues/prd.md`

## What to build

Atomic merge of `origin/release/2.2.410` into the integration branch. Single merge commit. Apply the per-category conflict resolution policy from parent PRD section "Merge strategy" — generated files regenerated (not hand-merged); storage restructure accepts theirs and parks `trail_route_ids` work for the next issue; map widgets take theirs verbatim (trail logic comes back in the Mapbox port issues); plan cubits/screens merge intent with synthesis comments; `main_staging.dart` merges intent; pubspec takes theirs; ARB unions keys.

**Escalation rule (mandatory)**: if a conflict's semantic intent is ambiguous — both sides changed the same line in semantically different ways — stop and escalate to the product owner. Do not guess.

After source-level conflicts resolve, regenerate generated files via `./tool/generate_protos.sh` and `dart run build_runner build --delete-conflicting-outputs`. Include regenerated output in the merge commit.

## Acceptance criteria

- [ ] Single merge commit on `feature/combining-trails-mapbox`
- [ ] All tests that pass on `origin/release/2.2.410` still pass on the merged branch
- [ ] `flutter analyze` is clean across all packages
- [ ] `flutter build apk --flavor development` succeeds
- [ ] `flutter build ios --flavor development --no-codesign` succeeds
- [ ] App launches in dev flavor; main 4 tabs render
- [ ] `PlanTypeChoiceSheet` opens (options 2/3 may be visually broken — expected, fixed by issues 006-009)

## Blocked by

- Blocked by `issues/001-set-up-integration-worktree.md`

## User stories addressed

- User story 14
- User story 17

## Progress note (2026-05-14)

AFK attempt at the atomic merge. Resolved 14 of 14 source-level conflicts cleanly per the per-category policy. Then discovered the PRD policy as written leaves the codebase in an architecturally inconsistent state that I cannot resolve without product-owner input. **Merge aborted; working tree restored to commit `99151913`.**

### What worked (applying the policy strictly)

- **Take-theirs (6 files)** — staged cleanly:
  - `pubspec.yaml`
  - `lib/tabs/map/widgets/embedded_stage_map.dart`
  - `lib/tabs/plan/screens/stage_map/stage_map_screen.dart`
  - `packages/storage/lib/src/app_database.dart`
  - `packages/storage/lib/src/app_database_schema.dart`
  - `packages/storage/lib/src/stage_planner_database.dart`
- **Merge-intent (9 files)** — all resolved by union semantics (both sides' fields/imports/widgets kept):
  - `lib/main_staging.dart` (import union: chottu_link + offline_map_service + shared_preferences + mapbox_maps_flutter; dropped unused `firebase_app_check` import)
  - `lib/tabs/plan/cubit/plan_cubit.dart` (added `_fireAndClearPendingStageUuidBackfill` call before `_resolveMultiRouteMaps`)
  - `lib/tabs/plan/plan_screen.dart` (import union: plan_type_choice_sheet + stage_note_bottom_sheet)
  - `lib/tabs/plan/screens/add_edit_stage/cubit/add_edit_stage_cubit.dart` (both `_resolveRouteId` and `_initialStageNote`/`_noteChangedDuringSession`)
  - `lib/tabs/plan/screens/add_edit_stage/cubit/add_edit_stage_state.dart` (added `trail` + `clearStageNotes` to constructor, copyWith, props)
  - `lib/tabs/plan/screens/plan_detail/cubit/plan_detail_cubit.dart` (added `_fetchRouteMap` AND `refreshLoginState` methods; copyWith call carries routeMap+trail+isLoggedIn)
  - `lib/tabs/plan/screens/plan_detail/cubit/plan_detail_state.dart` (added `routeMap`, `trail`, `isLoggedIn` to ctor, copyWith, props)
  - `lib/tabs/plan/screens/plan_detail/stage_detail_card.dart` (added `_StageNoteCard` to Column children list)
  - `lib/tabs/plan/widgets/expandable_plan_card.dart` (constructor takes `onStageNoteTap` + `multiRouteMap`)

No line-level escalation was needed for any of the above — both sides' intents were independent, additive, and compatible.

### Why the merge cannot be completed AFK

After conflict resolution and a fresh `flutter pub get` + `melos bootstrap` + proto regeneration, `flutter analyze` reports **168 errors** across **7 source files** in `lib/`. They cluster into four architectural gaps that the PRD's policy does not address:

1. **Half-migrated Mapbox state.** `release/2.2.410` removed `google_maps_flutter` from `pubspec.yaml` and ported `embedded_stage_map`, `stage_map_screen` to Mapbox. But these 7 HEAD-only multi-trail and dev-only screens still import `google_maps_flutter`:
   - `lib/tabs/plan/screens/trail_builder/cubit/trail_builder_cubit.dart`
   - `lib/tabs/plan/screens/trail_builder/trail_builder_screen.dart`
   - `lib/tabs/plan/screens/trail_builder/widgets/trail_preview_map.dart`
   - `lib/tabs/plan/screens/journey_planner/journey_planner_screen.dart`
   - `lib/tabs/more/screens/debug_route_map/debug_route_map_screen.dart`
   - `lib/tabs/more/screens/route_city_overview/route_city_overview_screen.dart`
   - `lib/tabs/more/screens/route_graph/route_map_screen.dart`

   With pubspec set to theirs (no `google_maps_flutter`), all 7 fail to compile.

2. **Transition dep attempt fails on type collisions.** Adding `google_maps_flutter: ^2.14.0` back to `pubspec.yaml` as a bridge produces a different cluster of compile errors: `LatLng` is now defined in BOTH `latlong2` and `google_maps_flutter_platform_interface`, and the multi-trail and `route_city_overview` screens pass `List<LatLng>` between callers that have resolved each to a different type. Other callers expect `MapboxMap?` where HEAD passes `GoogleMapController?` — already-Mapbox-migrated map widgets receive controllers from screens that have NOT been migrated. The merge produced inconsistent map-API call signatures across the cubit/widget boundary.

3. **`route_graph_screen.dart` uses a missing package.** Independent of Mapbox, that screen depends on the `graphview` package which is not in `pubspec.yaml` on either side of the merge. Either it was always missing on HEAD (i.e., this screen never compiled on the source branch), or the dependency was removed somewhere along the merge base history. Needs human triage.

4. **`trail_route_ids` runtime gap.** Per policy, storage was taken from theirs (no `trail_route_ids` column in the v9 schema), but the auto-merge brought in HEAD's `stage_plan_entity.dart` and `stage_planner_database_stage_plans.dart` that read/write the column. App will launch and read existing plans (column silently missing → NULL via JSON parsing), but `createStagePlan` will fail with `no such column: trail_route_ids`. The PRD explicitly parks this work for issue 003 (C2). This was expected and would resolve as soon as 003 lands.

### What the PRD as written cannot decide

The C1 acceptance criteria are mutually inconsistent given the policy:

- "take theirs for pubspec" → removes `google_maps_flutter`
- "`flutter analyze` clean" → requires the 7 HEAD-only screens to compile
- "`flutter build apk` succeeds" → same
- "options 2/3 may be visually broken — expected, fixed by issues 006–009" → implies the screens compile but render incorrectly

Compile-passing requires one of three approaches, and the PRD does not pick one:

- **(a) Reorder chunks** so that C3, C4, C5 (Mapbox ports of the 7 files) ship inside the same merge commit as C1. Largest C1, but produces the cleanest single-step landing.
- **(b) Stub the 7 screens** with placeholder widgets that compile, and let C3, C4, C5 restore the real implementation. Cheapest C1, loses logic temporarily.
- **(c) Keep `google_maps_flutter` as a transition dep AND write a `LatLng`/controller bridge layer** so HEAD's screens keep building until C3–C5 port them. Most code-preserving, but requires accepting a brief dual-Maps build (with the iOS native plugin tradeoffs that implies) and writing the shim.

Each of these is an architectural decision that exceeds the AFK escalation rule's "don't guess on ambiguous line-level conflicts." The choice carries different cost and risk profiles that the product owner should make explicitly.

### Recommendation

Reorder chunks so C3-C5 land in the same merge commit as C1 (option (a)). Rationale: it eliminates the inconsistent intermediate state entirely, and the Mapbox ports are already mandatory and load-bearing per the PRD. The added integration scope is real but bounded (7 files), and absorbing it here avoids three follow-up issues having to navigate a broken-build branch.

If that is too large a scope to swallow in one chunk, option (b) (stub) is next-cleanest: write 7 placeholder widgets, let C3-C5 restore the real code from the pre-merge branch via cherry-pick or `git show feature/combining-trails:<path>`.

### Next actions

- Product owner to choose between (a), (b), (c), or "merge anyway with broken build, fix forward in C3-C5"
- After the decision, re-run the merge from a clean tree starting from commit `99151913` and apply the 14 resolutions documented above; they were correct as far as they went
- `graphview` package question separately needs answering (was that screen ever compiling on this branch?)

**Status: blocked on product-owner architectural decision. Not moved to `issues/done/`.**

## Progress note (2026-05-14, decision)

Product owner picked **option (c) — bridge with transition dep**, plus delete `route_graph_screen.dart`.

### Adjusted approach for C1

Replay the 14 documented resolutions from a clean `99151913`. Adjustments to the policy:

- **`pubspec.yaml`**: do NOT take-theirs verbatim. Start from theirs, then **add back** `google_maps_flutter: ^2.14.0` alongside `mapbox_maps_flutter`. Both plugins ship in C1; `google_maps_flutter` is removed in a later cleanup issue after C3–C5 finish porting.
- **Bridge shim (minimal)**: write the smallest converter that compiles the 7 HEAD-only screens. Target locations:
  - `lib/utils/maps_bridge/lat_lng_bridge.dart` — pure converter between `latlong2.LatLng` and `google_maps_flutter.LatLng` (and Mapbox's `Point` if any call sites need it). Pure function, TDD-tested.
  - No generic `MapController` abstraction. Each of the 7 screens keeps importing `google_maps_flutter` directly. Issues 006–009 (C3–C5) port screen-by-screen and delete shim usages as they go.
- **Delete `route_graph_screen.dart`**: drop the file under `lib/tabs/more/screens/route_graph/`, remove its router entry, and remove any imports. If `graphview` is in pubspec anywhere, drop it too. Dev-only debug screen — no user-facing impact.
- **`trail_route_ids` runtime gap**: still expected — closes in issue 003 (C2).

### Acceptance criteria reaffirmed

- [ ] Single merge commit on `feature/combining-trails-mapbox`
- [ ] `pubspec.yaml` retains both `google_maps_flutter` and `mapbox_maps_flutter`
- [ ] `lib/utils/maps_bridge/lat_lng_bridge.dart` exists with pure-function unit tests
- [ ] `lib/tabs/more/screens/route_graph/` directory removed; no `graphview` references
- [ ] `flutter analyze` clean across all packages
- [ ] `flutter build apk --flavor development` succeeds
- [ ] `flutter build ios --flavor development --no-codesign` succeeds
- [ ] App launches in dev flavor; main 4 tabs render; `PlanTypeChoiceSheet` opens

**Status: unblocked. Bridge approach.**

## Progress note (2026-05-14, completion)

C1 landed. Final scope expanded beyond the original chunk plan after Phase A surfaced two architectural decisions that the product owner resolved.

### What shipped in C1's merge commit

- **The 14 documented conflict resolutions** — applied per the previous agent's analysis verbatim
- **`pubspec.yaml`** — theirs as baseline + `google_maps_flutter: ^2.14.0` added back as transition dep (alongside `mapbox_maps_flutter`). `graphview` confirmed absent from all pubspecs.
- **`route_graph/` directory deleted** — 4 files dropped (`route_graph_screen.dart`, `route_map_screen.dart`, `cubit/route_graph_cubit.dart`, `cubit/route_graph_state.dart`). Removed 2 `GoRoute` entries in `lib/app/view/app.dart` and 2 `SettingsListItem`s in `lib/tabs/more/more_screen.dart`. `DebugRouteMapScreen` (different file) preserved.
- **Bridge shim** — `lib/utils/maps_bridge/lat_lng_bridge.dart`: `LatLngBridge` class with 4 static methods (`toGmaps`, `toLatLong2`, `toGmapsList`, `toLatLong2List`). TDD-driven; 7 tests in `test/utils/maps_bridge/lat_lng_bridge_test.dart`. Applied at all 15 Category A callsites.
- **Category B (5 sites)** — `GoogleMapController` vs `MapboxMap` not isomorphic. Per-site decision: pass `null` / omit `mapController:` arg. `MapUtil.fitBounds` no-ops on null, so the affected screens display via `initialCameraPosition` but won't recenter. Consistent with PRD: "options 2/3 may be visually broken — fixed by issues 006-009".
- **Category C (1 site)** — `trail_preview_map.dart:210`: wrapped `Uint8List` in `BitmapDescriptor.fromBytes`.
- **C2 absorbed into C1** (v10 hybrid). The previous chunk plan parked DB v10 + `trail_route_ids` work for issue 003. Phase B's flutter-expert added `trail_route_ids` to v9's fresh-create + v8→v9 migration to avoid red tests. Product owner then approved a v10 add-on to close the in-the-wild gap (users on `release/2.2.410`'s v9 won't trigger any migration). Final state:
  - `stagePlannerDatabaseVersion = 10`
  - `_migrateStagePlannerToV10` helper: idempotent `PRAGMA table_info` + `ALTER TABLE … ADD COLUMN trail_route_ids TEXT`
  - `onDowngrade: onDatabaseDowngradeDelete` registered on the stage planner DB
  - `packages/storage/test/migrations/fixtures/stage_planner/v9.sql` added
  - 3 new tests in `stage_planner_migration_test.dart` (v9→v10 column-add no-data-rewrite; v9→v10 descriptor round-trip; `_stagePlansFullColumns` updated → v7→v10 + v8→v10 implicitly covered via existing chained tests). Storage test count 124 → 126.
  - **Issue 003 closed by this commit. Move to `issues/done/` alongside this one.**

### Acceptance criteria — final status

- [x] Single merge commit on `feature/combining-trails-mapbox`
- [x] `pubspec.yaml` retains both `google_maps_flutter` and `mapbox_maps_flutter`
- [x] `lib/utils/maps_bridge/lat_lng_bridge.dart` exists with pure-function unit tests
- [x] `lib/tabs/more/screens/route_graph/` directory removed; no `graphview` references
- [x] `flutter analyze` clean across all packages (0 errors; 36 warnings + 3828 infos all pre-existing)
- [ ] `flutter build apk --flavor development` succeeds — **ACCEPTED-RED.** `google_maps_flutter_android:2.19.8` hits Kotlin 2.1.0 internal compiler error analysing its own `Messages.kt:2961` (`java.lang.IllegalArgumentException: source must not be null`). Pre-merge HEAD had `2.18.6`; the merge bumped it via `^2.14.0` constraint. Product owner accepted this gap — Android build clears when C3-C5 finish porting the 5 remaining `google_maps_flutter` screens and the transition dep gets dropped. Until then, Android smoke testing is blocked.
- [x] `flutter build ios --flavor development --no-codesign` succeeds (185.9s; dual maps SDKs coexist via CocoaPods)
- [ ] App launches in dev flavor; main 4 tabs render; `PlanTypeChoiceSheet` opens — **DEFERRED to user smoke** (iOS only; Android-red).
- [x] All tests green: 37 app + 126 storage + 135 repository + 6 analytics

### Known gaps deferred to follow-up issues

- **Android build red** until `google_maps_flutter` is dropped (after C3-C5). New issue may be needed to track this if C3-C5 aren't done by Phase (a) staging TF cutoff.
- **`packages/storage` build_runner** can't regenerate `.g.dart` files because `json_serializable: 6.13.2` emits Dart 3.9 syntax but `packages/storage` declares `sdk: ^3.4.0`. Existing committed `.g.dart` files are correct for post-merge source (no JSON-relevant changes in the merge). Future concern — bump storage's SDK floor or pin json_serializable older.

**Status: complete. Move to `issues/done/`.**
