import 'package:json_annotation/json_annotation.dart';

part 'albergue_image_response.g.dart';

@JsonSerializable()
class AlbergueImageResponse {
  const AlbergueImageResponse({
    required this.id,
    required this.albergueId,
    required this.fileKey,
    this.width,
    this.height,
  });

  factory AlbergueImageResponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueImageResponseFromJson(json);

  final int id;
  @JsonKey(name: 'albergue_id')
  final int albergueId;
  @JsonKey(name: 'file_key')
  final String fileKey;
  final int? width;
  final int? height;

  Map<String, dynamic> toJson() => _$AlbergueImageResponseToJson(this);

  Map<String, dynamic> toDatabaseMapping() => <String, dynamic>{
        'id': id,
        'albergue_id': albergueId,
        'file_name': fileKey,
        'width': width,
        'height': height,
      };
}

@JsonSerializable()
class DirectusFileResponse {
  const DirectusFileResponse({
    required this.id,
    required this.filenameDisk,
    required this.type,
    required this.title,
    required this.width,
    required this.height,
  });

  factory DirectusFileResponse.fromJson(Map<String, dynamic> json) =>
      _$DirectusFileResponseFromJson(json);

  final String id;
  @JsonKey(name: 'filename_disk')
  final String filenameDisk;
  final String type;
  final String title;
  final int width;
  final int height;

  Map<String, dynamic> toJson() => _$DirectusFileResponseToJson(this);
}
