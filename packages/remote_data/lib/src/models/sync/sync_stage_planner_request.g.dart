// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_stage_planner_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncStagePlannerRequest _$SyncStagePlannerRequestFromJson(
        Map<String, dynamic> json) =>
    SyncStagePlannerRequest(
      plans: (json['plans'] as List<dynamic>)
          .map((e) => SyncPlanRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncStagePlannerRequestToJson(
        SyncStagePlannerRequest instance) =>
    <String, dynamic>{
      'plans': instance.plans,
    };

SyncPlanRequest _$SyncPlanRequestFromJson(Map<String, dynamic> json) =>
    SyncPlanRequest(
      uuid: json['uuid'] as String,
      stages: (json['stages'] as List<dynamic>)
          .map((e) => SyncStageRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: json['updated_at'] as String,
      routeId: (json['route_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      isImported: json['is_imported'] as bool? ?? false,
      startingDate: json['starting_date'] as String?,
      deletedAt: json['deleted_at'] as String?,
      trailRouteIds: json['trail_route_ids'] as String?,
    );

Map<String, dynamic> _$SyncPlanRequestToJson(SyncPlanRequest instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      if (instance.routeId case final value?) 'route_id': value,
      'name': instance.name,
      'is_imported': instance.isImported,
      'stages': instance.stages,
      'updated_at': instance.updatedAt,
      'starting_date': instance.startingDate,
      'deleted_at': instance.deletedAt,
      'trail_route_ids': instance.trailRouteIds,
    };

SyncStageRequest _$SyncStageRequestFromJson(Map<String, dynamic> json) =>
    SyncStageRequest(
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

Map<String, dynamic> _$SyncStageRequestToJson(SyncStageRequest instance) =>
    <String, dynamic>{
      'stage_number': instance.stageNumber,
      if (instance.routeId case final value?) 'route_id': value,
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
