import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_point_entity.g.dart';

@JsonSerializable()
class RoutePointEntity extends Equatable {
  const RoutePointEntity({
    required this.id,
    required this.orderKey,
    required this.elevation,
    this.routeId,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  @JsonKey(name: 'order_key')
  final int orderKey;
  final double elevation;
  @JsonKey(name: 'route_id')
  final int? routeId;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [
        id,
        orderKey,
        elevation,
        routeId,
        latitude,
        longitude,
      ];

  factory RoutePointEntity.fromJson(Map<String, dynamic> json) =>
      _$RoutePointEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RoutePointEntityToJson(this);
}
