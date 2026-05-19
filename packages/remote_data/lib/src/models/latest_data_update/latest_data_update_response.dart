import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'latest_data_update_response.g.dart';

@JsonSerializable()
class LatestDataUpdateResponse extends Equatable {
  const LatestDataUpdateResponse({
    this.albergues,
    this.albergueUserImages,
    this.cities,
    this.routes,
    this.routePoints,
    this.altRoutePoints,
  });

  factory LatestDataUpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$LatestDataUpdateResponseFromJson(json);

  @JsonKey(name: 'albergues_updated_at', fromJson: _parseDateTimeNullable)
  final DateTime? albergues;

  @JsonKey(
    name: 'albergue_user_images_updated_at',
    fromJson: _parseDateTimeNullable,
  )
  final DateTime? albergueUserImages;

  @JsonKey(name: 'cities_updated_at', fromJson: _parseDateTimeNullable)
  final DateTime? cities;

  @JsonKey(name: 'routes_updated_at', fromJson: _parseDateTimeNullable)
  final DateTime? routes;

  @JsonKey(
    name: 'route_points_updated_at',
    fromJson: _parseDateTimeNullable,
  )
  final DateTime? routePoints;

  @JsonKey(
    name: 'alt_route_points_updated_at',
    fromJson: _parseDateTimeNullable,
  )
  final DateTime? altRoutePoints;

  static DateTime? _parseDateTimeNullable(String? date) =>
      date != null ? DateTime.parse(date) : null;

  Map<String, dynamic> toDatabaseMapping() => <String, dynamic>{
    'id': 1,
    'albergues_updated_at': albergues?.toIso8601String(),
    'albergue_user_images_updated_at': albergueUserImages?.toIso8601String(),
    'cities_updated_at': cities?.toIso8601String(),
    'routes_updated_at': routes?.toIso8601String(),
    'route_points_updated_at': routePoints?.toIso8601String(),
    'alt_route_points_updated_at': altRoutePoints?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
        albergues,
        albergueUserImages,
        cities,
        routes,
        routePoints,
        altRoutePoints,
      ];
}
