// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserNotificationResponse _$UserNotificationResponseFromJson(
        Map<String, dynamic> json) =>
    UserNotificationResponse(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type'],
          unknownValue: NotificationType.unknown),
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool,
      createdAt: json['created_at'] as String,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$UserNotificationResponseToJson(
        UserNotificationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'data': instance.data,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.albergueReviewRequest: 'albergue_review_request',
  NotificationType.announcements: 'announcements',
  NotificationType.approvedReview: 'approved_review',
  NotificationType.unknown: 'unknown',
};
