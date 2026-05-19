## Parent PRD

`issues/prd.md`

## What to build

Unit tests for `JourneyPlannerCubit`. Per parent PRD section "Testing Decisions / Modules with mandatory tests".

Follow the same `cubit-testing.md` patterns as `issues/012`. Cover the state machine: `startCitySelection → destinationCitySelection → routeOptions`.

Test cases:
- Happy path: start city picked → destination picked → route options computed → option selected → `MultiRouteTrail` returned
- No-destinations-reachable: start city has no forward-reachable destinations → empty list state with appropriate UI signal
- Lazy polyline loading: route options beyond top 10 have polyline loaded on selection (not on initial fetch)
- Junction touching-point distance filter slider state: slider value change triggers re-computation of reachability with new threshold (dev/staging slider behavior)

Test file location: `test/tabs/plan/screens/journey_planner/cubit/journey_planner_cubit_test.dart`.

## Acceptance criteria

- [ ] Test file exists at the mirrored source location
- [ ] Happy path covered through all 3 state transitions
- [ ] No-destinations-reachable case covered
- [ ] Lazy polyline loading state covered (assert polylines for options 1-10 vs option 11+)
- [ ] Distance filter slider state-change covered
- [ ] All tests pass
- [ ] `flutter analyze` clean

## Blocked by

- Blocked by `issues/008-mapbox-port-journey-planner.md`

## User stories addressed

- User story 4
- User story 5
- User story 20
