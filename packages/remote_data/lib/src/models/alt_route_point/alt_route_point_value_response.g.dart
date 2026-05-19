// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alt_route_point_value_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AltRoutePointValueResponse _$AltRoutePointValueResponseFromJson(
        Map<String, dynamic> json) =>
    AltRoutePointValueResponse(
      id: (json['id'] as num).toInt(),
      orderKey: (json['order_key'] as num).toInt(),
      geom:
          GeometryResponse.fromJson(json['geo_point'] as Map<String, dynamic>),
      altRoutePointId: (json['alt_route_points_id'] as num).toInt(),
    );

Map<String, dynamic> _$AltRoutePointValueResponseToJson(
        AltRoutePointValueResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_key': instance.orderKey,
      'alt_route_points_id': instance.altRoutePointId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
