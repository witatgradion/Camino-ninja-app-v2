## Parent PRD

`issues/prd.md`

## What to build

Phase (c) continuation — ramp progression from 5% → 25% → 100% based on health and adoption metrics. Per parent PRD section "Strategic / Phase (c)".

After 5% ramp produces a clean week of signal (per `issues/024`):
1. Adjust Remote Config "App Store ramp" condition to `random_percent < 25`.
2. Watch for 1 week.
3. If health and adoption metrics stay green, adjust to `random_percent < 100` (full rollout).

Each ramp gate uses the same success criteria: selection rate ≥ 5% of choice_shown sessions; crash-free rate ≥ 99.5%; multi-trail plan sync round-trip success ≥ 95%.

If at any level a trigger from the rollback runbook (`issues/019`) fires, follow the protocol — flip the flag off, investigate, decide hotfix vs flag-stays-off.

When 100% is clean for 1 week, the feature is fully shipped. Document the rollout completion in branch memory and consider next-iteration follow-ups (e.g., multi-trail support in plan sharing, currently Out of Scope).

## Acceptance criteria

- [ ] Ramp adjusted to 25% after 5% clean week
- [ ] 1 week of clean signal at 25%
- [ ] Ramp adjusted to 100% after 25% clean week
- [ ] 1 week of clean signal at 100%
- [ ] No rollback triggers fired at any ramp level
- [ ] Adoption metrics summarized in a written rollout report
- [ ] Branch memory updated with rollout completion status
- [ ] Follow-up backlog item created for next-iteration features (e.g., multi-trail sharing)

## Blocked by

- Blocked by `issues/024-phase-c-app-store-5-percent-ramp.md`

## User stories addressed

- User story 11
- User story 12
- User story 13
