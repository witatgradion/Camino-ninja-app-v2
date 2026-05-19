import 'dart:async';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/sync_indicator_status.dart';
import 'package:camino_ninja_flutter/utils/network_util.dart';
import 'package:core/core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class SyncManager with WidgetsBindingObserver {
  SyncManager(
    this._stagePlanRepository,
    this._appPreferences,
    this._repository,
  );

  final StagePlanRepository _stagePlanRepository;
  final AppPreferences _appPreferences;
  final Repository _repository;
  Timer? _debounceTimer;
  Timer? _statusResetTimer;
  StreamSubscription<void>? _syncSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;
  Completer<void>? _syncCompleter;
  bool _isDirty = false;
  bool _syncQueued = false;
  bool _disposed = false;
  DateTime? _lastSyncTime;

  /// Notifier for the floating sync indicator pill.
  final ValueNotifier<SyncIndicatorStatus> syncStatus =
      ValueNotifier<SyncIndicatorStatus>(SyncIndicatorStatus.idle);

  /// Callback for UI to react to background sync completion
  void Function(bool success)? onSyncComplete;

  void start() {
    // 1. After local changes (debounced 3s)
    _syncSubscription = _stagePlanRepository.onSyncNeeded.listen((_) {
      _isDirty = true;
      scheduleSync();
    });

    // 2. On app resume
    WidgetsBinding.instance.addObserver(this);

    // 3. On connectivity restore
    _connectivitySubscription = NetworkUtil()
        .connectivityStream
        .distinct()
        .where((connected) => connected)
        .listen((_) => _performSync(trigger: 'connectivity'));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _performSync(trigger: 'resume');
    }
  }

  /// Trigger sync when Plan tab opens
  Future<void> syncIfNeeded() async => _performSync();

  // How long to wait after the last local change before syncing.
  // Longer means fewer mid-session syncs; shorter means faster
  // cloud propagation. Adjust as needed.
  static const _kLocalChangeSyncDelay = Duration(seconds: 10);

  void scheduleSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      _kLocalChangeSyncDelay,
      _performSync,
    );
  }

  Future<void> _performSync({String trigger = 'auto'}) async {
    if (_isSyncing) {
      _syncQueued = true;
      return;
    }
    // Claim synchronously so concurrent callers can't both pass
    // this guard before the first one awaits (issue 027).
    _isSyncing = true;
    _syncCompleter = Completer<void>();

    try {
      if (!NetworkUtil().isConnected) return;
      if (!await _isLoggedIn()) return;

      // Skip if no dirty changes and synced recently (< 30s).
      if (!_isDirty &&
          _lastSyncTime != null &&
          DateTime.now().difference(_lastSyncTime!) <
              const Duration(seconds: 30)) {
        return;
      }

      _isDirty = false;
      _setSyncStatus(SyncIndicatorStatus.syncing);

      final planCount = await _getPlanCount();
      final stopwatch = Stopwatch()..start();

      _trackAnalyticsEvent(
        CloudSyncStartedEvent(
          trigger: trigger,
          planCount: planCount,
        ),
      );

      try {
        final result = await _stagePlanRepository.syncPlans();

        // Sync favorites independently (fire-and-forget)
        unawaited(_repository.syncSavedAccommodations());

        stopwatch.stop();
        if (_disposed) return;
        _setSyncStatus(
          result.isSuccess
              ? SyncIndicatorStatus.success
              : SyncIndicatorStatus.failure,
        );
        if (result.isSuccess) {
          _trackAnalyticsEvent(
            CloudSyncSuccessEvent(
              planCount: planCount,
              durationMs: stopwatch.elapsedMilliseconds,
            ),
          );
          _trackStageNumberCompactionIfAny(result);
          _trackMultiTrailPlanSyncOutcome(result);
        } else {
          _trackAnalyticsEvent(
            CloudSyncFailureEvent(
              error: _describeFailure(result),
              planCount: planCount,
            ),
          );
          _trackMultiTrailPlanSyncOutcome(result);
          _recordSyncFailureToCrashlytics(result);
        }
        onSyncComplete?.call(result.isSuccess);
      } catch (e) {
        stopwatch.stop();
        if (_disposed) return;
        _setSyncStatus(SyncIndicatorStatus.failure);
        _trackAnalyticsEvent(
          CloudSyncFailureEvent(
            error: '$e',
            planCount: planCount,
          ),
        );
        onSyncComplete?.call(false);
      } finally {
        _lastSyncTime = DateTime.now();
      }
    } finally {
      _isSyncing = false;
      _syncCompleter?.complete();
      _syncCompleter = null;

      if (_syncQueued) {
        _syncQueued = false;
        unawaited(_performSync());
      }
    }
  }

  Future<bool> _isLoggedIn() async {
    final credential = await _appPreferences.getUserCredential();
    return credential?.accessToken != null;
  }

  /// Waits for any in-flight sync, then runs [syncNow] once (e.g. QR export
  /// needs server UUIDs).
  Future<bool> ensurePlansSyncedForExport() async {
    await _waitUntilSyncIdle(
      timeout: const Duration(seconds: 90),
    );
    if (_disposed) return false;
    if (_isSyncing) return false;
    if (!NetworkUtil().isConnected) return false;
    if (!await _isLoggedIn()) return false;
    return syncNow();
  }

  Future<void> _waitUntilSyncIdle({
    required Duration timeout,
  }) async {
    if (!_isSyncing) return;
    final completer = _syncCompleter;
    if (completer == null) return;
    await completer.future.timeout(
      timeout,
      onTimeout: () {},
    );
  }

  /// Sync immediately (for manual sync button).
  Future<bool> syncNow() async {
    _debounceTimer?.cancel();
    if (_isSyncing) return false;
    if (!NetworkUtil().isConnected) return false;
    // Claim synchronously so concurrent callers can't both pass
    // this guard before the first one awaits (issue 027).
    _isSyncing = true;
    _syncCompleter = Completer<void>();

    try {
      if (!await _isLoggedIn()) return false;

      _isDirty = false;
      _setSyncStatus(SyncIndicatorStatus.syncing);

      final planCount = await _getPlanCount();
      final stopwatch = Stopwatch()..start();

      _trackAnalyticsEvent(
        CloudSyncStartedEvent(
          trigger: 'manual',
          planCount: planCount,
        ),
      );

      try {
        final result = await _stagePlanRepository.syncPlans();

        // Sync favorites independently (fire-and-forget)
        unawaited(_repository.syncSavedAccommodations());

        stopwatch.stop();
        if (_disposed) return false;
        _setSyncStatus(
          result.isSuccess
              ? SyncIndicatorStatus.success
              : SyncIndicatorStatus.failure,
        );
        if (result.isSuccess) {
          _trackAnalyticsEvent(
            CloudSyncSuccessEvent(
              planCount: planCount,
              durationMs: stopwatch.elapsedMilliseconds,
            ),
          );
          _trackStageNumberCompactionIfAny(result);
          _trackMultiTrailPlanSyncOutcome(result);
        } else {
          _trackAnalyticsEvent(
            CloudSyncFailureEvent(
              error: _describeFailure(result),
              planCount: planCount,
            ),
          );
          _trackMultiTrailPlanSyncOutcome(result);
          _recordSyncFailureToCrashlytics(result);
        }
        return result.isSuccess;
      } catch (e) {
        stopwatch.stop();
        if (_disposed) return false;
        _setSyncStatus(SyncIndicatorStatus.failure);
        _trackAnalyticsEvent(
          CloudSyncFailureEvent(
            error: '$e',
            planCount: planCount,
          ),
        );
        return false;
      } finally {
        _lastSyncTime = DateTime.now();
      }
    } finally {
      _isSyncing = false;
      _syncCompleter?.complete();
      _syncCompleter = null;

      if (_syncQueued) {
        _syncQueued = false;
        unawaited(_performSync());
      }
    }
  }

  void _setSyncStatus(SyncIndicatorStatus status) {
    if (_disposed) return;
    _statusResetTimer?.cancel();
    syncStatus.value = status;
    if (status == SyncIndicatorStatus.success ||
        status == SyncIndicatorStatus.failure) {
      _statusResetTimer = Timer(const Duration(seconds: 2), () {
        syncStatus.value = SyncIndicatorStatus.idle;
      });
    }
  }

  Future<int> _getPlanCount() async {
    try {
      return await _stagePlanRepository.getStagePlanCount();
    } catch (_) {
      return 0;
    }
  }

  void _trackAnalyticsEvent(AnalyticsEvent event) {
    GetIt.instance<IAnalyticsService>().track(event);
  }

  /// Fires [StageNumberCompactionEvent] when the sync repaired any
  /// gappy `stage_number` values during merge.
  ///
  /// Temporary observability for the `fix/stage-sync-disappearing-stages`
  /// rollout — measures real-world prevalence of the corruption and
  /// confirms the fix is converging. Removed after 1-2 release cycles.
  void _trackStageNumberCompactionIfAny(SyncPlansResult result) {
    if (result is! SyncPlansSuccess) return;
    if (result.stagesCompacted <= 0) return;
    try {
      _trackAnalyticsEvent(
        StageNumberCompactionEvent(
          stagesCompacted: result.stagesCompacted,
          plansAffected: result.plansAffected,
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Stage-number compaction analytics failed',
        tag: 'SyncManager',
        error: e,
      );
    }
  }

  /// Emits per-plan multi-trail sync events based on the sync outcome.
  ///
  /// Success: one [MultiTrailPlanSyncSuccessEvent] per multi-trail plan
  /// that was in the batch, carrying its segment count.
  /// Failure (API error or exception): one [MultiTrailPlanSyncFailedEvent]
  /// per multi-trail plan in the failed batch, all sharing the same
  /// sanitized error string (sync is atomic at the batch level).
  /// Not-logged-in: emits nothing — the sync didn't run.
  void _trackMultiTrailPlanSyncOutcome(SyncPlansResult result) {
    switch (result) {
      case SyncPlansSuccess(:final multiTrailRouteCounts):
        for (final routeCount in multiTrailRouteCounts) {
          _trackAnalyticsEvent(
            MultiTrailPlanSyncSuccessEvent(routeCount: routeCount),
          );
        }
      case SyncPlansApiError(:final message, :final multiTrailPlanCount):
        final error = 'api_error: $message';
        for (var i = 0; i < multiTrailPlanCount; i++) {
          _trackAnalyticsEvent(
            MultiTrailPlanSyncFailedEvent(error: error),
          );
        }
      case SyncPlansException(:final error, :final multiTrailPlanCount):
        final sanitized = 'exception: ${error.runtimeType}';
        for (var i = 0; i < multiTrailPlanCount; i++) {
          _trackAnalyticsEvent(
            MultiTrailPlanSyncFailedEvent(error: sanitized),
          );
        }
      case SyncPlansNotLoggedIn():
        break;
    }
  }

  String _describeFailure(SyncPlansResult result) {
    return switch (result) {
      SyncPlansSuccess() => 'success',
      SyncPlansNotLoggedIn() => 'not_logged_in',
      SyncPlansApiError(message: final m) =>
        'api_error: $m',
      SyncPlansException(error: final e) =>
        'exception: $e',
    };
  }

  void _recordSyncFailureToCrashlytics(
    SyncPlansResult result,
  ) {
    switch (result) {
      case SyncPlansSuccess():
      case SyncPlansNotLoggedIn():
        break;
      case SyncPlansApiError(message: final m):
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            Exception('Sync API error: $m'),
            StackTrace.current,
            reason: 'syncPlans API failure',
            fatal: false,
          ),
        );
      case SyncPlansException(
        error: final e,
        stackTrace: final st,
      ):
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            st,
            reason: 'syncPlans exception',
            fatal: false,
          ),
        );
    }
  }

  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    _statusResetTimer?.cancel();
    _syncSubscription?.cancel();
    _connectivitySubscription?.cancel();
    syncStatus.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
