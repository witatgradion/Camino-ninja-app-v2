import 'package:analytics_services/src/analytics_event.dart';

/// Fired when the unit preference is changed.
class UnitChangedEvent extends AnalyticsEvent {
  /// Creates a [UnitChangedEvent].
  UnitChangedEvent({required this.unit});

  /// The new unit value.
  final String unit;

  @override
  String get name => 'unit_changed';

  @override
  Map<String, dynamic> get properties => {'unit': unit};
}

/// Fired when the language preference is changed.
class LanguageChangedEvent extends AnalyticsEvent {
  /// Creates a [LanguageChangedEvent].
  LanguageChangedEvent({required this.language});

  /// The new language code.
  final String language;

  @override
  String get name => 'language_changed';

  @override
  Map<String, dynamic> get properties => {
        'language': language,
      };
}

/// Fired when the theme preference is changed.
class ThemeChangedEvent extends AnalyticsEvent {
  /// Creates a [ThemeChangedEvent].
  ThemeChangedEvent({required this.theme});

  /// The new theme name.
  final String theme;

  @override
  String get name => 'theme_changed';

  @override
  Map<String, dynamic> get properties => {'theme': theme};
}

/// Fired when the update-now button is pressed.
class UpdateNowPressedEvent extends AnalyticsEvent {
  @override
  String get name => 'update_now_pressed';

  @override
  Map<String, dynamic> get properties => {};
}

/// Fired when data sync encounters an exception.
class DataSyncExceptionEvent extends AnalyticsEvent {
  /// Creates a [DataSyncExceptionEvent].
  DataSyncExceptionEvent({required this.error, required this.stackTrace});

  final String error;
  final String stackTrace;

  @override
  String get name => 'data_sync_exception';

  @override
  Map<String, dynamic> get properties => {
        'error': error,
        'stack_trace': stackTrace,
      };
}

/// Fired when the app version is copied to the clipboard
/// from the More tab footer.
class VersionCopiedEvent extends AnalyticsEvent {
  /// Creates a [VersionCopiedEvent].
  VersionCopiedEvent({required this.version});

  /// The app version string that was copied.
  final String version;

  @override
  String get name => 'version_copied';

  @override
  Map<String, dynamic> get properties => {'version': version};
}

/// Fired when a URL is launched.
class LaunchUrlSafelyEvent extends AnalyticsEvent {
  /// Creates a [LaunchUrlSafelyEvent].
  LaunchUrlSafelyEvent({required this.url});

  /// The URL being launched.
  final String url;

  @override
  String get name => 'launch_url_safely';

  @override
  Map<String, dynamic> get properties => {'url': url};
}
