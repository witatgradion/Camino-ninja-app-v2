## Parent PRD

`issues/prd.md`

## What to build

Create the integration worktree where all catch-up work will land. Branch from `feature/combining-trails`, target directory `.claude/worktrees/combining-trails-mapbox`, new branch name `feature/combining-trails-mapbox`. Copy the gitignored env files required for builds (`.env.development`, `.env.staging`, `.env.production`, `ios/Flutter/Secrets.xcconfig`, `android/keystore.properties`, `android/keystore/`). Initialize the branch memory file `memory/branches/feature-combining-trails-mapbox.md` with a reference to this PRD as the source-of-truth design doc and a back-link to the `feature/combining-trails` branch memory.

See parent PRD section "Branch and worktree" for the rationale.

## Acceptance criteria

- [ ] Worktree exists at `.claude/worktrees/combining-trails-mapbox` with HEAD on a new branch `feature/combining-trails-mapbox`
- [ ] Branch is up-to-date with `feature/combining-trails` at worktree creation time
- [ ] All required env/keystore files copied into the worktree (verified by `flutter build apk --flavor development` succeeding)
- [ ] Branch memory file `memory/branches/feature-combining-trails-mapbox.md` exists and references `issues/prd.md`
- [ ] Branch memory file points back to `feature/combining-trails` branch memory

## Blocked by

None - can start immediately.

## User stories addressed

- User story 17
