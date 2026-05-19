import 'package:json_annotation/json_annotation.dart';

part 'email_entity.g.dart';

@JsonSerializable()
class EmailEntity {

  const EmailEntity({
    required this.id,
    required this.albergueId,
    required this.emailAddress,
  });

  @JsonKey(name: 'email_id')
  final int id;
  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  @JsonKey(name: 'email_address')
  final String emailAddress;

  factory EmailEntity.fromJson(Map<String, dynamic> json) =>
      _$EmailEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EmailEntityToJson(this);
}