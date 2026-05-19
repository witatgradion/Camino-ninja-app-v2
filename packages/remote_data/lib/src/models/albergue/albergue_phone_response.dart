import 'package:json_annotation/json_annotation.dart';

part 'albergue_phone_response.g.dart';

@JsonSerializable()
class AlberguePhoneResponse {
  const AlberguePhoneResponse({
    required this.id,
    required this.albergueId,
    required this.phoneNumber,
    this.whatsapp = false,
    this.signal = false,
    this.private = false,
  });

  factory AlberguePhoneResponse.fromJson(Map<String, dynamic> json) =>
      _$AlberguePhoneResponseFromJson(json);

  final int id;
  @JsonKey(name: 'albergue_id')
  final int albergueId;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(defaultValue: false, toJson: _boolToInt)
  final bool whatsapp;
  @JsonKey(defaultValue: false, toJson: _boolToInt)
  final bool signal;
  @JsonKey(defaultValue: false, toJson: _boolToInt)
  final bool private;

  Map<String, dynamic> toJson() => _$AlberguePhoneResponseToJson(this);
}

int? _boolToInt(bool? value) => value == null ? null : (value ? 1 : 0);
