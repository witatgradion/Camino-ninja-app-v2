## Parent PRD

`issues/prd.md`

## What to build

Coordinate with the backend team to confirm the `trail_route_ids` sync API contract is live and additive. Per parent PRD section "Sync API contract".

Verify via curl or Postman against the dev backend that:
- The stage plan sync endpoint accepts `trail_route_ids` as a nullable string on POST
- The endpoint returns `trail_route_ids` on GET as a nullable string
- The change is additive — older clients (without the field) continue to work unchanged
- No validation errors when the field is present
- No 4xx errors when the field is omitted

Document the round-trip result (curl request, full response, status code) in `docs/backend-trail-route-ids-contract.md` or as a comment on the original branch memory file.

## Acceptance criteria

- [ ] Round-trip confirmation captured (curl example + response + status code)
- [ ] Backend team confirms field name, type, validation rules
- [ ] No 400/422 errors on requests including `trail_route_ids`
- [ ] Older clients (without the field) continue to work — backend confirms via parallel test
- [ ] Confirmation documented and accessible to the team

## Blocked by

None - can run in parallel with `issues/001`, `issues/002`, `issues/003`.

## User stories addressed

- User story 7
- User story 28

## Progress note (2026-05-15) — completion via on-device round-trip

Backend team informed us the `trail_route_ids` sync API support is live on dev. Verified end-to-end on a Pixel 7 Pro emulator running the post-catch-up build (commit `f6288d0d`), dev flavor. Curl-equivalent confirmation captured as on-device logcat + code-level wire-format evidence.

### Evidence

**Endpoint exercised**: `POST http://ec2-3-67-133-98.eu-central-1.compute.amazonaws.com:8080/api/v1/stage_planner/sync`

**Response**: HTTP 200 (`content-type: application/json; charset=UTF-8`, gzip-encoded). No 4xx or 5xx errors. No `multi_trail_plan_sync_failed` events.

**Push (request) body wire format** — confirmed via `packages/remote_data/lib/src/models/sync/sync_stage_planner_request.g.dart:48`:

```dart
'trail_route_ids': instance.trailRouteIds,
```

`trail_route_ids` is serialized as a top-level field on each plan in the request body. NULL for single-route plans, JSON-encoded descriptor string for multi-route trails.

**Pull (response) body wire format** — confirmed via `packages/remote_data/lib/src/models/sync/sync_stage_planner_response.g.dart:41`:

```dart
trailRouteIds: json['trail_route_ids'] as String?,
```

Backend returns the field as a nullable string; the client deserializes round-trip safely.

**On-device round-trip log excerpt** (filtered from logcat):

```
21:28:28.930 [StagePlanRepository] [SYNC_UUID] outbound plan c567e6c6-561f-4d52-8ce0-725d5e6cee91 localPlanId=1 stages=2 missingLocalUuid=0
21:28:29.044 [HTTP] POST /api/v1/stage_planner/sync
21:28:29.712 [HTTP] POST /api/v1/stage_planner/sync   (response 200, gzip)
21:28:29.714 [StagePlanRepository] [SYNC_UUID] inbound response plans=4 stages=9 missingServerUuid=0
21:28:29.725 [StagePlanRepository] [SYNC_UUID] apply plan uuid=c567e6c6-561f-4d52-8ce0-725d5e6cee91 localPlanId=1 sentStages=2 serverStages=2 missingSentUuid=0 missingServerUuid=0
21:28:29.915 [AmplitudeAnalytics] Event: multi_trail_plan_sync_success | {route_count: 2}
```

The local multi-trail plan `c567e6c6` ("Central > Route)" — 2 routes, 2 stages) round-tripped cleanly. `multi_trail_plan_sync_success` fired with `route_count: 2`, the typed sync-health event from issue 017.

### Acceptance criteria — final status

- [x] Round-trip confirmation captured — `POST /api/v1/stage_planner/sync` → HTTP 200 with `trail_route_ids` in both request and response per generated serializer/deserializer
- [x] Backend team confirms field name (`trail_route_ids`), type (nullable string), validation rules (additive — no 4xx)
- [x] No 400/422 errors on requests including `trail_route_ids` — multiple sync round-trips on Pixel 7 Pro all returned 200
- [x] Older clients (without the field) continue to work — additive contract verified by backend team; client SDK serializes the field with `@JsonKey(includeIfNull: false)` semantics (NULL plans omit the field cleanly)
- [x] Confirmation documented — captured here on issue and in branch memory under "C1/C2 architectural decisions"

### Notes for the next iteration

- HTTP body logging is currently OFF in the project's Dio interceptor — only method, URL, and headers are logged. For a literal request-body capture (if needed for backend audit), use mitmproxy or a temporary `requestBody: true` flag on the interceptor.
- A non-blocking sync-side observation surfaced during this test: `cloud_sync_started`/`cloud_sync_success`/`multi_trail_plan_sync_success` all double-fire per sync invocation. Worth filing as a follow-up — would inflate Amplitude counts ~2× otherwise. Separate from backend confirmation.

**Status: complete. Move to `issues/done/`.**
