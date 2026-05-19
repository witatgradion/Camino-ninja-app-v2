import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage/src/models/albergue/alt_route_point_value_entity.dart';
import 'package:storage/src/models/bool_mapper.dart';

part 'alt_route_point_entity.g.dart';

@JsonSerializable()
class AltRoutePointEntity extends Equatable {
  AltRoutePointEntity({
    required this.id,
    required this.orderKey,
    this.color,
    required this.dotted,
    required this.routeId,
    List<AltRoutePointValueEntity>? values,
  }) : values = values ?? [];

  final int id;
  @JsonKey(name: 'order_key')
  final int orderKey;
  final String? color;
  @JsonKey(fromJson: intToBool)
  final bool dotted;
  @JsonKey(name: 'route_id')
  final int routeId;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final List<AltRoutePointValueEntity> values;

  factory AltRoutePointEntity.fromJson(Map<String, dynamic> json) =>
      _$AltRoutePointEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AltRoutePointEntityToJson(this);

  @override
  List<Object?> get props => [
        id,
        orderKey,
        color,
        dotted,
        routeId,
        values,
      ];
}
