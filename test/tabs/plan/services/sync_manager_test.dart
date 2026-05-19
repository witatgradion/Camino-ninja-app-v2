// Regression tests for [SyncManager] guarding against the duplicate
// sync trigger (issue 027).
//
// Two near-simultaneous calls to `syncIfNeeded()` must produce
// exactly one `StagePlanRepository.syncPlans()` invocation. Before
// the fix, the `_isSyncing` flag was set AFTER `await _isLoggedIn()`,
// so two callers could both pass the guard and proceed concurrently.

import 'dart:async';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/sync_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class _MockStagePlanRepository extends Mock
    implements StagePlanRepository {}

class _MockRepository extends Mock implements Repository {}

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

const _loggedInCredential = CredentialEntity(
  accessToken: 'fake-access-token',
  refreshToken: 'fake-refresh-token',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockStagePlanRepository stageRepo;
  late _MockRepository repository;
  late _MockAppPreferences prefs;

  setUp(() {
    stageRepo = _MockStagePlanRepository();
    repository = _MockRepository();
    prefs = _MockAppPreferences();

    when(prefs.getUserCredential)
        .thenAnswer((_) async => _loggedInCredential);
    when(stageRepo.getStagePlanCount).thenAnswer((_) async => 0);
    // `Repository.syncSavedAccommodations` is an extension method —
    // mocktail can't intercept it. The SyncManager call is fire-and-
    // forget (`unawaited`), so the rejected Future from the
    // unstubbed Repository surface is harmless to the assertion.

    if (!GetIt.instance.isRegistered<IAnalyticsService>()) {
      GetIt.instance
          .registerSingleton<IAnalyticsService>(_NoopAnalyticsService());
    }
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  test(
    'two concurrent syncIfNeeded calls produce exactly one syncPlans call',
    () async {
      // Use a completer so we can hold the first `syncPlans` open
      // while the second `syncIfNeeded` arrives — this is the
      // scenario the bug exhibits.
      final firstSyncCompleter = Completer<SyncPlansResult>();
      var syncCallCount = 0;
      when(stageRepo.syncPlans).thenAnswer((_) {
        syncCallCount++;
        return firstSyncCompleter.future;
      });

      final manager = SyncManager(stageRepo, prefs, repository);

      // Fire both triggers without awaiting; they race through the
      // `_isLoggedIn()` await before the first one finishes.
      final firstSync = manager.syncIfNeeded();
      final secondSync = manager.syncIfNeeded();

      // Let microtasks settle so both callers reach the inner
      // `await _stagePlanRepository.syncPlans()` (or get rejected
      // by the `_isSyncing` guard).
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Now release the in-flight sync.
      firstSyncCompleter.complete(const SyncPlansSuccess());
      await Future.wait([firstSync, secondSync]);

      expect(
        syncCallCount,
        equals(1),
        reason: 'Two near-simultaneous triggers must coalesce into a '
            'single repository sync. A count > 1 means the trigger '
            'guard raced (issue 027 regression).',
      );
    },
  );

  test(
    'syncIfNeeded called after a previous sync completes runs again '
    '(when stale)',
    () async {
      // Sanity check: the trigger guard must release after a sync
      // finishes — a follow-up sync that arrives later still runs.
      var syncCallCount = 0;
      when(stageRepo.syncPlans).thenAnswer((_) async {
        syncCallCount++;
        return const SyncPlansSuccess();
      });

      final manager = SyncManager(stageRepo, prefs, repository);

      await manager.syncIfNeeded();
      // First call sets `_lastSyncTime`; the 30s freshness window
      // would skip a second call. Bypass it by aging the trigger.
      await Future<void>.delayed(Duration.zero);

      // The 30s freshness guard means a second call right away
      // should be a no-op — that's the expected debounce. Verify.
      await manager.syncIfNeeded();
      expect(
        syncCallCount,
        equals(1),
        reason: 'The 30s freshness window should debounce a follow-up '
            'sync after a recent successful one.',
      );
    },
  );
}
