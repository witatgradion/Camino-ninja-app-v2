// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_point_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePointResponse _$RoutePointResponseFromJson(Map<String, dynamic> json) =>
    RoutePointResponse(
      id: (json['id'] as num).toInt(),
      orderKey: (json['order_key'] as num).toInt(),
      geom:
          GeometryResponse.fromJson(json['geo_point'] as Map<String, dynamic>),
      elevation: (json['elevation'] as num).toDouble(),
      routeId: (json['route_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RoutePointResponseToJson(RoutePointResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_key': instance.orderKey,
      'elevation': instance.elevation,
      'route_id': instance.routeId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
