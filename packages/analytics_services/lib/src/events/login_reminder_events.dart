import 'package:analytics_services/src/analytics_event.dart';

/// Fired when the login reminder banner first becomes visible on a screen.
class LoginReminderShownEvent extends AnalyticsEvent {
  /// Creates a [LoginReminderShownEvent].
  LoginReminderShownEvent({
    required this.stageCount,
    required this.source,
  });

  /// Stage count that triggered the reminder (max across plans on list,
  /// current plan's stage count on detail).
  final int stageCount;

  /// Screen source: `plan_list` or `plan_detail`.
  final String source;

  @override
  String get name => 'login_reminder_shown';

  @override
  Map<String, dynamic> get properties => {
        'stage_count': stageCount,
        'source': source,
      };
}

/// Fired when the login reminder banner is tapped (navigates to login).
class LoginReminderTappedEvent extends AnalyticsEvent {
  /// Creates a [LoginReminderTappedEvent].
  LoginReminderTappedEvent({
    required this.stageCount,
    required this.source,
  });

  /// Stage count that triggered the reminder.
  final int stageCount;

  /// Screen source: `plan_list` or `plan_detail`.
  final String source;

  @override
  String get name => 'login_reminder_tapped';

  @override
  Map<String, dynamic> get properties => {
        'stage_count': stageCount,
        'source': source,
      };
}

/// Fired when the login reminder banner is dismissed for the session.
class LoginReminderDismissedEvent extends AnalyticsEvent {
  /// Creates a [LoginReminderDismissedEvent].
  LoginReminderDismissedEvent({
    required this.stageCount,
    required this.source,
  });

  /// Stage count that triggered the reminder.
  final int stageCount;

  /// Screen source: `plan_list` or `plan_detail`.
  final String source;

  @override
  String get name => 'login_reminder_dismissed';

  @override
  Map<String, dynamic> get properties => {
        'stage_count': stageCount,
        'source': source,
      };
}
