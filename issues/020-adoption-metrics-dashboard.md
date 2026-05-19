## Parent PRD

`issues/prd.md`

## What to build

Set up the adoption metrics dashboard in Amplitude. Per parent PRD section "Adoption KPIs" and "Analytics".

Build the following funnels and charts in Amplitude:

**Top-level funnel** (any plan creation entry):
- Step 1: `plan_type_choice_shown`
- Step 2: `plan_type_choice_selected` (filter: `plan_type != single_route`)
- Step 3: `create_plan` (filter: `plan_type != single_route`)

**Custom Trail flow funnel**:
- Step 1: `plan_type_choice_selected` (filter: `plan_type == custom_trail`)
- Step 2: `trail_builder_junction_decision` (count >= 1 per session)
- Step 3: `trail_builder_finalized`
- Step 4: `create_plan` (filter: `plan_type == custom_trail`)

**Plan a Journey flow funnel**:
- Step 1: `plan_type_choice_selected` (filter: `plan_type == journey`)
- Step 2: `journey_planner_start_city_selected`
- Step 3: `journey_planner_destination_selected`
- Step 4: `journey_planner_route_option_selected`
- Step 5: `create_plan` (filter: `plan_type == journey`)

**Charts**:
- Selection rate: % of `plan_type_choice_shown` sessions that fired `plan_type_choice_selected` with non-single plan_type
- Completion rate: % of selection events that ended with `create_plan` for the same plan_type
- Drop-off by step: per funnel, where do users abandon
- Sync health: ratio of `multi_trail_plan_sync_success` vs `multi_trail_plan_sync_failed` over time
- Feature flag exposure: count of `feature_flag_exposure` events per flag per day (cohort accounting)

## Acceptance criteria

- [ ] Dashboard exists in Amplitude (named e.g. "Multi-Trail Adoption")
- [ ] Top-level funnel configured
- [ ] Custom Trail flow funnel configured
- [ ] Plan a Journey flow funnel configured
- [ ] Selection rate, completion rate, drop-off, sync health, flag exposure charts present
- [ ] Dashboard accessible to product owner + designated teammates
- [ ] Sample events verified flowing into the dashboard (e.g., from a dev/staging session)

## Blocked by

- Blocked by `issues/014-plan-creation-analytics-events.md`
- Blocked by `issues/015-journey-planner-funnel-events.md`
- Blocked by `issues/016-trail-builder-funnel-events.md`
- Blocked by `issues/017-sync-health-and-flag-exposure-events.md`

## User stories addressed

- User story 12
