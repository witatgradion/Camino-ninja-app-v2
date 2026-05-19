## Parent PRD

`issues/prd.md`

## What to build

Add sync health events for multi-trail plans and the feature flag exposure event. Per parent PRD section "Analytics".

In analytics event files (locate appropriately — `plan_events.dart` or `sync_events.dart` or a new file):
- `MultiTrailPlanSyncSuccessEvent` — no properties or minimal context (e.g., `route_count`); event name `multi_trail_plan_sync_success`. Fires from `stage_plan_repository` sync paths when a plan with non-NULL `trail_route_ids` syncs successfully.
- `MultiTrailPlanSyncFailedEvent` — property `error` (string, sanitized); event name `multi_trail_plan_sync_failed`. Fires on sync failure for a multi-trail plan.
- `FeatureFlagExposureEvent` — properties `flag_name` (string) and `flag_value` (bool); event name `feature_flag_exposure`. Fires at most once per session per flag, when `PlanTypeChoiceSheet` reads the flag via `PlanTypeVisibility` resolver.

The session-once de-dup for `FeatureFlagExposureEvent` can use an in-memory `Set<String>` in the analytics service or a small state holder. Both flags fire their own exposure event independently.

Unit tests for event properties + de-dup logic for the exposure event.

## Acceptance criteria

- [ ] Three new event classes with correct names + properties
- [ ] `MultiTrailPlanSyncSuccessEvent` fires from repo sync success path for multi-trail plans
- [ ] `MultiTrailPlanSyncFailedEvent` fires from repo sync failure path for multi-trail plans
- [ ] `FeatureFlagExposureEvent` fires once per session per `flag_name`
- [ ] Both flag exposures fire independently (custom_trail and journey_planner are separate events)
- [ ] Unit tests pass including the de-dup behavior
- [ ] Events visible in Firebase Analytics DebugView and Amplitude debug stream

## Blocked by

- Blocked by `issues/005-sync-wiring-trail-route-ids.md`
- Blocked by `issues/011-plan-type-choice-sheet-gating.md`

## User stories addressed

- User story 12
- User story 22
- User story 23
- User story 24
