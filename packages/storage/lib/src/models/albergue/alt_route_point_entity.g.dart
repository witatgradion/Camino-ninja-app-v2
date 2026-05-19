// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alt_route_point_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AltRoutePointEntity _$AltRoutePointEntityFromJson(Map<String, dynamic> json) =>
    AltRoutePointEntity(
      id: (json['id'] as num).toInt(),
      orderKey: (json['order_key'] as num).toInt(),
      color: json['color'] as String?,
      dotted: intToBool((json['dotted'] as num?)?.toInt()),
      routeId: (json['route_id'] as num).toInt(),
    );

Map<String, dynamic> _$AltRoutePointEntityToJson(
        AltRoutePointEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_key': instance.orderKey,
      'color': instance.color,
      'dotted': instance.dotted,
      'route_id': instance.routeId,
    };
