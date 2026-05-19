import 'package:json_annotation/json_annotation.dart';

part 'albergue_social_media_response.g.dart';

@JsonSerializable()
class AlbergueSocialMediaResponse {

  const AlbergueSocialMediaResponse({
    required this.id,
    required this.albergueId,
    this.facebookUrl,
    this.facebookId,
    this.instagramHandle,
    this.messenger,
  });

  factory AlbergueSocialMediaResponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueSocialMediaResponseFromJson(json);

  final int id;
  @JsonKey(name: 'albergue_id')
  final int albergueId;
  @JsonKey(name: 'facebook_url')
  final String? facebookUrl;
  @JsonKey(name: 'facebook_id')
  final String? facebookId;
  @JsonKey(name: 'instagram_handle')
  final String? instagramHandle;
  final String? messenger;

  Map<String, dynamic> toJson() => _$AlbergueSocialMediaResponseToJson(this);
}
