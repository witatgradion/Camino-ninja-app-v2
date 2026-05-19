import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:geolocator/geolocator.dart';

class NewElevationChartUtils {
  // Maximum distance from route to show user location (in meters)
  static const double maxDistanceFromRoute = 5000;

  /// Shared function to find the nearest waypoint from a list of route points.
  ///
  /// Returns:
  /// - distance: Physical distance from user to nearest route point (meters)
  /// - routeDistance: Distance along the route to that point (meters)
  /// - elevation: Elevation of the nearest route point (meters)
  static ({double distance, double routeDistance, double elevation})
      findNearestWaypoint(
    Position currentPosition,
    List<ChartRoutePoint> routePoints,
  ) {
    ChartRoutePoint? nearestPoint;
    var minDistance = double.infinity;

    // Simply find the closest individual route point
    for (var i = 0; i < routePoints.length; i++) {
      final point = routePoints[i];
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        point.lat,
        point.lon,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    }

    return (
      distance: minDistance,
      routeDistance: nearestPoint?.distance ?? 0.0,
      elevation: nearestPoint?.ele ?? 0.0,
    );
  }
}
