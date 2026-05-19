import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest extends Equatable {

  const LoginRequest({
    this.token,
    this.loginType,
    this.name,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  final String? token;

  @JsonKey(name: 'login_type')
  final String? loginType;

  final String? name;

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  List<Object?> get props => [token];
}
