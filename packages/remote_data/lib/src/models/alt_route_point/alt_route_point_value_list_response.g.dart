// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alt_route_point_value_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AltRoutePointValueListResponse _$AltRoutePointValueListResponseFromJson(
        Map<String, dynamic> json) =>
    AltRoutePointValueListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              AltRoutePointValueResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AltRoutePointValueListResponseToJson(
        AltRoutePointValueListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
