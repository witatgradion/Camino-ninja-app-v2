// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      accessTokenExpiresIn: (json['access_token_expires_in'] as num?)?.toInt(),
      refreshTokenExpiresIn:
          (json['refresh_token_expires_in'] as num?)?.toInt(),
      user: json['user'] == null
          ? null
          : UserResponse.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'access_token_expires_in': instance.accessTokenExpiresIn,
      'refresh_token_expires_in': instance.refreshTokenExpiresIn,
      'user': instance.user,
    };
