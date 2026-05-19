import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user_notification_response.dart';

part 'user_notifications_page_response.g.dart';

@JsonSerializable()
class UserNotificationsPageResponse extends Equatable {
  const UserNotificationsPageResponse({
    required this.notifications,
    required this.unreadCount,
  });

  factory UserNotificationsPageResponse.fromJson(Map<String, dynamic> json) =>
      _$UserNotificationsPageResponseFromJson(json);

  final List<UserNotificationResponse> notifications;
  @JsonKey(name: 'unread_count')
  final int unreadCount;

  Map<String, dynamic> toJson() => _$UserNotificationsPageResponseToJson(this);

  @override
  List<Object?> get props => [notifications, unreadCount];
}
