import 'package:camino_ninja_flutter/utils/offline_map_service.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

/// Thin wrapper around [OfflineMapService] that gates every
/// operation behind a local compile-time flag.
///
/// When the flag is disabled, most operations return safe no-op
/// values without invoking the underlying service. This keeps
/// the offline-map feature dormant in production until the
/// paid-feature rollout is ready.
///
/// Cleanup methods ([cancelDownload] and [deleteRouteRegion])
/// are always forwarded to the service regardless of the flag —
/// teardown must work even if the feature is disabled mid-flight
/// or after the user previously paid and downloaded data.
class OfflineMapRepository {
  OfflineMapRepository(this._service);

  static const bool _isEnabled = false;

  final OfflineMapService _service;

  /// Synchronous read of the local feature flag for UI gating
  /// (e.g. show/hide a "Download offline map" button).
  bool get isEnabled => _isEnabled;

  Future<void> downloadIfNeeded({
    required int routeId,
    required String routeName,
    required List<RoutePointEntity> points,
  }) async {
    if (!_isEnabled) return;
    return _service.downloadIfNeeded(
      routeId: routeId,
      routeName: routeName,
      points: points,
    );
  }

  Future<bool> downloadRouteRegion({
    required int routeId,
    required String routeName,
    required List<RoutePointEntity> points,
    required void Function(double progress, int completed, int total)
        onProgress,
  }) async {
    if (!_isEnabled) return false;
    return _service.downloadRouteRegion(
      routeId: routeId,
      routeName: routeName,
      points: points,
      onProgress: onProgress,
    );
  }

  Future<void> downloadStylePacks({
    required void Function(String styleUri, double progress) onProgress,
  }) async {
    if (!_isEnabled) return;
    return _service.downloadStylePacks(onProgress: onProgress);
  }

  Future<void> cancelDownload() async {
    return _service.cancelDownload();
  }

  Future<bool> isRouteDownloaded(int routeId) async {
    if (!_isEnabled) return false;
    return _service.isRouteDownloaded(routeId);
  }

  Future<bool> areStylePacksDownloaded() async {
    if (!_isEnabled) return false;
    return _service.areStylePacksDownloaded();
  }

  Future<void> deleteRouteRegion(int routeId) async {
    return _service.deleteRouteRegion(routeId);
  }

  Future<List<TileRegion>> listDownloadedRegions() async {
    if (!_isEnabled) return const [];
    return _service.listDownloadedRegions();
  }

  Future<int> getTotalStorageBytes() async {
    if (!_isEnabled) return 0;
    return _service.getTotalStorageBytes();
  }
}
