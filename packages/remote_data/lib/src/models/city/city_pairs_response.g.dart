// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_pairs_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityPairsExportResponse _$CityPairsExportResponseFromJson(
        Map<String, dynamic> json) =>
    CityPairsExportResponse(
      calculatedAt: (json['calculatedAt'] as num?)?.toInt(),
      totalPairs: (json['totalPairs'] as num?)?.toInt(),
      pairs: (json['pairs'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k,
            CityPairsForStartCityResponse.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$CityPairsExportResponseToJson(
        CityPairsExportResponse instance) =>
    <String, dynamic>{
      'calculatedAt': instance.calculatedAt,
      'totalPairs': instance.totalPairs,
      'pairs': instance.pairs,
    };
