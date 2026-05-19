// Locks in current behavior of `AppState.copyWith` and
// `AppState.copyWithNoNull`.
//
// Both methods have non-obvious quirks that have caused real bugs:
//
// `copyWith()`:
//   nullifies these fields when they aren't passed explicitly —
//     selectedStartingPoint, selectedDestination, plannedRoute,
//     routeStats, routePoints, selectedRoutePoints, altRoutePoints,
//     loadingMessage, dataFetchCompletedAt, authChangedAt
//   This is direct assignment in the implementation, not `?? this.x`,
//   so calling `copyWith()` to update a single non-null-quirk field
//   silently wipes the entire batch above. The fix to use
//   `copyWithNoNull` for partial updates is the documented workaround.
//
// `copyWithNoNull()`:
//   preserves most nullable fields via `?? this.x` BUT still uses
//   direct assignment for `dataFetchCompletedAt` and `authChangedAt`.
//   Half-fixed.
//
// These tests document the gotcha so a future refactor doesn't break
// callers that depend on it. The footgun itself is NOT fixed here.

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

AppState _populated() {
  // A state with every list-or-string nullable field set to a
  // non-null marker so we can tell when copyWith has nullified one.
  // Object-typed nullables (selectedStartingPoint, selectedDestination,
  // routeStats) are documented in the same direct-assignment batch
  // and verified indirectly via the list/string fields below.
  return AppState(
    loadingData: true,
    updatingData: true,
    loadRoutesError: 'err',
    plannedRoute: const [],
    language: 'en',
    routePoints: const [],
    selectedRoutePoints: const [],
    altRoutePoints: const [],
    loadingMessage: 'loading',
    offlineAndNoData: true,
    loadingProgress: 5,
    loadingTotal: 10,
    dataUpdateAvailable: true,
    shouldShowAppReview: true,
    showNewLabelOnPlanTab: true,
    unreadNotificationsBadgeCount: 7,
    dataFetchCompletedAt: DateTime(2025, 3, 4),
    authChangedAt: DateTime(2025, 2, 2),
  );
}

void main() {
  group('AppState.copyWith — direct-assignment footgun', () {
    test('nullifies the entire batch of nullable fields when not passed',
        () {
      final state = _populated();
      final copy = state.copyWith();

      // These are the fields that get nullified by direct assignment.
      expect(copy.plannedRoute, isNull);
      expect(copy.routePoints, isNull);
      expect(copy.selectedRoutePoints, isNull);
      expect(copy.altRoutePoints, isNull);
      expect(copy.loadingMessage, isNull);
      expect(copy.dataFetchCompletedAt, isNull);
      expect(copy.authChangedAt, isNull);
      // Same direct-assignment quirk also wipes selectedStartingPoint,
      // selectedDestination, and routeStats; we don't construct those
      // here (they require deep object trees), but read the AppState
      // implementation: same code path.

      // Sanity: fields that DO use `?? this.x` are preserved.
      expect(copy.loadingData, equals(state.loadingData));
      expect(copy.updatingData, equals(state.updatingData));
      expect(copy.loadRoutesError, equals(state.loadRoutesError));
      expect(copy.language, equals(state.language));
      expect(copy.unit, equals(state.unit));
      expect(copy.theme, equals(state.theme));
      expect(
        copy.unreadNotificationsBadgeCount,
        equals(state.unreadNotificationsBadgeCount),
      );
    });

    test('updating a single non-quirk field still nullifies the batch',
        () {
      // This is the bug shape: caller wants to bump `loadingData` and
      // accidentally wipes routeStats/routePoints/etc.
      final state = _populated();
      final copy = state.copyWith(loadingData: false);

      expect(copy.loadingData, isFalse);
      expect(copy.routePoints, isNull);
      expect(copy.plannedRoute, isNull);
      expect(copy.altRoutePoints, isNull);
      expect(copy.loadingMessage, isNull);
    });
  });

  group('AppState.copyWithNoNull — half-fixed', () {
    test('preserves the nullable fields that copyWith would nullify', () {
      final state = _populated();
      final copy = state.copyWithNoNull();

      expect(copy.plannedRoute, equals(state.plannedRoute));
      expect(copy.routePoints, equals(state.routePoints));
      expect(copy.selectedRoutePoints, equals(state.selectedRoutePoints));
      expect(copy.altRoutePoints, equals(state.altRoutePoints));
      expect(copy.loadingMessage, equals(state.loadingMessage));
    });

    test(
      'BUG: copyWithNoNull still nullifies dataFetchCompletedAt and '
      'authChangedAt',
      () {
        final state = _populated();
        final copy = state.copyWithNoNull();

        expect(copy.dataFetchCompletedAt, isNull);
        expect(copy.authChangedAt, isNull);
      },
    );

    test(
      'notifyAuthChanged usage pattern preserves all other nullable '
      'fields (the documented workaround)',
      () {
        // Mirrors `AppCubit.notifyAuthChanged()`'s call shape:
        //   state.copyWithNoNull(authChangedAt: DateTime.now())
        final state = _populated();
        final newAuthAt = DateTime(2099, 6, 7);
        final copy = state.copyWithNoNull(authChangedAt: newAuthAt);

        expect(copy.authChangedAt, equals(newAuthAt));
        // Everything except dataFetchCompletedAt is preserved.
        expect(copy.plannedRoute, equals(state.plannedRoute));
        expect(copy.routePoints, equals(state.routePoints));
        expect(copy.selectedRoutePoints, equals(state.selectedRoutePoints));
        expect(copy.altRoutePoints, equals(state.altRoutePoints));
        expect(copy.loadingMessage, equals(state.loadingMessage));
        // But dataFetchCompletedAt is still nulled — half-fixed.
        expect(copy.dataFetchCompletedAt, isNull);
      },
    );
  });
}
