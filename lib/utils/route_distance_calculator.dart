import 'dart:math';

import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:core/core.dart';
import 'package:latlong2/latlong.dart';

class RouteDistanceCalculator {

  /// Calculates the shortest distance from a point to a route
  static double calculateShortestDistance(
      LatLng currentPosition,
      List<LatLng> routeCoordinates,
      ) {
    if (routeCoordinates.isEmpty) return 0;

    var shortestDist = 1000000000.0;
    var shortestDistIndex = -1;

    // Find nearest point
    for (var i = 0; i < routeCoordinates.length; i++) {
      final dist = _getHaversineDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        routeCoordinates[i].latitude,
        routeCoordinates[i].longitude,
      );

      if (dist < shortestDist) {
        shortestDist = dist;
        shortestDistIndex = i;
      }
    }

    // Create window around nearest point
    final windowStart = (shortestDistIndex - 10).clamp(0, routeCoordinates.length - 1);
    final windowEnd = (shortestDistIndex + 10).clamp(0, routeCoordinates.length);

    // Check segments within window
    for (var i = windowStart; i < windowEnd - 1; i++) {
      final dist = _getCrossArcDistance(
        routeCoordinates[i].latitude,
        routeCoordinates[i].longitude,
        routeCoordinates[i + 1].latitude,
        routeCoordinates[i + 1].longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      if (dist < shortestDist) {
        shortestDist = dist;
      }
    }

    return shortestDist;
  }

  /// Calculates distance between two points using Haversine formula
  static double _getHaversineDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    // Convert latitude and longitude to radians
    final phi1 = _toRadians(lat1);
    final phi2 = _toRadians(lat2);
    final deltaPhi = _toRadians(lat2 - lat1);
    final deltaLambda = _toRadians(lon2 - lon1);

    // Haversine formula
    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return GeoConstants.earthRadiusM * c;
  }


  static double _toRadians(double degree) => degree * pi / 180;

  static double _getCrossArcDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      double lat3,
      double lon3,
      ) {
    // Convert all coordinates to radians
    final phi1 = _toRadians(lat1);
    final lambda1 = _toRadians(lon1);
    final phi2 = _toRadians(lat2);
    final lambda2 = _toRadians(lon2);
    final phi3 = _toRadians(lat3);
    final lambda3 = _toRadians(lon3);

    // Calculate bearings
    final bearing12 = _getBearingFromRadians(phi1, lambda1, phi2, lambda2);
    final bearing13 = _getBearingFromRadians(phi1, lambda1, phi3, lambda3);

    // Calculate distances
    final distance13 = _getDistanceFromRadians(phi1, lambda1, phi3, lambda3);

    // Calculate difference in bearings
    var diffBearing = (bearing13 - bearing12).abs();
    if (diffBearing > pi) {
      diffBearing = 2 * pi - diffBearing;
    }

    // Check if relative bearing is obtuse
    if (diffBearing > (pi / 2)) {
      return distance13;
    } else {
      // Calculate cross-track distance
      final crossTrackDistance = asin(
        sin(distance13 / GeoConstants.earthRadiusM) *
            sin(bearing13 - bearing12),
      ) *
          GeoConstants.earthRadiusM;

      // Check if point is beyond the arc
      final distance12 = _getDistanceFromRadians(phi1, lambda1, phi2, lambda2);
      final distance14 = acos(
        cos(distance13 / GeoConstants.earthRadiusM) /
            cos(crossTrackDistance / GeoConstants.earthRadiusM),
      ) *
          GeoConstants.earthRadiusM;

      if (distance14 > distance12) {
        return _getDistanceFromRadians(phi2, lambda2, phi3, lambda3);
      } else {
        return crossTrackDistance.abs();
      }
    }
  }

  /// Calculates bearing between two points using radians
  static double _getBearingFromRadians(
      double phi1,
      double lambda1,
      double phi2,
      double lambda2,
      ) {
    return atan2(
        sin(lambda2 - lambda1) * cos(phi2),
        cos(phi1) * sin(phi2) -
            sin(phi1) * cos(phi2) * cos(lambda2 - lambda1),
    );
  }

  /// Calculates distance between two points using radians
  static double _getDistanceFromRadians(
      double phi1,
      double lambda1,
      double phi2,
      double lambda2,
      ) {
    final a = sin((phi2 - phi1) / 2) * sin((phi2 - phi1) / 2) +
        cos(phi1) * cos(phi2) *
            sin((lambda2 - lambda1) / 2) * sin((lambda2 - lambda1) / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return c * GeoConstants.earthRadiusM;
  }

  static String formatDistance(
    double meters, {
    UnitEnum unit = UnitEnum.metric,
  }) {
    if (unit == UnitEnum.imperial) {
      return UnitConverter.displayDistance(
        kilometers: meters / 1000,
        unit: unit,
      );
    }

    if (meters >= 1000) {
      final distanceInKm = meters / 1000;
      if (distanceInKm > 20) {
        return '${distanceInKm.toInt()} km';
      }
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${meters.toInt()} m';
    }
  }
}
