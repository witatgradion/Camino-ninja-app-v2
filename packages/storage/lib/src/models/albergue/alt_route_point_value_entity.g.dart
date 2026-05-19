// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alt_route_point_value_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AltRoutePointValueEntity _$AltRoutePointValueEntityFromJson(
        Map<String, dynamic> json) =>
    AltRoutePointValueEntity(
      id: (json['alt_route_points_value_id'] as num).toInt(),
      orderKey: (json['order_key'] as num).toInt(),
      altRoutePointId: (json['alt_route_points_id'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$AltRoutePointValueEntityToJson(
        AltRoutePointValueEntity instance) =>
    <String, dynamic>{
      'alt_route_points_value_id': instance.id,
      'order_key': instance.orderKey,
      'alt_route_points_id': instance.altRoutePointId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
