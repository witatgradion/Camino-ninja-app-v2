import 'dart:async';
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class StagePlanResult {
  const StagePlanResult({
    this.completePlans = const [],
    this.incompletePlans = const [],
    this.rawPlanCount = 0,
  });

  final List<StagePlanModel> completePlans;
  final List<IncompletePlanInfo> incompletePlans;

  /// Total plans returned from DB before any filtering.
  final int rawPlanCount;
}

sealed class SyncPlansResult {
  const SyncPlansResult();
  bool get isSuccess => this is SyncPlansSuccess;
}

final class SyncPlansSuccess extends SyncPlansResult {
  const SyncPlansSuccess({
    this.stagesCompacted = 0,
    this.plansAffected = 0,
    this.multiTrailRouteCounts = const [],
  });

  /// Total stages whose `stage_number` was rewritten across all plans
  /// during this sync (Fix 5 — `_applySyncResponse` compaction).
  ///
  /// Temporary observability hook for the
  /// `fix/stage-sync-disappearing-stages` rollout.
  final int stagesCompacted;

  /// Number of plans that had at least one compacted stage.
  final int plansAffected;

  /// One entry per multi-trail plan that was included in the sync.
  /// Each entry is the number of route segments in that plan's
  /// trail descriptor. Empty when the batch had no multi-trail plans.
  final List<int> multiTrailRouteCounts;
}

final class SyncPlansNotLoggedIn extends SyncPlansResult {
  const SyncPlansNotLoggedIn();
}

final class SyncPlansApiError extends SyncPlansResult {
  const SyncPlansApiError(this.message, {this.multiTrailPlanCount = 0});
  final String message;

  /// Number of multi-trail plans in the failed sync batch.
  final int multiTrailPlanCount;
}

final class SyncPlansException extends SyncPlansResult {
  const SyncPlansException(
    this.error,
    this.stackTrace, {
    this.multiTrailPlanCount = 0,
  });
  final Object error;
  final StackTrace stackTrace;

  /// Number of multi-trail plans in the failed sync batch.
  final int multiTrailPlanCount;
}

class StagePlanRepository {
  StagePlanRepository(
    this._appDatabase,
    this._stagePlannerDatabase,
    this._networkService,
    this._appPreferences,
  );

  final AppDatabase _appDatabase;
  final StagePlannerDatabase _stagePlannerDatabase;
  final NetworkService _networkService;
  final AppPreferences _appPreferences;

  // Stream that emits when local data changes and sync is needed
  final _syncTrigger = StreamController<void>.broadcast();
  Stream<void> get onSyncNeeded => _syncTrigger.stream;

  void _notifySyncNeeded() {
    _syncTrigger.add(null);
  }

  void dispose() {
    _syncTrigger.close();
  }

  // Whether legacy date normalization has already run
  static bool _legacyDatesNormalized = false;

  /// Resets the static legacy-normalization guard. Tests under random
  /// ordering need this so a test that asserts first-run normalization
  /// behavior isn't silently skipped because an earlier test already
  /// flipped the flag.
  @visibleForTesting
  static void resetLegacyDatesNormalized() {
    _legacyDatesNormalized = false;
  }

  // Cache for route data to avoid redundant queries
  final Map<int, RouteEntity> _routeCache = {};
  final Map<int, List<RoutePointEntity>> _routePointsCache = {};

  void clearCache() {
    _routeCache.clear();
    _routePointsCache.clear();
  }

  Future<CityEntity> getCityByIdFromDb(int cityId) async {
    return _appDatabase.getCityById(cityId: cityId);
  }

  Future<List<RoutePointEntity>> getRoutePointsByRouteIdFromDb({
    required int routeId,
    int? startingCityId,
    int? destCityId,
  }) async {
    final routePoints = await _appDatabase.getRoutePointsByRouteId(
      routeId: routeId,
    );
    if (startingCityId != null && destCityId != null) {
      final startingCity = await getCityByIdFromDb(startingCityId);
      final destCity = await getCityByIdFromDb(destCityId);

      // Get route points for the current route
      final startingRoutePoint = startingCity.routePoints.firstWhere(
        (rp) => rp.routeId == routeId,
        orElse: () => startingCity.routePoints.first,
      );
      final destRoutePoint = destCity.routePoints.firstWhere(
        (rp) => rp.routeId == routeId,
        orElse: () => destCity.routePoints.first,
      );

      final startingPoint = routePoints.indexWhere(
        (element) => element.id == startingRoutePoint.id,
      );
      final destPoint = routePoints.indexWhere(
        (element) => element.id == destRoutePoint.id,
      );

      // Handle case where points are not found
      if (startingPoint == -1 || destPoint == -1) {
        return routePoints;
      }

      // Handle case where start is after destination
      // (invalid stage data)
      if (startingPoint > destPoint) {
        return routePoints.sublist(
          destPoint,
          startingPoint + 1,
        );
      }

      if (destPoint >= routePoints.length) {
        return routePoints;
      }

      return routePoints.sublist(startingPoint, destPoint + 1);
    }
    return routePoints;
  }

  Future<void> validateStagePlanner() async {
    try {
      return _stagePlannerDatabase.cleanupInvalidReferences(_appDatabase);
    } catch (e) {
      AppLogger.e(
        'Error validating stage planner',
        tag: 'StagePlanRepository',
        error: e,
      );
    }
  }

  // Stage Planner CRUD Operations

  /// Delete a stage plan and all its stages
  Future<void> deleteStagePlan(int stagePlanId) async {
    try {
      await _stagePlannerDatabase.deleteStagePlan(stagePlanId);
    } catch (e) {
      AppLogger.e(
        'Error deleting stage plan $stagePlanId',
        tag: 'StagePlanRepository',
        error: e,
      );
      rethrow;
    }
    _notifySyncNeeded();
  }

  /// Update the isImported flag of a stage plan
  Future<void> updateStagePlanIsImported({
    required int stagePlanId,
    required bool isImported,
  }) async {
    await _stagePlannerDatabase.updateStagePlanIsImported(
      stagePlanId: stagePlanId,
      isImported: isImported,
    );
  }

  /// Update the name of a stage plan
  Future<void> updateStagePlanName({
    required int stagePlanId,
    String? name,
  }) async {
    await _stagePlannerDatabase.updateStagePlanName(
      stagePlanId: stagePlanId,
      name: name,
    );
    _notifySyncNeeded();
  }

  /// Update the starting date of a stage plan
  Future<void> updatePlanStartingDate({
    required int stagePlanId,
    DateTime? startingDate,
  }) async {
    try {
      final dateStr = startingDate != null
          ? '${startingDate.year.toString().padLeft(4, '0')}-'
              '${startingDate.month.toString().padLeft(2, '0')}-'
              '${startingDate.day.toString().padLeft(2, '0')}'
          : null;
      await _stagePlannerDatabase.updateStagePlanStartingDate(
        stagePlanId: stagePlanId,
        startingDate: dateStr,
      );
      _notifySyncNeeded();
    } catch (e) {
      AppLogger.e(
        'Error updating starting date for '
        'plan $stagePlanId',
        tag: 'StagePlanRepository',
        error: e,
      );
      rethrow;
    }
  }

  /// Update the days to stay for a stage
  Future<void> updateStageDaysToStay({
    required int stageId,
    required int daysToStay,
  }) async {
    try {
      await _stagePlannerDatabase.updateStageDaysToStay(
        stageId: stageId,
        daysToStay: daysToStay,
      );
      _notifySyncNeeded();
    } catch (e) {
      AppLogger.e(
        'Error updating days to stay for stage $stageId',
        tag: 'StagePlanRepository',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> updateStagePlanUuids({
    required int stagePlanId,
    required String uuid,
    String? planUuid,
  }) async {
    await _stagePlannerDatabase.updateStagePlanUuids(
      stagePlanId: stagePlanId,
      uuid: uuid,
      planUuid: planUuid,
    );
    _notifySyncNeeded();
  }

  /// Create a stage (automatically creates plan if needed)
  Future<int> createStage({
    required int routeId,
    required int startCityId,
    required int endCityId,
    DateTime? date,
    int daysToStay = 1,
    int? stagePlanId,
    int? startAlbergueId,
    int? endAlbergueId,
    String? customStartNotes,
    String? customEndNotes,
    String? stageNotes,
    bool isImported = false,
    String? planName,
    String? trailRouteIds,
  }) async {
    try {
      int? finalStagePlanId;
      if (stagePlanId == null) {
        // Create new stage plan for this route
        finalStagePlanId = await _stagePlannerDatabase.createStagePlan(
          routeId: routeId,
          isImported: isImported,
          name: planName,
          trailRouteIds: trailRouteIds,
        );
      } else {
        // Use existing stage plan
        finalStagePlanId = stagePlanId;
      }

      // Create the stage
      final stageId = await _stagePlannerDatabase.createStage(
        stagePlanId: finalStagePlanId,
        routeId: routeId,
        date: date,
        daysToStay: daysToStay,
        startCityId: startCityId,
        endCityId: endCityId,
        startAlbergueId: startAlbergueId,
        endAlbergueId: endAlbergueId,
        customStartNotes: customStartNotes,
        customEndNotes: customEndNotes,
        stageNotes: stageNotes,
      );

      _notifySyncNeeded();
      return stageId;
    } catch (e) {
      AppLogger.e(
        'Error creating stage',
        tag: 'StagePlanRepository',
        error: e,
      );
      rethrow;
    }
  }

  /// Insert a stage after a given stage number,
  /// shifting subsequent stages.
  Future<int> insertStageAfter({
    required int stagePlanId,
    required int routeId,
    required int afterStageNumber,
    required int startCityId,
    required int endCityId,
    DateTime? date,
    int? startAlbergueId,
    int? endAlbergueId,
    String? customStartNotes,
    String? customEndNotes,
    String? stageNotes,
    int daysToStay = 1,
  }) async {
    try {
      // Shift existing stages to make room
      await _stagePlannerDatabase.shiftStageNumbersAfter(
        stagePlanId: stagePlanId,
        afterStageNumber: afterStageNumber,
      );

      // Create the new stage with explicit stage_number
      final stageId =
          await _stagePlannerDatabase.createStage(
        stagePlanId: stagePlanId,
        routeId: routeId,
        date: date,
        startCityId: startCityId,
        endCityId: endCityId,
        startAlbergueId: startAlbergueId,
        endAlbergueId: endAlbergueId,
        customStartNotes: customStartNotes,
        customEndNotes: customEndNotes,
        stageNotes: stageNotes,
        stageNumber: afterStageNumber + 1,
        daysToStay: daysToStay,
      );

      _notifySyncNeeded();
      return stageId;
    } catch (e) {
      AppLogger.e(
        'Error inserting stage after $afterStageNumber',
        tag: 'StagePlanRepository',
        error: e,
      );
      rethrow;
    }
  }

  /// Update a stage
  Future<void> updateStagePartial({
    required int stageId,
    int? stagePlanId,
    String? stageUuid,
    DateTime? date,
    int? daysToStay,
    int? startCityId,
    int? endCityId,
    int? startAlbergueId,
    int? endAlbergueId,
    String? customStartNotes,
    String? customEndNotes,
    String? stageNotes,
    bool clearStageNotes = false,
  }) async {
    try {
      var effectiveStageId = stageId;
      final planId = stagePlanId;
      final uuid = stageUuid?.trim();
      if (planId != null && uuid != null && uuid.isNotEmpty) {
        final match = await _stagePlannerDatabase.getStageByPlanAndUuid(
          stagePlanId: planId,
          stageUuid: uuid,
        );
        if (match != null) {
          effectiveStageId = match.id;
          AppLogger.d(
            '[SYNC_UUID] updateStagePartial resolved uuid: '
            'planId=$planId stageUuid=$uuid '
            'requestedStageId=$stageId resolvedStageId=$effectiveStageId',
            tag: 'StagePlanRepository',
          );
        } else {
          AppLogger.w(
            '[SYNC_UUID] updateStagePartial could not resolve uuid: '
            'planId=$planId stageUuid=$uuid fallbackStageId=$stageId',
            tag: 'StagePlanRepository',
          );
        }
      }
      await _stagePlannerDatabase.updateStagePartial(
        stageId: effectiveStageId,
        date: date,
        daysToStay: daysToStay,
        startCityId: startCityId,
        endCityId: endCityId,
        startAlbergueId: startAlbergueId,
        endAlbergueId: endAlbergueId,
        customStartNotes: customStartNotes,
        customEndNotes: customEndNotes,
        stageNotes: stageNotes,
        clearStageNotes: clearStageNotes,
      );
      _notifySyncNeeded();
    } catch (e) {
      AppLogger.e(
        'Error updating stage $stageId',
        tag: 'StagePlanRepository',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> updateStage(StageModel stage) async {
    try {
      var stageId = stage.id;
      final stagePlanId = stage.stagePlanId;
      final date = stage.date;
      final startCityId = stage.startCity?.id;
      final endCityId = stage.endCity?.id;
      final startAlbergueId = stage.startAlbergue?.id;
      final endAlbergueId = stage.endAlbergue?.id;
      final customStartNotes = stage.customStartNotes;
      final customEndNotes = stage.customEndNotes;
      final stageNotes = stage.stageNotes;
      final routeId = stage.routeId;
      final stageNumber = stage.stageNumber;
      if (stagePlanId == null || startCityId == null || endCityId == null) {
        throw Exception(
          'Stage plan ID, start city ID, and end city ID are required',
        );
      }
      final uuid = stage.stageUuid?.trim();
      if (uuid != null && uuid.isNotEmpty) {
        final match = await _stagePlannerDatabase.getStageByPlanAndUuid(
          stagePlanId: stagePlanId,
          stageUuid: uuid,
        );
        if (match != null) {
          stageId = match.id;
          AppLogger.d(
            '[SYNC_UUID] updateStage resolved uuid: '
            'planId=$stagePlanId stageUuid=$uuid '
            'requestedStageId=${stage.id} resolvedStageId=$stageId',
            tag: 'StagePlanRepository',
          );
        } else {
          AppLogger.w(
            '[SYNC_UUID] updateStage could not resolve uuid: '
            'planId=$stagePlanId stageUuid=$uuid '
            'fallbackStageId=${stage.id}',
            tag: 'StagePlanRepository',
          );
        }
      }
      if (stageId == null) {
        throw Exception('Stage ID (or resolvable stage UUID) is required');
      }
      await _stagePlannerDatabase.updateStage(
        StageEntity(
          id: stageId,
          stagePlanId: stagePlanId,
          routeId: routeId,
          stageUuid: uuid?.isNotEmpty == true ? uuid : stage.stageUuid,
          date: date,
          startCityId: startCityId,
          endCityId: endCityId,
          startAlbergueId: startAlbergueId,
          endAlbergueId: endAlbergueId,
          customStartNotes: customStartNotes,
          customEndNotes: customEndNotes,
          stageNotes: stageNotes,
          stageNumber: stageNumber,
          daysToStay: stage.daysToStay,
        ),
      );
      _notifySyncNeeded();
    } catch (e) {
      AppLogger.e(
        'Error updating stage ${stage.id}',
        tag: 'StagePlanRepository',
        error: e,
      );
      rethrow;
    }
  }

  /// Delete a stage (automatically deletes plan if it becomes empty)
  Future<void> deleteStage(int stageId) async {
    try {
      // Get the stage to find its stage plan
      final stage = await _stagePlannerDatabase.getStageById(stageId);
      if (stage == null) {
        throw Exception('Stage not found');
      }

      // Delete the stage
      await _stagePlannerDatabase.deleteStage(stageId);

      // Check if stage plan is now empty
      final remainingStages =
          await _stagePlannerDatabase.getStagesByStagePlanId(stage.stagePlanId);

      if (remainingStages.isEmpty) {
        // Delete the empty stage plan
        await _stagePlannerDatabase.deleteStagePlan(stage.stagePlanId);
      }
    } catch (e) {
      AppLogger.e(
        'Error deleting stage $stageId',
        tag: 'StagePlanRepository',
        error: e,
      );
      rethrow;
    }
    _notifySyncNeeded();
  }

  /// Reorder stages by updating their stage numbers.
  Future<void> reorderStages({
    required int stagePlanId,
    required Map<int, int> stageIdToNumber,
  }) async {
    try {
      await _stagePlannerDatabase.updateStageNumbers(
        stagePlanId: stagePlanId,
        stageIdToNumber: stageIdToNumber,
      );
      _notifySyncNeeded();
    } catch (e) {
      AppLogger.e(
        'Error reordering stages',
        tag: 'StagePlanRepository',
        error: e,
      );
      rethrow;
    }
  }

  /// Get the number of non-deleted stage plans (lightweight).
  Future<int> getStagePlanCount() => _stagePlannerDatabase.getStagePlanCount();

  /// Returns the starting date of the user's "active" plan, or `null` if no
  /// plan has one set.
  ///
  /// Active plan = the soonest upcoming stage plan's starting_date; falls
  /// back to the most recent past plan if no upcoming plan exists. Returns
  /// `null` when no plan has a starting date. Used for lightweight
  /// attribution on click-time events (e.g. `days_until_trip_start` on
  /// `booking_com_clicked`).
  ///
  /// Implemented as a single-row SQL lookup with `ORDER BY ... LIMIT 1`
  /// on the stage planner database; no Dart-side scan of all plans.
  Future<DateTime?> getActivePlanStartingDate() async {
    try {
      return await _stagePlannerDatabase.getActivePlanStartingDate();
    } catch (e) {
      AppLogger.w(
        'getActivePlanStartingDate failed',
        tag: 'StagePlanRepository',
        error: e,
      );
      return null;
    }
  }

  Future<StagePlanResult> getAllStagePlans() async {
    try {
      if (!_legacyDatesNormalized) {
        try {
          await _stagePlannerDatabase
              .normalizeLegacyDates();
        } catch (e) {
          AppLogger.e(
            'Legacy date normalization failed',
            error: e,
          );
        }
        _legacyDatesNormalized = true;
      }

      final plans =
          await _stagePlannerDatabase.getAllStagePlans();
      AppLogger.w(
        'getAllStagePlans: ${plans.length} raw plans '
        'from DB',
        tag: 'StagePlanRepository',
      );
      if (plans.isEmpty) return const StagePlanResult();

      // Batch fetch routes (cached) - handle missing routes
      // gracefully
      final routeIds = plans.map((p) => p.routeId).toSet().toList();
      final routeMap = <int, RouteEntity>{};
      for (final id in routeIds) {
        if (_routeCache.containsKey(id)) {
          routeMap[id] = _routeCache[id]!;
          continue;
        }
        try {
          final route = await _appDatabase.getRouteById(routeId: id);
          _routeCache[id] = route;
          routeMap[id] = route;
        } catch (e) {
          AppLogger.w(
            'getAllStagePlans: route $id not found '
            'in main DB',
            tag: 'StagePlanRepository',
            error: e,
          );
        }
      }

      // Batch fetch all stages for all plans (parallel)
      final stageFutures = plans.map(
        (plan) => _stagePlannerDatabase.getStagesByStagePlanId(plan.id),
      );
      final stageResults = await Future.wait(stageFutures);
      final allStageEntities = <int, List<StageEntity>>{};
      for (var i = 0; i < plans.length; i++) {
        allStageEntities[plans[i].id] = stageResults[i];
      }

      // Collect city/albergue IDs only for plans whose
      // routes are available
      final allCityIds = <int>{};
      final allAlbergueIds = <int>{};
      for (final plan in plans) {
        if (!routeMap.containsKey(plan.routeId)) continue;
        final stages = allStageEntities[plan.id] ?? [];
        for (final stage in stages) {
          allCityIds.add(stage.startCityId);
          allCityIds.add(stage.endCityId);
          if (stage.startAlbergueId != null) {
            allAlbergueIds.add(stage.startAlbergueId!);
          }
          if (stage.endAlbergueId != null) {
            allAlbergueIds.add(stage.endAlbergueId!);
          }
        }
      }

      // Include junction city IDs from trail descriptors
      // so cross-route stages can resolve junction cities.
      for (final plan in plans) {
        if (plan.trailRouteIds != null) {
          final descriptors = MultiRouteTrail.parseDescriptors(
            plan.trailRouteIds,
          );
          if (descriptors != null) {
            for (final d in descriptors) {
              if (d.junctionCityId != null) {
                allCityIds.add(d.junctionCityId!);
              }
            }
          }
        }
      }

      // Collect ALL route IDs needed: plan routes + trail
      // routes. Trail route IDs are extracted early so their
      // points are included in allRoutePoints for city fetch.
      final allNeededRouteIds = <int>{...routeMap.keys};
      for (final plan in plans) {
        if (plan.trailRouteIds != null) {
          final descriptors = MultiRouteTrail.parseDescriptors(
            plan.trailRouteIds,
          );
          if (descriptors != null) {
            for (final d in descriptors) {
              allNeededRouteIds.add(d.routeId);
            }
          }
        }
      }

      // Batch fetch route points for all needed routes
      final uncachedRoutePointIds = allNeededRouteIds
          .where((id) => !_routePointsCache.containsKey(id))
          .toList();
      if (uncachedRoutePointIds.isNotEmpty) {
        final rpFutures = uncachedRoutePointIds.map(
          (id) => _appDatabase.getRoutePointsByRouteId(
            routeId: id,
          ),
        );
        final rpResults = await Future.wait(rpFutures);
        for (var i = 0; i < uncachedRoutePointIds.length; i++) {
          _routePointsCache[uncachedRoutePointIds[i]] = rpResults[i];
        }
      }

      // Also cache routes for trail route IDs (for stage
      // conversion)
      for (final rid in allNeededRouteIds) {
        if (!_routeCache.containsKey(rid) &&
            !routeMap.containsKey(rid)) {
          try {
            final r = await _appDatabase.getRouteById(
              routeId: rid,
            );
            _routeCache[rid] = r;
            routeMap[rid] = r;
          } catch (_) {
            // Route not available
          }
        }
      }

      // Combine all route points for lite city fetch
      final allRoutePoints = <RoutePointEntity>[];
      for (final id in allNeededRouteIds) {
        allRoutePoints.addAll(_routePointsCache[id] ?? []);
      }

      // Batch fetch cities (lite) and albergues (lite)
      // in parallel
      final dataFutures = await Future.wait<Object>([
        _appDatabase.getCitiesByIds(
          allCityIds.toList(),
          allRoutePoints,
        ),
        _appDatabase.getAlberguesByIds(allAlbergueIds.toList()),
      ]);
      final cityMap = dataFutures[0] as Map<int, CityEntity>;
      final albergueMap = dataFutures[1] as Map<int, AlbergueEntity>;

      // Build stage models using cached/batched data
      final models = <StagePlanModel>[];
      final incomplete = <IncompletePlanInfo>[];

      for (final plan in plans) {
        final route = routeMap[plan.routeId];
        final stageEntities = allStageEntities[plan.id] ?? [];

        // Route not in main DB -- mark as incomplete
        if (route == null) {
          incomplete.add(
            IncompletePlanInfo(
              id: plan.id,
              routeId: plan.routeId,
              stageCount: stageEntities.length,
              createdAt: plan.createdAt,
              updatedAt: plan.updatedAt,
              name: plan.name,
              isImported: plan.isImported,
              uuid: plan.uuid,
              planUuid: plan.planUuid,
            ),
          );
          continue;
        }

        final routePoints = _routePointsCache[plan.routeId] ?? [];

        // Build trail for cross-route support
        MultiRouteTrail? trail;
        if (plan.trailRouteIds != null) {
          try {
            final tempPlan = StagePlanModel(
              id: plan.id,
              route: route,
              stages: const [],
              createdAt: plan.createdAt,
              trailRouteIds: plan.trailRouteIds,
            );
            trail = await buildTrailForPlan(tempPlan);

            // Ensure route points for trail routes are
            // cached.
            if (trail != null) {
              for (final rid in trail.routeIds) {
                if (!_routePointsCache.containsKey(rid)) {
                  _routePointsCache[rid] = await _appDatabase
                      .getRoutePointsByRouteId(
                    routeId: rid,
                  );
                }
              }
            }
          } catch (_) {
            // Fall back to single-route behavior
          }
        }

        final stages = <StageModel>[];
        for (final stageEntity in stageEntities) {
          try {
            final stageRoute = routeMap[stageEntity.routeId] ??
                _routeCache[stageEntity.routeId] ??
                route;
            final stageRoutePoints =
                _routePointsCache[stageEntity.routeId] ?? routePoints;
            stages.add(
              _convertToStageModelOptimized(
                stage: stageEntity,
                route: stageRoute,
                routePoints: stageRoutePoints,
                cityMap: cityMap,
                albergueMap: albergueMap,
                trail: trail,
                routePointsCache: _routePointsCache,
              ),
            );
          } catch (e) {
            // Skip stage in UI -- don't delete from DB
            AppLogger.w(
              'getAllStagePlans: stage '
              '${stageEntity.id} conversion failed '
              '(plan ${plan.id}, '
              'route ${plan.routeId}, '
              'cities ${stageEntity.startCityId}'
              '->${stageEntity.endCityId})',
              tag: 'StagePlanRepository',
              error: e,
            );
          }
        }

        // All stages failed conversion -- mark as
        // incomplete
        if (stages.isEmpty && stageEntities.isNotEmpty) {
          AppLogger.w(
            'getAllStagePlans: plan ${plan.id} all '
            '${stageEntities.length} stages failed '
            'conversion, marking incomplete',
            tag: 'StagePlanRepository',
          );
          incomplete.add(
            IncompletePlanInfo(
              id: plan.id,
              routeId: plan.routeId,
              stageCount: stageEntities.length,
              createdAt: plan.createdAt,
              updatedAt: plan.updatedAt,
              name: plan.name,
              isImported: plan.isImported,
              uuid: plan.uuid,
              planUuid: plan.planUuid,
            ),
          );
          continue;
        }

        if (stages.isEmpty) {
          AppLogger.w(
            'getAllStagePlans: plan ${plan.id} dropped '
            '(zero stage entities)',
            tag: 'StagePlanRepository',
          );
          continue;
        }

        // Sort stages by date (null dates go to the end)
        stages.sort((a, b) {
          final dateA = a.date;
          final dateB = b.date;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateA.compareTo(dateB);
        });

        models.add(
          StagePlanModel(
            id: plan.id,
            route: route,
            stages: stages,
            createdAt: plan.createdAt,
            updatedAt: plan.updatedAt,
            isImported: plan.isImported,
            name: plan.name,
            uuid: plan.uuid,
            planUuid: plan.planUuid,
            deletedAt: plan.deletedAt,
            trailRouteIds: plan.trailRouteIds,
            startingDate: plan.startingDate != null
                ? DateTime.tryParse(plan.startingDate!)
                : null,
          ),
        );
      }

      AppLogger.w(
        'getAllStagePlans result: ${models.length} '
        'complete, ${incomplete.length} incomplete, '
        '${plans.length - models.length - incomplete.length}'
        ' dropped',
        tag: 'StagePlanRepository',
      );

      // Sort plans: startingDate closer to today first,
      // plans without startingDate last, then by
      // createdAt DESC
      final today = _dateOnly(DateTime.now());
      models.sort((a, b) {
        final dateA = a.startingDate;
        final dateB = b.startingDate;

        if (dateA != null && dateB != null) {
          final daysDiffA =
              _dateOnly(dateA).difference(today).inDays.abs();
          final daysDiffB =
              _dateOnly(dateB).difference(today).inDays.abs();
          return daysDiffA.compareTo(daysDiffB);
        }
        if (dateA != null) return -1;
        if (dateB != null) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      return StagePlanResult(
        completePlans: models,
        incompletePlans: incomplete,
        rawPlanCount: plans.length,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Normalize a DateTime to date-only (year-month-day)
  /// to ignore time-of-day.
  DateTime _dateOnly(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// Haversine distance between two lat/lng points in
  /// meters. Replicates [RouteEntity._getDistance] which
  /// is private to that class.
  static double _haversineDistance(
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

  /// Computes distance/elevation stats from pre-stitched
  /// route points that may span multiple routes.
  RouteDistanceElevation _computeStatsFromPoints(
    List<RoutePointEntity> points,
    RouteEntity route,
  ) {
    if (points.isEmpty) {
      return RouteDistanceElevation(
        routeId: route.id,
        routeName: route.routeName,
        routeSubName: route.routeSubName,
        distance: 0,
        elevationGain: 0,
        elevationLoss: 0,
        minElevation: 0,
        maxElevation: 0,
        route: route,
      );
    }

    var routeLength = 0.0;
    var up = 0.0;
    var down = 0.0;
    var minAlt = double.infinity;
    var maxAlt = 0.0;

    for (var j = 0; j < points.length; j++) {
      final ele = points[j].elevation;

      if (maxAlt < ele) maxAlt = ele;
      if (minAlt > ele) minAlt = ele;

      if (j > 0) {
        final prev = points[j - 1];
        final dist = _haversineDistance(
          points[j].latitude,
          points[j].longitude,
          prev.latitude,
          prev.longitude,
        );
        final height = (ele - prev.elevation).abs();
        routeLength += sqrt(
          (dist * dist) + (height * height),
        );

        final eleDiff = ele - prev.elevation;
        if (eleDiff > 0) {
          up += eleDiff;
        } else if (eleDiff < 0) {
          down += eleDiff.abs();
        }
      }
    }

    return RouteDistanceElevation(
      routeId: route.id,
      routeName: route.routeName,
      routeSubName: route.routeSubName,
      distance: routeLength / 1000,
      elevationGain: up.toInt(),
      elevationLoss: down.toInt(),
      minElevation: minAlt.toInt(),
      maxElevation: maxAlt.toInt(),
      route: route,
    );
  }

  /// Stitches route points across multiple trail segments
  /// for a cross-route stage.
  List<RoutePointEntity> _getCrossRouteSelectedPoints({
    required List<
            ({
              TrailSegment segment,
              int fromCityId,
              int toCityId,
            })>
        segmentRanges,
    required Map<int, List<RoutePointEntity>> routePointsCache,
    required Map<int, CityEntity> cityMap,
  }) {
    final result = <RoutePointEntity>[];

    for (final range in segmentRanges) {
      final points =
          routePointsCache[range.segment.routeId];
      if (points == null || points.isEmpty) continue;

      final fromCity = cityMap[range.fromCityId];
      final toCity = cityMap[range.toCityId];
      if (fromCity == null || toCity == null) continue;

      final slice = _getSelectedRoutePoints(
        routePoints: points,
        startCity: fromCity,
        endCity: toCity,
        routeId: range.segment.routeId,
      );
      if (slice.isEmpty) continue;

      // Deduplicate at junction boundaries: if the last
      // point of the previous slice has the same lat/lng
      // as the first point of this slice, skip the
      // duplicate.
      if (result.isNotEmpty && slice.isNotEmpty) {
        final last = result.last;
        final first = slice.first;
        if (last.latitude == first.latitude &&
            last.longitude == first.longitude) {
          result.addAll(slice.skip(1));
          continue;
        }
      }

      result.addAll(slice);
    }

    return result;
  }

  /// Optimized conversion using pre-fetched data
  /// (no DB queries)
  StageModel _convertToStageModelOptimized({
    required StageEntity stage,
    required RouteEntity route,
    required List<RoutePointEntity> routePoints,
    required Map<int, CityEntity> cityMap,
    required Map<int, AlbergueEntity> albergueMap,
    MultiRouteTrail? trail,
    Map<int, List<RoutePointEntity>>? routePointsCache,
  }) {
    final startCity = cityMap[stage.startCityId];
    final endCity = cityMap[stage.endCityId];

    if (startCity == null || endCity == null) {
      throw Exception(
        'City not found for stage ${stage.id}',
      );
    }

    final startAlbergue = stage.startAlbergueId != null
        ? albergueMap[stage.startAlbergueId]
        : null;
    final endAlbergue =
        stage.endAlbergueId != null ? albergueMap[stage.endAlbergueId] : null;

    // Check for cross-route stage
    List<RoutePointEntity> selectedRoutePoints;
    RouteDistanceElevation stats;

    final segmentRanges = trail?.segmentsBetweenCities(
      startCity.id,
      endCity.id,
    );
    // Determine the correct route points for this stage.
    // For stages on a non-primary route, use that route's
    // points from cache instead of the primary route's.
    var stageFullPoints = routePoints;

    if (segmentRanges != null &&
        segmentRanges.length > 1 &&
        routePointsCache != null) {
      // Cross-route stage: stitch points from multiple
      // trail segments.
      selectedRoutePoints = _getCrossRouteSelectedPoints(
        segmentRanges: segmentRanges,
        routePointsCache: routePointsCache,
        cityMap: cityMap,
      );
      stats = _computeStatsFromPoints(
        selectedRoutePoints,
        route,
      );
      stageFullPoints = selectedRoutePoints;
    } else if (segmentRanges != null &&
        segmentRanges.length == 1 &&
        routePointsCache != null &&
        segmentRanges.first.segment.routeId != route.id) {
      // Single-segment stage on a non-primary route.
      // Use that segment's route points instead of the
      // primary route's.
      final segRouteId =
          segmentRanges.first.segment.routeId;
      final segPoints =
          routePointsCache[segRouteId] ?? [];
      selectedRoutePoints = _getSelectedRoutePoints(
        routePoints: segPoints,
        startCity: startCity,
        endCity: endCity,
        routeId: segRouteId,
      );
      stats = _computeStatsFromPoints(
        selectedRoutePoints,
        route,
      );
      stageFullPoints = segPoints;
    } else {
      // Single-route stage (existing logic).
      selectedRoutePoints = _getSelectedRoutePoints(
        routePoints: routePoints,
        startCity: startCity,
        endCity: endCity,
        routeId: route.id,
      );
      stats = route.calculateRouteStatistics(
        startingCity: startCity,
        destCity: endCity,
        currentRoutePoints: selectedRoutePoints,
      );
    }

    return StageModel(
      id: stage.id,
      routeId: route.id,
      stagePlanId: stage.stagePlanId,
      date: stage.date,
      startCity: startCity,
      endCity: endCity,
      startAlbergue: startAlbergue,
      endAlbergue: endAlbergue,
      customStartNotes: stage.customStartNotes,
      customEndNotes: stage.customEndNotes,
      stageNotes: stage.stageNotes,
      createdAt: stage.createdAt ?? DateTime.now(),
      updatedAt: stage.updatedAt,
      distance: stats.distance,
      minElevation: stats.minElevation,
      maxElevation: stats.maxElevation,
      elevationGain: stats.elevationGain,
      elevationLoss: stats.elevationLoss,
      points: stageFullPoints,
      selectedRoutePoints: selectedRoutePoints,
      stageNumber: stage.stageNumber,
      daysToStay: stage.daysToStay,
    );
  }

  /// Get selected route points between start and end city
  /// (no DB query)
  List<RoutePointEntity> _getSelectedRoutePoints({
    required List<RoutePointEntity> routePoints,
    required CityEntity startCity,
    required CityEntity endCity,
    required int routeId,
  }) {
    if (routePoints.isEmpty) return [];

    final startingRoutePoint = startCity.routePoints.firstWhere(
      (rp) => rp.routeId == routeId,
      orElse: () => startCity.routePoints.isNotEmpty
          ? startCity.routePoints.first
          : routePoints.first,
    );
    final destRoutePoint = endCity.routePoints.firstWhere(
      (rp) => rp.routeId == routeId,
      orElse: () => endCity.routePoints.isNotEmpty
          ? endCity.routePoints.first
          : routePoints.last,
    );

    var startIdx =
        routePoints.indexWhere((e) => e.id == startingRoutePoint.id);
    var endIdx = routePoints.indexWhere((e) => e.id == destRoutePoint.id);

    if (startIdx == -1 || endIdx == -1) {
      // Fall back to nearest-point search by lat/lng when
      // the city's route point ID is not found in the list.
      if (startIdx == -1) {
        startIdx = _findNearestRoutePointIndex(
          routePoints,
          startCity.latitude,
          startCity.longitude,
        );
      }
      if (endIdx == -1) {
        endIdx = _findNearestRoutePointIndex(
          routePoints,
          endCity.latitude,
          endCity.longitude,
        );
      }
      // If still can't resolve (empty list), return empty.
      if (startIdx == -1 || endIdx == -1) return [];
    }
    if (startIdx > endIdx) {
      return routePoints.sublist(endIdx, startIdx + 1);
    }
    return routePoints.sublist(startIdx, endIdx + 1);
  }

  /// Returns the index of the route point closest to [lat]/[lng]
  /// using squared Euclidean distance, or -1 if the list is empty.
  int _findNearestRoutePointIndex(
    List<RoutePointEntity> points,
    double lat,
    double lng,
  ) {
    if (points.isEmpty) return -1;
    var bestIdx = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < points.length; i++) {
      final dx = points[i].latitude - lat;
      final dy = points[i].longitude - lng;
      final dist = dx * dx + dy * dy;
      if (dist < bestDist) {
        bestDist = dist;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  Future<StagePlanModel> getStagePlanById(
    int stagePlanId,
  ) async {
    try {
      final plan = await _stagePlannerDatabase.getStagePlanById(stagePlanId);
      if (plan == null) {
        throw Exception('Stage plan not found');
      }

      // Use cache for route
      if (!_routeCache.containsKey(plan.routeId)) {
        _routeCache[plan.routeId] =
            await _appDatabase.getRouteById(routeId: plan.routeId);
      }
      final route = _routeCache[plan.routeId]!;

      // Heal any stages with null stage_number before
      // fetching so callers never see unnumbered stages.
      await _stagePlannerDatabase
          .healMissingStageNumbers(stagePlanId);

      // Use optimized batch fetch for stages
      final stages = await _getStagesByPlanIdOptimized(
        plan.id,
        route,
        trailRouteIds: plan.trailRouteIds,
      );

      return StagePlanModel(
        id: plan.id,
        route: route,
        stages: stages,
        createdAt: plan.createdAt,
        updatedAt: plan.updatedAt,
        isImported: plan.isImported,
        name: plan.name,
        uuid: plan.uuid,
        planUuid: plan.planUuid,
        deletedAt: plan.deletedAt,
        trailRouteIds: plan.trailRouteIds,
        startingDate: plan.startingDate != null
            ? DateTime.tryParse(plan.startingDate!)
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Optimized version using batch fetch.
  ///
  /// Handles multi-route plans by resolving each stage's
  /// actual route ID instead of assuming all stages belong
  /// to the plan's primary [route].
  ///
  /// When [trailRouteIds] is provided and describes a
  /// multi-route trail, cross-route stages are stitched
  /// from multiple trail segments.
  Future<List<StageModel>> _getStagesByPlanIdOptimized(
    int stagePlanId,
    RouteEntity route, {
    String? trailRouteIds,
  }) async {
    final stageEntities =
        await _stagePlannerDatabase.getStagesByStagePlanId(stagePlanId);
    if (stageEntities.isEmpty) return [];

    // Collect all unique route IDs from stages
    final uniqueRouteIds =
        stageEntities.map((s) => s.routeId).toSet();

    // Pre-populate cache for all routes + route points.
    // The plan's primary route may already be cached.
    for (final routeId in uniqueRouteIds) {
      if (!_routeCache.containsKey(routeId)) {
        try {
          _routeCache[routeId] =
              await _appDatabase.getRouteById(routeId: routeId);
        } catch (_) {
          // Route not available in main DB — stages
          // referencing it will fall back to the plan's
          // primary route.
          continue;
        }
      }
      if (!_routePointsCache.containsKey(routeId)) {
        _routePointsCache[routeId] =
            await _appDatabase.getRoutePointsByRouteId(
          routeId: routeId,
        );
      }
    }

    // Collect all city/albergue IDs needed
    final cityIds = <int>{};
    final albergueIds = <int>{};
    for (final s in stageEntities) {
      cityIds
        ..add(s.startCityId)
        ..add(s.endCityId);
      if (s.startAlbergueId != null) {
        albergueIds.add(s.startAlbergueId!);
      }
      if (s.endAlbergueId != null) {
        albergueIds.add(s.endAlbergueId!);
      }
    }

    // Build trail BEFORE loading cities so that all trail
    // route points are available for city route-point
    // association (needed for cross-route stage slicing).
    MultiRouteTrail? trail;
    if (trailRouteIds != null) {
      final descriptors =
          MultiRouteTrail.parseDescriptors(trailRouteIds);
      if (descriptors != null) {
        for (final d in descriptors) {
          if (d.junctionCityId != null) {
            cityIds.add(d.junctionCityId!);
          }
        }
      }

      try {
        final tempPlan = StagePlanModel(
          id: stagePlanId,
          route: route,
          stages: const [],
          createdAt: DateTime.now(),
          trailRouteIds: trailRouteIds,
        );
        trail = await buildTrailForPlan(tempPlan);

        // Cache route points for all trail routes (may
        // include routes not referenced by stage entities).
        if (trail != null) {
          for (final routeId in trail.routeIds) {
            if (!_routePointsCache.containsKey(routeId)) {
              _routePointsCache[routeId] =
                  await _appDatabase.getRoutePointsByRouteId(
                routeId: routeId,
              );
            }
          }
        }
      } catch (_) {
        // Fall back to single-route behavior
      }
    }

    // Combine route points across ALL cached routes
    // (stage routes + trail routes) so that cities get
    // full route-point associations for cross-route
    // lookups.
    final allRoutePoints = <RoutePointEntity>[];
    for (final points in _routePointsCache.values) {
      allRoutePoints.addAll(points);
    }

    // Parallel fetch: cities (lite) and albergues (lite)
    final futures = <Future<Object>>[
      _appDatabase.getCitiesByIds(
        cityIds.toList(),
        allRoutePoints,
      ),
      _appDatabase.getAlberguesByIds(albergueIds.toList()),
    ];

    final results = await Future.wait(futures);
    final cityMap = results[0] as Map<int, CityEntity>;
    final albergueMap = results[1] as Map<int, AlbergueEntity>;

    // Convert stages — use the correct route per stage
    final stages = <StageModel>[];
    for (final stageEntity in stageEntities) {
      try {
        final stageRoute =
            _routeCache[stageEntity.routeId] ?? route;
        final stageRoutePoints =
            _routePointsCache[stageEntity.routeId] ??
                _routePointsCache[route.id] ??
                [];
        stages.add(
          _convertToStageModelOptimized(
            stage: stageEntity,
            route: stageRoute,
            routePoints: stageRoutePoints,
            cityMap: cityMap,
            albergueMap: albergueMap,
            trail: trail,
            routePointsCache: _routePointsCache,
          ),
        );
      } catch (_) {
        // Skip stage in UI -- don't delete from DB
      }
    }

    return stages;
  }

  Future<StageModel?> getStageById(int stageId) async {
    try {
      final stage = await _stagePlannerDatabase.getStageById(stageId);
      if (stage == null) return null;

      // Collect IDs for parallel fetch
      final albergueIds = <int>[];
      if (stage.startAlbergueId != null) {
        albergueIds.add(stage.startAlbergueId!);
      }
      if (stage.endAlbergueId != null) {
        albergueIds.add(stage.endAlbergueId!);
      }

      final needsRoute = !_routeCache.containsKey(stage.routeId);
      final needsRoutePoints =
          !_routePointsCache.containsKey(stage.routeId);

      // Fetch route and route points first (needed for
      // lite city fetch)
      if (needsRoute) {
        _routeCache[stage.routeId] =
            await _appDatabase.getRouteById(
          routeId: stage.routeId,
        );
      }
      if (needsRoutePoints) {
        _routePointsCache[stage.routeId] =
            await _appDatabase.getRoutePointsByRouteId(
          routeId: stage.routeId,
        );
      }
      final routePoints = _routePointsCache[stage.routeId]!;

      // Load trail context from the parent plan so
      // cross-route stages get correct stats.
      MultiRouteTrail? trail;
      final plan = await _stagePlannerDatabase
          .getStagePlanById(stage.stagePlanId);
      if (plan?.trailRouteIds != null) {
        try {
          final route = _routeCache[stage.routeId]!;
          final tempPlan = StagePlanModel(
            id: stage.stagePlanId,
            route: route,
            stages: const [],
            createdAt: DateTime.now(),
            trailRouteIds: plan!.trailRouteIds,
          );
          trail = await buildTrailForPlan(tempPlan);

          // Cache route points for all trail routes
          if (trail != null) {
            for (final rId in trail.routeIds) {
              if (!_routePointsCache.containsKey(rId)) {
                _routePointsCache[rId] =
                    await _appDatabase
                        .getRoutePointsByRouteId(
                  routeId: rId,
                );
              }
            }
          }
        } catch (_) {
          // Fall back to single-route behavior
        }
      }

      // Collect city IDs including junction cities
      final cityIds = <int>{
        stage.startCityId,
        stage.endCityId,
      };
      if (plan?.trailRouteIds != null) {
        final descriptors = MultiRouteTrail.parseDescriptors(
          plan!.trailRouteIds,
        );
        if (descriptors != null) {
          for (final d in descriptors) {
            if (d.junctionCityId != null) {
              cityIds.add(d.junctionCityId!);
            }
          }
        }
      }

      // Parallel fetch cities (lite) and albergues (lite)
      final futures = <Future<Object>>[
        _appDatabase.getCitiesByIds(
          cityIds.toList(),
          routePoints,
        ),
        _appDatabase.getAlberguesByIds(albergueIds),
      ];

      final results = await Future.wait(futures);
      final cityMap =
          results[0] as Map<int, CityEntity>;
      final albergueMap =
          results[1] as Map<int, AlbergueEntity>;

      return _convertToStageModelOptimized(
        stage: stage,
        route: _routeCache[stage.routeId]!,
        routePoints: routePoints,
        cityMap: cityMap,
        albergueMap: albergueMap,
        trail: trail,
        routePointsCache:
            trail != null ? _routePointsCache : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get stages by stage plan id as models
  /// (hydrated + computed)
  Future<List<StageModel>> getStagesByPlanId(
    int stagePlanId,
  ) async {
    final plan = await _stagePlannerDatabase.getStagePlanById(stagePlanId);
    if (plan == null) {
      return [];
    }

    // Use cache for route
    if (!_routeCache.containsKey(plan.routeId)) {
      _routeCache[plan.routeId] =
          await _appDatabase.getRouteById(routeId: plan.routeId);
    }
    final route = _routeCache[plan.routeId]!;

    return _getStagesByPlanIdOptimized(
      stagePlanId,
      route,
      trailRouteIds: plan.trailRouteIds,
    );
  }

  /// Default fallback color value when a route has no
  /// legend color (Material Blue 400).
  static const _kDefaultColorValue = 0xFF42A5F5;

  /// Parses a route's hex legend color into an int value.
  static int _parseColorValue(RouteEntity route) {
    final hex = route.legendColor;
    if (hex != null && hex.isNotEmpty) {
      final cleaned = hex.replaceAll('#', '');
      if (cleaned.length == 6) {
        return int.tryParse('FF$cleaned', radix: 16) ??
            _kDefaultColorValue;
      }
    }
    return _kDefaultColorValue;
  }

  /// Reconstructs a [MultiRouteTrail] from the plan's
  /// persisted `trailRouteIds` column.
  ///
  /// For the new JSON format, segments are sliced at
  /// junction city boundaries. For the old comma-separated
  /// format, segments contain ALL cities for each route
  /// (backward compatible but less precise).
  ///
  /// Returns null if the plan has no trail data or only
  /// one route.
  Future<MultiRouteTrail?> buildTrailForPlan(
    StagePlanModel plan,
  ) async {
    final descriptors = MultiRouteTrail.parseDescriptors(
      plan.trailRouteIds,
    );
    if (descriptors == null || descriptors.length < 2) {
      return null;
    }

    final segments = <TrailSegment>[];

    for (var i = 0; i < descriptors.length; i++) {
      final desc = descriptors[i];
      final routeId = desc.routeId;

      // Fetch route entity (cached)
      RouteEntity route;
      if (_routeCache.containsKey(routeId)) {
        route = _routeCache[routeId]!;
      } else {
        try {
          route = await _appDatabase.getRouteById(
            routeId: routeId,
          );
          _routeCache[routeId] = route;
        } catch (e, st) {
          AppLogger.e(
            'Failed to fetch route $routeId for trail '
            'reconstruction',
            tag: 'StagePlanRepository',
            error: e,
            stackTrace: st,
          );
          continue;
        }
      }

      // Fetch all cities for this route
      final allCities =
          await _appDatabase.getCitiesByRouteId(
        routeId: routeId,
      );
      if (allCities.isEmpty) continue;

      final allCityIds =
          allCities.map((c) => c.id).toList();

      // Determine if we have junction info (new format)
      final hasJunctionInfo =
          desc.junctionCityId != null ||
              (i + 1 < descriptors.length &&
                  descriptors[i + 1].junctionCityId !=
                      null);

      List<int> slicedCityIds;
      if (!hasJunctionInfo) {
        // Old format — use all cities
        slicedCityIds = allCityIds;
      } else {
        slicedCityIds = _sliceSegmentCities(
          allCityIds: allCityIds,
          junctionCityId: desc.junctionCityId,
          nextJunctionCityId:
              i + 1 < descriptors.length
                  ? descriptors[i + 1].junctionCityId
                  : null,
        );
      }

      if (slicedCityIds.isEmpty) continue;

      segments.add(
        TrailSegment(
          routeId: routeId,
          routeName: route.routeName,
          routeSubName: route.routeSubName,
          colorValue: _parseColorValue(route),
          cityIds: slicedCityIds,
          junctionCityId: desc.junctionCityId,
        ),
      );
    }

    return segments.length > 1
        ? MultiRouteTrail(segments: segments)
        : null;
  }

  /// Slices a full route city list between junction
  /// points.
  ///
  /// - [junctionCityId]: the city where this segment
  ///   starts (from the previous route). For the first
  ///   segment this is null, so slicing starts from the
  ///   beginning.
  /// - [nextJunctionCityId]: the city where the NEXT
  ///   segment branches off. If present and found in
  ///   this route, the slice includes up to and including
  ///   that city.
  ///
  /// If the junction city is near the end of the list
  /// (no cities after it), the segment is reversed
  /// (the pilgrim walks backward along this route).
  List<int> _sliceSegmentCities({
    required List<int> allCityIds,
    required int? junctionCityId,
    required int? nextJunctionCityId,
  }) {
    var startIndex = 0;
    if (junctionCityId != null) {
      final jIdx = allCityIds.indexOf(junctionCityId);
      if (jIdx == -1) return allCityIds;

      // If junction is near the end, walk backward:
      // start from junction toward the beginning.
      if (jIdx >= allCityIds.length - 1) {
        final reversed = allCityIds.reversed.toList();
        final revStart =
            reversed.indexOf(junctionCityId);
        var endIdx = reversed.length;
        if (nextJunctionCityId != null) {
          final nIdx =
              reversed.indexOf(nextJunctionCityId);
          if (nIdx != -1) endIdx = nIdx + 1;
        }
        return reversed.sublist(revStart, endIdx);
      }

      // Normal direction: start at the junction city
      startIndex = jIdx;
    }

    var endIndex = allCityIds.length;
    if (nextJunctionCityId != null) {
      final nIdx =
          allCityIds.indexOf(nextJunctionCityId);
      if (nIdx != -1 && nIdx >= startIndex) {
        endIndex = nIdx + 1;
      }
    }

    return allCityIds.sublist(startIndex, endIndex);
  }

  // Share Operations

  Future<ApiResult<PlanShareLinkResponse>> sharePlan(
    String uuid,
  ) {
    return _networkService.sharePlan(uuid: uuid);
  }

  Future<ApiResult<SharedPlanResponse>> getSharedPlan(
    String code,
  ) {
    return _networkService.getSharedPlan(code: code);
  }

  // Sync Operations

  /// Check if user is currently logged in
  Future<bool> _isLoggedIn() async {
    final credential = await _appPreferences.getUserCredential();
    return credential?.accessToken != null;
  }

  /// Sync local plans with the server.
  /// Returns true if sync was successful, false otherwise.
  Future<SyncPlansResult> syncPlans() async {
    // Check if user is logged in
    if (!await _isLoggedIn()) {
      return const SyncPlansNotLoggedIn();
    }

    final multiTrailRouteCounts = <int>[];
    try {
      // 1. Read all local plans including soft-deleted
      var localPlans =
          await _stagePlannerDatabase.getAllStagePlansIncludingDeleted();

      // 1a. Heal any stages with null stage_number before
      // building the sync payload. Missing stage_number can
      // collide with position-based fallbacks on the server
      // and silently drop sibling stages on re-sync.
      var totalHealed = 0;
      for (final plan in localPlans) {
        totalHealed += await _stagePlannerDatabase
            .healMissingStageNumbers(plan.id);
      }
      if (totalHealed > 0) {
        AppLogger.w(
          'Healed $totalHealed stages with null '
          'stageNumber before sync; reloading plans',
          tag: 'StagePlanRepository',
        );
        localPlans = await _stagePlannerDatabase
            .getAllStagePlansIncludingDeleted();
      }

      // 2. Build sync request
      final syncPlans = <SyncPlanRequest>[];
      final sentStagesMap = <String, List<StageEntity>>{};
      for (final plan in localPlans) {
        final stages = List<StageEntity>.from(plan.stages)
          ..sort((a, b) {
            final an = a.stageNumber ?? 1 << 30;
            final bn = b.stageNumber ?? 1 << 30;
            if (an != bn) return an.compareTo(bn);
            return a.id.compareTo(b.id);
          });
        sentStagesMap[plan.uuid ?? ''] = stages;
        final missingLocalUuid = stages
            .where(
              (s) => s.stageUuid == null || s.stageUuid!.trim().isEmpty,
            )
            .length;
        AppLogger.d(
          '[SYNC_UUID] outbound plan ${plan.uuid ?? '-'} '
          'localPlanId=${plan.id} stages=${stages.length} '
          'missingLocalUuid=$missingLocalUuid',
          tag: 'StagePlanRepository',
        );

        // Build stage requests with stage_number
        final syncStages = <SyncStageRequest>[];
        for (final stage in stages) {
          if (stage.stageNumber == null) {
            AppLogger.w(
              'Stage with id=${stage.id} is missing '
              'stageNumber; sync payload would synthesize '
              'from position. Skipping.',
              tag: 'StagePlanRepository',
            );
            continue;
          }
          syncStages.add(
            SyncStageRequest(
              stageNumber: stage.stageNumber!,
              routeId: stage.routeId,
              date: stage.date != null
                  ? '${stage.date!.year.toString().padLeft(4, '0')}-'
                      '${stage.date!.month.toString().padLeft(2, '0')}-'
                      '${stage.date!.day.toString().padLeft(2, '0')}'
                  : null,
              startCityId: stage.startCityId,
              endCityId: stage.endCityId,
              startAlbergueId: stage.startAlbergueId,
              endAlbergueId: stage.endAlbergueId,
              customStartNotes: stage.customStartNotes,
              customEndNotes: stage.customEndNotes,
              stageNotes: stage.stageNotes,
              daysToStay: stage.daysToStay,
              createdAt:
                  stage.createdAt?.toUtc().toIso8601String(),
              updatedAt:
                  stage.updatedAt?.toUtc().toIso8601String(),
              stageUuid: stage.stageUuid,
            ),
          );
        }

        syncPlans.add(
          SyncPlanRequest(
            uuid: plan.uuid ?? '',
            routeId: plan.routeId,
            name: plan.name,
            isImported: plan.isImported,
            stages: syncStages,
            updatedAt: (plan.updatedAt ?? plan.createdAt)
                .toUtc()
                .toIso8601String(),
            startingDate: plan.startingDate,
            deletedAt: plan.deletedAt,
            trailRouteIds: plan.trailRouteIds,
          ),
        );

        if (plan.deletedAt == null && plan.trailRouteIds != null) {
          final descriptors =
              MultiRouteTrail.parseDescriptors(plan.trailRouteIds);
          if (descriptors != null && descriptors.isNotEmpty) {
            multiTrailRouteCounts.add(descriptors.length);
          }
        }
      }

      // 3. Get device ID
      final deviceId = await _appPreferences.getDeviceId();
      final deviceName = await _appPreferences.getDeviceName();

      // 4. Call API
      final result = await _networkService.syncStagePlanner(
        deviceId: deviceId,
        deviceName: deviceName,
        request: SyncStagePlannerRequest(plans: syncPlans),
      );

      // 5. Handle response
      if (result is ApiSuccess<SyncStagePlannerResponse>) {
        final response = result.data;
        final totalResponseStages =
            response.plans.fold<int>(0, (sum, p) => sum + p.stages.length);
        final missingServerUuid = response.plans
            .expand((p) => p.stages)
            .where(
              (s) => s.stageUuid == null || s.stageUuid!.trim().isEmpty,
            )
            .length;
        AppLogger.d(
          '[SYNC_UUID] inbound response plans=${response.plans.length} '
          'stages=$totalResponseStages missingServerUuid=$missingServerUuid',
          tag: 'StagePlanRepository',
        );
        final compaction =
            await _applySyncResponse(response, sentStagesMap);
        return SyncPlansSuccess(
          stagesCompacted: compaction.stagesCompacted,
          plansAffected: compaction.plansAffected,
          multiTrailRouteCounts: List.unmodifiable(multiTrailRouteCounts),
        );
      }

      final message = result is ApiFailure
          ? (result as ApiFailure).message
          : 'unknown_api_error';
      return SyncPlansApiError(
        message,
        multiTrailPlanCount: multiTrailRouteCounts.length,
      );
    } catch (e, st) {
      return SyncPlansException(
        e,
        st,
        multiTrailPlanCount: multiTrailRouteCounts.length,
      );
    }
  }

  /// Apply sync response: smart merge.
  ///
  /// Returns aggregated stage-number compaction counts for analytics —
  /// see `StageNumberCompactionEvent` and Fix 5 in
  /// docs/stage-sync-disappearing-rootcause.md.
  Future<({int stagesCompacted, int plansAffected})> _applySyncResponse(
    SyncStagePlannerResponse response,
    Map<String, List<StageEntity>> sentStagesMap,
  ) async {
    var stagesCompacted = 0;
    var plansAffected = 0;
    final responsePlans = response.plans;

    // Collect all non-deleted UUIDs from response to
    // preserve them locally (including null-route plans)
    final responseUuids = responsePlans
        .where((p) => p.deletedAt == null)
        .map((p) => p.uuid)
        .toList();

    // Upsert each plan from response
    for (final responsePlan in responsePlans) {
      if (responsePlan.deletedAt != null) continue;
      // Skip plans with no route — the app can't display
      // them yet
      if (responsePlan.routeId == null) {
        AppLogger.w(
          'Skipping sync plan ${responsePlan.uuid}: '
          'routeId is null',
        );
        continue;
      }

      final localPlanId = await _stagePlannerDatabase.upsertStagePlanFromSync(
        uuid: responsePlan.uuid,
        routeId: responsePlan.routeId!,
        name: responsePlan.name,
        isImported: responsePlan.isImported,
        planUuid: responsePlan.planUuid,
        startingDate: responsePlan.startingDate,
        createdAt: responsePlan.createdAt,
        updatedAt: responsePlan.updatedAt,
        trailRouteIds: responsePlan.trailRouteIds,
      );

      final sentStages = sentStagesMap[responsePlan.uuid] ?? [];
      final sentByNumber = <int, StageEntity>{
        for (final s in sentStages)
          if (s.stageNumber != null) s.stageNumber!: s,
      };
      final missingSentUuid = sentStages
          .where(
            (s) => s.stageUuid == null || s.stageUuid!.trim().isEmpty,
          )
          .length;
      final missingServerUuid = responsePlan.stages
          .where(
            (s) => s.stageUuid == null || s.stageUuid!.trim().isEmpty,
          )
          .length;
      AppLogger.d(
        '[SYNC_UUID] apply plan uuid=${responsePlan.uuid} '
        'localPlanId=$localPlanId sentStages=${sentStages.length} '
        'serverStages=${responsePlan.stages.length} '
        'missingSentUuid=$missingSentUuid '
        'missingServerUuid=$missingServerUuid',
        tag: 'StagePlanRepository',
      );
      final seenStageNumbers = <int>{};
      final matchedLocalIds = <int>[];
      for (final stage in responsePlan.stages) {
        // Index by stage_number, not by position — see
        // docs/stage-sync-disappearing-rootcause.md
        final sentLocalStageUuid =
            sentByNumber[stage.stageNumber]?.stageUuid;
        final localId = await _stagePlannerDatabase.upsertStageFromSync(
          stagePlanId: localPlanId,
          stageNumber: stage.stageNumber,
          routeId: stage.routeId ?? responsePlan.routeId!,
          date: stage.date,
          startCityId: stage.startCityId,
          endCityId: stage.endCityId,
          startAlbergueId: stage.startAlbergueId,
          endAlbergueId: stage.endAlbergueId,
          customStartNotes: stage.customStartNotes,
          customEndNotes: stage.customEndNotes,
          stageNotes: stage.stageNotes,
          daysToStay: stage.daysToStay,
          createdAt: stage.createdAt,
          updatedAt: stage.updatedAt,
          serverStageUuid: stage.stageUuid,
          sentLocalStageUuid: sentLocalStageUuid,
          seenStageNumbers: seenStageNumbers,
        );
        if (localId > 0) {
          matchedLocalIds.add(localId);
        }
      }
      await _stagePlannerDatabase.deleteStagesNotInIds(
        stagePlanId: localPlanId,
        localIds: matchedLocalIds,
      );

      // Compact stage_number to a contiguous 1..N sequence,
      // preserving order — see Fix 5 in
      // docs/stage-sync-disappearing-rootcause.md
      final localStages = await _stagePlannerDatabase
          .getStagesByStagePlanId(localPlanId);
      final sorted = List.of(localStages)
        ..sort((a, b) {
          final an = a.stageNumber ?? 1 << 30;
          final bn = b.stageNumber ?? 1 << 30;
          if (an != bn) return an.compareTo(bn);
          return a.id.compareTo(b.id);
        });
      final renumber = <int, int>{};
      for (var i = 0; i < sorted.length; i++) {
        final desired = i + 1;
        if (sorted[i].stageNumber != desired) {
          renumber[sorted[i].id] = desired;
        }
      }
      if (renumber.isNotEmpty) {
        AppLogger.d(
          '[SYNC_UUID] compacting stage_numbers '
          'planId=$localPlanId changes=${renumber.length}',
          tag: 'StagePlanRepository',
        );
        await _stagePlannerDatabase.updateStageNumbers(
          stagePlanId: localPlanId,
          stageIdToNumber: renumber,
        );
        stagesCompacted += renumber.length;
        plansAffected += 1;
      }
    }

    // Delete local plans not in response
    if (responseUuids.isNotEmpty) {
      await _stagePlannerDatabase.deleteLocalPlansNotInUuids(responseUuids);
    }

    // Hard-delete soft-deleted plans (sync confirmed
    // server received them)
    await _stagePlannerDatabase.hardDeleteSyncedPlans();

    // Clear cache since data changed
    clearCache();

    // Reset so normalization re-runs on next fetch
    // (synced plans from older devices may need it)
    _legacyDatesNormalized = false;

    return (
      stagesCompacted: stagesCompacted,
      plansAffected: plansAffected,
    );
  }
}
