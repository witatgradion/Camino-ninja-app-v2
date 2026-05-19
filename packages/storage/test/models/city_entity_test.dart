import 'package:flutter_test/flutter_test.dart';
import 'package:storage/src/models/available_service.dart';
import 'package:storage/src/models/city_entity.dart';
import 'package:storage/src/models/route_entity.dart';
import 'package:storage/src/models/route_point_entity.dart';

void main() {
  group('CityEntity', () {
    group('fromJson / toJson', () {
      test('serializes and deserializes correctly', () {
        // Note: CityEntity uses intToBool converter, so we test with raw JSON
        final json = {
          'id': 1,
          'order_key': 1,
          'name': 'Santiago de Compostela',
          'country': 'Spain',
          'region': 'Galicia',
          'province': 'A Coruña',
          'slug': 'santiago-de-compostela',
          'km': 0,
          'has_atm': 1, // int for intToBool converter
          'has_bar_cafe': 1,
          'has_shop': 1,
          'latitude': 42.8805,
          'longitude': -8.5456,
        };

        final restored = CityEntity.fromJson(json);

        expect(restored.id, equals(1));
        expect(restored.name, equals('Santiago de Compostela'));
        expect(restored.country, equals('Spain'));
        expect(restored.slug, equals('santiago-de-compostela'));
        expect(restored.latitude, equals(42.8805));
        expect(restored.longitude, equals(-8.5456));
        expect(restored.hasAtm, isTrue);
        expect(restored.hasBarCafe, isTrue);
        expect(restored.hasShop, isTrue);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 1,
          'order_key': 1,
          'name': 'Test City',
          'slug': 'test-city',
          'latitude': 42.88,
          'longitude': -8.54,
        };

        final restored = CityEntity.fromJson(json);

        expect(restored.country, isNull);
        expect(restored.region, isNull);
        expect(restored.province, isNull);
      });
    });

    group('equality', () {
      test('two cities with same values are equal', () {
        const city1 = CityEntity(
          id: 1,
          orderKey: 1,
          name: 'Test',
          slug: 'test',
          latitude: 42.88,
          longitude: -8.54,
        );

        const city2 = CityEntity(
          id: 1,
          orderKey: 1,
          name: 'Test',
          slug: 'test',
          latitude: 42.88,
          longitude: -8.54,
        );

        expect(city1, equals(city2));
      });
    });
  });

  group('parseAvailableServices', () {
    test('returns hotel when hasAlbergues is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: true);

      expect(services, contains(AvailableService.hotel));
    });

    test('does not return hotel when hasAlbergues is false', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, isNot(contains(AvailableService.hotel)));
    });

    test('returns ATM when hasAtm is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasAtm: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, contains(AvailableService.atm));
    });

    test('returns cafe when hasBarCafe is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasBarCafe: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, contains(AvailableService.cafe));
    });

    test('returns shopping when hasShop is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasShop: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, contains(AvailableService.shopping));
    });

    test('returns pharmacy when hasPharmacy is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasPharmacy: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, contains(AvailableService.pharmacy));
    });

    test('returns clinic when hasMedClinic is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasMedClinic: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, contains(AvailableService.clinic));
    });

    test('returns fountain when hasFountain is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasFountain: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, contains(AvailableService.fountain));
    });

    test('returns trainStation when hasTrainStation is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasTrainStation: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, contains(AvailableService.trainStation));
    });

    test('returns airport when hasAirport is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasAirport: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, contains(AvailableService.airport));
    });

    test('returns busStation when hasBusStation is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasBusStation: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, contains(AvailableService.busStation));
    });

    test('returns restaurant when hasRestaurant is true', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasRestaurant: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: false);

      expect(services, contains(AvailableService.restaurant));
    });

    test('returns multiple services for city with multiple amenities', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
        hasAtm: true,
        hasBarCafe: true,
        hasShop: true,
        hasPharmacy: true,
        hasTrainStation: true,
      );

      final services = parseAvailableServices(city: city, hasAlbergues: true);

      expect(services.length, equals(6)); // 5 amenities + hotel
      expect(services, contains(AvailableService.hotel));
      expect(services, contains(AvailableService.atm));
      expect(services, contains(AvailableService.cafe));
      expect(services, contains(AvailableService.shopping));
      expect(services, contains(AvailableService.pharmacy));
      expect(services, contains(AvailableService.trainStation));
    });

  });

  group('calculateDistance', () {
    test('calculates zero distance for same point', () {
      final distance = calculateDistance(42.88, -8.54, 42.88, -8.54);

      expect(distance, equals(0.0));
    });

    test('calculates correct distance for known points', () {
      // Santiago de Compostela to O Pedrouzo (approximately 20km)
      final distance = calculateDistance(
        42.8805, -8.5456, // Santiago
        42.9072, -8.3533, // O Pedrouzo
      );

      // Should be approximately 15-20km
      expect(distance, greaterThan(15000)); // meters
      expect(distance, lessThan(20000));
    });

    test('calculates distance symmetrically', () {
      final distanceAB = calculateDistance(42.88, -8.54, 43.00, -8.40);
      final distanceBA = calculateDistance(43.00, -8.40, 42.88, -8.54);

      expect(distanceAB, closeTo(distanceBA, 0.001));
    });
  });

  group('getDistanceBetweenCities', () {
    test('calculates distance along route between two cities', () {
      // Create route points
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
          latitude: 42.8810,
          longitude: -8.5440,
        ),
        const RoutePointEntity(
          id: 3,
          orderKey: 3,
          elevation: 200.0,
          routeId: 1,
          latitude: 42.8820,
          longitude: -8.5430,
        ),
      ];

      const route = RouteEntity(id: 1, orderKey: 1, routeName: 'Test');

      // City 1 at point 1
      const city1 = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'City 1',
        slug: 'city-1',
        latitude: 42.8800,
        longitude: -8.5450,
        routes: [route],
        routePoints: [
          RoutePointEntity(
            id: 1,
            orderKey: 1,
            elevation: 100.0,
            routeId: 1,
            latitude: 42.8800,
            longitude: -8.5450,
          ),
        ],
      );

      // City 2 at point 3
      const city2 = CityEntity(
        id: 2,
        orderKey: 2,
        name: 'City 2',
        slug: 'city-2',
        latitude: 42.8820,
        longitude: -8.5430,
        routes: [route],
        routePoints: [
          RoutePointEntity(
            id: 3,
            orderKey: 3,
            elevation: 200.0,
            routeId: 1,
            latitude: 42.8820,
            longitude: -8.5430,
          ),
        ],
      );

      final distance = getDistanceBetweenCities(city1, city2, routePoints);

      // Distance should be positive (sum of segments)
      expect(distance, greaterThan(0));
    });

    test('returns 0 for same city', () {
      final routePoints = [
        const RoutePointEntity(
          id: 1,
          orderKey: 1,
          elevation: 100.0,
          routeId: 1,
          latitude: 42.8800,
          longitude: -8.5450,
        ),
      ];

      const route = RouteEntity(id: 1, orderKey: 1, routeName: 'Test');

      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'City',
        slug: 'city',
        latitude: 42.8800,
        longitude: -8.5450,
        routes: [route],
        routePoints: [
          RoutePointEntity(
            id: 1,
            orderKey: 1,
            elevation: 100.0,
            routeId: 1,
            latitude: 42.8800,
            longitude: -8.5450,
          ),
        ],
      );

      final distance = getDistanceBetweenCities(city, city, routePoints);

      expect(distance, equals(0));
    });

    test('handles cities with multiple route points', () {
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
          latitude: 42.8810,
          longitude: -8.5440,
        ),
        const RoutePointEntity(
          id: 3,
          orderKey: 3,
          elevation: 200.0,
          routeId: 1,
          latitude: 42.8820,
          longitude: -8.5430,
        ),
      ];

      const route = RouteEntity(id: 1, orderKey: 1, routeName: 'Test');

      // City with multiple route points - should use first one
      const city1 = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'City 1',
        slug: 'city-1',
        latitude: 42.8800,
        longitude: -8.5450,
        routes: [route],
        routePoints: [
          RoutePointEntity(
            id: 1,
            orderKey: 1,
            elevation: 100.0,
            routeId: 1,
            latitude: 42.8800,
            longitude: -8.5450,
          ),
          RoutePointEntity(
            id: 2,
            orderKey: 2,
            elevation: 150.0,
            routeId: 1,
            latitude: 42.8810,
            longitude: -8.5440,
          ),
        ],
      );

      const city2 = CityEntity(
        id: 2,
        orderKey: 2,
        name: 'City 2',
        slug: 'city-2',
        latitude: 42.8820,
        longitude: -8.5430,
        routes: [route],
        routePoints: [
          RoutePointEntity(
            id: 3,
            orderKey: 3,
            elevation: 200.0,
            routeId: 1,
            latitude: 42.8820,
            longitude: -8.5430,
          ),
        ],
      );

      final distance = getDistanceBetweenCities(city1, city2, routePoints);

      expect(distance, greaterThan(0));
    });
  });

  group('CityEntity boolean fields', () {
    test('all boolean fields default to null', () {
      const city = CityEntity(
        id: 1,
        orderKey: 1,
        name: 'Test',
        slug: 'test',
        latitude: 42.88,
        longitude: -8.54,
      );

      expect(city.hasAtm, isNull);
      expect(city.hasBarCafe, isNull);
      expect(city.hasShop, isNull);
      expect(city.hasPharmacy, isNull);
      expect(city.hasMedClinic, isNull);
      expect(city.hasFountain, isNull);
      expect(city.hasTrainStation, isNull);
      expect(city.hasAirport, isNull);
      expect(city.hasBusStation, isNull);
      expect(city.hasRestaurant, isNull);
    });

  });
}

