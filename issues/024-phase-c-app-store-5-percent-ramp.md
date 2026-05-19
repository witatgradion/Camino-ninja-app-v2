## Parent PRD

`issues/prd.md`

## What to build

Phase (c) start — App Store submission + Remote Config ramp at 5%. Per parent PRD section "Strategic / Phase (c)".

Submit the App Store build (same release branch as TF). Once Apple approves and the build is live in production:
1. Enable the Remote Config "App Store ramp 5%" condition (from issue 018) with `random_percent < 5`.
2. Watch the Amplitude adoption dashboard (issue 020).
3. Watch the rollback runbook triggers (issue 019).
4. If any trigger fires, follow the runbook protocol.

Phase (c) at 5% runs for ~1 week. Promotion to 25% gated on success criteria from PRD: selection rate ≥ 5% of choice_shown sessions; crash-free rate ≥ 99.5%; multi-trail plan sync round-trip success ≥ 95%.

## Acceptance criteria

- [ ] App Store build submitted via the standard release pipeline
- [ ] App Store approval received and build is live in production
- [ ] Remote Config "App Store ramp 5%" condition enabled with `random_percent < 5`
- [ ] Adoption metrics flowing into Amplitude dashboard from real users
- [ ] No rollback triggers fired
- [ ] 1 week of clean signal: selection rate ≥ 5%, crash-free ≥ 99.5%, sync success ≥ 95%
- [ ] Decision recorded to promote to 25% (or hold/flip per runbook if triggers fired)

## Blocked by

- Blocked by `issues/023-phase-b-prod-testflight.md`
- Blocked by `issues/019-rollback-runbook.md`
- Blocked by `issues/020-adoption-metrics-dashboard.md`

## User stories addressed

- User story 11
- User story 12
