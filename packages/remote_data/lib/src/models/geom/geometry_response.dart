import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'geometry_response.g.dart';

@JsonSerializable()
class GeometryResponse extends Equatable {


  const GeometryResponse({
    required this.lat,
    required this.lon,
  });

  factory GeometryResponse.fromJson(Map<String, dynamic> json) =>
      _$GeometryResponseFromJson(json);

  final double lat;
  final double lon;

  Map<String, dynamic> toJson() => _$GeometryResponseToJson(this);

  @override
  List<Object> get props => [lat, lon];
}
