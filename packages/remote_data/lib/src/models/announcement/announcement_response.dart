import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'announcement_response.g.dart';

@JsonSerializable()
class AnnouncementResponse extends Equatable {
  const AnnouncementResponse({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.content,
    this.deletedAt,
  });

  factory AnnouncementResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$AnnouncementResponseFromJson(json);

  final int id;
  final String title;
  final String? description;
  final Map<String, dynamic>? content;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;

  Map<String, dynamic> toJson() =>
      _$AnnouncementResponseToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
