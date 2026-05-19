import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/geom/geometry_response.dart';

part 'alt_route_point_value_response.g.dart';

@JsonSerializable()
class AltRoutePointValueResponse extends Equatable {
  AltRoutePointValueResponse({
    required this.id,
    required this.orderKey,
    required this.geom,
    required this.altRoutePointId,
  }) : latitude = geom.lat,
        longitude = geom.lon;

  factory AltRoutePointValueResponse.fromJson(Map<String, dynamic> json) =>
      _$AltRoutePointValueResponseFromJson(json);

  final int id;
  @JsonKey(name: 'order_key')
  final int orderKey;
  @JsonKey(name: 'geo_point', includeToJson: false)
  final GeometryResponse geom;
  @JsonKey(name: 'alt_route_points_id')
  final int altRoutePointId;
  @JsonKey(includeFromJson: false, includeToJson: true)
  final double latitude;
  @JsonKey(includeFromJson: false, includeToJson: true)
  final double longitude;

  Map<String, dynamic> toJson() => _$AltRoutePointValueResponseToJson(this);

  @override
  List<Object> get props => [
        id,
        orderKey,
        geom,
        altRoutePointId,
      ];
}
