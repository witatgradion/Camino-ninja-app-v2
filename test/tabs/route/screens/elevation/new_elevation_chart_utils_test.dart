import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/new_elevation_chart_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  group('NewElevationChartUtils', () {
    group('findNearestWaypoint', () {
      late List<ChartRoutePoint> routePoints;

      setUp(() {
        // Create a simple route: Santiago de Compostela area
        // Points roughly 100m apart along a straight line
        routePoints = [
          ChartRoutePoint(
            id: 1,
            lat: 42.8805,
            lon: -8.5456,
            ele: 260,
            distance: 0, // 0 km
          ),
          ChartRoutePoint(
            id: 2,
            lat: 42.8815,
            lon: -8.5446,
            ele: 270,
            distance: 0.1, // 0.1 km (100m)
          ),
          ChartRoutePoint(
            id: 3,
            lat: 42.8825,
            lon: -8.5436,
            ele: 280,
            distance: 0.2, // 0.2 km (200m)
          ),
          ChartRoutePoint(
            id: 4,
            lat: 42.8835,
            lon: -8.5426,
            ele: 290,
            distance: 0.3, // 0.3 km (300m)
          ),
          ChartRoutePoint(
            id: 5,
            lat: 42.8845,
            lon: -8.5416,
            ele: 300,
            distance: 0.4, // 0.4 km (400m)
          ),
        ];
      });

      test('returns nearest point when user is exactly on a route point', () {
        // User is exactly on point 3
        final position = Position(
          latitude: 42.8825,
          longitude: -8.5436,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 280,
          altitudeAccuracy: 10,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

        final result =
            NewElevationChartUtils.findNearestWaypoint(position, routePoints);

        expect(result.distance, lessThan(1.0)); // Very close, < 1 meter
        expect(result.routeDistance, equals(0.2)); // 200m along route
        expect(result.elevation, equals(280.0));
      });

      test('returns nearest point when user is between two route points', () {
        // User is between point 2 and point 3
        final position = Position(
          latitude: 42.8820,
          longitude: -8.5441,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 275,
          altitudeAccuracy: 10,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

        final result =
            NewElevationChartUtils.findNearestWaypoint(position, routePoints);

        // Should be close to either point 2 or 3 (within ~70m)
        expect(result.distance, lessThan(100.0));
        // Route distance should be 0.1 or 0.2 (point 2 or 3)
        expect(result.routeDistance, anyOf(equals(0.1), equals(0.2)));
      });

      test('returns first point data when user is before route start', () {
        // User is before the first point
        final position = Position(
          latitude: 42.8795,
          longitude: -8.5466,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 250,
          altitudeAccuracy: 10,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

        final result =
            NewElevationChartUtils.findNearestWaypoint(position, routePoints);

        // First point should be nearest
        expect(result.routeDistance, equals(0.0));
        expect(result.elevation, equals(260.0));
      });

      test('returns last point data when user is after route end', () {
        // User is after the last point
        final position = Position(
          latitude: 42.8855,
          longitude: -8.5406,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 310,
          altitudeAccuracy: 10,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

        final result =
            NewElevationChartUtils.findNearestWaypoint(position, routePoints);

        // Last point should be nearest
        expect(result.routeDistance, equals(0.4));
        expect(result.elevation, equals(300.0));
      });

      test('returns correct distance when user is far from route', () {
        // User is ~1km away from the route
        final position = Position(
          latitude: 42.8905,
          longitude: -8.5356,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 260,
          altitudeAccuracy: 10,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

        final result =
            NewElevationChartUtils.findNearestWaypoint(position, routePoints);

        // Distance should be significant (several hundred meters)
        expect(result.distance, greaterThan(500.0));
      });

    });

    group('maxDistanceFromRoute', () {
      test('constant is set to 5000 meters', () {
        expect(NewElevationChartUtils.maxDistanceFromRoute, equals(5000.0));
      });
    });
  });

  group('ChartRoutePoint', () {
    test('distanceInMeters converts km to meters correctly', () {
      final point = ChartRoutePoint(
        id: 1,
        lat: 42.8805,
        lon: -8.5456,
        ele: 260,
        distance: 5.5, // 5.5 km
      );

      expect(point.distanceInMeters, equals(5500.0)); // 5500 meters
    });

  });

  group('ChartCity', () {
    test('distanceInMeters converts km to meters correctly', () {
      const city = ChartCity(
        name: 'Santiago',
        routePointId: 1,
        distance: 10.5, // 10.5 km
      );

      expect(city.distanceInMeters, equals(10500.0)); // 10500 meters
    });

    test('equality works based on props', () {
      const city1 = ChartCity(
        name: 'Santiago',
        routePointId: 1,
        distance: 10.5,
      );

      const city2 = ChartCity(
        name: 'Santiago',
        routePointId: 1,
        distance: 10.5,
      );

      const city3 = ChartCity(
        name: 'Sarria',
        routePointId: 2,
        distance: 100,
      );

      expect(city1, equals(city2));
      expect(city1, isNot(equals(city3)));
    });

  });

}

