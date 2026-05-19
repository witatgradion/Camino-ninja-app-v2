import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_token_request.g.dart';

@JsonSerializable()
class DeviceTokenRequest extends Equatable {
  const DeviceTokenRequest({
    required this.deviceId,
    required this.platform,
    required this.token,
  });

  factory DeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenRequestFromJson(json);

  @JsonKey(name: 'device_id')
  final String deviceId;

  final String platform;

  final String token;

  Map<String, dynamic> toJson() => _$DeviceTokenRequestToJson(this);

  @override
  List<Object?> get props => [deviceId, platform, token];
}
