import 'package:analytics_services/src/analytics_event.dart';

/// Fired when the notification permission prompt is shown.
class NotificationPermissionPromptedEvent
    extends AnalyticsEvent {
  @override
  String get name => 'notification_permission_prompted';

  @override
  Map<String, dynamic> get properties => {};
}

/// Fired when notification permission is granted.
class NotificationPermissionGrantedEvent
    extends AnalyticsEvent {
  @override
  String get name => 'notification_permission_granted';

  @override
  Map<String, dynamic> get properties => {};
}

/// Fired when notification permission is denied.
class NotificationPermissionDeniedEvent
    extends AnalyticsEvent {
  @override
  String get name => 'notification_permission_denied';

  @override
  Map<String, dynamic> get properties => {};
}

/// Fired when a push notification is received.
class PushNotificationReceivedEvent extends AnalyticsEvent {
  /// Creates a [PushNotificationReceivedEvent].
  PushNotificationReceivedEvent({
    this.type,
    this.announcementId,
  });

  /// Notification type.
  final String? type;

  /// Announcement ID, if applicable.
  final String? announcementId;

  @override
  String get name => 'push_notification_received';

  @override
  Map<String, dynamic> get properties => {
        'type': type,
        'announcement_id': announcementId,
      };
}

/// Fired when a push notification is tapped.
class PushNotificationTappedEvent extends AnalyticsEvent {
  /// Creates a [PushNotificationTappedEvent].
  PushNotificationTappedEvent({
    this.type,
    this.announcementId,
    required this.appState,
  });

  /// Notification type.
  final String? type;

  /// Announcement ID, if applicable.
  final String? announcementId;

  /// App state when tapped: `background` or `terminated`.
  final String appState;

  @override
  String get name => 'push_notification_tapped';

  @override
  Map<String, dynamic> get properties => {
        'type': type,
        'announcement_id': announcementId,
        'app_state': appState,
      };
}

/// Fired when the user subscribes to a topic.
class NotificationTopicSubscribedEvent
    extends AnalyticsEvent {
  /// Creates a [NotificationTopicSubscribedEvent].
  NotificationTopicSubscribedEvent({required this.topic});

  /// The topic name.
  final String topic;

  @override
  String get name => 'notification_topic_subscribed';

  @override
  Map<String, dynamic> get properties => {
        'topic': topic,
      };
}

/// Fired when the user unsubscribes from a topic.
class NotificationTopicUnsubscribedEvent
    extends AnalyticsEvent {
  /// Creates a [NotificationTopicUnsubscribedEvent].
  NotificationTopicUnsubscribedEvent({required this.topic});

  /// The topic name.
  final String topic;

  @override
  String get name => 'notification_topic_unsubscribed';

  @override
  Map<String, dynamic> get properties => {
        'topic': topic,
      };
}

/// Fired when the albergue review reminder setting is toggled.
class ReviewReminderSettingChangedEvent
    extends AnalyticsEvent {
  /// Creates a [ReviewReminderSettingChangedEvent].
  ReviewReminderSettingChangedEvent({required this.enabled});

  /// Whether the review reminder setting is enabled.
  final bool enabled;

  @override
  String get name => 'review_reminder_setting_changed';

  @override
  Map<String, dynamic> get properties => {
        'enabled': enabled,
      };
}

/// Fired when an inbox notification is tapped.
class InboxNotificationTappedEvent extends AnalyticsEvent {
  /// Creates an [InboxNotificationTappedEvent].
  InboxNotificationTappedEvent({
    required this.notificationId,
    this.type,
  });

  /// Inbox notification id.
  final String notificationId;

  /// Notification type wire value.
  final String? type;

  @override
  String get name => 'inbox_notification_tapped';

  @override
  Map<String, dynamic> get properties => {
        'type': type,
        'notification_id': notificationId,
      };
}
