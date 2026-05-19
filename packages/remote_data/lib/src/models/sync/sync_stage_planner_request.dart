import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_stage_planner_request.g.dart';

@JsonSerializable()
class SyncStagePlannerRequest extends Equatable {
  const SyncStagePlannerRequest({required this.plans});

  factory SyncStagePlannerRequest.fromJson(Map<String, dynamic> json) =>
      _$SyncStagePlannerRequestFromJson(json);

  final List<SyncPlanRequest> plans;

  Map<String, dynamic> toJson() => _$SyncStagePlannerRequestToJson(this);

  @override
  List<Object?> get props => [plans];
}

@JsonSerializable()
class SyncPlanRequest extends Equatable {
  const SyncPlanRequest({
    required this.uuid,
    required this.stages,
    required this.updatedAt,
    this.routeId,
    this.name,
    this.isImported = false,
    this.startingDate,
    this.deletedAt,
    this.trailRouteIds,
  });

  factory SyncPlanRequest.fromJson(Map<String, dynamic> json) =>
      _$SyncPlanRequestFromJson(json);

  final String uuid;
  @JsonKey(name: 'route_id', includeIfNull: false)
  final int? routeId;
  final String? name;
  @JsonKey(name: 'is_imported')
  final bool isImported;
  final List<SyncStageRequest> stages;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'starting_date')
  final String? startingDate;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;
  @JsonKey(name: 'trail_route_ids')
  final String? trailRouteIds;

  Map<String, dynamic> toJson() => _$SyncPlanRequestToJson(this);

  @override
  List<Object?> get props => [
        uuid,
        routeId,
        name,
        isImported,
        stages,
        updatedAt,
        startingDate,
        deletedAt,
        trailRouteIds,
      ];
}

@JsonSerializable()
class SyncStageRequest extends Equatable {
  const SyncStageRequest({
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

  factory SyncStageRequest.fromJson(Map<String, dynamic> json) =>
      _$SyncStageRequestFromJson(json);

  @JsonKey(name: 'stage_number')
  final int stageNumber;
  @JsonKey(name: 'route_id', includeIfNull: false)
  final int? routeId;
  final String? date;
  @JsonKey(name: 'start_city_id')
  final int startCityId;
  @JsonKey(name: 'end_city_id')
  final int endCityId;
  @JsonKey(name: 'start_albergue_id')
  final int? startAlbergueId;
  @JsonKey(name: 'end_albergue_id')
  final int? endAlbergueId;
  @JsonKey(name: 'custom_start_notes')
  final String? customStartNotes;
  @JsonKey(name: 'custom_end_notes')
  final String? customEndNotes;
  @JsonKey(name: 'stage_notes')
  final String? stageNotes;
  @JsonKey(name: 'days_to_stay')
  final int? daysToStay;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'stage_uuid', includeIfNull: false)
  final String? stageUuid;

  Map<String, dynamic> toJson() => _$SyncStageRequestToJson(this);

  @override
  List<Object?> get props => [
        stageNumber,
        routeId,
        date,
        startCityId,
        endCityId,
        startAlbergueId,
        endAlbergueId,
        customStartNotes,
        customEndNotes,
        stageNotes,
        daysToStay,
        createdAt,
        updatedAt,
        stageUuid,
      ];
}
