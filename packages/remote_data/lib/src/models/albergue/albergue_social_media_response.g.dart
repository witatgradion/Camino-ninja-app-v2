// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albergue_social_media_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbergueSocialMediaResponse _$AlbergueSocialMediaResponseFromJson(
        Map<String, dynamic> json) =>
    AlbergueSocialMediaResponse(
      id: (json['id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num).toInt(),
      facebookUrl: json['facebook_url'] as String?,
      facebookId: json['facebook_id'] as String?,
      instagramHandle: json['instagram_handle'] as String?,
      messenger: json['messenger'] as String?,
    );

Map<String, dynamic> _$AlbergueSocialMediaResponseToJson(
        AlbergueSocialMediaResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albergue_id': instance.albergueId,
      'facebook_url': instance.facebookUrl,
      'facebook_id': instance.facebookId,
      'instagram_handle': instance.instagramHandle,
      'messenger': instance.messenger,
    };
