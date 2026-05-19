## Parent PRD

`issues/prd.md`

## What to build

Add journey planner funnel analytics events. Per parent PRD section "Analytics".

In `packages/analytics_services/lib/src/events/plan_events.dart` (or a new file if cleaner):
- `JourneyPlannerStartCitySelectedEvent` — property `city_id`; event name `journey_planner_start_city_selected`
- `JourneyPlannerDestinationSelectedEvent` — property `city_id`; event name `journey_planner_destination_selected`
- `JourneyPlannerRouteOptionSelectedEvent` — properties `option_type` (`direct` | `via_junction` | `multi_trail`) and `position_index`; event name `journey_planner_route_option_selected`

Wire from `JourneyPlannerCubit` state transitions. Each event fires exactly once per occurrence.

Unit tests for event properties matching existing `plan_events_test.dart` pattern.

## Acceptance criteria

- [ ] Three new event classes with correct names + properties
- [ ] Events fire from `JourneyPlannerCubit` at the right state transitions
- [ ] `option_type` correctly maps from the underlying reachability classification
- [ ] `position_index` reflects the rank of the chosen option in the displayed list
- [ ] Unit tests added and pass
- [ ] Events visible in Firebase Analytics DebugView and Amplitude debug stream

## Blocked by

- Blocked by `issues/008-mapbox-port-journey-planner.md`

## User stories addressed

- User story 12
- User story 22

## Progress note (2026-05-14)

Implementation shipped. Done despite the "Blocked by 008" note, matching
the precedent from issues 014 (plan-creation events), 016 (trail builder
funnel), and 017 (sync health + flag exposure) — the cubit and the events
are independent of the Mapbox port; only the screen widget is gated by 008.

Changes:

1. Three new event classes in `packages/analytics_services/lib/src/events/
   plan_events.dart`, placed adjacent to the `TrailBuilder*` events:
   - `JourneyPlannerStartCitySelectedEvent` ("journey_planner_start_city_
     selected", property `city_id`)
   - `JourneyPlannerDestinationSelectedEvent` ("journey_planner_destination_
     selected", property `city_id`)
   - `JourneyPlannerRouteOptionSelectedEvent` ("journey_planner_route_
     option_selected", properties `option_type` + `position_index`)

2. Cubit wiring in `lib/tabs/plan/screens/journey_planner/cubit/
   journey_planner_cubit.dart`:
   - New `_analytics` field via GetIt, matching the pattern in
     `trail_builder_cubit.dart` and `add_edit_stage_cubit.dart`.
   - Start city event fires at the very top of `selectStartCity`, before
     any state changes, so it tracks every user pick — including ones
     where reachability computation fails partway.
   - Destination event fires at the top of `selectDestinationCity`,
     before the `loadingRoutes` transition.
   - Route option event fires at the top of `buildTrailFromOption`,
     before the segment-build work. This is the terminal commit step
     (called from the screen at line 149).
   - New private `_optionTypeFor(JourneyOption)` helper that derives
     the analytics vocabulary (`direct`/`via_junction`/`multi_trail`)
     from `option.path.junctionCount` (0/1/2+). Keeps the mapping in
     one place — the BFS that built the path already encodes
     reachability via junction count.
   - `position_index` is derived from `state.journeyOptions.indexOf
     (option)` — 0-based index in the displayed list. The screen
     orders the list by display rank so the index matches the user's
     visual position.

3. Tests in `packages/analytics_services/test/events/plan_events_test.
   dart`: 10 new cases covering all three event names + property
   verbatim checks + value round-trips (city ids, option types,
   position indices).

Decisions:

- Events placed in `plan_events.dart` (not a new file). Consistent with
  issue 016's reasoning — the journey planner funnel is one branch of
  the plan-creation flow.
- `_optionTypeFor` kept private in the cubit rather than promoted to a
  `JourneyOptionAnalytics` extension on `JourneyOption`. The vocabulary
  is analytics-specific and the mapping only has one consumer right
  now. If a second consumer appears, promote it then.
- `_analytics.track(...)` fires before the `try` block in each method,
  matching the issue's "fires exactly once per occurrence" criterion
  — even when the subsequent logic throws, the event is still emitted.
  Trade-off: a thrown event still counts as "selected", but the funnel
  also has step counters (failures show up as drop-off between selected
  and the next step), so this is the right side of the trade.
- Cubit-level firing tests (assert events fire at the right transitions
  via mocktail/bloc_test) deferred to issue 013 (JourneyPlannerCubit
  unit tests), matching the pattern from commits 014/016/017.

Verification:
- `packages/analytics_services` flutter test — 42/42 pass (10 new + 32
  pre-existing).
- `flutter test test/` — 72/72 pass (no regressions).
- `flutter analyze` on changed files — 0 new issues. The 5 reported
  items are pre-existing infos on unchanged lines.

Acceptance criteria status:
All criteria met except the last (Firebase Analytics DebugView +
Amplitude debug stream visibility) — manual / HITL verification
deferred to phase (a) device smoke testing.

Unblocks issue 020 (adoption metrics dashboard — all four event
families it reads are now shipped: plan-creation, trail builder funnel,
sync health + flag exposure, and now journey planner funnel).
