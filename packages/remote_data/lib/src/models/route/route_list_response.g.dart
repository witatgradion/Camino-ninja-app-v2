// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteListResponse _$RouteListResponseFromJson(Map<String, dynamic> json) =>
    RouteListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => RouteResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteListResponseToJson(RouteListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
