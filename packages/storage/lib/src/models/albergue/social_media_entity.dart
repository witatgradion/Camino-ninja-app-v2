import 'package:json_annotation/json_annotation.dart';

part 'social_media_entity.g.dart';

@JsonSerializable()
class SocialMediaEntity {
  const SocialMediaEntity({
    required this.id,
    required this.albergueId,
    this.facebookUrl,
    this.facebookId,
    this.instagramHandle,
    this.messenger,
  });

  @JsonKey(name: 'social_media_id')
  final int id;
  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  @JsonKey(name: 'facebook_url')
  final String? facebookUrl;
  @JsonKey(name: 'facebook_id')
  final String? facebookId;
  @JsonKey(name: 'instagram_handle')
  final String? instagramHandle;
  final String? messenger;

  factory SocialMediaEntity.fromJson(Map<String, dynamic> json) =>
      _$SocialMediaEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SocialMediaEntityToJson(this);
}