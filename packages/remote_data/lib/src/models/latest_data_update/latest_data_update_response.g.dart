// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_data_update_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatestDataUpdateResponse _$LatestDataUpdateResponseFromJson(
        Map<String, dynamic> json) =>
    LatestDataUpdateResponse(
      albergues: LatestDataUpdateResponse._parseDateTimeNullable(
          json['albergues_updated_at'] as String?),
      albergueUserImages: LatestDataUpdateResponse._parseDateTimeNullable(
          json['albergue_user_images_updated_at'] as String?),
      cities: LatestDataUpdateResponse._parseDateTimeNullable(
          json['cities_updated_at'] as String?),
      routes: LatestDataUpdateResponse._parseDateTimeNullable(
          json['routes_updated_at'] as String?),
      routePoints: LatestDataUpdateResponse._parseDateTimeNullable(
          json['route_points_updated_at'] as String?),
      altRoutePoints: LatestDataUpdateResponse._parseDateTimeNullable(
          json['alt_route_points_updated_at'] as String?),
    );

Map<String, dynamic> _$LatestDataUpdateResponseToJson(
        LatestDataUpdateResponse instance) =>
    <String, dynamic>{
      'albergues_updated_at': instance.albergues?.toIso8601String(),
      'albergue_user_images_updated_at':
          instance.albergueUserImages?.toIso8601String(),
      'cities_updated_at': instance.cities?.toIso8601String(),
      'routes_updated_at': instance.routes?.toIso8601String(),
      'route_points_updated_at': instance.routePoints?.toIso8601String(),
      'alt_route_points_updated_at': instance.altRoutePoints?.toIso8601String(),
    };
