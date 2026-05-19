import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/cubit/stage_map_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class _MockRepository extends Mock implements Repository {}

class _MockStagePlanRepository extends Mock
    implements StagePlanRepository {}

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

StageMapCubit _buildCubit() => StageMapCubit(
      selectedStage: _stage(routeId: 1, selectedRoutePoints: null),
      routeId: 1,
    );

void main() {
  late _MockRepository repository;
  late _MockStagePlanRepository stagePlanRepository;

  setUp(() {
    repository = _MockRepository();
    stagePlanRepository = _MockStagePlanRepository();

    GetIt.instance
      ..registerSingleton<Repository>(repository)
      ..registerSingleton<StagePlanRepository>(stagePlanRepository);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('resolveStageMapRoutePoints', () {
    test(
      'multi-route plan concatenates stage selectedRoutePoints '
      'in stage order',
      () {
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

        final cubit = _buildCubit();
        addTearDown(cubit.close);

        // Pass a non-empty trailRoutePointsList — the multi-route
        // branch must IGNORE it (the bug being fixed picked
        // `trailRoutePointsList.first` instead of stitching stages).
        final result = cubit.resolveStageMapRoutePoints(
          stagePlan: plan,
          trailRoutePointsList: [
            [_point(999, routeId: 1)],
            [_point(998, routeId: 2)],
          ],
        );

        expect(result.map((p) => p.id), [101, 102, 201, 202, 203]);
      },
    );

    test(
      'multi-route plan with a stage missing selectedRoutePoints '
      'gracefully omits it',
      () {
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

        final cubit = _buildCubit();
        addTearDown(cubit.close);

        final result = cubit.resolveStageMapRoutePoints(
          stagePlan: plan,
          trailRoutePointsList: const [],
        );

        expect(result.map((p) => p.id), [101, 301]);
      },
    );

    test(
      'single-route plan returns the first trailRoutePointsList entry',
      () {
        // All stages share route 1 → `isMultiRoute` is false.
        final stageA = _stage(
          routeId: 1,
          selectedRoutePoints: [_point(101, routeId: 1)],
        );
        final plan = _plan(route: _route(1), stages: [stageA]);

        final cubit = _buildCubit();
        addTearDown(cubit.close);

        final trailPoints = [
          _point(901, routeId: 1),
          _point(902, routeId: 1),
        ];

        final result = cubit.resolveStageMapRoutePoints(
          stagePlan: plan,
          trailRoutePointsList: [trailPoints],
        );

        expect(result, same(trailPoints));
      },
    );

    test(
      'single-route plan with empty trailRoutePointsList '
      'returns an empty list',
      () {
        final stageA = _stage(
          routeId: 1,
          selectedRoutePoints: [_point(101, routeId: 1)],
        );
        final plan = _plan(route: _route(1), stages: [stageA]);

        final cubit = _buildCubit();
        addTearDown(cubit.close);

        final result = cubit.resolveStageMapRoutePoints(
          stagePlan: plan,
          trailRoutePointsList: const [],
        );

        expect(result, isEmpty);
      },
    );
  });
}
