// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albergue_image_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbergueImageResponse _$AlbergueImageResponseFromJson(
        Map<String, dynamic> json) =>
    AlbergueImageResponse(
      id: (json['id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num).toInt(),
      fileKey: json['file_key'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AlbergueImageResponseToJson(
        AlbergueImageResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albergue_id': instance.albergueId,
      'file_key': instance.fileKey,
      'width': instance.width,
      'height': instance.height,
    };

DirectusFileResponse _$DirectusFileResponseFromJson(
        Map<String, dynamic> json) =>
    DirectusFileResponse(
      id: json['id'] as String,
      filenameDisk: json['filename_disk'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
    );

Map<String, dynamic> _$DirectusFileResponseToJson(
        DirectusFileResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename_disk': instance.filenameDisk,
      'type': instance.type,
      'title': instance.title,
      'width': instance.width,
      'height': instance.height,
    };
