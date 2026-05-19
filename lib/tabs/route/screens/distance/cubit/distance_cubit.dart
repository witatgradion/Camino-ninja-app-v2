import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/distance/model/closest_city.dart';
import 'package:camino_ninja_flutter/utils/location_service.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'distance_state.dart';

class DistanceCubit extends Cubit<DistanceState> with SafeEmitMixin {
  DistanceCubit({
    required this.selectedRouteId,
    required this.destinationCity,
    required this.unit,
  }) : super(const DistanceState());

  final int selectedRouteId;
  final CityEntity destinationCity;
  final UnitEnum unit;

  final Repository _repository = GetIt.instance<Repository>();

  Future<void> checkLocationAndCalculateDistances({
    bool locationAccuracyOff = false,
  }) async {
    safeEmit(
      state.copyWith(
        isLoading: true,
        permanentlyDenied: false,
        permissionDenied: false,
        accuracyDenied: false,
      ),
    );

    try {
      final permission = await LocationService.getLocationPermission();

      if (permission == NinjaLocationPermission.gpsOff) {
        safeEmit(
          state.copyWith(
            errorMessage: 'Location services are disabled',
            permissionDenied: true,
            isLoading: false,
          ),
        );
        return;
      }

      if (permission == NinjaLocationPermission.deniedForever) {
        safeEmit(
          state.copyWith(
            errorMessage: 'Location permissions permanently denied',
            permissionDenied: true,
            permanentlyDenied: true,
            isLoading: false,
          ),
        );
        return;
      }

      if (permission == NinjaLocationPermission.denied) {
        safeEmit(
          state.copyWith(
            errorMessage: 'Location permission denied',
            permissionDenied: true,
            isLoading: false,
          ),
        );
        return;
      }

      Position? currentPosition;

      try {
        currentPosition = await LocationService.getCurrentPosition(
          locationAccuracyOff: locationAccuracyOff,
        );
      } on LocationServiceDisabledException {
        safeEmit(state.copyWith(accuracyDenied: true));
        return;
      }
      if (currentPosition == null) return;

      await calculateDistances(currentPosition);
    } on LocationServiceDisabledException {
      AppLogger.w(
        'Location services disabled exception',
        tag: 'DistanceCubit',
      );
    } catch (e) {
      AppLogger.e('Error getting location', tag: 'DistanceCubit', error: e);
      safeEmit(
        state.copyWith(
          errorMessage: 'Error getting location: $e',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> calculateDistances(Position currentPosition) async {
    try {
      final route = await _repository.getRouteById(selectedRouteId);
      final cities =
          await _repository.getCitiesByRouteIdFromDb(selectedRouteId);
      final routePoints = await _repository.getRoutePointsByRouteIdFromDb(
        routeId: selectedRouteId,
      );

      // Find closest city
      final closestCity = _findClosestCity(
        currentPosition.latitude,
        currentPosition.longitude,
        cities,
      );

      if (closestCity.distance! >= 50000) {
        // Too far from route
        safeEmit(
          state.copyWith(
            nextCity: closestCity.cityName,
            distanceToNextCity: _formatDistance(closestCity.distance!),
            routeName: route.routeName,
            isTooFar: true,
            isLoading: false,
          ),
        );
        return;
      }

      // Calculate distance from route
      final distanceFromRoute = _calculateDistanceFromRoute(
        currentPosition.latitude,
        currentPosition.longitude,
        routePoints,
      );

      // Get closest route point
      final closestRoutePoint = getClosestRoutePoint(
        currentPosition.latitude,
        currentPosition.longitude,
        routePoints,
      );

      // Find next city
      final nextCityIndex = getNextCityIndex(closestRoutePoint!, cities);

      var nextCity = '';
      var distanceToNextCity = '';
      String? distanceToDestString;

      if (nextCityIndex != null) {
        final nextCityRoutePointId =
            _getRoutePointIdForRoute(nextCityIndex, selectedRouteId);
        if (nextCityRoutePointId != null) {
          final distToNextCity = getDistanceBetweenRoutePoints(
            closestRoutePoint,
            nextCityRoutePointId,
            routePoints,
          );

          final totalDistToNext = distanceFromRoute + distToNextCity!;
          nextCity = nextCityIndex.name;
          distanceToNextCity = _formatDistance(totalDistToNext);
        }
      }

      if (nextCityIndex?.id != destinationCity.id) {
        final destCityRoutePointId =
            _getRoutePointIdForRoute(destinationCity, selectedRouteId);
        if (destCityRoutePointId != null) {
          var distanceToDest = getDistanceBetweenRoutePoints(
            closestRoutePoint,
            destCityRoutePointId,
            routePoints,
          );
          distanceToDest = distanceToDest ?? 0 + distanceFromRoute;
          distanceToDestString = _formatDistance(distanceToDest);
        }
      }

      safeEmit(
        state.copyWith(
          nextCity: nextCity,
          distanceToNextCity: distanceToNextCity,
          distanceFromRoute: _formatDistance(distanceFromRoute),
          destinationCity: destinationCity.name,
          distanceToDestination: distanceToDestString,
          isTooFar: false,
          isLoading: false,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          errorMessage: 'Error calculating distances: $e',
          isLoading: false,
        ),
      );
    }
  }

  int? getClosestRoutePoint(
    double lat,
    double lon,
    List<RoutePointEntity> routePoints,
  ) {
    var shortestDist = 1000000000.0;
    int? routePointId;

    for (var i = 0; i < routePoints.length; i++) {
      final dist = _getHaversineDistance(
        lat,
        lon,
        routePoints[i].latitude,
        routePoints[i].longitude,
      );

      if (dist < shortestDist) {
        shortestDist = dist;
        routePointId = routePoints[i].id;
      }
    }

    return routePointId;
  }

  CityEntity? getNextCityIndex(int fromRoutePoint, List<CityEntity> cities) {
    for (var i = 0; i < cities.length; i++) {
      final cityRoutePointId =
          _getRoutePointIdForRoute(cities[i], selectedRouteId);
      if (cityRoutePointId != null && cityRoutePointId > fromRoutePoint) {
        return cities[i];
      }
    }
    return null;
  }

  double? getDistanceBetweenRoutePoints(
    int routePoint1,
    int routePoint2,
    List<RoutePointEntity> routePoints,
  ) {
    var countStart = false;
    var dist = 0.0;
    var routeLength = 0.0;

    for (var i = 0; i < routePoints.length; i++) {
      if (routePoint1 == routePoints[i].id) {
        countStart = true;
        routeLength = 0;
      } else if (countStart == true && i > 0) {
        dist = _getHaversineDistance(
          routePoints[i - 1].latitude,
          routePoints[i - 1].longitude,
          routePoints[i].latitude,
          routePoints[i].longitude,
        );
        final height =
            (routePoints[i].elevation - routePoints[i - 1].elevation).abs();
        routeLength += math.sqrt((dist * dist) + (height * height));
      }

      if (routePoint2 == routePoints[i].id) {
        return routeLength;
      }
    }

    return null;
  }

  ClosestCity _findClosestCity(
    double lat,
    double lon,
    List<CityEntity> cities,
  ) {
    var shortestDistance = double.maxFinite;
    var cityId = -1;
    var cityName = '';
    int? cityRoutePointId;
    var cityIndex = 0;

    for (var i = 0; i < cities.length; i++) {
      final dist = _getHaversineDistance(
        lat,
        lon,
        cities[i].latitude,
        cities[i].longitude,
      );

      if (dist < shortestDistance) {
        shortestDistance = dist;
        cityId = cities[i].id;
        cityName = cities[i].name;
        cityRoutePointId = _getRoutePointIdForRoute(cities[i], selectedRouteId);
        cityIndex = i;
      }
    }

    return ClosestCity(
      cityId: cityId,
      cityName: cityName,
      cityIndex: cityIndex,
      distance: shortestDistance,
      routePointId: cityRoutePointId,
    );
  }

  double _getHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final phi1 = _toRadians(lat1);
    final phi2 = _toRadians(lat2);
    final deltaPhi = _toRadians(lat2 - lat1);
    final deltaLambda = _toRadians(lon2 - lon1);

    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(deltaLambda / 2) *
            math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return GeoConstants.earthRadiusM * c;
  }

  double _calculateDistanceFromRoute(
    double lat,
    double lon,
    List<RoutePointEntity> routePoints,
  ) {
    var shortestDist = double.maxFinite;
    var shortestDistIndex = 0;

    // Find nearest point
    for (var i = 0; i < routePoints.length; i++) {
      final dist = _getHaversineDistance(
        lat,
        lon,
        routePoints[i].latitude,
        routePoints[i].longitude,
      );

      if (dist < shortestDist) {
        shortestDist = dist;
        shortestDistIndex = i;
      }
    }

    // Create window
    final windowStart =
        (shortestDistIndex - 10).clamp(0, routePoints.length - 1);
    final windowEnd = (shortestDistIndex + 10).clamp(0, routePoints.length);

    // Check segments
    for (var i = windowStart; i < windowEnd - 1; i++) {
      final dist = _getCrossarcDistance(
        routePoints[i].latitude,
        routePoints[i].longitude,
        routePoints[i + 1].latitude,
        routePoints[i + 1].longitude,
        lat,
        lon,
      );

      if (dist < shortestDist) {
        shortestDist = dist;
      }
    }

    return shortestDist.abs();
  }

  double _getCrossarcDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double lat3,
    double lon3,
  ) {
    final phi1 = _toRadians(lat1);
    final lambda1 = _toRadians(lon1);
    final phi2 = _toRadians(lat2);
    final lambda2 = _toRadians(lon2);
    final phi3 = _toRadians(lat3);
    final lambda3 = _toRadians(lon3);

    final bear12 = _getBearingFromRadians(phi1, lambda1, phi2, lambda2);
    final bear13 = _getBearingFromRadians(phi1, lambda1, phi3, lambda3);
    final dis13 = _getDistanceFromRadians(phi1, lambda1, phi3, lambda3);

    var diff = (bear13 - bear12).abs();
    if (diff > math.pi) {
      diff = 2 * math.pi - diff;
    }

    if (diff > (math.pi / 2)) {
      return dis13;
    } else {
      final dxt = math.asin(
            math.sin(dis13 / GeoConstants.earthRadiusM) *
                math.sin(bear13 - bear12),
          ) *
          GeoConstants.earthRadiusM;

      final dis12 = _getDistanceFromRadians(phi1, lambda1, phi2, lambda2);
      final dis14 = math.acos(
            math.cos(dis13 / GeoConstants.earthRadiusM) /
                math.cos(dxt / GeoConstants.earthRadiusM),
          ) *
          GeoConstants.earthRadiusM;

      if (dis14 > dis12) {
        return _getDistanceFromRadians(phi2, lambda2, phi3, lambda3);
      } else {
        return dxt.abs();
      }
    }
  }

  double _getBearingFromRadians(
    double phi1,
    double lambda1,
    double phi2,
    double lambda2,
  ) {
    return math.atan2(
      math.sin(lambda2 - lambda1) * math.cos(phi2),
      math.cos(phi1) * math.sin(phi2) -
          math.sin(phi1) * math.cos(phi2) * math.cos(lambda2 - lambda1),
    );
  }

  double _getDistanceFromRadians(
    double phi1,
    double lambda1,
    double phi2,
    double lambda2,
  ) {
    final a = math.sin((phi2 - phi1) / 2) * math.sin((phi2 - phi1) / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin((lambda2 - lambda1) / 2) *
            math.sin((lambda2 - lambda1) / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return c * GeoConstants.earthRadiusM;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  String _formatDistance(double meters) {
    if (unit == UnitEnum.imperial) {
      return UnitConverter.displayDistance(
        kilometers: meters / 1000,
        unit: unit,
      );
    }
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    } else {
      return '${meters.toStringAsFixed(2)} m';
    }
  }

  int? _getRoutePointIdForRoute(CityEntity city, int routeId) {
    final routePoint = city.routePoints.firstWhere(
      (rp) => rp.routeId == routeId,
      orElse: () => city.routePoints.first,
    );
    return routePoint.id;
  }
}
