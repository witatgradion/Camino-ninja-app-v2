# Multi-Trail Remote Config (Operator Reference)

Operator reference for the Remote Config setup that governs the multi-trail rollout (Custom Trail + Plan a Journey). Companion to `multi-trail-rollback-runbook.md`.

PRD references: `issues/prd.md` sections "Feature flag design", "Cohort targeting via Remote Config", and "Rollback runbook".

## Flag parameters

Both Firebase projects (prod `camino-ninja-80a28` + dev `camino-ninja-dev`) carry the same two parameters. Dev gets them for parity only — the dev flavor uses a flavor-gate (hard-coded `true` for options 2/3) and never reads Remote Config for these flags. Staging flavor + prod flavor read RC.

| Parameter | Type | Default | Gates |
|---|---|---|---|
| `feature_custom_trail_enabled` | Boolean | `false` | "Custom Trail" option in `PlanTypeChoiceSheet` |
| `feature_journey_planner_enabled` | Boolean | `false` | "Plan a Journey" option in `PlanTypeChoiceSheet` |

Resolver: `lib/utils/feature_flags/plan_type_visibility.dart` (issues 010 + 011). The resolver is a pure function over `(PlanType, Flavor, FirebaseConfigDataSource)` — flavor short-circuits to always-visible on dev + staging; prod consults Remote Config.

Wiring sites: `lib/tabs/plan/plan_screen.dart:332` (`feature_custom_trail_enabled`), `:337` (`feature_journey_planner_enabled`). Both call `FeatureFlagExposureTracker.report(...)` so `feature_flag_exposure` analytics events fire once per session per flag read (PRD user story 24).

## Conditions (prod only)

Two conditions defined in the prod project, both currently using a placeholder expression that will not match any real build. They MUST be edited to real build numbers before they take effect.

### `Internal TF cohort` (BLUE)

- **Current expression**: `app.build.exactlyMatches(['0'])`
- **Conditional value on both flags**: `true`
- **Purpose**: targets the internal TestFlight build cohort during phase (b). Internal team gets the multi-trail features turned on on prod infrastructure; external users do not.
- **When to enable**: at the start of phase (b) (issue 023 — Prod TestFlight). Edit the `'0'` placeholder to the actual TF build number(s) cut by issue 021.
- **Build-number format**: stringified iOS/Android build numbers as reported by `app.build` (the value embedded by `pubspec.yaml`'s `version:` line — currently `+202405` → `'202405'`). Multiple builds: `app.build.exactlyMatches(['202410', '202411'])`.

### `App Store ramp` (GREEN)

- **Current expression**: `app.build.exactlyMatches(['0']) && percent <= 5`
- **Conditional value on both flags**: `true`
- **Purpose**: targets a percentage of users on the App Store / Play Store release builds during phase (c). Starts at 5%, ramps to 25%, then 100%.
- **When to enable**: at the start of phase (c) (issue 024 — Phase (c) App Store 5% ramp). Edit the `'0'` placeholder to the production App Store / Play build number cut for the release.
- **Ramp progression**: bump `percent <= 5` to `percent <= 25` (issue 025) then `percent <= 100` (also 025). Done as separate console updates so each step is auditable in the RC change history.
- **Independent ramp option**: each flag has its own `conditionalValues` entry, so Custom Trail and Plan a Journey can be ramped independently. To ramp Plan a Journey faster than Custom Trail, change only `feature_journey_planner_enabled`'s conditional value to `true` and leave `feature_custom_trail_enabled` on `false` for the App Store ramp condition.

## Operator playbook — flipping the kill switch

Per PRD "Rollback runbook" triggers (see `multi-trail-rollback-runbook.md`):

1. Identify the affected flag — Custom Trail or Plan a Journey, or both.
2. In the prod RC console, edit the parameter's `App Store ramp` conditional value from `true` to `false` (do NOT delete the conditional value — keeping it allows easy re-enable).
3. Publish. Remote Config propagates to clients within minutes (next `fetchAndActivate` on each device).
4. Post the flip to the designated channel: flag name, trigger that caused it, raw numbers, time.
5. 30-minute investigation window per PRD.

Total time target: under 5 minutes from trigger detection to flag flipped.

## Dev project notes

Dev project has the parameters with default `false` and no conditions. Reasons:

- Dev flavor never reads these flags from RC (flavor gate short-circuits).
- Staging flavor connects to dev Firebase and DOES read RC. Staging users always see the multi-trail options because the flavor gate also force-visible for staging (per `PlanTypeVisibility` resolver).
- The parity-only param exists so that someone running prod flavor against the dev Firebase backend (debug scenario) does not get an `INVALID_FETCH_STATUS` on RC fetch.

Dev project also has an unrelated `delta_sync_10pct_rollout` condition + `delta_sync_enabled` param. Left untouched.

## Current version snapshot (2026-05-15)

- **Prod** (`camino-ninja-80a28`): RC template version **11**, updated 2026-05-15 by `annt.thwin@gradion.com` via REST API. Pre-existing parameters `optional_upgrade_min_build` and `force_version` preserved.
- **Dev** (`camino-ninja-dev`): RC template version **16**, updated 2026-05-15 by `annt.thwin@gradion.com` via REST API. Pre-existing parameters preserved.

Use `firebase use <project>` + `mcp__firebase__remoteconfig_get_template` (or the Firebase Console) to verify current state.
