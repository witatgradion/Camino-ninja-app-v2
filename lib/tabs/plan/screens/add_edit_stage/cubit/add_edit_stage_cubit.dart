import 'dart:math';

import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/plan_type_choice_sheet.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'add_edit_stage_state.dart';

class AddEditStageCubit extends Cubit<AddEditStageState> with SafeEmitMixin {
  AddEditStageCubit({
    this.routeId,
    this.stagePlanId,
    this.insertAfterStageNumber,
    String? planName,
    this.trail,
    this.planType,
  }) : super(AddEditStageState(planName: planName, trail: trail));
  final int? routeId;
  final int? stagePlanId;
  final MultiRouteTrail? trail;
  final int? insertAfterStageNumber;

  /// The plan-type choice the user made when creating a new plan.
  /// Null when this cubit is reached from an existing-plan path or
  /// when the create flow predates the choice sheet.
  final PlanType? planType;

  final StagePlanRepository _stagePlanRepository =
      GetIt.instance<StagePlanRepository>();
  final Repository _repository = GetIt.instance<Repository>();
  String? _lastCityPairKey;

  /// Determines which route a stage belongs to based on the
  /// start city's position in the trail. Falls back to the
  /// cubit's [routeId] if trail is null or city not found.
  int? _resolveRouteId(CityEntity? startCity) {
    if (trail == null || startCity == null) return routeId;
    final segment = trail!.segmentForCity(startCity.id);
    if (segment != null) return segment.routeId;
    return routeId;
  }

  /// Snapshot of the stage's note when the screen opened (update mode only).
  /// Used to decide whether to fire a [StageNoteUpdatedEvent] on save and,
  /// if so, which `action` value it carries.
  String? _initialStageNote;
  bool _noteChangedDuringSession = false;

  void updatePlanName(String? name) {
    if (name == null || name.isEmpty) {
      safeEmit(state.copyWith(clearPlanName: true));
    } else {
      safeEmit(state.copyWith(planName: name));
    }
  }

  Future<void> savePlanName({
    required int stagePlanId,
    String? name,
  }) async {
    await _stagePlanRepository.updateStagePlanName(
      stagePlanId: stagePlanId,
      name: name,
    );
  }

  Future<void> selectStartCity({required CityEntity city}) async {
    // Clear end city, end alberges if start city changed
    final oldCity = state.stage?.startCity;
    final isChanged = oldCity?.id != city.id;

    var newStage = state.stage?.clearEndCityAndEndAlbergues();
    if (isChanged) {
      newStage = newStage?.clearStartAlbergueInfo();
    }
    newStage = newStage?.copyWith(startCity: city);
    safeEmit(
      state.copyWith(
        stage: newStage,
        stageOverviewVisibility: StageOverviewVisibility.hidden,
      ),
    );
  }

  Future<void> selectEndCity({required CityEntity city}) async {
    // Clear end albergues if end city changed
    final oldCity = state.stage?.endCity;
    final isChanged = oldCity?.id != city.id;

    var newStage = state.stage?.copyWith(endCity: city);
    if (isChanged) {
      newStage = newStage?.clearEndAlbergueInfo();
    }

    final newPairKey = '${newStage?.startCity?.id}-${newStage?.endCity?.id}';
    final startCity = newStage?.startCity;
    final endCity = newStage?.endCity;
    final resolvedRouteId = _resolveRouteId(startCity);
    if (startCity == null || endCity == null || resolvedRouteId == null) {
      safeEmit(state.copyWith(stage: newStage));
      return;
    }
    if (_lastCityPairKey == null || _lastCityPairKey != newPairKey) {
      _lastCityPairKey = newPairKey;

      try {
        List<({TrailSegment segment, int fromCityId, int toCityId})>?
            segmentRanges;
        try {
          segmentRanges = trail?.segmentsBetweenCities(
            startCity.id,
            endCity.id,
          );
        } catch (e) {
          AppLogger.d(
            'segmentsBetweenCities failed, '
            'falling back to single-route path: $e',
            tag: 'AddEditStageCubit',
          );
        }
        final isCrossRoute =
            segmentRanges != null && segmentRanges.length > 1;

        AppLogger.d(
          'selectEndCity: trail=${trail != null}, '
          'segmentRanges=${segmentRanges?.length}, '
          'isCrossRoute=$isCrossRoute, '
          'resolvedRouteId=$resolvedRouteId',
          tag: 'AddEditStageCubit',
        );

        if (isCrossRoute) {
          newStage = await _computeCrossRouteStage(
            newStage: newStage,
            segmentRanges: segmentRanges!,
          );
        } else {
          // When segmentsBetweenCities returns a single segment,
          // use that segment's routeId. This avoids a mismatch
          // when _resolveRouteId (which prefers the last segment
          // for junction cities) picks a different route than
          // the segment the cities actually share.
          final effectiveRouteId =
              segmentRanges != null && segmentRanges.length == 1
                  ? segmentRanges.first.segment.routeId
                  : resolvedRouteId;
          newStage = await _computeSingleRouteStage(
            newStage: newStage,
            startCity: startCity,
            endCity: endCity,
            resolvedRouteId: effectiveRouteId,
          );
        }

        AppLogger.d(
          'selectEndCity result: '
          'hasRoutePoints='
          '${newStage?.selectedRoutePoints?.isNotEmpty}',
          tag: 'AddEditStageCubit',
        );
      } catch (e, st) {
        AppLogger.e(
          'Failed to compute stage statistics',
          tag: 'AddEditStageCubit',
          error: e,
          stackTrace: st,
        );
      }
    }

    safeEmit(
      state.copyWith(
        stage: newStage,
        stageOverviewVisibility: StageOverviewVisibility.visible,
        saveButtonVisibility: _shouldShowSaveButton(newStage),
      ),
    );
  }

  Future<void> updateStage({
    AlbergueEntity? startAlbergue,
    AlbergueEntity? endAlbergue,
    String? customStartNotes,
    String? customEndNotes,
    bool forceClearStart = false,
    bool forceClearEnd = false,
  }) async {
    var stage = state.stage;
    if (forceClearStart) {
      stage = state.stage?.clearStartAlbergueInfo();
    }
    if (forceClearEnd) {
      stage = state.stage?.clearEndAlbergueInfo();
    }
    stage = stage?.copyWith(
      routeId: _resolveRouteId(stage.startCity) ?? routeId,
      startAlbergue: startAlbergue,
      endAlbergue: endAlbergue,
      customStartNotes: customStartNotes,
      customEndNotes: customEndNotes,
    );
    safeEmit(
      state.copyWith(
        stage: stage,
        saveButtonVisibility: _shouldShowSaveButton(stage),
      ),
    );
  }

  void updateStageNote(String? note) {
    final stage = state.stage;
    if (stage == null) return;
    final trimmed = note?.trim();
    final clear = trimmed == null || trimmed.isEmpty;
    final updated = stage.copyWith(
      stageNotes: clear ? null : trimmed,
      clearStageNotes: clear,
    );
    _noteChangedDuringSession = true;
    safeEmit(
      state.copyWith(
        stage: updated,
        clearStageNotes: clear,
      ),
    );
  }

  Future<void> init({
    StageModel? stage,
    CityEntity? startCity,
    AlbergueEntity? startAlbergue,
    String? startAlbergueNotes,
  }) async {
    if (routeId == null) {
      safeEmit(state.copyWith(initStatus: AddEditStageInitStatus.failure));
      return;
    }

    // Parallelize all initial data fetches
    final results = await Future.wait([
      _repository.getRouteById(routeId!),
      _repository.getRoutePointsByRouteIdFromDb(routeId: routeId!),
      _repository.getAltRoutePointsWithValueByRouteId(routeId: routeId!),
    ]);
    final route = results[0] as RouteEntity;
    final routePoints = results[1] as List<RoutePointEntity>;
    final altRoutePoints = results[2] as List<AltRoutePointEntity>;
    if (stage == null) {
      _initialStageNote = null;
      safeEmit(
        state.copyWith(
          stage: StageModel(
            routeId: route.id,
            startCity: startCity,
            startAlbergue: startAlbergue,
            customStartNotes: startAlbergueNotes,
          ),
          route: route,
          routePoints: routePoints,
          altRoutePoints: altRoutePoints,
        ),
      );
    } else {
      _initialStageNote = stage.stageNotes;
      safeEmit(
        state.copyWith(
          stage: stage,
          route: route,
          stageOverviewVisibility: StageOverviewVisibility.visible,
          saveButtonVisibility: _shouldShowSaveButton(stage),
          routePoints: routePoints,
          altRoutePoints: altRoutePoints,
        ),
      );
    }
  }

  SaveButtonVisibility? _shouldShowSaveButton(StageModel? stage) {
    return stage?.isValid() ?? false
        ? SaveButtonVisibility.visible
        : SaveButtonVisibility.hidden;
  }

  /// Computes stage stats when start and end cities are on the
  /// same route segment (the common single-route case).
  Future<StageModel?> _computeSingleRouteStage({
    required StageModel? newStage,
    required CityEntity startCity,
    required CityEntity endCity,
    required int resolvedRouteId,
  }) async {
    final route = state.route?.id == resolvedRouteId
        ? state.route!
        : await _repository.getRouteById(resolvedRouteId);

    final results = await Future.wait([
      _repository.getRoutePointsByRouteIdFromDb(
        routeId: resolvedRouteId,
        startingCityId: startCity.id,
        destCityId: endCity.id,
      ),
      _repository.getRoutePointsByRouteIdFromDb(
        routeId: resolvedRouteId,
      ),
    ]);
    final selectedRoutePoints = results[0];
    final routePoints = results[1];

    // Use _computeStatsFromPoints instead of
    // route.calculateRouteStatistics to avoid relying on
    // city.routePoints which may only contain entries for
    // the route the city was originally loaded from.
    final stats = _computeStatsFromPoints(selectedRoutePoints);

    return newStage?.copyWith(
      distance: stats.distance,
      minElevation: stats.minElev,
      maxElevation: stats.maxElev,
      elevationGain: stats.elevGain,
      elevationLoss: stats.elevLoss,
      points: routePoints,
      selectedRoutePoints: selectedRoutePoints,
    );
  }

  /// Computes stage stats when start and end cities span
  /// multiple trail segments (cross-route stage).
  Future<StageModel?> _computeCrossRouteStage({
    required StageModel? newStage,
    required List<
            ({TrailSegment segment, int fromCityId, int toCityId})>
        segmentRanges,
  }) async {
    // Collect unique route IDs and fetch all route points
    // in parallel.
    final uniqueRouteIds = segmentRanges
        .map((r) => r.segment.routeId)
        .toSet();
    final routePointResults = await Future.wait(
      uniqueRouteIds.map(
        (id) => _repository.getRoutePointsByRouteIdFromDb(
          routeId: id,
        ),
      ),
    );
    final routePointsMap = Map.fromIterables(
      uniqueRouteIds,
      routePointResults,
    );

    final stitchedPoints = <RoutePointEntity>[];
    final allRoutePoints = <RoutePointEntity>[];

    for (final range in segmentRanges) {
      final segmentAllPoints =
          routePointsMap[range.segment.routeId] ?? [];
      final slicedPoints =
          await _repository.getRoutePointsByRouteIdFromDb(
        routeId: range.segment.routeId,
        startingCityId: range.fromCityId,
        destCityId: range.toCityId,
      );

      allRoutePoints.addAll(segmentAllPoints);

      // Deduplicate at junction boundary
      if (stitchedPoints.isNotEmpty &&
          slicedPoints.isNotEmpty) {
        final lastPt = stitchedPoints.last;
        final firstPt = slicedPoints.first;
        final isDuplicate =
            lastPt.latitude == firstPt.latitude &&
            lastPt.longitude == firstPt.longitude;
        if (isDuplicate) {
          stitchedPoints.addAll(slicedPoints.skip(1));
        } else {
          stitchedPoints.addAll(slicedPoints);
        }
      } else {
        stitchedPoints.addAll(slicedPoints);
      }
    }

    final stats = _computeStatsFromPoints(stitchedPoints);

    return newStage?.copyWith(
      distance: stats.distance,
      minElevation: stats.minElev,
      maxElevation: stats.maxElev,
      elevationGain: stats.elevGain,
      elevationLoss: stats.elevLoss,
      points: allRoutePoints,
      selectedRoutePoints: stitchedPoints,
    );
  }

  /// Computes distance and elevation stats from a list of
  /// route points. Uses the same haversine algorithm as
  /// [RouteEntity.calculateRouteStatistics].
  ({
    double distance,
    int elevGain,
    int elevLoss,
    int minElev,
    int maxElev,
  }) _computeStatsFromPoints(List<RoutePointEntity> points) {
    if (points.isEmpty) {
      return (
        distance: 0.0,
        elevGain: 0,
        elevLoss: 0,
        minElev: 0,
        maxElev: 0,
      );
    }
    var routeLength = 0.0;
    var up = 0.0;
    var down = 0.0;
    var minAlt = double.infinity;
    var maxAlt = 0.0;

    for (var j = 0; j < points.length; j++) {
      final lat = points[j].latitude;
      final lon = points[j].longitude;
      final ele = points[j].elevation;
      if (maxAlt < ele) maxAlt = ele;
      if (minAlt > ele) minAlt = ele;
      if (j > 0) {
        final prevLat = points[j - 1].latitude;
        final prevLon = points[j - 1].longitude;
        final prevEle = points[j - 1].elevation;
        final dist = _haversineDistance(
          lat,
          lon,
          prevLat,
          prevLon,
        );
        final height = (ele - prevEle).abs();
        routeLength += sqrt((dist * dist) + (height * height));
        final eleDiff = ele - prevEle;
        if (eleDiff > 0) {
          up += eleDiff;
        } else if (eleDiff < 0) {
          down += eleDiff.abs();
        }
      }
    }
    return (
      distance: routeLength / 1000,
      elevGain: up.toInt(),
      elevLoss: down.toInt(),
      minElev: minAlt.toInt(),
      maxElev: maxAlt.toInt(),
    );
  }

  /// Haversine formula returning distance in meters between
  /// two geographic coordinates.
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = GeoConstants.earthRadiusM;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) *
            cos(phi2) *
            sin(deltaLambda / 2) *
            sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return r * c;
  }

  Future<void> saveStage() async {
    try {
      if (state.saveStageStatus == SaveStageStatus.loading) {
        return;
      }
      final effectiveRouteId =
          _resolveRouteId(state.stage?.startCity) ?? routeId;
      if (effectiveRouteId == null) {
        safeEmit(state.copyWith(saveStageStatus: SaveStageStatus.failure));
        return;
      }
      safeEmit(state.copyWith(saveStageStatus: SaveStageStatus.loading));
      final stage = state.stage;
      final isUpdating = stage?.id != null;
      final stagePlanId = this.stagePlanId ?? stage?.stagePlanId;

      // For plan creation, use the trail's primary route ID so the
      // stage_plans row represents the overall trail. For each
      // individual stage, use the route resolved from the start city.
      final planRouteId = trail?.primaryRouteId ?? effectiveRouteId;

      var stageId = stage?.id;
      if (isUpdating) {
        if (stageId == null) {
          AppLogger.e(
            'Cannot update stage with null id',
            tag: 'AddEditStageCubit',
          );
          safeEmit(
            state.copyWith(
              saveStageStatus: SaveStageStatus.failure,
            ),
          );
          return;
        }
        await _stagePlanRepository.updateStagePartial(
          stageId: stageId,
          stagePlanId: stagePlanId,
          stageUuid: stage?.stageUuid,
          date: stage?.date,
          startCityId: stage?.startCity?.id,
          endCityId: stage?.endCity?.id,
          startAlbergueId: stage?.startAlbergue?.id,
          endAlbergueId: stage?.endAlbergue?.id,
          customStartNotes: stage?.customStartNotes,
          customEndNotes: stage?.customEndNotes,
          stageNotes: stage?.stageNotes,
          clearStageNotes: state.clearStageNotes,
        );
      } else if (insertAfterStageNumber != null &&
          stagePlanId != null) {
        // Insert between existing stages
        stageId = await _stagePlanRepository.insertStageAfter(
          stagePlanId: stagePlanId,
          routeId: routeId!,
          afterStageNumber: insertAfterStageNumber!,
          date: stage?.date,
          startCityId: stage?.startCity?.id ?? 0,
          endCityId: stage?.endCity?.id ?? 0,
          startAlbergueId: stage?.startAlbergue?.id ?? 0,
          endAlbergueId: stage?.endAlbergue?.id ?? 0,
          customStartNotes: stage?.customStartNotes,
          customEndNotes: stage?.customEndNotes,
          stageNotes: stage?.stageNotes,
        );
        await _repository.setShowNewLabelOnPlanTab(false);
      } else {
        stageId = await _stagePlanRepository.createStage(
          routeId: stagePlanId == null ? planRouteId : effectiveRouteId,
          stagePlanId: stagePlanId,
          date: stage?.date,
          startCityId: stage?.startCity?.id ?? 0,
          endCityId: stage?.endCity?.id ?? 0,
          startAlbergueId: stage?.startAlbergue?.id,
          endAlbergueId: stage?.endAlbergue?.id,
          customStartNotes: stage?.customStartNotes,
          customEndNotes: stage?.customEndNotes,
          stageNotes: stage?.stageNotes,
          planName: state.planName,
          trailRouteIds: stagePlanId == null && trail != null
              ? trail!.toStorageString()
              : null,
        );
        await _repository.setShowNewLabelOnPlanTab(false);
      }

      final finalNote = stage?.stageNotes;
      final noteAction = _noteChangedDuringSession
          ? resolveStageNoteAction(
              isUpdating ? _initialStageNote : null,
              finalNote,
            )
          : null;

      StagePlanModel? updatedPlan;
      final updatedStage = await _stagePlanRepository.getStageById(stageId);
      final effectiveStagePlanId =
          stagePlanId ?? updatedStage?.stagePlanId ?? stage?.stagePlanId;
      if (effectiveStagePlanId != null) {
        updatedPlan =
            await _stagePlanRepository.getStagePlanById(effectiveStagePlanId);
      }

      // Track stage note change (for both create and update flows).
      if (noteAction != null) {
        final planRoute = state.route;
        if (planRoute != null) {
          final stages = updatedPlan?.stages ?? [];
          final stageIndex =
              stages.indexWhere((s) => s.id == updatedStage?.id);
          GetIt.instance<IAnalyticsService>().track(
            StageNoteUpdatedEvent(
              routeId: planRoute.id,
              routeName: planRoute.routeName,
              stageNumber: stageIndex >= 0 ? stageIndex + 1 : 0,
              action: noteAction,
              noteLength: finalNote?.trim().length ?? 0,
            ),
          );
        }
      }

      // Track create stage event
      if (!isUpdating) {
        final isPlanJustCreated = stagePlanId == null;
        // Use cached route from state instead of fetching again
        final route = state.route;
        // Track create plan event
        if (isPlanJustCreated && route != null) {
          GetIt.instance<IAnalyticsService>().track(
            CreatePlanEvent(
              routeId: planRouteId,
              routeName: route.routeName,
              hasStartingDate: updatedPlan?.startingDate != null,
              source: 'manual',
              planType: planType?.analyticsValue,
              trailRouteCount: trail?.segments.length ?? 1,
            ),
          );
        }

        final stages = updatedPlan?.stages ?? [];
        final indexOfNewStage =
            stages.indexWhere((stage) => stage.id == updatedStage?.id);

        GetIt.instance<IAnalyticsService>().track(
          CreateStageEvent(
            routeId: effectiveRouteId,
            routeName: route?.routeName,
            stageNumber: indexOfNewStage + 1,
            date: updatedStage?.date?.toHumanReadableDate(),
            startingCityId: updatedStage?.startCity?.id,
            startingCityName: updatedStage?.startCity?.name,
            startingAlbergueId: updatedStage?.startAlbergue?.id,
            startingAlbergueName: updatedStage?.startAlbergue?.name,
            startingCustomAccomm: updatedStage?.customStartNotes,
            endingCityId: updatedStage?.endCity?.id,
            endingCityName: updatedStage?.endCity?.name,
            endingAlbergueId: updatedStage?.endAlbergue?.id,
            endingAlbergueName: updatedStage?.endAlbergue?.name,
            endingCustomAccomm: updatedStage?.customEndNotes,
            totalStages: stages.length,
            hasAlbergue: updatedStage?.startAlbergue != null ||
                updatedStage?.endAlbergue != null,
            isInsertBetween: insertAfterStageNumber != null,
          ),
        );

        // Update albergue of next stage if it's empty and the same city
        if (indexOfNewStage >= 0) {
          final nextStageIndex = indexOfNewStage + 1;
          if (nextStageIndex < stages.length) {
            final nextStage = stages[nextStageIndex];
            final isAlbergueEmpty = nextStage.startAlbergue == null &&
                nextStage.customStartNotes == null;
            final isSameCity =
                nextStage.startCity?.id == updatedStage?.endCity?.id;
            if (isAlbergueEmpty && isSameCity) {
              final nextStageUpdated = nextStage.copyWith(
                startAlbergue: updatedStage?.endAlbergue,
                customStartNotes: updatedStage?.customEndNotes,
              );
              await _stagePlanRepository.updateStage(nextStageUpdated);
            }
          }
        }
      }

      safeEmit(
        state.copyWith(
          saveStageStatus: SaveStageStatus.success,
          updatedStage: updatedStage,
          updatedPlan: updatedPlan,
        ),
      );
    } catch (e) {
      safeEmit(state.copyWith(saveStageStatus: SaveStageStatus.failure));
    }
  }
}
