import 'package:camino_ninja_flutter/mapbox/mapbox.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class StageSmallMap extends StatefulWidget {
  const StageSmallMap({
    required this.routePoints,
    this.selectedRoutePoints = const [],
    this.isDarkMode = false,
    this.routeColor,
    super.key,
  });

  final List<LatLng> routePoints;
  final List<LatLng> selectedRoutePoints;
  final Color? routeColor;
  final bool isDarkMode;

  @override
  State<StageSmallMap> createState() => _StageSmallMapState();
}

class _StageSmallMapState extends State<StageSmallMap> {
  late final StageSmallMapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StageSmallMapController(
      routePoints: widget.routePoints,
      selectedRoutePoints: widget.selectedRoutePoints,
      isDarkMode: widget.isDarkMode,
      routeColor: widget.routeColor,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StageSmallMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routePoints.length != widget.routePoints.length ||
        oldWidget.selectedRoutePoints.length !=
            widget.selectedRoutePoints.length ||
        oldWidget.isDarkMode != widget.isDarkMode) {
      if (_controller.mapReady) {
        _controller.update(
          routePoints: widget.routePoints,
          selectedRoutePoints: widget.selectedRoutePoints,
          isDarkMode: widget.isDarkMode,
          routeColor: widget.routeColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routePoints.isEmpty) {
      return const SizedBox.shrink();
    }
    return MapWidget(
      styleUri: widget.isDarkMode
          ? MapboxMapStyle.dark
          : MapboxMapStyle.light,
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            widget.routePoints.first.longitude,
            widget.routePoints.first.latitude,
          ),
        ),
        zoom: 14,
      ),
      onMapCreated: _controller.onMapCreated,
      onStyleLoadedListener: (_) => _controller.onStyleLoaded(),
    );
  }
}
