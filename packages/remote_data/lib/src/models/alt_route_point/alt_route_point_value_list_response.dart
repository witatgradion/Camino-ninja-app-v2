import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/remote_data.dart';

part 'alt_route_point_value_list_response.g.dart';

@JsonSerializable()
class AltRoutePointValueListResponse {
  const AltRoutePointValueListResponse({
    required this.data,
  });

  factory AltRoutePointValueListResponse.fromJson(Map<String, dynamic> json) =>
      _$AltRoutePointValueListResponseFromJson(json);

  final List<AltRoutePointValueResponse> data;

  Map<String, dynamic> toJson() => _$AltRoutePointValueListResponseToJson(this);
}
