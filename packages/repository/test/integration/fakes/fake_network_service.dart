import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:remote_data/remote_data.dart';

/// Dio [HttpClientAdapter] that hard-fails on every request.
///
/// We install this on the [Dio] instance handed to the real
/// [NetworkService] super-constructor so that any method on
/// [FakeNetworkService] that the integration tests have NOT
/// explicitly overridden cannot silently hit the network or
/// surface a vague Dio error. Instead the test crashes with an
/// explicit message naming the offending method/URL.
///
/// If a new test exercises a code path we haven't fake-covered,
/// the throw here is the signal to either (a) add an override
/// on [FakeNetworkService] or (b) seed the relevant remote
/// state in-memory.
class _ThrowingHttpAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw StateError(
      'FakeNetworkService received an unexpected real-Dio '
      'request: ${options.method} ${options.uri}. Add an '
      'override on FakeNetworkService or seed remote state '
      'instead of letting the real Dio fire.',
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Builds a [Dio] whose adapter throws on any unexpected request.
///
/// Extracted into a top-level helper because Dart super-constructor
/// invocations require an expression — we need somewhere to do the
/// `..httpClientAdapter = ...` cascade before passing the instance up.
Dio _buildThrowingDio() {
  return Dio()..httpClientAdapter = _ThrowingHttpAdapter();
}

/// Configures how the fake responds to a `syncStagePlanner` call.
///
/// `succeed` (default) merges the request into the in-memory remote
/// state and returns it. `apiError`, `exception`, and `partial` are
/// used by tests that need to assert error/recovery behavior.
sealed class _FakeSyncMode {
  const _FakeSyncMode();
}

class _SucceedMode extends _FakeSyncMode {
  const _SucceedMode();
}

class _ApiErrorMode extends _FakeSyncMode {
  const _ApiErrorMode(this.message);
  final String message;
}

class _ExceptionMode extends _FakeSyncMode {
  const _ExceptionMode(this.error);
  final Object error;
}

class _PartialMode extends _FakeSyncMode {
  const _PartialMode(this.failAtStageIndex);
  final int failAtStageIndex;
}

/// In-memory remote-side state, keyed by plan UUID.
class FakeRemotePlan {
  FakeRemotePlan({
    required this.uuid,
    required this.routeId,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.isImported = false,
    this.planUuid,
    this.startingDate,
    this.deletedAt,
    this.trailRouteIds,
    List<FakeRemoteStage>? stages,
  }) : stages = stages ?? <FakeRemoteStage>[];

  String uuid;
  int? routeId;
  String? name;
  bool isImported;
  String? planUuid;
  String? startingDate;
  String createdAt;
  String updatedAt;
  String? deletedAt;
  String? trailRouteIds;
  List<FakeRemoteStage> stages;
}

class FakeRemoteStage {
  FakeRemoteStage({
    required this.stageNumber,
    required this.startCityId,
    required this.endCityId,
    this.routeId,
    this.date,
    this.startAlbergueId,
    this.endAlbergueId,
    this.customStartNotes,
    this.customEndNotes,
    this.stageNotes,
    this.daysToStay,
    this.createdAt,
    this.updatedAt,
    this.stageUuid,
  });

  int stageNumber;
  int? routeId;
  String? date;
  int startCityId;
  int endCityId;
  int? startAlbergueId;
  int? endAlbergueId;
  String? customStartNotes;
  String? customEndNotes;
  String? stageNotes;
  int? daysToStay;
  String? createdAt;
  String? updatedAt;
  String? stageUuid;
}

/// Hand-rolled fake for [NetworkService] focused on `syncStagePlanner`.
///
/// Subclasses [NetworkService] (passing a [Dio] wired to a throwing
/// [HttpClientAdapter] to super) and overrides only the method
/// exercised by the integration tests. Any other inherited method
/// that ultimately hits the underlying [Dio] will throw a loud
/// [StateError] naming the method+URL — surgical and noisy, with no
/// risk of a real-Dio request slipping out from under a test.
///
/// Configuration verbs:
///   - [succeed] — default merge-and-return behavior.
///   - [failWithApiError] — return `ApiFailure(message)`.
///   - [throwException] — throw an arbitrary [Object] (caught as
///     `SyncPlansException` by the repository).
///   - [partialFailure] — merge stages up to `failAtStageIndex` then
///     return `ApiFailure`, simulating a mid-write disconnect.
///   - [seedRemotePlan] — pre-populate remote-side state to model a
///     "second device" or pre-existing cloud plan.
class FakeNetworkService extends NetworkService {
  FakeNetworkService() : super(_buildThrowingDio());

  /// Each request the repository makes, in call order.
  final List<SyncStagePlannerRequest> recordedRequests = [];

  /// Each (deviceId, deviceName) pair the repository submits.
  final List<({String deviceId, String? deviceName})> recordedDeviceInfo = [];

  /// In-memory remote state, keyed by plan UUID.
  final Map<String, FakeRemotePlan> remotePlans = {};

  _FakeSyncMode _mode = const _SucceedMode();

  /// When non-null, every merged stage's `updatedAt` is overwritten
  /// with this sentinel before the response is built. Tests use this
  /// to prove local DB rows actually came from the response (and not
  /// from the pre-sync local state) — `updatedAt` is not a value the
  /// device originally wrote, so its presence in local post-sync is
  /// load-bearing evidence that `_applySyncResponse` ran.
  ///
  /// Default null preserves the existing behavior for tests that
  /// rely on the request's `updatedAt` echoing through unchanged.
  String? serverUpdatedAtSentinel;

  /// Reset the response mode to the default merge behavior.
  void succeed() => _mode = const _SucceedMode();

  /// Configure the next call(s) to return an `ApiFailure(message)`.
  void failWithApiError(String message) =>
      _mode = _ApiErrorMode(message);

  /// Configure the next call(s) to throw [error] (caught as
  /// `SyncPlansException` by the repository).
  void throwException(Object error) => _mode = _ExceptionMode(error);

  /// Configure a partial-success response: merges all incoming plans
  /// up to and including the (planIndex, stageIndex) reaching the
  /// global stage counter [failAtStageIndex], then returns an
  /// `ApiFailure` to simulate the connection dying mid-write.
  ///
  /// Stages already merged into [remotePlans] before the failure
  /// remain there — that's the realistic case the integration test
  /// asserts recovery against.
  void partialFailure({required int failAtStageIndex}) =>
      _mode = _PartialMode(failAtStageIndex);

  /// Seed remote state for tests that simulate a "remote-only" change.
  void seedRemotePlan(FakeRemotePlan plan) {
    remotePlans[plan.uuid] = plan;
  }

  @override
  Future<ApiResult<SyncStagePlannerResponse>> syncStagePlanner({
    required String deviceId,
    required SyncStagePlannerRequest request,
    String? deviceName,
  }) async {
    recordedRequests.add(request);
    recordedDeviceInfo.add(
      (deviceId: deviceId, deviceName: deviceName),
    );

    final mode = _mode;

    if (mode is _ExceptionMode) {
      // ignore: only_throw_errors
      // Intentionally throws Object so we can simulate non-Error /
      // non-Exception throwables hitting the catch-all in `syncPlans`.
      throw mode.error;
    }

    if (mode is _ApiErrorMode) {
      return ApiFailure(mode.message);
    }

    if (mode is _PartialMode) {
      _applyRequestUpToStage(request, mode.failAtStageIndex);
      return const ApiFailure('partial_sync_failed');
    }

    // _SucceedMode: merge everything and return remote state for the
    // plans involved in this call (matching real server behavior).
    _applyRequest(request);
    return ApiSuccess(_buildResponse(request));
  }

  void _applyRequest(SyncStagePlannerRequest request) {
    for (final plan in request.plans) {
      _mergePlan(plan, plan.stages.length);
    }
  }

  void _applyRequestUpToStage(
    SyncStagePlannerRequest request,
    int failAtStageIndex,
  ) {
    var stagesProcessed = 0;
    for (final plan in request.plans) {
      if (stagesProcessed >= failAtStageIndex) break;
      final stagesToTake =
          (failAtStageIndex - stagesProcessed).clamp(0, plan.stages.length);
      _mergePlan(plan, stagesToTake);
      stagesProcessed += stagesToTake;
    }
  }

  void _mergePlan(SyncPlanRequest plan, int stagesToMerge) {
    final now = DateTime.now().toUtc().toIso8601String();
    final existing = remotePlans[plan.uuid];

    if (plan.deletedAt != null) {
      // Soft-delete propagation: mark deleted but keep the row so
      // the response can still echo it.
      if (existing != null) {
        existing
          ..deletedAt = plan.deletedAt
          ..updatedAt = plan.updatedAt;
      } else {
        remotePlans[plan.uuid] = FakeRemotePlan(
          uuid: plan.uuid,
          routeId: plan.routeId,
          createdAt: now,
          updatedAt: plan.updatedAt,
          name: plan.name,
          isImported: plan.isImported,
          startingDate: plan.startingDate,
          deletedAt: plan.deletedAt,
          trailRouteIds: plan.trailRouteIds,
        );
      }
      return;
    }

    final stagesSlice = plan.stages.take(stagesToMerge).toList();
    if (existing == null) {
      remotePlans[plan.uuid] = FakeRemotePlan(
        uuid: plan.uuid,
        routeId: plan.routeId,
        createdAt: now,
        updatedAt: plan.updatedAt,
        name: plan.name,
        isImported: plan.isImported,
        startingDate: plan.startingDate,
        trailRouteIds: plan.trailRouteIds,
        stages: _mergeStages(<FakeRemoteStage>[], stagesSlice),
      );
      return;
    }

    existing
      ..routeId = plan.routeId ?? existing.routeId
      ..name = plan.name ?? existing.name
      ..isImported = plan.isImported
      ..startingDate = plan.startingDate
      ..updatedAt = plan.updatedAt
      ..deletedAt = null
      ..trailRouteIds = plan.trailRouteIds
      ..stages = _mergeStages(existing.stages, stagesSlice);
  }

  /// Merge incoming sync stages into the existing remote stage list.
  ///
  /// Conflict rule: incoming wins (last-write-wins, keyed by
  /// `stage_uuid` if present else `stage_number`). This matches the
  /// observed behavior of the production server in stage planner sync
  /// (the request is the "source of truth" for the device that just
  /// pushed). The sync_test then locks this rule in.
  List<FakeRemoteStage> _mergeStages(
    List<FakeRemoteStage> existing,
    List<SyncStageRequest> incoming,
  ) {
    final result = <FakeRemoteStage>[...existing];

    for (final stage in incoming) {
      final uuid = stage.stageUuid?.trim();
      var matchIndex = -1;
      if (uuid != null && uuid.isNotEmpty) {
        matchIndex = result.indexWhere((s) => s.stageUuid == uuid);
      }
      if (matchIndex == -1) {
        matchIndex =
            result.indexWhere((s) => s.stageNumber == stage.stageNumber);
      }

      final newStage = FakeRemoteStage(
        stageNumber: stage.stageNumber,
        routeId: stage.routeId,
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
        // Server-side bumps `updated_at` on merge when the test has
        // configured a sentinel; otherwise echo the request value
        // (the original behavior — preserved so test 1/3/4/5 pass).
        updatedAt: serverUpdatedAtSentinel ?? stage.updatedAt,
        stageUuid: stage.stageUuid,
      );

      if (matchIndex >= 0) {
        result[matchIndex] = newStage;
      } else {
        result.add(newStage);
      }
    }

    // Note: this fake does NOT drop existing stages that are absent
    // from the incoming request. Real-world stage-planner sync uses
    // stage_uuid to track deletions; the fake only models the
    // last-write-wins merge for stages the request mentions, which
    // mirrors how cross-device push-then-pull behaves in practice.
    // System-level deletion still works in production because
    // `_applySyncResponse` calls `deleteStagesNotInIds` to prune
    // local stages whose `stage_number` isn't in the response —
    // that pruning happens on the local side, not in this fake's
    // `_mergeStages`.

    result.sort((a, b) => a.stageNumber.compareTo(b.stageNumber));
    return result;
  }

  SyncStagePlannerResponse _buildResponse(SyncStagePlannerRequest request) {
    final responsePlans = <SyncPlanResponse>[];
    final seen = <String>{};
    for (final plan in request.plans) {
      seen.add(plan.uuid);
      final remote = remotePlans[plan.uuid];
      if (remote == null) continue;
      responsePlans.add(_planResponseFrom(remote));
    }
    // Plans the device didn't push but exist remotely (e.g. seeded by
    // a "second device") are also surfaced — that's how cross-device
    // sync works.
    for (final entry in remotePlans.entries) {
      if (seen.contains(entry.key)) continue;
      responsePlans.add(_planResponseFrom(entry.value));
    }
    return SyncStagePlannerResponse(plans: responsePlans);
  }

  SyncPlanResponse _planResponseFrom(FakeRemotePlan plan) {
    return SyncPlanResponse(
      uuid: plan.uuid,
      routeId: plan.routeId,
      name: plan.name,
      isImported: plan.isImported,
      planUuid: plan.planUuid,
      startingDate: plan.startingDate,
      createdAt: plan.createdAt,
      updatedAt: plan.updatedAt,
      deletedAt: plan.deletedAt,
      trailRouteIds: plan.trailRouteIds,
      stages: plan.stages
          .map(
            (s) => SyncStageResponse(
              stageNumber: s.stageNumber,
              routeId: s.routeId,
              date: s.date,
              startCityId: s.startCityId,
              endCityId: s.endCityId,
              startAlbergueId: s.startAlbergueId,
              endAlbergueId: s.endAlbergueId,
              customStartNotes: s.customStartNotes,
              customEndNotes: s.customEndNotes,
              stageNotes: s.stageNotes,
              daysToStay: s.daysToStay,
              createdAt: s.createdAt,
              updatedAt: s.updatedAt,
              stageUuid: s.stageUuid,
            ),
          )
          .toList(),
    );
  }
}
