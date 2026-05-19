import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/cubit/plan_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class _MockRepository extends Mock implements Repository {}

class _MockStagePlanRepository extends Mock
    implements StagePlanRepository {}

class _MockAppPreferences extends Mock implements AppPreferences {}

class _NoopAnalyticsService implements IAnalyticsService {
  @override
  void trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) {}

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

RouteEntity _route(int id) => RouteEntity(
      id: id,
      orderKey: id,
      routeName: 'Route $id',
    );

RoutePointEntity _point(int id, {int? routeId}) => RoutePointEntity(
      id: id,
      orderKey: id,
      elevation: 0,
      routeId: routeId,
      latitude: id.toDouble(),
      longitude: id.toDouble(),
    );

StageModel _stage({
  required int routeId,
  required List<RoutePointEntity>? selectedRoutePoints,
  int? id,
}) {
  return StageModel(
    id: id,
    routeId: routeId,
    selectedRoutePoints: selectedRoutePoints,
  );
}

StagePlanModel _plan({
  required RouteEntity route,
  required List<StageModel> stages,
  String? trailRouteIds,
}) {
  return StagePlanModel(
    id: 1,
    route: route,
    stages: stages,
    createdAt: DateTime(2026),
    trailRouteIds: trailRouteIds,
  );
}

void main() {
  late _MockRepository repository;
  late _MockStagePlanRepository stagePlanRepository;
  late _MockAppPreferences appPreferences;

  setUp(() {
    repository = _MockRepository();
    stagePlanRepository = _MockStagePlanRepository();
    appPreferences = _MockAppPreferences();

    GetIt.instance
      ..registerSingleton<Repository>(repository)
      ..registerSingleton<StagePlanRepository>(stagePlanRepository)
      ..registerSingleton<AppPreferences>(appPreferences)
      ..registerSingleton<IAnalyticsService>(_NoopAnalyticsService());
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('resolveRoutePoints', () {
    test(
      'multi-route plan concatenates stage selectedRoutePoints in order',
      () async {
        // Two stages on different routes — `isMultiRoute` is derived
        // from the distinct routeIds.
        final stageA = _stage(
          routeId: 1,
          selectedRoutePoints: [
            _point(101, routeId: 1),
            _point(102, routeId: 1),
          ],
        );
        final stageB = _stage(
          routeId: 2,
          selectedRoutePoints: [
            _point(201, routeId: 2),
            _point(202, routeId: 2),
            _point(203, routeId: 2),
          ],
        );
        final plan = _plan(
          route: _route(1),
          stages: [stageA, stageB],
        );

        final cubit = PlanDetailCubit(planId: plan.id);
        addTearDown(cubit.close);

        final result = await cubit.resolveRoutePoints(plan);

        // The multi-route branch returns concatenated stage points.
        // It must NOT call `_repository.getRoutePointsByRouteIdFromDb`
        // (the bug): that extension method dereferences the mock's
        // null `_appDatabase` and would throw — so a successful
        // return here is itself proof the legacy branch was skipped.
        expect(result, isA<List<RoutePointEntity>>());
        expect(result.map((p) => p.id), [101, 102, 201, 202, 203]);
      },
    );

    test(
      'multi-route plan with a stage missing selectedRoutePoints '
      'gracefully omits it',
      () async {
        final stageA = _stage(
          routeId: 1,
          selectedRoutePoints: [_point(101, routeId: 1)],
        );
        final stageMissing = _stage(
          routeId: 2,
          selectedRoutePoints: null,
        );
        final stageC = _stage(
          routeId: 3,
          selectedRoutePoints: [_point(301, routeId: 3)],
        );
        final plan = _plan(
          route: _route(1),
          stages: [stageA, stageMissing, stageC],
        );

        final cubit = PlanDetailCubit(planId: plan.id);
        addTearDown(cubit.close);

        final result = await cubit.resolveRoutePoints(plan);

        expect(result.map((p) => p.id), [101, 301]);
      },
    );

    test(
      'single-route plan delegates to repository '
      'getRoutePointsByRouteIdFromDb',
      () async {
        // All stages share route 1 → `isMultiRoute` is false.
        final stageA = _stage(
          routeId: 1,
          selectedRoutePoints: [_point(101, routeId: 1)],
        );
        final plan = _plan(route: _route(1), stages: [stageA]);

        final cubit = PlanDetailCubit(planId: plan.id);
        addTearDown(cubit.close);

        // `getRoutePointsByRouteIdFromDb` is a Dart extension on
        // `Repository` — mocktail cannot intercept it, so the call
        // body runs and dereferences the mock's null `_appDatabase`.
        // That this throws is itself the proof we took the
        // single-route branch (not the multi-route concat path).
        await expectLater(
          cubit.resolveRoutePoints(plan),
          throwsA(anything),
        );
      },
    );
  });
}
