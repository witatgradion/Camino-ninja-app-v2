## Parent PRD

`issues/prd.md`

## What to build

Phase (b) rollout — prod TestFlight to internal team only, on prod backend. Per parent PRD section "Strategic / Phase (b)".

Cut a prod-flavor TestFlight build from the new release branch. Enable the Remote Config "Internal TF cohort" condition (from issue 018) so internal team sees options 2 and 3 in the prod build. Re-confirm backend `trail_route_ids` round-trip works against the prod backend (curl/Postman). Internal team uses prod TF with both options. Verify cross-device sync: sign in on a second device and confirm a multi-trail plan returns intact with `trail_route_ids` preserved.

Watch crash-free rate, sync success rate. Phase (b) is the last internal gate before external users see the feature.

## Acceptance criteria

- [ ] Prod TestFlight build distributed to internal team
- [ ] Remote Config "Internal TF cohort" condition enabled in prod project
- [ ] Internal team confirms options 2 and 3 visible in prod TF build
- [ ] Backend prod round-trip re-confirmed (curl/Postman result documented)
- [ ] Cross-device sync verified: multi-trail plan created on device A returns intact on device B sign-in
- [ ] 1 week of clean signal (no crashes for trail builder / journey planner screens; sync success rate ≥ 95%)
- [ ] Internal team signs off to promote to phase (c)
- [ ] Analytics events flowing into Amplitude dashboard

## Blocked by

- Blocked by `issues/022-phase-a-staging-testflight.md`
- Blocked by `issues/004-backend-trail-route-ids-api-confirmation.md`

## User stories addressed

- User story 7
- User story 10
- User story 28
