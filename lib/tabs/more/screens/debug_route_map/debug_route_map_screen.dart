import 'dart:async';

import 'package:camino_ninja_flutter/mapbox/mapbox.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

/// Dev-only debug screen that displays a full route on a
/// Mapbox map with all cities as markers.
class DebugRouteMapScreen extends StatefulWidget {
  const DebugRouteMapScreen({super.key});

  @override
  State<DebugRouteMapScreen> createState() => _DebugRouteMapScreenState();
}

class _DebugRouteMapScreenState extends State<DebugRouteMapScreen> {
  final _repository = GetIt.instance<Repository>();

  List<RouteEntity> _routes = [];
  int? _selectedRouteId;
  List<CityEntity> _cities = [];
  List<RoutePointEntity> _routePoints = [];
  Map<int, Set<int>> _cityRouteMapping = {};
  bool _isLoadingRoutes = true;
  bool _isLoadingRouteData = false;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      final routes = await _repository.getRoutesFromDb();
      final mapping = await _repository.getCityRouteMapping();
      if (!mounted) return;
      setState(() {
        _routes = routes;
        _cityRouteMapping = mapping;
        _isLoadingRoutes = false;
      });
    } catch (e, st) {
      AppLogger.e(
        'Failed to load routes',
        tag: 'DebugRouteMap',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      setState(() => _isLoadingRoutes = false);
    }
  }

  Future<void> _onRouteSelected(int routeId) async {
    setState(() {
      _selectedRouteId = routeId;
      _isLoadingRouteData = true;
      _cities = [];
      _routePoints = [];
    });

    try {
      final cities = await _repository.getCitiesByRouteIdFromDb(routeId);
      final routePoints = await _repository.getRoutePointsByRouteIdFromDb(
        routeId: routeId,
      );
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _routePoints = routePoints;
        _isLoadingRouteData = false;
      });
    } catch (e, st) {
      AppLogger.e(
        'Failed to load route data',
        tag: 'DebugRouteMap',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      setState(() => _isLoadingRouteData = false);
    }
  }

  bool _isJunction(int cityId) {
    final routeIds = _cityRouteMapping[cityId];
    return routeIds != null && routeIds.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CaminoNinjaAppBar(
        title: 'Debug Route Map',
      ),
      body: _isLoadingRoutes
          ? const Center(child: LoadingWidget())
          : Column(
              children: [
                _RouteDropdown(
                  routes: _routes,
                  selectedRouteId: _selectedRouteId,
                  onChanged: _onRouteSelected,
                ),
                if (_selectedRouteId == null)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Select a route to visualize',
                      ),
                    ),
                  )
                else if (_isLoadingRouteData)
                  const Expanded(
                    child: Center(child: LoadingWidget()),
                  )
                else
                  Expanded(
                    child: _MapView(
                      cities: _cities,
                      routePoints: _routePoints,
                      selectedRouteId: _selectedRouteId!,
                      isJunction: _isJunction,
                    ),
                  ),
              ],
            ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Route dropdown
// ────────────────────────────────────────────────────────

class _RouteDropdown extends StatelessWidget {
  const _RouteDropdown({
    required this.routes,
    required this.selectedRouteId,
    required this.onChanged,
  });

  final List<RouteEntity> routes;
  final int? selectedRouteId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: DropdownButtonFormField<int>(
        initialValue: selectedRouteId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Route',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: routes
            .map(
              (r) => DropdownMenuItem<int>(
                value: r.id,
                child: Text(
                  r.routeSubName != null
                      ? '${r.routeName}'
                          ' (${r.routeSubName})'
                      : r.routeName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (routeId) {
          if (routeId != null) onChanged(routeId);
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Map view with debug info overlay
// ────────────────────────────────────────────────────────

class _MapView extends StatefulWidget {
  const _MapView({
    required this.cities,
    required this.routePoints,
    required this.selectedRouteId,
    required this.isJunction,
  });

  final List<CityEntity> cities;
  final List<RoutePointEntity> routePoints;
  final int selectedRouteId;
  final bool Function(int cityId) isJunction;

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> with MapboxHostMixin {
  MapboxMap? _map;
  bool _mapReady = false;
  bool _styleLoaded = false;
  bool _wasDark = false;

  final PolylineDelegate _polylineDelegate = PolylineDelegate();
  final WidgetMarkerDelegate _markerDelegate = WidgetMarkerDelegate();
  late GestureDelegate _gestureDelegate;

  @override
  MapboxMap? get hostMap => _map;

  @override
  void initState() {
    super.initState();
    _gestureDelegate = const GestureDelegate(locationEnabled: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = context.isDarkMode;
    if (_mapReady && isDark != _wasDark) {
      _wasDark = isDark;
      unawaited(
        swapStyle(
          isDark ? MapboxMapStyle.dark : MapboxMapStyle.light,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(_MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_styleLoaded &&
        (oldWidget.selectedRouteId != widget.selectedRouteId ||
            oldWidget.cities.length != widget.cities.length ||
            oldWidget.routePoints.length != widget.routePoints.length)) {
      unawaited(_redraw());
    }
  }

  @override
  void dispose() {
    disposeHost();
    _mapReady = false;
    _styleLoaded = false;
    unawaited(_polylineDelegate.clear().catchError((_) {}));
    unawaited(_markerDelegate.clear().catchError((_) {}));
    _polylineDelegate.resetForStyleReload();
    _markerDelegate.resetForStyleReload();
    _map = null;
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    if (disposed) return;
    _map = map;
    _wasDark = context.isDarkMode;
    setInitialStyleUri(
      _wasDark ? MapboxMapStyle.dark : MapboxMapStyle.light,
    );
    await _gestureDelegate.apply(map);
    _mapReady = true;
  }

  Future<void> _onStyleLoaded() async {
    if (disposed || !_mapReady) return;
    final map = _map;
    if (map == null) return;
    _polylineDelegate.resetForStyleReload();
    _markerDelegate.resetForStyleReload();
    await _polylineDelegate.initialize(map.annotations);
    await _markerDelegate.initialize(map.annotations);
    _styleLoaded = true;
    await _redraw();
  }

  Future<void> _redraw() async {
    if (disposed) return;
    await _syncPolyline();
    await _syncMarkers();
    await _fitBounds();
  }

  Future<void> _syncPolyline() async {
    final manager = _polylineDelegate.manager;
    if (manager == null) return;
    await _polylineDelegate.clear();
    if (widget.routePoints.isEmpty) return;
    final coords = widget.routePoints
        .map((p) => Position(p.longitude, p.latitude))
        .toList();
    await manager.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: coords),
        lineColor: Colors.red.toARGB32(),
        lineWidth: 4,
      ),
    );
  }

  Future<void> _syncMarkers() async {
    await _markerDelegate.clear();
    if (!mounted) return;

    for (final city in widget.cities) {
      final isJunction = widget.isJunction(city.id);

      final rp = city.routePoints.cast<RoutePointEntity?>().firstWhere(
            (rp) => rp!.routeId == widget.selectedRouteId,
            orElse: () => null,
          );
      final position = rp != null
          ? LatLng(rp.latitude, rp.longitude)
          : LatLng(city.latitude, city.longitude);

      if (!mounted) return;
      await _markerDelegate.addWidgetMarker(
        context: context,
        widget: _CityMarkerWidget(isJunction: isJunction),
        cacheKey: isJunction
            ? 'debug-route-city-junction'
            : 'debug-route-city-plain',
        position: position,
        iconAnchor: IconAnchor.CENTER,
      );
    }
  }

  Future<void> _fitBounds() async {
    if (widget.routePoints.isEmpty) return;
    final points = MapUtil.getLatLngsFromRoutePoints(widget.routePoints);
    await MapUtil.fitBounds(
      mapController: _map,
      points: points,
      zoomConstant: 1.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final initial = widget.routePoints.isNotEmpty
        ? LatLng(
            widget.routePoints.first.latitude,
            widget.routePoints.first.longitude,
          )
        : const LatLng(42.88, -8.55);

    return Stack(
      children: [
        MapWidget(
          styleUri: isDark ? MapboxMapStyle.dark : MapboxMapStyle.light,
          cameraOptions: CameraOptions(
            center: Point(
              coordinates: Position(initial.longitude, initial.latitude),
            ),
            zoom: 6,
          ),
          onMapCreated: _onMapCreated,
          onStyleLoadedListener: (_) => _onStyleLoaded(),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: _DebugInfoChip(
            cityCount: widget.cities.length,
            routePointCount: widget.routePoints.length,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
// City marker widget (red for plain, blue for junction).
// Replaces Google Maps's defaultMarkerWithHue pins.
// ────────────────────────────────────────────────────────

class _CityMarkerWidget extends StatelessWidget {
  const _CityMarkerWidget({required this.isJunction});

  final bool isJunction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isJunction ? Colors.blue : Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Debug info chip — shows counts of cities + route points
// ────────────────────────────────────────────────────────

class _DebugInfoChip extends StatelessWidget {
  const _DebugInfoChip({
    required this.cityCount,
    required this.routePointCount,
  });

  final int cityCount;
  final int routePointCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$cityCount cities  |  $routePointCount pts',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }
}
