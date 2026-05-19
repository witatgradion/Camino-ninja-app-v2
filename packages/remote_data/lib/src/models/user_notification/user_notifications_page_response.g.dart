// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_notifications_page_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserNotificationsPageResponse _$UserNotificationsPageResponseFromJson(
        Map<String, dynamic> json) =>
    UserNotificationsPageResponse(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) =>
              UserNotificationResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadCount: (json['unread_count'] as num).toInt(),
    );

Map<String, dynamic> _$UserNotificationsPageResponseToJson(
        UserNotificationsPageResponse instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
      'unread_count': instance.unreadCount,
    };
