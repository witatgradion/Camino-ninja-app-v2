import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/route/route_response.dart';

part 'route_list_response.g.dart';

@JsonSerializable()
class RouteListResponse extends Equatable {

  const RouteListResponse({
    required this.data,
  });

  factory RouteListResponse.fromJson(Map<String, dynamic> json) =>
      _$RouteListResponseFromJson(json);
  final List<RouteResponse> data;

  Map<String, dynamic> toJson() => _$RouteListResponseToJson(this);

  @override
  List<Object> get props => [data];
}
