// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_stage_planner_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncStagePlannerResponse _$SyncStagePlannerResponseFromJson(
        Map<String, dynamic> json) =>
    SyncStagePlannerResponse(
      plans: (json['plans'] as List<dynamic>)
          .map((e) => SyncPlanResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncStagePlannerResponseToJson(
        SyncStagePlannerResponse instance) =>
    <String, dynamic>{
      'plans': instance.plans,
    };

SyncPlanResponse _$SyncPlanResponseFromJson(Map<String, dynamic> json) =>
    SyncPlanResponse(
      uuid: json['uuid'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      routeId: (json['route_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      isImported: json['is_imported'] as bool? ?? false,
      planUuid: json['plan_uuid'] as String?,
      deviceId: json['device_id'] as String?,
      deviceName: json['device_name'] as String?,
      startingDate: json['starting_date'] as String?,
      stages: (json['stages'] as List<dynamic>?)
              ?.map(
                  (e) => SyncStageResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      deletedAt: json['deleted_at'] as String?,
      trailRouteIds: json['trail_route_ids'] as String?,
    );

Map<String, dynamic> _$SyncPlanResponseToJson(SyncPlanResponse instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'route_id': instance.routeId,
      'name': instance.name,
      'is_imported': instance.isImported,
      'plan_uuid': instance.planUuid,
      'device_id': instance.deviceId,
      'device_name': instance.deviceName,
      'starting_date': instance.startingDate,
      'stages': instance.stages,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
      'trail_route_ids': instance.trailRouteIds,
    };

SyncStageResponse _$SyncStageResponseFromJson(Map<String, dynamic> json) =>
    SyncStageResponse(
      stageNumber: (json['stage_number'] as num).toInt(),
      startCityId: (json['start_city_id'] as num).toInt(),
      endCityId: (json['end_city_id'] as num).toInt(),
      routeId: (json['route_id'] as num?)?.toInt(),
      date: json['date'] as String?,
      startAlbergueId: (json['start_albergue_id'] as num?)?.toInt(),
      endAlbergueId: (json['end_albergue_id'] as num?)?.toInt(),
      customStartNotes: json['custom_start_notes'] as String?,
      customEndNotes: json['custom_end_notes'] as String?,
      stageNotes: json['stage_notes'] as String?,
      daysToStay: (json['days_to_stay'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      stageUuid: json['stage_uuid'] as String?,
    );

Map<String, dynamic> _$SyncStageResponseToJson(SyncStageResponse instance) =>
    <String, dynamic>{
      'stage_number': instance.stageNumber,
      'route_id': instance.routeId,
      'date': instance.date,
      'start_city_id': instance.startCityId,
      'end_city_id': instance.endCityId,
      'start_albergue_id': instance.startAlbergueId,
      'end_albergue_id': instance.endAlbergueId,
      'custom_start_notes': instance.customStartNotes,
      'custom_end_notes': instance.customEndNotes,
      'stage_notes': instance.stageNotes,
      'days_to_stay': instance.daysToStay,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      if (instance.stageUuid case final value?) 'stage_uuid': value,
    };
