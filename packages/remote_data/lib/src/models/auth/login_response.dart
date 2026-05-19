import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/auth/user_response.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse extends Equatable {

  const LoginResponse({
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiresIn,
    this.refreshTokenExpiresIn,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  @JsonKey(name: 'access_token')
  final String? accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'access_token_expires_in')
  final int? accessTokenExpiresIn;
  @JsonKey(name: 'refresh_token_expires_in')
  final int? refreshTokenExpiresIn;
  @JsonKey(name: 'user')
  final UserResponse? user;

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        accessTokenExpiresIn,
        refreshTokenExpiresIn,
        user,
      ];
}
