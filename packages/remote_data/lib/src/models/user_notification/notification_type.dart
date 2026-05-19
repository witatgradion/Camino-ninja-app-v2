import 'package:json_annotation/json_annotation.dart';

part 'notification_type.g.dart';

@JsonEnum(alwaysCreate: true)
enum NotificationType {
  @JsonValue('albergue_review_request')
  albergueReviewRequest,
  @JsonValue('announcements')
  announcements,
  @JsonValue('approved_review')
  approvedReview,
  unknown;

  static NotificationType fromString(String? value) {
    if (value == null) return NotificationType.unknown;
    switch (value) {
      case 'albergue_review_request':
        return NotificationType.albergueReviewRequest;
      case 'announcements':
        return NotificationType.announcements;
      case 'approved_review':
        return NotificationType.approvedReview;
      default:
        return NotificationType.unknown;
    }
  }
}

extension NotificationTypeWireValue on NotificationType {
  String get wireValue {
    switch (this) {
      case NotificationType.albergueReviewRequest:
        return 'albergue_review_request';
      case NotificationType.announcements:
        return 'announcements';
      case NotificationType.approvedReview:
        return 'approved_review';
      case NotificationType.unknown:
        return '';
    }
  }
}
