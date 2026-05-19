import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shared_plan_response.g.dart';

@JsonSerializable()
class SharedPlanResponse extends Equatable {
  const SharedPlanResponse({
    this.routeId,
    this.name,
    this.uuid,
    this.planUuid,
    this.startingDate,
    this.stages = const [],
  });

  factory SharedPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$SharedPlanResponseFromJson(json);

  @JsonKey(name: 'route_id')
  final int? routeId;
  final String? name;
  final String? uuid;
  @JsonKey(name: 'plan_uuid')
  final String? planUuid;
  @JsonKey(name: 'starting_date')
  final String? startingDate;
  final List<SharedStageResponse> stages;

  Map<String, dynamic> toJson() => _$SharedPlanResponseToJson(this);

  @override
  List<Object?> get props =>
      [routeId, name, uuid, planUuid, startingDate, stages];
}

@JsonSerializable()
class SharedStageResponse extends Equatable {
  const SharedStageResponse({
    this.stageNumber,
    this.routeId,
    this.startCityId,
    this.endCityId,
    this.date,
    this.daysToStay,
    this.startAlbergueId,
    this.endAlbergueId,
    this.customStartNotes,
    this.customEndNotes,
    this.stageNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory SharedStageResponse.fromJson(Map<String, dynamic> json) =>
      _$SharedStageResponseFromJson(json);

  @JsonKey(name: 'stage_number')
  final int? stageNumber;
  @JsonKey(name: 'route_id')
  final int? routeId;
  final String? date;
  @JsonKey(name: 'days_to_stay')
  final int? daysToStay;
  @JsonKey(name: 'start_city_id')
  final int? startCityId;
  @JsonKey(name: 'end_city_id')
  final int? endCityId;
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
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  Map<String, dynamic> toJson() => _$SharedStageResponseToJson(this);

  @override
  List<Object?> get props => [
        stageNumber,
        routeId,
        date,
        daysToStay,
        startCityId,
        endCityId,
        startAlbergueId,
        endAlbergueId,
        customStartNotes,
        customEndNotes,
        stageNotes,
        createdAt,
        updatedAt,
      ];
}
