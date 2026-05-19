## Parent PRD

`issues/prd.md`

## What to build

Unit tests for `TrailBuilderCubit`. Per parent PRD section "Testing Decisions / Modules with mandatory tests".

Follow the cubit-testing pattern documented in the project's `cubit-testing.md` memory file (uses `bloc_test`, `mocktail`, no mocks at the DB boundary).

Cover the state machine transitions:
- Happy path: initial state → route picked → first junction decision → next junction (or finalized) → trail finalized → `MultiRouteTrail` returned
- Undo from any junction step: each decision can be reversed; state restored to prior snapshot
- No-junction-found case: starting route has no junctions → trail builder closes / falls back gracefully
- Network failure mid-flow: route/city fetch fails → error state surfaced; existing decisions preserved
- Decision stack snapshot/restore: `_DecisionSnapshot` stack behaves correctly under interleaved make/undo

Test file location: `test/tabs/plan/screens/trail_builder/cubit/trail_builder_cubit_test.dart` (mirror the source layout).

## Acceptance criteria

- [x] Test file exists at the mirrored source location
- [x] Happy path covered
- [x] Undo at each junction step covered
- [x] No-junction-found case covered
- [x] Network failure mid-flow covered
- [x] Decision stack semantics covered (make → undo → make sequence)
- [x] All tests pass
- [x] `flutter analyze` clean
- [x] Test follows `cubit-testing.md` patterns (no DB boundary mocking)

## Blocked by

- Blocked by `issues/007-mapbox-port-trail-builder.md`

## User stories addressed

- User story 3
- User story 20

## Progress note (2026-05-15)

Shipped despite the "Blocked by 007" header — the cubit's state machine
is independent of the screen's map library. The cubit imports
`google_maps_flutter.LatLng` only inside `getTrailRoutePoints` /
`getBranchRoutePoints` for the screen-side polyline cache. Those two
methods aren't covered by this issue's required test cases and weren't
exercised here. When 007 lands and the cubit's cache type switches to
`latlong2.LatLng`, none of these tests need to change.

### What was built

20 tests across 11 groups at
`test/tabs/plan/screens/trail_builder/cubit/trail_builder_cubit_test.dart`
covering every transition + edge case the issue called out:

- `loadRoutes` failure path (mock surface throws on Repository
  extension; cubit's try/catch surfaces `failure`).
- `selectStartingRoute` happy + failure.
- `selectStartingCity` no-junctions branch (single-segment trail,
  `trail_builder_finalized` fires).
- `selectStartingCity` with-junctions branch (presents first junction,
  no finalized event yet).
- `continueOnRoute` with more junctions (advances index, fires
  `trail_builder_junction_decision` with `decision_number = 1`).
- `continueOnRoute` no-more-junctions (finalizes with a new segment).
- `switchToRoute` no-junctions on new route (two-segment trail).
- `switchToRoute` with-junctions on new route (resets pendingJunctions,
  carries forward segments).
- `endTrailHere` (segment ends at junction city, finalized fires).
- `undoLastDecision` restores junction state + fires
  `trail_builder_undo`.
- `undoLastDecision` no-op when history empty (no emission, no event).
- After undo, re-deciding fires `decision_number = 1` again (locks in
  the "position in current chain" semantics from issue 016's commit).
- Decision-stack snapshot/restore with 3 continues → 3 undos: asserts
  each undo pops the most recent snapshot, so undoing decision 3
  restores `currentJunctionIndex = 2`, decision 2 → 1, decision 1 → 0.
- `buildTrail` returns a `MultiRouteTrail` wrapping the current
  segments (multi-route, primaryRouteId = 1).
- `reset` clears state.
- `backToRouteSelection` clears route + city selection.
- Three error-path tests: `continueOnRoute` failure mid-flow,
  `switchToRoute` failure on getJunctions, segments survive a failure
  emission after a successful prior decision.

### Mocking strategy

- `_MockJunctionService extends Mock implements JunctionService` —
  regular class, mockable directly. Stubs cover `getCitiesForRoute`,
  `getJunctionsForRoute`, `initialize`.
- `_MockRepository extends Mock implements Repository` — registered in
  GetIt but only exercised by `loadRoutes` (its only test forces the
  failure path). All other tests skip `loadRoutes` and call
  `selectStartingRoute` directly, so `state.routes = []` is fine —
  the cubit's `_lookupRoute` falls back to a placeholder RouteEntity
  per the existing `orElse:` in its source.
- `_RecordingAnalyticsService implements IAnalyticsService` — matches
  the pattern already in `plan_type_choice_sheet_test.dart`. Captures
  `eventName` + `parameters` per call so tests can assert on event
  names + payloads. Stubs `trackEvent` (the abstract method that
  `.track(AnalyticsEvent)` extension delegates to) per the
  `cubit-testing.md` caveat.
- `setUpAll(registerFallbackValue(<RouteEntity>[]))` for
  `any(named: 'allRoutes')` in the JunctionService stub matcher.
- `setUp` registers everything in GetIt; `tearDown` calls
  `GetIt.instance.reset`.

### Helper: `primeAtFirstJunction`

Reusable async helper that drives the cubit through
`selectStartingRoute(1) → selectStartingCity(10)` with caller-supplied
`junctionsAfterStart`. Sets up the default city stubs for routes 1 and
2 (overrideable via parameters). Returns the cubit at
`TrailBuilderStatus.junction`. Cuts test boilerplate by ~10 lines per
test.

### Verification

- `flutter test test/tabs/plan/screens/trail_builder/cubit/trail_builder_cubit_test.dart`
  — 20/20 pass.
- `flutter test test/` (full app suite) — 92/92 pass.
- `flutter analyze` on the new file — 0 issues.
- No regressions in app-package analyze output (all warnings
  pre-existing on other files).
