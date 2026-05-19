import 'dart:async';

import 'package:camino_ninja_flutter/mapbox/controllers/mapbox_host_mixin.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/gesture_delegate.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/polyline_delegate.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Controller for the small stage map shown inside the add/edit stage flow.
///
/// Uses the shared [GestureDelegate] for non-interactive configuration and a
/// [PolylineDelegate] for annotation lifecycle, while keeping the original
/// stage-specific colour logic (which differs from the shared
/// `PolylineStyleDefs`).
class StageSmallMapController with MapboxHostMixin {
  StageSmallMapController({
    required List<LatLng> routePoints,
    required List<LatLng> selectedRoutePoints,
    required bool isDarkMode,
    Color? routeColor,
  })  : _routePoints = routePoints,
        _selectedRoutePoints = selectedRoutePoints,
        _isDarkMode = isDarkMode,
        _routeColor = routeColor,
        _gestureDelegate = const GestureDelegate(
          scrollEnabled: false,
          pinchToZoomEnabled: false,
          doubleTapToZoomInEnabled: false,
          locationEnabled: false,
        ),
        _polylineDelegate = PolylineDelegate();

  final GestureDelegate _gestureDelegate;
  final PolylineDelegate _polylineDelegate;

  List<LatLng> _routePoints;
  List<LatLng> _selectedRoutePoints;
  bool _isDarkMode;
  Color? _routeColor;

  MapboxMap? _map;
  bool _mapReady = false;

  MapboxMap? get mapboxMap => _map;
  @override
  MapboxMap? get hostMap => _map;
  bool get mapReady => _mapReady;

  Future<void> onMapCreated(MapboxMap map) async {
    if (disposed) return;
    _map = map;
    setInitialStyleUri(
      _isDarkMode ? MapboxMapStyle.dark : MapboxMapStyle.light,
    );
    await _gestureDelegate.apply(map);
    // `GestureDelegate` does not expose `quickZoomEnabled`; disable it here
    // to match the original stage-map configuration exactly.
    await map.gestures.updateSettings(
      GesturesSettings(quickZoomEnabled: false),
    );
    await _polylineDelegate.initialize(map.annotations);
    _mapReady = true;
    await syncPolylines();
    await _fitBounds();
  }

  Future<void> onStyleLoaded() async {
    if (disposed || !_mapReady) return;
    final map = _map;
    if (map != null) {
      // The polyline annotation manager does not survive a style swap.
      // Drop the cached reference so `initialize` recreates one against
      // the freshly-loaded style before `syncPolylines` writes into it.
      _polylineDelegate.resetForStyleReload();
      await _polylineDelegate.initialize(map.annotations);
    }
    await syncPolylines();
    await _fitBounds();
  }

  Future<void> update({
    required List<LatLng> routePoints,
    required List<LatLng> selectedRoutePoints,
    required bool isDarkMode,
    Color? routeColor,
  }) async {
    if (disposed) return;
    final didDarkModeChange = _isDarkMode != isDarkMode;
    _routePoints = routePoints;
    _selectedRoutePoints = selectedRoutePoints;
    _isDarkMode = isDarkMode;
    _routeColor = routeColor;
    if (!_mapReady) return;
    if (didDarkModeChange) {
      final newUri = isDarkMode ? MapboxMapStyle.dark : MapboxMapStyle.light;
      if (currentStyleUri != newUri) {
        // `loadStyleURI` auto-refires `onStyleLoaded`, which recreates
        // the polyline manager and calls `syncPolylines` / `_fitBounds`.
        // Skip the manual calls below to avoid a redundant redraw.
        await swapStyle(newUri);
        return;
      }
    }
    await syncPolylines();
    await _fitBounds();
  }

  /// Draws the stage polylines using the original colour/width logic.
  Future<void> syncPolylines() async {
    final manager = _polylineDelegate.manager;
    if (manager == null) return;
    await _polylineDelegate.clear();

    var mainRouteColor = _routeColor ??
        (_isDarkMode ? AppColors.primary80 : AppColors.primary40);
    if (_selectedRoutePoints.isNotEmpty) {
      mainRouteColor = Colors.red;
    }

    if (_routePoints.isNotEmpty) {
      await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: _routePoints
                .map((p) => Position(p.longitude, p.latitude))
                .toList(),
          ),
          lineColor: mainRouteColor.toARGB32(),
          lineWidth: _selectedRoutePoints.isNotEmpty ? 3.0 : 4.0,
        ),
      );
    }

    if (_selectedRoutePoints.isNotEmpty) {
      final selectedColor =
          _isDarkMode ? AppColors.primary80 : AppColors.primary40;
      await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: _selectedRoutePoints
                .map((p) => Position(p.longitude, p.latitude))
                .toList(),
          ),
          lineColor: selectedColor.toARGB32(),
          lineWidth: 4,
        ),
      );
    }
  }

  Future<void> _fitBounds() async {
    if (disposed) return;
    if (_selectedRoutePoints.isNotEmpty) {
      await MapUtil.fitBounds(
        mapController: _map,
        points: _selectedRoutePoints,
        zoomConstant: 5,
      );
    } else {
      await MapUtil.fitBounds(
        mapController: _map,
        points: _routePoints,
        zoomConstant: 2,
      );
    }
  }

  void dispose() {
    if (disposed) return;
    disposeHost();
    _mapReady = false;
    // Drop the polyline annotation manager reference so the native
    // manager isn't pinned by the delegate across stage-row rebuilds.
    unawaited(_polylineDelegate.clear().catchError((_) {}));
    _polylineDelegate.resetForStyleReload();
    _map = null;
  }
}
