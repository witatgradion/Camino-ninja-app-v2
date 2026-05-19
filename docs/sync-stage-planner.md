# Stage Planner Sync API Documentation

**Last Updated:** 2026-02-12

## Overview

The Stage Planner Sync API enables bidirectional synchronization of travel plans between mobile devices and the server. It handles conflict detection for multi-device scenarios and uses `UpdatedAt` timestamps for determining the source of truth.

---

## Endpoint

```
POST /api/v1/stage_planner/sync
```

### Required Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes | Bearer token (JWT) |
| `X-Device-ID` | Yes | Unique identifier for the device (e.g., UUID) |
| `X-Device-Name` | No | Human-readable device name (e.g., "iPhone 12") |

---

## Request Body

```json
{
  "plans": [
    {
      "uuid": "",
      "route_id": 1,
      "name": "My Camino Plan",
      "is_imported": false,
      "stages": [
        {
          "stage_number": 1,
          "route_id": 1,
          "date": "2026-05-01T00:00:00Z",
          "start_city_id": 1,
          "end_city_id": 2,
          "start_albergue_id": null,
          "end_albergue_id": null,
          "custom_start_notes": null,
          "custom_end_notes": null,
          "stage_notes": "First day on the Camino!",
          "created_at": "2026-02-10T10:00:00Z",
          "updated_at": "2026-02-12T15:30:00Z"
        }
      ],
      "updated_at": "2026-02-12T12:00:00Z"
    }
  ]
}
```

### Plan Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `uuid` | string | No | Plan UUID. Empty string = new plan (server generates UUID) |
| `route_id` | int32 | Yes | Route ID |
| `name` | string | No | Plan name |
| `is_imported` | bool | No | Whether the plan was imported |
| `plan_uuid` | string | No | Reference to original plan (for copies/conflicts) |
| `stages` | array | Yes | Array of Stage objects |
| `updated_at` | string (RFC3339) | Yes | Last modification timestamp |

### Stage Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `stage_number` | int32 | Yes | Stage order (1, 2, 3...) |
| `route_id` | int32 | Yes | Route ID |
| `date` | string (RFC3339) | No | Planned date for this stage |
| `start_city_id` | int32 | Yes | Starting city ID |
| `end_city_id` | int32 | Yes | Ending city ID |
| `start_albergue_id` | int32 | No | Starting albergue ID |
| `end_albergue_id` | int32 | No | Ending albergue ID |
| `custom_start_notes` | string | No | Custom notes for start |
| `custom_end_notes` | string | No | Custom notes for end |
| `stage_notes` | string | No | General notes for the stage |
| `created_at` | string (RFC3339) | No | Stage creation timestamp (not used in comparison) |
| `updated_at` | string (RFC3339) | No | Stage update timestamp (not used in comparison) |

---

## Response

The response contains **all plans for the user** after processing. Mobile should replace its local state with this response.

```json
{
  "plans": [
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "user_id": 1,
      "route_id": 1,
      "name": "My Camino Plan",
      "is_imported": false,
      "plan_uuid": null,
      "device_id": "device-001",
      "device_name": "iPhone 12",
      "stages": [...],
      "created_at": "2026-02-12T12:00:00Z",
      "updated_at": "2026-02-12T12:00:00Z",
      "deleted_at": null
    }
  ]
}
```

---

## Sync Logic & Scenarios

### Scenario 1: New Plan (No UUID)

**Client sends:**
```json
{
  "plans": [{
    "uuid": "",
    "route_id": 1,
    "name": "New Plan",
    "stages": [
      {"stage_number": 1, "route_id": 1, "date": "2026-05-01T00:00:00Z", "start_city_id": 1, "end_city_id": 2}
    ],
    "updated_at": "2026-02-12T12:00:00Z"
  }]
}
```

**Result:** Server generates UUID, creates plan, returns it with UUID assigned.

---

### Scenario 2: Update from Same Device (Client Newer)

**Server has:**
- Plan UUID: `abc-123`
- Device ID: `device-001`
- UpdatedAt: `2026-02-12T10:00:00Z`

**Client sends (same device, newer timestamp):**
```json
{
  "plans": [{
    "uuid": "abc-123",
    "route_id": 1,
    "name": "Updated Plan Name",
    "stages": [
      {"stage_number": 1, "route_id": 1, "date": "2026-05-02T00:00:00Z", "start_city_id": 1, "end_city_id": 2}
    ],
    "updated_at": "2026-02-12T14:00:00Z"
  }]
}
```

**Result:** Server updates with client data (client is newer).

---

### Scenario 3: Update from Same Device (Server Newer)

**Server has:**
- Plan UUID: `abc-123`
- Device ID: `device-001`
- UpdatedAt: `2026-02-12T16:00:00Z`

**Client sends (same device, older timestamp):**
```json
{
  "plans": [{
    "uuid": "abc-123",
    "route_id": 1,
    "name": "Stale Client Data",
    "stages": [...],
    "updated_at": "2026-02-12T10:00:00Z"
  }]
}
```

**Result:** Server keeps its version (server is newer). Client data is ignored.

---

### Scenario 4: Conflict - Different Device, Different Stages

**Server has:**
- Plan UUID: `abc-123`
- Device ID: `device-001`
- Stages: 2 stages

**Client sends (different device, different stages):**

Headers:
```
X-Device-ID: device-002
```

Body:
```json
{
  "plans": [{
    "uuid": "abc-123",
    "route_id": 1,
    "name": "Modified from iPad",
    "stages": [
      {"stage_number": 1, "route_id": 1, "date": "2026-05-01T00:00:00Z", "start_city_id": 1, "end_city_id": 2},
      {"stage_number": 2, "route_id": 1, "date": "2026-05-02T00:00:00Z", "start_city_id": 2, "end_city_id": 3},
      {"stage_number": 3, "route_id": 1, "date": "2026-05-03T00:00:00Z", "start_city_id": 3, "end_city_id": 4}
    ],
    "updated_at": "2026-02-12T12:00:00Z"
  }]
}
```

**Result:** CONFLICT! Server returns **2 plans**:
1. Original plan (unchanged, UUID: `abc-123`)
2. New conflict plan (new UUID, `plan_uuid` references `abc-123`)

```json
{
  "plans": [
    {
      "uuid": "abc-123",
      "device_id": "device-001",
      "stages": [/* original 2 stages */]
    },
    {
      "uuid": "new-generated-uuid",
      "device_id": "device-002",
      "plan_uuid": "abc-123",
      "stages": [/* client's 3 stages */]
    }
  ]
}
```

---

### Scenario 5: Different Device, Same Stages (No Conflict)

If the stages content is identical (same cities, dates, albergues, notes), even from different devices, **no conflict is created**.

---

## Conflict Detection Rules

| Same Device? | Same Stages? | Result |
|--------------|--------------|--------|
| Yes | Any | Update based on `updated_at` (newer wins) |
| No | Yes | No conflict (stages identical) |
| No | No | **CONFLICT** - create new plan |

### What's Compared in Stages

The following fields are compared to detect conflicts:
- `stage_number`
- `route_id`
- `date`
- `start_city_id`
- `end_city_id`
- `start_albergue_id`
- `end_albergue_id`
- `custom_start_notes`
- `custom_end_notes`
- `stage_notes`

**NOT compared** (intentionally excluded):
- `created_at` (stage-level)
- `updated_at` (stage-level)

---

## Timestamp Format

All timestamps use **RFC3339** format:

```
2026-02-12T12:00:00Z        # UTC
2026-05-01T00:00:00Z        # Date only (midnight UTC)
2026-02-12T15:30:00+07:00   # With timezone offset
```

---

## Complete Example

### Request

```
POST /api/v1/stage_planner/sync
Authorization: Bearer <jwt_token>
X-Device-ID: 550e8400-e29b-41d4-a716-446655440001
X-Device-Name: iPhone 12
Content-Type: application/json
```

```json
{
  "plans": [
    {
      "uuid": "",
      "route_id": 1,
      "name": "My Camino Frances Plan",
      "is_imported": false,
      "stages": [
        {
          "stage_number": 1,
          "route_id": 1,
          "date": "2026-05-01T00:00:00Z",
          "start_city_id": 1,
          "end_city_id": 2,
          "start_albergue_id": 10,
          "end_albergue_id": 25,
          "stage_notes": "Starting from Saint-Jean-Pied-de-Port"
        },
        {
          "stage_number": 2,
          "route_id": 1,
          "date": "2026-05-02T00:00:00Z",
          "start_city_id": 2,
          "end_city_id": 3,
          "end_albergue_id": 30,
          "stage_notes": "Through the Pyrenees"
        },
        {
          "stage_number": 3,
          "route_id": 1,
          "date": "2026-05-03T00:00:00Z",
          "start_city_id": 3,
          "end_city_id": 4
        }
      ],
      "updated_at": "2026-02-12T12:00:00Z"
    }
  ]
}
```

### Response

```json
{
  "plans": [
    {
      "uuid": "7f3b8c90-1234-5678-abcd-ef1234567890",
      "user_id": 42,
      "route_id": 1,
      "name": "My Camino Frances Plan",
      "is_imported": false,
      "plan_uuid": null,
      "device_id": "550e8400-e29b-41d4-a716-446655440001",
      "device_name": "iPhone 12",
      "stages": [
        {
          "stage_number": 1,
          "route_id": 1,
          "date": "2026-05-01T00:00:00Z",
          "start_city_id": 1,
          "end_city_id": 2,
          "start_albergue_id": 10,
          "end_albergue_id": 25,
          "custom_start_notes": null,
          "custom_end_notes": null,
          "stage_notes": "Starting from Saint-Jean-Pied-de-Port",
          "created_at": null,
          "updated_at": null
        },
        {
          "stage_number": 2,
          "route_id": 1,
          "date": "2026-05-02T00:00:00Z",
          "start_city_id": 2,
          "end_city_id": 3,
          "start_albergue_id": null,
          "end_albergue_id": 30,
          "custom_start_notes": null,
          "custom_end_notes": null,
          "stage_notes": "Through the Pyrenees",
          "created_at": null,
          "updated_at": null
        },
        {
          "stage_number": 3,
          "route_id": 1,
          "date": "2026-05-03T00:00:00Z",
          "start_city_id": 3,
          "end_city_id": 4,
          "start_albergue_id": null,
          "end_albergue_id": null,
          "custom_start_notes": null,
          "custom_end_notes": null,
          "stage_notes": null,
          "created_at": null,
          "updated_at": null
        }
      ],
      "created_at": "2026-02-12T12:00:00Z",
      "updated_at": "2026-02-12T12:00:00Z",
      "deleted_at": null
    }
  ]
}
```

---

## Mobile Implementation Notes

1. **Replace Local State**: After sync, replace all local plans with the response
2. **Generate Device ID**: Generate a persistent UUID for `X-Device-ID` on first app launch
3. **Track UpdatedAt**: Always send accurate `updated_at` timestamps
4. **Handle Conflicts**: When `plan_uuid` is not null, the plan was created from a conflict - consider showing user a "duplicate" indicator
5. **Empty Plans Array**: Send `{"plans": []}` if no local plans exist - server will return all server-side plans

---

## Error Responses

| Status | Description |
|--------|-------------|
| 400 | Missing `X-Device-ID` header or invalid request body |
| 401 | Unauthorized (missing or invalid JWT) |
| 500 | Server error |
