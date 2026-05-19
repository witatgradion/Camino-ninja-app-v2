import 'dart:async';

import 'package:camino_ninja_flutter/mapbox/controllers/mapbox_host_mixin.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/gesture_delegate.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/polyline_delegate.dart';
import 'package:camino_ninja_flutter/repositories/offline_map_repository.dart';
import 'package:camino_ninja_flutter/tabs/map/cubit/map_cubit.dart';
import 'package:camino_ninja_flutter/tabs/map/map_chart_handler.dart';
import 'package:camino_ninja_flutter/tabs/map/map_cluster_handler.dart';
import 'package:camino_ninja_flutter/tabs/map/map_location_handler.dart';
import 'package:camino_ninja_flutter/tabs/map/map_marker_handler.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/marker_helper.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

/// Padding applied when fitting the map bounds to a route.
///
/// The first/last city markers are rendered with `iconAnchor: BOTTOM`, so
/// the icon extends UPWARDS from its lat/lng. Without a top inset the
/// marker gets clipped at the screen top. Bottom padding keeps the
/// location-pulse circle visible.
const _mapFitTopPadding = 100.0;
const _mapFitBottomPadding = 56.0;
const _mapFitHorizontalPadding = 48.0;

/// Controller for `MapScreenWidget` — owns all map logic and non-UI state
/// (Mapbox handle, handlers, cubit, subscriptions, debounce timer).
///
/// The widget only retains ephemeral UI state (current distance / altitude
/// strings) and forwards lifecycle events to this controller.
class MapScreenController with MapboxHostMixin {
  MapScreenController({
    required this.context,
    required this.routeId,
    required this.routeName,
    required this.startingCityId,
    required this.destCityId,
    required this.getPoints,
    required this.getAltPoints,
    required this.getChartRoutePoints,
    required this.getUnit,
    required this.onDistanceChanged,
    required this.onAltitudeChanged,
    required this.onLocationStateChanged,
    required this.onMyLocationEnabledChanged,
  });

  final BuildContext context;
  final int? routeId;
  final String routeName;
  final int? startingCityId;
  final int? destCityId;
  final List<RoutePointEntity> Function() getPoints;
  final List<AltRoutePointEntity> Function() getAltPoints;
  final List<ChartRoutePoint> Function() getChartRoutePoints;
  final UnitEnum Function() getUnit;
  final void Function(String) onDistanceChanged;
  final void Function(String) onAltitudeChanged;
  final VoidCallback onLocationStateChanged;
  final void Function(bool) onMyLocationEnabledChanged;

  MapboxMap? _map;
  final PolylineDelegate _polylineDelegate = PolylineDelegate();

  MapCubit? _mapCubit;
  StreamSubscription<List<CityEntity>>? _cityStreamSubscription;

  MapLocationHandler? _locationHandler;
  MapMarkerHandler? _markerHandler;
  MapClusterHandler? _clusterHandler;
  MapChartHandler? _chartHandler;

  Timer? _arrowDebounce;
  bool _initialized = false;
  bool _isActive = true;
  bool _pendingFit = true;

  MapboxMap? get mapboxMap => _map;
  @override
  MapboxMap? get hostMap => _map;
  MapLocationHandler? get locationHandler => _locationHandler;
  MapChartHandler? get chartHandler => _chartHandler;
  ValueNotifier<LoadUserLocationStatus>? get loadLocationNotifier =>
      _locationHandler?.loadLocationNotifier;

  bool get hasSubRouteSelection =>
      startingCityId != null && destCityId != null;

  /// Padding that keeps first/last city markers visible when fitting
  /// bounds. See the `_mapFit*Padding` constants for rationale.
  MbxEdgeInsets _fitBoundsPadding() => MbxEdgeInsets(
        top: _mapFitTopPadding,
        left: _mapFitHorizontalPadding,
        bottom: _mapFitBottomPadding,
        right: _mapFitHorizontalPadding,
      );

  void setIsActive(bool active) {
    _isActive = active;
  }

  Future<void> onTabBecameActive() async {
    if (disposed) return;
    if (!_pendingFit) return;
    await _fitToCurrentRoute();
  }

  Future<void> _fitToCurrentRoute() async {
    if (disposed) return;
    final map = _map;
    if (map == null) return;

    final chartRoutePoints = getChartRoutePoints();
    final points = getPoints();
    if (points.isEmpty && chartRoutePoints.isEmpty) return;

    final useSubRouteFit =
        hasSubRouteSelection || chartRoutePoints.isNotEmpty;
    if (useSubRouteFit && chartRoutePoints.isNotEmpty) {
      await MapUtil.fitBounds(
        mapController: map,
        points: MapUtil.getLatLngsFromChartRoutePoints(chartRoutePoints),
        zoomConstant: 1.2,
        padding: _fitBoundsPadding(),
      );
    } else {
      await MapUtil.fitBounds(
        mapController: map,
        points: MapUtil.getLatLngsFromRoutePoints(points),
        padding: _fitBoundsPadding(),
      );
    }

    // On iOS, fitBounds against an offstage UiKitView is dropped.
    // Only clear the pending flag when we know we were visible —
    // otherwise retry once the tab becomes active.
    if (_isActive) {
      _pendingFit = false;
    }
  }

  /// Mirrors the original `initState` + `didChangeDependencies` logic.
  /// Idempotent — may be called multiple times safely.
  ///
  /// Note: location init, cluster init and elevation-icon pre-create are
  /// fire-and-forget (matching the original widget, which chained them
  /// via `.then` / `unawaited`).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final cubit = MapCubit(routeId: routeId);
    _mapCubit = cubit;
    if (routeId != null) {
      unawaited(
        cubit.loadCities(
          startingCityId: startingCityId,
          destCityId: destCityId,
        ),
      );
      _cityStreamSubscription = cubit.citiesStream.listen(handleCities);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (disposed || !context.mounted) return;
      _triggerAutoDownload();
    });

    _initializeHandlers();

    _mapCubit
        ?.loadDoNotAskLocationRequired()
        .then((doNotAskLocationRequired) {
      if (disposed) return;
      _locationHandler?.initialize(
        showDialog: !doNotAskLocationRequired,
      );
    });
    unawaited(_clusterHandler?.initialize());

    if (getPoints().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (disposed || !context.mounted) return;
        await _locationHandler?.showAlertDialog(context);
      });
    }

    unawaited(_markerHandler?.preCreateElevationIcon());
  }

  void _initializeHandlers() {
    _markerHandler = MapMarkerHandler(context: context);

    _clusterHandler = MapClusterHandler(
      getRoutePoints: getPoints,
      markerHandler: _markerHandler!,
    );

    _locationHandler = MapLocationHandler(
      context: context,
      onLocationStateChanged: onLocationStateChanged,
      onDistanceChanged: onDistanceChanged,
      onAltitudeChanged: onAltitudeChanged,
      onMyLocationEnabledChanged: (enabled) {
        if (_map != null) {
          _map!.location.updateSettings(
            LocationComponentSettings(
              enabled: enabled,
              pulsingEnabled: enabled,
            ),
          );
        }
        onMyLocationEnabledChanged(enabled);
      },
      getMapController: () => _map,
      getRoutePoints: getPoints,
      getUnit: getUnit,
      getRoute: () => RouteEntity(
        id: routeId ?? 0,
        routeName: _mapCubit?.state.route?.routeName ?? '',
        orderKey: 0,
      ),
      getChartRoutePoints: getChartRoutePoints,
    );

    _chartHandler = MapChartHandler(
      getMapController: () => _map,
      getChartRoutePoints: getChartRoutePoints,
      markerHandler: _markerHandler!,
    );
  }

  void _triggerAutoDownload() {
    final id = routeId;
    final points = getPoints();
    AppLogger.d(
      '[OFFLINE] MapScreen._triggerAutoDownload — '
      'routeId=$id points=${points.length}',
      tag: 'MapScreen',
    );
    if (id == null || points.isEmpty) {
      AppLogger.d(
        '[OFFLINE] MapScreen skipped — routeId or points missing',
        tag: 'MapScreen',
      );
      return;
    }
    unawaited(
      GetIt.instance<OfflineMapRepository>().downloadIfNeeded(
        routeId: id,
        routeName: routeName,
        points: points,
      ),
    );
  }

  /// Called from the widget's `MapWidget.onMapCreated` callback.
  Future<void> onMapCreated(MapboxMap map) async {
    if (disposed) return;
    _map = map;
    setInitialStyleUri(
      context.mounted && context.isDarkMode
          ? MapboxMapStyle.dark
          : MapboxMapStyle.light,
    );
    // Initialize the polyline delegate (takes ownership of the
    // `PolylineAnnotationManager` for this map).
    await _polylineDelegate.initialize(map.annotations);
    final pointAnnotationManager =
        await map.annotations.createPointAnnotationManager();
    _markerHandler?.setAnnotationManager(pointAnnotationManager);

    // `GestureDelegate` defaults: rotate/pitch disabled, scale bar off,
    // compass off, attribution off, location disabled, pulsing disabled —
    // matches the original inline configuration. We override
    // `locationEnabled` to match the prior behaviour (only enable when
    // `_locationHandler?.myLocationEnabled` is true).
    final locationEnabled = _locationHandler?.myLocationEnabled ?? false;
    await GestureDelegate(
      locationEnabled: locationEnabled,
      locationPulsingEnabled: locationEnabled,
    ).apply(map);

    await _fitToCurrentRoute();
    await drawPolylines();
    await _clusterHandler?.updateArrowsForViewport(map);
    await _markerHandler?.preCreateElevationIcon();
  }

  /// Called when the app theme changes. Triggers a Mapbox style reload —
  /// `MapWidget.styleUri` is consumed only at creation, so the style must
  /// be swapped imperatively. `loadStyleURI` auto-refires `onStyleLoaded`,
  /// which recreates the annotation managers (they do NOT survive a
  /// style reload) and redraws polylines / re-adds markers.
  ///
  /// Clears the widget-marker bitmap cache up-front so first/last-city
  /// markers re-render with the new theme colours.
  Future<void> onThemeChanged({required bool isDark}) async {
    if (disposed || _map == null) return;
    MarkerHelper.clearWidgetMarkerCache();
    final themeUri = isDark ? MapboxMapStyle.dark : MapboxMapStyle.light;
    // If the user is currently viewing satellite, leave the visible
    // style alone but update the URI we'll restore to when satellite is
    // toggled off — otherwise toggling off would land them on the
    // pre-change theme.
    if (isSatelliteView) {
      updatePreSatelliteThemeUri(themeUri);
      return;
    }
    await swapStyle(themeUri);
  }

  /// Routes a satellite toggle through the mixin's serialised
  /// [MapboxHostMixin.toggleSatellite] using the current theme as the
  /// fallback URI.
  Future<void> toggleSatelliteView({required bool isDark}) async {
    if (disposed) return;
    final themeUri = isDark ? MapboxMapStyle.dark : MapboxMapStyle.light;
    await toggleSatellite(themeUri: themeUri);
  }

  /// Called from the widget's `MapWidget.onStyleLoadedListener` callback.
  ///
  /// Annotation managers do NOT survive a `loadStyleURI` swap — recreate
  /// them here BEFORE drawing, otherwise `drawPolylines` and the marker
  /// handler would write into stale managers and silently no-op.
  Future<void> onStyleLoaded() async {
    if (disposed) return;
    final map = _map;
    if (map != null) {
      // Recreate the polyline annotation manager on the freshly-loaded
      // style. `resetForStyleReload` drops the cached reference so the
      // subsequent `initialize` call creates a new one — mirrors the
      // pattern used in `onMapCreated`.
      _polylineDelegate.resetForStyleReload();
      await _polylineDelegate.initialize(map.annotations);

      // The point annotation manager held by `_markerHandler` is also
      // stale. Recreate it and hand it back via `setAnnotationManager`
      // (the existing setter is the same one `onMapCreated` uses).
      final pointAnnotationManager =
          await map.annotations.createPointAnnotationManager();
      _markerHandler?.setAnnotationManager(pointAnnotationManager);
    }

    await drawPolylines();
    if (map != null) {
      await _clusterHandler?.updateArrowsForViewport(map);
    }
    await _markerHandler?.createFirstLastCityAnnotations();
  }

  /// Called from the widget's `MapWidget.onCameraChangeListener` callback.
  /// Debounces arrow-viewport updates at 300ms.
  void onCameraChange() {
    if (disposed) return;
    _arrowDebounce?.cancel();
    _arrowDebounce = Timer(
      const Duration(milliseconds: 300),
      () async {
        if (disposed) return;
        final map = _map;
        if (!context.mounted || map == null) {
          return;
        }
        await _clusterHandler?.updateArrowsForViewport(map);
      },
    );
  }

  /// Called from the widget's `MapWidget.onMapIdleListener` callback.
  Future<void> onMapIdle() async {
    if (disposed) return;
    final map = _map;
    if (map == null) return;
    await _clusterHandler?.updateArrowsForViewport(map);
    if (disposed) return;
    final state = await map.getCameraState();
    if (disposed) return;
    // ignore: unnecessary_null_comparison
    if (state != null) {
      _markerHandler?.updateFirstLastCityMarkersVisibility(state.zoom);
    }
  }

  /// Draws all polylines: main route (red), optional selected sub-route
  /// (primary colour depending on theme) and alt routes (their own hex
  /// colour with 0x88 alpha).
  ///
  /// This method intentionally does NOT use
  /// [PolylineDelegate.syncRoutePolylines] — that helper doesn't support
  /// the sub-route colouring driven by `chartRoutePoints`. We use the
  /// delegate for lifecycle (`clear()` / exposed manager) but create
  /// annotations manually with the original colour/width logic.
  Future<void> drawPolylines() async {
    final manager = _polylineDelegate.manager;
    if (manager == null) return;

    await _polylineDelegate.clear();

    final points = getPoints();
    if (points.isNotEmpty) {
      await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: points
                .map(
                  (e) => Position(e.longitude, e.latitude),
                )
                .toList(),
          ),
          lineColor: Colors.red.value,
          lineWidth: 3.0,
          lineSortKey: 1.0,
        ),
      );
    }

    final chartRoutePoints = getChartRoutePoints();
    if (chartRoutePoints.isNotEmpty && hasSubRouteSelection) {
      final selectedColor =
          context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
      await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: chartRoutePoints
                .map((e) => Position(e.lon, e.lat))
                .toList(),
          ),
          lineColor: selectedColor.value,
          lineWidth: 4.0,
          lineSortKey: 2.0,
        ),
      );
    }

    for (final ap in getAltPoints()) {
      if (ap.values.isNotEmpty) {
        final color = HexColor.fromHex('88${ap.color ?? 'FF0000'}');
        await manager.create(
          PolylineAnnotationOptions(
            geometry: LineString(
              coordinates: ap.values
                  .map(
                    (e) => Position(e.longitude, e.latitude),
                  )
                  .toList(),
            ),
            lineColor: color.value,
            lineWidth: 2.0,
            lineSortKey: 0.5,
          ),
        );
      }
    }
  }

  /// Called from the widget's `didUpdateWidget`. Mirrors the original
  /// behaviour: redraw polylines, trigger auto-download when points
  /// appeared for the first time, and refit bounds after a 350ms delay.
  void updatePoints({
    required List<RoutePointEntity> oldPoints,
    required List<RoutePointEntity> points,
    required List<AltRoutePointEntity> oldAltPoints,
    required List<AltRoutePointEntity> altPoints,
    required List<ChartRoutePoint> oldChartRoutePoints,
    required List<ChartRoutePoint> chartRoutePoints,
  }) {
    if (disposed) return;
    final didPointsChange = oldPoints != points;
    final didAltPointsChange = oldAltPoints != altPoints;
    final didChartRoutePointsChange = oldChartRoutePoints != chartRoutePoints;

    if (didPointsChange || didAltPointsChange || didChartRoutePointsChange) {
      drawPolylines();

      if (oldPoints.isEmpty && points.isNotEmpty) {
        _triggerAutoDownload();
      }

      if (_map != null) {
        _pendingFit = true;
        Future.delayed(
          const Duration(milliseconds: 350),
          () {
            if (disposed || !context.mounted || _map == null) return;
            unawaited(_fitToCurrentRoute());
          },
        );
      }
    }
  }

  void handleCities(List<CityEntity> cities) {
    if (disposed) return;
    _clusterHandler?.handleCities(
      cities,
      startingCityId: startingCityId,
      destCityId: destCityId,
    );
  }

  void dispose() {
    if (disposed) return;
    disposeHost();
    _arrowDebounce?.cancel();
    _arrowDebounce = null;
    _locationHandler?.dispose();
    _chartHandler?.dispose();
    _cityStreamSubscription?.cancel();
    final cubit = _mapCubit;
    if (cubit != null && !cubit.isClosed) {
      cubit.close();
    }
    _markerHandler?.clearAnnotations();
    // Drop the polyline annotation manager reference. Without this the
    // native manager stays reachable from Dart and pins the annotation
    // graph across push/pop of the map screen.
    unawaited(_polylineDelegate.clear().catchError((_) {}));
    _polylineDelegate.resetForStyleReload();
    _map = null;
  }
}
