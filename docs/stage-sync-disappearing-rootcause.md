# Stage Sync Disappearing — Root Cause

**Date:** 2026-05-07 (updated same day after PR #384 verification + share/import audit)
**Investigation doc:** `docs/stage-sync-disappearing-investigation.md`
**Verdict:** Defect 1 confirmed (catastrophic, primary cause). Defect 2 confirmed (secondary, contributes to "reorder" symptoms). Defect 3 confirmed but its impact has been downgraded (see status table below).

---

## Shipping status (PR #384 against `develop`)

| Fix | Status | Commit |
|---|---|---|
| Fix 1 — map `sentStages` by `stage_number` | **SHIPPED** | `ccbea7cb` |
| Fix 5 — compact `stage_number` to 1..N post-sync | **SHIPPED** | `3c4b5eee` |
| `deleteStage` renumber survivors (origin of `stage_number` gaps) | **SHIPPED** (Fix 7, added during investigation) | `892b2856` |
| DB v9 — backfill NULL/blank `stage_uuid` (origin of NULL UUIDs) | **SHIPPED** (Fix 8, added during investigation) | `9ad1ed62` + `28427c90` |
| Fix 2 — ambiguity-safe match in `upsertStageFromSync` | Deferred (defense-in-depth, no urgency) | — |
| Fix 3 — tombstone-based delete instead of `deleteStagesNotInIds` | Deferred (architectural, requires backend coordination) | — |
| Fix 4 — drop `@JsonKey(includeIfNull: false)` for `stage_uuid` on push | **DOWNGRADED to "cosmetic"** — see [Reassessment](#reassessment-fix-4-and-fix-6-after-shipping-fixes-1-5-7-8) | — |
| Fix 6 — one-shot SQL backfill of server-side NULL UUIDs | **DOWNGRADED to "optional cleanup"** — see [Reassessment](#reassessment-fix-4-and-fix-6-after-shipping-fixes-1-5-7-8) | — |

Verified end-to-end on Pixel 7 Pro emulator against the dev backend. See "Verifications" in PR #384 description for traces.

---

## TL;DR

The "stages disappear after sync" bug is caused by a **position-based UUID lookup that assumes contiguous `stage_number`**, in `_applySyncResponse` at `packages/repository/lib/src/stage_plan_repository.dart:1394–1398`:

```dart
final sentLocalStageUuid =
    stage.stageNumber - 1 < sentStages.length &&
            stage.stageNumber - 1 >= 0
        ? sentStages[stage.stageNumber - 1].stageUuid
        : null;
```

`sentStages` is a list **sorted by stage_number** but with potential gaps. Indexing by `stage.stageNumber - 1` only works if stage_numbers are contiguous `{1, 2, 3, …, N}`. When they aren't (and prod data shows ~10% of plans have gaps), this fetches the **wrong stage's UUID** as the match key. Combined with the destructive `deleteStagesNotInIds` step at line 1422, this causes:

1. **Wrong local stages get overwritten** with server data (data loss + identity scrambling)
2. **Stages with no match found** get silently deleted

The 50% prevalence of NULL `stage_uuid` rows on the server side (from the investigation doc) is then explained by Defect 3: `@JsonKey(name: 'stage_uuid', includeIfNull: false)` on the request model omits the field when null, so any UUID-less local stage that gets pushed creates a NULL-UUID row server-side. Once a NULL-UUID row exists, every subsequent sync triggers Defect 1's mis-matching and destroys data.

---

## Defect 1 — Position-by-stage_number indexing breaks for non-contiguous plans

**File:** `packages/repository/lib/src/stage_plan_repository.dart`
**Lines:** 1394–1398 (the index computation), 1399–1417 (the upsert call), 1422–1425 (the destructive delete)

### The bug

```dart
// stage_plan_repository.dart:1219–1227 — sentStages is sorted by stage_number
final stages = List<StageEntity>.from(plan.stages)
  ..sort((a, b) {
    final an = a.stageNumber ?? 1 << 30;
    final bn = b.stageNumber ?? 1 << 30;
    if (an != bn) return an.compareTo(bn);
    return a.id.compareTo(b.id);
  });
sentStagesMap[plan.uuid ?? ''] = stages;

// stage_plan_repository.dart:1394–1398 — index into that list by stage_number-1
final sentLocalStageUuid =
    stage.stageNumber - 1 < sentStages.length &&
            stage.stageNumber - 1 >= 0
        ? sentStages[stage.stageNumber - 1].stageUuid
        : null;
```

`sentStages[stage.stageNumber - 1]` assumes a **bijection** between stage_number and list index — i.e. stages are numbered exactly `1, 2, 3, …, N`. This is false for any plan with gaps.

### Why it's catastrophic

`sentLocalStageUuid` is fed into `upsertStageFromSync` at `packages/storage/lib/src/stage_planner_database_stages.dart:253`:

```dart
// stage_planner_database_stages.dart:289–303
Future<void> tryMatchByUuid(String? raw) async {
  if (existing != null) return;
  final uuid = raw?.trim();
  if (uuid == null || uuid.isEmpty) return;
  final rows = await txn.query(
    'stages',
    where: 'stage_plan_id = ? AND stage_uuid = ?',
    whereArgs: [stagePlanId, uuid],
    limit: 1,
  );
  if (rows.isNotEmpty) {
    existing = rows.first;
    matchSource = 'uuid:$uuid';
  }
}

// stage_planner_database_stages.dart:305–307
await tryMatchByUuid(serverStageUuid);
await tryMatchByUuid(sentLocalStageUuid);
```

So when the server's `stage_uuid` is null (prevalent — see investigation doc), the only match key is `sentLocalStageUuid`, which is **the wrong stage's UUID** for non-contiguous plans.

### Walk-through with user 16763 (gholtemann, bug #455/456)

Plan has 17 stages with stage_numbers `{1, 2, 3, 5, 6, 25, 26, 37–46}`. Position 5 in the sorted list is the stage with stage_number=25.

When server returns stage with `stage_number=5, stage_uuid=null`:
- `sentStages[5 - 1]` → `sentStages[4]` → the stage with **stage_number=6** (Pamplona → Puente la Reina, the NULL-UUID one)
- `sentLocalStageUuid` = stage 6's UUID (or null, since stage 6 had a NULL UUID)

In `upsertStageFromSync`:
- `tryMatchByUuid(serverStageUuid=null)` → skipped
- `tryMatchByUuid(sentLocalStageUuid=stage 6's UUID)` → matches **stage 6's row**, not stage 5's
- The server's stage 5 data overwrites stage 6's row
- `matchedLocalIds.add(stage 6's id)`

When server returns stage with `stage_number=6, stage_uuid=null`:
- `sentStages[6 - 1]` → `sentStages[5]` → stage with **stage_number=25**
- And so on — chained mis-matching

Then at line 1422–1425:

```dart
await _stagePlannerDatabase.deleteStagesNotInIds(
  stagePlanId: localPlanId,
  localIds: matchedLocalIds,
);
```

`deleteStagesNotInIds` (`stage_planner_database_stages.dart:472–493`) deletes every local stage whose id isn't in `matchedLocalIds`. Stages that didn't get a correct match are wiped.

This is exactly user 16763's symptom: "stage between Puente la Reina and Ayegui keeps deleting on every sync." The very stage with NULL UUID is the one that triggers the cascade.

### Counterevidence considered

- Could the `stage_number` fallback save us? `upsertStageFromSync` at line 309–321 falls back to matching by `stage_plan_id + stage_number`, but **only if `existing` is still null**. The bad `sentLocalStageUuid` match at line 307 succeeds first and prevents the fallback.
- Could the user's plan just be unstable due to multi-device? Single-device users (gholtemann is on one Samsung S911B) reproduce the bug, so multi-device isn't required.

---

## Defect 2 — Server-driven `stage_number` chaos persisted verbatim

**File:** `packages/repository/lib/src/stage_plan_repository.dart`
**Lines:** 1399–1417

### The bug

```dart
final localId = await _stagePlannerDatabase.upsertStageFromSync(
  stagePlanId: localPlanId,
  stageNumber: stage.stageNumber,        // ← server-supplied
  ...
);
```

Local `insertStageAfter` at line 323–371 does `shiftStageNumbersAfter` correctly to keep numbers contiguous. But the sync response handler writes server's `stage_number` verbatim with no normalization. There's no client-side renumbering pass after `_applySyncResponse`.

### Why it matters

If the server allocates `stage_number` lazily (e.g. `MAX(stage_number) + 1` without renumbering on insert/delete), client picks up the chaos on every pull. Prod data shows patterns like `{1–7, 10–16, 38–44}` and `{1–20, 40–49, 52, 105–111}` — these are not what the local client allocator produces.

This isn't itself fatal, but it directly **enables Defect 1**: every gap in stage_number breaks the position-based UUID lookup. Defect 2 is the *fuel*, Defect 1 is the *match*.

### Bug #400 (edouard.graf) — "first 2 stages moved to end after Santiago" — explained

When stage_numbers reorder (via Defect 2), a stage formerly numbered 1 might now be numbered 36, displayed at the end of a 35-stage plan. The user sees their first stages "moved to after Santiago." No data loss — just chaotic ordering — but UX is identical to deletion from the user's perspective.

---

## Defect 3 — `stage_uuid` omitted from request payload when null

**File:** `packages/remote_data/lib/src/models/sync/sync_stage_planner_request.dart`
**Lines:** 113–114

```dart
@JsonKey(name: 'stage_uuid', includeIfNull: false)
final String? stageUuid;
```

When a local stage has null `stageUuid`, this field is **omitted entirely** from the JSON push payload. The server then has no way to distinguish "client wants me to assign a UUID" from "client is referencing an existing UUID."

### How NULL-UUID rows arise on the server

Path: any local stage with NULL `stageUuid` gets pushed → server stores the row without a UUID → that row becomes a permanent NULL-UUID stage that triggers Defect 1 on every subsequent sync for any device that pulls this plan.

### Where do local NULL-UUID stages come from?

I traced every client-side stage creation path:

| Path | Location | UUID assigned? |
|---|---|---|
| `_insertStageRaw` direct insert | `stage_planner_database_stages.dart` (around DB v8 backfill) | Yes — generates UUID via `_uuid.v4()` if entity has none |
| `insertStageAfter` (insert-between) | `stage_plan_repository.dart:323–371` → `createStage` | Yes (relies on `_insertStageRaw`) |
| `upsertStageFromSync` insert path | `stage_planner_database_stages.dart:376–400` | Yes — generates UUID if neither server nor sent UUID is present |
| `upsertStageFromSync` update path | `stage_planner_database_stages.dart:340–375` | Yes — backfills NULL UUIDs from server, sent, or generates new |
| v8/v9 migration backfill | `stage_planner_database.dart` (per memory: "v9 adds whichever is missing + backfills `stage_uuid`") | Yes |

So the **client cannot produce a NULL-UUID local row** anymore. The 50% prevalence in prod must come from:

- **Pre-v8 stages** that never went through the v9 backfill migration (e.g. devices still on older app versions), OR
- **Server-side NULL UUIDs that round-tripped back to client**, but the upsert paths backfill these. So on round-trip, local should be healed.
- **Most likely**: pre-v8 client pushes that the server stored with NULL UUID. Those rows persist server-side forever (Defect 3 means client never asks the server to assign one). When a v9 client pulls them, it backfills the local copy, but the server stays NULL.

---

## Execution flow — the disappearing-stage cascade

```
User edits stage / adds accommodation / inserts stage between
  ↓
StagePlanRepository.updateStagePartial() / insertStageAfter()
  ↓
Local DB write (UUID intact, stage_number maybe gappy)
  ↓
Cubit triggers syncPlans()
  ↓
Build SyncStageRequest list — sentStages sorted by stage_number     [stage_plan_repository.dart:1219]
  ↓
toJson() — stages with NULL stageUuid omit the field                [request.dart:113 includeIfNull: false]
  ↓
POST /api/v1/stage-planner/sync
  ↓
Server response. Some stages have stage_uuid: null (legacy rows)
  ↓
_applySyncResponse() processes each response stage                  [stage_plan_repository.dart:1334]
  │
  ├─ For each response stage with stage_number=N:
  │     sentLocalStageUuid = sentStages[N - 1].stageUuid             [stage_plan_repository.dart:1394]
  │     ★ WRONG INDEX when local has gappy stage_numbers
  │
  ├─ upsertStageFromSync(serverUuid, sentLocalStageUuid)             [stage_planner_database_stages.dart:253]
  │     tryMatchByUuid(serverUuid)        — null when server lost UUID
  │     tryMatchByUuid(sentLocalStageUuid) — WRONG STAGE matched
  │     Fallback by stage_number          — never reached after wrong match
  │     ★ Wrong local row gets overwritten with server data
  │
  ├─ matchedLocalIds.add(wrongStageId)
  │
  └─ deleteStagesNotInIds(matchedLocalIds)                           [stage_plan_repository.dart:1422]
        ★ All local stages not matched are DELETED
```

---

## Suggested minimal fixes (DO NOT IMPLEMENT — describe only)

### Fix 1 (highest impact, smallest diff) — index `sentStages` by stage_number, not by position

**File:** `packages/repository/lib/src/stage_plan_repository.dart` around line 1372 and 1394.

Build a lookup map alongside the sorted list:

```dart
// ~line 1372, in _applySyncResponse
final sentStages = sentStagesMap[responsePlan.uuid] ?? [];
final sentByNumber = <int, StageEntity>{
  for (final s in sentStages)
    if (s.stageNumber != null) s.stageNumber!: s,
};

// ~line 1394, replace the index math with a map lookup
final sentLocalStageUuid = sentByNumber[stage.stageNumber]?.stageUuid;
```

This eliminates Defect 1 entirely. **Single defect line; small, surgical change.** Would have prevented the entire cascade for users 16763, 13232, 17760, 18495, 8489, 19839, 18163, 515 (every NULL-UUID user in the investigation).

### Fix 2 — ambiguity-safe match in `upsertStageFromSync`

**File:** `packages/storage/lib/src/stage_planner_database_stages.dart` around line 305–321.

When `serverStageUuid` is null AND `sentLocalStageUuid` is null, fall through to stage_number match — but if **multiple** local rows share the stage_number (shouldn't happen but might during corruption recovery), refuse to match and force an insert + log a diagnostic. Also: when `tryMatchByUuid` fails on a UUID, prefer matching by stage_number than blindly trying the next UUID. This is defense-in-depth on top of Fix 1.

### Fix 3 — never silently delete unmatched local stages on sync

**File:** `packages/repository/lib/src/stage_plan_repository.dart` around line 1422.

`deleteStagesNotInIds` deletes any local stage that wasn't matched in the response. This is too destructive given the matching can be wrong. Replace with a tombstone approach:

- Server returns explicit `deleted_stage_uuids` list (requires backend coordination).
- Client only deletes local rows whose UUID is in that list.
- Local rows that are not echoed back AND not tombstoned are kept (assume server response was incomplete).

Without backend coordination, a cheaper interim fix: only delete local stages whose UUID is present in the local row AND was sent in the request AND wasn't echoed back. Local rows with no UUID OR not sent in the request are never touched. This protects against most failure modes.

### Fix 4 — always serialize `stage_uuid`, even when null

> **Status (2026-05-07): downgraded to cosmetic.** See [Reassessment](#reassessment-fix-4-and-fix-6-after-shipping-fixes-1-5-7-8). After Fix 8 (v9 backfill) ships and clients update, the local DB invariant guarantees every stage has a UUID at serialization time. The `includeIfNull: false` flag becomes a no-op in practice. The change is still defensible as defense-in-depth but is not load-bearing for the sync correctness story.

**File:** `packages/remote_data/lib/src/models/sync/sync_stage_planner_request.dart` line 113.

Change to:

```dart
@JsonKey(name: 'stage_uuid')
final String? stageUuid;
```

(remove `includeIfNull: false`). Server contract change: treat `"stage_uuid": null` as "client requests UUID assignment." Server echoes the new UUID back. Coordinated backend change required.

Originally framed as the way to stop new NULL-UUID rows from appearing server-side. With Fix 8 in place the client never sends null `stage_uuid` anyway, so this is no longer the load-bearing fix.

### Fix 5 — client-side stage_number compaction on response

**File:** `packages/repository/lib/src/stage_plan_repository.dart` around line 1426.

After processing all response stages, run a per-plan pass: sort stages by `stage_number`, rewrite `stage_number = index + 1`. Compacts `{1–7, 10–16, 38–44}` to `{1..21}`. Eliminates the "stages reordered" symptoms (~10 reports) and removes the conditions that enable Defect 1.

This is independent of Fix 1 (Fix 1 would still be necessary), but addresses Defect 2's user-visible symptoms.

### Fix 6 — backfill server-side NULL `stage_uuid` rows

> **Status (2026-05-07): downgraded to optional cleanup.** See [Reassessment](#reassessment-fix-4-and-fix-6-after-shipping-fixes-1-5-7-8). The combination of Fix 1 + Fix 8 makes the system self-heal: when a v9+ client pulls a server-side NULL-UUID row, `upsertStageFromSync`'s generator path assigns a UUID locally, and the next push propagates it to the server. So existing NULL-UUID rows get cleaned up organically as users open the app. Fix 6 is acceleration / hygiene for analytics, not correctness.

**One-shot SQL** on prod backend (not in client code):

```sql
UPDATE plans SET stages = (
  SELECT jsonb_agg(
    CASE WHEN s ? 'stage_uuid' AND s->>'stage_uuid' IS NOT NULL
         THEN s
         ELSE s || jsonb_build_object('stage_uuid', gen_random_uuid()::text)
    END
  )
  FROM jsonb_array_elements(stages::jsonb) s
)
WHERE deleted_at IS NULL
  AND EXISTS (
    SELECT 1 FROM jsonb_array_elements(stages::jsonb) s
    WHERE NOT (s ? 'stage_uuid') OR s->>'stage_uuid' IS NULL
  );
```

Coordinate with backend team. This heals the 50% prevalence stat — but only after Fix 4 is deployed (otherwise a v8 client could re-null them on next push).

---

## Rollout order — superseded

> The original recommended order below was written before the investigation expanded to cover the upstream causes (delete-renumber and v9 backfill). What actually shipped in PR #384 is captured in the [Shipping status](#shipping-status-pr-384-against-develop) table at the top of this doc. Fixes 4 and 6 were re-evaluated and downgraded — see [Reassessment](#reassessment-fix-4-and-fix-6-after-shipping-fixes-1-5-7-8). Fix 2 and Fix 3 remain deferred.

### Original (pre-shipping) recommendation, kept for posterity

1. **Fix 1** — ship immediately (one-line patch, no backend coordination, protects every user from new occurrences). **Most users will stop reporting the bug after this lands.**
2. **Fix 5** — adds defense in depth and addresses reorder symptoms. Same release as Fix 1.
3. **Fix 3 (interim version)** — same release. Reduces blast radius if any other matching defect surfaces.
4. **Fix 4 + Fix 6** — coordinate with backend; ship in a follow-up release. Heals prevalence permanently.
5. **Fix 2** — defense in depth, no urgency once 1+5 ship.

---

## File:line citation index (verified against actual source)

| Concern | Citation |
|---|---|
| Position-by-stage_number bug (Defect 1) | `packages/repository/lib/src/stage_plan_repository.dart:1394–1398` |
| Sorted sentStages source | `packages/repository/lib/src/stage_plan_repository.dart:1219–1227` |
| upsertStageFromSync match logic | `packages/storage/lib/src/stage_planner_database_stages.dart:289–321` |
| upsertStageFromSync existing-row update | `packages/storage/lib/src/stage_planner_database_stages.dart:340–375` |
| upsertStageFromSync new-row insert | `packages/storage/lib/src/stage_planner_database_stages.dart:376–400` |
| Destructive deleteStagesNotInIds | `packages/repository/lib/src/stage_plan_repository.dart:1422–1425` |
| deleteStagesNotInIds impl | `packages/storage/lib/src/stage_planner_database_stages.dart:472–493` |
| Defect 3: includeIfNull on push | `packages/remote_data/lib/src/models/sync/sync_stage_planner_request.dart:113–114` |
| Same on response model | `packages/remote_data/lib/src/models/sync/sync_stage_planner_response.dart:129–130` |
| insertStageAfter (correct local logic) | `packages/repository/lib/src/stage_plan_repository.dart:323–371` |
| healMissingStageNumbers (pre-sync heal) | `packages/storage/lib/src/stage_planner_database_stages.dart:502+` |

---

## What this investigation does NOT cover

- **Server-side allocator**: I did not read the Go backend. Defect 2's root cause (chaotic stage_numbers) likely lives there. Need a follow-up investigation in `camino-ninja-backend-go`.
- **The accommodation-selection flow specifically**: 3 reports describe "select accommodation → stage erased." I traced `updateStagePartial` and confirmed the local update is safe. The disappearance happens on the **next sync** after the cubit fires `_notifySyncNeeded()` — so the proximate cause is still Defect 1 + 3, with accommodation-selection just being the trigger that flushes a sync. This is consistent with Lara's bug report ("losing stages on share" — share triggers sync).
- **Multi-device interactions**: investigated 16763 (single device) is sufficient to prove the defect; multi-device just compounds the chaos via Defect 2.

---

## Reassessment: Fix 4 and Fix 6 after shipping Fixes 1, 5, 7, 8

The original write-up framed Fix 4 (drop `includeIfNull: false`) and Fix 6 (server-side SQL backfill) as essential to closing the loop on NULL `stage_uuid` rows. Empirical re-examination after shipping the other fixes shows both are over-engineered for the actual post-fix world.

### Why Fix 4 is no longer load-bearing

After **Fix 8** (DB v9 backfill, commit `9ad1ed62` + `28427c90`), every local stage on a v9+ device has a non-null `stage_uuid`:
- `createStage` (`stage_planner_database_stages.dart:48`) generates a UUID at insert time
- v9 migration backfills any pre-existing NULL/blank rows on app launch
- `upsertStageFromSync` generates a UUID when both server and sent UUIDs are null (lines 354–358)

So the client never has a null `stageUuid` at JSON serialization time. The `@JsonKey(includeIfNull: false)` flag is effectively a no-op — the field is always present. Removing the flag is cosmetic. The defensive value is real but small (catches a hypothetical future regression introducing a NULL-UUID code path), and `flutter analyze` + tests catch this anyway.

### Why Fix 6 is no longer load-bearing

The combination of Fix 1 + Fix 8 makes the system self-heal:
1. v9+ client pulls a server-side NULL-UUID row
2. `upsertStageFromSync` matches by `stage_number` fallback (Fix 1's fixed path)
3. Generates a UUID locally via the existing generator (`stage_planner_database_stages.dart:354–358`)
4. On next sync push, client sends the new UUID; server adopts it
5. NULL row on server is healed in one round-trip

So the existing ~50% prevalence of server-side NULL UUIDs **decays organically** as users open the v9+ client. Fix 6 (one-shot SQL) just accelerates that. It's hygiene, not correctness.

### Net implication for rollout

Fixes 4 and 6 can be skipped entirely without functional harm. They might still be worth shipping for:
- **Fix 4**: cleaner JSON contract; defensive against future regression
- **Fix 6**: faster convergence so analytics dashboards on `stage_uuid IS NULL` stabilize quickly

Neither is urgent. Neither is a prerequisite for declaring this bug closed.

---

## Share/import flow audit (verified clean — 2026-05-07)

Concern raised: when User A shares a plan and User B imports it, would User B's local plan inherit User A's plan UUID and stage UUIDs, causing collisions on subsequent sync push or re-import?

### Empirical answer: no collision risk in practice

Three independent safeguards conspire to keep the import flow clean:

**Safeguard 1 — backend strips plan UUID from the response.** The Go backend's `GetSharedPlan` handler at `camino-ninja-backend-go/internal/modules/stage_planner/handler.go:247–257` explicitly excludes `uuid`, `plan_uuid`, and `reference_plan_uuid` from the JSON, with a comment `// IMPORTANT: Exclude UUID from response to prevent direct access`.

Verified empirically against the dev backend:
```
$ curl http://ec2-...:8080/api/v1/stage_planner/shared/aysY3k1k
{
  "name": "Test 2",
  "route_id": 1,
  "route": { ... },
  "starting_date": null,
  "trail_descriptor": null,
  "stages": [ ... ],
  "cities": [ ... ],
  "albergues": null
}
```

No `uuid`. So in `lib/tabs/plan/services/stage_plan_share_service.dart:143–150`:

```dart
final serverUuid = plan.uuid;  // always null because server stripped it
if (serverUuid != null && serverUuid.isNotEmpty) {
  await _stageRepository.updateStagePlanUuids(...);  // never fires
}
```

The local plan keeps its `createStage`-generated uuid. **Plan UUID collision: impossible.**

**Safeguard 2 — Flutter `SharedStageResponse` model omits `stage_uuid` field.** The server *does* include `stage_uuid` in each stage object in the response (verified empirically). However the Flutter deserialization model at `packages/remote_data/lib/src/models/shared/shared_plan_response.dart:38–102` defines no `stage_uuid` property — `fromJson` silently drops the field. So when `importPlans` calls `createStage` for each stage, it has no UUID to pass and a fresh one is generated locally.

This safeguard is **probably accidental** rather than designed. The unique index `(stage_plan_id, stage_uuid)` is per-plan, so even if the field were preserved, collisions only fire if two stages within the same imported plan had the same UUID — which the server wouldn't produce. Still: this is fragile. If anyone adds `stage_uuid` to `SharedStageResponse` in the future, the import flow needs auditing for whether existing UUIDs should be preserved or regenerated.

**Safeguard 3 — `createStage` always generates a UUID.** Even if both safeguards above failed, `createStage` would overwrite any incoming UUID with a fresh `_uuid.v4()`. Belt and suspenders.

### Latent risks worth flagging

- **`updateStagePlanUuids` call in `importPlans` is dead code** as long as Safeguard 1 holds. It only fires if the server starts returning `uuid` for shared plans, which would re-introduce the collision risk this audit just ruled out. Could be removed in a cleanup PR with a comment explaining why.
- **The server's `POST /stage_planner/import/{code}` endpoint exists but is never called by the Flutter client.** It properly creates a server-side copy with `ReferencePlanUUID` linking back to the original (`service.go:510–534`). The current client implementation does pure local import with no server-side lineage tracking. If a future feature wants share→import analytics or "this is a copy of X" UX, switching to the server endpoint is the right path.

### Conclusion

Share/import is not a contributor to the disappearing-stages bug. No additional fix needed in this PR scope.
