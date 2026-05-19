import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/journey_planner/cubit/journey_planner_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class _MockPathFinder extends Mock implements RoutePathFinder {}

class _MockJunctionService extends Mock implements JunctionService {}

class _MockAppPreferences extends Mock implements AppPreferences {}

class _RecordingAnalyticsService implements IAnalyticsService {
  final List<({String name, Map<String, dynamic> params})> tracked = [];

  @override
  void trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) {
    tracked.add((name: eventName, params: parameters ?? const {}));
  }

  @override
  void trackScreen({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) {}

  @override
  void setUserId({String? userId}) {}

  @override
  void setUserProperties(Map<String, dynamic> properties) {}

  @override
  Future<void> flush() async {}
}

CityEntity _city(int id, {String? name}) => CityEntity(
      id: id,
      orderKey: id,
      name: name ?? 'City $id',
      slug: 'city-$id',
      latitude: 0,
      longitude: 0,
    );

RouteEntity _route(int id, {String? name}) => RouteEntity(
      id: id,
      orderKey: id,
      routeName: name ?? 'Route $id',
    );

RouteGraph _graph({
  required List<RouteEntity> routes,
  Map<int, List<RouteConnection>> adjacency = const {},
  Map<int, Set<int>> cityRouteIndex = const {},
  Map<int, Map<int, int>> routeCityIndex = const {},
}) {
  return RouteGraph(
    adjacency: adjacency,
    routeIndex: {for (final r in routes) r.id: r},
    cityRouteIndex: cityRouteIndex,
    routeCityIndex: routeCityIndex,
  );
}

JourneyOption _option({
  required List<int> routeIds,
  required List<int> junctionCityIds,
  required int startCityId,
  required int endCityId,
  double? distanceKm,
}) {
  return JourneyOption(
    path: RoutePath(
      routeIds: routeIds,
      junctionCityIds: junctionCityIds,
    ),
    routes: routeIds.map(_route).toList(),
    junctionCities: junctionCityIds.map(_city).toList(),
    startCityId: startCityId,
    endCityId: endCityId,
    startCityName: 'Start',
    endCityName: 'End',
    estimatedDistanceKm: distanceKm,
  );
}

void main() {
  late _MockPathFinder pathFinder;
  late _MockJunctionService junctionService;
  late _MockAppPreferences appPreferences;
  late _RecordingAnalyticsService analytics;

  setUpAll(() {
    registerFallbackValue(0.0);
  });

  setUp(() {
    pathFinder = _MockPathFinder();
    junctionService = _MockJunctionService();
    appPreferences = _MockAppPreferences();
    analytics = _RecordingAnalyticsService();

    // Defaults that most tests don't care about.
    when(() => junctionService.initialize()).thenAnswer((_) async {});
    when(() => appPreferences.getJunctionMaxDistanceMeters())
        .thenAnswer((_) async => null);
    when(() => appPreferences.setJunctionMaxDistanceMeters(any()))
        .thenAnswer((_) async {});
    when(() => pathFinder.setJunctionMaxDistanceMeters(any()))
        .thenAnswer((_) {});

    GetIt.instance
      ..registerSingleton<RoutePathFinder>(pathFinder)
      ..registerSingleton<JunctionService>(junctionService)
      ..registerSingleton<AppPreferences>(appPreferences)
      ..registerSingleton<IAnalyticsService>(analytics);
  });

  tearDown(GetIt.instance.reset);

  /// Stubs a graph with two routes that share city 20 as a junction:
  /// - Route 1 cities: [10, 20, 30] (city 10 is the future start)
  /// - Route 2 cities: [20, 200, 300]
  /// - Adjacency: route 1 -> route 2 at city 20 (idx 1 on route 1)
  ///
  /// Returns the cubit after a successful [init].
  Future<JourneyPlannerCubit> primeAtStartCitySelection({
    bool withJunction = true,
  }) async {
    final route1 = _route(1);
    final route2 = _route(2);
    final route1Cities = [_city(10), _city(20), _city(30)];
    final route2Cities = [_city(20), _city(200), _city(300)];

    when(() => junctionService.getCitiesForRoute(1))
        .thenAnswer((_) async => route1Cities);
    when(() => junctionService.getCitiesForRoute(2))
        .thenAnswer((_) async => route2Cities);

    final adjacency = <int, List<RouteConnection>>{};
    if (withJunction) {
      adjacency[1] = [
        const RouteConnection(
          targetRouteId: 2,
          junctionCityId: 20,
          junctionCityName: 'City 20',
          junctionIndexOnSource: 1,
        ),
      ];
    }

    when(pathFinder.buildGraph).thenAnswer(
      (_) async => _graph(
        routes: [route1, route2],
        adjacency: adjacency,
        cityRouteIndex: {
          10: {1},
          20: {1, 2},
          30: {1},
          200: {2},
          300: {2},
        },
        routeCityIndex: {
          1: {10: 0, 20: 1, 30: 2},
          2: {20: 0, 200: 1, 300: 2},
        },
      ),
    );

    final cubit = JourneyPlannerCubit();
    await cubit.init();
    expect(cubit.state.status, JourneyPlannerStatus.startCitySelection);
    return cubit;
  }

  group('init', () {
    test('emits [loadingCities, startCitySelection] on success', () async {
      final cubit = await primeAtStartCitySelection();

      expect(cubit.state.allCities.map((c) => c.id), [10, 20, 200, 30, 300]);
      // allCities is alphabetically sorted by name ("City 10", "City 20", ...).
      // ID order above reflects "City 10", "City 20", "City 200", "City 30",
      // "City 300" — the default string comparison.
      expect(cubit.state.allRoutes.map((r) => r.id), [1, 2]);
      expect(cubit.state.cityRouteIds[20], {1, 2});
      expect(cubit.state.cityRouteIds[10], {1});
      expect(cubit.state.cityRouteNames[20], hasLength(2));
    });

    test('emits failure when buildGraph throws', () async {
      when(() => junctionService.initialize()).thenAnswer((_) async {});
      when(pathFinder.buildGraph)
          .thenAnswer((_) async => throw StateError('boom'));

      final cubit = JourneyPlannerCubit();
      await cubit.init();

      expect(cubit.state.status, JourneyPlannerStatus.failure);
      expect(cubit.state.errorMessage, isNotEmpty);
    });
  });

  group('selectStartCity', () {
    test(
      'emits destinationCitySelection with direct cities only when no '
      'junctions exist',
      () async {
        final cubit = await primeAtStartCitySelection(withJunction: false);

        await cubit.selectStartCity(_city(10));

        expect(
          cubit.state.status,
          JourneyPlannerStatus.destinationCitySelection,
        );
        expect(cubit.state.startCity!.id, 10);
        // Cities AFTER city 10 on route 1.
        expect(cubit.state.directlyReachableCityIds, {20, 30});
        expect(cubit.state.viaJunctionReachableCityIds, isEmpty);
        expect(
          analytics.tracked.map((e) => e.name),
          contains('journey_planner_start_city_selected'),
        );
      },
    );

    test(
      'emits destinationCitySelection with via-junction cities when a '
      'forward junction exists',
      () async {
        final cubit = await primeAtStartCitySelection();

        await cubit.selectStartCity(_city(10));

        expect(
          cubit.state.status,
          JourneyPlannerStatus.destinationCitySelection,
        );
        // City 20 is the junction (also direct on route 1).
        // City 30 comes after city 10 on route 1 (direct).
        expect(cubit.state.directlyReachableCityIds, {20, 30});
        // Route 2 is reachable via the junction at city 20; cities 200
        // and 300 lie on it (excluding city 20 which is direct).
        expect(cubit.state.viaJunctionReachableCityIds, {200, 300});
        expect(
          cubit.state.reachabilityOf(20),
          CityReachability.direct,
        );
        expect(
          cubit.state.reachabilityOf(200),
          CityReachability.viaJunction,
        );
        expect(
          cubit.state.reachabilityOf(999),
          CityReachability.notReachable,
        );
      },
    );
  });

  group('selectDestinationCity', () {
    test(
      'emits [loadingRoutes, routeOptions] with options on success',
      () async {
        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));

        final options = [
          _option(
            routeIds: [1],
            junctionCityIds: const [],
            startCityId: 10,
            endCityId: 200,
          ),
          _option(
            routeIds: [1, 2],
            junctionCityIds: [20],
            startCityId: 10,
            endCityId: 200,
          ),
        ];
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: 10,
            endCityId: 200,
          ),
        ).thenAnswer((_) async => options);

        await cubit.selectDestinationCity(_city(200));

        expect(cubit.state.status, JourneyPlannerStatus.routeOptions);
        expect(cubit.state.endCity!.id, 200);
        expect(cubit.state.journeyOptions, hasLength(2));
        expect(
          analytics.tracked.map((e) => e.name),
          contains('journey_planner_destination_selected'),
        );
      },
    );

    test(
      'emits routeOptions with an empty list when no destinations are '
      'reachable',
      () async {
        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));

        when(
          () => pathFinder.findJourneyOptions(
            startCityId: any(named: 'startCityId'),
            endCityId: any(named: 'endCityId'),
          ),
        ).thenAnswer((_) async => const <JourneyOption>[]);

        await cubit.selectDestinationCity(_city(999));

        expect(cubit.state.status, JourneyPlannerStatus.routeOptions);
        expect(cubit.state.journeyOptions, isEmpty);
        expect(cubit.state.endCity!.id, 999);
      },
    );

    test('emits failure when findJourneyOptions throws', () async {
      final cubit = await primeAtStartCitySelection();
      await cubit.selectStartCity(_city(10));

      when(
        () => pathFinder.findJourneyOptions(
          startCityId: any(named: 'startCityId'),
          endCityId: any(named: 'endCityId'),
        ),
      ).thenAnswer((_) async => throw StateError('boom'));

      await cubit.selectDestinationCity(_city(200));

      expect(cubit.state.status, JourneyPlannerStatus.failure);
      expect(cubit.state.errorMessage, isNotEmpty);
    });
  });

  group('buildTrailFromOption', () {
    test(
      'returns a single-segment MultiRouteTrail for a direct option and '
      'fires route_option_selected with option_type=direct',
      () async {
        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: 10,
            endCityId: 30,
          ),
        ).thenAnswer(
          (_) async => [
            _option(
              routeIds: [1],
              junctionCityIds: const [],
              startCityId: 10,
              endCityId: 30,
            ),
          ],
        );
        await cubit.selectDestinationCity(_city(30));

        analytics.tracked.clear();

        final option = cubit.state.journeyOptions.first;
        final trail = await cubit.buildTrailFromOption(option);

        expect(trail, isNotNull);
        expect(trail!.segments, hasLength(1));
        expect(trail.segments.first.routeId, 1);
        expect(trail.segments.first.cityIds, [10, 20, 30]);
        expect(trail.segments.first.junctionCityId, isNull);

        final event = analytics.tracked.firstWhere(
          (e) => e.name == 'journey_planner_route_option_selected',
        );
        expect(event.params['option_type'], 'direct');
        expect(event.params['position_index'], 0);
      },
    );

    test(
      'returns a two-segment MultiRouteTrail for a via_junction option',
      () async {
        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: 10,
            endCityId: 200,
          ),
        ).thenAnswer(
          (_) async => [
            _option(
              routeIds: [1, 2],
              junctionCityIds: [20],
              startCityId: 10,
              endCityId: 200,
            ),
          ],
        );
        await cubit.selectDestinationCity(_city(200));

        analytics.tracked.clear();

        final option = cubit.state.journeyOptions.first;
        final trail = await cubit.buildTrailFromOption(option);

        expect(trail, isNotNull);
        expect(trail!.segments, hasLength(2));
        expect(trail.segments[0].routeId, 1);
        expect(trail.segments[0].cityIds, [10, 20]);
        expect(trail.segments[0].junctionCityId, isNull);
        expect(trail.segments[1].routeId, 2);
        expect(trail.segments[1].cityIds, [20, 200]);
        expect(trail.segments[1].junctionCityId, 20);

        final event = analytics.tracked.firstWhere(
          (e) => e.name == 'journey_planner_route_option_selected',
        );
        expect(event.params['option_type'], 'via_junction');
      },
    );

    test(
      'fires route_option_selected with option_type=multi_trail for a '
      'two-junction option',
      () async {
        when(() => junctionService.getCitiesForRoute(3)).thenAnswer(
          (_) async => [_city(300), _city(400)],
        );

        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: 10,
            endCityId: 400,
          ),
        ).thenAnswer(
          (_) async => [
            _option(
              routeIds: [1, 2, 3],
              junctionCityIds: [20, 300],
              startCityId: 10,
              endCityId: 400,
            ),
          ],
        );
        await cubit.selectDestinationCity(_city(400));

        analytics.tracked.clear();

        final option = cubit.state.journeyOptions.first;
        final trail = await cubit.buildTrailFromOption(option);

        expect(trail, isNotNull);
        expect(trail!.segments, hasLength(3));

        final event = analytics.tracked.firstWhere(
          (e) => e.name == 'journey_planner_route_option_selected',
        );
        expect(event.params['option_type'], 'multi_trail');
      },
    );

    test(
      'returns null when a segment boundary city is not on its route',
      () async {
        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));

        // Option claims to end at city 999, which is NOT on route 1.
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: 10,
            endCityId: 999,
          ),
        ).thenAnswer(
          (_) async => [
            _option(
              routeIds: [1],
              junctionCityIds: const [],
              startCityId: 10,
              endCityId: 999,
            ),
          ],
        );
        await cubit.selectDestinationCity(_city(999));

        final option = cubit.state.journeyOptions.first;
        final trail = await cubit.buildTrailFromOption(option);

        expect(trail, isNull);
      },
    );

    test('position_index reflects the option list ordering', () async {
      final cubit = await primeAtStartCitySelection();
      await cubit.selectStartCity(_city(10));
      when(
        () => pathFinder.findJourneyOptions(
          startCityId: 10,
          endCityId: 200,
        ),
      ).thenAnswer(
        (_) async => [
          _option(
            routeIds: [1],
            junctionCityIds: const [],
            startCityId: 10,
            // First option goes city 10 → 30 directly, but for the test we
            // only care about its index, not its trail buildability.
            endCityId: 30,
          ),
          _option(
            routeIds: [1, 2],
            junctionCityIds: [20],
            startCityId: 10,
            endCityId: 200,
          ),
        ],
      );
      await cubit.selectDestinationCity(_city(200));

      analytics.tracked.clear();

      final secondOption = cubit.state.journeyOptions[1];
      await cubit.buildTrailFromOption(secondOption);

      final event = analytics.tracked.firstWhere(
        (e) => e.name == 'journey_planner_route_option_selected',
      );
      expect(event.params['position_index'], 1);
    });
  });

  group('lazy polyline loading', () {
    test(
      'preserves estimatedDistanceKm for the top 10 options and null for '
      'options beyond — distance enrichment is the cubit-observable signal '
      'of eager-vs-lazy preview loading',
      () async {
        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));

        // Simulate RoutePathFinder's "top 10 enriched, rest unenriched"
        // behavior: 15 options total, first 10 with distance, last 5 null.
        final options = <JourneyOption>[
          for (var i = 0; i < 10; i++)
            _option(
              routeIds: [1],
              junctionCityIds: const [],
              startCityId: 10,
              endCityId: 100 + i,
              distanceKm: 100.0 + i,
            ),
          for (var i = 10; i < 15; i++)
            _option(
              routeIds: [1],
              junctionCityIds: const [],
              startCityId: 10,
              endCityId: 100 + i,
              // distanceKm intentionally null
            ),
        ];

        when(
          () => pathFinder.findJourneyOptions(
            startCityId: any(named: 'startCityId'),
            endCityId: any(named: 'endCityId'),
          ),
        ).thenAnswer((_) async => options);

        await cubit.selectDestinationCity(_city(200));

        expect(cubit.state.journeyOptions, hasLength(15));
        for (var i = 0; i < 10; i++) {
          expect(
            cubit.state.journeyOptions[i].estimatedDistanceKm,
            isNotNull,
            reason: 'top 10 option $i should have eager distance',
          );
        }
        for (var i = 10; i < 15; i++) {
          expect(
            cubit.state.journeyOptions[i].estimatedDistanceKm,
            isNull,
            reason: 'option $i beyond top 10 should have null distance',
          );
        }
      },
    );
  });

  group('updateJunctionDistanceThreshold', () {
    test(
      'persists threshold and updates path finder without emitting state '
      'when no start/end is selected',
      () async {
        final cubit = await primeAtStartCitySelection();
        // Status is startCitySelection; no start/end city yet.

        final initialStatus = cubit.state.status;

        await cubit.updateJunctionDistanceThreshold(500);

        verify(
          () => appPreferences.setJunctionMaxDistanceMeters(500),
        ).called(1);
        verify(
          () => pathFinder.setJunctionMaxDistanceMeters(500),
        ).called(1);
        // No state transition because there's no active journey selection.
        expect(cubit.state.status, initialStatus);
      },
    );

    test(
      'recomputes journey options when start and end are selected',
      () async {
        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));

        final initialOptions = [
          _option(
            routeIds: [1],
            junctionCityIds: const [],
            startCityId: 10,
            endCityId: 200,
          ),
        ];
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: 10,
            endCityId: 200,
          ),
        ).thenAnswer((_) async => initialOptions);
        await cubit.selectDestinationCity(_city(200));
        expect(cubit.state.journeyOptions, hasLength(1));

        // After threshold change, the path finder returns different options.
        final recomputed = [
          _option(
            routeIds: [1],
            junctionCityIds: const [],
            startCityId: 10,
            endCityId: 200,
          ),
          _option(
            routeIds: [1, 2],
            junctionCityIds: [20],
            startCityId: 10,
            endCityId: 200,
          ),
        ];
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: 10,
            endCityId: 200,
          ),
        ).thenAnswer((_) async => recomputed);

        await cubit.updateJunctionDistanceThreshold(500);

        expect(cubit.state.status, JourneyPlannerStatus.routeOptions);
        expect(cubit.state.journeyOptions, hasLength(2));
        verify(() => pathFinder.setJunctionMaxDistanceMeters(500)).called(1);
      },
    );

    test(
      'emits failure when recomputation throws',
      () async {
        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: any(named: 'startCityId'),
            endCityId: any(named: 'endCityId'),
          ),
        ).thenAnswer(
          (_) async => [
            _option(
              routeIds: [1],
              junctionCityIds: const [],
              startCityId: 10,
              endCityId: 200,
            ),
          ],
        );
        await cubit.selectDestinationCity(_city(200));

        // Next call throws.
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: any(named: 'startCityId'),
            endCityId: any(named: 'endCityId'),
          ),
        ).thenAnswer((_) async => throw StateError('boom'));

        await cubit.updateJunctionDistanceThreshold(500);

        expect(cubit.state.status, JourneyPlannerStatus.failure);
      },
    );
  });

  group('selectOption / navigation', () {
    test('selectOption updates selectedOptionIndex', () async {
      final cubit = await primeAtStartCitySelection();

      cubit.selectOption(2);
      expect(cubit.state.selectedOptionIndex, 2);

      cubit.selectOption(null);
      expect(cubit.state.selectedOptionIndex, isNull);
    });

    test(
      'backToStartCity clears the start city, end city, and journey options',
      () async {
        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: any(named: 'startCityId'),
            endCityId: any(named: 'endCityId'),
          ),
        ).thenAnswer(
          (_) async => [
            _option(
              routeIds: [1],
              junctionCityIds: const [],
              startCityId: 10,
              endCityId: 200,
            ),
          ],
        );
        await cubit.selectDestinationCity(_city(200));

        cubit.backToStartCity();

        expect(cubit.state.status, JourneyPlannerStatus.startCitySelection);
        expect(cubit.state.startCity, isNull);
        expect(cubit.state.endCity, isNull);
        expect(cubit.state.journeyOptions, isEmpty);
        expect(cubit.state.directlyReachableCityIds, isEmpty);
        expect(cubit.state.viaJunctionReachableCityIds, isEmpty);
      },
    );

    test(
      'backToDestination clears the end city and journey options but '
      'preserves the start city',
      () async {
        final cubit = await primeAtStartCitySelection();
        await cubit.selectStartCity(_city(10));
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: any(named: 'startCityId'),
            endCityId: any(named: 'endCityId'),
          ),
        ).thenAnswer(
          (_) async => [
            _option(
              routeIds: [1],
              junctionCityIds: const [],
              startCityId: 10,
              endCityId: 200,
            ),
          ],
        );
        await cubit.selectDestinationCity(_city(200));
        cubit
          ..selectOption(0)
          ..backToDestination();

        expect(
          cubit.state.status,
          JourneyPlannerStatus.destinationCitySelection,
        );
        expect(cubit.state.startCity!.id, 10);
        expect(cubit.state.endCity, isNull);
        expect(cubit.state.journeyOptions, isEmpty);
        expect(cubit.state.selectedOptionIndex, isNull);
      },
    );
  });

  group('happy path', () {
    test(
      'startCitySelection -> destinationCitySelection -> routeOptions -> '
      'option selected returns a MultiRouteTrail',
      () async {
        final cubit = await primeAtStartCitySelection();

        // Transition 1: start city.
        await cubit.selectStartCity(_city(10));
        expect(
          cubit.state.status,
          JourneyPlannerStatus.destinationCitySelection,
        );
        expect(cubit.state.startCity!.id, 10);

        // Transition 2: destination city.
        when(
          () => pathFinder.findJourneyOptions(
            startCityId: 10,
            endCityId: 200,
          ),
        ).thenAnswer(
          (_) async => [
            _option(
              routeIds: [1, 2],
              junctionCityIds: [20],
              startCityId: 10,
              endCityId: 200,
              distanceKm: 42.5,
            ),
          ],
        );
        await cubit.selectDestinationCity(_city(200));
        expect(cubit.state.status, JourneyPlannerStatus.routeOptions);
        expect(cubit.state.journeyOptions, hasLength(1));

        // Transition 3: option selected → trail returned.
        final trail = await cubit.buildTrailFromOption(
          cubit.state.journeyOptions.first,
        );
        expect(trail, isNotNull);
        expect(trail!.isMultiRoute, isTrue);
        expect(trail.segments.map((s) => s.routeId), [1, 2]);

        // All three funnel events fired in order.
        final names = analytics.tracked.map((e) => e.name).toList();
        expect(
          names,
          containsAllInOrder([
            'journey_planner_start_city_selected',
            'journey_planner_destination_selected',
            'journey_planner_route_option_selected',
          ]),
        );
      },
    );
  });
}
