# Switch from Google Maps to Mapbox with Offline Support



## Context



The app currently uses `google_maps_flutter` (+ `google_maps_cluster_manager_2`) for all map rendering across ~10 screens. The goal is to replace Google Maps with Mapbox to enable **offline tile downloading per-route corridor** — critical for Camino pilgrims who walk through areas with poor connectivity.



The `mapbox_maps_flutter` package (Mapbox GL Native) provides built-in offline tile management via `OfflineManager` / `TileStore`, which Google Maps does not offer. This is the primary motivation for the switch.



## Scope of change



```

29 files import google_maps_flutter or google_maps_cluster_manager_2

```



The migration touches three layers:



```

┌─────────────────────────────────────────────────────────┐

│  Platform config                                         │

│  (Android manifest, iOS AppDelegate, build.gradle,       │

│   .env files, pubspec.yaml)                              │

├─────────────────────────────────────────────────────────┤

│  Shared utilities                                        │

│  (MapUtil, map_style, marker helpers, route distance     │

│   calculator, route label resolver, cluster handler)     │

├─────────────────────────────────────────────────────────┤

│  Map screens                                             │

│  (MapScreen, CityAlberguesMap, StageMapScreen,           │

│   EmbeddedStageMap, SelectRouteMapWidget, StageSmallMap, │

│   CityMap, CityFullMapScreen, FullMapScreen,             │

│   stage_overview_card, route_overview_card, etc.)        │

├─────────────────────────────────────────────────────────┤

│  New: Offline map service                                │

│  (Download manager, UI for download progress)            │

└─────────────────────────────────────────────────────────┘

```



## Implementation Plan



### Phase 1: Dependencies & Platform Config



**1a. Update `pubspec.yaml`**

- Remove: `google_maps_flutter`, `google_maps_cluster_manager_2`

- Add: `mapbox_maps_flutter: ^2.4.0`

- Keep: `map_launcher` (for external navigation links — unrelated to map rendering)



**1b. Environment config**

- Add `MAPBOX_ACCESS_TOKEN` to `.env.development`, `.env.staging`, `.env.production`

- Add getter in `lib/app_env.dart`:

  ```dart

  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  ```



**1c. Android config**

- `android/app/src/main/AndroidManifest.xml`: Remove the `com.google.android.geo.API_KEY` meta-data entry

- `android/app/build.gradle`: Remove `googleMapsApiKey` variable and `manifestPlaceholders` references to it



**1d. iOS config**

- `ios/Runner/AppDelegate.swift`: Remove `import GoogleMaps` and `GMSServices.provideAPIKey(...)` call

- `ios/Runner/Info.plist`: Remove `GOOGLE_MAPS_API_KEY` entry

- Mapbox token is configured in Dart via `MapboxOptions.setAccessToken()` at app startup



**1e. App startup**

- In each `main_*.dart`, after `AppEnv.load()`, call:

  ```dart

  MapboxOptions.setAccessToken(AppEnv.mapboxAccessToken);

  ```



---



### Phase 2: Shared Utilities Migration



**2a. Create `lib/utils/mapbox_map_style.dart`** (replaces `map_style.dart`)

- Define light and dark Mapbox style URLs (e.g., `mapbox://styles/mapbox/outdoors-v12` for light, `mapbox://styles/mapbox/dark-v11` for dark)

- The Google Maps JSON style format is not needed — Mapbox uses style URLs



**2b. Migrate `lib/utils/map_util.dart`**

- Replace `GoogleMapController` → `MapboxMap`

- Replace `LatLng` (google) → `Point` (mapbox uses GeoJSON `Point` with `Position(lng, lat)` — note: **longitude first**)

- `fitBounds()`: Use `MapboxMap.cameraForCoordinateBounds()` + `MapboxMap.flyTo()` instead of `GoogleMapController.animateCamera(CameraUpdate.newCameraPosition(...))`

- `getLatLngsFromRoutePoints` / `getLatLngsFromChartRoutePoints`: Return `List<Position>` instead of `List<LatLng>`



**2c. Migrate marker helpers**



Mapbox uses annotation managers instead of `Marker` objects:

- `PointAnnotationManager` for markers (city markers, albergue markers, elevation indicator)

- `CircleAnnotationManager` for simple circles (elevation dot)



Key changes:

- `lib/utils/marker_helpers/marker_helper.dart`: `BitmapDescriptor` → `Uint8List` image bytes passed to `PointAnnotation.image`. The `widgetToBitmapDescriptor` method becomes `widgetToAnnotationImage` returning `Uint8List`

- `lib/utils/marker_helpers/city_marker_helper.dart`: `Marker(markerId:..., position:..., icon:...)` → `PointAnnotationOptions(geometry: Point(...), image: ...)`. Remove `ClusterItem` mixin (Mapbox has its own clustering)

- `lib/utils/marker_helpers/albergue_marker_helper.dart`: Same pattern. Remove `google_maps_cluster_manager_2` dependency entirely

- `lib/utils/marker_helpers/directional_arrows_marker_helper.dart`: Same. Arrow rotation via `PointAnnotationOptions.iconRotate`

- `lib/utils/marker_helpers/route_marker_helper.dart`: Same pattern for route label markers



**2d. Migrate `lib/utils/route_distance_calculator.dart`**

- Replace `LatLng` imports from google_maps to use a simple local `LatLng` class or `Position` from mapbox_maps_flutter. Since this file only uses `LatLng` as a data holder for lat/lon pairs, create a minimal `lib/utils/lat_lng.dart` typedef or use Mapbox's `Position(lng, lat)`.



**2e. Migrate `lib/utils/route_label_resolver.dart`**

- Same as 2d — replace google `LatLng` and `LatLngBounds` with Mapbox equivalents (`Position`, `CoordinateBounds`)



**2f. Migrate `lib/tabs/map/map_cluster_handler.dart`**

- Remove `google_maps_cluster_manager_2` usage entirely

- Mapbox GL Native supports **built-in source-level clustering** via GeoJSON sources with `cluster: true`. This is more performant than the Flutter-side cluster manager

- City clustering: Add cities as a GeoJSON source with clustering enabled on the `SymbolLayer`

- Arrow clustering: Same approach with a separate source/layer



**2g. Migrate `lib/tabs/map/map_marker_handler.dart`**

- Replace `Marker` / `BitmapDescriptor` with Mapbox `PointAnnotation` objects

- `GoogleMapController? Function()` → `MapboxMap? Function()`



**2h. Migrate `lib/tabs/map/map_chart_handler.dart`**

- Replace `GoogleMapController` with `MapboxMap`

- `getZoomLevel()` → `MapboxMap.getCameraState()` then read zoom

- `fitBounds` calls already go through `MapUtil`



**2i. Migrate `lib/tabs/map/map_location_handler.dart`**

- Replace `GoogleMapController` with `MapboxMap`

- `animateCamera(CameraUpdate.newCameraPosition(...))` → `MapboxMap.flyTo(CameraOptions(center: Point(...), zoom: ...))`

- User location: Mapbox has built-in `LocationComponentSettings` — enable via `MapboxMap.location.updateSettings(...)`



---



### Phase 3: Screen Migration



Each screen follows the same pattern:



| Google Maps | Mapbox |

|---|---|

| `GoogleMap(...)` widget | `MapWidget(...)` from mapbox_maps_flutter |

| `onMapCreated: (GoogleMapController c)` | `onMapCreated: (MapboxMap map)` |

| `CameraPosition(target: LatLng(...), zoom: ...)` | `CameraOptions(center: Point(...), zoom: ...)` |

| `MapType.satellite / MapType.normal` | Switch style URL between satellite and streets |

| `Polyline(polylineId:..., points:..., color:...)` | Add a GeoJSON `LineLayer` with `LineString` geometry |

| `Marker(markerId:..., position:..., icon:...)` | `PointAnnotation` via `PointAnnotationManager` |

| `myLocationEnabled: true` | `map.location.updateSettings(LocationComponentSettings(enabled: true))` |

| `style: darkMapStyle` (JSON) | `styleUri: mapboxDarkStyleUrl` |



**Screens to migrate (in order):**

1. `lib/tabs/plan/screens/add_edit_stage/widgets/stage_map.dart` — Simplest (polylines only, no markers) — good first target

2. `lib/tabs/route/screens/select_route/widgets/select_route_map_widget.dart` — Polylines + label markers

3. `lib/tabs/route/screens/city_details/city_albergues_map.dart` — Shared component used by multiple screens; city markers + albergue markers + clustering

4. `lib/tabs/map/map_screen.dart` — Main map tab; most complex (polylines, clusters, location, elevation, chart interaction)

5. `lib/tabs/plan/screens/stage_map/stage_map_screen.dart` — Stage map with combine markers + directional arrows

6. `lib/tabs/map/widgets/embedded_stage_map.dart` — Near-copy of stage_map_screen

7. Remaining screens that use `CityAlberguesMap` or `LatLng` (city_map.dart, city_full_map_screen.dart, city_full_map_route_screen.dart, full_map_screen.dart, alberbue_map_section.dart, route_overview_card.dart, stage_overview_card.dart, city_details_screen.dart, albergue_details_screen.dart)



**Polylines in Mapbox**: Instead of passing `Set<Polyline>` to the widget, add a `GeoJsonSource` with `LineString`/`MultiLineString` geometry and a `LineLayer` to style it. This is done imperatively after `onMapCreated`.



**Satellite toggle**: Switch between `MapboxStyles.SATELLITE_STREETS` and `MapboxStyles.OUTDOORS` (or custom style URLs) via `MapboxMap.loadStyleURI()`.



---



### Phase 4: Offline Map Support



**4a. Create `lib/services/offline_map_service.dart`**



```dart

class OfflineMapService {

  /// Downloads map tiles along a route corridor

  Future<void> downloadRouteRegion({

    required int routeId,

    required List<RoutePointEntity> routePoints,

    required double bufferKm, // e.g. 5km either side

    required double minZoom,  // e.g. 6

    required double maxZoom,  // e.g. 16

    void Function(double progress)? onProgress,

  });



  /// Check if a route's offline region exists

  Future<bool> isRouteDownloaded(int routeId);



  /// Delete a downloaded route region

  Future<void> deleteRouteRegion(int routeId);



  /// Get total size of downloaded tiles

  Future<int> getDownloadedSizeBytes();



  /// List all downloaded route regions

  Future<List<OfflineRouteRegion>> getDownloadedRegions();

}

```



Implementation uses Mapbox's `OfflineManager` and `TileStore`:

- Compute a bounding polygon from the route points + buffer

- Create a `TileRegionLoadOptions` with the geometry, zoom range, and style URI

- Track download progress via the stream returned by `TileStore.loadTileRegion()`



**4b. Create `lib/services/offline_route_region.dart`** — Data class for stored regions



**4c. Register in DI** — Add `OfflineMapService` to `lib/di/dependency_injection.dart`



**4d. Create `lib/widgets/offline_map_download_widget.dart`**

- Button/card shown on route detail screens: "Download for offline use"

- Shows download progress bar

- Shows "Downloaded" state with delete option

- Shows total storage used



**4e. Create a BLoC/Cubit for managing offline state**

- `lib/tabs/route/cubits/offline_map_cubit.dart`

- States: initial, downloading (with progress), downloaded, error

- Persists download metadata in SharedPreferences or SQLite



**4f. Integrate download widget** into the route detail screen where users prepare for their Camino walk



---



### Phase 5: Cleanup



- Delete `lib/utils/map_style.dart` (Google Maps JSON styles no longer needed)

- Remove all `google_maps_flutter` and `google_maps_cluster_manager_2` imports

- Run `flutter pub get` to verify clean dependency resolution

- Update `ios/Podfile` — run `cd ios && pod install` to remove Google Maps iOS SDK pod



---



## Files to modify (complete list)



**Platform/config:**

- `pubspec.yaml`

- `lib/app_env.dart`

- `lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart`

- `android/app/build.gradle`

- `android/app/src/main/AndroidManifest.xml`

- `ios/Runner/AppDelegate.swift`

- `ios/Runner/Info.plist`

- `.env.development`, `.env.staging`, `.env.production`



**Utilities:**

- `lib/utils/map_util.dart`

- `lib/utils/map_style.dart` → replace with `lib/utils/mapbox_map_style.dart`

- `lib/utils/route_distance_calculator.dart`

- `lib/utils/route_label_resolver.dart`

- `lib/utils/marker_helpers/marker_helper.dart`

- `lib/utils/marker_helpers/city_marker_helper.dart`

- `lib/utils/marker_helpers/albergue_marker_helper.dart`

- `lib/utils/marker_helpers/directional_arrows_marker_helper.dart`

- `lib/utils/marker_helpers/route_marker_helper.dart`



**Handlers:**

- `lib/tabs/map/map_cluster_handler.dart`

- `lib/tabs/map/map_marker_handler.dart`

- `lib/tabs/map/map_chart_handler.dart`

- `lib/tabs/map/map_location_handler.dart`



**Screens:**

- `lib/tabs/plan/screens/add_edit_stage/widgets/stage_map.dart`

- `lib/tabs/plan/screens/add_edit_stage/widgets/stage_overview_card.dart`

- `lib/tabs/route/screens/select_route/widgets/select_route_map_widget.dart`

- `lib/tabs/route/screens/city_details/city_albergues_map.dart`

- `lib/tabs/route/screens/city_details/city_map.dart`

- `lib/tabs/route/screens/city_details/city_full_map_screen.dart`

- `lib/tabs/route/screens/city_details/city_full_map_route_screen.dart`

- `lib/tabs/route/screens/city_details/city_details_screen.dart`

- `lib/tabs/route/screens/city_details/cubit/city_details_cubit.dart`

- `lib/tabs/route/screens/full_map/full_map_screen.dart`

- `lib/tabs/route/screens/full_map/cubit/full_map_cubit.dart`

- `lib/tabs/route/screens/albergue_details/alberbue_map_section.dart`

- `lib/tabs/route/screens/albergue_details/cubit/albergue_details_cubit.dart`

- `lib/tabs/route/screens/albergue_details/albergue_details_screen.dart`

- `lib/tabs/route/widgets/route_overview_card.dart`

- `lib/tabs/map/map_screen.dart`

- `lib/tabs/map/widgets/embedded_stage_map.dart`

- `lib/tabs/plan/screens/stage_map/stage_map_screen.dart`



**New files:**

- `lib/utils/mapbox_map_style.dart`

- `lib/services/offline_map_service.dart`

- `lib/services/offline_route_region.dart`

- `lib/tabs/route/cubits/offline_map_cubit.dart`

- `lib/tabs/route/cubits/offline_map_state.dart`

- `lib/widgets/offline_map_download_widget.dart`



## Verification



1. `flutter pub get` — clean resolution, no google_maps references

2. `flutter analyze` — no lint errors

3. `flutter test` — existing tests pass (update any tests that reference google maps types)

4. Manual testing on each screen:

   - Maps render with correct light/dark style

   - Polylines display correctly (route, selected route, alt routes)

   - City markers, albergue markers, directional arrows appear

   - Clustering works for cities and albergues

   - Satellite toggle works

   - My location button works

   - Elevation chart interaction moves marker on map

   - Stage selection updates map correctly

5. Offline testing:

   - Download a route corridor

   - Enable airplane mode

   - Verify map tiles load from cache

   - Verify download progress UI works

   - Verify delete/re-download works

