import 'dart:math';

import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

class MapUtil {
  /// Fits the camera to [points].
  ///
  /// When [padding] is supplied, Mapbox's native `cameraForCoordinates` is
  /// used so on-screen UI (e.g. bottom panels, marker heights) can be
  /// accounted for without clipping geometry. When [padding] is null, the
  /// existing manual zoom calculation is used so all existing callers
  /// relying on [zoomConstant] keep their behaviour.
  static Future<void> fitBounds({
    MapboxMap? mapController,
    List<LatLng> points = const [],
    double zoomConstant = 0.7,
    MbxEdgeInsets? padding,
  }) async {
    if (mapController == null) return;

    if (points.isEmpty) {
      AppLogger.w(
        'Cannot fit bounds: no route points available',
        tag: 'MapUtil',
      );
      return;
    }

    if (padding != null) {
      final didApply = await _fitBoundsWithPadding(
        mapController: mapController,
        points: points,
        padding: padding,
      );
      if (didApply) return;
      // Fall through to the manual zoom path below if the padded fit
      // failed (e.g. pigeon threw on degenerate input or pre-layout call).
    }

    await _fitBoundsManual(
      mapController: mapController,
      points: points,
      zoomConstant: zoomConstant,
    );
  }

  /// Computes a [CameraOptions] (center + zoom) that fits [points] in a
  /// square viewport using the same manual log2 calculation as
  /// [_fitBoundsManual]. Sync, no map controller required — use this when
  /// you need the camera at widget-build time (initial [CameraOptions])
  /// rather than animating to it after the map is laid out.
  ///
  /// Returns null when [points] is empty.
  static CameraOptions? cameraForPoints({
    required List<LatLng> points,
    double zoomConstant = 0.7,
  }) {
    if (points.isEmpty) return null;

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    final latDelta = maxLat - minLat;
    final lngDelta = maxLng - minLng;
    // Clamp the span to a tiny floor so a single-point input (or two
    // identical points) does not feed `Infinity` into the log/clamp.
    final maxDelta = max(
      latDelta > lngDelta ? latDelta : lngDelta,
      1e-6,
    );

    final zoom =
        (log(360 / (maxDelta * zoomConstant)) / ln2).clamp(0.0, 22.0);

    return CameraOptions(
      center: Point(
        coordinates: Position(centerLng, centerLat),
      ),
      zoom: zoom,
    );
  }

  /// Manual zoom-level calculation used when no on-screen padding is
  /// required or when the native `cameraForCoordinatesPadding` call is
  /// unavailable. Kept as a separate helper so both the padded and
  /// un-padded paths can share fallback behaviour.
  static Future<void> _fitBoundsManual({
    required MapboxMap mapController,
    required List<LatLng> points,
    required double zoomConstant,
  }) async {
    final camera = cameraForPoints(
      points: points,
      zoomConstant: zoomConstant,
    );
    if (camera == null) return;

    await mapController.flyTo(
      camera,
      MapAnimationOptions(duration: 500),
    );
  }

  /// Uses `cameraForCoordinatesPadding` to compute a camera that fits
  /// [points] while respecting [padding] around the geometry. This is the
  /// recommended Mapbox approach because it accounts for on-screen UI that
  /// would otherwise clip the fitted content.
  ///
  /// Returns `true` when the camera was applied, `false` when the pigeon
  /// call threw (e.g. degenerate coordinates or the map has not laid out
  /// yet). Callers should fall back to the manual zoom-calc path on
  /// `false` rather than let the bounds-fit fail silently.
  static Future<bool> _fitBoundsWithPadding({
    required MapboxMap mapController,
    required List<LatLng> points,
    required MbxEdgeInsets padding,
  }) async {
    final coordinates = points
        .map(
          (p) => Point(coordinates: Position(p.longitude, p.latitude)),
        )
        .toList();

    try {
      final camera = await mapController.cameraForCoordinatesPadding(
        coordinates,
        CameraOptions(),
        padding,
        null,
        null,
      );

      await mapController.flyTo(
        camera,
        MapAnimationOptions(duration: 500),
      );
      return true;
    } catch (e, st) {
      AppLogger.w(
        'cameraForCoordinatesPadding failed; '
        'falling back to manual zoom calc',
        tag: 'MapUtil',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  static List<LatLng> getLatLngsFromRoutePoints(
    List<RoutePointEntity> points,
  ) {
    return points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  /// Finds the index of the point nearest to the given
  /// latitude and longitude using squared Euclidean
  /// distance.
  static int findNearestPointIndex(
    List<LatLng> points,
    double lat,
    double lng,
  ) {
    var bestIdx = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < points.length; i++) {
      final dx = points[i].latitude - lat;
      final dy = points[i].longitude - lng;
      final dist = dx * dx + dy * dy;
      if (dist < bestDist) {
        bestDist = dist;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  static List<LatLng> getLatLngsFromChartRoutePoints(
    List<ChartRoutePoint> points,
  ) {
    return points
        .map((point) => LatLng(point.lat, point.lon))
        .toList();
  }
}
