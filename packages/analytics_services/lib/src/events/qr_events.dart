import 'package:analytics_services/src/analytics_event.dart';

/// Fired when a QR code is generated for sharing plans.
class QrGeneratedEvent extends AnalyticsEvent {
  /// Creates a [QrGeneratedEvent].
  QrGeneratedEvent({
    required this.planCount,
    required this.totalStages,
    required this.routeIds,
    required this.routeNames,
    required this.planNames,
  });

  /// Number of plans encoded.
  final int planCount;

  /// Total number of stages across all plans.
  final int totalStages;

  /// List of route IDs.
  final List<int> routeIds;

  /// List of route names.
  final List<String> routeNames;

  /// List of plan names.
  final List<String> planNames;

  @override
  String get name => 'plan_share_qr_generated';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
        'total_stages': totalStages,
        'route_ids': routeIds,
        'route_names': routeNames,
        'plan_names': planNames,
      };
}

/// Fired when a deep-link QR code is generated for sharing.
class QrDeepLinkGeneratedEvent extends AnalyticsEvent {
  /// Creates a [QrDeepLinkGeneratedEvent].
  QrDeepLinkGeneratedEvent({
    required this.planCount,
    required this.totalStages,
    required this.routeIds,
    required this.routeNames,
    required this.planNames,
  });

  /// Number of plans encoded.
  final int planCount;

  /// Total number of stages across all plans.
  final int totalStages;

  /// List of route IDs.
  final List<int> routeIds;

  /// List of route names.
  final List<String> routeNames;

  /// List of plan names.
  final List<String> planNames;

  @override
  String get name => 'plan_share_deeplink_qr_generated';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
        'total_stages': totalStages,
        'route_ids': routeIds,
        'route_names': routeNames,
        'plan_names': planNames,
      };
}

/// Fired when QR generation fails.
class QrGenerateFailedEvent extends AnalyticsEvent {
  /// Creates a [QrGenerateFailedEvent].
  QrGenerateFailedEvent({
    required this.planCount,
    required this.totalStages,
    required this.routeIds,
    required this.routeNames,
    required this.planNames,
    required this.errorMessage,
  });

  /// Number of plans attempted.
  final int planCount;

  /// Total stages attempted.
  final int totalStages;

  /// List of route IDs.
  final List<int> routeIds;

  /// List of route names.
  final List<String> routeNames;

  /// List of plan names.
  final List<String> planNames;

  /// The error message.
  final String errorMessage;

  @override
  String get name => 'plan_share_qr_generate_failed';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
        'total_stages': totalStages,
        'route_ids': routeIds,
        'route_names': routeNames,
        'plan_names': planNames,
        'error_message': errorMessage,
      };
}

/// Fired when a QR image is saved to gallery.
class QrSaveToGalleryEvent extends AnalyticsEvent {
  /// Creates a [QrSaveToGalleryEvent].
  QrSaveToGalleryEvent({
    required this.planCount,
    required this.totalStages,
    required this.routeIds,
    required this.routeNames,
    required this.planNames,
  });

  /// Number of plans in the QR.
  final int planCount;

  /// Total stages in the QR.
  final int totalStages;

  /// List of route IDs.
  final List<int> routeIds;

  /// List of route names.
  final List<String> routeNames;

  /// List of plan names.
  final List<String> planNames;

  @override
  String get name => 'plan_share_save_to_gallery';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
        'total_stages': totalStages,
        'route_ids': routeIds,
        'route_names': routeNames,
        'plan_names': planNames,
      };
}

/// Fired when a QR image is shared via share sheet.
class QrShareViaSheetEvent extends AnalyticsEvent {
  /// Creates a [QrShareViaSheetEvent].
  QrShareViaSheetEvent({
    required this.planCount,
    required this.totalStages,
    required this.routeIds,
    required this.routeNames,
    required this.planNames,
  });

  /// Number of plans in the QR.
  final int planCount;

  /// Total stages in the QR.
  final int totalStages;

  /// List of route IDs.
  final List<int> routeIds;

  /// List of route names.
  final List<String> routeNames;

  /// List of plan names.
  final List<String> planNames;

  @override
  String get name => 'plan_share_via_share_sheet';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
        'total_stages': totalStages,
        'route_ids': routeIds,
        'route_names': routeNames,
        'plan_names': planNames,
      };
}

/// Fired when a QR code is successfully decoded.
class QrDecodedEvent extends AnalyticsEvent {
  /// Creates a [QrDecodedEvent].
  QrDecodedEvent({
    required this.planCount,
    required this.totalStages,
    required this.routeIds,
    required this.routeNames,
    required this.planNames,
    required this.source,
    required this.qrVersion,
    required this.qrGeneratedOs,
    required this.currentAppVersion,
    this.isDeepLink,
  });

  /// Number of plans decoded.
  final int planCount;

  /// Total stages decoded.
  final int totalStages;

  /// List of route IDs.
  final List<int> routeIds;

  /// List of route names.
  final List<String> routeNames;

  /// List of plan names.
  final List<String> planNames;

  /// QR scan source (`scan` or `gallery`).
  final String source;

  /// Build number from the QR code.
  final String qrVersion;

  /// OS that generated the QR code.
  final String qrGeneratedOs;

  /// Current app version.
  final String currentAppVersion;

  /// Whether the QR was a deep link.
  final bool? isDeepLink;

  @override
  String get name => 'plan_import_qr_decoded';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
        'total_stages': totalStages,
        'route_ids': routeIds,
        'route_names': routeNames,
        'plan_names': planNames,
        'source': source,
        'qr_version': qrVersion,
        'qr_generated_os': qrGeneratedOs,
        'current_app_version': currentAppVersion,
        if (isDeepLink != null) 'is_deep_link': isDeepLink,
      };
}

/// Fired when QR decoding fails.
class QrDecodeFailedEvent extends AnalyticsEvent {
  /// Creates a [QrDecodeFailedEvent].
  QrDecodeFailedEvent({
    required this.planCount,
    required this.totalStages,
    required this.routeIds,
    required this.routeNames,
    required this.planNames,
    required this.source,
    required this.qrVersion,
    required this.qrGeneratedOs,
    required this.currentAppVersion,
    this.isDeepLink,
    this.errorMessage,
  });

  /// Number of plans attempted.
  final int planCount;

  /// Total stages attempted.
  final int totalStages;

  /// List of route IDs.
  final List<int> routeIds;

  /// List of route names.
  final List<String> routeNames;

  /// List of plan names.
  final List<String> planNames;

  /// QR scan source.
  final String source;

  /// Build number from the QR code.
  final String qrVersion;

  /// OS that generated the QR code.
  final String qrGeneratedOs;

  /// Current app version.
  final String currentAppVersion;

  /// Whether the QR was a deep link.
  final bool? isDeepLink;

  /// The error message, if any.
  final String? errorMessage;

  @override
  String get name => 'plan_import_qr_decode_failed';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
        'total_stages': totalStages,
        'route_ids': routeIds,
        'route_names': routeNames,
        'plan_names': planNames,
        'source': source,
        'qr_version': qrVersion,
        'qr_generated_os': qrGeneratedOs,
        'current_app_version': currentAppVersion,
        if (isDeepLink != null) 'is_deep_link': isDeepLink,
        'error_message': errorMessage,
      };
}

/// Fired when plans are successfully imported from QR.
class PlanImportSuccessEvent extends AnalyticsEvent {
  /// Creates a [PlanImportSuccessEvent].
  PlanImportSuccessEvent({
    required this.planCount,
    required this.totalStages,
    required this.routeIds,
    required this.routeNames,
    required this.planNames,
  });

  /// Number of plans imported.
  final int planCount;

  /// Total stages imported.
  final int totalStages;

  /// List of route IDs.
  final List<int> routeIds;

  /// List of route names.
  final List<String> routeNames;

  /// List of plan names.
  final List<String> planNames;

  @override
  String get name => 'plan_import_success';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
        'total_stages': totalStages,
        'route_ids': routeIds,
        'route_names': routeNames,
        'plan_names': planNames,
      };
}

/// Fired when a user cancels QR import after scanning.
class QrImportCancelledEvent extends AnalyticsEvent {
  /// Creates a [QrImportCancelledEvent].
  QrImportCancelledEvent({
    required this.planCount,
  });

  /// Number of decoded plans that were cancelled.
  final int planCount;

  @override
  String get name => 'qr_import_cancelled';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
      };
}

/// Fired when plan import fails.
class PlanImportFailedEvent extends AnalyticsEvent {
  /// Creates a [PlanImportFailedEvent].
  PlanImportFailedEvent({
    required this.planCount,
    required this.totalStages,
    required this.routeIds,
    required this.routeNames,
    required this.planNames,
    this.errorMessage,
  });

  /// Number of plans attempted.
  final int planCount;

  /// Total stages attempted.
  final int totalStages;

  /// List of route IDs.
  final List<int> routeIds;

  /// List of route names.
  final List<String> routeNames;

  /// List of plan names.
  final List<String> planNames;

  /// The error message, if any.
  final String? errorMessage;

  @override
  String get name => 'plan_import_failed';

  @override
  Map<String, dynamic> get properties => {
        'plan_count': planCount,
        'total_stages': totalStages,
        'route_ids': routeIds,
        'route_names': routeNames,
        'plan_names': planNames,
        'error_message': errorMessage,
      };
}
