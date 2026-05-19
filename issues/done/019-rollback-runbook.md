## Parent PRD

`issues/prd.md`

## What to build

Author the rollback runbook document for operational reference during ramp. Per parent PRD section "Rollback runbook".

Create `docs/multi-trail-rollback-runbook.md` with:

**Trigger criteria** (any one alone justifies flipping):
- Crashlytics: crash-free rate for `TrailBuilderScreen` or `JourneyPlannerScreen` drops below 99% over a 1-hour window with ≥100 sessions
- Sync: `multi_trail_plan_sync_failed` event count > 1% of `multi_trail_plan_sync_success` over a 1-hour window
- Support: ≥3 unique user complaints referencing the feature within a 24-hour window

**Authority**: 2-person quorum. Identify by name the product owner + 1-2 designated teammates with Remote Config console access. Designate the communication channel (e.g., Slack channel name) where flip notifications are posted.

**Protocol**:
- Anyone with access posts the proposed flip to the designated channel with: flag name, trigger that fired, raw numbers
- They flip immediately (the channel post is the record; do not block on ack)
- Time target: under 5 minutes from trigger detection to flag flipped

**Post-flip decision** (after 30-minute investigation):
- If flag flip stopped the bleeding AND no existing user data is corrupted → flag stays off, fix scheduled for the next release
- If existing user data is in a broken state OR flag flip did not stop the bleeding → cut a hotfix release

Designated teammates and channel name may be marked "TBD — owner: <name>" if not finalized at issue completion, but a follow-up owner must be identified.

## Acceptance criteria

- [ ] Document exists at `docs/multi-trail-rollback-runbook.md`
- [ ] All trigger criteria captured with concrete numbers
- [ ] Authority model captured; designated teammates listed (or marked TBD with owner)
- [ ] Communication channel named (or marked TBD with owner)
- [ ] Time target (<5 min) captured
- [ ] Post-flip decision tree captured
- [ ] Document is reviewable as a self-contained operational runbook (a teammate can read it without other context and act correctly)

## Blocked by

None - can run in parallel with code work.

## User stories addressed

- User story 13
- User story 25
- User story 26
- User story 27
