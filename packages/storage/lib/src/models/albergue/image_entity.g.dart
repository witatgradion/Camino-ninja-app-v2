// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageEntity _$ImageEntityFromJson(Map<String, dynamic> json) => ImageEntity(
      id: (json['id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      fileName: json['file_name'] as String,
      title: json['title'] as String?,
      type: json['type'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ImageEntityToJson(ImageEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albergue_id': instance.albergueId,
      'file_name': instance.fileName,
      'title': instance.title,
      'type': instance.type,
      'width': instance.width,
      'height': instance.height,
    };
