## Parent PRD

`issues/prd.md`

## What to build

Phase (a) rollout — staging TestFlight to internal team only, on dev backend. Per parent PRD section "Strategic / Phase (a)".

Cut a staging-flavor TestFlight build from the integration branch (or the new release branch after PR opens). Distribute to internal team via TestFlight. Internal team runs through smoke checklists for both Custom Trail and Plan a Journey flows. Verify no crashes, no migration failures, no sync errors against dev backend.

Important: phase (a) is local-only by design (per PRD Out of Scope). Cross-device sync verification is NOT required at this phase — that happens in phase (b).

Internal team uses the dev/staging flavor gate, so options 2 and 3 are always visible without Remote Config involvement.

## Acceptance criteria

- [ ] Staging TestFlight build distributed to internal team
- [ ] Internal team confirms: Custom Trail flow completed end-to-end at least 3 times
- [ ] Internal team confirms: Plan a Journey flow completed end-to-end at least 3 times
- [ ] No crashes reported during ~1 week of internal use
- [ ] No DB migration failures observed
- [ ] No sync errors observed against dev backend
- [ ] Smoke checklists from issues 006-009 all confirmed passing on real devices (not just emulator)
- [ ] Internal team signs off to promote to phase (b)

## Blocked by

- Blocked by `issues/021-cut-release-branch-and-final-pr.md`

## User stories addressed

- User story 8
- User story 9
