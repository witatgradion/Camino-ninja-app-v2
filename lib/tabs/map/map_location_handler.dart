import 'dart:async';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/map/cubit/map_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_starting_point/select_starting_point_screen.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/location_service.dart';
import 'package:camino_ninja_flutter/utils/location_tracker.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/route_distance_calculator.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/location_accuracy_dialog.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/location_service_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geotypes/geotypes.dart' as geotypes;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    hide Position;
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

/// Handler for location-related operations
class MapLocationHandler {
  MapLocationHandler({
    required this.context,
    required this.onLocationStateChanged,
    required this.onDistanceChanged,
    required this.onAltitudeChanged,
    required this.onMyLocationEnabledChanged,
    required this.getMapController,
    required this.getRoutePoints,
    required this.getUnit,
    required this.getRoute,
    required this.getChartRoutePoints,
  });

  final BuildContext context;
  final VoidCallback onLocationStateChanged;
  final void Function(String) onDistanceChanged;
  final void Function(String) onAltitudeChanged;
  final void Function(bool) onMyLocationEnabledChanged;
  final MapboxMap? Function() getMapController;
  final List<RoutePointEntity> Function() getRoutePoints;
  final List<ChartRoutePoint> Function() getChartRoutePoints;
  final UnitEnum Function() getUnit;
  final RouteEntity Function() getRoute;

  final _loadLocationNotifier =
      ValueNotifier(LoadUserLocationStatus.loading);
  final _locationPermissionNotifier =
      ValueNotifier(LocationPermissionStatus.loading);
  LocationTracker? _locationTracker;
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _oldPosition;
  bool _myLocationEnabled = false;

  ValueNotifier<LoadUserLocationStatus>
      get loadLocationNotifier => _loadLocationNotifier;
  ValueNotifier<LocationPermissionStatus>
      get locationPermissionNotifier =>
          _locationPermissionNotifier;
  bool get myLocationEnabled => _myLocationEnabled;

  Future<void> initialize({
    String? source,
    bool forceAnimated = false,
    bool showDialog = true,
    bool shouldShowDoNotShowAgain = true,
    bool isMyLocationClicked = false,
  }) async {
    try {
      final hasPermission =
          await LocationService.checkLocationPermission();
      await Future<void>.delayed(
        const Duration(milliseconds: 250),
      );
      if (!hasPermission) {
        if (isMyLocationClicked) {
          GetIt.instance<IAnalyticsService>().track(
            MyLocationClickedEvent(
              routeId: getRoute().id,
              routeName: getRoute().routeName,
              source: source ?? '',
              hasLocationPermission: false,
            ),
          );
        }
        _myLocationEnabled = false;
        onMyLocationEnabledChanged(false);
        onAltitudeChanged('unknown');
        onDistanceChanged('unknown');
        _loadLocationNotifier.value =
            LoadUserLocationStatus.success;
        _locationPermissionNotifier.value =
            LocationPermissionStatus.serviceDisabled;
        onLocationStateChanged();
        if (showDialog) {
          await showLocationDialog(
            shouldShowDoNotShowAgain:
                shouldShowDoNotShowAgain,
          );
        }
        return;
      }
      _myLocationEnabled = true;
      onMyLocationEnabledChanged(true);
      onLocationStateChanged();
      final isPreciseLocationEnable =
          await LocationService.isPreciseLocationEnable();
      if (!isPreciseLocationEnable) {
        _locationPermissionNotifier.value =
            LocationPermissionStatus.preciseLocationDisabled;
      } else {
        _locationPermissionNotifier.value =
            LocationPermissionStatus.fullGranted;
      }
      await startLocationTracking(
        forceAnimated: forceAnimated,
        isMyLocationClicked: isMyLocationClicked,
        source: source,
      );
    } catch (e) {
      AppLogger.e(
        'Location initialization error',
        tag: 'MapLocationHandler',
        error: e,
      );
    }
  }

  Future<void> showLocationDialog({
    bool shouldShowDoNotShowAgain = true,
  }) async {
    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return LocationServiceDialog(
          shouldShowDoNotShowAgain: shouldShowDoNotShowAgain,
        );
      },
    );
  }

  Future<void> showAccuracyDialog() async {
    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return LocationAccuracyDialog(
          onAllow: startLocationTracking,
          onDeny: (permanentlyDenied) async {
            await GetIt.instance<Repository>()
                .setLocationAccuracyDenied(permanentlyDenied);
            if (permanentlyDenied) {
              await startLocationTracking();
            } else {
              await startLocationTracking(
                locationAccuracyOff: true,
              );
            }
          },
        );
      },
    );
  }

  Future<void> startLocationTracking({
    bool forceAnimated = false,
    bool locationAccuracyOff = false,
    String? source,
    bool isMyLocationClicked = false,
  }) async {
    await _positionStreamSubscription?.cancel();

    _locationTracker ??= LocationTracker();

    Position? currentPosition;

    try {
      currentPosition =
          await _locationTracker!.getCurrentPosition(
        locationAccuracyOff: locationAccuracyOff,
      );
    } on LocationServiceDisabledException {
      await showAccuracyDialog();
    }

    if (currentPosition != null) {
      _loadLocationNotifier.value =
          LoadUserLocationStatus.success;
      handleZoomToUserLocation(
        currentPosition,
        forceAnimated: forceAnimated,
        isMyLocationClicked: isMyLocationClicked,
        source: source,
      );
    }

    _positionStreamSubscription =
        _locationTracker?.locationStream.listen((position) {
      final distance =
          RouteDistanceCalculator.calculateShortestDistance(
        LatLng(position.latitude, position.longitude),
        getRoutePoints()
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList(),
      );
      _loadLocationNotifier.value =
          LoadUserLocationStatus.success;

      final distanceStr =
          RouteDistanceCalculator.formatDistance(
        distance,
        unit: getUnit(),
      );
      onDistanceChanged(distanceStr);
      updateAltitude(position);
    });
  }

  void updateAltitude(Position position) {
    final altitude = position.altitude;

    String altitudeStr;

    if (altitude >= 1000) {
      altitudeStr =
          '${(altitude / 1000).toStringAsFixed(2)} km';
    } else {
      altitudeStr = '${altitude.toStringAsFixed(1)} m';
    }

    if (getUnit() == UnitEnum.imperial) {
      altitudeStr = UnitConverter.displayElevation(
        meters: altitude,
        unit: getUnit(),
      );
    }

    onAltitudeChanged(altitudeStr);
  }

  void handleZoomToUserLocation(
    Position position, {
    bool forceAnimated = false,
    bool isMyLocationClicked = false,
    String? source,
  }) {
    final hasMoved =
        _oldPosition?.latitude != position.latitude ||
            _oldPosition?.longitude != position.longitude;

    final distance =
        RouteDistanceCalculator.calculateShortestDistance(
      LatLng(position.latitude, position.longitude),
      getRoutePoints()
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList(),
    );

    final mapController = getMapController();

    if (forceAnimated) {
      mapController?.flyTo(
        CameraOptions(
          center: Point(
            coordinates: geotypes.Position(
              position.longitude,
              position.latitude,
            ),
          ),
          zoom: 14.4746,
        ),
        MapAnimationOptions(duration: 500),
      );
      final distanceStr =
          RouteDistanceCalculator.formatDistance(
        distance,
        unit: getUnit(),
      );
      onDistanceChanged(distanceStr);
      if (isMyLocationClicked) {
        GetIt.instance<IAnalyticsService>().track(
          MyLocationClickedEvent(
            routeId: getRoute().id,
            routeName: getRoute().routeName,
            source: source ?? '',
            hasLocationPermission: true,
            distanceFromRoute: distanceStr,
          ),
        );
      }
      updateAltitude(position);
      return;
    }

    if (hasMoved) {
      _oldPosition = position;

      if (distance <= maxAllowedDistance) {
        mapController?.flyTo(
          CameraOptions(
            center: Point(
              coordinates: geotypes.Position(
                position.longitude,
                position.latitude,
              ),
            ),
            zoom: 14.4746,
          ),
          MapAnimationOptions(duration: 500),
        );
      } else {
        final chartRoutePoints = getChartRoutePoints();
        if (chartRoutePoints.isNotEmpty) {
          MapUtil.fitBounds(
            mapController: mapController,
            points:
                MapUtil.getLatLngsFromChartRoutePoints(
              chartRoutePoints,
            ),
            zoomConstant: 1.2,
          );
        } else {
          MapUtil.fitBounds(
            mapController: mapController,
            points: MapUtil.getLatLngsFromRoutePoints(
              getRoutePoints(),
            ),
          );
        }
      }
    }

    final distanceStr =
        RouteDistanceCalculator.formatDistance(
      distance,
      unit: getUnit(),
    );
    onDistanceChanged(distanceStr);
    if (isMyLocationClicked) {
      GetIt.instance<IAnalyticsService>().track(
        MyLocationClickedEvent(
          routeId: getRoute().id,
          routeName: getRoute().routeName,
          source: source ?? '',
          distanceFromRoute: distanceStr,
          hasLocationPermission: true,
        ),
      );
    }
    updateAltitude(position);
  }

  void dispose() {
    _loadLocationNotifier.dispose();
    _locationPermissionNotifier.dispose();
    _positionStreamSubscription?.cancel();
    _locationTracker?.dispose();
  }

  Future<void> showAlertDialog(BuildContext context) async {
    final Widget okButton = TextButton(
      child: Text(AppLocalizations.of(context).ok),
      onPressed: () {
        context.pop();
      },
    );

    final alert = AlertDialog(
      content: Text(
        AppLocalizations.of(context).selectRouteForMap,
      ),
      actions: [
        okButton,
      ],
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
