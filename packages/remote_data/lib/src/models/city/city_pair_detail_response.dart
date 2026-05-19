import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'city_pair_detail_response.g.dart';

@JsonSerializable()
class CityPairDetailResponse extends Equatable {
  final int? endCityId;
  final String? endCityName;
  final double? percentage;
  final int? pairCount;
  final double? distanceKm;

  const CityPairDetailResponse({
    this.endCityId,
    this.endCityName,
    this.percentage,
    this.pairCount,
    this.distanceKm,
  });

  factory CityPairDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$CityPairDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CityPairDetailResponseToJson(this);

  @override
  List<Object?> get props =>
      [endCityId, endCityName, percentage, pairCount, distanceKm];
}
