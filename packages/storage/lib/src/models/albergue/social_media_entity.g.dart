// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_media_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialMediaEntity _$SocialMediaEntityFromJson(Map<String, dynamic> json) =>
    SocialMediaEntity(
      id: (json['social_media_id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      facebookUrl: json['facebook_url'] as String?,
      facebookId: json['facebook_id'] as String?,
      instagramHandle: json['instagram_handle'] as String?,
      messenger: json['messenger'] as String?,
    );

Map<String, dynamic> _$SocialMediaEntityToJson(SocialMediaEntity instance) =>
    <String, dynamic>{
      'social_media_id': instance.id,
      'albergue_id': instance.albergueId,
      'facebook_url': instance.facebookUrl,
      'facebook_id': instance.facebookId,
      'instagram_handle': instance.instagramHandle,
      'messenger': instance.messenger,
    };
