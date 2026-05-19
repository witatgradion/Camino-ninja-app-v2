import 'package:camino_ninja_flutter/mapbox/mapbox.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_route/widgets/route_preview_panel.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

const _defaultCamera = LatLng(42.8760274, -8.5396835);
const _defaultZoom = 5.0;

class SelectRouteMapWidget extends StatefulWidget {
  const SelectRouteMapWidget({
    required this.filteredRoutes,
    required this.routePointsByRouteId,
    required this.selectedRouteId,
    required this.onRouteSelected,
    required this.isDarkMode,
    required this.unit,
    this.isSearchActive = false,
    super.key,
  });

  final List<RouteDistanceElevation> filteredRoutes;
  final Map<int, List<RoutePointEntity>> routePointsByRouteId;
  final int? selectedRouteId;
  final void Function(int routeId) onRouteSelected;
  final bool isDarkMode;
  final bool isSearchActive;
  final UnitEnum unit;

  @override
  State<SelectRouteMapWidget> createState() => _SelectRouteMapWidgetState();
}

class _SelectRouteMapWidgetState extends State<SelectRouteMapWidget> {
  late final SelectRouteMapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SelectRouteMapController(
      filteredRoutes: widget.filteredRoutes,
      routePointsByRouteId: widget.routePointsByRouteId,
      selectedRouteId: widget.selectedRouteId,
      onRouteSelected: widget.onRouteSelected,
      isDarkMode: widget.isDarkMode,
      unit: widget.unit,
      isSearchActive: widget.isSearchActive,
    );
  }

  @override
  void didUpdateWidget(SelectRouteMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final routesChanged = oldWidget.filteredRoutes != widget.filteredRoutes ||
        oldWidget.routePointsByRouteId != widget.routePointsByRouteId;
    final darkModeChanged = oldWidget.isDarkMode != widget.isDarkMode;
    final selectionChanged =
        oldWidget.selectedRouteId != widget.selectedRouteId;

    if (routesChanged || darkModeChanged) {
      _controller.onRouteDataChanged(
        filteredRoutes: widget.filteredRoutes,
        routePointsByRouteId: widget.routePointsByRouteId,
        isDarkMode: widget.isDarkMode,
        selectedRouteId: widget.selectedRouteId,
        isSearchActive: widget.isSearchActive,
      );
    }
    if (selectionChanged) {
      _controller.onSelectionChanged(widget.selectedRouteId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapWidget(
          styleUri:
              widget.isDarkMode ? MapboxMapStyle.dark : MapboxMapStyle.light,
          cameraOptions: CameraOptions(
            center: Point(
              coordinates: Position(
                _defaultCamera.longitude,
                _defaultCamera.latitude,
              ),
            ),
            zoom: _defaultZoom,
          ),
          onMapCreated: _controller.onMapCreated,
          onStyleLoadedListener: (_) => _controller.onStyleLoaded(),
        ),
        ValueListenableBuilder<RouteDistanceElevation?>(
          valueListenable: _controller.previewRoute,
          builder: (context, route, _) {
            if (route == null) return const SizedBox.shrink();
            return Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: RoutePreviewPanel(
                route: route,
                unit: widget.unit,
                isSelected: route.routeId == widget.selectedRouteId,
                onCancel: _controller.cancelPreview,
                onContinue: () => widget.onRouteSelected(route.routeId),
              ),
            );
          },
        ),
      ],
    );
  }
}
