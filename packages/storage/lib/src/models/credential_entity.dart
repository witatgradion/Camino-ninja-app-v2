import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage/storage.dart';

part 'credential_entity.g.dart';

@JsonSerializable()
class CredentialEntity extends Equatable {
  const CredentialEntity({
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiry,
    this.refreshTokenExpiry,
    this.user,
  });

  final String? accessToken;
  final String? refreshToken;
  final DateTime? accessTokenExpiry;
  final DateTime? refreshTokenExpiry;
  final UserEntity? user;

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        accessTokenExpiry,
        refreshTokenExpiry,
        user,
      ];

  factory CredentialEntity.fromJson(Map<String, dynamic> json) =>
      _$CredentialEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialEntityToJson(this);
}

extension CredentialEntityX on CredentialEntity? {
  bool get isAccessTokenValid {
    if (this?.accessToken == null || this?.accessTokenExpiry == null)
      return false;
    return DateTime.now().isBefore(this!.accessTokenExpiry!);
  }

  bool get isRefreshTokenValid {
    if (this?.refreshToken == null || this?.refreshTokenExpiry == null)
      return false;
    return DateTime.now().isBefore(this!.refreshTokenExpiry!);
  }

  bool get isLoggedIn {
    return isAccessTokenValid || isRefreshTokenValid;
  }
}
