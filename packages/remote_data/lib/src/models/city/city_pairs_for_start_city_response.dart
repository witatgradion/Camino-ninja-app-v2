import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/city/city_pair_detail_response.dart';

part 'city_pairs_for_start_city_response.g.dart';

@JsonSerializable()
class CityPairsForStartCityResponse extends Equatable {
  final int? startCityId;
  final String? startCityName;
  final int? totalPlans;
  final List<CityPairDetailResponse>? pairs;

  const CityPairsForStartCityResponse({
    this.startCityId,
    this.startCityName,
    this.totalPlans,
    this.pairs,
  });

  factory CityPairsForStartCityResponse.fromJson(Map<String, dynamic> json) =>
      _$CityPairsForStartCityResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CityPairsForStartCityResponseToJson(this);

  @override
  List<Object?> get props => [startCityId, startCityName, totalPlans, pairs];
}
