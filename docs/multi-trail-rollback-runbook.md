# Multi-Trail Rollback Runbook

**Last Updated:** 2026-05-14
**Status:** Operational — applies for the duration of the multi-trail feature ramp (phases (b) Prod TestFlight and (c) App Store)
**Owner (this runbook):** TBD — owner: @annt (product owner)

This runbook governs kill-switch decisions for the multi-trail plan-creation feature (Custom Trail + Plan a Journey). The feature is gated by two independent Firebase Remote Config flags:

- `feature_custom_trail_enabled`
- `feature_journey_planner_enabled`

Each flag controls one of the two new entry points on `PlanTypeChoiceSheet`. Flipping a flag hides the entry point from the rendered option list; **it does not delete or invalidate any existing plans on disk or on the server**. Existing multi-trail plans continue to load, render, edit, and sync regardless of flag state.

The runbook covers when to flip, who can flip, how to flip, and what to do after a flip.

---

## When to flip — trigger criteria

Any one of the following triggers, on its own, justifies flipping the relevant flag off. Triggers are independent — do not wait for two to fire.

### Trigger 1 — Crash rate

Crash-free rate for `TrailBuilderScreen` **or** `JourneyPlannerScreen` drops below **99%** over a **1-hour window** with **≥100 sessions** on that screen.

- Source: Firebase Crashlytics dashboard, filtered by screen name (Crashlytics page-level reports).
- Why this threshold: 99% crash-free is the rest-of-app baseline; a feature-specific dip below 99% with adequate session volume indicates the feature itself is the cause, not noise.
- Which flag to flip: the flag for the screen that fired the trigger. `TrailBuilderScreen` → `feature_custom_trail_enabled`. `JourneyPlannerScreen` → `feature_journey_planner_enabled`. If both fire, flip both.

### Trigger 2 — Sync failure rate

`multi_trail_plan_sync_failed` event count exceeds **1%** of `multi_trail_plan_sync_success` count over a **1-hour window**.

- Source: Amplitude dashboard — "Multi-Trail Adoption" — sync health chart (the ratio of `multi_trail_plan_sync_failed` to `multi_trail_plan_sync_success`).
- Why this threshold: client-side network noise sits well under 1%; sustained breach signals a backend regression or a client/server contract drift on `trail_route_ids`.
- Which flag to flip: both flags. A sync regression affects every multi-trail plan regardless of which entry point created it.

### Trigger 3 — User complaints

**Three or more unique users** report a problem referencing the feature within a **24-hour window**.

- Source: support inbox + designated support channel (TBD below).
- Definition of "referencing the feature": user mentions Custom Trail, Plan a Journey, multi-trail, junctions, route options, or describes a symptom isolated to plans with more than one route.
- Definition of "unique users": three distinct user accounts. Duplicate reports from the same user count once.
- Which flag to flip: whichever entry point the complaints reference. If complaints span both, flip both.

---

## Authority — who can flip

**Two-person quorum.** Two named operators with Firebase Remote Config console access for the prod project (`camino-ninja-80a28`) can flip independently. The first to spot a trigger and flip is the authority; the channel post is the audit record.

### Designated operators (prod Remote Config console access)

| Role | Name | Notes |
|------|------|-------|
| Product owner | @annt (annt@caminounlimited.com) | Primary authority |
| Engineer 1 | TBD — owner: @annt | Designate before phase (b) starts |
| Engineer 2 | TBD — owner: @annt | Optional second backup |

> The runbook works with one designated operator + product owner if a second engineer is not designated by phase (b). Two named people total is the minimum.

### Communication channel

| Purpose | Channel | Notes |
|---------|---------|-------|
| Flip notifications + audit record | TBD — owner: @annt (Slack channel name) | Designate before phase (b) starts |
| Support escalations | Existing support inbox | Pre-existing |

---

## How to flip — protocol

**Time target: under 5 minutes from trigger detection to flag flipped.**

1. **Spot the trigger.** Notice the crash rate, sync failure ratio, or third user complaint.
2. **Post to the designated channel** with three fields:
   - Which flag (`feature_custom_trail_enabled`, `feature_journey_planner_enabled`, or both)
   - Which trigger fired (Crash rate / Sync failure rate / User complaints)
   - Raw numbers (e.g., "crash-free rate 97.3% over the last hour, 142 sessions" or "12 sync failures vs 580 successes in last hour" or "3 distinct user reports on Custom Trail since yesterday")
3. **Flip the flag immediately** in the Firebase Remote Config console. Do not wait for acknowledgement on the channel post — the post is the record, not the gate.
   - Navigate to: Firebase Console → `camino-ninja-80a28` → Remote Config.
   - Find the parameter (`feature_custom_trail_enabled` or `feature_journey_planner_enabled`).
   - Set the default value to `false` (or disable the active condition, whichever is faster).
   - Publish the change.
4. **Verify the flip propagated.** New app sessions will pick up the new value at next fetch. The client cache has a default minimum fetch interval — typical propagation is under 1 hour. Crashlytics and the Amplitude funnel both show the propagation curve via `feature_flag_exposure` events.

---

## After the flip — investigation window

**30-minute investigation window** starting from the flip. The goal is to decide whether a hotfix release is required or whether the flag-off state is sufficient until the next planned release.

### Step 1 — Confirm the flip stopped the bleeding

Watch the same trigger metric for 30 minutes after the flip:

- Crash rate: does the screen's crash-free rate return to ≥99% as flag-off propagates?
- Sync failure rate: does the ratio drop back under 1%?
- User complaints: do new complaints stop coming in?

If the metric returns to a healthy state, the flag-off state worked.

### Step 2 — Check whether existing user data is in a broken state

- Inspect the most recent `bug_report` archives that include DB dumps (see `docs/db-export-guide.md`).
- Inspect Amplitude funnels: did `multi_trail_plan_sync_success` continue for plans created before the flip, or did sync fail for everyone?
- Inspect support inbox: are users reporting **lost data** (plans missing, stages disappearing) vs **inability to use a new feature** (entry point gone)?

A user with a multi-trail plan that no longer loads or that sync corrupts counts as broken data. A user who can no longer create a new multi-trail plan because the entry point is hidden does **not** count as broken data — that's the flag working as intended.

### Step 3 — Decide hotfix vs flag-stays-off

| Outcome of Step 1 | Outcome of Step 2 | Decision |
|-------------------|-------------------|----------|
| Flip stopped the bleeding | No existing user data corrupted | **Flag stays off**, fix scheduled for the next planned release |
| Flip stopped the bleeding | Existing user data corrupted | **Cut a hotfix** to repair affected plans (forward-recovery migration or server-side data correction) |
| Flip did NOT stop the bleeding | (any) | **Cut a hotfix** — the regression is not isolated to the flag's gate; client logic or server state is the cause |

For a hotfix:
- Branch from the current production release branch.
- Single-commit fix scoped to the regression.
- Run the standard release pipeline (CI tests + at least one TestFlight build for an internal smoke check before App Store submission).
- Document the incident in the next post-mortem.

---

## Reset criteria — when to flip back on

After a flip-off, re-enabling the flag requires:

1. The root cause is understood and a fix has shipped (either in a hotfix or the next planned release, depending on severity).
2. Internal team has re-verified the affected flow on the build that contains the fix (against prod backend during TestFlight phase).
3. A new 5% Remote Config ramp condition is configured for the App Store cohort. Do not re-enable at the previous ramp percentage — restart at 5% to catch regressions in the fix.
4. The trigger metric (crash rate, sync failure rate, or complaint volume) has been clean for at least one full week on the fixed internal build.

A re-enable is a fresh ramp start, not a resume.

---

## Related references

- Parent PRD: `issues/prd.md` (section "Rollback runbook")
- Remote Config setup: `docs/multi-trail-remote-config.md` (build by `issues/018-remote-config-console-setup.md`)
- Adoption dashboard: Amplitude project "Multi-Trail Adoption" (build by `issues/020-adoption-metrics-dashboard.md`)
- DB export for incident forensics: `docs/db-export-guide.md`
- Analytics event taxonomy: `docs/analytics-audit.md` (and the typed event classes under `packages/analytics_services/lib/src/events/`)

---

## Open items before phase (b) starts

These TBD items must be resolved before the internal Prod TestFlight rollout begins:

- [ ] Designate Engineer 1 with Remote Config console access (owner: @annt)
- [ ] Designate Engineer 2 with Remote Config console access — optional but recommended (owner: @annt)
- [ ] Name the communication channel for flip notifications (owner: @annt)
- [ ] Confirm all designated operators have Firebase console access to `camino-ninja-80a28` Remote Config (owner: @annt)
