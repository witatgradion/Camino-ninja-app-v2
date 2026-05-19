import 'dart:async';
import 'dart:convert';

import 'package:camino_ninja_flutter/mapbox/controllers/mapbox_host_mixin.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/gesture_delegate.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/route_layer_delegate.dart';
import 'package:camino_ninja_flutter/repositories/offline_map_repository.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/utils/route_label_resolver.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

const _defaultLegendColor = 'FF0000';
const _zoomConstantAllRoutes = 0.7;
const _zoomConstantSingleRoute = 0.85;

/// Padding used when `RoutePreviewPanel` is visible above the bottom edge
/// (the panel sits at `bottom: 16` with fixed-ish content — ~220 px keeps
/// the route line/label clear of it).
const _previewPanelBottomPadding = 220.0;

/// Modest inset for the top/left/right edges so the route label does not
/// hug the edge of the screen.
const _previewEdgePadding = 48.0;

class SelectRouteMapController with MapboxHostMixin {
  SelectRouteMapController({
    required List<RouteDistanceElevation> filteredRoutes,
    required Map<int, List<RoutePointEntity>> routePointsByRouteId,
    required int? selectedRouteId,
    required this.onRouteSelected,
    required bool isDarkMode,
    required this.unit,
    this.isSearchActive = false,
  })  : _filteredRoutes = filteredRoutes,
        _routePointsByRouteId = routePointsByRouteId,
        _selectedRouteId = selectedRouteId,
        _isDarkMode = isDarkMode;

  List<RouteDistanceElevation> _filteredRoutes;
  Map<int, List<RoutePointEntity>> _routePointsByRouteId;
  int? _selectedRouteId;
  bool _isDarkMode;
  bool isSearchActive;
  final UnitEnum unit;
  final void Function(int routeId) onRouteSelected;

  final RouteLayerDelegate _layerDelegate = RouteLayerDelegate();

  MapboxMap? _mapController;
  bool _initialFitDone = false;

  List<RouteDistanceElevation>? _sortedRoutesCache;
  Map<int, List<LatLng>>? _latLngCache;
  List<LatLng>? _allPointsCache;

  final ValueNotifier<RouteDistanceElevation?> previewRoute =
      ValueNotifier<RouteDistanceElevation?>(null);

  MapboxMap? get mapboxMap => _mapController;
  @override
  MapboxMap? get hostMap => _mapController;
  int? get selectedRouteId => _selectedRouteId;

  // ── Coordinate caches ──────────────────────────────────────

  Map<int, List<LatLng>> get _latLngsById {
    if (_latLngCache != null) return _latLngCache!;
    final cache = <int, List<LatLng>>{};
    _routePointsByRouteId.forEach((routeId, points) {
      cache[routeId] =
          points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    });
    _latLngCache = cache;
    return cache;
  }

  List<LatLng> _allPointsForBounds() {
    if (_allPointsCache != null) return _allPointsCache!;
    final points = <LatLng>[];
    for (final route in _filteredRoutes) {
      final pts = _latLngsById[route.routeId];
      if (pts != null && pts.isNotEmpty) {
        points.addAll(pts);
      }
    }
    _allPointsCache = points;
    return points;
  }

  List<LatLng> _pointsForRoute(int routeId) =>
      _latLngsById[routeId] ?? const [];

  // ── Camera ─────────────────────────────────────────────────

  Future<void> _fitBounds(
    List<LatLng> points, {
    double zoomConstant = _zoomConstantAllRoutes,
    MbxEdgeInsets? padding,
  }) async {
    if (_mapController == null || points.isEmpty) return;
    await MapUtil.fitBounds(
      mapController: _mapController,
      points: points,
      zoomConstant: zoomConstant,
      padding: padding,
    );
  }

  /// Padding that keeps the route line/label clear of the bottom preview
  /// panel, with modest insets on the other edges. Only used when a
  /// preview is being shown.
  MbxEdgeInsets _previewPadding() => MbxEdgeInsets(
        top: _previewEdgePadding,
        left: _previewEdgePadding,
        bottom: _previewPanelBottomPadding,
        right: _previewEdgePadding,
      );

  Future<void> _performInitialFit() async {
    if (_mapController == null || _initialFitDone) return;
    _initialFitDone = true;
    await _refitForCurrentSelection();
  }

  /// Re-fits the camera to the current selection (or to all routes if no
  /// route is selected), using no padding. Used after the preview panel
  /// is dismissed so the camera no longer respects the panel's bottom
  /// padding.
  Future<void> _refitForCurrentSelection() async {
    if (_mapController == null) return;
    final selectedId = _selectedRouteId;
    if (selectedId != null) {
      final points = _pointsForRoute(selectedId);
      if (points.isNotEmpty) {
        await _fitBounds(
          points,
          zoomConstant: _zoomConstantSingleRoute,
        );
        return;
      }
    }
    final all = _allPointsForBounds();
    if (all.isNotEmpty) {
      await _fitBounds(all);
    }
  }

  // ── Route helpers ──────────────────────────────────────────

  List<RouteDistanceElevation> get _routesByOrderKey =>
      _sortedRoutesCache ??= (List<RouteDistanceElevation>.from(
        _filteredRoutes,
      )..sort((a, b) => a.route.orderKey.compareTo(b.route.orderKey)));

  Color _colorOf(RouteDistanceElevation route) {
    final hex = (_isDarkMode
            ? route.route.darkLegendColor
            : route.route.lightLegendColor) ??
        _defaultLegendColor;
    return HexColor.fromHex(hex);
  }

  Color get _selectedRouteAccentColor => _isDarkMode
      ? AppColors.mapSelectedRouteDark
      : AppColors.mapSelectedRouteLight;

  int? get _effectiveHighlightedRouteId =>
      previewRoute.value?.routeId ?? _selectedRouteId;

  String _markerLabel(RouteDistanceElevation route) =>
      route.routeName.replaceAll(RegExp('-->|->'), '→');

  // ── GeoJSON builders ───────────────────────────────────────

  String _colorToHex(Color c) => '#${c.red.toRadixString(16).padLeft(2, '0')}'
      '${c.green.toRadixString(16).padLeft(2, '0')}'
      '${c.blue.toRadixString(16).padLeft(2, '0')}';

  String _contrastingHex(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? '#000000' : '#ffffff';
  }

  String _buildLinesGeoJson() {
    final features = <Map<String, dynamic>>[];
    for (final route in _routesByOrderKey) {
      final pts = _latLngsById[route.routeId];
      if (pts == null || pts.isEmpty) continue;
      final color = _colorOf(route);
      features.add({
        'type': 'Feature',
        'id': route.routeId.toString(),
        'properties': {
          'routeId': route.routeId,
          'baseColor': _colorToHex(color),
          'selectedColor': _colorToHex(_selectedRouteAccentColor),
          'baseSortKey': 1,
        },
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            for (final p in pts) [p.longitude, p.latitude],
          ],
        },
      });
    }
    return jsonEncode({
      'type': 'FeatureCollection',
      'features': features,
    });
  }

  String _buildLabelsGeoJson() {
    final features = <Map<String, dynamic>>[];
    for (final route in _routesByOrderKey) {
      final pts = _routePointsByRouteId[route.routeId];
      if (pts == null || pts.isEmpty) continue;
      final mid = pts[pts.length ~/ 2];
      final color = _colorOf(route);
      final selectedColor = _selectedRouteAccentColor;
      final sortKey = RouteLabelResolver.priorityOf(route);
      features.add({
        'type': 'Feature',
        'id': route.routeId.toString(),
        'properties': {
          'routeId': route.routeId,
          'label': _markerLabel(route),
          'baseTextColor': _contrastingHex(color),
          'selectedTextColor': _contrastingHex(selectedColor),
          'baseHaloColor': _colorToHex(color),
          'selectedHaloColor': _colorToHex(selectedColor),
          'baseSortKey': -sortKey,
        },
        'geometry': {
          'type': 'Point',
          'coordinates': [mid.longitude, mid.latitude],
        },
      });
    }
    return jsonEncode({
      'type': 'FeatureCollection',
      'features': features,
    });
  }

  // ── Layer orchestration ───────────────────────────────────

  Future<void> _updateSourceData() async {
    final map = _mapController;
    if (map == null) return;
    await _layerDelegate.updateSourceData(
      map.style,
      _buildLinesGeoJson(),
      _buildLabelsGeoJson(),
    );
    await _applyHighlightedRoute(_effectiveHighlightedRouteId);
  }

  Future<void> _applyHighlightedRoute(int? routeId) async {
    final map = _mapController;
    if (map == null) return;
    await _layerDelegate.applyHighlightedRoute(map, routeId);
  }

  // ── Tap handling ───────────────────────────────────────────

  Future<void> onMapTap(MapContentGestureContext ctx) async {
    final map = _mapController;
    if (map == null) return;

    final point = ctx.touchPosition;

    try {
      final routeId = await _layerDelegate.queryTappedRouteId(map, point);
      if (routeId != null) {
        await _onMarkerTap(routeId);
        return;
      }
      cancelPreview();
    } catch (_) {
      cancelPreview();
    }
  }

  void cancelPreview() {
    if (previewRoute.value == null) return;
    previewRoute.value = null;
    _applyHighlightedRoute(_effectiveHighlightedRouteId);
    // Re-fit the camera so it no longer respects the preview panel's
    // bottom padding (the panel is gone). Fire-and-forget — callers of
    // cancelPreview are synchronous gesture handlers.
    unawaited(_refitForCurrentSelection());
  }

  Future<void> _onMarkerTap(int routeId) async {
    final route =
        _filteredRoutes.where((r) => r.routeId == routeId).firstOrNull;
    if (route == null) return;
    previewRoute.value = route;
    final pts = _pointsForRoute(routeId);
    final tasks = <Future<void>>[
      _applyHighlightedRoute(_effectiveHighlightedRouteId),
    ];
    if (pts.isNotEmpty) {
      // Preview panel is now visible — pad the bottom so the route line
      // and its mid-point label are not occluded by the panel.
      tasks.add(
        _fitBounds(
          pts,
          zoomConstant: _zoomConstantSingleRoute,
          padding: _previewPadding(),
        ),
      );
    }
    await Future.wait(tasks);
  }

  // ── Auto-download ──────────────────────────────────────────

  void _triggerAutoDownload() {
    final selectedId = _selectedRouteId;
    AppLogger.d(
      '[OFFLINE] SelectRouteMap._triggerAutoDownload — '
      'selectedRouteId=$selectedId',
      tag: 'SelectRouteMap',
    );
    if (selectedId == null) {
      AppLogger.d(
        '[OFFLINE] SelectRouteMap skipped — no route selected',
        tag: 'SelectRouteMap',
      );
      return;
    }
    final points = _routePointsByRouteId[selectedId];
    if (points == null || points.isEmpty) {
      AppLogger.d(
        '[OFFLINE] SelectRouteMap skipped — no points for route $selectedId',
        tag: 'SelectRouteMap',
      );
      return;
    }
    final selectedRoute =
        _filteredRoutes.where((r) => r.routeId == selectedId).firstOrNull;
    if (selectedRoute == null) return;
    AppLogger.d(
      '[OFFLINE] SelectRouteMap triggering download — '
      'routeId=$selectedId "${selectedRoute.routeName}" '
      'points=${points.length}',
      tag: 'SelectRouteMap',
    );
    unawaited(
      GetIt.instance<OfflineMapRepository>().downloadIfNeeded(
        routeId: selectedId,
        routeName: selectedRoute.routeName,
        points: points,
      ),
    );
  }

  // ── Lifecycle / external hooks ─────────────────────────────

  Future<void> onMapCreated(MapboxMap map) async {
    if (disposed) return;
    _mapController = map;
    setInitialStyleUri(
      _isDarkMode ? MapboxMapStyle.dark : MapboxMapStyle.light,
    );
    map.setOnMapTapListener(onMapTap);
    await const GestureDelegate(
      locationEnabled: false,
      locationPulsingEnabled: false,
    ).apply(map);
    _triggerAutoDownload();
  }

  Future<void> onStyleLoaded() async {
    if (disposed) return;
    final map = _mapController;
    if (map == null) return;
    await _performInitialFit();
    if (disposed) return;
    await _layerDelegate.setup(
      map.style,
      _buildLinesGeoJson(),
      _buildLabelsGeoJson(),
    );
    if (disposed) return;
    await _applyHighlightedRoute(_effectiveHighlightedRouteId);
  }

  Future<void> onRouteDataChanged({
    required List<RouteDistanceElevation> filteredRoutes,
    required Map<int, List<RoutePointEntity>> routePointsByRouteId,
    required bool isDarkMode,
    required int? selectedRouteId,
    required bool isSearchActive,
  }) async {
    final routesChanged = _filteredRoutes != filteredRoutes ||
        _routePointsByRouteId != routePointsByRouteId;
    final darkModeChanged = _isDarkMode != isDarkMode;

    _filteredRoutes = filteredRoutes;
    _routePointsByRouteId = routePointsByRouteId;
    _isDarkMode = isDarkMode;
    _selectedRouteId = selectedRouteId;
    this.isSearchActive = isSearchActive;

    if (routesChanged) {
      _sortedRoutesCache = null;
      _latLngCache = null;
      _allPointsCache = null;
    }

    if (darkModeChanged) {
      final newUri = isDarkMode ? MapboxMapStyle.dark : MapboxMapStyle.light;
      if (_mapController != null && currentStyleUri != newUri) {
        // `loadStyleURI` auto-refires `onStyleLoaded`, which rebuilds
        // the route layers with fresh GeoJSON. Skip the source-data
        // update below to avoid touching layers that are about to be
        // recreated.
        if (isSatelliteView) {
          updatePreSatelliteThemeUri(newUri);
        } else {
          await swapStyle(newUri);
        }
      }
    } else if (routesChanged) {
      await _updateSourceData();
    }

    if (routesChanged && _initialFitDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (disposed) return;
        if (!isSearchActive) {
          final selectedId = selectedRouteId;
          if (selectedId != null) {
            final pts = _pointsForRoute(selectedId);
            if (pts.isNotEmpty) {
              _fitBounds(
                pts,
                zoomConstant: _zoomConstantSingleRoute,
              );
              return;
            }
          }
        }
        final all = _allPointsForBounds();
        if (all.isNotEmpty) {
          _fitBounds(all);
        }
      });
    }
  }

  Future<void> onSelectionChanged(int? selectedRouteId) async {
    if (disposed) return;
    _selectedRouteId = selectedRouteId;
    await _applyHighlightedRoute(_effectiveHighlightedRouteId);
    if (selectedRouteId != null) {
      _triggerAutoDownload();
    }
  }

  /// Routes a satellite toggle through the mixin's serialised
  /// [MapboxHostMixin.toggleSatellite] using the controller's current
  /// dark-mode state as the fallback theme URI.
  Future<void> toggleSatelliteView() async {
    if (disposed) return;
    final themeUri = _isDarkMode ? MapboxMapStyle.dark : MapboxMapStyle.light;
    await toggleSatellite(themeUri: themeUri);
  }

  void dispose() {
    if (disposed) return;
    disposeHost();
    // Drop the native tap listener edge so the closure (which captures
    // `this` via `onMapTap`) does not pin the controller and its layer
    // delegate after the hosting widget unmounts.
    _mapController?.setOnMapTapListener(null);
    previewRoute.dispose();
    _mapController = null;
  }
}
