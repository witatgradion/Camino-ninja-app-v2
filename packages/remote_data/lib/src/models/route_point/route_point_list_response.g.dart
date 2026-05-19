// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_point_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePointListResponse _$RoutePointListResponseFromJson(
        Map<String, dynamic> json) =>
    RoutePointListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => RoutePointResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoutePointListResponseToJson(
        RoutePointListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
