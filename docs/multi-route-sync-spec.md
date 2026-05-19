# Multi-Route Trail Sync — Backend Specification

## Overview

The app supports multi-route trail plans where a pilgrim's journey crosses multiple Camino routes via junction cities. This document specifies the data structure changes needed on the backend to support syncing these plans.

## Current State

### Server
- Plans table stores stages as a JSON blob inside the plan record
- No awareness of multi-route trails or junctions

### App (Client)
- SQLite `stage_plans` table + separate `stages` table
- `trail_route_ids` column on `stage_plans` stores trail descriptor (local-only, not synced)
- Cross-route stage stitching happens at the repository layer using trail descriptor + city positions

## Proposed Data Structure

### Plans Table

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| id | INTEGER / UUID | No | Primary key |
| route_id | INTEGER | No | Primary/starting route. Keep for backward compatibility. |
| name | TEXT | Yes | User-defined plan name |
| trail_descriptor | TEXT (JSON) | Yes | Multi-route trail definition. `null` for single-route plans. |
| created_at | TIMESTAMP | No | |
| updated_at | TIMESTAMP | Yes | |
| deleted_at | TIMESTAMP | Yes | Soft delete |

#### `trail_descriptor` Format

A JSON array of trail segment descriptors, ordered in walking direction:

```json
[
  {"r": 1},
  {"r": 3, "j": 250}
]
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `r` | int | Yes | Route ID for this segment |
| `j` | int | No | Junction city ID where the trail switches to this route. Absent for the first segment. |

**Examples:**

- Single-route plan: `trail_descriptor` is `null` (or omitted)
- Two-route plan (Camino Portugués Central → Caminho Nascente e Poente, junction at Tomar):
  ```json
  [{"r": 5}, {"r": 12, "j": 847}]
  ```
- Three-route plan:
  ```json
  [{"r": 1}, {"r": 3, "j": 250}, {"r": 7, "j": 412}]
  ```

### Stages Table (Recommended: Extract from JSON Blob)

Moving stages to their own table improves queryability and consistency. If extracting stages is too large a change initially, the existing JSON blob approach works — just ensure `trail_descriptor` is included in the plan sync payload.

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| id | INTEGER / UUID | No | Primary key |
| plan_id | INTEGER / UUID | No | FK to plans table |
| stage_number | INTEGER | Yes | Ordering within the plan |
| route_id | INTEGER | No | The route this stage is ON (starting route for cross-route stages) |
| date | TEXT | No | Stage date |
| start_city_id | INTEGER | No | |
| end_city_id | INTEGER | No | |
| start_albergue_id | INTEGER | Yes | |
| end_albergue_id | INTEGER | Yes | |
| custom_start_notes | TEXT | Yes | |
| custom_end_notes | TEXT | Yes | |
| stage_notes | TEXT | Yes | |
| created_at | TIMESTAMP | Yes | |
| updated_at | TIMESTAMP | Yes | |

#### Cross-Route Stages

A stage that crosses a junction (starts on route A, ends on route B) stores `route_id` as the **starting route**. The app derives the full cross-route path at runtime using:

1. The plan's `trail_descriptor` to know the route sequence and junction cities
2. `start_city_id` and `end_city_id` to determine which segments the stage spans
3. Route point data (cached locally) to stitch the polyline across routes

**The server does not need to understand cross-route stitching.** It just persists `route_id`, `start_city_id`, `end_city_id`, and the plan's `trail_descriptor`. The client handles the rest.

## Sync API Changes

### Plan Payload

Add `trail_descriptor` to the plan sync request/response:

```json
{
  "uuid": "plan-uuid-123",
  "route_id": 5,
  "name": "My Camino Plan",
  "trail_descriptor": [{"r": 5}, {"r": 12, "j": 847}],
  "stages": [
    {
      "uuid": "stage-uuid-1",
      "stage_number": 1,
      "route_id": 5,
      "date": "2026-04-01",
      "start_city_id": 100,
      "end_city_id": 847
    },
    {
      "uuid": "stage-uuid-2",
      "stage_number": 2,
      "route_id": 12,
      "date": "2026-04-02",
      "start_city_id": 847,
      "end_city_id": 900
    }
  ],
  "created_at": "2026-03-19T10:00:00Z",
  "updated_at": "2026-03-19T10:00:00Z"
}
```

### Backward Compatibility

- `trail_descriptor` is nullable. Old plans and old app versions omit it.
- When `trail_descriptor` is `null`, the plan is single-route — existing behavior applies.
- Old clients that don't understand `trail_descriptor` will ignore it. They can still display stages (each has `route_id`, `start_city_id`, `end_city_id`) — they just won't render the cross-route trail visualization.

## Migration Path

1. **Phase 1 — Minimal**: Add `trail_descriptor` as a nullable JSON/TEXT column to the plans table. Include it in sync request/response. No other backend changes needed — the client handles all junction logic.

2. **Phase 2 — Recommended**: Extract stages from the JSON blob into a proper stages table. This enables server-side queries (e.g., "which plans include city X?", analytics on popular routes).

3. **Phase 3 — Optional**: Parse `trail_descriptor` server-side for analytics (e.g., most popular junction choices, common multi-route combinations).

## What the Server Does NOT Need To Do

- **No junction detection logic** — the app handles this using local route/city data
- **No cross-route polyline stitching** — the app handles this at the repository layer
- **No validation of junction city IDs** — the app ensures these are valid before saving
- **No understanding of route geography** — just persist the IDs

## App-Side Reference

| App Column | Sync Field | Notes |
|------------|------------|-------|
| `stage_plans.trail_route_ids` | `plan.trail_descriptor` | Renamed for clarity in API |
| `stages.route_id` | `stage.route_id` | Starting route for cross-route stages |
| `stages.start_city_id` | `stage.start_city_id` | |
| `stages.end_city_id` | `stage.end_city_id` | |

## Key Decisions

1. **Trail descriptor lives on the plan, not on stages** — it describes the overall trail shape, not individual stage routing. One source of truth.

2. **`route_id` on stages is the starting route** — simpler than storing start/end route pairs. The trail descriptor + city positions provide enough context for the app to derive the full cross-route path.

3. **Server treats `trail_descriptor` as opaque initially** — just store and return it. This minimizes backend changes while enabling full multi-route sync.
