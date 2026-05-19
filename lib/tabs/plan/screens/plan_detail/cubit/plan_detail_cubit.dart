import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/plan/login_reminder_config.dart';
import 'package:camino_ninja_flutter/utils/app_helper.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'plan_detail_state.dart';

class PlanDetailCubit extends Cubit<PlanDetailState> with SafeEmitMixin {
  PlanDetailCubit({required this.planId}) : super(const PlanDetailState());

  final int planId;

  final Repository _repository = GetIt.instance<Repository>();
  final StagePlanRepository _stagePlanRepository =
      GetIt.instance<StagePlanRepository>();
  final AppPreferences _appPreferences = GetIt.instance<AppPreferences>();

  Future<void> init({
    StageModel? scrollToStage,
    int? scrollToStageId,
  }) async {
    emit(state.copyWith(initStatus: PlanDetailInitStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final credential = await _appPreferences.getUserCredential();
    final isLoggedIn = credential?.accessToken != null;
    final plan = await _stagePlanRepository.getStagePlanById(planId);
    final routeId = plan.route.id;

    // Multi-route plans must stitch route points across stages — the
    // plan's base routeId only covers a single segment of the trail.
    final routePoints = await resolveRoutePoints(plan);
    final altRoutePoints =
        await _repository.getAltRoutePointsWithValueByRouteId(
      routeId: routeId,
    );

    // Fetch route data for all unique routes (multi-route)
    Map<int, RouteEntity>? routeMap;
    MultiRouteTrail? trail;
    if (plan.isMultiRoute) {
      routeMap = await _fetchRouteMap(plan);
      trail = await _stagePlanRepository.buildTrailForPlan(
        plan,
      );
    }

    int? scrollToIndex;
    if (scrollToStage != null) {
      scrollToIndex =
          plan.stages.indexWhere((stage) => stage.id == scrollToStage.id);
    } else if (scrollToStageId != null) {
      scrollToIndex =
          plan.stages.indexWhere((stage) => stage.id == scrollToStageId);
    }
    final shouldScroll = scrollToIndex != null && scrollToIndex >= 0;

    safeEmit(
      state.copyWith(
        plan: plan,
        routePoints: routePoints,
        altRoutePoints: altRoutePoints,
        shouldShowOverlayLoading: shouldScroll,
        initStatus: PlanDetailInitStatus.success,
        routeMap: routeMap,
        trail: trail,
        isLoggedIn: isLoggedIn,
      ),
    );

    // Delay to allow widget tree to rebuild before scrolling
    if (shouldScroll) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      safeEmit(state.copyWith(scrollToIndex: scrollToIndex));
    }
  }

  /// Returns the route points that the Plan Detail map should
  /// render as the red "planned route" polyline.
  ///
  /// For multi-trail plans, concatenates each stage's
  /// `selectedRoutePoints` — those are already correctly stitched
  /// across routes (cross-route stages) or sliced to a city segment
  /// (single-route stages) by [StagePlanRepository]. Concatenating
  /// them yields the full cross-route trail.
  ///
  /// For single-route plans, falls back to the legacy lookup against
  /// the plan's base route ID.
  @visibleForTesting
  Future<List<RoutePointEntity>> resolveRoutePoints(
    StagePlanModel plan,
  ) async {
    if (plan.isMultiRoute) {
      return [
        for (final stage in plan.stages)
          ...?stage.selectedRoutePoints,
      ];
    }
    return _repository.getRoutePointsByRouteIdFromDb(
      routeId: plan.route.id,
    );
  }

  /// Fetches [RouteEntity] for every unique route ID in the
  /// plan's stages, in parallel.
  Future<Map<int, RouteEntity>> _fetchRouteMap(
    StagePlanModel plan,
  ) async {
    final uniqueIds = plan.uniqueRouteIds;
    final entries = await Future.wait(
      uniqueIds.map((id) async {
        try {
          final route = await _repository.getRouteById(id);
          return MapEntry(id, route);
        } catch (_) {
          return null;
        }
      }),
    );
    return Map.fromEntries(
      entries.whereType<MapEntry<int, RouteEntity>>(),
    );
  }

  /// Refresh the logged-in flag in state. Called when the auth state
  /// changes (e.g. the user logs in from the login reminder banner).
  Future<void> refreshLoginState() async {
    try {
      final credential = await _appPreferences.getUserCredential();
      final isLoggedIn = credential?.accessToken != null;
      if (isLoggedIn == state.isLoggedIn) return;
      safeEmit(state.copyWith(isLoggedIn: isLoggedIn));
    } catch (e) {
      AppLogger.e(
        'Error refreshing login state',
        tag: 'PlanDetailCubit',
        error: e,
      );
    }
  }

  Future<void> setOverlayLoading(bool value) async {
    safeEmit(state.copyWith(shouldShowOverlayLoading: value));
  }

  /// Set plan directly without DB fetch (when data is already available)
  Future<void> setPlanDirectly({
    required StagePlanModel plan,
    int? scrollToStageId,
  }) async {
    int? scrollToIndex;
    if (scrollToStageId != null) {
      scrollToIndex = plan.stages.indexWhere((s) => s.id == scrollToStageId);
    }
    final shouldScroll = scrollToIndex != null && scrollToIndex >= 0;

    safeEmit(
      state.copyWith(
        plan: plan,
        initStatus: PlanDetailInitStatus.success,
        shouldShowOverlayLoading: shouldScroll,
      ),
    );

    await _reorderStagesByRoutePosition();

    // Recompute scroll index after potential reorder
    if (shouldScroll && scrollToStageId != null) {
      final reorderedPlan = state.plan;
      scrollToIndex = reorderedPlan?.stages
          .indexWhere((s) => s.id == scrollToStageId) ?? -1;
    }

    // Delay to allow widget tree to rebuild before scrolling
    if (scrollToIndex != null && scrollToIndex >= 0) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      safeEmit(state.copyWith(scrollToIndex: scrollToIndex));
    }
  }

  /// Update a single stage in the current plan without DB fetch
  void _updateStageLocally(StageModel updatedStage) {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final uuid = updatedStage.stageUuid?.trim();
    final updatedStages = currentPlan.stages.map((s) {
      if (uuid != null &&
          uuid.isNotEmpty &&
          s.stageUuid?.trim() == uuid) {
        return updatedStage;
      }
      return s.id == updatedStage.id ? updatedStage : s;
    }).toList();

    safeEmit(
      state.copyWith(
        plan: currentPlan.copyWith(stages: updatedStages),
      ),
    );
  }

  Future<void>? reloadData({int? scrollToStageId}) async {
    try {
      safeEmit(state.copyWith(initStatus: PlanDetailInitStatus.loading));
      final updatedPlan = await _stagePlanRepository.getStagePlanById(planId);

      // Rebuild route map and trail if the plan is multi-route
      Map<int, RouteEntity>? routeMap = state.routeMap;
      var trail = state.trail;
      if (updatedPlan.isMultiRoute) {
        routeMap = await _fetchRouteMap(updatedPlan);
        trail = await _stagePlanRepository.buildTrailForPlan(
          updatedPlan,
        );
      }

      int? scrollToIndex;
      if (scrollToStageId != null) {
        scrollToIndex = updatedPlan.stages
            .indexWhere((stage) => stage.id == scrollToStageId);
      }
      final shouldScroll = scrollToIndex != null && scrollToIndex >= 0;

      safeEmit(
        state.copyWith(
          plan: updatedPlan,
          initStatus: PlanDetailInitStatus.success,
          shouldShowOverlayLoading: shouldScroll,
          routeMap: routeMap,
          trail: trail,
        ),
      );

      // Delay to allow widget tree to rebuild before scrolling
      if (shouldScroll) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        safeEmit(state.copyWith(scrollToIndex: scrollToIndex));
      }
    } catch (e) {
      AppLogger.e('Error reloading data', tag: 'PlanDetailCubit', error: e);
      safeEmit(state.copyWith(initStatus: PlanDetailInitStatus.failure));
    }
  }

  Future<void> updatePlanName(String? name) async {
    await _stagePlanRepository.updateStagePlanName(
      stagePlanId: planId,
      name: name,
    );
    GetIt.instance<IAnalyticsService>().track(
      PlanRenamedEvent(planId: planId, hasName: name != null),
    );
    final currentPlan = state.plan;
    if (currentPlan != null) {
      safeEmit(
        state.copyWith(
          plan: currentPlan.copyWith(name: name, clearName: name == null),
        ),
      );
    }
  }

  Future<void> deletePlan() async {
    try {
      final plan = state.plan;
      await _stagePlanRepository.deleteStagePlan(planId);

      if (plan != null) {
        GetIt.instance<IAnalyticsService>().track(
          DeletePlanEvent(
            routeId: plan.route.id,
            routeName: plan.route.routeName,
            stageCount: plan.stages.length,
            hadStartingDate: plan.startingDate != null,
          ),
        );
      }
    } catch (e) {
      AppLogger.e('Error deleting plan', tag: 'PlanDetailCubit', error: e);
      safeEmit(
        state.copyWith(planActionStatus: PlanDetailActionStatus.failure),
      );
    }
  }

  Future<void> deleteStage(int stageId) async {
    try {
      final currentPlan = state.plan;
      if (currentPlan == null) return;

      final routeId = currentPlan.route.id;
      final routeName = currentPlan.route.routeName;

      final stages = currentPlan.stages;
      final stageIndex = stages.indexWhere((stage) => stage.id == stageId);
      final matchedStage = stages.firstWhereOrNull((e) => e.id == stageId);
      await _stagePlanRepository.deleteStage(stageId);

      final stagesAfterDeletion = stages.length - 1;
      GetIt.instance<IAnalyticsService>().track(
        DeleteStageEvent(
          routeId: routeId,
          routeName: routeName,
          stageNumber: stageIndex + 1,
          totalStages: stagesAfterDeletion,
          startingCityId: matchedStage?.startCity?.id,
          startingCityName: matchedStage?.startCity?.name,
          endingCityId: matchedStage?.endCity?.id,
          endingCityName: matchedStage?.endCity?.name,
        ),
      );

      // Update state locally - remove the deleted stage
      final updatedStages = stages.where((s) => s.id != stageId).toList();
      safeEmit(
        state.copyWith(
          plan: currentPlan.copyWith(stages: updatedStages),
        ),
      );
    } catch (e) {
      AppLogger.e('Error deleting stage', tag: 'PlanDetailCubit', error: e);
      safeEmit(
        state.copyWith(planActionStatus: PlanDetailActionStatus.failure),
      );
    }
  }

  Future<void> updateStartingDate(DateTime? date) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final previousDate = currentPlan.startingDate;

    try {
      await _stagePlanRepository.updatePlanStartingDate(
        stagePlanId: planId,
        startingDate: date,
      );

      if (date != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final chosen =
            DateTime(date.year, date.month, date.day);
        final diff = chosen.difference(today).inDays;
        GetIt.instance<IAnalyticsService>().track(
          PlanStartingDateSetEvent(
            routeId: currentPlan.route.id,
            routeName: currentPlan.route.routeName,
            isFirstTime: previousDate == null,
            daysUntilStart: diff >= 0 ? diff : null,
          ),
        );
      } else {
        GetIt.instance<IAnalyticsService>().track(
          PlanStartingDateClearedEvent(
            routeId: currentPlan.route.id,
            routeName: currentPlan.route.routeName,
          ),
        );
      }

      safeEmit(
        state.copyWith(
          plan: currentPlan.copyWith(
            startingDate: date,
            clearStartingDate: date == null,
          ),
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Error updating starting date',
        tag: 'PlanDetailCubit',
        error: e,
      );
      safeEmit(
        state.copyWith(planActionStatus: PlanDetailActionStatus.failure),
      );
    }
  }

  Future<void> updateStageDaysToStay({
    required int stageId,
    required int daysToStay,
  }) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final matchedStage =
        currentPlan.stages.firstWhereOrNull((s) => s.id == stageId);
    final oldDaysToStay = matchedStage?.daysToStay ?? 1;
    final stageIndex =
        currentPlan.stages.indexWhere((s) => s.id == stageId);

    try {
      await _stagePlanRepository.updateStageDaysToStay(
        stageId: stageId,
        daysToStay: daysToStay,
      );

      GetIt.instance<IAnalyticsService>().track(
        StageDaysToStayUpdatedEvent(
          routeId: currentPlan.route.id,
          routeName: currentPlan.route.routeName,
          stageNumber: stageIndex + 1,
          oldValue: oldDaysToStay,
          newValue: daysToStay,
        ),
      );

      final updatedStages = currentPlan.stages.map((s) {
        return s.id == stageId
            ? s.copyWith(daysToStay: daysToStay)
            : s;
      }).toList();

      safeEmit(
        state.copyWith(
          plan: currentPlan.copyWith(stages: updatedStages),
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Error updating days to stay',
        tag: 'PlanDetailCubit',
        error: e,
      );
      safeEmit(
        state.copyWith(planActionStatus: PlanDetailActionStatus.failure),
      );
    }
  }

  Future<void> updateStageNote({
    required int stageId,
    required String? note,
  }) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;
    final stage =
        currentPlan.stages.firstWhereOrNull((s) => s.id == stageId);
    if (stage == null) return;
    final oldNote = stage.stageNotes;
    try {
      await _stagePlanRepository.updateStagePartial(
        stageId: stageId,
        stagePlanId: currentPlan.id,
        stageUuid: stage.stageUuid,
        stageNotes: note,
        clearStageNotes: note == null,
      );
      // Match by UUID first, fall back to id, to avoid patching the
      // wrong in-memory stage when local ids have drifted post-sync.
      final uuid = stage.stageUuid?.trim();
      final hasUuid = uuid != null && uuid.isNotEmpty;
      final updatedStages = currentPlan.stages.map((s) {
        final matches = hasUuid
            ? s.stageUuid?.trim() == uuid
            : s.id == stageId;
        return matches
            ? s.copyWith(stageNotes: note, clearStageNotes: note == null)
            : s;
      }).toList();
      safeEmit(
        state.copyWith(
          plan: currentPlan.copyWith(stages: updatedStages),
        ),
      );

      final action = resolveStageNoteAction(oldNote, note);
      if (action != null) {
        final stageIndex =
            currentPlan.stages.indexWhere((s) => s.id == stageId);
        GetIt.instance<IAnalyticsService>().track(
          StageNoteUpdatedEvent(
            routeId: currentPlan.route.id,
            routeName: currentPlan.route.routeName,
            stageNumber: stageIndex >= 0 ? stageIndex + 1 : 0,
            action: action,
            noteLength: note?.trim().length ?? 0,
          ),
        );
      }
    } catch (e) {
      AppLogger.e(
        'Error updating stage note',
        tag: 'PlanDetailCubit',
        error: e,
      );
      safeEmit(
        state.copyWith(planActionStatus: PlanDetailActionStatus.failure),
      );
    }
  }

  Future<void> updateStageStartCity({
    required StageModel stage,
    required CityEntity startCity,
    CityEntity? endCity,
  }) async {
    final current = _resolveStage(stage);
    if (current == null) return;

    final oldStartCity = current.startCity;
    final oldStartNotes = current.customStartNotes;
    final oldEndNotes = current.customEndNotes;
    var newStage = current.clearStartAlbergueInfo();
    newStage = newStage.copyWith(
      startCity: startCity,
      customStartNotes: oldStartNotes,
    );

    // This case end city not valid anymore, we need to update it
    if (endCity != null) {
      newStage = newStage.clearEndAlbergueInfo();
      newStage = newStage.copyWith(
        endCity: endCity,
        customEndNotes: oldEndNotes,
      );
    }

    try {
      await _stagePlanRepository.updateStage(newStage);
    } catch (e) {
      AppLogger.e(
        'Error saving stage start city',
        tag: 'PlanDetailCubit',
        error: e,
      );
      return;
    }

    final currentPlan = state.plan;
    if (currentPlan != null) {
      final stageIndex =
          currentPlan.stages.indexWhere((s) => s.id == current.id);
      final bothChanged = endCity != null;
      final field = bothChanged ? 'both' : 'start_city';
      GetIt.instance<IAnalyticsService>().track(
        StageCityUpdatedEvent(
          routeId: currentPlan.route.id,
          routeName: currentPlan.route.routeName,
          stageNumber: stageIndex + 1,
          field: field,
          oldCityName: oldStartCity?.name,
          newCityName: startCity.name,
        ),
      );
    }

    // Fetch updated stage with recalculated stats, fall back
    // to the locally-constructed model if the DB read fails.
    try {
      final updatedStage =
          await _stagePlanRepository.getStageById(current.id!);
      _updateStageLocally(updatedStage ?? newStage);
    } catch (e) {
      AppLogger.e(
        'Error reloading stage after save, using local model',
        tag: 'PlanDetailCubit',
        error: e,
      );
      _updateStageLocally(newStage);
    }
    await _reorderStagesByRoutePosition();
  }

  Future<void> updateStageEndCity({
    required CityEntity city,
    required StageModel stage,
  }) async {
    final current = _resolveStage(stage);
    if (current == null) return;

    final oldEndCity = current.endCity;
    final oldEndNotes = current.customEndNotes;
    var newStage = current.clearEndAlbergueInfo();
    newStage = newStage.copyWith(
      endCity: city,
      customEndNotes: oldEndNotes,
    );

    try {
      await _stagePlanRepository.updateStage(newStage);
    } catch (e) {
      AppLogger.e(
        'Error saving stage end city',
        tag: 'PlanDetailCubit',
        error: e,
      );
      return;
    }

    final currentPlan = state.plan;
    if (currentPlan != null) {
      final stageIndex =
          currentPlan.stages.indexWhere((s) => s.id == current.id);
      GetIt.instance<IAnalyticsService>().track(
        StageCityUpdatedEvent(
          routeId: currentPlan.route.id,
          routeName: currentPlan.route.routeName,
          stageNumber: stageIndex + 1,
          field: 'end_city',
          oldCityName: oldEndCity?.name,
          newCityName: city.name,
        ),
      );
    }

    // Fetch updated stage with recalculated stats, fall back
    // to the locally-constructed model if the DB read fails.
    try {
      final updatedStage =
          await _stagePlanRepository.getStageById(current.id!);
      _updateStageLocally(updatedStage ?? newStage);
    } catch (e) {
      AppLogger.e(
        'Error reloading stage after save, using local model',
        tag: 'PlanDetailCubit',
        error: e,
      );
      _updateStageLocally(newStage);
    }
    await _reorderStagesByRoutePosition();
  }

  Future<void> updateStageEndAlbergue({
    required StageModel stage,
    AlbergueEntity? albergue,
    String? customEndNotes,
  }) async {
    final current = _resolveStage(stage);
    if (current == null) return;

    var newStage = current.clearEndAlbergueInfo();
    newStage = newStage.copyWith(
      endAlbergue: albergue,
      customEndNotes: customEndNotes,
    );

    try {
      await _stagePlanRepository.updateStage(newStage);
    } catch (e) {
      AppLogger.e(
        'Error saving stage end albergue',
        tag: 'PlanDetailCubit',
        error: e,
      );
      return;
    }

    final currentPlan = state.plan;
    final stageIndex = (currentPlan?.stages ?? [])
        .indexWhere((s) => s.id == current.id);
    if (currentPlan != null) {
      final endAlbergueType = albergue != null
          ? 'albergue'
          : (customEndNotes != null && customEndNotes.isNotEmpty
              ? 'custom_text'
              : 'cleared');
      GetIt.instance<IAnalyticsService>().track(
        StageAlbergueUpdatedEvent(
          routeId: currentPlan.route.id,
          routeName: currentPlan.route.routeName,
          stageNumber: stageIndex + 1,
          field: 'end_albergue',
          type: endAlbergueType,
        ),
      );
    }

    // Update albergue of next stage if it's empty and the same city
    StageModel? nextStageUpdated;
    if (stageIndex >= 0) {
      final stages = state.plan?.stages ?? [];
      final nextStageIndex = stageIndex + 1;
      if (nextStageIndex < stages.length) {
        final nextStage = stages[nextStageIndex];
        final isAlbergueEmpty = nextStage.startAlbergue == null &&
            nextStage.customStartNotes == null;
        final isSameCity =
            nextStage.startCity?.id == newStage.endCity?.id;
        if (isAlbergueEmpty && isSameCity) {
          nextStageUpdated = nextStage.copyWith(
            startAlbergue: newStage.endAlbergue,
            customStartNotes: newStage.customEndNotes,
          );
          try {
            await _stagePlanRepository.updateStage(
              nextStageUpdated,
            );
          } catch (e) {
            AppLogger.e(
              'Error updating next stage albergue',
              tag: 'PlanDetailCubit',
              error: e,
            );
            nextStageUpdated = null;
          }
        }
      }
    }

    // Update locally - albergue changes don't affect stats
    _updateStageLocally(newStage);
    if (nextStageUpdated != null) {
      _updateStageLocally(nextStageUpdated);
    }
  }

  Future<void> updateStageStartAlbergue({
    required StageModel stage,
    AlbergueEntity? albergue,
    String? customStartNotes,
  }) async {
    final current = _resolveStage(stage);
    if (current == null) return;

    var newStage = current.clearStartAlbergueInfo();
    newStage = newStage.copyWith(
      startAlbergue: albergue,
      customStartNotes: customStartNotes,
    );

    try {
      await _stagePlanRepository.updateStage(newStage);
    } catch (e) {
      AppLogger.e(
        'Error saving stage start albergue',
        tag: 'PlanDetailCubit',
        error: e,
      );
      return;
    }

    final currentPlan = state.plan;
    if (currentPlan != null) {
      final stageIndex =
          currentPlan.stages.indexWhere((s) => s.id == current.id);
      final startAlbergueType = albergue != null
          ? 'albergue'
          : (customStartNotes != null && customStartNotes.isNotEmpty
              ? 'custom_text'
              : 'cleared');
      GetIt.instance<IAnalyticsService>().track(
        StageAlbergueUpdatedEvent(
          routeId: currentPlan.route.id,
          routeName: currentPlan.route.routeName,
          stageNumber: stageIndex + 1,
          field: 'start_albergue',
          type: startAlbergueType,
        ),
      );
    }

    // Update locally - albergue changes don't affect stats
    _updateStageLocally(newStage);
  }

  StageModel? _resolveStage(StageModel stage) {
    final stages = state.plan?.stages;
    if (stages == null) return null;
    final uuid = stage.stageUuid?.trim();
    if (uuid != null && uuid.isNotEmpty) {
      final byUuid = stages.firstWhereOrNull(
        (s) => s.stageUuid?.trim() == uuid,
      );
      if (byUuid != null) return byUuid;
    }
    final byId = stages.firstWhereOrNull((s) => s.id == stage.id);
    if (byId != null) return byId;
    return null;
  }

  /// Reorder stages to match the route's city sequence.
  Future<void> _reorderStagesByRoutePosition() async {
    final currentPlan = state.plan;
    if (currentPlan == null || currentPlan.stages.length <= 1) {
      return;
    }

    try {
      final cities = await _repository.getCitiesByRouteIdFromDb(
        currentPlan.route.id,
      );

      // Build position lookup: cityId -> index in route
      final cityPositionMap = <int, int>{};
      for (var i = 0; i < cities.length; i++) {
        cityPositionMap[cities[i].id] = i;
      }

      // Sort stages by start city position on the route.
      // Use original index as fallback for unknown cities
      // to preserve their relative position.
      final sortedStages =
          List<StageModel>.from(currentPlan.stages);

      // Pre-build index map to avoid O(n) indexOf calls
      // inside the comparator.
      final originalIndexMap = <StageModel, int>{};
      for (var i = 0; i < currentPlan.stages.length; i++) {
        originalIndexMap[currentPlan.stages[i]] = i;
      }

      sortedStages.sort((a, b) {
        final indexA = originalIndexMap[a] ?? 0;
        final indexB = originalIndexMap[b] ?? 0;
        final posA = cityPositionMap[a.startCity?.id] ??
            (cities.length + indexA);
        final posB = cityPositionMap[b.startCity?.id] ??
            (cities.length + indexB);
        return posA.compareTo(posB);
      });

      // Check if order actually changed
      var orderChanged = false;
      for (var i = 0; i < sortedStages.length; i++) {
        if (sortedStages[i].id != currentPlan.stages[i].id) {
          orderChanged = true;
          break;
        }
      }

      if (!orderChanged) return;

      // Build stageId -> new stage_number map
      final stageIdToNumber = <int, int>{};
      for (var i = 0; i < sortedStages.length; i++) {
        if (sortedStages[i].id != null) {
          stageIdToNumber[sortedStages[i].id!] = i + 1;
        }
      }

      await _stagePlanRepository.reorderStages(
        stagePlanId: currentPlan.id,
        stageIdToNumber: stageIdToNumber,
      );

      safeEmit(
        state.copyWith(
          plan: currentPlan.copyWith(stages: sortedStages),
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Error reordering stages',
        tag: 'PlanDetailCubit',
        error: e,
      );
    }
  }

  Future<bool> checkIfEndCityStillValid({
    required CityEntity startCity,
    required StageModel stage,
  }) async {
    final endCity = stage.endCity;
    if (endCity == null) {
      return false;
    }
    final cities = await _repository.getCitiesByRouteIdFromDb(stage.routeId);
    final startCityIndex = cities.indexWhere((c) => c.id == startCity.id);
    final endCityIndex = cities.indexWhere((c) => c.id == endCity.id);
    return endCityIndex > startCityIndex;
  }

  /// Reload the current plan from DB (e.g. after cloud sync).
  Future<void> reloadPlan() async {
    try {
      final plan = await _stagePlanRepository.getStagePlanById(planId);
      safeEmit(state.copyWith(plan: plan));
    } catch (e) {
      AppLogger.e(
        'Error reloading plan after sync',
        tag: 'PlanDetailCubit',
        error: e,
      );
    }
  }

  Future<bool> isLoggedIn() async {
    final userrCredential = await _repository.getCredential();
    return userrCredential.isLoggedIn;
  }

  Future<bool> shouldUpgradeToUseFeature() async {
    final optionalUpgradeMinBuild =
        await _repository.getOptionalUpgradeMinBuild();
    if (optionalUpgradeMinBuild == null) {
      return false;
    }
    return AppHelper.shouldUpgradeToUseFeature(optionalUpgradeMinBuild);
  }
}
