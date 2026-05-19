import 'package:camino_ninja_flutter/tabs/map/map_marker_handler.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Handler for chart interactions
class MapChartHandler {
  MapChartHandler({
    required this.getMapController,
    required this.getChartRoutePoints,
    required this.markerHandler,
  });

  final MapboxMap? Function() getMapController;
  final List<ChartRoutePoint> Function() getChartRoutePoints;
  final MapMarkerHandler markerHandler;

  Future<void> _easeMapToPosition(LatLng position) async {
    final mapController = getMapController();
    if (mapController == null) return;

    await mapController.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
      ),
      MapAnimationOptions(duration: 150),
    );
  }

  Future<void> _snapMapToPosition(LatLng position) async {
    final mapController = getMapController();
    if (mapController == null) return;

    await mapController.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
      ),
    );
  }

  Future<void> handleChartTouchDown(
    ChartRoutePoint delta,
  ) async {
    await markerHandler.handleChartTouchDown(delta);
    await _easeMapToPosition(LatLng(delta.lat, delta.lon));
  }

  Future<void> handleChartTouchUp() async {
    markerHandler.handleChartTouchUp();
  }

  Future<void> handleChartTouchMove(
    ChartRoutePoint delta,
  ) async {
    await markerHandler.handleChartTouchMove(delta);
    await _snapMapToPosition(LatLng(delta.lat, delta.lon));
  }

  void dispose() {}
}
