import 'package:camino_ninja_flutter/mapbox/style_definitions/polyline_style_defs.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

class PolylineDelegate {
  PolylineAnnotationManager? _manager;

  PolylineAnnotationManager? get manager => _manager;

  /// Creates the underlying [PolylineAnnotationManager]. Idempotent: safe
  /// to call multiple times — subsequent calls are no-ops while a manager
  /// already exists.
  Future<void> initialize(AnnotationManager annotations) async {
    if (_manager != null) return;
    _manager = await annotations.createPolylineAnnotationManager();
  }

  /// Drops the current manager reference so [initialize] will recreate it
  /// on the next call. Used when the map style is swapped (dark/light) —
  /// the underlying annotation layer does not survive a style reload.
  void resetForStyleReload() {
    _manager = null;
  }

  Future<void> clear() async => _manager?.deleteAll();

  Future<void> syncRoutePolylines({
    List<LatLng>? routePoints,
    List<AltRoutePointEntity>? altRoutePoints,
  }) async {
    await clear();
    if (routePoints != null && routePoints.isNotEmpty) {
      await _manager?.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: routePoints
                .map((p) => Position(p.longitude, p.latitude))
                .toList(),
          ),
          lineColor: PolylineStyleDefs.routeColor,
          lineWidth: PolylineStyleDefs.routeWidth,
        ),
      );
    }
    if (altRoutePoints != null) {
      for (final ap in altRoutePoints) {
        if (ap.values.isEmpty) continue;
        await _manager?.create(
          PolylineAnnotationOptions(
            geometry: LineString(
              coordinates: ap.values
                  .map((e) => Position(e.longitude, e.latitude))
                  .toList(),
            ),
            lineColor: PolylineStyleDefs.altRouteColor(ap.color),
            lineWidth: PolylineStyleDefs.altRouteWidth,
          ),
        );
      }
    }
  }
}
