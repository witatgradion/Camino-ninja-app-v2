import 'package:camino_ninja_flutter/utils/marker_helpers/city_marker_helper.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/city_marker_style.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

class CityMarkerDelegate {
  CityMarkerDelegate({required this.city, required this.markerStyle});

  final CityEntity city;
  CityMarkerStyle markerStyle;

  PointAnnotationManager? _manager;

  /// Whether the annotation manager has been created for the current style.
  bool get isInitialized => _manager != null;

  /// Creates the underlying [PointAnnotationManager]. Idempotent: safe to
  /// call multiple times — subsequent calls are no-ops while a manager
  /// already exists for the current style.
  ///
  /// IMPORTANT: call this AFTER all other style layers (e.g. the albergue
  /// cluster layers) have been added. Mapbox places the annotation
  /// manager's internal layer on top of whatever style layers exist at
  /// creation time, so later initialization = city marker drawn on top.
  Future<void> initialize(AnnotationManager annotations) async {
    if (_manager != null) return;
    _manager = await annotations.createPointAnnotationManager();
  }

  /// Drops the current manager reference so [initialize] will recreate it
  /// on the next call. Used when the map style is swapped (dark/light) —
  /// the underlying annotation layer does not survive a style reload and
  /// must be recreated after the new cluster layers are added.
  void resetForStyleReload() {
    _manager = null;
  }

  Future<void> sync() async {
    await _manager?.deleteAll();
    final image = await CityMarkerHelper.createCityImage(
      city,
      style: markerStyle,
    );
    await _manager?.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(city.longitude, city.latitude),
        ),
        image: image,
        iconAnchor: IconAnchor.BOTTOM,
        symbolSortKey: 3,
      ),
    );
  }
}
