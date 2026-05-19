import 'package:json_annotation/json_annotation.dart';
import 'package:storage/src/models/bool_mapper.dart';

part 'phone_entity.g.dart';

@JsonSerializable()
class PhoneEntity {
  const PhoneEntity({
    required this.id,
    required this.albergueId,
    required this.phoneNumber,
    required this.whatsapp,
    required this.private,
    required this.signal,
  });

  @JsonKey(name: 'phone_id')
  final int id;
  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(fromJson: intToBool)
  final bool whatsapp;
  @JsonKey(fromJson: intToBool)
  final bool private;
  @JsonKey(fromJson: intToBool)
  final bool signal;

  factory PhoneEntity.fromJson(Map<String, dynamic> json) =>
      _$PhoneEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneEntityToJson(this);
}
