// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_pairs_for_start_city_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityPairsForStartCityResponse _$CityPairsForStartCityResponseFromJson(
        Map<String, dynamic> json) =>
    CityPairsForStartCityResponse(
      startCityId: (json['startCityId'] as num?)?.toInt(),
      startCityName: json['startCityName'] as String?,
      totalPlans: (json['totalPlans'] as num?)?.toInt(),
      pairs: (json['pairs'] as List<dynamic>?)
          ?.map(
              (e) => CityPairDetailResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CityPairsForStartCityResponseToJson(
        CityPairsForStartCityResponse instance) =>
    <String, dynamic>{
      'startCityId': instance.startCityId,
      'startCityName': instance.startCityName,
      'totalPlans': instance.totalPlans,
      'pairs': instance.pairs,
    };
