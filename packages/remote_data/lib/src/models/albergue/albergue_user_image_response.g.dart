// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albergue_user_image_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbergueUserImageReponse _$AlbergueUserImageReponseFromJson(
        Map<String, dynamic> json) =>
    AlbergueUserImageReponse(
      images: (json['images'] as List<dynamic>)
          .map((e) => UserImageResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      albergueId: (json['albergue'] as num).toInt(),
      status: json['status'] as String,
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$AlbergueUserImageReponseToJson(
        AlbergueUserImageReponse instance) =>
    <String, dynamic>{
      'images': instance.images,
      'albergue': instance.albergueId,
      'status': instance.status,
      'id': instance.id,
    };

AlbergueUserImageListResponse _$AlbergueUserImageListResponseFromJson(
        Map<String, dynamic> json) =>
    AlbergueUserImageListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              AlbergueUserImageReponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AlbergueUserImageListResponseToJson(
        AlbergueUserImageListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

UserImageResponse _$UserImageResponseFromJson(Map<String, dynamic> json) =>
    UserImageResponse(
      file: DirectusFileResponse.fromJson(
          json['directus_files_id'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$UserImageResponseToJson(UserImageResponse instance) =>
    <String, dynamic>{
      'directus_files_id': instance.file,
      'id': instance.id,
    };
