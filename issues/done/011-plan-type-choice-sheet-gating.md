## Parent PRD

`issues/prd.md`

## What to build

Wire the `PlanTypeVisibility` resolver from `issues/010` into `PlanTypeChoiceSheet` so options 2 and 3 are flag-gated. Per parent PRD section "Feature flag design".

Compute visibility for each `PlanType` at build time using the current flavor + the current Remote Config flag values. Hide non-visible options from the rendered option list. Ensure layout adjusts gracefully in all states (3 options visible, 2 visible, only Single Route visible).

The gate hides the entry point only — existing multi-trail plans on disk continue to render, load, edit, and sync regardless of flag state. Do not touch the data model or sync path.

## Acceptance criteria

- [ ] `PlanTypeChoiceSheet` reads flag state via `PlanTypeVisibility` resolver
- [ ] In dev flavor: all 3 options visible
- [ ] In staging flavor: all 3 options visible
- [ ] In prod flavor with both flags off (default): only Single Route visible
- [ ] In prod flavor with `feature_custom_trail_enabled = true` only: Single Route + Custom Trail visible
- [ ] In prod flavor with `feature_journey_planner_enabled = true` only: Single Route + Plan a Journey visible
- [ ] In prod flavor with both flags on: all 3 options visible
- [ ] Layout looks correct in all states (no broken spacing when fewer options visible)
- [ ] Existing multi-trail plans render and load even when the flag is off (verified manually)

## Blocked by

- Blocked by `issues/010-firebase-config-flags-and-resolver.md`

## User stories addressed

- User story 1
- User story 2
- User story 9
- User story 10
- User story 11
