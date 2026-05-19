import 'package:analytics_services/analytics_services.dart';

/// An [IAnalyticsService] that fans out every call to
/// multiple underlying providers.
///
/// This allows Firebase, Amplitude, and any future providers
/// to receive the same tracking calls without changing
/// call-sites throughout the app.
class CompositeAnalyticsService implements IAnalyticsService {
  /// Creates a [CompositeAnalyticsService] that delegates
  /// to each provider in [_providers].
  const CompositeAnalyticsService(this._providers);

  final List<IAnalyticsService> _providers;

  @override
  void trackScreen({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) {
    for (final provider in _providers) {
      provider.trackScreen(
        screenName: screenName,
        parameters: parameters,
      );
    }
  }

  @override
  void trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) {
    for (final provider in _providers) {
      provider.trackEvent(
        eventName: eventName,
        parameters: parameters,
      );
    }
  }

  @override
  void setUserId({String? userId}) {
    for (final provider in _providers) {
      provider.setUserId(userId: userId);
    }
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    for (final provider in _providers) {
      provider.setUserProperties(properties);
    }
  }

  @override
  Future<void> flush() async {
    for (final provider in _providers) {
      await provider.flush();
    }
  }
}
