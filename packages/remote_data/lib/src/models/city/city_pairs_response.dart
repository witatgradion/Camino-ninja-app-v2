import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/city/city_pairs_for_start_city_response.dart';

part 'city_pairs_response.g.dart';

@JsonSerializable()
class CityPairsExportResponse extends Equatable {
  final int? calculatedAt;
  final int? totalPairs;
  final Map<String, CityPairsForStartCityResponse>? pairs;
  const CityPairsExportResponse({
    this.calculatedAt,
    this.totalPairs,
    this.pairs,
  });

  factory CityPairsExportResponse.fromJson(Map<String, dynamic> json) =>
      _$CityPairsExportResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CityPairsExportResponseToJson(this);

  @override
  List<Object?> get props => [calculatedAt, totalPairs, pairs];
}
