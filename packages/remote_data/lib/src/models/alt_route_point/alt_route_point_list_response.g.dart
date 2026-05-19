// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alt_route_point_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AltRoutePointListResponse _$AltRoutePointListResponseFromJson(
        Map<String, dynamic> json) =>
    AltRoutePointListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AltRoutePointResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AltRoutePointListResponseToJson(
        AltRoutePointListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
