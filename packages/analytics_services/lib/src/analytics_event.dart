/// Base class for all typed analytics events.
abstract class AnalyticsEvent {
  /// The event name sent to analytics providers.
  String get name;

  /// The event properties/parameters.
  Map<String, dynamic> get properties;
}
