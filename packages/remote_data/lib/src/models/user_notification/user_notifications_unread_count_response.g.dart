// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_notifications_unread_count_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserNotificationsUnreadCountResponse
    _$UserNotificationsUnreadCountResponseFromJson(Map<String, dynamic> json) =>
        UserNotificationsUnreadCountResponse(
          unreadCount: (json['unread_count'] as num).toInt(),
        );

Map<String, dynamic> _$UserNotificationsUnreadCountResponseToJson(
        UserNotificationsUnreadCountResponse instance) =>
    <String, dynamic>{
      'unread_count': instance.unreadCount,
    };
