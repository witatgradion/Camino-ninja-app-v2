import 'package:analytics_services/src/analytics_event.dart';

/// Fired on every plan load to report diagnostic
/// counts for detecting silent data loss.
class PlanLoadDiagnosticEvent extends AnalyticsEvent {
  /// Creates a [PlanLoadDiagnosticEvent].
  PlanLoadDiagnosticEvent({
    required this.rawPlanCount,
    required this.completePlanCount,
    required this.incompletePlanCount,
    required this.droppedPlanCount,
    required this.isLoggedIn,
  });

  /// Total plans returned from the DB before filtering.
  final int rawPlanCount;

  /// Plans that fully converted to stage plan models.
  final int completePlanCount;

  /// Plans marked incomplete (missing route, etc.).
  final int incompletePlanCount;

  /// Plans silently dropped during conversion.
  final int droppedPlanCount;

  /// Whether the user is logged in.
  final bool isLoggedIn;

  @override
  String get name => 'plan_load_diagnostic';

  @override
  Map<String, dynamic> get properties => {
        'raw_plan_count': rawPlanCount,
        'complete_plan_count': completePlanCount,
        'incomplete_plan_count': incompletePlanCount,
        'dropped_plan_count': droppedPlanCount,
        'is_logged_in': isLoggedIn,
      };
}

/// Fired after a successful stage-planner sync when at least one
/// stage had its `stage_number` rewritten to compact a 1..N gap.
///
/// Temporary observability event for the
/// `fix/stage-sync-disappearing-stages` rollout — once 1-2 release
/// cycles confirm gaps have stopped recurring, this can be removed.
class StageNumberCompactionEvent extends AnalyticsEvent {
  /// Creates a [StageNumberCompactionEvent].
  StageNumberCompactionEvent({
    required this.stagesCompacted,
    required this.plansAffected,
  });

  /// Total stages whose `stage_number` was rewritten across all plans
  /// in this sync cycle.
  final int stagesCompacted;

  /// Number of plans that had at least one compacted stage.
  final int plansAffected;

  @override
  String get name => 'stage_number_compaction';

  @override
  Map<String, dynamic> get properties => {
        'stages_compacted': stagesCompacted,
        'plans_affected': plansAffected,
      };
}

/// Fired once after the stage planner DB v9 migration has backfilled
/// at least one NULL/blank `stage_uuid` row.
///
/// Temporary observability event for the
/// `fix/stage-sync-disappearing-stages` rollout — measures the real
/// prevalence of the corruption preconditions in the wild. Removed
/// after 1-2 releases.
class StageUuidBackfillEvent extends AnalyticsEvent {
  /// Creates a [StageUuidBackfillEvent].
  StageUuidBackfillEvent({required this.backfilledCount});

  /// Number of stages whose `stage_uuid` was backfilled by the v9
  /// migration on this device.
  final int backfilledCount;

  @override
  String get name => 'stage_uuid_backfill';

  @override
  Map<String, dynamic> get properties => {
        'backfilled_count': backfilledCount,
      };
}
