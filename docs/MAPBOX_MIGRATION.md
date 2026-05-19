# Mapbox Migration — Architecture & Per-Screen Drawing

> Companion doc to [PR_DESCRIPTION.md](../PR_DESCRIPTION.md). Covers how the Google Maps → Mapbox migration is structured, what each reusable piece does, and how every map screen now draws its content.

## Table of contents

1. [Goals & non-goals](#goals--non-goals)
2. [High-level architecture](#high-level-architecture)
3. [Platform & app startup](#platform--app-startup)
4. [The delegate layer](#the-delegate-layer)
5. [The controller layer](#the-controller-layer)
6. [Per-screen drawing](#per-screen-drawing)
   - [MapScreen (main navigation tab)](#mapscreen-main-navigation-tab)
   - [SelectRouteMapWidget](#selectroutemapwidget)
   - [CityAlberguesMap](#cityalberguesmap)
   - [StageMapScreen / EmbeddedStageMap](#stagemapscreen--embeddedstagemap)
   - [StageSmallMap (add/edit stage)](#stagesmallmap-addedit-stage)
7. [Marker rendering pipeline](#marker-rendering-pipeline)
8. [Style swapping (dark / light / satellite)](#style-swapping-dark--light--satellite)
9. [Gotchas surfaced during migration](#gotchas-surfaced-during-migration)

---

## Goals & non-goals

**Goals**
- Visual parity with the previous Google Maps UI on every screen.
- Land the SDK foundation that *would* support offline tile caching in the future. The scaffolding is checked in but disabled — see [`OFFLINE_MAP.md`](OFFLINE_MAP.md) for the dormant-flag details.
- Deduplicate the ~1,600 lines of inline map code that had accumulated across screens into a small set of composable primitives.
- Preserve existing gesture behaviour per screen (full-screen vs. preview, zoom-locked vs. pinch-to-zoom, etc.).

**Non-goals**
- No behavioural changes that users would notice. The migration is feature-flat.
- No offline downloads in this PR. The `OfflineMapService` / `OfflineMapRepository` classes are present but gated behind `_isEnabled = false` and never touch disk at runtime.
- No new map features beyond what existed before.
- No migration of the underlying data model — `RoutePointEntity`, `CityEntity`, `AlbergueEntity` are unchanged.

---

## High-level architecture

```
┌───────────────────────────────────────────────────────────────┐
│ Screen widget                                                 │
│   - Stateless / Stateful UI                                   │
│   - Owns the MapWidget and wires its callbacks to a           │
│     Controller. Holds no map state itself.                    │
└────────────────────────┬──────────────────────────────────────┘
                         │ forwards onMapCreated / onStyleLoaded
                         │ / onCameraChange / lifecycle hooks
                         ▼
┌───────────────────────────────────────────────────────────────┐
│ Controller  (lib/mapbox/controllers/*.dart +                  │
│              per-screen controllers under lib/tabs/**)        │
│   - Owns MapboxMap handle, cubit, handlers, timers            │
│   - Orchestrates delegates, reacts to cubit state changes,    │
│     triggers auto-download, handles taps                      │
└───────────┬───────────────┬─────────────────┬─────────────────┘
            ▼               ▼                 ▼
      ┌──────────┐    ┌──────────────┐   ┌──────────────┐
      │ Delegate │    │ Delegate      │   │ Delegate      │
      │ (polyline│    │ (widget       │   │ (albergue     │
      │  / route │    │  marker /     │   │  cluster /    │
      │  layer)  │    │  city marker) │   │  gestures)    │
      └────┬─────┘    └──────┬────────┘   └──────┬────────┘
           ▼                 ▼                   ▼
      Mapbox annotation managers & style layers (official SDK)
```

Widgets hold **no map state** — destroying + recreating a widget is safe because the controller is the source of truth. Controllers are deterministic: given the same cubit state they produce the same draw calls.

---

## Platform & app startup

### Dependencies

```yaml
# pubspec.yaml
mapbox_maps_flutter: ^2.4.0
# removed: google_maps_flutter, google_maps_cluster_manager_2
```

### Access token

- Per-flavor env var: `MAPBOX_ACCESS_TOKEN` in `.env.development` / `.env.staging` / `.env.production`.
- Surfaced via `AppEnv.mapboxAccessToken` (`lib/app_env.dart`).

### Startup sequence (each `main_*.dart`)

```dart
await AppEnv.load(Flavor.xxx);
await OfflineMapService.configureTileStore();  // no-op while _isEnabled = false
MapboxOptions.setAccessToken(AppEnv.mapboxAccessToken);
```

The `configureTileStore()` call is intentionally kept in `main_*.dart` so flipping `_isEnabled = true` in `OfflineMapService` is a one-line change to revive the feature. **Today the method short-circuits on its disabled flag and never calls `MapboxMapsOptions.setDataPath(...)`**, so Mapbox runs against its default cache directory.

When the feature is later enabled: `setDataPath(...)` must run before `setAccessToken(...)` so the Maps engine and our `TileStore` agree on which directory holds cached tiles. Skipping this order would put cached tiles outside the read path.

### Native config removed

- **Android:** removed `com.google.android.geo.API_KEY` from `AndroidManifest.xml`, removed `googleMapsApiKey` + `manifestPlaceholders` from `build.gradle`. Mapbox token is configured entirely in Dart.
- **iOS:** removed `import GoogleMaps` / `GMSServices.provideAPIKey(...)` from `AppDelegate.swift`, removed `GOOGLE_MAPS_API_KEY` entry from `Info.plist`. Google Maps pod removed from `ios/Podfile.lock`.

---

## The delegate layer

All delegates live in `lib/mapbox/delegates/` and are exported from `lib/mapbox/delegates/delegates.dart`.

### `GestureDelegate`

A lightweight configuration object — apply once in `onMapCreated` to configure gestures, scale bar, compass, attribution, and location component settings. Flags map 1-to-1 to the Mapbox `GesturesSettings` / `ScaleBarSettings` / `CompassSettings` / `AttributionSettings` / `LocationComponentSettings` structures.

```dart
await const GestureDelegate(
  locationEnabled: true,
  locationPulsingEnabled: true,
).apply(map);
```

Default behaviour matches Google Maps' defaults on the Camino screens: scroll + pinch-to-zoom + double-tap-to-zoom on, rotate + pitch off, location on, pulsing off.

### `PolylineDelegate`

Owns a `PolylineAnnotationManager`. Two usage modes:

1. **Convenience mode** (`syncRoutePolylines`) — used by screens whose polyline styling matches the shared `PolylineStyleDefs` (main route red + alt routes with per-route hex + alpha).
2. **Lifecycle-only mode** — screens with bespoke colouring (e.g. `MapScreen` and `EmbeddedStageMap`, which need a selected-sub-route overlay and per-stage colouring) call `.initialize()` + `.clear()` and then use `.manager!.create(...)` to build their own annotations.

Exposes `resetForStyleReload()` so callers can drop the manager on a style swap, since annotation layers do not survive `loadStyleURI()`.

### `WidgetMarkerDelegate`

Owns a `PointAnnotationManager` for Flutter-widget-based markers:

1. Widget (e.g. a `CityMarker`) is rendered to a `Uint8List` bitmap via `MarkerHelper.widgetToBitmapDescriptor`, cached by `cacheKey`.
2. The bitmap is attached to a `PointAnnotation` at the given `LatLng`, with optional `iconRotate` + `symbolSortKey`.

**Why two delegates per screen sometimes?** Some screens need independent marker families (e.g. combine markers + a directional arrow) that must be cleared separately. Giving each family its own `WidgetMarkerDelegate` — and therefore its own `PointAnnotationManager` — sidesteps the fact that `deleteAll()` on a manager would otherwise wipe both families.

### `CityMarkerDelegate`

Small specialisation that draws exactly one city marker via its own `PointAnnotationManager`. Separated so that `EmbeddedStageMap` and `CityAlberguesMap` can add it **after** other style layers (e.g. the albergue cluster layer), guaranteeing the city marker sits on top regardless of style-layer stacking order.

### `AlbergueClusterDelegate`

This is the only delegate that uses **native style-layer clustering** instead of annotations:

1. Builds a GeoJSON `FeatureCollection` from albergue locations.
2. Adds a `GeoJsonSource` with `cluster: true`, `clusterMaxZoom: 16`, `clusterRadius: 50`.
3. Adds three `SymbolLayer`s on top of that source:
   - **Individual** (filter `!has point_count`) — the hotel-circle icon + text label.
   - **Cluster hotel icon** (filter `has point_count`) — same hotel-circle icon so a cluster still "reads" as a group of albergues.
   - **Cluster count badge** (filter `has point_count`) — small red circle + `point_count_abbreviated` text, offset to the upper-right of the hotel icon.

Tap handling uses `queryRenderedFeatures`: if the hit is a cluster, `flyTo(center, zoom + 3)`; if it's an individual, dispatch `onMarkerTap(albergueLocation)`.

### `RouteLayerDelegate`

Used exclusively by `SelectRouteMapWidget`. Builds two style sources + layers from GeoJSON:

- `route-lines` source → `route-lines-layer` (`LineLayer`): one feature per route, coloured by route's legend color, line width driven by `feature-state.highlighted`.
- `route-labels` source → `route-labels-layer` (`SymbolLayer`): one label per route at the mid-point, coloured by the same legend, text halo ringed in the route colour, `symbol-sort-key` driven by `RouteLabelResolver.priorityOf(route)` so preferred routes stay on top when labels collide.

Highlighting a route uses `MapboxMap.setFeatureState(sourceId, null, featureId, '{"highlighted": true}')` — the `LineLayer` / `SymbolLayer` expressions read that state and switch to `selectedColor` / `selectedTextColor` / `selectedHaloColor`. This is a zero-rebuild highlight (no source data change, no layer teardown).

---

## The controller layer

### `MapScreenController` (`lib/mapbox/controllers/`)

Used by the main Map tab (`lib/tabs/map/map_screen.dart`). Owns:
- The `MapboxMap` handle, `PolylineDelegate`, and `MapCubit`.
- `MapMarkerHandler` (first/last city annotations + elevation indicator), `MapClusterHandler` (viewport-dynamic directional arrows), `MapLocationHandler` (my-location button, permission flow, pulsing circle), `MapChartHandler` (elevation chart → map marker).
- A 300 ms camera-change debounce timer that re-computes viewport arrows on movement end.

Orchestrates `onMapCreated`, `onStyleLoaded`, `onCameraChange`, `onMapIdle`, `drawPolylines`, `updatePoints`. It also calls `OfflineMapRepository.downloadIfNeeded(...)` when the route's points first become available — this is a no-op today (both the repository and the underlying `OfflineMapService` are gated by `_isEnabled = false`) but the call site is preserved so revival is a one-line flag flip.

### `SelectRouteMapController` (`lib/mapbox/controllers/`)

Used by `SelectRouteMapWidget`. Owns `RouteLayerDelegate` and a `ValueNotifier<RouteDistanceElevation?> previewRoute` that the widget renders into a bottom-sheet panel.

`onMapTap` → `RouteLayerDelegate.queryTappedRouteId(...)` → if a route is hit, flip the preview route and refit bounds with bottom padding for the panel; otherwise cancel the preview.

### `StageSmallMapController` (`lib/mapbox/controllers/`)

Used by the tiny stage map inside `add_edit_stage/widgets/stage_map.dart`. Non-interactive (scroll / pinch / double-tap all disabled). Draws two polylines: the whole route, and the currently-selected stage portion. Re-fits bounds whenever `update(...)` is called.

### `EmbeddedStageMapController` (`lib/tabs/map/widgets/mapbox/`)

Used by `EmbeddedStageMap` (shown inside `StageMapScreen`). Owns its own `StageMapCubit`, a `PolylineDelegate`, two separate `WidgetMarkerDelegate`s (one for combine markers, one for the single directional arrow), and a `MapLocationHandler`.

The two-delegate split lets the combine-marker clear / redraw logic run without wiping the arrow. `_stageIdByPolylineAnnotationId` and `_stageIdByCombineMarkerAnnotationId` maps translate annotation tap events back to stage IDs so taps can drive `cubit.onSelectStage(...)`.

### `CityAlberguesMapController` (`lib/tabs/route/screens/city_details/mapbox/`)

Used by the `CityAlberguesMap` widget, which is itself used in five places (city details, city full map, city full map route, albergue map section, full-map screen). Owns:
- `AlbergueClusterDelegate` for albergue markers (native clustering).
- `PolylineDelegate` for optional route / alt-route overlays.
- `CityMarkerDelegate` (if a city is passed in) for the single city marker.

The initialisation order matters — cluster setup must run before the city-marker's annotation manager is created so the city marker sits on top. See [Gotchas](#gotchas-surfaced-during-migration).

---

## Per-screen drawing

### `MapScreen` (main navigation tab)

File: `lib/tabs/map/map_screen.dart` → `MapScreenController`.

**What's drawn**

| Element | Delegate / handler | Details |
|---|---|---|
| Main route polyline | `PolylineDelegate.manager.create(...)` | Red, width 3, `lineSortKey=1.0` |
| Selected sub-route polyline | `PolylineDelegate.manager.create(...)` | `AppColors.primary40/80` (theme-aware), width 4, `lineSortKey=2.0`; only drawn when both `startingCityId` and `destCityId` are set |
| Alt-route polylines | `PolylineDelegate.manager.create(...)` per alt | `HexColor.fromHex('88${ap.color}')` (50 % alpha), width 2, `lineSortKey=0.5` |
| Directional arrows | `MapClusterHandler.updateArrowsForViewport(...)` | ~4 evenly-spaced arrows inside the current viewport, `iconRotate` from segment bearing. Re-computed 300 ms after `onCameraChange`, plus on `onMapIdle` |
| First / last city + starting / destination city markers | `MapMarkerHandler.createFirstLastCityAnnotations(...)` | Widget-based markers, cached by `_buildMarkerCacheKey` |
| City clustering | `MapClusterHandler.handleCities(...)` | Native GeoJSON + SymbolLayer clustering |
| Elevation indicator | `MapChartHandler` + `MapMarkerHandler` | A single `PointAnnotation` whose image is a pre-cached circle bitmap |
| Location puck + pulse | `MapLocationHandler` → `map.location.updateSettings(...)` | Pulsing enabled when `myLocationEnabled` is true |

**Lifecycle**

- `onMapCreated` — initialises the polyline delegate, creates a `PointAnnotationManager` for the marker handler, applies `GestureDelegate`, fits bounds, draws polylines, pre-creates the elevation icon.
- `onStyleLoaded` — redraws polylines + first/last city annotations (annotation layers are wiped by `loadStyleURI` on satellite toggle).
- `onCameraChange` — debounced (300 ms) viewport-arrow re-compute.
- `onMapIdle` — viewport-arrow update + `updateFirstLastCityMarkersVisibility(zoom)`.

Auto-download for this route fires on the first `addPostFrameCallback` after `initialize()` and again whenever `didUpdateWidget` delivers a non-empty `points` list for the first time.

### `SelectRouteMapWidget`

Files: `lib/tabs/route/screens/select_route/widgets/select_route_map_widget.dart` → `SelectRouteMapController` → `RouteLayerDelegate`.

**What's drawn**

All routes are packed into two GeoJSON sources with feature-state-based highlighting — no annotation managers at all on this screen.

| Element | Details |
|---|---|
| Route lines | `route-lines-layer` (`LineLayer`) — width 3 (base) / 5 (highlighted), colour = `baseColor` / `selectedColor` from the feature's properties; line-sort-key boosted when highlighted so it sits above overlapping routes |
| Route labels | `route-labels-layer` (`SymbolLayer`) — `text-field: ['get', 'label']` at the route's mid-point, halo colour = route legend colour, sort key = `−RouteLabelResolver.priorityOf(route)` (so preferred routes' labels render first when overlapping) |
| Preview panel | Flutter-side — `ValueListenableBuilder` on `controller.previewRoute` |

**Why style-layer rendering here and not annotations?** Select-route renders up to ~30 routes simultaneously with hover-like highlight behaviour. Feature-state updates are essentially free (no source data change, no layer teardown); annotation managers would require O(n) create/update calls on every selection change.

**Tap handling** is a two-pass query in `_queryTappedRouteId`:
1. First query the label layer (labels are small — exact hits only).
2. Fall back to a 10 px-padded `ScreenBox` query against the line layer (finger-friendly hit area for thin polylines).

### `CityAlberguesMap`

Files: `lib/tabs/route/screens/city_details/city_albergues_map.dart` → `CityAlberguesMapController`.

**What's drawn**

| Element | Delegate | Details |
|---|---|---|
| Albergue markers + clustering | `AlbergueClusterDelegate` | GeoJSON source (`cluster: true`, `clusterRadius: 50`, `clusterMaxZoom: 16`). Three symbol layers: individual hotel-circle icon, cluster hotel icon, cluster count badge |
| Optional route / alt-route polylines | `PolylineDelegate.syncRoutePolylines` | Uses the shared `PolylineStyleDefs` |
| City marker (if passed) | `CityMarkerDelegate` | Rendered from `CityMarkerHelper.createCityImage(city, style)`. Initialised AFTER cluster layers so it stacks on top |

**Layer stacking order** (from Mapbox `addLayer` append-to-top semantics):

```
bottom ─────────────────────────────────────────────── top
1. route polyline (PolylineAnnotationManager)
2. individual albergue marker layer
3. cluster hotel icon layer
4. cluster count badge layer
5. city marker (CityMarkerDelegate's own PointAnnotationManager)
```

**Tap handling** — single `setOnMapTapListener` on the map delegates to `AlbergueClusterDelegate.handleTap(...)`. Cluster hits fly to `(center, currentZoom + 3)`; individual hits resolve `albergueId` back to the list and dispatch `onMarkerTap(albergueLocation)`.

### `StageMapScreen` / `EmbeddedStageMap`

Files: `lib/tabs/plan/screens/stage_map/stage_map_screen.dart` (shell) → `lib/tabs/map/widgets/embedded_stage_map.dart` (body) → `EmbeddedStageMapController`.

**What's drawn**

| Element | Delegate | Details |
|---|---|---|
| Main route polyline | `PolylineDelegate.manager.create` | Red, width 4, `lineSortKey=1.0` |
| Alt-route polylines | `PolylineDelegate.manager.create` per alt | `88${hex}` colour, width 3, `lineSortKey=2.0` |
| Selected-stage polyline | `PolylineDelegate.manager.create` | Primary color (dark or light), width 5, `lineSortKey=4.0` — sits on top |
| Unselected-stage polylines | `PolylineDelegate.manager.create` per stage | Gray-400/500 (theme-aware), width 5, `lineSortKey=3.0` |
| Combine markers (cities with start/end stage labels) | `_combineMarkerDelegate` (`WidgetMarkerDelegate`) | Rendered from `CombineMarker` widget, cached by `_buildMarkerCacheKey(d, isDark)` |
| Single directional arrow | `_arrowMarkerDelegate` (separate `WidgetMarkerDelegate`) | Placed at the middle point of the selected stage's route, rotated to match the bearing between the preceding and following points |
| Location puck | `MapLocationHandler` | Same as `MapScreen` |

**Selection → redraw** — `onCubitStateChanged` detects `_previousSelectedStageId != state.selectedStage?.id` and redraws polylines + markers + arrow, then refits bounds to the new selected stage. Redrawing is ~O(stages) but stage counts are small (< 20 typically).

**Annotation-ID → stage-ID maps** — `_stageIdByPolylineAnnotationId` and `_stageIdByCombineMarkerAnnotationId` are rebuilt on every draw (annotation IDs roll over between clears). A tap listener on each manager looks up the stage and dispatches `cubit.onSelectStage(...)`.

### `StageSmallMap` (add/edit stage)

File: `lib/tabs/plan/screens/add_edit_stage/widgets/stage_map.dart` → `StageSmallMapController`.

**What's drawn**

| Element | Details |
|---|---|
| Whole route polyline | Red when there IS a selected portion (so it visually fades behind it), primary colour otherwise. Width 3 / 4 |
| Selected-stage polyline | Primary colour (theme-aware), width 4 |

Gestures disabled (`scrollEnabled: false`, `pinchToZoomEnabled: false`, `doubleTapToZoomInEnabled: false`, `quickZoomEnabled: false`). The controller refits bounds every time `update(...)` is called so the selected portion stays centred as the user scrubs.

---

## Marker rendering pipeline

The widget-to-bitmap pipeline is shared by every screen that draws a Flutter-widget-based marker:

```
Flutter widget (e.g. CityMarker, CombineMarker, StageDirectionalArrowMarker)
  │
  ▼
MarkerHelper.widgetToBitmapDescriptor(context, widget, cacheKey)
  │  renders widget → OffStage → RepaintBoundary → toImage → PNG bytes
  │  cached in-memory keyed by cacheKey (cleared on theme change via
  │  MarkerHelper.clearWidgetMarkerCache())
  ▼
Uint8List bitmap
  │
  ▼
PointAnnotationOptions(image: bitmap, geometry: Point(...), iconAnchor, iconRotate, symbolSortKey)
  │
  ▼
WidgetMarkerDelegate.manager.create(...) → PointAnnotation
```

Cache keys encode the inputs that affect the rendered pixels — e.g. for combine markers:
```
city_{cityId}_{mode}_s{startStageId}_{isSelected},..._e{endStageId}_{isSelected},...
```
This means identical markers on different selections reuse the same bitmap and the only redraws are for visually-changed markers.

---

## Style swapping (dark / light / satellite)

When the user toggles the satellite button (`lib/widgets/satellite_toggle_button.dart`), the map reloads a new style URI:

```dart
await mapboxMap.loadStyleURI(
  isSatellite ? MapboxMapStyle.satellite
              : (isDark ? MapboxMapStyle.dark : MapboxMapStyle.light),
);
```

A style reload wipes all annotation layers. Every controller has an `onStyleLoaded` hook that redraws everything:

- `MapScreenController.onStyleLoaded` — redraws polylines, updates viewport arrows, re-creates first/last city annotations.
- `SelectRouteMapController.onStyleLoaded` — calls `RouteLayerDelegate.setup(...)` (which tears down existing sources/layers then adds fresh ones with the current GeoJSON), then re-applies the highlighted route.
- `CityAlberguesMapController.onStyleLoaded` — calls `_cityMarkerDelegate.resetForStyleReload()` before `_syncAll()` so the city marker's `PointAnnotationManager` is recreated **after** the albergue cluster layers (otherwise it would sit beneath them after a satellite toggle).
- `EmbeddedStageMapController.onStyleLoaded` — redraws polylines, combine markers, and directional arrow against the existing delegates (the arrow and combine-marker annotation managers persist across style swaps — this mirrors pre-migration behaviour and matches what the Mapbox SDK actually does on a `loadStyleURI`).

On **theme swap (dark ↔ light)** specifically:
- `MarkerHelper.clearWidgetMarkerCache()` is called so cached bitmaps don't leak the old theme colours into the new theme.
- `EmbeddedStageMapController.onAppThemeChanged` schedules a post-frame redraw with explicit `isDarkOverride` + `textThemeOverride` so theme-dependent values don't get read out of a stale context.
- `MapScreen` redraws polylines only (text colour is handled by the marker cache key, so cache clears redraw markers automatically on next frame).

---

## Gotchas surfaced during migration

A short list of the non-obvious things the migration had to get right. Most of these are encoded as explicit comments in the code.

1. **Position order is longitude-first.** Google's `LatLng(lat, lng)` vs. Mapbox's `Position(lng, lat)` is the #1 source of silent bugs. `MapUtil` centralises the conversion.

2. **Access token must be set AFTER `setDataPath`** (relevant once offline is enabled). `OfflineMapService.configureTileStore()` is where the app would call `MapboxMapsOptions.setDataPath(...)`. If `setAccessToken` ran first, the Maps engine would cache under the default path and never see the TileStore directory. Today this is dormant — `configureTileStore()` returns early on its disabled flag — but the call order in `main_*.dart` is already correct so revival doesn't require touching startup again.

3. **Annotation managers are layered in creation order.** `addLayer` appends to the top of the style-layer stack. `CityMarkerDelegate.initialize` must run AFTER `AlbergueClusterDelegate.setup` or the city marker sits underneath the cluster icons.

4. **Annotation layers do NOT survive a style reload.** Every controller resets the affected delegates in `onStyleLoaded`. Without this, satellite toggle silently removes all markers.

5. **`TileStore.loadTileRegion` is not cancellable.** Cancellation is implemented as (a) set `_isDownloading = false` to suppress progress callbacks, (b) `removeRegion(regionId)` to reclaim disk, (c) ignore the native future when it resolves. See [`OFFLINE_MAP.md`](OFFLINE_MAP.md).

6. **Annotation IDs roll over between `deleteAll()` calls.** Controllers that map annotation IDs to domain IDs (stage, albergue, route) rebuild those maps on every redraw.

7. **Clustering lives at two different layers.**
   - City markers on `MapScreen` use a Dart-side wrapper over native GeoJSON clustering (`MapClusterHandler`) so they can be redrawn reactively as the cubit's city stream emits.
   - Albergue markers use pure-native clustering (`AlbergueClusterDelegate`) because they're static per city and don't need reactive redraws.

8. **`cameraForCoordinatesPadding` can throw on degenerate input** (e.g. all points collapsed to one lat/lng before the first layout). `MapUtil.fitBounds` catches the pigeon error and falls back to a manual zoom-calculation path.

9. **Gesture config flags are not a direct map of Google's.** `scrollEnabled` / `pinchToZoomEnabled` / `doubleTapToZoomInEnabled` are the ones we actually use; Mapbox additionally exposes `quickZoomEnabled` which `StageSmallMapController` explicitly disables (it isn't in `GestureDelegate`'s defaults because only that screen needs it off).
