import 'package:analytics_services/src/analytics_event.dart';

/// Fired when a plan is created.
class CreatePlanEvent extends AnalyticsEvent {
  /// Creates a [CreatePlanEvent].
  CreatePlanEvent({
    required this.routeId,
    required this.routeName,
    this.hasStartingDate,
    this.source,
    this.planType,
    this.trailRouteCount,
  });

  /// The route ID.
  final int? routeId;

  /// The route name.
  final String routeName;

  /// Whether the plan has a starting date set.
  final bool? hasStartingDate;

  /// Source of plan creation (e.g., `manual`).
  final String? source;

  /// Which choice the user made:
  /// `single_route`, `custom_trail`, or `journey`. Nullable for
  /// older entry points that don't pass through the choice sheet.
  final String? planType;

  /// Number of route segments in the plan. `1` for single-route
  /// plans, `2+` for multi-trail plans. Nullable when not known.
  final int? trailRouteCount;

  @override
  String get name => 'create_plan';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        if (hasStartingDate != null)
          'has_starting_date': hasStartingDate,
        if (source != null) 'source': source,
        if (planType != null) 'plan_type': planType,
        if (trailRouteCount != null)
          'trail_route_count': trailRouteCount,
      };
}

/// Fired when the plan-type choice bottom sheet opens.
class PlanTypeChoiceShownEvent extends AnalyticsEvent {
  /// Creates a [PlanTypeChoiceShownEvent].
  PlanTypeChoiceShownEvent();

  @override
  String get name => 'plan_type_choice_shown';

  @override
  Map<String, dynamic> get properties => const {};
}

/// Fired the first time per session that a feature flag is read.
///
/// Dedup of "once per session per `flag_name`" is the caller's
/// responsibility — see `FeatureFlagExposureTracker` in the app
/// layer.
class FeatureFlagExposureEvent extends AnalyticsEvent {
  /// Creates a [FeatureFlagExposureEvent].
  FeatureFlagExposureEvent({
    required this.flagName,
    required this.flagValue,
  });

  /// Remote Config flag name (e.g. `feature_custom_trail_enabled`).
  final String flagName;

  /// The resolved boolean value at exposure time.
  final bool flagValue;

  @override
  String get name => 'feature_flag_exposure';

  @override
  Map<String, dynamic> get properties => {
        'flag_name': flagName,
        'flag_value': flagValue,
      };
}

/// Fired when the user taps a plan-type option on the choice sheet.
class PlanTypeChoiceSelectedEvent extends AnalyticsEvent {
  /// Creates a [PlanTypeChoiceSelectedEvent].
  PlanTypeChoiceSelectedEvent({required this.planType});

  /// Which option was selected:
  /// `single_route`, `custom_trail`, or `journey`.
  final String planType;

  @override
  String get name => 'plan_type_choice_selected';

  @override
  Map<String, dynamic> get properties => {
        'plan_type': planType,
      };
}

/// Fired when the user commits a junction decision in the
/// trail builder (continue, switch route, or end here). Fires once
/// per decision; undoing and re-deciding fires a fresh event with
/// the same [decisionNumber].
class TrailBuilderJunctionDecisionEvent extends AnalyticsEvent {
  /// Creates a [TrailBuilderJunctionDecisionEvent].
  TrailBuilderJunctionDecisionEvent({required this.decisionNumber});

  /// 1-based index of the decision in the current builder session.
  final int decisionNumber;

  @override
  String get name => 'trail_builder_junction_decision';

  @override
  Map<String, dynamic> get properties => {
        'decision_number': decisionNumber,
      };
}

/// Fired when the user undoes a junction decision in the trail
/// builder. Friction signal — emitted per undo, not batched.
class TrailBuilderUndoEvent extends AnalyticsEvent {
  /// Creates a [TrailBuilderUndoEvent].
  TrailBuilderUndoEvent();

  @override
  String get name => 'trail_builder_undo';

  @override
  Map<String, dynamic> get properties => const {};
}

/// Fired when the trail builder reaches a terminal `complete` state
/// — the multi-route trail is finalized and ready to be handed off
/// to plan creation.
class TrailBuilderFinalizedEvent extends AnalyticsEvent {
  /// Creates a [TrailBuilderFinalizedEvent].
  TrailBuilderFinalizedEvent();

  @override
  String get name => 'trail_builder_finalized';

  @override
  Map<String, dynamic> get properties => const {};
}

/// Fired when the user picks a start city in the journey planner.
class JourneyPlannerStartCitySelectedEvent extends AnalyticsEvent {
  /// Creates a [JourneyPlannerStartCitySelectedEvent].
  JourneyPlannerStartCitySelectedEvent({required this.cityId});

  /// The selected start city ID.
  final int cityId;

  @override
  String get name => 'journey_planner_start_city_selected';

  @override
  Map<String, dynamic> get properties => {
        'city_id': cityId,
      };
}

/// Fired when the user picks a destination city in the journey planner.
class JourneyPlannerDestinationSelectedEvent extends AnalyticsEvent {
  /// Creates a [JourneyPlannerDestinationSelectedEvent].
  JourneyPlannerDestinationSelectedEvent({required this.cityId});

  /// The selected destination city ID.
  final int cityId;

  @override
  String get name => 'journey_planner_destination_selected';

  @override
  Map<String, dynamic> get properties => {
        'city_id': cityId,
      };
}

/// Fired when the user commits to a route option in the journey
/// planner — the terminal step that converts a `JourneyOption` into
/// a `MultiRouteTrail` for plan creation.
class JourneyPlannerRouteOptionSelectedEvent extends AnalyticsEvent {
  /// Creates a [JourneyPlannerRouteOptionSelectedEvent].
  JourneyPlannerRouteOptionSelectedEvent({
    required this.optionType,
    required this.positionIndex,
  });

  /// Reachability classification of the selected option:
  /// `direct` (single route), `via_junction` (one junction
  /// transition), or `multi_trail` (two or more transitions).
  final String optionType;

  /// 0-based index of the chosen option in the displayed list.
  final int positionIndex;

  @override
  String get name => 'journey_planner_route_option_selected';

  @override
  Map<String, dynamic> get properties => {
        'option_type': optionType,
        'position_index': positionIndex,
      };
}

/// Fired when a stage is created.
class CreateStageEvent extends AnalyticsEvent {
  /// Creates a [CreateStageEvent].
  CreateStageEvent({
    this.routeId,
    this.routeName,
    required this.stageNumber,
    this.date,
    this.startingCityId,
    this.startingCityName,
    this.startingAlbergueId,
    this.startingAlbergueName,
    this.startingCustomAccomm,
    this.endingCityId,
    this.endingCityName,
    this.endingAlbergueId,
    this.endingAlbergueName,
    this.endingCustomAccomm,
    this.totalStages,
    this.hasAlbergue,
    this.isInsertBetween,
  });

  /// The route ID.
  final int? routeId;

  /// The route name.
  final String? routeName;

  /// The 1-based stage number.
  final int stageNumber;

  /// The stage date.
  final String? date;

  /// The starting city ID.
  final int? startingCityId;

  /// The starting city name.
  final String? startingCityName;

  /// The starting albergue ID.
  final int? startingAlbergueId;

  /// The starting albergue name.
  final String? startingAlbergueName;

  /// Custom start accommodation notes.
  final String? startingCustomAccomm;

  /// The ending city ID.
  final int? endingCityId;

  /// The ending city name.
  final String? endingCityName;

  /// The ending albergue ID.
  final int? endingAlbergueId;

  /// The ending albergue name.
  final String? endingAlbergueName;

  /// Custom end accommodation notes.
  final String? endingCustomAccomm;

  /// Total number of stages after creation.
  final int? totalStages;

  /// Whether the stage has an albergue selected.
  final bool? hasAlbergue;

  /// Whether this stage was inserted between existing stages.
  final bool? isInsertBetween;

  @override
  String get name => 'create_stage';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'stage_number': stageNumber,
        'date': date,
        'starting_city_id': startingCityId,
        'starting_city_name': startingCityName,
        'starting_albergue_id': startingAlbergueId,
        'starting_albergue_name': startingAlbergueName,
        'starting_custom_accomm': startingCustomAccomm,
        'ending_city_id': endingCityId,
        'ending_city_name': endingCityName,
        'ending_albergue_id': endingAlbergueId,
        'ending_albergue_name': endingAlbergueName,
        'ending_custom_accomm': endingCustomAccomm,
        if (totalStages != null) 'total_stages': totalStages,
        if (hasAlbergue != null) 'has_albergue': hasAlbergue,
        if (isInsertBetween != null)
          'is_insert_between': isInsertBetween,
      };
}

/// Fired when a plan is deleted.
class DeletePlanEvent extends AnalyticsEvent {
  /// Creates a [DeletePlanEvent].
  DeletePlanEvent({
    this.routeId,
    this.routeName,
    this.stageCount,
    this.hadStartingDate,
  });

  /// The route ID.
  final int? routeId;

  /// The route name.
  final String? routeName;

  /// Number of stages in the plan.
  final int? stageCount;

  /// Whether the plan had a starting date.
  final bool? hadStartingDate;

  @override
  String get name => 'plan_deleted';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        if (stageCount != null) 'stage_count': stageCount,
        if (hadStartingDate != null)
          'had_starting_date': hadStartingDate,
      };
}

/// Fired when a stage is deleted.
class DeleteStageEvent extends AnalyticsEvent {
  /// Creates a [DeleteStageEvent].
  DeleteStageEvent({
    this.routeId,
    this.routeName,
    required this.stageNumber,
    this.totalStages,
    this.startingCityId,
    this.startingCityName,
    this.endingCityId,
    this.endingCityName,
  });

  /// The route ID.
  final int? routeId;

  /// The route name.
  final String? routeName;

  /// The 1-based stage number.
  final int stageNumber;

  /// Total stages after deletion.
  final int? totalStages;

  /// The starting city ID.
  final int? startingCityId;

  /// The starting city name.
  final String? startingCityName;

  /// The ending city ID.
  final int? endingCityId;

  /// The ending city name.
  final String? endingCityName;

  @override
  String get name => 'stage_deleted';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'stage_number': stageNumber,
        if (totalStages != null) 'total_stages': totalStages,
        'starting_city_id': startingCityId,
        'starting_city_name': startingCityName,
        'ending_city_id': endingCityId,
        'ending_city_name': endingCityName,
      };
}

/// Fired when a stage is updated from the plan detail
/// screen. Uses a generic changes map because each update
/// method passes different old/new parameter pairs.
class PlanDetailUpdateStageEvent extends AnalyticsEvent {
  /// Creates a [PlanDetailUpdateStageEvent].
  PlanDetailUpdateStageEvent({
    this.routeId,
    this.routeName,
    required this.stageNumber,
    Map<String, dynamic> changes = const {},
  }) : _changes = changes;

  /// The route ID.
  final int? routeId;

  /// The route name.
  final String? routeName;

  /// The 1-based stage number.
  final int stageNumber;

  final Map<String, dynamic> _changes;

  @override
  String get name => 'plan_detail_update_stage';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'stage_number': stageNumber,
        ..._changes,
      };
}

/// Fired when a plan starting date is set.
class PlanStartingDateSetEvent extends AnalyticsEvent {
  /// Creates a [PlanStartingDateSetEvent].
  PlanStartingDateSetEvent({
    required this.routeId,
    required this.routeName,
    required this.isFirstTime,
    this.daysUntilStart,
  });

  /// The route ID.
  final int routeId;

  /// The route name.
  final String routeName;

  /// Whether this is the first time a date is being set.
  final bool isFirstTime;

  /// Days until the start date (only if in the future).
  final int? daysUntilStart;

  @override
  String get name => 'plan_starting_date_set';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'is_first_time': isFirstTime,
        if (daysUntilStart != null)
          'days_until_start': daysUntilStart,
      };
}

/// Fired when a plan starting date is cleared.
class PlanStartingDateClearedEvent extends AnalyticsEvent {
  /// Creates a [PlanStartingDateClearedEvent].
  PlanStartingDateClearedEvent({
    required this.routeId,
    required this.routeName,
  });

  /// The route ID.
  final int routeId;

  /// The route name.
  final String routeName;

  @override
  String get name => 'plan_starting_date_cleared';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
      };
}

/// Fired when the days-to-stay value of a stage is updated.
class StageDaysToStayUpdatedEvent extends AnalyticsEvent {
  /// Creates a [StageDaysToStayUpdatedEvent].
  StageDaysToStayUpdatedEvent({
    required this.routeId,
    required this.routeName,
    required this.stageNumber,
    required this.oldValue,
    required this.newValue,
  });

  /// The route ID.
  final int routeId;

  /// The route name.
  final String routeName;

  /// The 1-based stage number.
  final int stageNumber;

  /// Previous days-to-stay value.
  final int oldValue;

  /// New days-to-stay value.
  final int newValue;

  @override
  String get name => 'stage_days_to_stay_updated';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'stage_number': stageNumber,
        'old_value': oldValue,
        'new_value': newValue,
      };
}

/// Fired when a stage city is updated from plan detail.
class StageCityUpdatedEvent extends AnalyticsEvent {
  /// Creates a [StageCityUpdatedEvent].
  StageCityUpdatedEvent({
    required this.routeId,
    required this.routeName,
    required this.stageNumber,
    required this.field,
    this.oldCityName,
    required this.newCityName,
  });

  /// The route ID.
  final int routeId;

  /// The route name.
  final String routeName;

  /// The 1-based stage number.
  final int stageNumber;

  /// Which field changed: `start_city`, `end_city`, or `both`.
  final String field;

  /// Previous city name.
  final String? oldCityName;

  /// New city name.
  final String newCityName;

  @override
  String get name => 'stage_city_updated';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'stage_number': stageNumber,
        'field': field,
        if (oldCityName != null) 'old_city_name': oldCityName,
        'new_city_name': newCityName,
      };
}

/// Fired when a stage albergue is updated from plan detail.
class StageAlbergueUpdatedEvent extends AnalyticsEvent {
  /// Creates a [StageAlbergueUpdatedEvent].
  StageAlbergueUpdatedEvent({
    required this.routeId,
    required this.routeName,
    required this.stageNumber,
    required this.field,
    required this.type,
  });

  /// The route ID.
  final int routeId;

  /// The route name.
  final String routeName;

  /// The 1-based stage number.
  final int stageNumber;

  /// Which field changed: `start_albergue` or `end_albergue`.
  final String field;

  /// Type of update: `albergue`, `custom_text`, or `cleared`.
  final String type;

  @override
  String get name => 'stage_albergue_updated';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'stage_number': stageNumber,
        'field': field,
        'type': type,
      };
}

/// Resolve the analytics `action` value for a stage-note change.
///
/// Returns `added` when the note changes from empty/null to non-empty,
/// `cleared` when the note changes from non-empty to empty/null, and
/// `edited` when both sides are non-empty but different. Returns `null`
/// when there is no meaningful change (i.e. both sides are empty or
/// identical) so the caller can skip firing an analytics event.
String? resolveStageNoteAction(String? oldNote, String? newNote) {
  final oldTrimmed = oldNote?.trim() ?? '';
  final newTrimmed = newNote?.trim() ?? '';
  final oldEmpty = oldTrimmed.isEmpty;
  final newEmpty = newTrimmed.isEmpty;
  if (oldEmpty && newEmpty) return null;
  if (oldEmpty && !newEmpty) return 'added';
  if (!oldEmpty && newEmpty) return 'cleared';
  if (oldTrimmed == newTrimmed) return null;
  return 'edited';
}

/// Fired when a stage note is added, edited, or cleared.
class StageNoteUpdatedEvent extends AnalyticsEvent {
  /// Creates a [StageNoteUpdatedEvent].
  StageNoteUpdatedEvent({
    required this.routeId,
    required this.routeName,
    required this.stageNumber,
    required this.action,
    required this.noteLength,
  });

  /// The route ID.
  final int routeId;

  /// The route name.
  final String routeName;

  /// The 1-based stage number.
  final int stageNumber;

  /// Action performed: `added`, `edited`, or `cleared`.
  final String action;

  /// Length of the new note (0 when cleared).
  final int noteLength;

  @override
  String get name => 'stage_note_updated';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'stage_number': stageNumber,
        'action': action,
        'note_length': noteLength,
      };
}

/// Fired when a plan is renamed.
class PlanRenamedEvent extends AnalyticsEvent {
  /// Creates a [PlanRenamedEvent].
  PlanRenamedEvent({
    required this.planId,
    required this.hasName,
  });

  /// The plan ID.
  final int planId;

  /// Whether the plan now has a name (false if cleared).
  final bool hasName;

  @override
  String get name => 'plan_renamed';

  @override
  Map<String, dynamic> get properties => {
        'plan_id': planId,
        'has_name': hasName,
      };
}

