import 'dart:typed_data';

import 'package:camino_ninja_flutter/tabs/map/map_marker_handler.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/directional_arrows_marker_helper.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

/// Handler for arrow annotations and city marker management.
/// Arrows are dynamically placed based on the current viewport
/// so that only ~5 evenly-spaced arrows are visible at a time.
class MapClusterHandler {
  MapClusterHandler({
    required this.getRoutePoints,
    required this.markerHandler,
  });

  final List<RoutePointEntity> Function() getRoutePoints;
  final MapMarkerHandler markerHandler;

  Uint8List? _cachedArrowImage;

  Future<void> initialize() async {
    _cachedArrowImage ??=
        await DirectionalArrowsHelper.createArrowImage();
  }

  /// Recalculates and redraws arrows visible in the current
  /// viewport, evenly spacing ~[targetCount] arrows along the
  /// visible portion of the route.
  Future<void> updateArrowsForViewport(
    MapboxMap mapController, {
    int targetCount = 4,
  }) async {
    final allPoints = getRoutePoints();
    if (allPoints.length < 2) {
      await markerHandler.setArrowAnnotations([]);
      return;
    }

    _cachedArrowImage ??=
        await DirectionalArrowsHelper.createArrowImage();

    final cameraState = await mapController.getCameraState();
    final bounds =
        await mapController.coordinateBoundsForCamera(
      CameraOptions(
        center: cameraState.center,
        zoom: cameraState.zoom,
        bearing: cameraState.bearing,
        pitch: cameraState.pitch,
        padding: cameraState.padding,
      ),
    );

    final sw = bounds.southwest.coordinates;
    final ne = bounds.northeast.coordinates;

    final arrows =
        DirectionalArrowsHelper.getViewportArrows(
      allPoints,
      minLat: sw.lat.toDouble(),
      maxLat: ne.lat.toDouble(),
      minLng: sw.lng.toDouble(),
      maxLng: ne.lng.toDouble(),
      targetCount: targetCount,
    );

    final image = _cachedArrowImage!;
    final options = arrows
        .map(
          (arrow) => PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                arrow.location.longitude,
                arrow.location.latitude,
              ),
            ),
            image: image,
            iconRotate: arrow.rotation,
            iconSize: 1.0,
            iconAnchor: IconAnchor.CENTER,
            symbolSortKey: 1.0,
          ),
        )
        .toList();
    await markerHandler.setArrowAnnotations(options);
  }

  void handleCities(
    List<CityEntity> cities, {
    int? startingCityId,
    int? destCityId,
  }) {
    if (cities.isEmpty) return;

    final firstCity = cities.first;
    final lastCity =
        cities.length > 1 ? cities.last : cities.first;

    CityEntity? startingCity;
    if (startingCityId != null) {
      try {
        startingCity = cities
            .firstWhere((city) => city.id == startingCityId);
      } catch (_) {
        startingCity = null;
      }
    }

    CityEntity? destinationCity;
    if (destCityId != null) {
      try {
        destinationCity =
            cities.firstWhere((city) => city.id == destCityId);
      } catch (_) {
        destinationCity = null;
      }
    }

    markerHandler
      ..setFirstCity(firstCity)
      ..setLastCity(lastCity)
      ..setStartingCity(startingCity)
      ..setDestinationCity(destinationCity)
      ..createFirstLastCityAnnotations();
  }
}
