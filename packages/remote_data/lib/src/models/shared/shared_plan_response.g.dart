// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_plan_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedPlanResponse _$SharedPlanResponseFromJson(Map<String, dynamic> json) =>
    SharedPlanResponse(
      routeId: (json['route_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      uuid: json['uuid'] as String?,
      planUuid: json['plan_uuid'] as String?,
      startingDate: json['starting_date'] as String?,
      stages: (json['stages'] as List<dynamic>?)
              ?.map((e) =>
                  SharedStageResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SharedPlanResponseToJson(SharedPlanResponse instance) =>
    <String, dynamic>{
      'route_id': instance.routeId,
      'name': instance.name,
      'uuid': instance.uuid,
      'plan_uuid': instance.planUuid,
      'starting_date': instance.startingDate,
      'stages': instance.stages,
    };

SharedStageResponse _$SharedStageResponseFromJson(Map<String, dynamic> json) =>
    SharedStageResponse(
      stageNumber: (json['stage_number'] as num?)?.toInt(),
      routeId: (json['route_id'] as num?)?.toInt(),
      startCityId: (json['start_city_id'] as num?)?.toInt(),
      endCityId: (json['end_city_id'] as num?)?.toInt(),
      date: json['date'] as String?,
      daysToStay: (json['days_to_stay'] as num?)?.toInt(),
      startAlbergueId: (json['start_albergue_id'] as num?)?.toInt(),
      endAlbergueId: (json['end_albergue_id'] as num?)?.toInt(),
      customStartNotes: json['custom_start_notes'] as String?,
      customEndNotes: json['custom_end_notes'] as String?,
      stageNotes: json['stage_notes'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$SharedStageResponseToJson(
        SharedStageResponse instance) =>
    <String, dynamic>{
      'stage_number': instance.stageNumber,
      'route_id': instance.routeId,
      'date': instance.date,
      'days_to_stay': instance.daysToStay,
      'start_city_id': instance.startCityId,
      'end_city_id': instance.endCityId,
      'start_albergue_id': instance.startAlbergueId,
      'end_albergue_id': instance.endAlbergueId,
      'custom_start_notes': instance.customStartNotes,
      'custom_end_notes': instance.customEndNotes,
      'stage_notes': instance.stageNotes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
