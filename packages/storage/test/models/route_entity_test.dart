import 'package:flutter_test/flutter_test.dart';
import 'package:storage/src/models/city_entity.dart';
import 'package:storage/src/models/route_entity.dart';
import 'package:storage/src/models/route_point_entity.dart';

void main() {
  group('RouteEntity', () {
    group('calculateRouteStatistics', () {
      late RouteEntity route;

      setUp(() {
        route = const RouteEntity(
          id: 1,
          orderKey: 1,
          routeName: 'Camino Frances',
          routeSubName: 'Main Route',
        );
      });

      test('calculates elevation gain correctly for ascending route', () {
        final routePoints = [
          const RoutePointEntity(
            id: 1,
            orderKey: 1,
            elevation: 100.0,
            routeId: 1,
            latitude: 42.8800,
            longitude: -8.5450,
          ),
          const RoutePointEntity(
            id: 2,
            orderKey: 2,
            elevation: 150.0,
            routeId: 1,
            latitude: 42.8801,
            longitude: -8.5451,
          ),
          const RoutePointEntity(
            id: 3,
            orderKey: 3,
            elevation: 200.0,
            routeId: 1,
            latitude: 42.8802,
            longitude: -8.5452,
          ),
        ];

        final stats = route.calculateRouteStatistics(
          currentRoutePoints: routePoints,
        );

        expect(stats.elevationGain, equals(100)); // 50 + 50 = 100
        expect(stats.elevationLoss, equals(0));
        expect(stats.minElevation, equals(100));
        expect(stats.maxElevation, equals(200));
      });

      test('calculates elevation loss correctly for descending route', () {
        final routePoints = [
          const RoutePointEntity(
            id: 1,
            orderKey: 1,
            elevation: 500.0,
            routeId: 1,
            latitude: 42.8800,
            longitude: -8.5450,
          ),
          const RoutePointEntity(
            id: 2,
            orderKey: 2,
            elevation: 400.0,
            routeId: 1,
            latitude: 42.8801,
            longitude: -8.5451,
          ),
          const RoutePointEntity(
            id: 3,
            orderKey: 3,
            elevation: 300.0,
            routeId: 1,
            latitude: 42.8802,
            longitude: -8.5452,
          ),
        ];

        final stats = route.calculateRouteStatistics(
          currentRoutePoints: routePoints,
        );

        expect(stats.elevationGain, equals(0));
        expect(stats.elevationLoss, equals(200)); // 100 + 100 = 200
        expect(stats.minElevation, equals(300));
        expect(stats.maxElevation, equals(500));
      });

      test('calculates both gain and loss for undulating route', () {
        final routePoints = [
          const RoutePointEntity(
            id: 1,
            orderKey: 1,
            elevation: 100.0,
            routeId: 1,
            latitude: 42.8800,
            longitude: -8.5450,
          ),
          const RoutePointEntity(
            id: 2,
            orderKey: 2,
            elevation: 200.0, // +100
            routeId: 1,
            latitude: 42.8801,
            longitude: -8.5451,
          ),
          const RoutePointEntity(
            id: 3,
            orderKey: 3,
            elevation: 150.0, // -50
            routeId: 1,
            latitude: 42.8802,
            longitude: -8.5452,
          ),
          const RoutePointEntity(
            id: 4,
            orderKey: 4,
            elevation: 300.0, // +150
            routeId: 1,
            latitude: 42.8803,
            longitude: -8.5453,
          ),
        ];

        final stats = route.calculateRouteStatistics(
          currentRoutePoints: routePoints,
        );

        expect(stats.elevationGain, equals(250)); // 100 + 150 = 250
        expect(stats.elevationLoss, equals(50)); // 50
        expect(stats.minElevation, equals(100));
        expect(stats.maxElevation, equals(300));
      });

      test('calculates distance in kilometers', () {
        // Two points approximately 1.11 km apart (0.01 degrees at equator ~ 1.11km)
        final routePoints = [
          const RoutePointEntity(
            id: 1,
            orderKey: 1,
            elevation: 100.0,
            routeId: 1,
            latitude: 0.0,
            longitude: 0.0,
          ),
          const RoutePointEntity(
            id: 2,
            orderKey: 2,
            elevation: 100.0,
            routeId: 1,
            latitude: 0.01,
            longitude: 0.0,
          ),
        ];

        final stats = route.calculateRouteStatistics(
          currentRoutePoints: routePoints,
        );

        // Distance should be approximately 1.11 km (some variance due to Haversine formula)
        expect(stats.distance, greaterThan(1.0));
        expect(stats.distance, lessThan(1.2));
      });

      test('filters route points by starting and destination cities', () {
        // Create a longer route
        final routePoints = [
          const RoutePointEntity(
            id: 1,
            orderKey: 1,
            elevation: 100.0,
            routeId: 1,
            latitude: 42.8800,
            longitude: -8.5450,
          ),
          const RoutePointEntity(
            id: 2,
            orderKey: 2,
            elevation: 200.0,
            routeId: 1,
            latitude: 42.8801,
            longitude: -8.5451,
          ),
          const RoutePointEntity(
            id: 3,
            orderKey: 3,
            elevation: 300.0,
            routeId: 1,
            latitude: 42.8802,
            longitude: -8.5452,
          ),
          const RoutePointEntity(
            id: 4,
            orderKey: 4,
            elevation: 400.0,
            routeId: 1,
            latitude: 42.8803,
            longitude: -8.5453,
          ),
          const RoutePointEntity(
            id: 5,
            orderKey: 5,
            elevation: 500.0,
            routeId: 1,
            latitude: 42.8804,
            longitude: -8.5454,
          ),
        ];

        // Starting city at point 2, destination city at point 4
        const startCity = CityEntity(
          id: 1,
          orderKey: 1,
          name: 'Start City',
          slug: 'start-city',
          latitude: 42.8801,
          longitude: -8.5451,
          routePoints: [
            RoutePointEntity(
              id: 2,
              orderKey: 2,
              elevation: 200.0,
              routeId: 1,
              latitude: 42.8801,
              longitude: -8.5451,
            ),
          ],
          routes: [
            RouteEntity(id: 1, orderKey: 1, routeName: 'Test'),
          ],
        );

        const destCity = CityEntity(
          id: 2,
          orderKey: 2,
          name: 'Dest City',
          slug: 'dest-city',
          latitude: 42.8803,
          longitude: -8.5453,
          routePoints: [
            RoutePointEntity(
              id: 4,
              orderKey: 4,
              elevation: 400.0,
              routeId: 1,
              latitude: 42.8803,
              longitude: -8.5453,
            ),
          ],
          routes: [
            RouteEntity(id: 1, orderKey: 1, routeName: 'Test'),
          ],
        );

        final stats = route.calculateRouteStatistics(
          currentRoutePoints: routePoints,
          startingCity: startCity,
          destCity: destCity,
        );

        // Should only calculate for points 2, 3, 4 (elevation 200, 300, 400)
        expect(stats.minElevation, equals(200));
        expect(stats.maxElevation, equals(400));
        expect(stats.elevationGain, equals(200)); // 100 + 100
        expect(stats.elevationLoss, equals(0));
      });

    });

    group('fromJson / toJson', () {
      test('serializes and deserializes correctly', () {
        const original = RouteEntity(
          id: 1,
          orderKey: 1,
          routeName: 'Camino Frances',
          routeSubName: 'Main Route',
          legendColor: '#FF0000',
        );

        final json = original.toJson();
        final restored = RouteEntity.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.orderKey, equals(original.orderKey));
        expect(restored.routeName, equals(original.routeName));
        expect(restored.routeSubName, equals(original.routeSubName));
        expect(restored.legendColor, equals(original.legendColor));
      });

      test('handles null optional fields', () {
        const original = RouteEntity(
          id: 1,
          orderKey: 1,
          routeName: 'Test Route',
        );

        final json = original.toJson();
        final restored = RouteEntity.fromJson(json);

        expect(restored.routeSubName, isNull);
        expect(restored.legendColor, isNull);
      });
    });

    group('equality', () {
      test('two routes with same values are equal', () {
        const route1 = RouteEntity(
          id: 1,
          orderKey: 1,
          routeName: 'Test',
        );

        const route2 = RouteEntity(
          id: 1,
          orderKey: 1,
          routeName: 'Test',
        );

        expect(route1, equals(route2));
      });

      test('two routes with different values are not equal', () {
        const route1 = RouteEntity(
          id: 1,
          orderKey: 1,
          routeName: 'Test 1',
        );

        const route2 = RouteEntity(
          id: 2,
          orderKey: 2,
          routeName: 'Test 2',
        );

        expect(route1, isNot(equals(route2)));
      });
    });
  });
}

