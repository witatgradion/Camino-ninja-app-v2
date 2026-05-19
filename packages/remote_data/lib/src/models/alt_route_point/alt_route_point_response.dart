import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/remote_data.dart';

part 'alt_route_point_response.g.dart';

@JsonSerializable()
class AltRoutePointResponse extends Equatable {
  const AltRoutePointResponse({
    required this.id,
    required this.orderKey,
    required this.routeId,
    required this.color,
    required this.dotted,
    required this.altRoutePointValues,
  });

  factory AltRoutePointResponse.fromJson(Map<String, dynamic> json) =>
      _$AltRoutePointResponseFromJson(json);

  final int id;
  @JsonKey(name: 'order_key')
  final int orderKey;
  @JsonKey(name: 'route_id')
  final int routeId;
  final String color;
  @JsonKey(toJson: _boolToInt)
  final bool dotted;
  @JsonKey(name: 'alt_route_points_values', includeToJson: false)
  final List<AltRoutePointValueResponse> altRoutePointValues;

  Map<String, dynamic> toJson() => _$AltRoutePointResponseToJson(this);

  @override
  List<Object> get props => [
        id,
        orderKey,
        routeId,
        color,
        dotted,
        altRoutePointValues,
      ];
}

int? _boolToInt(bool? value) => value == null ? null : (value ? 1 : 0);
