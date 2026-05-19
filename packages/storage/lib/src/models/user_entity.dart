import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';

@JsonSerializable()
class UserEntity extends Equatable {
  const UserEntity({
    this.id,
    this.username,
    this.fullName,
    this.email,
    this.role,
  });

  final int? id;
  final String? username;
  final String? fullName;
  final String? email;
  final String? role;

  @override
  List<Object?> get props => [
        id,
        username,
        fullName,
        email,
        role,
        role,
      ];

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);
}

extension UserEntityX on UserEntity? {
  String get displayName {
    if (this?.fullName != null && this!.fullName!.isNotEmpty) {
      return this!.fullName!;
    }
    if (this?.username != null && this!.username!.isNotEmpty) {
      return this!.username!;
    }
    return this?.email ?? '';
  }
}
