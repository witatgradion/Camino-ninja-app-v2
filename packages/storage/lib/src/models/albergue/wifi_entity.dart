import 'package:json_annotation/json_annotation.dart';

part 'wifi_entity.g.dart';

@JsonSerializable()
class WifiEntity {
  const WifiEntity({
    required this.id,
    required this.albergueId,
    this.name,
    this.url,
  });

  final int id;
  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  final String? name;
  final String? url;

  factory WifiEntity.fromJson(Map<String, dynamic> json) =>
      _$WifiEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WifiEntityToJson(this);
}
