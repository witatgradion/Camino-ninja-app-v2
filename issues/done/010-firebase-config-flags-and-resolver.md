## Parent PRD

`issues/prd.md`

## What to build

Add the two feature flag getters to `FirebaseConfigDataSource` and create a pure `PlanTypeVisibility` resolver function with unit tests. Per parent PRD sections "Feature flag design" and "NEW modules to BUILD".

Extend `packages/remote_data/lib/src/firebase_config_datasource.dart` with:
- `bool getCustomTrailEnabled()` reading Remote Config key `feature_custom_trail_enabled`
- `bool getJourneyPlannerEnabled()` reading Remote Config key `feature_journey_planner_enabled`

Follow the existing `getOptionalUpgradeMinBuild()` pattern. Pass-through via `Repository` matching the existing preference-method pattern.

Create new pure function `PlanTypeVisibility.isVisible(PlanType, {required Flavor flavor, required bool customTrailEnabled, required bool journeyPlannerEnabled}) → bool`. Logic:
- `PlanType.singleRoute` → always `true`
- Dev or staging flavor → always `true` for all plan types (flavor gate)
- Prod flavor + `PlanType.customTrail` → `customTrailEnabled`
- Prod flavor + `PlanType.journey` → `journeyPlannerEnabled`

Add unit tests covering the matrix: 3 plan types × 3 flavors × 2 flag states. Match existing test patterns in `packages/analytics_services/test/events/plan_events_test.dart` and `packages/storage/test/models/`.

## Acceptance criteria

- [ ] `FirebaseConfigDataSource` has the two new getters
- [ ] `Repository` exposes pass-through to the new getters
- [ ] `PlanTypeVisibility` pure resolver function exists (no widget dependencies)
- [ ] Unit tests cover all flavor/flag combinations (at least 12 cases — 3 types × 3 flavors × 2 flag states reduced by flavor-gate short-circuit)
- [ ] All tests pass
- [ ] `flutter analyze` clean

## Blocked by

- Blocked by `issues/002-atomic-merge-release-2-2-410.md`

## User stories addressed

- User story 2
- User story 9
- User story 10
- User story 11
