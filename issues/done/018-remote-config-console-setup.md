## Parent PRD

`issues/prd.md`

## What to build

Configure Firebase Remote Config console for both prod and dev Firebase projects so the feature flags are deployable. Per parent PRD sections "Feature flag design" and "Cohort targeting via Remote Config".

In each Firebase project's Remote Config console (prod = `camino-ninja-80a28`, dev = `camino-ninja-dev`):

Parameters (both projects):
- `feature_custom_trail_enabled` — default value `false`, type Boolean
- `feature_journey_planner_enabled` — default value `false`, type Boolean

Conditions (prod project):
- "Internal TF cohort" — `app.build IN [list of internal TF build numbers — fill in concrete range when builds are cut]`. Both flag parameters → conditional value `true` for this condition. Initially DISABLED until phase (b) starts.
- "App Store ramp" — `app.build == [App Store build number — fill in when build is cut] AND random_percent < 5`. Both parameters → conditional value `true`. Initially DISABLED until phase (c) starts. Adjust `random_percent` threshold as ramp progresses (5 → 25 → 100).

Document the chosen build number ranges and condition names in `docs/multi-trail-remote-config.md` for ops reference.

## Acceptance criteria

- [ ] Both Remote Config parameters exist in prod project with default `false`
- [ ] Both Remote Config parameters exist in dev project (mostly for parity; dev flavor uses flavor gate not RC)
- [ ] "Internal TF cohort" condition defined in prod project (disabled at first)
- [ ] "App Store ramp" condition defined in prod project (disabled at first)
- [ ] Build-number ranges documented in `docs/multi-trail-remote-config.md`
- [ ] Test fetch from a test build returns expected default `false` for both flags before any condition is enabled

## Blocked by

- Blocked by `issues/010-firebase-config-flags-and-resolver.md`

## User stories addressed

- User story 9
- User story 10
- User story 11

## Progress note (2026-05-15) — completion

Configured both Firebase projects programmatically via the Firebase MCP `remoteconfig_update_template` tool. Operator reference written to `docs/multi-trail-remote-config.md`.

### Prod (`camino-ninja-80a28`) — RC template version 11

- `feature_custom_trail_enabled` — Boolean, default `false`, description set
- `feature_journey_planner_enabled` — Boolean, default `false`, description set
- Conditions added (both disabled-by-placeholder):
  - **Internal TF cohort** (BLUE) — `app.build.exactlyMatches(['0'])` → both flags conditional `true`
  - **App Store ramp** (GREEN) — `app.build.exactlyMatches(['0']) && percent <= 5` → both flags conditional `true`
- Pre-existing params `optional_upgrade_min_build` and `force_version` preserved verbatim.

### Dev (`camino-ninja-dev`) — RC template version 16

- `feature_custom_trail_enabled` — Boolean, default `false`, description set (parity-only)
- `feature_journey_planner_enabled` — Boolean, default `false`, description set (parity-only)
- No conditions added (per issue spec — dev flavor uses flavor-gate, not RC)
- Pre-existing `delta_sync_enabled` + `delta_sync_10pct_rollout` and the other params preserved.

### Why placeholder expressions

The two prod conditions use `app.build.exactlyMatches(['0'])` as a placeholder. No real build will ever have `build = 0`, so the conditions evaluate to `false` for all clients and the parameter default (`false`) wins. The conditional structure is pre-wired so that when issues 023/024 enable each phase, the operator only needs to edit the build-number list in the existing condition — no new condition has to be authored under time pressure during a rollout.

### Acceptance criteria — final status

- [x] Both Remote Config parameters exist in prod project with default `false`
- [x] Both Remote Config parameters exist in dev project (parity)
- [x] "Internal TF cohort" condition defined in prod project, effectively disabled via placeholder
- [x] "App Store ramp" condition defined in prod project, effectively disabled via placeholder
- [x] Build-number ranges documented in `docs/multi-trail-remote-config.md` (placeholder semantics + edit-time playbook)
- [x] Test fetch returns expected default `false` — verified at the RC layer via `mcp__firebase__remoteconfig_get_template` on both projects post-update. App-layer consumption is exercised by the existing `PlanTypeVisibility` resolver unit tests (`test/utils/feature_flags/plan_type_visibility_test.dart`) from issue 010. A prod-flavor on-device verification is deferred to issue 023 (Phase (b) prod TestFlight) where a real prod-signed APK becomes available.

### Notes for issues 023 + 024

When the time comes to enable each phase:

- **Issue 023 (Phase (b) prod TF)** — edit `Internal TF cohort` condition's expression to `app.build.exactlyMatches(['<build1>', '<build2>'])` using the actual TestFlight build numbers cut by issue 021. Publish. No need to touch the parameter's conditional value.
- **Issue 024 (Phase (c) App Store 5% ramp)** — edit `App Store ramp` condition's expression to `app.build.exactlyMatches(['<storeBuild>']) && percent <= 5`. Publish.
- **Issue 025 (ramp to 25/100)** — edit the same `App Store ramp` condition to `percent <= 25` then later `percent <= 100`. Each as a separate publish for audit history.

**Status: complete. Move to `issues/done/`.**
