# DB Test Harness & Stability Plan

**Branch:** `chore/db-test-harness`
**Owner:** Technical Co-Founder (Claude) + Flutter Expert agent
**Status:** Approved — decisions captured below; ready to execute after next release

## Problem

Recent production bugs have clustered around the stage planner database and sync layer:

- **v5→v7 migration failure** (fix/optional-date-migration-issue, PR #364): orphaned `stages` rows from a pre-v2.2.364 FK-enforcement gap broke a FK-constrained `INSERT` during migration. ~388 users affected.
- **Stage loss on update** (fix/stage-update-bug, current branch): `stage_number` not preserved through updates during sync, causing stages to disappear.
- **Optional-date migration normalization** (feature/stage-planner-optional-dates): legacy date formats needed runtime normalization post-migration.

These share a pattern: **correctness depends on real-user data shape, not pure logic.** Mocked unit tests and emulator-only QA don't exercise the states that break in production (orphans, legacy rows, partial syncs, null-in-nullable fields).

Current test surface:
- `packages/storage/test/app_database_test.dart` — uses `sqflite_common_ffi`, covers singleton + basic CRUD.
- `packages/storage/test/stage_planner_database_test.dart` — same pattern, single-version only.
- `packages/repository/test/repository_test.dart` — repository-level, with mocks.
- **No migration tests. No realistic fixtures. No sync round-trip tests.**

## Goal

Stop this class of bug from reaching production. Specifically:
1. Every DB migration is exercised against realistic (and messy) data before merge.
2. Sync round-trips (local ↔ remote merge) are covered end-to-end with a real SQLite.
3. Regressions in production are detected within 48h via telemetry, not weeks via user reports.

Non-goals for this branch:
- Full E2E / `integration_test` coverage of the Flutter UI (separate follow-up).
- Raising unit test coverage % as a headline metric.
- Rewriting the DB layer.

## Scope & Phases

### Phase 1 — Migration Test Harness (highest priority)

Goal: every version bump in `AppDatabase` and `StagePlannerDatabase` has a test that migrates from each prior version to current, with realistic fixtures including known failure modes.

**Deliverables:**
- `packages/storage/test/migrations/` directory.
- Per-version fixture SQL files: `fixtures/v1.sql`, `fixtures/v2.sql`, … `fixtures/v7.sql` that each seed a DB at that version with:
  - Happy-path rows.
  - Edge rows: null-in-nullable, empty strings, legacy date formats, duplicate keys, orphans (FK violations from pre-enforcement era).
- `migration_test.dart` that for each (fromVersion, toVersion) pair:
  1. Creates DB at `fromVersion` with fixture.
  2. Opens it at `currentVersion` (triggers migration).
  3. Asserts row counts, FK integrity, expected normalizations.
- Helper: `MigrationTestHarness` utility (open-at-version, seed-from-sql, assert-fk-valid).
- Regression tests encoding the two recent bugs:
  - Orphaned `stages` → v5→v7 migration must succeed.
  - `stage_number` preserved through an update.

**Exit criteria:** All migrations (v1→current, v2→current, …, v6→v7) pass in CI. Both known prod bugs have a failing-then-passing test committed.

### Phase 2 — Repository & Sync Integration Tests

Goal: cover the stage planner round-trip flows using a real in-memory SQLite (no mocks at the DB boundary).

**Deliverables:**
- `packages/repository/test/integration/stage_plan_sync_test.dart`.
- Fake `ApiClient` (not mocked — a hand-rolled fake with controllable responses, so we test the merge logic, not mock setup).
- Covered scenarios:
  - Create plan → add stages → sync up → pull back → merge.
  - Local edit + remote edit → merge conflict resolution.
  - Soft-delete local → sync → remote reflects delete.
  - Partial sync failure mid-stage → state is consistent on retry.
  - Legacy data (optional dates absent) → sync normalization.
- `AppState.copyWith` footgun tests: assert that nullable fields behave as documented.

**Exit criteria:** Critical stage-planner flows pass against real SQLite + fake API. No mocks at the repository-DB boundary.

### Phase 3a — In-App DB Export Flow (beta-only)

Goal: give us a mechanism to collect anonymized real-user DB samples.

**Deliverables:**
- Hidden entry point in More tab (Remote Config flag or 7-tap easter egg), beta builds only.
- On tap, the app:
  1. Copies `app_database.db` + `stage_planner_database.db` to a temp location.
  2. Runs an **in-code anonymization pass**: nulls auth tokens, email/PII columns, push tokens, free-text notes. Preserves schema, row counts, dates, FKs.
  3. Zips both DBs + app version/build number into one archive.
  4. Opens system share sheet (AirDrop / email), with optional signed-S3-upload as a follow-up.
- Short internal doc for the product owner on how to guide beta testers through the export.

**Exit criteria:** Flow works in beta build; product owner has 3–5 anonymized archives in hand.

### Phase 3 — Golden DB Corpus

Goal: run migrations and core flows against anonymized real-user DB snapshots (collected via Phase 3a).

**Deliverables:**
- `packages/storage/test/golden_dbs/` with 3–5 anonymized DBs, fixture-named by shape (e.g., `long-plan-legacy-dates.db`, `pre-v2.2.364-orphans.db`).
- Second-pass PII scrub (beyond Phase 3a) before committing anything to the repo.
- `golden_migration_test.dart` that runs each golden DB through migration-to-current and asserts no data loss, no FK violations.

**Exit criteria:** Golden DBs pass migration + stage planner read-back in CI.

### Phase 4 — Release Telemetry, Guardrails & Incident Response

Goal: catch prod regressions within 48h and contain blast radius when they happen.

**Why not auto-rollback:** true rollback of a prod DB migration on mobile is infeasible — app stores don't downgrade, and destructive migrations can't be reversed post-facto. Our containment strategy below is what's actually achievable.

**Deliverables:**
- **Telemetry.** Extend the `SyncPlansResult` diagnostic pattern to `openDatabase` / migration steps. Emit typed analytics events for migration success/failure per (fromVersion, toVersion) pair.
- **Alerting.** Amplitude chart + alert: migration success rate by app version (threshold: <99%). Alert fires to team channel.
- **Feature-flag risky downstream paths.** Any code path that depends on a new schema ships behind Firebase Remote Config. If the migration goes wrong in prod, disable the dependent feature remotely within minutes instead of waiting on a store review.
- **Transactional migration policy.** Code-review checklist item: every migration must be transactional (already the current pattern — now enforced, not incidental). Documented in `CLAUDE.md` gotchas.
- **Hotfix SLA & runbook.** Document target <24h from alert → Play Store submission, <48h → App Store. Pre-built hotfix branch template.
- **Release checklist** (`docs/release-checklist.md`):
  - Pre-promote: migration tests green, golden DBs green, integration tests green, new schema usages flag-gated.
  - Post-release: watch migration-success + crash-free rate for 48h before moving on.

**Exit criteria:** Dashboard + alert live, checklist + runbook documented, `CLAUDE.md` updated with transactional-migration + feature-flag-on-schema-change requirements.

### Phase 5 (optional, follow-up branch) — Critical-path E2E

Not in scope for this branch. Separate branch `chore/stage-planner-e2e` using `integration_test` for: create plan → add stages → sync → kill app → reopen → verify.

## Execution Order

Parallelized with ongoing feature work on other branches. This branch runs alongside, not blocking feature velocity.

1. Phase 1 lands first (biggest risk reduction per hour of work).
2. Phase 2 in parallel once the harness util exists.
3. Phase 3a (in-app export) can start anytime; ship to beta early so the golden DBs collected by product owner arrive in time for Phase 3.
4. Phase 3 once ≥3 golden DBs are in hand.
5. Phase 4 last — lightweight; mostly dashboard + docs + `CLAUDE.md` updates.

**Release coupling:** work begins now but does not block the next planned release. Phase 1 + 2 can land in a release *after* the next one; Phase 4 guardrails should be in place before any subsequent migration ships.

## Risks & Tradeoffs

- **Maintenance cost:** every future DB change now requires a fixture + migration test. This is the point — it's the tax we pay to stop shipping bugs. Estimated +30–60 min per migration.
- **Golden DB collection is slow:** needs real user consent + anonymization. If it blocks Phase 3, ship Phases 1, 2, 4 first.
- **Fake API drift:** the hand-rolled fake must stay in sync with `ApiClient`. Mitigation: generate the fake from the Retrofit interface, or add a contract test that exercises both against a recorded response.
- **CI time:** migration + integration tests will add ~30–60s to CI. Acceptable.

## Estimated Effort

- Phase 1: 3–4 days (Flutter Expert)
- Phase 2: 3–4 days
- Phase 3a: 1.5 days (in-app export flow + anonymization)
- Phase 3: 2 days + product-owner-side data collection lead time
- Phase 4: 2 days (telemetry + flag policy + runbook + `CLAUDE.md` updates)

**Total: ~2.5 weeks of focused Flutter Expert work**, parallelized with other branches, excluding golden-DB collection lead time.

## Decisions (from product owner, 2026-04-21)

1. **Parallelize.** Harness work runs alongside ongoing feature branches, not in place of them.
2. **Golden DB collection: yes, with an in-app export mechanism.** Product owner will recruit beta testers; Phase 3a builds the flow (see above). No support-ticket scraping or manual device access.
3. **Ship after next release.** Next release goes out on current feature set; harness work lands in a subsequent release.
4. **No auto-rollback.** Infeasible for mobile DB migrations. Instead: alert (required) + feature-flag downstream schema consumers + transactional-migration policy + documented hotfix SLA.

## Next Step

Delegate Phase 1 to `flutter-expert` with a detailed task spec (on hold — product owner will trigger kickoff).
