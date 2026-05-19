# Offline Map — Future Plan (Currently Disabled)

> **Status — not shipped.** The offline-map feature described below is **not active** in the app today. The code scaffolding (`OfflineMapService`, `OfflineMapRepository`, DI registration) is checked in and dormant: `OfflineMapService` carries `static const bool _isEnabled = false;` so every public method is a no-op (including `configureTileStore()` called from `main_*.dart`), and `OfflineMapRepository` has the same flag as a defense-in-depth outer gate. No tiles are downloaded, no style packs are written to disk, no `TileStore` directory is created. **The Mapbox migration shipped in this PR uses online tiles only.**
>
> This document is preserved as the **design blueprint** for the feature when we revive it as a paid offering. To enable: flip both `_isEnabled` constants to `true` and build the UI listed in the "What to Build Next" section. Everything below describes the intended behaviour once enabled — not current runtime behaviour.

## Overview

This document covers the planned offline map feature built on top of Mapbox Maps Flutter SDK v2.21.1. It explains the technical solution, which files were added, estimated storage per route, Mapbox billing for offline downloads, Mapbox billing for normal online usage, and device performance characteristics on iOS and Android.

---

## Technical Solution

### How Mapbox offline works (SDK v10+)

The Mapbox v10+ SDK stores two kinds of downloadable assets:

| Asset | What it contains | Size |
|---|---|---|
| **Style pack** | Fonts, glyphs, sprites, layer rules | ~3–6 MB per style |
| **Tile region** | Map tile images for a geographic area + zoom range | Varies (see below) |

Both live in a local **TileStore** directory on device. Once written there, every `MapWidget` in the app reads from that store automatically — no code change is needed in any existing map screen.

### Architecture

```
App startup
  OfflineMapService.configureTileStore()   ← sets global TileStore path
  MapboxOptions.setAccessToken(...)        ← must come AFTER

User triggers download (via OfflineMapCubit)
  Phase 1 — Style pack light   (mapbox://styles/mapbox/outdoors-v12)
  Phase 2 — Style pack dark    (mapbox://styles/mapbox/dark-v11)
  Phase 3 — Tile region        (route LineString, zoom 5–15)

Every MapWidget (online or offline)
  SDK checks TileStore first → falls back to network if not cached
```

### Files added

| File | Role |
|---|---|
| `lib/utils/offline_map_service.dart` | Core service wrapping `TileStore` + `OfflineManager` |
| `lib/tabs/map/cubit/offline_map_cubit.dart` | BLoC cubit — manages download state |
| `lib/tabs/map/cubit/offline_map_state.dart` | State definitions |

One-line additions in `main_development.dart`, `main_staging.dart`, `main_production.dart`, and `dependency_injection.dart`. **Zero changes** to any existing map widget.

### Map screens covered

| Screen | Zoom used | Covered by download? |
|---|---|---|
| `SelectRouteMapWidget` | 5–10 | Yes (zoom 5–15 pack) |
| `MapScreen` (main navigation) | 8–15 | Yes |
| `EmbeddedStageMap` | 10–15 | Yes |
| `StageSmallMap` | 10–14 | Yes |
| `CityAlberguesMap` | 14–18 | Partial — works up to zoom 15, may appear lower-res when zoomed in further |

Satellite tiles are intentionally **excluded** from offline downloads — raster satellite tiles are 5–10× larger than vector tiles and rarely needed for hiking navigation.

### Download strategy

- **Style packs** are downloaded once and shared across all routes. Already-downloaded packs are skipped on re-download.
- **Tile regions** use the route's LineString geometry (simplified to ~200 points via striding). Mapbox downloads only tiles that intersect the route line — not an entire bounding box — which keeps the size proportional to route length.
- Zoom range **5–15** covers overview navigation (select-route screen at zoom 5) through street-level navigation (zoom 15). Zoom 16–18 is skipped to contain download size.

### State machine

```
initial
  └─ checkStatus(routeId)
       ├─ checking
       ├─ notDownloaded
       └─ downloaded (storageSizeBytes populated)

notDownloaded
  └─ startDownload(routeId, routeName, points)
       ├─ downloading / phase: stylePackLight  (progress 0→1)
       ├─ downloading / phase: stylePackDark   (progress 0→1)
       ├─ downloading / phase: tiles           (progress 0→1, completedTiles, totalTiles)
       └─ downloaded  ──or──  error(message)

downloaded
  └─ deleteDownload(routeId)
       ├─ deleting
       └─ notDownloaded

downloading
  └─ cancelDownload()
       └─ notDownloaded  (partial region removed from disk)
```

### Cancellation behaviour

The Mapbox SDK does not expose a `Cancelable` from `TileStore.loadTileRegion`. Cancellation works by:
1. Setting an `_isDownloading = false` flag — stops progress callbacks immediately.
2. Calling `TileStore.removeRegion` for the active route — cleans up any partially downloaded tiles so storage is not wasted.
3. A generation counter in `OfflineMapCubit` ensures that if the native future resolves after cancel, the subsequent `checkStatus` call is skipped and the `notDownloaded` state is not overwritten.

---

## Storage Size Estimates

Sizes below are for vector tiles (light + dark styles combined) at zoom 5–15 with a route-geometry-intersect strategy. Actual sizes vary with terrain complexity and Mapbox tile server compression.

| Route | Distance | Estimated download |
|---|---|---|
| Single stage (50 km) | 50 km | 15–25 MB |
| Camino Portugués | 250 km | 80–120 MB |
| Camino del Norte | 820 km | 280–380 MB |
| Camino Francés | 800 km | 250–350 MB |
| Style packs (light + dark) | shared | 8–12 MB (one-time) |

**Recommendation:** Offer per-stage downloads (~15–25 MB each) as the default option. Full-route downloads should be WiFi-only and clearly labelled with the estimated size before the user confirms.

---

## Performance

### iOS (Metal renderer, iOS 13+)

| Metric | Online | Offline (TileStore) |
|---|---|---|
| Tile load latency | 80–250 ms (network round-trip) | < 5 ms (local disk) |
| Map widget open time | 1–3 s (first cold load) | 200–500 ms |
| Camera animation smoothness | Dependent on network | Identical to online — no jank |
| RAM usage | ~80–120 MB | ~80–120 MB (no difference) |
| Battery drain | Moderate (cellular/WiFi radio active) | Low (no network radio) |
| Download speed | 5–15 MB/s on WiFi | — |
| Background download | Pauses when app backgrounds (iOS limitation) | — |

### Android (OpenGL ES 3 / Vulkan)

| Metric | Online | Offline (TileStore) |
|---|---|---|
| Tile load latency | 100–350 ms | < 10 ms |
| Map widget open time | 1.5–4 s | 300–700 ms |
| Camera animation smoothness | Network-dependent | Smooth |
| RAM usage | ~100–150 MB (higher OEM variance) | Same |
| Battery drain | Moderate | Lower |
| Low-end devices (< 2 GB RAM) | Zoom 14+ may stutter | Same behaviour — bottleneck is GPU, not network |
| Background download | Stops on aggressive OEMs (MIUI, OxygenOS) | Use WorkManager for reliable background downloads |

### Cross-platform notes

- **Expired tiles:** The service sets `acceptExpired: true`. If Mapbox marks cached tiles as expired (past their `Cache-Control` TTL), the SDK will still serve them from disk when offline rather than failing with a blank map.
- **Style pack glyphs:** `GlyphsRasterizationMode.ALL_GLYPHS_RASTERIZED_LOCALLY` is used, meaning all text is rendered using on-device fonts. This reduces style pack download size and eliminates font-related network requests entirely.
- **First offline render:** The very first render after download is slightly slower (~100 ms) as SQLite pages are loaded into the OS file cache. Subsequent renders are near-instant.
- **Partial coverage at zoom 16+:** `CityAlberguesMap` uses zoom up to 18 for albergue street-level detail. Tiles at zoom 16–18 are not downloaded. The map will show tiles at zoom 15 (slightly lower resolution) when zoomed in past the downloaded range, rather than going blank.

---

## What to Build Next

The service and cubit are production-ready. The following UI components are needed to expose the feature to users:

1. **Download button on `MapScreen`** — cloud-download icon; calls `OfflineMapCubit.checkStatus()` on screen load; switches to checkmark + delete option when `status == downloaded`.
2. **Download progress bottom sheet** — shows current phase label (`Downloading map styles…` / `Downloading route tiles…`) and a `LinearProgressIndicator` driven by `state.progress`.
3. **Pre-download size estimate dialog** — shown before download starts; displays estimated MB based on route distance so users can decide whether to use WiFi.
4. **Offline indicator banner** — small chip in `MapScreen` when `connectivity_plus` reports no network, confirming the user is viewing cached tiles.
5. **Storage management screen** (Settings) — lists downloaded routes with individual sizes from `listDownloadedRegions()`, total storage used, delete-per-route and delete-all actions.
