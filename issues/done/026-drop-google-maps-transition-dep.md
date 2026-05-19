## Parent PRD

`issues/prd.md` — see "Progress note (2026-05-14)" for the chunk plan update that introduced this issue.

## What to build

Drop the `google_maps_flutter` transition dependency that was added back into `pubspec.yaml` during C1 (issue 002). Port the 2 dev-only screens that weren't covered by issues 006-009 in the original PRD, port `trail_builder_cubit.dart`'s Polyline-point logic, delete the `LatLngBridge` shim and all its callsites, and restore the Android build.

This issue closes the transition state created by C1's bridge approach. It is the prerequisite for re-enabling Android builds on this branch.

### Files to port to Mapbox

- `lib/tabs/more/screens/debug_route_map/debug_route_map_screen.dart` — dev-only screen, NOT in the original PRD's port list. Imports `google_maps_flutter`. Uses `LatLngBridge.toGmaps` at :158; passes `GoogleMapController?` at :105. Port to `mapbox_maps_flutter ^2.4.0`.
- `lib/tabs/more/screens/route_city_overview/route_city_overview_screen.dart` — dev-only screen, NOT in the original PRD's port list. Imports `google_maps_flutter`. Shim usages at :700, :760, :722; `null` mapController at :721. Port to `mapbox_maps_flutter`.
- `lib/tabs/plan/screens/trail_builder/cubit/trail_builder_cubit.dart` — cubit logic, not a screen. Caches `List<google_maps_flutter.LatLng>` at :470 + :502 via `LatLngBridge.toGmapsList`. Once issue 007 ports `trail_builder_screen.dart` to Mapbox, this cubit can switch to caching `List<latlong2.LatLng>` and the shim usages disappear naturally. If issue 007 didn't clean these up, do it here.

### Cleanup steps after porting

1. Remove `google_maps_flutter: ^2.14.0` from `pubspec.yaml`.
2. Delete the `LatLngBridge` shim source + tests:
   - `lib/utils/maps_bridge/lat_lng_bridge.dart`
   - `test/utils/maps_bridge/lat_lng_bridge_test.dart`
   - `lib/utils/maps_bridge/` directory (if empty)
   - `test/utils/maps_bridge/` directory (if empty)
3. Run `flutter pub get` and verify the lockfile no longer carries `google_maps_flutter` or any transitive Google Maps native pods.
4. Grep the codebase for `google_maps_flutter` to confirm no remaining imports anywhere in `lib/`, `test/`, or `packages/`.
5. Restore the Android build: with the transition dep gone, `google_maps_flutter_android:2.19.8`'s Kotlin compiler bug no longer applies. Run `flutter build apk --flavor development` and confirm it succeeds.

## Acceptance criteria

- [ ] `debug_route_map_screen.dart` ported to Mapbox; smoke checklist passes in dev flavor on iOS + Android emulator
- [ ] `route_city_overview_screen.dart` ported to Mapbox; smoke checklist passes in dev flavor on iOS + Android emulator
- [ ] `trail_builder_cubit.dart` no longer imports `google_maps_flutter`; cache type switched to `List<latlong2.LatLng>`
- [ ] No file in `lib/`, `test/`, or `packages/` imports `google_maps_flutter` (grep clean)
- [ ] `google_maps_flutter` removed from `pubspec.yaml` and `pubspec.lock`
- [ ] `lib/utils/maps_bridge/` directory deleted (shim + tests gone)
- [ ] `flutter analyze` clean across all packages
- [ ] `flutter build apk --flavor development` succeeds — **this is the gate that re-enables Android**
- [ ] `flutter build ios --flavor development --no-codesign` still succeeds
- [ ] App launches in dev flavor on both Android emulator and iOS simulator; multi-trail features (Custom Trail + Plan a Journey) render correctly

## Blocked by

- Blocked by `issues/006-mapbox-port-stage-map.md`
- Blocked by `issues/007-mapbox-port-trail-builder.md`
- Blocked by `issues/008-mapbox-port-journey-planner.md`

(006-008 must land first so their respective screens are off `google_maps_flutter`. Then this issue ports the 2 missed dev-only screens + the cubit, and drops the dep.)

## User stories addressed

- User story 14 (data survival across migration — this issue closes the Android coverage gap, ensuring Android users running the multi-trail features post-ramp also get the full migration test surface)
- User story 17 (developer review experience — this issue removes the transition-dep cognitive load from the integration branch)
