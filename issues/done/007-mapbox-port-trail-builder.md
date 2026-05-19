## Parent PRD

`issues/prd.md`

## What to build

Port the trail builder maps from `google_maps_flutter` to `mapbox_maps_flutter ^2.4.0`. Per parent PRD section "Chunk plan / C4 part 1".

Files to port:
- `lib/tabs/plan/screens/trail_builder/trail_builder_screen.dart` (any embedded map widgets)
- `lib/tabs/plan/screens/trail_builder/widgets/trail_preview_map.dart`
- `lib/tabs/map/widgets/embedded_stage_map.dart`

Preserve trail-specific behavior: glowing junction markers (Plan tab and Map tab usage contexts), theme-aware route colors via the `parseRouteColor` helper, reduced polyline thickness without alpha transparency for trail previews, integration with `MultiRouteTrail` data flow. Re-implement against Mapbox APIs.

Document smoke checklist results.

## Acceptance criteria

- [ ] All three files compile without `google_maps_flutter` imports
- [ ] Smoke checklist passes on Android emulator + iOS simulator:
  - Trail builder loads without crash
  - Junction markers render with glow effect
  - Route colors respect light/dark mode
  - Trail preview polylines render at the right thickness without alpha transparency
  - Trail preview map updates as user makes junction decisions
  - Undo step updates map correctly
- [ ] `embedded_stage_map` renders correctly inside Plan tab AND Map tab
- [ ] No crashes when switching between dark/light themes
- [ ] `flutter analyze` clean

## Blocked by

- Blocked by `issues/002-atomic-merge-release-2-2-410.md`

## User stories addressed

- User story 3
- User story 6

## Migration notes (2026-05-14) — scope reduced + shim cleanup

C1 took `lib/tabs/map/widgets/embedded_stage_map.dart` from `release/2.2.410` verbatim (already on Mapbox). Remaining scope for this issue:

1. **Verify** `embedded_stage_map.dart` works as intended (smoke checklist)
2. **Port** `lib/tabs/plan/screens/trail_builder/trail_builder_screen.dart` from `google_maps_flutter` to `mapbox_maps_flutter`. Remove `LatLngBridge.toLatLong2List` usages at :117, :169, :1226 — once on Mapbox, the screen can pass `latlong2.LatLng` directly.
3. **Port** `lib/tabs/plan/screens/trail_builder/widgets/trail_preview_map.dart`. Remove `LatLngBridge.toLatLong2List` usages at :294, :301. Replace `BitmapDescriptor.fromBytes(uint8List)` wrap at :210 with the Mapbox marker-image API. Replace the `null` mapController passes at :293, :301 with the real `MapboxMap` controller.

`trail_builder_cubit.dart` has 2 shim usages at :470 + :502 (`LatLngBridge.toGmapsList`). That cubit is logic, not a screen, and tracks the screen's Polyline points. It's scoped to **issue 026** rather than this issue — but if the cubit's shim usages naturally disappear when this issue ports trail_builder_screen.dart (because the screen no longer needs `gmaps.LatLng` lists), feel free to clean them up here and link in 026.

**Android smoke is blocked** until issue 026 drops the transition dep. iOS-only smoke for this issue.

## Progress note (2026-05-15) — code port complete; smoke deferred to HITL

Both code-port files ported to Mapbox in this iteration:

- `trail_preview_map.dart` rewritten against `MapWidget` + `PolylineDelegate` + `WidgetMarkerDelegate` (separate delegates for branch labels vs junction marker for independent lifecycles). `MapboxMapStyle.dark` / `.light` replaces the Google Maps JSON styles. The junction marker is now a Flutter widget (red dot, white border, drop shadow) rendered to bitmap via `MarkerHelper.widgetToBitmapDescriptor` — Mapbox ships no built-in pin sprite, so the equivalent of `BitmapDescriptor.defaultMarkerWithHue(red)` is a widget-marker. `MapboxHostMixin` powers theme-swap + dispose discipline. Dark-mode swap is driven from `didChangeDependencies` (Theme is an InheritedWidget). `latlong2` imported with `hide Path` because `latlong2.Path<LatLng>` collides with `ui.Path` used elsewhere; `Size` collides with `mapbox_maps_flutter.Size` so the junction marker uses `Container`+`BoxDecoration` instead of `CustomPainter` to sidestep that collision entirely.

- `trail_builder_screen.dart`: dropped `google_maps_flutter` import + 3 `LatLngBridge.toLatLong2List` callsites. `_TrailMapData.inProgressPoints` is now `List<latlong2.LatLng>?`. The screen passes `points` directly to `MapUtil.findNearestPointIndex` since the cubit cache is now `latlong2.LatLng`.

- `trail_builder_cubit.dart` (originally scoped to issue 026; included here per the migration note "feel free to clean them up here"): cache switched from `Map<int, List<gmaps.LatLng>>` to `Map<int, List<latlong2.LatLng>>`. Dropped 2 `LatLngBridge.toGmapsList` wrap callsites + `google_maps_flutter` + `maps_bridge` imports. The getters (`getTrailRoutePoints`, `getBranchRoutePoints`) now return `latlong2.LatLng` directly. **All 20 existing `trail_builder_cubit_test.dart` tests pass — the test file never referenced either `LatLng` flavor, so the cache-type swap is invisible to it.** This reduces issue 026's scope by 3 callsites.

`embedded_stage_map.dart` is verified already on Mapbox post-merge (matches the issue body).

### Verification

- `flutter analyze` on the 3 changed files: 0 errors. 4 info/warnings remain, all pre-existing on `feature/combining-trails-mapbox` HEAD (`_showMap` could be final, `_MapToggleButton` unused, directives ordering, redundant arg). Issue count *reduced* from 12 → 4 — the prior `BitmapDescriptor.fromBytes` and `Polyline.zIndex` deprecation warnings are gone.
- `flutter analyze` (full app): 0 errors across all packages.
- `flutter test test/tabs/plan/screens/trail_builder/`: 20/20 pass.
- `flutter test test/`: 112/112 pass (no regressions).

### Smoke checklist — deferred to HITL

Acceptance checklist items "smoke checklist passes on Android emulator + iOS simulator" + "no crashes when switching between dark/light themes" + "embedded_stage_map renders correctly inside Plan tab AND Map tab" require running the app on physical or emulated devices with real route data. Per the issue's own note: **Android smoke is blocked** until issue 026 drops the transition dep. Recommended next step: pick up the iOS smoke pass during phase (a) staging TestFlight (issue 022).

### Items to watch during smoke

- `_RouteLabelWidget` rendering path is unchanged (`MarkerHelper.widgetToBitmapDescriptor`); should look identical.
- Junction marker is visually different: was Google Maps's built-in red pin (`BitmapDescriptor hueRed`), now a 24x24 red dot with white border + shadow, anchored CENTER (was BOTTOM). If this reads too small on real devices, swap to an SVG-driven custom pin widget.
- Trail-preview map dark-mode switching uses `swapStyle` from `MapboxHostMixin`; the polyline manager resets on `_onStyleLoaded` and polylines are redrawn. Worth confirming no flicker / no missing polylines after a theme toggle.
- `MapUtil.fitBounds` now receives the live `MapboxMap` controller (was `null` pre-port, with `MapUtil.fitBounds` no-oping). The bounds animation should fire correctly on map updates — the recenter behavior C1 temporarily disabled is restored here.
