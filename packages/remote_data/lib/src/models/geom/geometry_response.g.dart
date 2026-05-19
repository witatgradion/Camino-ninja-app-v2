// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geometry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeometryResponse _$GeometryResponseFromJson(Map<String, dynamic> json) =>
    GeometryResponse(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );

Map<String, dynamic> _$GeometryResponseToJson(GeometryResponse instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
    };
