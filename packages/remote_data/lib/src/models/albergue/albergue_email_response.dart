import 'package:json_annotation/json_annotation.dart';

part 'albergue_email_response.g.dart';

@JsonSerializable()
class AlbergueEmailResponse {
  const AlbergueEmailResponse({
    required this.id,
    required this.albergueId,
    required this.emailAddress,
  });

  factory AlbergueEmailResponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueEmailResponseFromJson(json);

  final int id;
  @JsonKey(name: 'albergue_id')
  final int albergueId;
  @JsonKey(name: 'email_address')
  final String emailAddress;

  Map<String, dynamic> toJson() => _$AlbergueEmailResponseToJson(this);
}
