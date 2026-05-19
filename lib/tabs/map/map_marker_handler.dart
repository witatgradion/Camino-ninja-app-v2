import 'dart:typed_data';

import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/city_marker_helper.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/city_marker_style.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/marker_helper.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

/// Handler for marker management (cities, arrows, elevation)
class MapMarkerHandler {
  MapMarkerHandler({required this.context});

  final BuildContext context;
  PointAnnotationManager? _manager;

  // Track annotation IDs by category
  final Map<String, PointAnnotation> _cityAnnotations = {};
  final Map<String, PointAnnotation> _arrowAnnotations = {};
  PointAnnotation? _elevationAnnotation;
  bool _isTouchActive = false;

  // Special cities data
  CityEntity? _firstCity;
  CityEntity? _lastCity;
  CityEntity? _startingCity;
  CityEntity? _destinationCity;
  Uint8List? _cachedElevationIcon;

  void setAnnotationManager(PointAnnotationManager manager) {
    _manager = manager;
  }

  void setFirstCity(CityEntity? city) => _firstCity = city;
  void setLastCity(CityEntity? city) => _lastCity = city;

  void setStartingCity(CityEntity? city) =>
      _startingCity = city;

  void setDestinationCity(CityEntity? city) =>
      _destinationCity = city;

  Future<void> preCreateElevationIcon() async {
    try {
      _cachedElevationIcon =
          await MarkerHelper.createCircleBitmapDescriptor();
    } catch (e) {
      AppLogger.e(
        'Failed to pre-create elevation icon',
        tag: 'MapMarkerHandler',
        error: e,
      );
    }
  }

  Future<void> createFirstLastCityAnnotations() async {
    if (_manager == null) return;
    final currentContext = context;
    if (!currentContext.mounted) return;

    // Collect unique special cities
    final specialCities = <CityEntity>[];
    final cityIds = <int>{};

    void addIfUnique(CityEntity? city) {
      if (city != null && cityIds.add(city.id)) {
        specialCities.add(city);
      }
    }

    addIfUnique(_firstCity);
    addIfUnique(_startingCity);
    addIfUnique(_destinationCity);
    addIfUnique(_lastCity);

    // Remove old city annotations
    for (final ann in _cityAnnotations.values) {
      try {
        await _manager?.delete(ann);
      } catch (_) {}
    }
    _cityAnnotations.clear();

    // Create new ones
    for (final city in specialCities) {
      if (!currentContext.mounted) break;
      try {
        final imageBytes = await CityMarkerHelper.createCityImage(
          city,
          style: mapScreenCityMarkerStyle(currentContext),
        );
        final ann = await _manager?.create(
          PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                city.longitude,
                city.latitude,
              ),
            ),
            image: imageBytes,
            iconSize: 1.0,
            iconAnchor: IconAnchor.BOTTOM,
            symbolSortKey: 3.0,
          ),
        );
        if (ann != null) {
          _cityAnnotations['city_${city.id}'] = ann;
        }
      } catch (e) {
        AppLogger.e(
          'Error creating city annotation',
          tag: 'MapMarkerHandler',
          error: e,
        );
      }
    }
  }

  void updateFirstLastCityMarkersVisibility(double zoom) {
    const minZoomForFirstLastCities = 5.0;
    if (zoom < minZoomForFirstLastCities) {
      _hideCityAnnotations();
    } else {
      if (_cityAnnotations.isEmpty &&
          (_firstCity != null ||
              _lastCity != null ||
              _startingCity != null ||
              _destinationCity != null)) {
        createFirstLastCityAnnotations();
      }
    }
  }

  void _hideCityAnnotations() {
    for (final ann in _cityAnnotations.values) {
      _manager?.delete(ann).catchError((_) {});
    }
    _cityAnnotations.clear();
  }

  Future<void> setArrowAnnotations(
    List<PointAnnotationOptions> options,
  ) async {
    if (_manager == null) return;
    // Remove old
    for (final ann in _arrowAnnotations.values) {
      try {
        await _manager?.delete(ann);
      } catch (_) {}
    }
    _arrowAnnotations.clear();
    // Create new
    for (var i = 0; i < options.length; i++) {
      try {
        final ann = await _manager?.create(options[i]);
        if (ann != null) {
          _arrowAnnotations['arrow_$i'] = ann;
        }
      } catch (_) {}
    }
  }

  Future<void> handleChartTouchDown(
    ChartRoutePoint delta,
  ) async {
    _isTouchActive = true;
    if (_elevationAnnotation != null) {
      _elevationAnnotation!.geometry = Point(
        coordinates: Position(delta.lon, delta.lat),
      );
      try {
        await _manager?.update(_elevationAnnotation!);
      } catch (_) {}
      return;
    }
    final icon = _cachedElevationIcon ??
        await MarkerHelper.createCircleBitmapDescriptor();
    _cachedElevationIcon = icon;
    if (!_isTouchActive) return;
    await _setElevationAnnotation(delta.lat, delta.lon, icon);
    if (!_isTouchActive && _elevationAnnotation != null) {
      try {
        await _manager?.delete(_elevationAnnotation!);
      } catch (_) {}
      _elevationAnnotation = null;
    }
  }

  void handleChartTouchUp() {
    _isTouchActive = false;
    if (_elevationAnnotation != null) {
      _manager
          ?.delete(_elevationAnnotation!)
          .catchError((_) {});
      _elevationAnnotation = null;
    }
  }

  Future<void> handleChartTouchMove(
    ChartRoutePoint delta,
  ) async {
    if (!_isTouchActive) return;
    if (_elevationAnnotation == null) return;
    _elevationAnnotation!.geometry = Point(
      coordinates: Position(delta.lon, delta.lat),
    );
    try {
      await _manager?.update(_elevationAnnotation!);
    } catch (_) {}
  }

  Future<void> _setElevationAnnotation(
    double lat,
    double lon,
    Uint8List icon,
  ) async {
    if (_manager == null) return;
    try {
      _elevationAnnotation = await _manager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(lon, lat),
          ),
          image: icon,
          iconSize: 1.0,
          iconAnchor: IconAnchor.CENTER,
          symbolSortKey: 10.0,
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Error creating elevation annotation',
        tag: 'MapMarkerHandler',
        error: e,
      );
    }
  }

  Future<void> zoomToCity(
    CityEntity city,
    MapboxMap mapController,
  ) async {
    await mapController.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            city.longitude,
            city.latitude,
          ),
        ),
        zoom: 14.0,
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  void clearAnnotations() {
    for (final ann in _cityAnnotations.values) {
      _manager?.delete(ann).catchError((_) {});
    }
    _cityAnnotations.clear();
    for (final ann in _arrowAnnotations.values) {
      _manager?.delete(ann).catchError((_) {});
    }
    _arrowAnnotations.clear();
    if (_elevationAnnotation != null) {
      _manager
          ?.delete(_elevationAnnotation!)
          .catchError((_) {});
      _elevationAnnotation = null;
    }
  }
}
