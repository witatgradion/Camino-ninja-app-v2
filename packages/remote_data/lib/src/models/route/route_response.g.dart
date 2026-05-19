// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteResponse _$RouteResponseFromJson(Map<String, dynamic> json) =>
    RouteResponse(
      id: (json['id'] as num).toInt(),
      orderKey: (json['order_key'] as num).toInt(),
      routeName: json['route_name'] as String,
      routeSubName: json['route_sub_name'] as String?,
      legendColor: json['legend_color'] as String?,
      lightLegendColor: json['light_legend_color'] as String?,
      darkLegendColor: json['dark_legend_color'] as String?,
      shortName: json['short_name'] as String?,
      cities: (json['cities'] as List<dynamic>?)
          ?.map((e) => CityResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteResponseToJson(RouteResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_key': instance.orderKey,
      'route_name': instance.routeName,
      'route_sub_name': instance.routeSubName,
      'legend_color': instance.legendColor,
      'light_legend_color': instance.lightLegendColor,
      'dark_legend_color': instance.darkLegendColor,
      'short_name': instance.shortName,
    };
