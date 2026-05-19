import 'dart:async';
import 'dart:math' as math;

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/gesture_delegate.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/mapbox/city_albergues_map_controller.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/city_marker_style.dart';
import 'package:camino_ninja_flutter/widgets/satellite_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

class CityAlberguesMap extends StatefulWidget {
  const CityAlberguesMap({
    required this.locations,
    this.onMarkerTap,
    this.routePoints,
    this.altRoutePoints,
    this.zoom = 18,
    this.zoomEnabled = false,
    this.scrollEnabled = false,
    this.mapToolbarEnabled = true,
    this.fallbackTarget,
    this.city,
    this.isFullScreen = true,
    super.key,
  });

  final bool isFullScreen;
  final CityEntity? city;
  final LatLng? fallbackTarget;
  final List<AlbergueLocation> locations;
  final List<LatLng>? routePoints;
  final List<AltRoutePointEntity>? altRoutePoints;
  final double zoom;
  final bool zoomEnabled;
  final bool scrollEnabled;
  final bool mapToolbarEnabled;
  final ValueChanged<AlbergueLocation>? onMarkerTap;

  @override
  State<CityAlberguesMap> createState() => _CityAlberguesMapState();
}

class _CityAlberguesMapState extends State<CityAlberguesMap> {
  CityAlberguesMapController? _controller;

  CityAlberguesMapController _buildController(CityMarkerStyle markerStyle) {
    return CityAlberguesMapController(
      locations: widget.locations,
      routePoints: widget.routePoints,
      altRoutePoints: widget.altRoutePoints,
      city: widget.city,
      onMarkerTap: widget.onMarkerTap,
      isFullScreen: widget.isFullScreen,
      gestureConfig: GestureDelegate(
        scrollEnabled: widget.scrollEnabled,
        pinchToZoomEnabled: widget.zoomEnabled,
        doubleTapToZoomInEnabled: widget.zoomEnabled,
        mapToolbarEnabled: widget.mapToolbarEnabled,
      ),
      cityMarkerStyle: markerStyle,
    );
  }

  @override
  void didUpdateWidget(CityAlberguesMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = _controller;
    if (controller == null) return;
    // `CityAlberguesMap` lives inside the `CityDetailsCubit`'s
    // `BlocBuilder` on `CityDetailsScreen` and rebuilds on
    // search-result / bookmark updates. Without this hop the controller
    // would keep showing the stale dataset captured at construction.
    final didLocationsChange = !identical(
      oldWidget.locations,
      widget.locations,
    );
    final didRoutePointsChange =
        !identical(oldWidget.routePoints, widget.routePoints);
    final didAltRoutePointsChange =
        !identical(oldWidget.altRoutePoints, widget.altRoutePoints);
    if (didLocationsChange ||
        didRoutePointsChange ||
        didAltRoutePointsChange) {
      unawaited(
        controller.updateData(
          locations: widget.locations,
          routePoints: widget.routePoints,
          altRoutePoints: widget.altRoutePoints,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Pre-computes the initial camera so the very first frame is already
  /// fitted to all markers — avoids the visible jump from
  /// `locations.first` to the bounds-fit camera that an `onMapCreated`
  /// `flyTo` would produce, and dodges the reliability problems with
  /// pre-layout `cameraForCoordinatesPadding`/`flyTo` calls.
  CameraOptions _initialCameraOptions() {
    final bounds = MapUtil.cameraForPoints(
      points: widget.locations.map((l) => l.latLng).toList(),
      // Match `_fitBounds` in the controller so the (defensive)
      // post-layout re-fit produces an identical camera.
      zoomConstant: 1.1,
    );
    if (bounds != null) return bounds;

    // Fallback: no markers — center on the supplied fallback (or 0,0)
    // and use the caller-provided zoom. Preview-card variant clamps the
    // zoom down a bit so a missing-locations preview still feels sane.
    final fallback = widget.fallbackTarget ?? const LatLng(0, 0);
    final zoom = widget.isFullScreen
        ? widget.zoom
        : math.max(widget.zoom - 2, 10).toDouble();
    return CameraOptions(
      center: Point(
        coordinates: Position(fallback.longitude, fallback.latitude),
      ),
      zoom: zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final markerStyle = defaultCityMarkerStyle(context);
    _controller ??= _buildController(markerStyle);

    final map = MapWidget(
      styleUri: isDark ? MapboxMapStyle.dark : MapboxMapStyle.light,
      cameraOptions: _initialCameraOptions(),
      onMapCreated: (mapboxMap) =>
          _controller!.onMapCreated(mapboxMap, isDark: isDark),
      onStyleLoadedListener: (_) => _controller!.onStyleLoaded(),
    );

    final wrapped = BlocListener<AppCubit, AppState>(
      listenWhen: (previous, current) => previous.theme != current.theme,
      listener: (context, state) {
        final controller = _controller;
        if (controller == null) return;
        unawaited(
          controller.onThemeChanged(
            isDark: state.theme.isDarkMode,
            markerStyle: defaultCityMarkerStyle(context),
          ),
        );
      },
      child: map,
    );

    if (!widget.isFullScreen) return wrapped;

    return Stack(
      children: [
        wrapped,
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: _SatelliteToggleBinding(
            controller: _controller,
          ),
        ),
      ],
    );
  }
}

/// Stateful binding so the satellite toggle re-renders when the
/// controller's `isSatelliteView` flag flips. The controller is the
/// single source of truth — the button asks it for state and routes
/// taps back through it.
class _SatelliteToggleBinding extends StatefulWidget {
  const _SatelliteToggleBinding({required this.controller});

  final CityAlberguesMapController? controller;

  @override
  State<_SatelliteToggleBinding> createState() =>
      _SatelliteToggleBindingState();
}

class _SatelliteToggleBindingState extends State<_SatelliteToggleBinding> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return SatelliteToggleButton(
      isActive: controller?.isSatelliteView ?? false,
      onToggle: () async {
        if (controller == null) return;
        await controller.toggleSatelliteView(isDark: context.isDarkMode);
        if (mounted) setState(() {});
      },
    );
  }
}

class AlbergueLocation {
  const AlbergueLocation({
    required this.latLng,
    required this.name,
    this.albergueId,
    this.albergue,
  });

  final LatLng latLng;
  final String name;
  final int? albergueId;
  final AlbergueEntity? albergue;
}
