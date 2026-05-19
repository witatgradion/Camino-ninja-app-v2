import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/alt_route_point/alt_route_point_response.dart';

part 'alt_route_point_list_response.g.dart';

@JsonSerializable()
class AltRoutePointListResponse extends Equatable {
  const AltRoutePointListResponse({
    required this.data,
  });

  factory AltRoutePointListResponse.fromJson(Map<String, dynamic> json) =>
      _$AltRoutePointListResponseFromJson(json);
  final List<AltRoutePointResponse> data;

  Map<String, dynamic> toJson() => _$AltRoutePointListResponseToJson(this);

  @override
  List<Object> get props => [data];
}
