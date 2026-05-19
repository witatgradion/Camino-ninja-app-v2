import 'package:analytics_services/src/analytics_event.dart';

/// Fired when cloud sync starts.
class CloudSyncStartedEvent extends AnalyticsEvent {
  /// Creates a [CloudSyncStartedEvent].
  CloudSyncStartedEvent({
    required this.trigger,
    required this.planCount,
  });

  /// What triggered the sync (e.g. `auto`, `manual`).
  final String trigger;

  /// Number of plans being synced.
  final int planCount;

  @override
  String get name => 'cloud_sync_started';

  @override
  Map<String, dynamic> get properties => {
        'trigger': trigger,
        'plan_count': planCount,
      };
}

/// Fired when cloud sync succeeds.
class CloudSyncSuccessEvent extends AnalyticsEvent {
  /// Creates a [CloudSyncSuccessEvent].
  CloudSyncSuccessEvent({
    required this.planCount,
    required this.durationMs,
  });

  /// Number of plans synced.
  final int planCount;

  /// Duration of the sync in milliseconds.
  final int durationMs;

  @override
  String get name => 'cloud_sync_success';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
        'duration_ms': durationMs,
      };
}

/// Fired when cloud sync fails.
class CloudSyncFailureEvent extends AnalyticsEvent {
  /// Creates a [CloudSyncFailureEvent].
  CloudSyncFailureEvent({
    required this.error,
    required this.planCount,
  });

  /// The error description.
  final String error;

  /// Number of plans attempted.
  final int planCount;

  @override
  String get name => 'cloud_sync_failure';

  @override
  Map<String, dynamic> get properties => {
        'error': error,
        'plan_count': planCount,
      };
}

/// Fired once per multi-trail plan that successfully synced.
///
/// A plan is considered "multi-trail" when its `trail_route_ids` column
/// is non-NULL. The [routeCount] is the number of route segments in
/// the plan's trail descriptor.
class MultiTrailPlanSyncSuccessEvent extends AnalyticsEvent {
  /// Creates a [MultiTrailPlanSyncSuccessEvent].
  MultiTrailPlanSyncSuccessEvent({required this.routeCount});

  /// Number of route segments in the synced multi-trail plan.
  final int routeCount;

  @override
  String get name => 'multi_trail_plan_sync_success';

  @override
  Map<String, dynamic> get properties => {
        'route_count': routeCount,
      };
}

/// Fired once per multi-trail plan that failed to sync.
///
/// All multi-trail plans in a failed sync batch share the same [error]
/// string — sync is atomic at the batch level, so per-plan diagnosis
/// requires server-side correlation.
class MultiTrailPlanSyncFailedEvent extends AnalyticsEvent {
  /// Creates a [MultiTrailPlanSyncFailedEvent].
  MultiTrailPlanSyncFailedEvent({required this.error});

  /// Sanitized error description.
  final String error;

  @override
  String get name => 'multi_trail_plan_sync_failed';

  @override
  Map<String, dynamic> get properties => {
        'error': error,
      };
}
