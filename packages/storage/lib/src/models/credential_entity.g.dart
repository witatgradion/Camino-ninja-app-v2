// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialEntity _$CredentialEntityFromJson(Map<String, dynamic> json) =>
    CredentialEntity(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      accessTokenExpiry: json['accessTokenExpiry'] == null
          ? null
          : DateTime.parse(json['accessTokenExpiry'] as String),
      refreshTokenExpiry: json['refreshTokenExpiry'] == null
          ? null
          : DateTime.parse(json['refreshTokenExpiry'] as String),
      user: json['user'] == null
          ? null
          : UserEntity.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CredentialEntityToJson(CredentialEntity instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'accessTokenExpiry': instance.accessTokenExpiry?.toIso8601String(),
      'refreshTokenExpiry': instance.refreshTokenExpiry?.toIso8601String(),
      'user': instance.user,
    };
