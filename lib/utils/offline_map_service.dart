import 'dart:async';
import 'dart:io';

import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storage/storage.dart';

/// Service that manages offline map downloads using Mapbox
/// [OfflineManager] and [TileStore].
///
/// Downloads style packs (light + dark) and tile regions for
/// pilgrimage routes so they are available without network.
class OfflineMapService {
  static const String _tag = 'OfflineMapService';

  /// Defense-in-depth kill switch for the offline-map feature.
  ///
  /// The outer `OfflineMapRepository` is the primary guard, but
  /// [configureTileStore] is invoked directly from `main_*.dart`
  /// and bypasses the repository. Keeping this flag here ensures
  /// every public entry point on the service is inert while the
  /// feature is dormant.
  static const bool _isEnabled = false;

  static const int _minZoom = 5;
  static const int _maxZoom = 15;
  static const int _targetPointCount = 200;

  static String? _tileStorePath;

  TileStore? _tileStore;
  OfflineManager? _offlineManager;
  bool _isDownloading = false;
  int? _activeRouteId;

  /// Called BEFORE [MapboxOptions.setAccessToken] in main.
  /// Sets the global data path so the Maps engine and
  /// TileStore share the same directory.
  static Future<void> configureTileStore() async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — skipping configureTileStore',
        tag: _tag,
      );
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    _tileStorePath = '${dir.path}/mapbox_tiles';
    final tileDir = Directory(_tileStorePath!);
    if (!tileDir.existsSync()) {
      await tileDir.create(recursive: true);
    }
    MapboxMapsOptions.setDataPath(_tileStorePath!);
  }

  Future<void> _ensureInitialized() async {
    if (!_isEnabled) {
      return;
    }
    if (_tileStorePath == null) {
      throw StateError(
        'OfflineMapService.configureTileStore() must be called '
        'before using OfflineMapService.',
      );
    }
    _tileStore ??= await TileStore.createAt(
      Uri.parse(_tileStorePath!),
    );
    _offlineManager ??= await OfflineManager.create();
  }

  /// Downloads style packs for light and dark map styles.
  ///
  /// Skips styles that are already fully downloaded.
  /// Uses [GlyphsRasterizationMode.ALL_GLYPHS_RASTERIZED_LOCALLY]
  /// to reduce download size.
  Future<void> downloadStylePacks({
    required void Function(String styleUri, double progress)
        onProgress,
  }) async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — skipping downloadStylePacks',
        tag: _tag,
      );
      return;
    }
    await _ensureInitialized();

    final styles = [MapboxMapStyle.light, MapboxMapStyle.dark];

    for (final styleUri in styles) {
      if (!_isDownloading) return;

      if (await _isStylePackDownloaded(styleUri)) {
        AppLogger.d(
          '[OFFLINE] Style pack already cached: $styleUri',
          tag: _tag,
        );
        onProgress(styleUri, 1);
        continue;
      }

      AppLogger.d(
        '[OFFLINE] Downloading style pack: $styleUri',
        tag: _tag,
      );
      final loadOptions = StylePackLoadOptions(
        glyphsRasterizationMode:
            GlyphsRasterizationMode.ALL_GLYPHS_RASTERIZED_LOCALLY,
        acceptExpired: true,
      );

      try {
        await _offlineManager!.loadStylePack(
          styleUri,
          loadOptions,
          (progress) {
            if (!_isDownloading) return;
            final total = progress.requiredResourceCount;
            final done = progress.completedResourceCount;
            final fraction =
                total > 0 ? done.toDouble() / total : 0.0;
            AppLogger.d(
              '[OFFLINE] Style pack progress: $done/$total '
              '(${(fraction * 100).toStringAsFixed(0)}%)',
              tag: _tag,
            );
            onProgress(styleUri, fraction);
          },
        );
        AppLogger.d(
          '[OFFLINE] Style pack downloaded: $styleUri',
          tag: _tag,
        );
        onProgress(styleUri, 1);
      } catch (e, stackTrace) {
        AppLogger.e(
          'Failed to download style pack: $styleUri',
          tag: _tag,
          error: e,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    }
  }

  /// Downloads a tile region for the given route.
  ///
  /// The route geometry is simplified to ~200 points using
  /// striding. Tiles are downloaded for zoom levels 5–15
  /// covering all map screens in the app.
  ///
  /// Returns `false` without throwing if the download was
  /// cancelled before it completed.
  Future<bool> downloadRouteRegion({
    required int routeId,
    required String routeName,
    required List<RoutePointEntity> points,
    required void Function(
      double progress,
      int completed,
      int total,
    ) onProgress,
  }) async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — skipping downloadRouteRegion',
        tag: _tag,
      );
      return false;
    }
    await _ensureInitialized();

    if (_isDownloading) {
      AppLogger.w(
        'Download already in progress — ignoring new request '
        'for route $routeId',
        tag: _tag,
      );
      return false;
    }

    if (points.isEmpty) {
      AppLogger.w(
        'No route points provided for route $routeId',
        tag: _tag,
      );
      return false;
    }

    _isDownloading = true;
    _activeRouteId = routeId;

    try {
      return await _loadTileRegion(
        routeId: routeId,
        routeName: routeName,
        points: points,
        onProgress: onProgress,
      );
    } finally {
      _isDownloading = false;
    }
  }

  /// Core tile region download logic — shared by
  /// [downloadRouteRegion] and [downloadIfNeeded].
  ///
  /// Does NOT check or set the [_isDownloading] flag — callers
  /// are responsible for owning the lock before invoking this.
  Future<bool> _loadTileRegion({
    required int routeId,
    required String routeName,
    required List<RoutePointEntity> points,
    required void Function(double progress, int completed, int total)
        onProgress,
  }) async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — skipping _loadTileRegion',
        tag: _tag,
      );
      return false;
    }
    AppLogger.d(
      '[OFFLINE] Starting tile region download — '
      'routeId=$routeId points=${points.length} zoom=$_minZoom-$_maxZoom',
      tag: _tag,
    );

    final geometry = _buildRouteGeometry(points);

    final descriptors = [
      TilesetDescriptorOptions(
        styleURI: MapboxMapStyle.light,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
      ),
      TilesetDescriptorOptions(
        styleURI: MapboxMapStyle.dark,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
      ),
    ];

    final loadOptions = TileRegionLoadOptions(
      geometry: geometry.cast<String?, Object?>(),
      descriptorsOptions: descriptors,
      metadata: <String?, Object?>{
        'routeName': routeName,
      },
      acceptExpired: true,
      networkRestriction: NetworkRestriction.NONE,
    );

    final regionId = _regionId(routeId);

    AppLogger.d(
      '[OFFLINE] Calling TileStore.loadTileRegion — '
      'regionId=$regionId',
      tag: _tag,
    );

    try {
      await _tileStore!.loadTileRegion(
        regionId,
        loadOptions,
        (progress) {
          if (!_isDownloading) return;
          final total = progress.requiredResourceCount;
          final done = progress.completedResourceCount;
          final errored = progress.erroredResourceCount;
          final fraction =
              total > 0 ? done.toDouble() / total : 0.0;
          final pct = (fraction * 100).round();
          if (pct % 10 == 0) {
            AppLogger.d(
              '[OFFLINE] Tile region progress: $done/$total '
              '($pct%) errored=$errored',
              tag: _tag,
            );
          }
          onProgress(fraction, done, total);
        },
      ).timeout(
        const Duration(minutes: 30),
        onTimeout: () => throw TimeoutException(
          'Tile region download timed out after 30 minutes',
        ),
      );

      AppLogger.d(
        '[OFFLINE] loadTileRegion future resolved for $regionId',
        tag: _tag,
      );

      // Download completed — but check if it was cancelled
      // while the native future was in flight.
      if (!_isDownloading) {
        AppLogger.d(
          'Tile region download completed after cancel for '
          'route $routeId — treating as cancelled',
          tag: _tag,
        );
        _activeRouteId = null;
        return false;
      }

      AppLogger.d(
        'Tile region download complete for route $routeId',
        tag: _tag,
      );
      _activeRouteId = null;
      return true;
    } catch (e, stackTrace) {
      _activeRouteId = null;
      AppLogger.e(
        'Failed to download tile region for route $routeId',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Cancels the active download.
  ///
  /// Sets the download flag to false and removes any partial
  /// tile region for the active route so storage is not
  /// wasted. The SDK does not expose a [Cancelable] from
  /// [TileStore.loadTileRegion], so the native download
  /// continues briefly but the result is discarded.
  Future<void> cancelDownload() async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — skipping cancelDownload',
        tag: _tag,
      );
      return;
    }
    if (!_isDownloading) return;
    _isDownloading = false;
    AppLogger.d('Download cancelled', tag: _tag);

    final routeId = _activeRouteId;
    _activeRouteId = null;
    if (routeId != null) {
      try {
        await _tileStore?.removeRegion(_regionId(routeId));
      } catch (e) {
        AppLogger.w(
          'Could not clean up partial region for route $routeId '
          'after cancel: $e',
          tag: _tag,
        );
      }
    }
  }

  /// Returns `true` if the tile region for [routeId] is
  /// fully downloaded (completed >= required and required > 0).
  Future<bool> isRouteDownloaded(int routeId) async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — isRouteDownloaded -> false',
        tag: _tag,
      );
      return false;
    }
    await _ensureInitialized();
    try {
      final region = await _tileStore!.tileRegion(
        _regionId(routeId),
      );
      return region.requiredResourceCount > 0 &&
          region.completedResourceCount >=
              region.requiredResourceCount;
    } catch (_) {
      return false;
    }
  }

  /// Returns `true` if both light and dark style packs are
  /// fully downloaded.
  Future<bool> areStylePacksDownloaded() async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — areStylePacksDownloaded -> false',
        tag: _tag,
      );
      return false;
    }
    await _ensureInitialized();
    final lightDownloaded = await _isStylePackDownloaded(
      MapboxMapStyle.light,
    );
    final darkDownloaded = await _isStylePackDownloaded(
      MapboxMapStyle.dark,
    );
    return lightDownloaded && darkDownloaded;
  }

  /// Silently downloads style packs and the tile region for
  /// [routeId] if they are not already cached.
  ///
  /// Safe to call fire-and-forget — never throws; skips if a
  /// download is already in progress; logs failures internally.
  Future<void> downloadIfNeeded({
    required int routeId,
    required String routeName,
    required List<RoutePointEntity> points,
  }) async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — skipping downloadIfNeeded',
        tag: _tag,
      );
      return;
    }
    AppLogger.d(
      '[OFFLINE] downloadIfNeeded called — '
      'routeId=$routeId routeName="$routeName" points=${points.length}',
      tag: _tag,
    );
    try {
      if (_isDownloading) {
        AppLogger.d(
          '[OFFLINE] Skipped — another download is already in progress',
          tag: _tag,
        );
        return;
      }
      if (points.isEmpty) {
        AppLogger.d(
          '[OFFLINE] Skipped — route $routeId has no points',
          tag: _tag,
        );
        return;
      }
      final alreadyDownloaded = await isRouteDownloaded(routeId);
      if (alreadyDownloaded) {
        final bytes = await getTotalStorageBytes();
        AppLogger.d(
          '[OFFLINE] Skipped — route $routeId already cached '
          '(totalStorageBytes=$bytes)',
          tag: _tag,
        );
        return;
      }
      AppLogger.d(
        '[OFFLINE] Starting auto-download for route $routeId "$routeName"',
        tag: _tag,
      );
      _isDownloading = true;
      _activeRouteId = routeId;
      await downloadStylePacks(onProgress: (_, __) {});
      await _loadTileRegion(
        routeId: routeId,
        routeName: routeName,
        points: points,
        onProgress: (_, __, ___) {},
      );
      AppLogger.d(
        '[OFFLINE] Auto-download complete for route $routeId',
        tag: _tag,
      );
    } catch (e) {
      AppLogger.w(
        '[OFFLINE] Auto-download FAILED for route $routeId: $e',
        tag: _tag,
      );
      // Intentionally not rethrowing — background operation.
    } finally {
      _isDownloading = false;
      _activeRouteId = null;
    }
  }

  /// Deletes the tile region for the given [routeId].
  Future<void> deleteRouteRegion(int routeId) async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — skipping deleteRouteRegion',
        tag: _tag,
      );
      return;
    }
    await _ensureInitialized();
    try {
      await _tileStore!.removeRegion(_regionId(routeId));
      AppLogger.d(
        'Deleted tile region for route $routeId',
        tag: _tag,
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to delete tile region for route $routeId',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Returns all downloaded [TileRegion] objects from the
  /// tile store.
  Future<List<TileRegion>> listDownloadedRegions() async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — listDownloadedRegions -> []',
        tag: _tag,
      );
      return const [];
    }
    await _ensureInitialized();
    try {
      return await _tileStore!.allTileRegions();
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to list downloaded regions',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Returns the total downloaded storage in bytes across
  /// all tile regions and style packs.
  Future<int> getTotalStorageBytes() async {
    if (!_isEnabled) {
      AppLogger.d(
        '[OFFLINE] Service disabled — getTotalStorageBytes -> 0',
        tag: _tag,
      );
      return 0;
    }
    await _ensureInitialized();
    var totalBytes = 0;

    try {
      final regions = await _tileStore!.allTileRegions();
      for (final region in regions) {
        totalBytes += region.completedResourceSize;
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to get tile regions size',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }

    try {
      final stylePacks = await _offlineManager!.allStylePacks();
      for (final pack in stylePacks) {
        totalBytes += pack.completedResourceSize;
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to get style packs size',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }

    return totalBytes;
  }

  // -- Private helpers --

  String _regionId(int routeId) => 'route-$routeId';

  Future<bool> _isStylePackDownloaded(String styleUri) async {
    try {
      final packs = await _offlineManager!.allStylePacks();
      final match = packs.where((p) => p.styleURI == styleUri);
      if (match.isEmpty) return false;
      final pack = match.first;
      return pack.requiredResourceCount > 0 &&
          pack.completedResourceCount >= pack.requiredResourceCount;
    } catch (_) {
      return false;
    }
  }

  /// Builds a simplified LineString GeoJSON geometry from
  /// route points by striding to ~200 points max.
  Map<String, dynamic> _buildRouteGeometry(
    List<RoutePointEntity> points,
  ) {
    final stride =
        (points.length / _targetPointCount).ceil().clamp(
              1,
              points.length,
            );
    final simplified = [
      for (int i = 0; i < points.length; i += stride) points[i],
      // Include the last point only if the stride did not
      // already land on it, to avoid a duplicate coordinate.
      if ((points.length - 1) % stride != 0) points.last,
    ];
    return {
      'type': 'LineString',
      'coordinates': [
        for (final p in simplified) [p.longitude, p.latitude],
      ],
    };
  }
}
