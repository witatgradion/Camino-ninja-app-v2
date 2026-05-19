import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_notifications_unread_count_response.g.dart';

@JsonSerializable()
class UserNotificationsUnreadCountResponse extends Equatable {
  const UserNotificationsUnreadCountResponse({required this.unreadCount});

  factory UserNotificationsUnreadCountResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$UserNotificationsUnreadCountResponseFromJson(json);

  @JsonKey(name: 'unread_count')
  final int unreadCount;

  Map<String, dynamic> toJson() =>
      _$UserNotificationsUnreadCountResponseToJson(this);

  @override
  List<Object?> get props => [unreadCount];
}
