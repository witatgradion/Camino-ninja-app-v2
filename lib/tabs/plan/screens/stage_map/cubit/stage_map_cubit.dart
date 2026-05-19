import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/combine_marker_data.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/junction_marker_data.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/trail_builder/widgets/junction_mini_graph.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'stage_map_state.dart';

class StageMapCubit extends Cubit<StageMapState> with SafeEmitMixin {
  StageMapCubit({
    required this.selectedStage,
    required this.routeId,
    this.stagePlanId,
  }) : super(const StageMapState());
  final StageModel selectedStage;
  final int routeId;
  final int? stagePlanId;

  /// Whether the app is in dark mode, used for resolving
  /// theme-aware route legend colors on junction markers.
  bool isDark = false;

  final StagePlanRepository _stagePlanRepository =
      GetIt.instance<StagePlanRepository>();
  final Repository _repository = GetIt.instance<Repository>();

  Future<void> init() async {
    try {
      safeEmit(state.copyWith(initStatus: StageMapInitStatus.loading));

      if (stagePlanId == null) {
        // Parallelize all fetches
        final results = await Future.wait([
          _repository.getRouteById(routeId),
          _repository.getRoutePointsByRouteIdFromDb(routeId: routeId),
          _repository.getAltRoutePointsWithValueByRouteId(routeId: routeId),
        ]);
        final route = results[0] as RouteEntity;
        final routePoints = results[1] as List<RoutePointEntity>;
        final altRoutePoints = results[2] as List<AltRoutePointEntity>;

        final updatedSelectedStage = selectedStage.copyWith(
          id: selectedStage.id ?? DateTime.now().millisecondsSinceEpoch,
        );
        safeEmit(
          state.copyWith(
            routePoints: routePoints,
            altRoutePoints: altRoutePoints,
            allStages: [updatedSelectedStage],
            selectedStage: updatedSelectedStage,
            combineMarkerDataList: getCombineMarkerDataList(
              stages: [updatedSelectedStage],
              selectedStage: updatedSelectedStage,
            ),
            initStatus: StageMapInitStatus.success,
            route: route,
          ),
        );
      } else {
        // Fetch route and stagePlan in parallel first
        final initialResults = await Future.wait([
          _repository.getRouteById(routeId),
          _stagePlanRepository.getStagePlanById(stagePlanId!),
        ]);
        final route = initialResults[0] as RouteEntity;
        final stagePlan = initialResults[1] as StagePlanModel;

        // Collect all unique route IDs from the trail
        final trailDescriptors = MultiRouteTrail.parseDescriptors(
          stagePlan.trailRouteIds,
        );
        final allRouteIds = trailDescriptors != null
            ? trailDescriptors.map((d) => d.routeId).toSet()
            : <int>{stagePlan.route.id};

        // Fetch route points for ALL trail routes, alt points,
        // and junction data in parallel
        final routePointFutures = allRouteIds.map(
          (id) => _repository.getRoutePointsByRouteIdFromDb(
            routeId: id,
          ),
        );
        final pointResults = await Future.wait([
          ...routePointFutures,
          _repository.getAltRoutePointsWithValueByRouteId(
            routeId: stagePlan.route.id,
          ),
          _computeJunctionMarkerData(stagePlan),
        ]);

        // Build per-route point lists for separate polylines
        final trailRoutePointsList = <List<RoutePointEntity>>[];
        for (var i = 0; i < allRouteIds.length; i++) {
          trailRoutePointsList
              .add(pointResults[i] as List<RoutePointEntity>);
        }
        // Multi-trail plans must stitch route points across stages —
        // the plan's base routeId only covers one segment of the
        // trail. Single-route plans keep using the first (only) entry
        // in `trailRoutePointsList` so location-handler and any other
        // consumers of `state.routePoints` keep their "primary route"
        // reference.
        final routePoints = resolveStageMapRoutePoints(
          stagePlan: stagePlan,
          trailRoutePointsList: trailRoutePointsList,
        );
        final altRoutePoints = pointResults[allRouteIds.length]
            as List<AltRoutePointEntity>;
        final junctionMarkerDataList =
            pointResults[allRouteIds.length + 1]
                as List<JunctionMarkerData>;

        // Compute dates from plan's starting date
        final stagesWithDates = <StageModel>[];
        for (var i = 0; i < stagePlan.stages.length; i++) {
          final computedDate = stagePlan.computeStageDate(i);
          final stage = stagePlan.stages[i];
          stagesWithDates.add(
            computedDate != null
                ? stage.copyWith(date: computedDate)
                : stage,
          );
        }

        // Prefer the freshly-fetched stage from the plan
        // (has correctly computed selectedRoutePoints) over
        // the widget's version which may be stale. Use the
        // date-enriched list for lookup.
        final freshStage = stagesWithDates.firstWhere(
          (s) => s.id == selectedStage.id,
          orElse: () => selectedStage.copyWith(
            id: selectedStage.id ??
                DateTime.now().millisecondsSinceEpoch,
          ),
        );
        final updatedSelectedStage = freshStage.copyWith(
          id: freshStage.id ??
              DateTime.now().millisecondsSinceEpoch,
        );

        final allStages = stagesWithDates
          ..sort(
            (a, b) => (a.stageNumber ?? 0)
                .compareTo(b.stageNumber ?? 0),
          );

        final combineMarkers = _enrichWithJunctionData(
          getCombineMarkerDataList(
            stages: allStages,
            selectedStage: updatedSelectedStage,
          ),
          junctionMarkerDataList,
        );

        safeEmit(
          state.copyWith(
            stagePlan: stagePlan,
            selectedStage: updatedSelectedStage,
            allStages: allStages,
            combineMarkerDataList: combineMarkers,
            junctionMarkerDataList: junctionMarkerDataList,
            routePoints: routePoints,
            trailRoutePointsList: trailRoutePointsList,
            altRoutePoints: altRoutePoints,
            initStatus: StageMapInitStatus.success,
            route: route,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'StageMapCubit init failed',
        tag: 'StageMapCubit',
        error: e,
        stackTrace: stackTrace,
      );
      safeEmit(state.copyWith(initStatus: StageMapInitStatus.failure));
    }
  }

  MarkerSide _calculateMarkerSide({
    required StageModel stage,
    required CityEntity city,
    required bool isStartStage,
  }) {
    // Decide side based on where the *other* city of this stage lies
    // relative to the current city:
    // - If the other city is north (higher latitude), place the marker on top.
    // - If the other city is south (lower latitude), place the marker below.
    // This way, at the start city and end city of a stage, the markers are
    // always drawn towards the interior of the segment between them.
    final otherCity = isStartStage ? stage.endCity : stage.startCity;
    if (otherCity == null) {
      // Fallback if we don't have both cities
      return isStartStage ? MarkerSide.top : MarkerSide.bottom;
    }

    const epsilon = 1e-5;
    final latDiff = otherCity.latitude - city.latitude;

    if (latDiff.abs() < epsilon) {
      // Stage is almost purely east-west; fall back to a stable convention
      return isStartStage ? MarkerSide.top : MarkerSide.bottom;
    }

    // If the other city is north, draw towards north (top); if south, bottom.
    return latDiff > 0 ? MarkerSide.top : MarkerSide.bottom;
  }

  List<CombineMarkerData> getCombineMarkerDataList({
    required StageModel selectedStage,
    List<StageModel> stages = const [],
  }) {
    final cityMap = <int?, CombineMarkerData>{};
    final selectedStageId = selectedStage.id;

    // Pre-compute stage indices for O(1) lookup
    final stageIndexMap = <int?, int>{};
    for (var i = 0; i < stages.length; i++) {
      stageIndexMap[stages[i].id] = i;
    }

    // Helper to add stage to city's start or end stages
    void addStageToCity({
      required CityEntity? city,
      required StageModel stage,
      required bool isStartStage,
    }) {
      if (city == null) return;

      final cityData = cityMap[city.id];
      final stageData = CombineMarkerStageData(
        stage: stage,
        index: stageIndexMap[stage.id] ?? 0,
        isSelected: stage.id == selectedStageId,
        side: _calculateMarkerSide(
          stage: stage,
          city: city,
          isStartStage: isStartStage,
        ),
      );

      if (cityData == null) {
        cityMap[city.id] = CombineMarkerData(
          city: city,
          startStages: isStartStage ? [stageData] : [],
          endStages: isStartStage ? [] : [stageData],
        );
      } else {
        final updatedStages = [
          ...(isStartStage ? cityData.startStages : cityData.endStages),
          stageData,
        ];
        cityMap[city.id] = isStartStage
            ? cityData.copyWith(startStages: updatedStages)
            : cityData.copyWith(endStages: updatedStages);
      }
    }

    for (final stage in stages) {
      addStageToCity(
        city: stage.startCity,
        stage: stage,
        isStartStage: true,
      );
      addStageToCity(
        city: stage.endCity,
        stage: stage,
        isStartStage: false,
      );
    }

    return cityMap.values.toList();
  }

  void onSelectStage(StageModel stage) {
    safeEmit(
      state.copyWith(
        selectedStage: stage,
        combineMarkerDataList: _enrichWithJunctionData(
          getCombineMarkerDataList(
            stages: state.allStages,
            selectedStage: stage,
          ),
          state.junctionMarkerDataList,
        ),
      ),
    );
  }

  /// Merges junction info into combine marker data entries
  /// whose city matches a junction city. This lets the
  /// combine marker render a glow ring and label pill
  /// instead of requiring a separate junction marker.
  List<CombineMarkerData> _enrichWithJunctionData(
    List<CombineMarkerData> combineMarkers,
    List<JunctionMarkerData> junctionMarkers,
  ) {
    if (junctionMarkers.isEmpty) return combineMarkers;

    final junctionByCityId = <int, JunctionMarkerData>{};
    for (final j in junctionMarkers) {
      junctionByCityId[j.city.id] = j;
    }

    return combineMarkers.map((d) {
      final junction = junctionByCityId[d.city.id];
      if (junction == null) return d;
      return d.copyWith(
        junctionFromRouteName: junction.fromRouteName,
        junctionToRouteName: junction.toRouteName,
        junctionGlowColorValue: junction.glowColorValue,
      );
    }).toList();
  }

  /// Returns the route points that the stage map should render as
  /// the red "planned route" polyline.
  ///
  /// For multi-trail plans, concatenates each stage's
  /// `selectedRoutePoints` — those are already correctly stitched
  /// across routes (cross-route stages) or sliced to a city segment
  /// (single-route stages) by [StagePlanRepository]. Concatenating
  /// them yields the full cross-route trail.
  ///
  /// For single-route plans, returns the first (and only) entry from
  /// [trailRoutePointsList] so existing consumers keep their primary
  /// route reference.
  @visibleForTesting
  List<RoutePointEntity> resolveStageMapRoutePoints({
    required StagePlanModel stagePlan,
    required List<List<RoutePointEntity>> trailRoutePointsList,
  }) {
    if (stagePlan.isMultiRoute) {
      final perStageCounts = stagePlan.stages
          .map((s) => s.selectedRoutePoints?.length ?? -1)
          .toList();
      final result = [
        for (final stage in stagePlan.stages)
          ...?stage.selectedRoutePoints,
      ];
      AppLogger.d(
        '[DEBUG-POLYLINE] multi-route branch '
        'stages=${stagePlan.stages.length} '
        'selectedRoutePointsCounts=$perStageCounts '
        'concatenated=${result.length}',
        tag: 'StageMapCubit',
      );
      return result;
    }
    AppLogger.d(
      '[DEBUG-POLYLINE] single-route branch '
      'trailRoutePointsList.length=${trailRoutePointsList.length} '
      'first.length=${trailRoutePointsList.isNotEmpty ? trailRoutePointsList.first.length : 0}',
      tag: 'StageMapCubit',
    );
    return trailRoutePointsList.isNotEmpty
        ? trailRoutePointsList.first
        : const <RoutePointEntity>[];
  }

  Future<List<JunctionMarkerData>> _computeJunctionMarkerData(
    StagePlanModel stagePlan,
  ) async {
    final descriptors = MultiRouteTrail.parseDescriptors(
      stagePlan.trailRouteIds,
    );
    if (descriptors == null || descriptors.length < 2) {
      return const [];
    }

    final results = <JunctionMarkerData>[];
    for (var i = 1; i < descriptors.length; i++) {
      final descriptor = descriptors[i];
      final junctionCityId = descriptor.junctionCityId;
      if (junctionCityId == null) continue;

      final prevDescriptor = descriptors[i - 1];
      try {
        final data = await Future.wait([
          _repository.getCityByIdFromDb(junctionCityId),
          _repository.getRouteById(prevDescriptor.routeId),
          _repository.getRouteById(descriptor.routeId),
        ]);
        final marker = JunctionMarkerData(
          city: data[0] as CityEntity,
          fromRouteName: (data[1] as RouteEntity).routeName,
          toRouteName: (data[2] as RouteEntity).routeName,
          glowColorValue: JunctionMiniGraph.parseColorValue(
            data[1] as RouteEntity,
            isDark: isDark,
          ),
        );
        results.add(marker);
      } catch (_) {
        // Skip junction markers that fail to resolve
      }
    }

    return results;
  }
}
