## Parent PRD

`issues/prd.md`

## What to build

Port the stage planner core map screens from `google_maps_flutter` to `mapbox_maps_flutter ^2.4.0`. Per parent PRD section "Chunk plan / C3".

Files to port:
- `lib/tabs/plan/screens/stage_map/stage_map_screen.dart`
- `lib/tabs/plan/screens/add_edit_stage/widgets/stage_map.dart`

Reference release/2.2.410's existing Mapbox port patterns and `docs/MAPBOX_MIGRATION.md`. Preserve all current behavior: trail rendering for multi-route plans, route polylines, markers, satellite toggle, edge-to-edge layout, system UI overlay handling, floating back button styling.

Document smoke checklist results in a comment on the issue or in branch memory. Manual smoke is the verification gate (no widget tests for map rendering — see PRD section "Testing Decisions").

## Acceptance criteria

- [ ] Both files compile without `google_maps_flutter` imports
- [ ] Smoke checklist passes on Android emulator:
  - Screen loads without crash
  - Map renders at correct initial center/zoom
  - Pan and zoom work
  - Marker tap responds correctly
  - Polylines render with correct color/thickness
  - Satellite toggle switches map type
  - Edge-to-edge layout intact (status bar handling)
- [ ] Smoke checklist passes on iOS simulator
- [ ] No regressions in stage planner core flow (create stage, edit stage, view stage map)
- [ ] `flutter analyze` clean

## Blocked by

- Blocked by `issues/002-atomic-merge-release-2-2-410.md`

## User stories addressed

- User story 14
- User story 17

## Migration notes (2026-05-14) — scope reduced by C1

C1 took `lib/tabs/plan/screens/stage_map/stage_map_screen.dart` from `release/2.2.410` verbatim (per the merge policy's "take theirs for map widgets"). The file is **already on Mapbox** post-merge. Likely scope for this issue is now:

1. **Verify** `stage_map_screen.dart` works as intended (smoke checklist below) — no porting needed
2. **Port** `lib/tabs/plan/screens/add_edit_stage/widgets/stage_map.dart` — check whether this also got take-theirs treatment or still imports `google_maps_flutter`. If it still imports `google_maps_flutter`, port it.
3. Confirm `flutter analyze` clean for both files

Neither file uses `LatLngBridge` per the C1 inventory in the PRD's "Progress note (2026-05-14)". No `null` mapController passes from these files.

**Android smoke is blocked** until issue 026 drops the `google_maps_flutter` transition dep. Use iOS simulator smoke only for this issue. The Android emulator smoke acceptance criterion is deferred to issue 026.
