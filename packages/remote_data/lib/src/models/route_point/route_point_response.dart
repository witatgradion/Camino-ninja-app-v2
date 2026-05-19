import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/geom/geometry_response.dart';

part 'route_point_response.g.dart';

@JsonSerializable()
class RoutePointResponse extends Equatable {

  RoutePointResponse({
    required this.id,
    required this.orderKey,
    required this.geom,
    required this.elevation,
    required this.routeId,
  })  : latitude = geom.lat,
        longitude = geom.lon;

  factory RoutePointResponse.fromJson(Map<String, dynamic> json) =>
      _$RoutePointResponseFromJson(json);
  final int id;
  @JsonKey(name: 'order_key')
  final int orderKey;
  @JsonKey(name: 'geo_point', includeToJson: false)
  final GeometryResponse geom;
  final double elevation;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(includeFromJson: false, includeToJson: true)
  final double latitude;
  @JsonKey(includeFromJson: false, includeToJson: true)
  final double longitude;

  Map<String, dynamic> toJson() => _$RoutePointResponseToJson(this);

  @override
  List<Object?> get props => [
    id,
    orderKey,
    geom,
    elevation,
    routeId,
  ];
}
