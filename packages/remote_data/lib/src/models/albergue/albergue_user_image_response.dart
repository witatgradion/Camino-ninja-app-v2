import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/remote_data.dart';

part 'albergue_user_image_response.g.dart';

@JsonSerializable()
class AlbergueUserImageReponse {
  AlbergueUserImageReponse({
    required this.images,
    required this.albergueId,
    required this.status,
    required this.id,
  });

  factory AlbergueUserImageReponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueUserImageReponseFromJson(json);

  final List<UserImageResponse> images;
  @JsonKey(name: 'albergue')
  final int albergueId;
  final String status;
  final int id;

  Map<String, dynamic> toJson() => _$AlbergueUserImageReponseToJson(this);
}

@JsonSerializable()
class AlbergueUserImageListResponse {
  AlbergueUserImageListResponse({
    required this.data,
  });

  factory AlbergueUserImageListResponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueUserImageListResponseFromJson(json);
  final List<AlbergueUserImageReponse> data;

  Map<String, dynamic> toJson() => _$AlbergueUserImageListResponseToJson(this);
}

@JsonSerializable()
class UserImageResponse {
  UserImageResponse({
    required this.file,
    required this.id,
  });

  factory UserImageResponse.fromJson(Map<String, dynamic> json) =>
      _$UserImageResponseFromJson(json);

  @JsonKey(name: 'directus_files_id')
  final DirectusFileResponse file;
  final int id;

  Map<String, dynamic> toJson() => _$UserImageResponseToJson(this);

  Map<String, dynamic> toDatabaseMapping(int albergueId) => <String, dynamic>{
    'id': id,
    'albergue_id': albergueId,
    'file_name': file.filenameDisk,
    'title': file.title,
    'type': file.type,
    'width': file.width,
    'height': file.height,
  };
}
