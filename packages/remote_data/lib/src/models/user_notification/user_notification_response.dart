import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/user_notification/notification_type.dart';

part 'user_notification_response.g.dart';

@JsonSerializable()
class UserNotificationResponse extends Equatable {
  const UserNotificationResponse({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory UserNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$UserNotificationResponseFromJson(json);

  final int id;
  @JsonKey(unknownEnumValue: NotificationType.unknown)
  final NotificationType type;
  final String title;
  final String body;
  final String? data;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;

  Map<String, dynamic> toJson() => _$UserNotificationResponseToJson(this);

  UserNotificationResponse copyWith({
    int? id,
    NotificationType? type,
    String? title,
    String? body,
    String? data,
    bool? isRead,
    String? createdAt,
  }) {
    return UserNotificationResponse(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, type, title, body, data, isRead, createdAt];
}

extension UserNotificationResponseX on UserNotificationResponse {
  String? get route {
    if (data == null || data!.isEmpty) return null;
    try {
      final decoded = jsonDecode(data!);
      if (decoded is Map<String, dynamic>) return decoded['route'] as String?;
      return null;
    } catch (_) {
      return null;
    }
  }
}
