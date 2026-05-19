## Parent PRD

`issues/prd.md`

## What to build

Add the plan-creation analytics events and extend the existing `CreatePlanEvent`. Per parent PRD section "Analytics".

In `packages/analytics_services/lib/src/events/plan_events.dart`:
- New `PlanTypeChoiceShownEvent` — no properties; event name `plan_type_choice_shown`. Fires when `PlanTypeChoiceSheet` opens.
- New `PlanTypeChoiceSelectedEvent` — property `plan_type` (`single_route` | `custom_trail` | `journey`); event name `plan_type_choice_selected`. Fires when user taps an option.
- Extend `CreatePlanEvent`: add nullable `plan_type` and `trail_route_count` properties. `trail_route_count` is `1` for single-route plans, `2+` for multi-trail.

Wire from `PlanTypeChoiceSheet` (show + select) and update all `CreatePlanEvent` firing sites to pass the new properties.

Add unit tests in `packages/analytics_services/test/events/plan_events_test.dart` mirroring the existing pattern: assert event name, property keys, property values for representative cases.

## Acceptance criteria

- [ ] `PlanTypeChoiceShownEvent` class exists with correct name
- [ ] `PlanTypeChoiceSelectedEvent` class exists with correct name + `plan_type` property
- [ ] `CreatePlanEvent` extended with `plan_type` and `trail_route_count` properties
- [ ] `plan_type_choice_shown` fires when sheet opens
- [ ] `plan_type_choice_selected` fires on option tap with correct `plan_type` value
- [ ] All `CreatePlanEvent` firing sites pass `plan_type` and `trail_route_count`
- [ ] Unit tests added matching existing pattern; tests pass
- [ ] Events visible in Firebase Analytics DebugView and Amplitude debug stream

## Blocked by

- Blocked by `issues/011-plan-type-choice-sheet-gating.md`

## User stories addressed

- User story 12
- User story 22

## Progress note (2026-05-14)

Implemented.

- `PlanTypeChoiceShownEvent` (`plan_type_choice_shown`, no properties)
  and `PlanTypeChoiceSelectedEvent` (`plan_type_choice_selected`, with
  `plan_type` property) added to `packages/analytics_services/lib/src/
  events/plan_events.dart`.
- `CreatePlanEvent` extended with nullable `plan_type` and
  `trail_route_count` properties — emitted only when non-null
  (matches existing optional-property pattern in this file).
- `PlanTypeAnalytics` extension on `PlanType` maps each enum value
  to its snake-case analytics string (`single_route` / `custom_trail`
  / `journey`).
- `showPlanTypeChoiceSheet` fires `PlanTypeChoiceShownEvent` before
  presenting the modal. Option `onTap`s fire
  `PlanTypeChoiceSelectedEvent` with the matching `plan_type` value
  before popping. Both go through `GetIt.instance<IAnalyticsService>()`
  matching the project's analytics call pattern.
- `planType` threaded from each of the three create-plan entry flows
  through `AddEditStageScreenArguments` → `AddEditStageCubit` so the
  cubit can emit `CreatePlanEvent` with `plan_type` and
  `trail_route_count: trail?.segments.length ?? 1`. The single-route
  entry passes `PlanType.singleRoute` from `stage_select_route_screen.
  dart`; the other two pass from `plan_screen.dart`'s
  `_goToCustomTrailPlan` / `_goToJourneyPlan`.

Tests:
- `packages/analytics_services/test/events/plan_events_test.dart` —
  11 new test cases (CreatePlanEvent name + 5 property cases,
  PlanTypeChoiceShownEvent name + properties, PlanTypeChoiceSelected
  name + verbatim property + 3-value round-trip). Total 17 pass.
- `test/tabs/plan/widgets/plan_type_choice_sheet_test.dart` — 4 new
  cases plus a `_RecordingAnalyticsService` fake registered via
  GetIt in setUp/tearDown: `plan_type_choice_shown` fires on
  open, `plan_type_choice_selected` fires on tap with the right
  value, all three PlanType values round-trip, and the
  `PlanTypeAnalytics` extension test. Total 30 pass.
- Repository tests still green (138/138). App-level tests green
  (67 including the 4 new ones).
- `flutter analyze` — 0 errors across the worktree (pre-existing
  warnings/infos only).

Acceptance criteria status:
- All criteria except the last (Firebase DebugView / Amplitude debug
  stream visibility) are met. The DebugView check is the manual /
  HITL verification step deferred to phase (a) or (b) device
  smoke testing — it cannot be confirmed from this AFK iteration.

Unblocks issue 020 (adoption metrics dashboard).
