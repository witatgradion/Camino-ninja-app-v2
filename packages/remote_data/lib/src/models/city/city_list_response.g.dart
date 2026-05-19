// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityListResponse _$CityListResponseFromJson(Map<String, dynamic> json) =>
    CityListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => CityResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CityListResponseToJson(CityListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
