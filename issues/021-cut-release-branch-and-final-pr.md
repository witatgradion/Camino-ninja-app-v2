## Parent PRD

`issues/prd.md`

## What to build

Cut a new release branch from `origin/release/2.2.410` and open the final integration PR from `feature/combining-trails-mapbox` to the new release branch. Per parent PRD section "Branch and worktree".

Steps:
1. From `origin/release/2.2.410`, cut a new release branch (likely `release/2.2.411` or the next sequence number per the team's versioning).
2. Bump the version in pubspec on the integration branch (or the new release branch — match team convention).
3. Open the PR from `feature/combining-trails-mapbox` → new release branch.
4. PR title: short and descriptive (e.g., "feat(plan): combining trails — multi-trail plans via Custom Trail and Plan a Journey").
5. PR description: link to `issues/prd.md`; list the chunks (commits) and their issue numbers; note the feature-flag gating; note the (a)/(b)/(c) rollout plan.

All CI checks must pass on the integration branch before opening. PR ready for human review.

Note: open PR #383 ("chore(ci): fix broken release pipeline + add PR-level check") must land before this PR can ship via the standard release pipeline. Coordinate timing.

## Acceptance criteria

- [ ] New release branch exists on remote (cut from `origin/release/2.2.410`)
- [ ] Version bumped to next number on integration branch
- [ ] PR opened from `feature/combining-trails-mapbox` → new release branch
- [ ] PR title is short and descriptive
- [ ] PR description links to PRD and lists chunk commits
- [ ] All CI checks pass on the PR
- [ ] PR is ready for human review
- [ ] No conflicts with target branch (rebased/merged clean)
- [ ] PR #383 status documented in PR description (block or unblock)

## Blocked by

- Blocked by `issues/003-db-v10-migration-and-downgrade.md`
- Blocked by `issues/005-sync-wiring-trail-route-ids.md`
- Blocked by `issues/006-mapbox-port-stage-map.md`
- Blocked by `issues/007-mapbox-port-trail-builder.md`
- Blocked by `issues/008-mapbox-port-journey-planner.md`
- Blocked by `issues/009-mapbox-port-route-map-explorer.md`
- Blocked by `issues/011-plan-type-choice-sheet-gating.md`
- Blocked by `issues/012-trail-builder-cubit-unit-tests.md`
- Blocked by `issues/013-journey-planner-cubit-unit-tests.md`
- Blocked by `issues/014-plan-creation-analytics-events.md`
- Blocked by `issues/015-journey-planner-funnel-events.md`
- Blocked by `issues/016-trail-builder-funnel-events.md`
- Blocked by `issues/017-sync-health-and-flag-exposure-events.md`
- Blocked by `issues/018-remote-config-console-setup.md`

## User stories addressed

- User story 17
