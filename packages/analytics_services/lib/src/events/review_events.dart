import 'package:analytics_services/src/analytics_event.dart';

/// Fired when the review bottom sheet is opened.
class OpenReviewEvent extends AnalyticsEvent {
  /// Creates an [OpenReviewEvent].
  OpenReviewEvent({
    required this.albergueId,
    this.albergueName,
    required this.source,
  });

  /// The albergue ID.
  final int albergueId;

  /// The albergue name.
  final String? albergueName;

  /// Where the review was opened from.
  final String source;

  @override
  String get name => 'open_review';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'albergue_name': albergueName,
        'source': source,
      };
}

/// Fired when a review is successfully submitted.
class ReviewSubmittedEvent extends AnalyticsEvent {
  /// Creates a [ReviewSubmittedEvent].
  ReviewSubmittedEvent({
    required this.albergueId,
    this.rating,
    this.comment,
    this.submitterName,
    this.email,
    this.attachments,
  });

  /// The albergue ID.
  final int albergueId;

  /// The rating value.
  final int? rating;

  /// The review comment.
  final String? comment;

  /// Reviewer name.
  final String? submitterName;

  /// Reviewer email.
  final String? email;

  /// Number of attachments.
  final int? attachments;

  @override
  String get name => 'review_submitted';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'rating': rating,
        'comment': comment,
        'name': submitterName,
        'email': email,
        'attachments': attachments,
      };
}

/// Fired when review submission fails.
class ReviewSubmitErrorEvent extends AnalyticsEvent {
  /// Creates a [ReviewSubmitErrorEvent].
  ReviewSubmitErrorEvent({
    required this.albergueId,
    this.rating,
    this.comment,
    this.submitterName,
    this.email,
    this.attachments,
    required this.error,
  });

  /// The albergue ID.
  final int albergueId;

  /// The rating value.
  final int? rating;

  /// The review comment.
  final String? comment;

  /// Reviewer name.
  final String? submitterName;

  /// Reviewer email.
  final String? email;

  /// Number of attachments.
  final int? attachments;

  /// The error description.
  final String error;

  @override
  String get name => 'review_submit_error';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'rating': rating,
        'comment': comment,
        'name': submitterName,
        'email': email,
        'attachments': attachments,
        'error': error,
      };
}

/// Fired when feedback is successfully submitted.
class FeedbackSubmittedEvent extends AnalyticsEvent {
  /// Creates a [FeedbackSubmittedEvent].
  FeedbackSubmittedEvent({
    required this.albergueId,
    this.comment,
    this.submitterName,
    this.email,
    this.attachments,
  });

  /// The albergue ID.
  final int albergueId;

  /// The feedback comment.
  final String? comment;

  /// Submitter name.
  final String? submitterName;

  /// Submitter email.
  final String? email;

  /// Number of attachments.
  final int? attachments;

  @override
  String get name => 'feedback_submitted';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'comment': comment,
        'name': submitterName,
        'email': email,
        'attachments': attachments,
      };
}

/// Fired when feedback submission fails.
class FeedbackSubmitErrorEvent extends AnalyticsEvent {
  /// Creates a [FeedbackSubmitErrorEvent].
  FeedbackSubmitErrorEvent({
    required this.albergueId,
    this.comment,
    this.submitterName,
    this.email,
    this.attachments,
    required this.error,
  });

  /// The albergue ID.
  final int albergueId;

  /// The feedback comment.
  final String? comment;

  /// Submitter name.
  final String? submitterName;

  /// Submitter email.
  final String? email;

  /// Number of attachments.
  final int? attachments;

  /// The error description.
  final String error;

  @override
  String get name => 'feedback_submit_error';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'comment': comment,
        'name': submitterName,
        'email': email,
        'attachments': attachments,
        'error': error,
      };
}

/// Fired when a missing albergue is reported.
class MissingAlbergueReportedEvent extends AnalyticsEvent {
  /// Creates a [MissingAlbergueReportedEvent].
  MissingAlbergueReportedEvent({
    this.cityId,
    this.reportDetails,
    this.submitterName,
    this.email,
    this.attachments,
  });

  /// The city ID.
  final int? cityId;

  /// The report details.
  final String? reportDetails;

  /// Reporter name.
  final String? submitterName;

  /// Reporter email.
  final String? email;

  /// Number of attachments.
  final int? attachments;

  @override
  String get name => 'missing_albergue_reported';

  @override
  Map<String, dynamic> get properties => {
        'city_id': cityId,
        'report_details': reportDetails,
        'name': submitterName,
        'email': email,
        'attachments': attachments,
      };
}

/// Fired when missing albergue report fails.
class MissingAlbergueReportErrorEvent extends AnalyticsEvent {
  /// Creates a [MissingAlbergueReportErrorEvent].
  MissingAlbergueReportErrorEvent({
    this.cityId,
    this.reportDetails,
    this.submitterName,
    this.email,
    this.attachments,
    required this.error,
  });

  /// The city ID.
  final int? cityId;

  /// The report details.
  final String? reportDetails;

  /// Reporter name.
  final String? submitterName;

  /// Reporter email.
  final String? email;

  /// Number of attachments.
  final int? attachments;

  /// The error description.
  final String error;

  @override
  String get name => 'missing_albergue_report_error';

  @override
  Map<String, dynamic> get properties => {
        'city_id': cityId,
        'report_details': reportDetails,
        'name': submitterName,
        'email': email,
        'attachments': attachments,
        'error': error,
      };
}

/// Fired when a bug report is successfully submitted.
class BugReportSubmittedEvent extends AnalyticsEvent {
  /// Creates a [BugReportSubmittedEvent].
  BugReportSubmittedEvent({
    this.comment,
    this.submitterName,
    this.email,
    this.attachments,
    this.includesDbDump = false,
  });

  /// The bug report comment.
  final String? comment;

  /// Reporter name.
  final String? submitterName;

  /// Reporter email.
  final String? email;

  /// Number of attachments.
  final int? attachments;

  /// Whether the anonymized DB export was attached to the report.
  /// Reflects what was *actually* sent: if the user opted in but
  /// the export failed, this is `false`.
  final bool includesDbDump;

  @override
  String get name => 'bug_report_submitted';

  @override
  Map<String, dynamic> get properties => {
        'comment': comment,
        'name': submitterName,
        'email': email,
        'attachments': attachments,
        'includes_db_dump': includesDbDump,
      };
}

/// Fired when bug report submission fails.
class BugReportSubmitErrorEvent extends AnalyticsEvent {
  /// Creates a [BugReportSubmitErrorEvent].
  BugReportSubmitErrorEvent({
    this.comment,
    this.submitterName,
    this.email,
    this.attachments,
    this.includesDbDump = false,
    required this.error,
  });

  /// The bug report comment.
  final String? comment;

  /// Reporter name.
  final String? submitterName;

  /// Reporter email.
  final String? email;

  /// Number of attachments.
  final int? attachments;

  /// Whether the anonymized DB export was attached to the (failed)
  /// upload. Same semantics as [BugReportSubmittedEvent.includesDbDump].
  final bool includesDbDump;

  /// The error description.
  final String error;

  @override
  String get name => 'bug_report_submit_error';

  @override
  Map<String, dynamic> get properties => {
        'comment': comment,
        'name': submitterName,
        'email': email,
        'attachments': attachments,
        'includes_db_dump': includesDbDump,
        'error': error,
      };
}
