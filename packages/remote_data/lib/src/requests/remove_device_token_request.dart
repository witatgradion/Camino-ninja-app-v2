import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'remove_device_token_request.g.dart';

@JsonSerializable()
class RemoveDeviceTokenRequest extends Equatable {
  const RemoveDeviceTokenRequest({required this.token});

  factory RemoveDeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RemoveDeviceTokenRequestFromJson(json);

  final String token;

  Map<String, dynamic> toJson() => _$RemoveDeviceTokenRequestToJson(this);

  @override
  List<Object?> get props => [token];
}
