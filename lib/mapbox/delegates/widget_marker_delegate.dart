import 'package:camino_ninja_flutter/utils/marker_helpers/marker_helper.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Delegate that owns a [PointAnnotationManager] for Flutter-widget-based
/// markers. Each marker is produced by rendering a widget to a bitmap via
/// `MarkerHelper.widgetToBitmapDescriptor` and cached by cache key.
///
/// Unlike `CityMarkerDelegate` (which targets a single entity) and
/// `AlbergueClusterDelegate` (which uses style-layer clustering), this
/// delegate is a generic bucket for point annotations whose visual
/// representation is a Flutter widget.
///
/// Typical usage is to instantiate TWO separate delegates when two
/// unrelated marker families need independent lifecycles — e.g. city
/// markers and a directional arrow. Each delegate manages its own
/// [PointAnnotationManager] so calling [clear] on one does not touch the
/// other, and draw order does not have to be coupled.
class WidgetMarkerDelegate {
  PointAnnotationManager? _manager;

  PointAnnotationManager? get manager => _manager;

  /// Creates the underlying [PointAnnotationManager]. Idempotent: safe to
  /// call multiple times — subsequent calls are no-ops while a manager
  /// already exists.
  Future<void> initialize(AnnotationManager annotations) async {
    if (_manager != null) return;
    _manager = await annotations.createPointAnnotationManager();
  }

  /// Drops the current manager reference so [initialize] will recreate it
  /// on the next call. Used when the map style is swapped (dark/light) —
  /// the underlying annotation layer does not survive a style reload.
  void resetForStyleReload() {
    _manager = null;
  }

  /// Removes every annotation owned by this delegate. Does not affect the
  /// underlying manager — new markers can be added afterwards.
  Future<void> clear() async => _manager?.deleteAll();

  /// Renders [widget] to a bitmap (via
  /// [MarkerHelper.widgetToBitmapDescriptor], cached by [cacheKey]) and
  /// creates a [PointAnnotation] at [position].
  ///
  /// Returns `null` if [initialize] hasn't been called yet.
  Future<PointAnnotation?> addWidgetMarker({
    required BuildContext context,
    required Widget widget,
    required String cacheKey,
    required LatLng position,
    double iconSize = 1.0,
    IconAnchor iconAnchor = IconAnchor.BOTTOM,
    double? iconRotate,
    double symbolSortKey = 0.0,
  }) async {
    final manager = _manager;
    if (manager == null) return null;
    final icon = await MarkerHelper.widgetToBitmapDescriptor(
      context: context,
      widget: widget,
      cacheKey: cacheKey,
    );
    return manager.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        image: icon,
        iconSize: iconSize,
        iconAnchor: iconAnchor,
        iconRotate: iconRotate,
        symbolSortKey: symbolSortKey,
      ),
    );
  }
}
