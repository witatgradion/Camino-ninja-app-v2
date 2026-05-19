import 'package:json_annotation/json_annotation.dart';

part 'image_entity.g.dart';

@JsonSerializable()
class ImageEntity {
  const ImageEntity({
    required this.id,
    required this.albergueId,
    required this.fileName,
    this.title,
    this.type,
    this.width,
    this.height,
  });

  final int id;
  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  @JsonKey(name: 'file_name')
  final String fileName;
  final String? title;
  final String? type;
  final int? width;
  final int? height;

  factory ImageEntity.fromJson(Map<String, dynamic> json) =>
      _$ImageEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ImageEntityToJson(this);
}
