import 'dart:async';

import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/stage_plan_share_service.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/sync_manager.dart';
import 'package:camino_ninja_flutter/utils/app_helper.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get_it/get_it.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage/storage.dart';

part 'plan_state.dart';

class PlanCubit extends Cubit<PlanState> with SafeEmitMixin {
  PlanCubit() : super(const PlanState());

  final StagePlanRepository _stagePlanRepository =
      GetIt.instance<StagePlanRepository>();
  final StagePlanShareService _stagePlanShareService =
      GetIt.instance<StagePlanShareService>();
  final Repository _repository = GetIt.instance<Repository>();
  final SyncManager _syncManager = GetIt.instance<SyncManager>();
  final AppPreferences _appPreferences = GetIt.instance<AppPreferences>();

  void init() {
    _syncManager.onSyncComplete = _onBackgroundSyncComplete;
  }

  void _onBackgroundSyncComplete(bool success) {
    if (success) {
      loadData(shouldShowLoading: false);
    }
  }

  Future<void> loadData({bool shouldShowLoading = true}) async {
    try {
      if (shouldShowLoading) {
        safeEmit(state.copyWith(initStatus: PlanInitStatus.loading));
      }
      final currentExpandedIds =
          state.stagePlans.where((p) => p.isExpanded).map((p) => p.id).toSet();
      final isFirstLoad = !state.hasLoadedOnce;
      final credential = await _appPreferences.getUserCredential();
      final isLoggedIn = credential?.accessToken != null;
      final result = await _stagePlanRepository.getAllStagePlans();
      unawaited(
        FirebaseCrashlytics.instance.log(
          'PlanCubit.loadData: '
          '${result.completePlans.length} complete, '
          '${result.incompletePlans.length} incomplete',
        ),
      );

      // Set Crashlytics custom keys for session context
      unawaited(
        FirebaseCrashlytics.instance.setCustomKey(
          'plan_raw_count',
          result.rawPlanCount,
        ),
      );
      unawaited(
        FirebaseCrashlytics.instance.setCustomKey(
          'plan_complete_count',
          result.completePlans.length,
        ),
      );
      unawaited(
        FirebaseCrashlytics.instance.setCustomKey(
          'plan_incomplete_count',
          result.incompletePlans.length,
        ),
      );

      // Detect and report silent plan data loss
      final droppedCount = result.rawPlanCount -
          result.completePlans.length -
          result.incompletePlans.length;

      if (droppedCount > 0) {
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            Exception(
              'Plans dropped during load: '
              '${result.rawPlanCount} raw, '
              '${result.completePlans.length} complete, '
              '${result.incompletePlans.length} incomplete, '
              '$droppedCount dropped',
            ),
            StackTrace.current,
            reason: 'plan_load_plans_dropped',
            fatal: false,
          ),
        );
      }

      // Fire diagnostic event on every load for
      // distribution visibility
      try {
        GetIt.instance<IAnalyticsService>().track(
          PlanLoadDiagnosticEvent(
            rawPlanCount: result.rawPlanCount,
            completePlanCount: result.completePlans.length,
            incompletePlanCount: result.incompletePlans.length,
            droppedPlanCount: droppedCount,
            isLoggedIn: isLoggedIn,
          ),
        );
      } catch (e) {
        AppLogger.e(
          'Diagnostic analytics failed',
          tag: 'PlanCubit',
          error: e,
        );
      }

      // One-shot fire of [StageUuidBackfillEvent] if the v9 migration
      // wrote a pending count to prefs. Read+fire+clear; idempotent
      // across restarts. Removed after 1-2 release cycles.
      unawaited(_fireAndClearPendingStageUuidBackfill());

      final updatedPlans = result.completePlans.mapIndexed((index, plan) {
        final wasExpanded = currentExpandedIds.contains(plan.id);
        final shouldExpand = isFirstLoad ? index == 0 : wasExpanded;
        return plan.copyWith(isExpanded: shouldExpand);
      }).toList();

      // Resolve route data for multi-route plans
      final multiRouteMap = await _resolveMultiRouteMaps(updatedPlans);

      safeEmit(
        state.copyWith(
          initStatus: PlanInitStatus.success,
          stagePlans: updatedPlans,
          incompletePlans: result.incompletePlans,
          isLoggedIn: isLoggedIn,
          hasLoadedOnce: true,
          multiRouteMap: multiRouteMap,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error loading plans',
        tag: 'PlanCubit',
        error: e,
      );
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'PlanCubit.loadData failed',
        ),
      );
      safeEmit(
        state.copyWith(
          initStatus: PlanInitStatus.failure,
        ),
      );
    }
  }

  /// Fetches RouteEntity for every unique route in each
  /// multi-route plan, parallelized.
  Future<Map<int, Map<int, RouteEntity>>> _resolveMultiRouteMaps(
    List<StagePlanModel> plans,
  ) async {
    final multiRoutePlans = plans.where((p) => p.isMultiRoute).toList();
    if (multiRoutePlans.isEmpty) return const {};

    // Collect all unique route IDs across multi-route plans
    final allRouteIds = <int>{};
    for (final plan in multiRoutePlans) {
      allRouteIds.addAll(plan.uniqueRouteIds);
    }

    // Fetch all routes in parallel
    final entries = await Future.wait(
      allRouteIds.map((id) async {
        try {
          final route = await _repository.getRouteById(id);
          return MapEntry(id, route);
        } catch (_) {
          return null;
        }
      }),
    );
    final globalMap = Map<int, RouteEntity>.fromEntries(
      entries.whereType<MapEntry<int, RouteEntity>>(),
    );

    // Build per-plan route maps
    final result = <int, Map<int, RouteEntity>>{};
    for (final plan in multiRoutePlans) {
      final planRouteMap = <int, RouteEntity>{};
      for (final routeId in plan.uniqueRouteIds) {
        final route = globalMap[routeId];
        if (route != null) {
          planRouteMap[routeId] = route;
        }
      }
      if (planRouteMap.length > 1) {
        result[plan.id] = planRouteMap;
      }
    }
    return result;
  }

  Future<void>? updatePlan(
    StagePlanModel copyWith, {
    bool preserveExpandedState = false,
  }) async {
    try {
      safeEmit(state.copyWith(planActionStatus: PlanActionStatus.loading));
      final plans = state.stagePlans;
      final updatedPlans = plans.map((plan) {
        if (plan.id == copyWith.id) {
          if (preserveExpandedState) {
            return copyWith.copyWith(isExpanded: plan.isExpanded);
          }
          return copyWith;
        }
        return plan;
      }).toList();
      safeEmit(
        state.copyWith(
          stagePlans: updatedPlans,
          planActionStatus: PlanActionStatus.success,
        ),
      );
    } catch (e) {
      AppLogger.e('Error updating plan', tag: 'PlanCubit', error: e);
      safeEmit(
        state.copyWith(
          planActionStatus: PlanActionStatus.failure,
        ),
      );
    }
  }

  Future<void> deletePlan(StagePlanModel plan) async {
    try {
      safeEmit(
        state.copyWith(
          planActionStatus: PlanActionStatus.loading,
        ),
      );
      final routeId = plan.route.id;
      final routeName = plan.route.routeName;
      await _stagePlanRepository.deleteStagePlan(plan.id);

      GetIt.instance<IAnalyticsService>().track(
        DeletePlanEvent(
          routeId: routeId,
          routeName: routeName,
          stageCount: plan.stages.length,
          hadStartingDate: plan.startingDate != null,
        ),
      );
      final plans = List.of(state.stagePlans)
        ..removeWhere((p) => p.id == plan.id);
      safeEmit(
        state.copyWith(
          stagePlans: plans,
          planActionStatus: PlanActionStatus.success,
        ),
      );
    } catch (e) {
      AppLogger.e('Error deleting plan', tag: 'PlanCubit', error: e);
      safeEmit(
        state.copyWith(
          planActionStatus: PlanActionStatus.failure,
        ),
      );
    }
  }

  Future<bool> syncPlans() async {
    safeEmit(state.copyWith(isSyncing: true));
    try {
      final success = await _syncManager.syncNow();
      if (success) {
        await loadData(shouldShowLoading: false);
      }
      return success;
    } catch (e) {
      AppLogger.e('Error syncing plans', tag: 'PlanCubit', error: e);
      return false;
    } finally {
      safeEmit(state.copyWith(isSyncing: false));
    }
  }

  Future<void> deleteIncompletePlan(IncompletePlanInfo plan) async {
    try {
      await _stagePlanRepository.deleteStagePlan(plan.id);
      final plans = List.of(state.incompletePlans)
        ..removeWhere((p) => p.id == plan.id);
      safeEmit(state.copyWith(incompletePlans: plans));
    } catch (e) {
      AppLogger.e(
        'Error deleting incomplete plan',
        tag: 'PlanCubit',
        error: e,
      );
    }
  }

  Future<void> deleteStage(StagePlanModel plan, StageModel stage) async {
    try {
      safeEmit(state.copyWith(planActionStatus: PlanActionStatus.loading));
      final routeId = plan.route.id;
      final routeName = plan.route.routeName;

      final stageIndex = plan.stages.indexWhere((s) => s.id == stage.id);

      await _stagePlanRepository.deleteStage(stage.id!);

      final stagesAfterDeletion = plan.stages.length - 1;
      GetIt.instance<IAnalyticsService>().track(
        DeleteStageEvent(
          routeId: routeId,
          routeName: routeName,
          stageNumber: stageIndex + 1,
          totalStages: stagesAfterDeletion,
          startingCityId: stage.startCity?.id,
          startingCityName: stage.startCity?.name,
          endingCityId: stage.endCity?.id,
          endingCityName: stage.endCity?.name,
        ),
      );

      final stages = List.of(plan.stages)..removeWhere((s) => s.id == stage.id);
      if (stages.isEmpty) {
        // Plan was soft-deleted by repository, remove from UI
        final newPlans = List.of(state.stagePlans)
          ..removeWhere((p) => p.id == plan.id);
        safeEmit(
          state.copyWith(
            stagePlans: newPlans,
            planActionStatus: PlanActionStatus.success,
          ),
        );
      } else {
        final updatedPlan = plan.copyWith(stages: stages);
        final newPlans = List.of(state.stagePlans).map((p) {
          if (p.id == plan.id) {
            return updatedPlan;
          }
          return p;
        }).toList();
        safeEmit(
          state.copyWith(
            stagePlans: newPlans,
            planActionStatus: PlanActionStatus.success,
          ),
        );
      }
    } catch (e) {
      AppLogger.e('Error deleting stage', tag: 'PlanCubit', error: e);
      safeEmit(
        state.copyWith(
          planActionStatus: PlanActionStatus.failure,
        ),
      );
    }
  }

  /// Update the note for a stage (null clears the note).
  Future<void> updateStageNote({
    required StagePlanModel plan,
    required StageModel stage,
    required String? note,
  }) async {
    final stageId = stage.id;
    if (stageId == null) return;
    final oldNote = stage.stageNotes;
    try {
      await _stagePlanRepository.updateStagePartial(
        stageId: stageId,
        stagePlanId: plan.id,
        stageUuid: stage.stageUuid,
        stageNotes: note,
        clearStageNotes: note == null,
      );
      // Match by UUID first, fall back to id, to avoid patching the
      // wrong in-memory stage when local ids have drifted post-sync.
      final uuid = stage.stageUuid?.trim();
      final hasUuid = uuid != null && uuid.isNotEmpty;
      final updatedStages = plan.stages.map((s) {
        final matches = hasUuid
            ? s.stageUuid?.trim() == uuid
            : s.id == stageId;
        return matches
            ? s.copyWith(stageNotes: note, clearStageNotes: note == null)
            : s;
      }).toList();
      final updatedPlan = plan.copyWith(stages: updatedStages);
      final newPlans = state.stagePlans.map((p) {
        return p.id == plan.id ? updatedPlan : p;
      }).toList();
      safeEmit(state.copyWith(stagePlans: newPlans));

      final action = resolveStageNoteAction(oldNote, note);
      if (action != null) {
        final stageIndex =
            plan.stages.indexWhere((s) => s.id == stageId);
        GetIt.instance<IAnalyticsService>().track(
          StageNoteUpdatedEvent(
            routeId: plan.route.id,
            routeName: plan.route.routeName,
            stageNumber: stageIndex >= 0 ? stageIndex + 1 : 0,
            action: action,
            noteLength: note?.trim().length ?? 0,
          ),
        );
      }
    } catch (e) {
      AppLogger.e(
        'Error updating stage note',
        tag: 'PlanCubit',
        error: e,
      );
      safeEmit(
        state.copyWith(planActionStatus: PlanActionStatus.failure),
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

  Future<StagePlanModel?> getSharedPlanPreview(String shortCode) async {
    final result = await _stagePlanRepository.getSharedPlan(shortCode);
    if (result is! ApiSuccess<SharedPlanResponse>) {
      return null;
    }
    return _stagePlanShareService.getSharedPlanFromResponse(result.data);
  }

  Future<int?> importSharedPlan(StagePlanModel selectedPlan) async {
    final result = await _stagePlanShareService.importPlans([selectedPlan]);
    return result.stagePlanIds.firstOrNull;
  }

  /// Reads the v9 stage_uuid backfill count the migration persisted
  /// to prefs, fires a one-shot [StageUuidBackfillEvent], and clears
  /// the key. Safe to call on every plan load — only fires once per
  /// migration run. Removed after 1-2 release cycles.
  Future<void> _fireAndClearPendingStageUuidBackfill() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(pendingStageUuidV9BackfillCountKey);
      if (count == null || count <= 0) return;
      // Claim the work first to prevent a racing loadData() from
      // double-firing the event. If track() throws after this point,
      // we lose one signal datapoint — preferable to dashboard
      // duplicates.
      await prefs.remove(pendingStageUuidV9BackfillCountKey);
      GetIt.instance<IAnalyticsService>().track(
        StageUuidBackfillEvent(backfilledCount: count),
      );
    } catch (e) {
      AppLogger.e(
        'Stage UUID backfill diagnostic analytics failed',
        tag: 'PlanCubit',
        error: e,
      );
    }
  }
}
