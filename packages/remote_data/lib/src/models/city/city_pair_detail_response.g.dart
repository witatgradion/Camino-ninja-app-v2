// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_pair_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityPairDetailResponse _$CityPairDetailResponseFromJson(
        Map<String, dynamic> json) =>
    CityPairDetailResponse(
      endCityId: (json['endCityId'] as num?)?.toInt(),
      endCityName: json['endCityName'] as String?,
      percentage: (json['percentage'] as num?)?.toDouble(),
      pairCount: (json['pairCount'] as num?)?.toInt(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CityPairDetailResponseToJson(
        CityPairDetailResponse instance) =>
    <String, dynamic>{
      'endCityId': instance.endCityId,
      'endCityName': instance.endCityName,
      'percentage': instance.percentage,
      'pairCount': instance.pairCount,
      'distanceKm': instance.distanceKm,
    };
