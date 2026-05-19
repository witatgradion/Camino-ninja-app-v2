import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_stage_planner_response.g.dart';

@JsonSerializable()
class SyncStagePlannerResponse extends Equatable {
  const SyncStagePlannerResponse({required this.plans});

  factory SyncStagePlannerResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncStagePlannerResponseFromJson(json);

  final List<SyncPlanResponse> plans;

  Map<String, dynamic> toJson() => _$SyncStagePlannerResponseToJson(this);

  @override
  List<Object?> get props => [plans];
}

@JsonSerializable()
class SyncPlanResponse extends Equatable {
  const SyncPlanResponse({
    required this.uuid,
    required this.createdAt,
    required this.updatedAt,
    this.routeId,
    this.name,
    this.isImported = false,
    this.planUuid,
    this.deviceId,
    this.deviceName,
    this.startingDate,
    this.stages = const [],
    this.deletedAt,
    this.trailRouteIds,
  });

  factory SyncPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncPlanResponseFromJson(json);

  final String uuid;
  @JsonKey(name: 'route_id')
  final int? routeId;
  final String? name;
  @JsonKey(name: 'is_imported')
  final bool isImported;
  @JsonKey(name: 'plan_uuid')
  final String? planUuid;
  @JsonKey(name: 'device_id')
  final String? deviceId;
  @JsonKey(name: 'device_name')
  final String? deviceName;
  @JsonKey(name: 'starting_date')
  final String? startingDate;
  final List<SyncStageResponse> stages;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;
  @JsonKey(name: 'trail_route_ids')
  final String? trailRouteIds;

  Map<String, dynamic> toJson() => _$SyncPlanResponseToJson(this);

  @override
  List<Object?> get props => [
        uuid,
        routeId,
        name,
        isImported,
        planUuid,
        deviceId,
        deviceName,
        startingDate,
        stages,
        createdAt,
        updatedAt,
        deletedAt,
        trailRouteIds,
      ];
}

@JsonSerializable()
class SyncStageResponse extends Equatable {
  const SyncStageResponse({
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

  factory SyncStageResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncStageResponseFromJson(json);

  @JsonKey(name: 'stage_number')
  final int stageNumber;
  @JsonKey(name: 'route_id')
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

  Map<String, dynamic> toJson() => _$SyncStageResponseToJson(this);

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
