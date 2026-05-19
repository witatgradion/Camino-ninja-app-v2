## Parent PRD

`issues/prd.md` — surfaced during on-device smoke test of a fresh multi-trail plan on the iPhone 17 Pro simulator (2026-05-15). Invalidates part of the issue 004 verification (which only exercised the pull-only path, not the push-then-echo round trip).

## Severity

**SHIP BLOCKER** for the multi-trail feature. Without a fix, every multi-trail plan a user creates is silently corrupted on the very next sync. Phase (a) staging TestFlight onwards cannot proceed.

## What's happening

Backend's `POST /api/v1/stage_planner/sync` accepts the `trail_route_ids` field on push (additive contract confirmed in issue 004) but **omits the field entirely from the response body** for every plan. Plans that include it on push come back without it. JSON deserialization on the client treats absent-field as `null`, and the client's apply-from-server path unconditionally overwrites the local DB with whatever the server returned.

Result: local `stage_plans.trail_route_ids` is wiped to NULL after every sync. The plan-list loader can no longer pre-cache route points for the trail's non-primary routes (3, 23 in the captured case), so cross-route stages fail the city/route-point lookup in `_convertToStageModelOptimized`, throwing `City not found for stage <id>` (the catch swallows the actual exception and logs only metadata — fix candidate too). The plan flips to "Data incomplete" and the user can't view stages 2+.

## Captured evidence (2026-05-15, iPhone 17 Pro sim, build 2.2.405+202405)

### User action

Created a journey plan from the Journey Planner: start route 2 (Camino Portugués Central) → junction city 170 → route 3 → junction city 30 → route 23, ending at destination on route 23. Three trail segments.

### Push request body (22:48:16.549, request to `POST /api/v1/stage_planner/sync`)

```json
{
  "plans": [
    {
      "uuid": "df844518-d3a3-4b4a-8871-bc40c5a28e88",
      "route_id": 2,
      "name": null,
      "is_imported": false,
      "stages": [{
        "stage_number": 1, "route_id": 2,
        "start_city_id": 213, "end_city_id": 116,
        "stage_uuid": "c78374c8-a55f-4ab5-ba38-86fe8ce1eddc",
        ...
      }],
      "updated_at": "2026-05-15T15:48:06.516900Z",
      "starting_date": null,
      "deleted_at": null,
      "trail_route_ids": "[{\"r\":2},{\"r\":3,\"j\":170},{\"r\":23,\"j\":30}]"   ← SENT
    }
  ]
}
```

### Pull response body (22:48:16.993, response from same `POST`)

```json
{
  "plans": [
    {
      "uuid": "df844518-d3a3-4b4a-8871-bc40c5a28e88",
      "user_id": 6641,
      "route_id": 2,
      "name": null,
      "is_imported": false,
      "reference_plan_uuid": null,
      "device_id": "a2b65c5e-9b93-4f11-aac9-be436af5e43a",
      "device_name": "iPhone18,1",
      "stages": [{
        "stage_uuid": "c78374c8-...",
        "stage_number": 1, "route_id": 2,
        "days_to_stay": 1,
        "start_city_id": 213, "end_city_id": 116,
        "created_at": "2026-05-15T15:48:06.5169Z"
      }],
      "created_at": "2026-05-15T15:48:17.078865Z",
      "updated_at": "2026-05-15T15:48:06.5169Z"
      /* ← trail_route_ids ABSENT */
    }
  ]
}
```

HTTP status: 200. No 4xx, no 5xx. Server is processing the request successfully, just stripping the field from the response model.

### Local DB state after sync apply

```
sqlite> SELECT id, route_id, name, trail_route_ids FROM stage_plans WHERE id = 5;
5|2||      ← trail_route_ids empty (NULL)
```

While the stages were correctly stored with their cross-route routeIds:

```
sqlite> SELECT id, stage_number, route_id, start_city_id, end_city_id FROM stages WHERE stage_plan_id = 5;
10|1|2|213|116
11|2|3|116|30   ← stage on route 3, but plan has no trail_route_ids to advertise route 3 is part of the trail
12|3|23|30|689  ← stage on route 23, same problem
```

### Client-side amplifier

`packages/repository/lib/src/stage_plan_repository.dart:2057-2067`:

```dart
final localPlanId = await _stagePlannerDatabase.upsertStagePlanFromSync(
  uuid: responsePlan.uuid,
  routeId: responsePlan.routeId!,
  name: responsePlan.name,
  ...
  trailRouteIds: responsePlan.trailRouteIds,  // ← always overwrites local with server value
);
```

`packages/storage/lib/src/stage_planner_database_stage_plans.dart:316-373` `upsertStagePlanFromSync` has the comment:

```
/// `trail_route_ids` is written verbatim — including null. This matches
/// the "device-that-pushed wins" semantics: a server response carrying
/// NULL for a previously-multi-trail plan downgrades the local row
/// gracefully to single-route.
```

The intent assumes the server **always echoes the field**, even if value is null. Currently the server omits the field entirely from the response, which the JSON deserializer collapses to `null`. The client can't distinguish "server said null" (legitimate downgrade) from "server forgot to include the field" (data loss).

## What backend needs to do

Include `trail_route_ids` in the sync response body for **every plan in the `plans[]` array**, even if the stored value is null. The field must be present in the JSON, value can be `null` for plans without multi-trail metadata.

Test fixture for backend acceptance:
- POST a plan with `trail_route_ids: "[{\"r\":1},{\"r\":3,\"j\":250}]"`
- Server stores → returns the same plan in the response body with `trail_route_ids: "[{\"r\":1},{\"r\":3,\"j\":250}]"`
- POST a plan WITHOUT `trail_route_ids` (single-route plan)
- Server stores → returns the same plan in the response body with `trail_route_ids: null` (field present, value null)
- In both cases, GET / sync response includes `trail_route_ids` as a JSON key.

## Acceptance criteria

- [ ] Backend includes `trail_route_ids` key in sync response body for every plan (value null or string)
- [ ] On-device verification: create a multi-trail journey plan → trigger sync → assert local `stage_plans.trail_route_ids` is NOT wiped to NULL after sync apply
- [ ] On-device verification: plan-list reload after sync shows the multi-trail plan as complete (not "Data incomplete")
- [ ] On-device verification: existing multi-trail plans (created on Device A, downgraded to single-route on Device B) still downgrade correctly when the server response carries `"trail_route_ids": null`

## Blocked by

Nothing on the client side. Backend team needs to do the echo fix.

## Out of scope (deferred to issue 029 / follow-up)

- **Client mitigation** (local-wins semantics when server response omits the field). Documented as option 2 in the diagnosis. Not required if backend echo lands before TestFlight. Worth keeping in mind as defense-in-depth if backend delivery slips: the client could pre-parse the JSON to check for field presence and preserve local when absent — but this complicates the Retrofit/json_serializable flow.
- **`getAllStagePlans` exception swallowing** at `stage_plan_repository.dart:859-871`: the catch logs only `(plan, route, cities)` metadata but not the actual exception message. Future improvement: include `error: e, stackTrace: st` in the AppLogger call (already does this for SOME of the logs at lines 875-882 but not for the per-stage one). Helps diagnose conversion failures faster next time.

## User stories addressed

- User story 7 (round-trip through sync)
- User story 14 (data survival)
- User story 23 (operator sync health — currently `multi_trail_plan_sync_success` fires even when data is being silently dropped, which misleads ops monitoring)
- User story 28 (cross-device sync)

## Notes for ops monitoring

`multi_trail_plan_sync_success | {route_count: N}` is firing on the client side based on the PUSH state (the local plan IS multi-trail at push time). After this bug strips the trail, the client still considers the sync "successful" because no error was raised. So the analytics event is currently a false-positive for "the feature works end-to-end". After the backend fix lands, the event becomes meaningful again. Worth noting in `multi-trail-rollback-runbook.md` until then — DO NOT treat `multi_trail_plan_sync_success` count as proof of feature health while this bug is live.
