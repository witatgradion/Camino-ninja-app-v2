import 'package:json_annotation/json_annotation.dart';

part 'alt_route_point_value_entity.g.dart';

@JsonSerializable()
class AltRoutePointValueEntity {

  const AltRoutePointValueEntity({
    required this.id,
    required this.orderKey,
    required this.altRoutePointId,
    required this.latitude,
    required this.longitude,
  });

  @JsonKey(name: 'alt_route_points_value_id')
  final int id;
  @JsonKey(name: 'order_key')
  final int orderKey;
  @JsonKey(name: 'alt_route_points_id')
  final int altRoutePointId;
  final double latitude;
  final double longitude;

  factory AltRoutePointValueEntity.fromJson(Map<String, dynamic> json) =>
      _$AltRoutePointValueEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AltRoutePointValueEntityToJson(this);
}