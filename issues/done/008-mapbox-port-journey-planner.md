## Parent PRD

`issues/prd.md`

## What to build

Port the journey planner map preview from `google_maps_flutter` to `mapbox_maps_flutter ^2.4.0`. Per parent PRD section "Chunk plan / C4 part 2".

File to port:
- `lib/tabs/plan/screens/journey_planner/journey_planner_screen.dart` (the embedded map preview)

Preserve current behavior: draggable preview at 0.35 peek / 0.65 max heights, header-wide drag handle, lazy polyline loading for route options beyond the top 10, position-aware reachability indicators, route option selection triggers map update, ranked route options displayed alongside the map.

Document smoke checklist results.

## Acceptance criteria

- [ ] File compiles without `google_maps_flutter` import
- [ ] Smoke checklist passes on Android emulator + iOS simulator:
  - Journey planner loads after picking start and destination cities
  - Map preview draggable to 0.35 peek and 0.65 max
  - Drag handle responds across the full header width
  - Top 10 route options load polylines eagerly
  - Option 11+ loads its polyline lazily on selection
  - Position-aware reachability indicators (Direct / Via Junction / Not Reachable) display
  - Selecting a route option updates the map preview
- [ ] `flutter analyze` clean

## Blocked by

- Blocked by `issues/002-atomic-merge-release-2-2-410.md`

## User stories addressed

- User story 4
- User story 5
- User story 6

## Migration notes (2026-05-14) — shim cleanup

`lib/tabs/plan/screens/journey_planner/journey_planner_screen.dart` is still on `google_maps_flutter` post-C1. Port to Mapbox. Specifics:

- Remove `LatLngBridge.toLatLong2List` usages at :837 and :853 — once on Mapbox the screen can pass `latlong2.LatLng` directly.
- Replace the `null` mapController passes at :836 and :853 (currently a no-op on `MapUtil.fitBounds`) with the real `MapboxMap` controller obtained from the Mapbox map widget. This restores the route-option-selection map recenter behavior that C1 temporarily disabled.

**Android smoke is blocked** until issue 026 drops the transition dep. iOS-only smoke for this issue.
