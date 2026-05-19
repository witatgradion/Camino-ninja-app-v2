import 'package:analytics_services/src/analytics_event.dart';

/// Fired when a deep link is opened.
class DeepLinkOpenedEvent extends AnalyticsEvent {
  /// Creates a [DeepLinkOpenedEvent].
  DeepLinkOpenedEvent({
    required this.path,
    required this.link,
  });

  /// The parsed path from the deep link URI.
  final String path;

  /// The full deep link URL.
  final String link;

  @override
  String get name => 'deep_link_opened';

  @override
  Map<String, dynamic> get properties => {
        'path': path,
        'link': link,
      };
}
