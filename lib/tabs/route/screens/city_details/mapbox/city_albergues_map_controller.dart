import 'dart:async';

import 'package:camino_ninja_flutter/mapbox/controllers/mapbox_host_mixin.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/albergue_cluster_delegate.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/city_marker_delegate.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/gesture_delegate.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/polyline_delegate.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_albergues_map.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/city_marker_style.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

class CityAlberguesMapController with MapboxHostMixin {
  CityAlberguesMapController({
    required this.isFullScreen,
    required GestureDelegate gestureConfig,
    required CityMarkerStyle cityMarkerStyle,
    required List<AlbergueLocation> locations,
    List<LatLng>? routePoints,
    List<AltRoutePointEntity>? altRoutePoints,
    this.city,
    this.onMarkerTap,
  })  : _locations = locations,
        _routePoints = routePoints,
        _altRoutePoints = altRoutePoints,
        _gestureConfig = gestureConfig,
        _polylineDelegate = PolylineDelegate(),
        _cityMarkerDelegate = city != null
            ? CityMarkerDelegate(city: city, markerStyle: cityMarkerStyle)
            : null {
    _clusterDelegate = AlbergueClusterDelegate(
      locations: locations,
      onMarkerTap: onMarkerTap == null ? null : _handleMarkerTap,
    );
    _currentMarkerStyle = cityMarkerStyle;
  }

  List<AlbergueLocation> _locations;
  List<LatLng>? _routePoints;
  List<AltRoutePointEntity>? _altRoutePoints;
  final CityEntity? city;
  final ValueChanged<AlbergueLocation>? onMarkerTap;
  final bool isFullScreen;

  List<AlbergueLocation> get locations => _locations;
  List<LatLng>? get routePoints => _routePoints;
  List<AltRoutePointEntity>? get altRoutePoints => _altRoutePoints;

  final GestureDelegate _gestureConfig;
  late AlbergueClusterDelegate _clusterDelegate;
  final PolylineDelegate _polylineDelegate;
  final CityMarkerDelegate? _cityMarkerDelegate;

  MapboxMap? _map;
  bool _initialBoundsDone = false;
  late CityMarkerStyle _currentMarkerStyle;

  MapboxMap? get mapboxMap => _map;
  @override
  MapboxMap? get hostMap => _map;

  Future<void> onMapCreated(MapboxMap map, {required bool isDark}) async {
    if (disposed) return;
    _map = map;
    setInitialStyleUri(
      isDark ? MapboxMapStyle.dark : MapboxMapStyle.light,
    );
    await _gestureConfig.apply(map);
    map.setOnMapTapListener(_onTap);
    // Polyline annotation manager is created early — polylines sit
    // visually at ground level and render fine beneath every marker.
    await _polylineDelegate.initialize(map.annotations);
    // NOTE: the city marker annotation manager is intentionally NOT
    // initialized here. It must be created AFTER the cluster delegate
    // adds its style layers (see `_syncAll`) so that the annotation
    // layer sits on top of the albergue cluster/individual layers.

    // The initial CameraOptions is pre-fitted to the locations bounds at
    // widget-build time (see `_CityAlberguesMapState._initialCameraOptions`),
    // so the first frame is already correct. For the full-screen variant
    // we still schedule a defensive re-fit AFTER the first frame — Mapbox
    // `flyTo` calls inside `onMapCreated` happen pre-layout and can be
    // silently dropped. `addPostFrameCallback` defers it until layout has
    // settled. The preview-card variant doesn't need the re-fit.
    if (!_initialBoundsDone && _locations.isNotEmpty && isFullScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (disposed) return;
        _fitBounds();
      });
      _initialBoundsDone = true;
    }

    await _syncAll();
  }

  Future<void> onStyleLoaded() async {
    if (disposed) return;
    if (_cityMarkerDelegate != null) {
      _cityMarkerDelegate.markerStyle = _currentMarkerStyle;
      // A style swap (dark/light) wipes the previous annotation layer.
      // Drop the cached manager so `_syncAll` recreates it AFTER the
      // cluster layers are re-added on the fresh style.
      _cityMarkerDelegate.resetForStyleReload();
    }
    await _syncAll();
  }

  /// Called from the widget when the app theme changes. Reloads the
  /// Mapbox style — `loadStyleURI` auto-refires `onStyleLoaded` which
  /// recreates the city marker layer on top of the freshly-loaded
  /// cluster layers.
  Future<void> onThemeChanged({
    required bool isDark,
    required CityMarkerStyle markerStyle,
  }) async {
    if (disposed) return;
    _currentMarkerStyle = markerStyle;
    if (_map == null) return;
    final themeUri = isDark ? MapboxMapStyle.dark : MapboxMapStyle.light;
    // Theme changed while satellite is on — keep the satellite overlay
    // visible but update the URI we'll restore to.
    if (isSatelliteView) {
      updatePreSatelliteThemeUri(themeUri);
      return;
    }
    await swapStyle(themeUri);
  }

  /// Routes a satellite toggle through the mixin's serialised
  /// [MapboxHostMixin.toggleSatellite].
  Future<void> toggleSatelliteView({required bool isDark}) async {
    if (disposed) return;
    final themeUri = isDark ? MapboxMapStyle.dark : MapboxMapStyle.light;
    await toggleSatellite(themeUri: themeUri);
  }

  /// Updates the locations / route points the map shows. Lets the
  /// widget react to its embedding cubit's rebuilds without recreating
  /// the controller and leaking the in-flight map handle.
  Future<void> updateData({
    required List<AlbergueLocation> locations,
    List<LatLng>? routePoints,
    List<AltRoutePointEntity>? altRoutePoints,
  }) async {
    if (disposed) return;
    final didLocationsChange = !identical(_locations, locations);
    _locations = locations;
    _routePoints = routePoints;
    _altRoutePoints = altRoutePoints;
    if (didLocationsChange) {
      // The cluster delegate holds locations on construction — rebuild
      // so the next `setup()` writes the new GeoJSON feature set.
      _clusterDelegate = AlbergueClusterDelegate(
        locations: locations,
        onMarkerTap: onMarkerTap == null ? null : _handleMarkerTap,
      );
    }
    await _syncAll();
  }

  Future<void> _syncAll() async {
    if (disposed) return;
    final map = _map;
    if (map == null) return;
    // Run cluster setup and polyline sync in parallel — they use
    // independent resources (style layers vs. polyline annotation
    // manager). The city marker must wait for cluster setup so its
    // annotation manager is created on top of the cluster layers.
    await Future.wait([
      _clusterDelegate.setup(map.style),
      _polylineDelegate.syncRoutePolylines(
        routePoints: _routePoints,
        altRoutePoints: _altRoutePoints,
      ),
    ]);
    if (disposed) return;
    final cityMarker = _cityMarkerDelegate;
    if (cityMarker != null) {
      await cityMarker.initialize(map.annotations);
      if (disposed) return;
      await cityMarker.sync();
    }
  }

  Future<void> _fitBounds() async {
    if (disposed) return;
    await MapUtil.fitBounds(
      mapController: _map,
      points: _locations.map((e) => e.latLng).toList(),
      zoomConstant: 1.1,
    );
  }

  Future<void> _onTap(MapContentGestureContext ctx) async {
    if (disposed) return;
    final map = _map;
    if (map == null) return;
    await _clusterDelegate.handleTap(map, ctx.touchPosition);
  }

  void _handleMarkerTap(AlbergueLocation location) {
    if (disposed) return;
    unawaited(_flyToLocation(location.latLng));
    onMarkerTap?.call(location);
  }

  Future<void> _flyToLocation(LatLng target) async {
    if (disposed) return;
    final map = _map;
    if (map == null) return;
    final currentZoom = (await map.getCameraState()).zoom;
    if (disposed) return;
    await map.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(target.longitude, target.latitude),
        ),
        zoom: currentZoom,
      ),
      MapAnimationOptions(duration: 400),
    );
  }

  void dispose() {
    if (disposed) return;
    disposeHost();
    // Drop the native tap listener edge so the closure (which captures
    // `this`) does not pin the controller and its delegates after the
    // hosting widget unmounts.
    _map?.setOnMapTapListener(null);
    // Drop cached annotation manager references so future GC of the
    // map handle isn't pinned by them.
    _polylineDelegate.resetForStyleReload();
    _cityMarkerDelegate?.resetForStyleReload();
    _map = null;
  }
}
