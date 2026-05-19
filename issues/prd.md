# PRD — Catch Up `feature/combining-trails` and Ship the Multi-Trail Feature

## Problem Statement

Camino Ninja's pilgrimage plans are currently tied to a single route. Real pilgrims often want to combine multiple routes into one journey — either by manually walking the junction graph or by picking start/end cities and letting the app suggest combinations. The product owner wants to put this capability in front of users and measure adoption.

Two blockers stand in the way:

1. **The branch implementing the feature is 89 commits behind the live release train.** The catch-up target is `release/2.2.410`, which is 22 commits ahead of `develop` and includes a Google Maps → Mapbox migration plus the data-loss hotfixes that have shipped during the branch's lifetime. Shipping without absorbing these would re-introduce known production regressions (orphan stages breaking FK migrations, NULL `stage_uuid` causing silent stage deletion on sync, plan data loss on upgrade).

2. **The feature has known structural gaps that need to close before user exposure.** Specifically: `trail_route_ids` is not yet in the sync request/response models (backend coordinating in parallel, 1-day ETA); the stage planner database lacks a downgrade handler; the feature has no entry-point flag gating or analytics instrumentation; and the multi-trail map screens need porting to Mapbox.

The product owner wants to ship to real users and measure adoption while keeping prod data integrity intact and retaining the ability to kill the feature quickly if it misbehaves.

## Solution

Catch the branch up to `release/2.2.410` on an isolated integration worktree, complete the structural gaps (DB v10, sync wiring, Mapbox port, feature flag, analytics), and ship via a phased rollout: internal staging TestFlight → internal prod TestFlight → App Store release with a Remote Config ramp.

Multi-trail plan creation is offered to users as two paired UX surfaces on a shared underlying capability: **Custom Trail** (advanced, manual junction-walking) and **Plan a Journey** (friendlier — start city + destination city → suggested route combinations). Both feed the same `MultiRouteTrail` model and persist via the same `trail_route_ids` column.

The catch-up work lands on the integration branch as a sequence of small reviewable chunks (C1–C8), each independently testable per the team's existing test culture (migration harness, sync integration tests via `FakeNetworkService`, cubit unit tests, pure-function tests). The Mapbox port is verified via manual smoke checklist — no widget tests for maps. When all chunks are green, a single PR lands the work on a new release branch cut from `release/2.2.410`.

Feature visibility is gated by two independent Remote Config flags (`feature_custom_trail_enabled`, `feature_journey_planner_enabled`) so each option can be ramped independently. Internal TestFlight cohorts are targeted by build-number conditions; App Store users get a 5% → 25% → 100% ramp. A multi-signal rollback runbook (crash rate, sync failure rate, support complaints) governs kill-switch decisions during the ramp.

## User Stories

1. As a pilgrim creating a new plan, I want to see three plan-type options so that I can choose between a single route, a manually-built custom trail, or a guided journey across multiple routes.
2. As a pilgrim creating a new plan, I want options 2 and 3 to be hidden in production by default so that I do not see incomplete or unstable features unless I'm in the rollout cohort.
3. As an advanced user choosing "Custom Trail", I want to walk the junction graph step by step so that I can manually compose a multi-route journey at any junction I choose.
4. As a user choosing "Plan a Journey", I want to pick a start city and a destination city so that the app can suggest available route options without me knowing about the junction graph.
5. As a user picking a destination in journey planner, I want suggested routes ranked by reachability (direct / via junction / not reachable) so that I can pick the best fit at a glance.
6. As a user reviewing route options, I want to see a draggable map preview of each suggested route so that I can visually compare them before committing.
7. As a user who created a multi-trail plan, I want my plan to round-trip through sync so that I can sign in on a second device and still see my multi-trail plan as multi-trail (not silently downgraded to single-route).
8. As a user who created a multi-trail plan during the TestFlight cohort, I want my plan to remain accessible if the operator flips the feature flag off later so that my data is not lost.
9. As an internal team member on staging TestFlight, I want the multi-trail options to always be visible so that I can dogfood the feature without Remote Config gymnastics.
10. As an internal team member on prod TestFlight, I want the options to be visible to me but not to external users so that I can test against the real prod backend without exposing the feature prematurely.
11. As a beta user installing the App Store release, I want the feature to ramp to me at 5% → 25% → 100% so that the operator can catch problems before they affect everyone.
12. As the product owner, I want to see adoption metrics (selection rate, completion rate, drop-off funnel) so that I can decide whether to ramp the rollout or kill the feature.
13. As the product owner, I want a runbook for flipping the feature off so that I can stop a regression within minutes of detecting it.
14. As an existing user upgrading from an older version, I want my plans to survive the DB migration so that I do not lose data.
15. As a user on a device that ends up running an older app version (e.g., TestFlight sideload or downgrade), I want the app to open without crashing so that I can continue using it even if my local data resets.
16. As a developer switching between branches, I want the DB to handle downgrades cleanly so that switching from this branch back to `release/2.2.410` does not require manually wiping data.
17. As a developer reviewing the catch-up work, I want the integration to land as a sequence of small reviewable chunks so that I can audit each step instead of reviewing one mega-PR.
18. As a developer running the test suite, I want every DB migration path covered by fixture-based tests so that I have confidence migrations are idempotent and lossless.
19. As a developer running the test suite, I want sync paths covered by integration tests against a fake network service so that sync regressions are caught before they reach prod.
20. As a developer changing a cubit's state machine, I want unit tests for the cubit's happy path and edge cases so that I know I haven't broken the state transitions.
21. As a developer touching the path-finding logic, I want pure-function tests for `RoutePathFinder` and `JunctionService` against fixture route graphs so that I can refactor with confidence.
22. As an operator reviewing analytics, I want a clean funnel from `plan_type_choice_shown` through `plan_type_choice_selected` through per-flow step events through `CreatePlanEvent` so that I can see exactly where users drop off.
23. As an operator monitoring sync health, I want explicit `multi_trail_plan_sync_success` and `_failed` events so that I can detect backend regressions without parsing generic sync events.
24. As an operator reviewing adoption, I want `feature_flag_exposure` events keyed to the flag name and value so that I can reconcile "users in cohort × users who saw it × users who tried it."
25. As an operator flipping the kill switch, I want any one of three triggers (crash rate, sync failure rate, support complaints) to justify flipping so that I am not waiting on a single signal that may be delayed.
26. As an operator flipping the kill switch, I want a two-person authority model with a designated channel-post protocol so that the team has redundancy without flip-flopping conflict.
27. As an operator post-flip, I want a 30-minute investigation window with a clear decision rule (flag-stays-off vs. hotfix) so that the team knows whether a code release is required.
28. As a user signing in on a new device after backend lands the sync API change, I want my multi-trail plans to come back complete so that the cross-device experience matches single-route plans.

## Implementation Decisions

### Strategic

- **Target branch for catch-up is `release/2.2.410`, not `develop`.** Release/2.2.410 is 22 commits ahead of develop, is a strict superset, and contains the Mapbox migration plus all data-loss hotfixes. Shipping to develop directly would re-introduce known regressions.
- **Mapbox migration is mandatory scope.** Roughly 7 multi-trail map files (the journey planner map, trail preview map, trail builder maps, stage map, embedded stage map, route map explorer) need porting from `google_maps_flutter` to `mapbox_maps_flutter ^2.4.0`. The remaining ~23 map-using files are inherited via the merge already ported.
- **Ship sequence is three phases, in order**:
  - **Phase (a) Staging TestFlight** — internal team only, on the `camino-ninja-dev` Firebase project. Flavor-gated visibility (no Remote Config). Goal: dogfood + smoke test against dev backend.
  - **Phase (b) Prod TestFlight** — internal team only, on prod Firebase. Remote Config gated, with build-number condition targeting the internal TF cohort. Goal: validate behavior against real prod infrastructure (analytics pipeline, real backend, real Firebase).
  - **Phase (c) App Store release** — external (beta and general) users, Remote Config gated. Default off, ramp to 5% → 25% → 100% based on adoption signal and health metrics. Goal: gather real adoption data.
- **Backend coordinates `trail_route_ids` sync support in parallel** with a 1-day ETA. Client work begins immediately and absorbs the sync wiring (chunk C8) when backend is ready. Hard checkpoint before phase (b): backend round-trip confirmed via curl/Postman.

### Branch and worktree

- **Integration worktree**: `.claude/worktrees/combining-trails-mapbox`, branched from `feature/combining-trails`.
- **Branch memory file**: `branches/feature-combining-trails-mapbox.md` tracks chunk progress.
- **Final PR**: integration branch → newly cut release branch (e.g., `release/2.2.411`), one PR at the end.

### Merge strategy

- **Atomic merge of `origin/release/2.2.410` into the integration branch** as the first chunk (C1). No staged sub-merges and no cherry-picking. The storage package restructure (file splits + helper-function migrations) forces atomicity — partial application would leave a broken state.
- **Per-category conflict resolution policy**:
  - Generated files (`*.pb.dart`, `*.pbjson.dart`, `*.g.dart`, `*.freezed.dart`): never hand-merge. Regenerate after source conflicts resolve.
  - Storage restructure (`stage_planner_database.dart` and friends): accept release/2.2.410's structure. Adopt the file split and the top-level migration helper functions. Drop this branch's defensive `stage_uuid` backfill — release/2.2.410's v9 handles it correctly. Park the `trail_route_ids` migration work for chunk C2.
  - Map widgets (`embedded_stage_map.dart`, `stage_map_screen.dart`): take release/2.2.410's Mapbox port verbatim during C1. Trail-rendering logic comes back in chunks C3–C5 implemented against Mapbox APIs.
  - Plan cubits/screens (8 files): merge intent — read both sides and synthesize. Their changes are sync/UUID/stage-number related; this branch's are trail_route_ids and 3-option related. Both must land.
  - `main_staging.dart`: merge intent. Both the dev-Firebase reroute and the Mapbox SDK init apply.
  - Pubspec / lockfiles: take theirs (Mapbox + their version bumps).
  - ARB localization: union the keys. Same-key conflicts resolve in favor of release/2.2.410 unless this branch's wording is known to be correct.
- **Escalation rule (critical)**: if a conflict's semantic intent is ambiguous — both sides changed the same line in semantically different ways — stop and escalate to the product owner. Do not guess.
- **C1 acceptance criteria**: all tests that pass on `release/2.2.410` still pass; `flutter analyze` clean across all packages; builds succeed for dev flavor (Android + iOS no-codesign); app launches in dev flavor and main 4 tabs render. Options 2 and 3 may be visually broken post-C1 (Mapbox port pending in C3–C5) — that's expected.

### Chunk plan

Eight chunks land on the integration branch in this order:

1. **C1 — Atomic merge of `origin/release/2.2.410`.** Single commit with conflict resolutions per the policy above. Includes regenerated proto/JSON-serializable output.
2. **C2 — DB v10 migration + downgrade handler + tests.** Adds `_migrateStagePlannerToV10` helper (idempotent `ALTER TABLE stage_plans ADD COLUMN trail_route_ids TEXT`). Registers `onDowngrade: onDatabaseDowngradeDelete` on the stage planner database (matching the app database pattern). Adds `v9.sql` fixture and migration tests for `v7→v10`, `v8→v10`, `v9→v10`. Regression test exercises a real multi-stage `MultiRouteTrail` plan through the migration.
3. **C8 — Sync wiring for `trail_route_ids`.** Adds field to `SyncPlanRequest` and `SyncPlanResponse` (nullable string). Wires push and pull paths in `stage_plan_repository`. Adds round-trip integration test via `FakeNetworkService`. Requires backend confirmation (curl/Postman round-trip) before merge.
4. **C3 — Mapbox port: stage planner core map screens.** Port `stage_map_screen.dart`, `add_edit_stage/widgets/stage_map.dart`, and any directly dependent components. Manual smoke checklist: load, pan, zoom, marker tap, polyline render, satellite toggle if applicable.
5. **C4 — Mapbox port: trail builder.** Port `trail_builder_screen.dart`, `trail_preview_map.dart`, `embedded_stage_map.dart`. Trail-rendering logic re-implemented against Mapbox APIs.
6. **C5 — Mapbox port: journey planner and explorer.** Port `journey_planner_screen.dart` map preview and `route_map_screen.dart` (dev-only explorer).
7. **C6 — Cubit unit tests.** Tests for `TrailBuilderCubit` and `JourneyPlannerCubit` covering happy path + key state-machine edge cases (no city selected, no junction found, network failure mid-flow, undo). Follows the cubit-testing pattern documented in `cubit-testing.md`.
8. **C7 — Feature flag wiring + analytics events + flag-gating tests.** Extends `FirebaseConfigDataSource` with two getters. Adds `PlanTypeVisibility` resolver (pure function). Wires gate in `PlanTypeChoiceSheet`. Adds funnel analytics events. Adds tests for visibility resolver under flag/flavor combinations and for analytics event property correctness.

Each chunk is reviewed by the code-reviewer agent before the next chunk starts.

### Database

- **Schema**: `stage_plans.trail_route_ids TEXT` (nullable). String encoding parsed by `MultiRouteTrail.parseDescriptors`. NULL for single-route plans.
- **Migration body**: `_migrateStagePlannerToV10` checks `PRAGMA table_info(stage_plans)` and adds the column only if missing. Idempotent — safe for users coming from this branch's pre-merge v9 (column exists, no-op) and from release/2.2.410's v9 (column missing, added).
- **No backfill**: existing single-route plans keep NULL `trail_route_ids`. `MultiRouteTrail.parseDescriptors` handles NULL gracefully.
- **No index**: the column is never used as a query filter, only read per-plan.
- **Downgrade handler**: `onDowngrade: onDatabaseDowngradeDelete` registered on the stage planner database. A v10 → v9 downgrade resets the stage planner DB cleanly; user loses local data but app does not crash. Acceptable cost — only affects TestFlight sideload and developer branch-switching.

### Sync API contract (to confirm with backend before C8)

- Field name: `trail_route_ids`
- Type: nullable string
- Behavior on POST: server persists as-is (opaque string)
- Behavior on GET: server returns as-is
- Validation: backend allows the field (does not reject as unknown property)
- Backward compatibility: additive change; older clients without the field continue to work unchanged

### Feature flag design

- **Two independent flags**: `feature_custom_trail_enabled` and `feature_journey_planner_enabled`. Allows independent ramping; Plan a Journey can ramp faster than Custom Trail.
- **Hybrid flavor + Remote Config**:
  - Dev + staging flavors: always visible (hard flavor gate, no Remote Config read).
  - Prod flavor: gated by Remote Config. In-app default `false`. If Remote Config fetch fails, in-app default applies — options stay hidden (safe-by-default).
- **Gate location**: `PlanTypeChoiceSheet` build, via a pure `PlanTypeVisibility` resolver function — `(PlanType, {Flavor, FirebaseConfigDataSource}) → bool`. Extracting to a pure function makes the gate logic testable without widget tests.
- **Data behavior under flag-off**: gate hides the entry point only. Existing multi-trail plans continue to load, render, edit, and sync. Sync continues to carry `trail_route_ids` regardless of flag state. A user whose plan was created during a flag-on window does not lose access if the flag flips off.

### Cohort targeting via Remote Config

- **Internal TF cohort**: Remote Config condition keyed to build-number range (`app.build IN [internal TF range]` → `true`). Internal team is the audience for phases (a) and (b).
- **App Store ramp**: Remote Config condition keyed to App Store build number with a `random_percent` rule. Starts at 5%, ramps to 25%, ramps to 100% based on health and adoption signals.
- **Optional backup**: user-property condition keyed to `user_email_domain == 'caminounlimited.com'` for internal team members who install App Store builds after ramp begins.

### Analytics

- **Existing events extended**: `CreatePlanEvent` gains `plan_type` (`single_route` / `custom_trail` / `journey`) and `trail_route_count` (`1` for single, `2+` for multi) properties.
- **New funnel events**:
  - `plan_type_choice_shown` — fires when `PlanTypeChoiceSheet` opens
  - `plan_type_choice_selected` — fires when user taps an option; carries `plan_type`
  - `journey_planner_start_city_selected` — funnel step 1 (journey)
  - `journey_planner_destination_selected` — funnel step 2 (journey)
  - `journey_planner_route_option_selected` — funnel step 3 (journey); carries `option_type` (`direct` / `via_junction` / `multi_trail`) and `position_index`
  - `trail_builder_junction_decision` — funnel step (custom trail); carries `decision_number`
  - `trail_builder_undo` — friction signal
  - `trail_builder_finalized` — terminal success (custom trail)
  - `multi_trail_plan_sync_success` and `multi_trail_plan_sync_failed` — sync health (post-C8)
  - `feature_flag_exposure` — fires once per session per flag read; carries `flag_name` and `flag_value`
- **Dashboard**: primary view in Amplitude (team just invested in it with 68+ typed events); Firebase Analytics as fallback for cohort filtering.

### Rollback runbook

- **Triggers (any one justifies flipping the relevant flag off)**:
  - Crash-free rate for `TrailBuilderScreen` or `JourneyPlannerScreen` drops below 99% over a 1-hour window with ≥100 sessions
  - `multi_trail_plan_sync_failed` count exceeds 1% of `multi_trail_plan_sync_success` over a 1-hour window
  - Three or more unique user complaints referencing the feature within a 24-hour window
- **Authority**: two-person quorum. Product owner + 1–2 designated teammates with Remote Config access. Flip-first protocol — post to the designated channel with which flag, which trigger, and the raw numbers.
- **Time target**: under 5 minutes from trigger detection to flag flipped.
- **Post-flip**: 30-minute investigation window. If flag flip stopped the bleeding and no existing user data is broken, the flag stays off until the next planned release ships the fix. If existing user data is in a broken state or the flag flip did not help, cut a hotfix release on the existing release branch.

### Adoption KPIs

- **Phase (a) Staging TF success**: no crashes, no migration failures, no sync errors. Internal team uses both options to completion at least three times each. Watch ~1 week.
- **Phase (b) Prod TF success**: same as (a) but against prod infrastructure. Confirms backend round-trip, analytics pipeline, real Firebase. Watch ~1 week. Not an adoption signal — cohort is internal only.
- **Phase (c) App Store ramp success at each level**: `plan_type_choice_selected` non-single rate ≥ 5% of sessions that opened the sheet; crash-free rate ≥ 99.5%; multi-trail plan sync round-trip success ≥ 95%. Ramp progression: 5% → 25% → 100% with ~1 week per level.

## Testing Decisions

**What makes a good test**: tests external behavior, not implementation details. A test should pass before and after a refactor that does not change the observable behavior. Mocks are reserved for the boundaries (network, time); internal code paths use real implementations or fakes that share the production interface (e.g., `FakeNetworkService`).

**Modules with mandatory tests** (per the test matrix locked in during the grilling session):

- **`_migrateStagePlannerToV10`** — fixture-based migration test via `migration_test_harness`. Covers `v7 → v10`, `v8 → v10`, `v9 → v10`. New `v9.sql` fixture captures release/2.2.410's post-`stage_uuid`-backfill state. Regression test exercises a real multi-stage plan through the migration to assert no data loss. Prior art: `packages/storage/test/migrations/stage_planner_migration_test.dart`.
- **`MultiRouteTrail` / `parseDescriptors` codec** — pure-function tests for serialization round-trip and malformed input handling. Prior art: `packages/storage/test/models/stage_plan_entity_test.dart` for the entity-test pattern.
- **`RoutePathFinder`** — pure-function tests against fixture route graphs. Covers direct path, via-junction path, multi-trail combinations, no-path case. Edge cases: cycle handling, forward-only filtering, position-aware reachability.
- **`JunctionService` / `RouteGraph` builder** — pure-function tests for graph construction from fixture route data. Covers junction identification, touching-point distance filtering (the existing `default 1 km` filter and runtime slider behavior).
- **`stage_plan_repository` sync wiring for `trail_route_ids`** — integration test via `FakeNetworkService`. Round-trips a multi-trail plan through push + pull and asserts `trail_route_ids` survives. Covers conflict resolution semantics consistent with the existing `stage_plan_sync_test.dart` (device-that-pushed wins). Prior art: `packages/repository/test/integration/stage_plan_sync_test.dart`.
- **`TrailBuilderCubit`** — cubit unit tests covering: happy path (route picked → junction decision → trail finalized), undo from any junction step, no-junction-found state, network failure mid-flow. Prior art: the existing one cubit test in `test/` plus the pattern documented in the project's `cubit-testing.md` memory.
- **`JourneyPlannerCubit`** — cubit unit tests covering: happy path (start city → destination → route option → trail returned), no destinations reachable from start city, lazy polyline loading for option beyond top-10, journey-touching-point distance filter slider state.
- **`PlanTypeVisibility` resolver** — pure-function tests over the matrix of `(PlanType, Flavor, RemoteConfig flag state)` combinations. Asserts dev/staging always visible; prod gated by flag; correct fallback when Remote Config fetch fails. Trivial test — ~10 cases.
- **Analytics event correctness** — unit tests asserting each new event class emits the expected name and properties. Prior art: `packages/analytics_services/test/events/plan_events_test.dart`.

**Modules verified by manual smoke test only**:

- **Mapbox-ported map widgets** (chunks C3–C5). No widget tests or golden tests — the codebase has no precedent for these. Each ported screen has a documented smoke checklist (load, pan, zoom, marker tap, polyline render, satellite toggle if applicable). Smoke verification is required before chunk acceptance.

**CI gate**: every chunk's PR runs the full test suite. Promotion to phase (a) staging TestFlight requires all tests green plus all smoke checklists complete.

## Out of Scope

- **Building the multi-trail feature's core logic.** `RoutePathFinder`, `JunctionService`, `MultiRouteTrail`, `RouteGraph`, the trail builder UI, and the journey planner UI all already exist on this branch. This PRD is about catch-up and integration, not building.
- **Backend implementation of `trail_route_ids` sync.** Backend team owns the API endpoint changes; this PRD owns the client-side wiring against the agreed contract. The 1-day backend ETA is an assumed input.
- **Widget tests, golden tests, or end-to-end integration tests for map rendering.** The team has not invested in these patterns; introducing them is a separate workstream and would expand scope significantly.
- **Server-side validation of `trail_route_ids` content.** The server treats the field as an opaque string; client is the only consumer of the descriptor format.
- **Renaming the feature labels.** Current labels ("Custom Trail", "Plan a Journey") and Beta badge are accepted as-is. Polish deferred.
- **Multi-trail support in plan sharing / QR import.** The plan-sharing service was audited and currently drops `trail_route_ids` on share. This is an acknowledged limitation — multi-trail plans are not shareable in v1. A future iteration can add this once adoption justifies the investment.
- **Onboarding or in-app explainer for the new options.** Treated as a follow-up if adoption signal at phase (c) is positive.
- **Cross-device sync verification at phase (a) staging TF.** Backend coordination targets phase (b) for cross-device working state. Phase (a) is local-only by design.
- **Backfill of `trail_route_ids` for existing single-route plans.** They stay NULL. The data model treats NULL as "not multi-trail."
- **Index on `trail_route_ids`.** Not used as a query filter.

## Further Notes

- **Branch already renamed**: `worktree-route-graph-minimal` → `feature/combining-trails` on 2026-05-14. Old remote ref deleted. Branch memory updated.
- **Release CI is currently broken** — open PR #383 ("chore(ci): fix broken release pipeline + add PR-level check") has been open since 2026-05-05. This PR must land before the catch-up integration PR can ship via the standard pipeline.
- **Release/2.2.410 stability caveat**: the Mapbox migration was merged into `release/2.2.410` on 2026-05-14 (hours before this PRD was written). It has not yet been TestFlight-baked. Expect to absorb Mapbox stability fixes during the integration work. The release/2.2.410 base is structurally healthy (deliberate review cycle, no abandoned hotfix forks) but the merged Mapbox surface is fresh.
- **DB version collision pre-merge**: this branch and release/2.2.410 both currently sit at stage planner DB version 9 with semantically different contents. The merge resolves this by adopting release/2.2.410's v9 structure and adding v10 for the column this branch needed. A user already on release/2.2.410's v9 in the wild would otherwise have skipped this branch's v9 work entirely (no migration runs for same-version) — silent feature failure. C2 closes this gap.
- **Conflict surface measured**: 27 files modified on both branches; 12 with content-level conflicts after auto-merge. Resolves into 4 conflict clusters (storage, map widgets, plan cubits/screens, startup) plus the regenerated generated-file group.
- **Hand-off**: after this PRD is broken into issues (via `/prd-to-issues` or equivalent), each chunk becomes one or more issues that agents can grab. The chunk ordering (C1 → C2 → C8 → C3 → C4 → C5 → C6 → C7) is load-bearing — C8 cannot start before backend confirms; C3–C5 cannot start cleanly before C1 lands; C6/C7 can parallel each other after C1.
- **Branch memory follow-up**: once the integration worktree is set up, the integration branch's memory file (`branches/feature-combining-trails-mapbox.md`) should reference this PRD as the source-of-truth design doc. The `feature/combining-trails` branch memory should be updated with a pointer to the integration branch.

## Progress note (2026-05-14) — C1 + C2 outcomes

C1 landed as a single merge commit (`3be26bc8`) along with C2 absorbed. The PRD's original chunk plan deviated based on two product-owner architectural decisions made during C1. The full decision record is in `issues/done/002-atomic-merge-release-2-2-410.md` (sections "Progress note (2026-05-14, decision)" and "Progress note (2026-05-14, completion)").

### Updated chunk plan (effective after C1's commit)

The original ordering `C1 → C2 → C8 → C3 → C4 → C5 → C6 → C7` is superseded by:

1. **C1 + C2 — DONE** (merge commit `3be26bc8`). Issues 002 + 003 closed.
2. **C8 — Sync wiring** (issue 005). Still blocked on backend ETA.
3. **C3 — Stage planner core maps** (issue 006). NOTE: `stage_map_screen.dart` was take-theirs in C1 — already on Mapbox. Scope reduced to verification + remaining file. See issue's migration note.
4. **C4 — Trail builder maps** (issue 007). NOTE: `embedded_stage_map.dart` was take-theirs — already on Mapbox. Scope reduced to `trail_builder_screen.dart` + `trail_preview_map.dart`.
5. **C4 part 2 — Journey planner map** (issue 008).
6. **~~C5 — Route map explorer~~ OBSOLETE** (issue 009 obsolete — `route_map_screen.dart` deleted in C1 along with the rest of `lib/tabs/more/screens/route_graph/`).
7. **NEW: Cleanup chunk** (issue 026). Port the 2 dev-only screens that weren't in the original PRD port list (`debug_route_map_screen.dart`, `route_city_overview_screen.dart`) + `trail_builder_cubit.dart` Polyline points. Drop `google_maps_flutter` from `pubspec.yaml`. Delete `lib/utils/maps_bridge/` shim. Restore Android build. Blocked by 006-008.
8. **C6 + C7 — Cubit tests + flag/analytics** (issues 012-018). Can parallel after C1.

### Updated decisions

- **Transition dep approach**: `pubspec.yaml` now carries BOTH `google_maps_flutter: ^2.14.0` AND `mapbox_maps_flutter ^2.4.0` until issue 026 lands. The bridge shim `LatLngBridge` at `lib/utils/maps_bridge/lat_lng_bridge.dart` mediates `latlong2.LatLng ↔ google_maps_flutter.LatLng` conversions for the 6 screens still on Google Maps. The `MapboxMap` ↔ `GoogleMapController` boundary is NOT shimmed (not isomorphic); the 5 affected callsites pass `null` to map utilities (null-guarded), accepting visually-broken-until-cleanup behavior per existing PRD allowance.
- **Android build red until issue 026**: `google_maps_flutter_android:2.19.8` triggers a Kotlin 2.1.0 internal compiler error. Android smoke testing is blocked until the transition dep is dropped. Workaround if needed before then: `dependency_overrides: google_maps_flutter_android: 2.18.6` in pubspec. iOS builds fine throughout.
- **`packages/storage` build_runner is broken**: `json_serializable: 6.13.2` emits Dart 3.9 syntax but `packages/storage` declares `sdk: ^3.4.0`. Existing committed `.g.dart` files remain correct for post-merge source. Future fix: bump storage SDK floor or pin `json_serializable` older. Not blocking any chunk.
- **C2 silent-feature-failure gap is closed**: v10 migration with idempotent `ALTER TABLE … ADD COLUMN trail_route_ids TEXT` ensures users on `release/2.2.410`'s v9 in the wild get the column on next upgrade. Belt-and-braces also keeps `trail_route_ids` in v9 fresh-create + v8→v9 migration so the merge-time storage tests pass.

### Inventory of files still on `google_maps_flutter` after C1

For planning each remaining port issue, these 6 files import `google_maps_flutter` and use the `LatLngBridge` shim:

| File | Shim sites | `null` mapController sites | Covered by issue |
|------|-----------|---------------------------|------------------|
| `lib/tabs/plan/screens/journey_planner/journey_planner_screen.dart` | :837, :853 | :836, :853 | 008 |
| `lib/tabs/plan/screens/trail_builder/trail_builder_screen.dart` | :117, :169, :1226 | — | 007 |
| `lib/tabs/plan/screens/trail_builder/widgets/trail_preview_map.dart` | :294, :301 + BitmapDescriptor.fromBytes at :210 | :293, :301 | 007 |
| `lib/tabs/plan/screens/trail_builder/cubit/trail_builder_cubit.dart` | :470, :502 | — | 026 (cubit logic, not screen) |
| `lib/tabs/more/screens/debug_route_map/debug_route_map_screen.dart` | :158 | :105 | 026 (dev-only, not in original PRD) |
| `lib/tabs/more/screens/route_city_overview/route_city_overview_screen.dart` | :700, :760, :722 | :721 | 026 (dev-only, not in original PRD) |

Line numbers reflect post-C1 state; expect modest drift as ports proceed.
