import 'package:analytics_services/src/analytics_event.dart';

/// Fired when fetching data from the server fails.
class DataFetchFailedEvent extends AnalyticsEvent {
  /// Creates a [DataFetchFailedEvent].
  DataFetchFailedEvent({required this.entity});

  /// The entity type that failed to fetch.
  final String entity;

  @override
  String get name => 'data_fetch_failed';

  @override
  Map<String, dynamic> get properties => {'entity': entity};
}
