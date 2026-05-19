import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/route_point/route_point_response.dart';

part 'route_point_list_response.g.dart';

@JsonSerializable()
class RoutePointListResponse extends Equatable {
  const RoutePointListResponse({
    required this.data,
  });

  factory RoutePointListResponse.fromJson(Map<String, dynamic> json) =>
      _$RoutePointListResponseFromJson(json);
  final List<RoutePointResponse> data;

  Map<String, dynamic> toJson() => _$RoutePointListResponseToJson(this);

  @override
  List<Object> get props => [data];
}
