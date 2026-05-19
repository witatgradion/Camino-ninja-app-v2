# Stage Planner Sync — Stages Disappearing Investigation

**Date:** 2026-05-07
**Trigger:** User bug report from Lara Noack (DE) — stages keep disappearing after sharing/sync
**Scope:** 14 days of bug reports + prod DB analysis

---

## TL;DR

`~35%` of plans active in the last 14 days have at least one stage with `stage_uuid = NULL` on the server. Both iOS and Android are affected at similar rates. The UUID-less stages cluster near the end of plans (avg relative position 0.87), strongly suggesting they are user-inserted stages that never got a UUID assigned client-side. On subsequent sync pulls, the client's merge logic appears to drop these UUID-less stages, manifesting as the widely reported "stages disappear after sync" bug.

A second, related defect produces non-contiguous `stage_number` gaps (e.g. `{1–7, 10–16, 38–44}`), causing reordering / "stages moved to the end" symptoms.

---

## Bug-report cluster (last 14 days)

At least **25+ of ~100 reports** describe variants of the same problem. Three sub-symptoms:

### A. Stages disappear after sync (~12 reports)
- `#456 / #455` (gholtemann, DA): Stage keeps getting deleted every time it syncs (between Puente la Reina and Ayegui)
- `#428` (michael.deseife, DE): "Synchronization is deleting my saved stages... must recreate all subsequent stages"
- `#423` (amzi007.az, DE): "Stage 15 disappears every time after sync"
- `#440`: "changes made to plan delete when syncs"
- `#367` (autdraw.marcelo, PT): "app deleted a stage... when I sync, the stage disappears again" — verbatim match for Lara's report
- `#376` (mag.popovich): "Plan changes are not syncing... keeps syncing to old save with missing cities"
- `#365` (kerstinboonk476, DE): Route gone after a few hours, must restart
- `#445`: "deleted my whole plan???"
- `#442` (RU): "Stages 3 and 4 are missing"
- `#378` (DE): "All my Via Podiensis entries deleted"
- `#409`: "deleted first 2 stages of my Camino"

### B. Adding accommodation deletes the stage (3+ reports — clear repro)
- `#354` (f5ptgtmky2): "selecting accommodation on a stage... it's dropping out that stage all together"
- `#363` (peter): "When I add a place to stay... the complete stage is removed from the itinerary"
- `#364` (yooshinc): "Choosing staying albergue in a stage then that stage is erased and stage discontinuity error shown"

### C. Stages reorder / dates scramble after sync or update (~10 reports)
- `#400` (edouard.graf): First two stages disappeared and got appended after Santiago
- `#359` (eberhardwypior, DE): "1st stage now shown as 13th stage"
- `#355`: "When changing a stage it adds it to the start. Changes dates of all stages. New issue since updates"
- `#393`: "Stages out of order with wrong dates" — and again after a second open
- `#402` (DE): "Route suddenly in reverse order without my doing"
- `#386` (DE): "All route sections in disarray since the last update"
- `#372`: "Keeps changing order of my stages by itself"
- `#396`: "All the dates have mixed up on my planned route"
- `#417`: "Plan totally out of order with incorrect dates"
- `#405`: "Stages added to connect gaps... next day put at the first"

Reports tagged "since updates" / "last update" cluster from **2026-04-23 onward**, aligning with `release/v2.2.400` activity and the `2.2.393` hotfix rollout window.

---

## Production DB evidence

### Global prevalence

```
bucket          | plans  | users  | stages   | missing_uuid_stages
----------------+--------+--------+----------+--------------------
all_have_uuid   |  5,543 |  3,876 |   52,478 |             0
mixed           |  1,330 |  1,183 |   13,360 |         1,888
NONE_have_uuid  |  6,582 |  4,939 |   50,880 |        50,880
```

**~50% of all plans have zero stages with `stage_uuid`. Another 10% are mixed.**

### Plans active in last 14 days, by platform

```
platform | bucket          | plans | users
---------+-----------------+-------+------
Android  | all_have_uuid   |  2008 |  1393
Android  | mixed           |   469 |   418
Android  | NONE_have_uuid  |   490 |   406
iOS      | all_have_uuid   |  3339 |  2398
iOS      | mixed           |   844 |   749
iOS      | NONE_have_uuid  |   980 |   824
```

- Android: **~32% of active plans have at least one stage missing `stage_uuid`**
- iOS:     **~35%** — both platforms affected at similar rates

### Position pattern — UUID-less stages are user-inserted stages

For mixed plans (some stages with UUID, some without):

```
state    | stages | avg_relative_position | avg_index | avg_plan_size
---------+--------+-----------------------+-----------+--------------
has_uuid | 11,417 |                  0.50 |       9.4 |          18.9
no_uuid  |  1,875 |                  0.87 |       9.7 |          11.7
```

UUID-less stages cluster near the end of plans (rel position 0.87) and live in smaller plans. This is consistent with: *original auto-generated stages get UUIDs; user-added stages do not*.

---

## Per-user smoking guns

### User 16763 (gholtemann, #455/456) — Lara's twin report

Plan `db941c46-1494-4db7-965b-bcd73c083f0f`, 17 stages:
```
| num | uuid   | start_name              | end_name                | updated_at                   |
|-----+--------+-------------------------+-------------------------+------------------------------|
| 1   | 921bb… | Saint-Jean-Pied-de-Port | Orisson                 | 2026-05-06T17:14:18Z         |
| 2   | 1c459… | Orisson                 | Roncesvalles            | 2026-04-26T06:15:37Z         |
| 3   | f1a9f… | Roncesvalles            | Zubiri                  | 2026-05-05T14:50:58Z         |
| 5   | 5be7a… | Zubiri                  | Pamplona                | 2026-05-05T08:32:02Z         |
| 6   | NULL   | Pamplona                | Puente la Reina         | NULL                         |
| 25  | 43712… | Ayegui                  | Sansol                  | 2026-05-05T15:03:36Z         |
| 26  | 729b9… | Sansol                  | Logroño                 | 2026-05-06T16:57:35Z         |
| ... | ...    | ...                     | ...                     | ...                          |
```

Stage 6 — the **only one with `NULL stage_uuid`** — is the stage the user reports keeps disappearing on sync (Pamplona → Puente la Reina, in the gap between stage_number 6 and Ayegui's 25). Chain breaks at exactly that point.

### User 13232 (michael.deseife, #428) — all-NULL plan

Plan `5b08cbee-1dfc-4ad0-8642-e100a678b5cd`, 14 stages, **all 14 have `stage_uuid = NULL`**.

```
num | start_name               | end_name                 | updated_at
----+--------------------------+--------------------------+-----------
  1 | Ponferrada               | Borrenes                 | 2026-04-06
  ...
  9 | Diomondi                 | Vilaseco                 | NULL
 14 | Vilaseco                 | Rodeiro                  | 2026-05-06
 15 | Rodeiro                  | Lalín                    | 2026-05-06
  ...
 18 | Ponte Ulla               | Santiago de Compostela   | 2026-05-06
```

Note `stage_number` jumps 9 → 14 (missing 10–13 — exactly what the user said keeps getting deleted after every sync).

### Cross-user summary table

Of 16 affected users investigated, 8 have at least one `NULL stage_uuid` in production:

| user_id | bug | stages | NULL uuids | stage_number set                                         |
|---------|-----|--------|------------|----------------------------------------------------------|
| 13232   | #428 | 14   | 14         | {1–9, 14–18}                                             |
| 17760   | #373 | 2    | 2          | {1, 2}                                                   |
| 18495   | #374 | 1    | 1          | {1}                                                      |
| 16763   | #455/456 | 17 | 1     | {1,2,3,5,6,25,26,37–46}                                  |
| 8489    | #384 | 2    | 2          | {1, 2}                                                   |
| 19839   | #440 | 59   | 1          | {2,9–14,17–19,26,31,32,35,36,37–79} (chaotic)            |
| 18163   | #367 | 40   | 1          | {2–17, 28–51}                                            |
| 515     | #354 | 31   | 1          | {1–12, 18–36}                                            |
| 309     | #364 | 37   | 0          | {1–20, 40–49, 52, 105–111}                               |
| 16288   | #423 | 20   | 0          | {1–7, 10–16, 38–44}                                      |
| 17013   | #409 | 34   | 0          | {1, 3–16, 18–36}                                         |
| 19403   | #400 | 35   | 0          | {1–35} (continuous)                                      |
| 16117   | #363 | 41   | 0          | {1–41} (continuous)                                      |
| 17842   | #376 | 14   | 0          | {1–14} (continuous)                                      |
| 4296    | #442 | 13   | 0          | {2,3, 6–16}                                              |

Half the affected users show NULL UUIDs; the rest show non-contiguous `stage_number` (Defect B).

---

## Hypothesis

Two related defects, both producing the same family of symptoms:

### Defect A — `stage_uuid` not assigned on client-side stage creation

When a user adds a stage (insert-between flow, accommodation-selection flow, or fill-gap flow), the client persists it locally and pushes to sync **without** `stage_uuid`. Server stores JSON verbatim with the missing field. On next pull, the merge logic (`_applySyncResponse`) appears to treat UUID-less stages as non-keyed and drops/dedups them — they vanish.

### Defect B — `stage_number` allocator picks bad numbers on insert

When inserting a stage between two existing ones, the new `stage_number` is allocated in a way that doesn't shift neighbours, producing chaotic ordering (`{1–7, 10–16, 38–44}`). The UI rendering / sync merge sometimes mishandles this, causing reordering or "stages moved to end" symptoms.

---

## Investigation directives for `bug-analyzer`

1. **Find all client paths** that build a `StageEntity` / `StageModel` for sync push and verify whether `stageUuid` is ever left null. Focus on:
   - The "insert stage between" / "stages-not-connected card" flow
   - The accommodation-selection flow that triggers stage updates
   - Any path that creates a stage outside `StagePlanRepository.addStage`
2. **In `_applySyncResponse`** (`packages/repository/lib/src/stage_plan_repository.dart`): how does the merge handle a stage whose `stageUuid` is null? Does it match on a fallback key (e.g. `stage_number`, `start_city_id + end_city_id`)? Or drop?
3. **Audit the `stage_number` allocator** on insert-between to understand why gaps like `{1–7, 10–16, 38–44}` appear and how the client sorts/renders such sets.
4. **Check if any migration paths** (v5→v7→v8→v9) drop `stage_uuid` when copying rows.

---

## Data sources

- Bug reports JSON: `/private/tmp/bug-reports/bug_reports_last_14d.json` (last 14 days, ~100 reports)
- Prod DB: `camino-ninja-prod.cpck86owqq0n.eu-central-1.rds.amazonaws.com:5432/camino_ninja`
- Tables queried: `plans` (stages stored as JSON column), `cities`
