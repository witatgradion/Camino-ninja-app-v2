// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StageEntity _$StageEntityFromJson(Map<String, dynamic> json) => StageEntity(
      id: (json['id'] as num).toInt(),
      stagePlanId: (json['stage_plan_id'] as num).toInt(),
      routeId: (json['route_id'] as num).toInt(),
      stageUuid: json['stage_uuid'] as String?,
      startCityId: (json['start_city_id'] as num).toInt(),
      endCityId: (json['end_city_id'] as num).toInt(),
      date: _nullableDateFromJson(json['date'] as String?),
      startAlbergueId: (json['start_albergue_id'] as num?)?.toInt(),
      endAlbergueId: (json['end_albergue_id'] as num?)?.toInt(),
      customStartNotes: json['custom_start_notes'] as String?,
      customEndNotes: json['custom_end_notes'] as String?,
      stageNotes: json['stage_notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      stageNumber: (json['stage_number'] as num?)?.toInt(),
      daysToStay: (json['days_to_stay'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$StageEntityToJson(StageEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stage_plan_id': instance.stagePlanId,
      'route_id': instance.routeId,
      if (instance.stageUuid case final value?) 'stage_uuid': value,
      'date': _nullableDateToJson(instance.date),
      'start_city_id': instance.startCityId,
      'end_city_id': instance.endCityId,
      'start_albergue_id': instance.startAlbergueId,
      'end_albergue_id': instance.endAlbergueId,
      'custom_start_notes': instance.customStartNotes,
      'custom_end_notes': instance.customEndNotes,
      'stage_notes': instance.stageNotes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'stage_number': instance.stageNumber,
      'days_to_stay': instance.daysToStay,
    };
