// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wifi_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WifiEntity _$WifiEntityFromJson(Map<String, dynamic> json) => WifiEntity(
      id: (json['id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$WifiEntityToJson(WifiEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albergue_id': instance.albergueId,
      'name': instance.name,
      'url': instance.url,
    };
