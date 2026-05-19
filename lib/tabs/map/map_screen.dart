import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/mapbox/mapbox.dart';
import 'package:camino_ninja_flutter/tabs/map/map_tab_screen.dart';
import 'package:camino_ninja_flutter/tabs/map/widgets/location_warning_widget.dart';
import 'package:camino_ninja_flutter/tabs/map/widgets/my_location_button.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/elevation_cubit.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:camino_ninja_flutter/widgets/elevation_chart_panel/elevation_chart_panel.dart';
import 'package:camino_ninja_flutter/widgets/satellite_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

class MapScreenArguments {
  const MapScreenArguments({
    required this.title,
    this.routeId,
    this.startingCityId,
    this.destCityId,
    this.routePoints = const [],
    this.altRoutePoints = const [],
  });
  final int? routeId;
  final int? startingCityId;
  final int? destCityId;
  final List<RoutePointEntity> routePoints;
  final List<AltRoutePointEntity> altRoutePoints;
  final String title;
}

class MapScreen extends StatelessWidget {
  const MapScreen({
    this.arguments,
    super.key,
  });
  final MapScreenArguments? arguments;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        final routeId = appState.selectedRoute?.id ?? arguments?.routeId ?? 0;
        final startingCityId =
            appState.selectedStartingPoint?.id ?? arguments?.startingCityId;
        final destCityId =
            appState.selectedDestination?.id ?? arguments?.destCityId;
        final routePoints =
            appState.routePoints ?? arguments?.routePoints ?? [];
        final altRoutePoints =
            appState.altRoutePoints ?? arguments?.altRoutePoints ?? [];

        return BlocProvider(
          key: ValueKey(
            'elevation-$routeId-$startingCityId-$destCityId',
          ),
          create: (context) => ElevationCubit(
            routeId: routeId,
            startingCityId: startingCityId,
            destCityId: destCityId,
          )..getRoutePoints(),
          child: BlocBuilder<ElevationCubit, ElevationState>(
            builder: (context, state) {
              final chartRoutePoints = state.routePoints ?? [];
              return MapScreenWidget(
                key: ValueKey(
                  '$routeId-$startingCityId-$destCityId',
                ),
                routeId: routeId > 0 ? routeId : null,
                routeName: appState.selectedRoute?.routeName ??
                    arguments?.title ??
                    '',
                unit: appState.unit,
                points: routePoints,
                altPoints: altRoutePoints,
                chartRoutePoints: chartRoutePoints,
                startingCityId: startingCityId,
                destCityId: destCityId,
              );
            },
          ),
        );
      },
    );
  }
}

class MapScreenWidget extends StatefulWidget {
  const MapScreenWidget({
    required this.points,
    required this.altPoints,
    required this.unit,
    required this.chartRoutePoints,
    required this.routeName,
    this.routeId,
    this.startingCityId,
    this.destCityId,
    super.key,
  });

  final int? routeId;
  final String routeName;
  final int? startingCityId;
  final int? destCityId;
  final UnitEnum unit;
  final List<RoutePointEntity> points;
  final List<AltRoutePointEntity> altPoints;
  final List<ChartRoutePoint> chartRoutePoints;

  @override
  State<MapScreenWidget> createState() => _MapScreenWidgetState();
}

class _MapScreenWidgetState extends State<MapScreenWidget> {
  late final MapScreenController _controller;

  String _currentDistance = '';
  String _currentAltitude = '';
  bool? _wasActive;

  @override
  void initState() {
    super.initState();
    _controller = MapScreenController(
      context: context,
      routeId: widget.routeId,
      routeName: widget.routeName,
      startingCityId: widget.startingCityId,
      destCityId: widget.destCityId,
      getPoints: () => widget.points,
      getAltPoints: () => widget.altPoints,
      getChartRoutePoints: () => widget.chartRoutePoints,
      getUnit: () => widget.unit,
      onLocationStateChanged: () {
        if (mounted) setState(() {});
      },
      onDistanceChanged: (distance) {
        if (mounted) {
          setState(() {
            _currentDistance = distance;
          });
        }
      },
      onAltitudeChanged: (altitude) {
        if (mounted) {
          setState(() {
            _currentAltitude = altitude;
          });
        }
      },
      onMyLocationEnabledChanged: (_) {
        // The controller itself updates the Mapbox location settings;
        // no widget-level state change is required (preserves the
        // original behaviour which did not call setState here).
      },
    );
    // Fire-and-forget: handler setup is synchronous up to the first
    // await, so by the first `build()` the handlers are already in
    // place. Async steps (location init, cluster init, etc.) complete
    // in the background.
    unawaited(_controller.initialize());
  }

  @override
  void didUpdateWidget(MapScreenWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.updatePoints(
      oldPoints: oldWidget.points,
      points: widget.points,
      oldAltPoints: oldWidget.altPoints,
      altPoints: widget.altPoints,
      oldChartRoutePoints: oldWidget.chartRoutePoints,
      chartRoutePoints: widget.chartRoutePoints,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isActive = TickerMode.of(context);
    _controller.setIsActive(isActive);
    if (isActive && _wasActive == false) {
      unawaited(_controller.onTabBecameActive());
    }
    _wasActive = isActive;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return BlocListener<AppCubit, AppState>(
          listenWhen: (previous, current) => previous.theme != current.theme,
          listener: (context, state) {
            if (mounted) {
              _controller.onThemeChanged(isDark: state.theme.isDarkMode);
            }
          },
          child: _controller.locationHandler != null &&
                  _controller.chartHandler != null
              ? BlocBuilder<AppCubit, AppState>(
                  builder: (context, state) {
                    return ElevationChartPanel(
                      appState: state,
                      parentHeight: boxConstraints.maxHeight,
                      loadLocationNotifier:
                          _controller.locationHandler!.loadLocationNotifier,
                      currentAltitude: _currentAltitude,
                      currentDistance: _currentDistance,
                      elevationData: widget.chartRoutePoints,
                      onTouchDown:
                          _controller.chartHandler!.handleChartTouchDown,
                      onTouchUp: _controller.chartHandler!.handleChartTouchUp,
                      onTouchMove:
                          _controller.chartHandler!.handleChartTouchMove,
                      unit: widget.unit,
                      body: (_) {
                        return _buildMap();
                      },
                    );
                  },
                )
              : _buildMap(),
        );
      },
    );
  }

  Widget _buildMap() {
    final isDark = context.isDarkMode;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRect(
            child: Stack(
              children: [
                MapWidget(
                  styleUri: isDark ? MapboxMapStyle.dark : MapboxMapStyle.light,
                  cameraOptions: CameraOptions(
                    center: Point(
                      coordinates: Position(-8.5396835, 42.8760274),
                    ),
                    zoom: 14.4746,
                  ),
                  onMapCreated: _controller.onMapCreated,
                  onStyleLoadedListener: (StyleLoadedEventData _) =>
                      _controller.onStyleLoaded(),
                  onCameraChangeListener: (CameraChangedEventData _) =>
                      _controller.onCameraChange(),
                  onMapIdleListener: (MapIdleEventData _) =>
                      _controller.onMapIdle(),
                ),
                Positioned(
                  top: statusBarHeight + kMapModeBarHeight + 16,
                  left: 16,
                  right: 16,
                  child: _controller.locationHandler != null
                      ? LocationWarningWidget(
                          locationPermissionNotifier: _controller
                              .locationHandler!.locationPermissionNotifier,
                          onReloadLocation: () {
                            _controller.locationHandler?.initialize(
                              showDialog: false,
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      MyLocationButton(
                        onTap: () {
                          _controller.locationHandler?.initialize(
                            forceAnimated: true,
                            showDialog: true,
                            shouldShowDoNotShowAgain: false,
                            isMyLocationClicked: true,
                            source: 'route',
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildSatelliteToggle(context),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSatelliteToggle(BuildContext context) {
    return SatelliteToggleButton(
      isActive: _controller.isSatelliteView,
      onToggle: () async {
        await _controller.toggleSatelliteView(isDark: context.isDarkMode);
        if (mounted) setState(() {});
      },
    );
  }
}
