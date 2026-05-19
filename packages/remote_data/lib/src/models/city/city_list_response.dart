import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/city/city_response.dart';

part 'city_list_response.g.dart';

@JsonSerializable()
class CityListResponse extends Equatable {

  const CityListResponse({
    required this.data,
  });

  factory CityListResponse.fromJson(Map<String, dynamic> json) =>
      _$CityListResponseFromJson(json);
  final List<CityResponse> data;

  Map<String, dynamic> toJson() => _$CityListResponseToJson(this);

  @override
  List<Object> get props => [data];
}
