// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_point_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePointEntity _$RoutePointEntityFromJson(Map<String, dynamic> json) =>
    RoutePointEntity(
      id: (json['id'] as num).toInt(),
      orderKey: (json['order_key'] as num).toInt(),
      elevation: (json['elevation'] as num).toDouble(),
      routeId: (json['route_id'] as num?)?.toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$RoutePointEntityToJson(RoutePointEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_key': instance.orderKey,
      'elevation': instance.elevation,
      'route_id': instance.routeId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
