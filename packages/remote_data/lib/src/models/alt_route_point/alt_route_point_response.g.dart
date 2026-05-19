// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alt_route_point_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AltRoutePointResponse _$AltRoutePointResponseFromJson(
        Map<String, dynamic> json) =>
    AltRoutePointResponse(
      id: (json['id'] as num).toInt(),
      orderKey: (json['order_key'] as num).toInt(),
      routeId: (json['route_id'] as num).toInt(),
      color: json['color'] as String,
      dotted: json['dotted'] as bool,
      altRoutePointValues: (json['alt_route_points_values'] as List<dynamic>)
          .map((e) =>
              AltRoutePointValueResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AltRoutePointResponseToJson(
        AltRoutePointResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_key': instance.orderKey,
      'route_id': instance.routeId,
      'color': instance.color,
      'dotted': _boolToInt(instance.dotted),
    };
