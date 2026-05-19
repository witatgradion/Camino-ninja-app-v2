// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_plan_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StagePlanEntity _$StagePlanEntityFromJson(Map<String, dynamic> json) =>
    StagePlanEntity(
      id: (json['id'] as num).toInt(),
      routeId: (json['route_id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isImported: json['is_imported'] == null
          ? false
          : StagePlanEntity._boolFromInt(json['is_imported']),
      name: json['name'] as String?,
      uuid: json['uuid'] as String?,
      planUuid: json['plan_uuid'] as String?,
      deletedAt: json['deleted_at'] as String?,
      trailRouteIds: json['trail_route_ids'] as String?,
      startingDate: json['starting_date'] as String?,
    );

Map<String, dynamic> _$StagePlanEntityToJson(StagePlanEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'route_id': instance.routeId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_imported': StagePlanEntity._boolToInt(instance.isImported),
      'name': instance.name,
      'uuid': instance.uuid,
      'plan_uuid': instance.planUuid,
      'deleted_at': instance.deletedAt,
      'trail_route_ids': instance.trailRouteIds,
      'starting_date': instance.startingDate,
    };
