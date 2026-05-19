# PROJECT

This is **camino_ninja_flutter** — a Flutter app for Camino pilgrimage routes. Multi-flavor (development / staging / production), Very Good CLI structure, BLoC/Cubit state management, GetIt DI, modular packages under `packages/` (analytics_services, remote_data, repository, storage, core).

The active feature branch is `feature/combining-trails-mapbox`. Read `issues/prd.md` for the broader feature context. Read `CLAUDE.md` for project conventions.

# ISSUES

Local issue files from `issues/` are provided at the start of context. Parse them to understand the open work.

You will work on **AFK issues only** — skip any task whose acceptance criteria require human-in-the-loop coordination (filing tickets with backend team, confirming external deliveries, getting human sign-off, manual production rollout, etc.). Issue 001 is the canonical HITL example; treat similarly-shaped tasks the same way.

You've also been passed the last few commits. Review them to understand what's already been done and avoid duplicating work.

If all AFK tasks are complete, output `<promise>NO MORE TASKS</promise>` and stop.

# TASK SELECTION

Pick the next task. Prioritize in this order:

1. **Critical bugfixes** — anything blocking the feature branch from compiling, passing tests, or shipping.
2. **Development infrastructure** — test harnesses, fixtures, fakes, type/contract scaffolding, dev-only toggles. These unblock everything downstream.
3. **Tracer bullets for new features** — a tiny end-to-end vertical slice through all layers (DB → repo → BLoC → UI) that proves the architecture before fanning out. Build the slice first, then expand.
4. **Polish and quick wins**
5. **Refactors**

Within a priority tier, prefer issues with no unmet `Blocked by` dependencies.

# EXPLORATION

Before coding, orient yourself:

- Read the chosen issue file end-to-end, plus its parent PRD reference if any.
- Skim the relevant package(s): for sync work that's `packages/repository/`, `packages/remote_data/`, `packages/storage/`. For UI work it's `lib/tabs/<tab>/`.
- Check the branch memory file at `memory/branches/feature-combining-trails-mapbox.md` if it exists — it has decisions and gotchas specific to this branch.
- Use `grep`/`Glob` over the codebase rather than guessing file paths.

# IMPLEMENTATION

Use `/tdd` when the task is well-specified enough for a red-green-refactor loop (most data-layer and pure-logic tasks qualify). For UI-heavy or exploratory tasks, write a thin happy-path test first, then implement, then add edge-case tests.

Project conventions to follow:

- **Lints**: `very_good_analysis`. No `// ignore:` unless justified.
- **State**: BLoC/Cubit via `flutter_bloc`. Cubits for simple state.
- **DI**: register new services in `lib/di/dependency_injection.dart` (lazy via GetIt).
- **API**: extend the Retrofit `ApiClient` in `packages/remote_data/lib/src/api_client.dart`. Models go under `packages/remote_data/lib/src/models/`.
- **DB**: changes to `packages/storage/` SQLite schemas need a migration in the appropriate `app_database.dart` / `stage_planner_database.dart` extension files. Bump the version and add a migration test under `packages/storage/test/migrations/`.
- **Analytics**: typed events under `packages/analytics_services/lib/src/events/`. Never call raw `trackEvent('string')`.
- **Localization**: new user-visible strings go in `lib/l10n/arb/app_en.arb` first, then run `flutter gen-l10n --arb-dir="lib/l10n/arb"`. English fallback is acceptable for non-English locales when AFK.
- **Logging**: use `AppLogger` from `packages/core`. No `print` / `debugPrint` / `log()`.
- **Comments**: default to none. Only add a comment when WHY is non-obvious.

Keep diffs scoped to the chosen issue. Do not refactor unrelated code.

# FEEDBACK LOOPS

Before committing, run the feedback loops from the worktree root:

- `melos run analyze` — static analysis (Dart's equivalent of typecheck + lint)
- `melos run test` — runs tests across all packages with a `test/` directory

If a package's tests need a specific runner (e.g., `packages/storage` tests need `sqflite_common_ffi` and must run from inside that package directory), invoke them directly with `flutter test` from the package root. Check the branch memory or recent commits — there are known cases.

Do not commit with failing analyze or tests. If a fix is out of scope for the current issue, document it in the issue file and pick a different task.

# COMMIT

Make a single git commit per iteration. The commit message must:

1. **Subject**: short, imperative, scoped (e.g., `feat(sync): add count endpoint client`, `fix(repository): handle empty delta response`).
2. **Body**: include
   - Key decisions made and why (architectural choices, trade-offs)
   - Files changed (high-level, not a verbatim file list — e.g., "repository + storage migration + 4 new tests")
   - Blockers, deferred work, or notes for the next iteration
3. Do **not** add Claude/co-author trailers.

# THE ISSUE FILE

- If the task is **complete**: move the file to `issues/done/` (create the dir if missing).
- If the task is **partially done**: append a `## Progress note (YYYY-MM-DD)` section to the issue file describing what was done, what's left, and any blockers/decisions discovered.

# FINAL RULES

- **Work on a single task per iteration.**
- Skip HITL issues entirely.
- If you can't make meaningful forward progress (blocked, ambiguous, dependency missing), pick a different AFK task — don't stall.
- If genuinely nothing is left, emit `<promise>NO MORE TASKS</promise>`.
