import 'dart:async';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:analytics_services/analytics_services.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Analytics service implementation backed by Amplitude.
///
/// Wraps the Amplitude Flutter SDK and conforms to
/// [IAnalyticsService] so it can be used interchangeably
/// with Firebase or composed inside a composite service.
class AmplitudeAnalyticsService implements IAnalyticsService {
  /// Creates an [AmplitudeAnalyticsService].
  ///
  /// [apiKey] is the Amplitude project API key, typically
  /// injected via `--dart-define=AMPLITUDE_API_KEY=xxx`.
  AmplitudeAnalyticsService({required String apiKey})
      : _amplitude = Amplitude(Configuration(
          apiKey: apiKey,
          serverZone: ServerZone.eu,
        ));

  final Amplitude _amplitude;

  static const _tag = 'AmplitudeAnalytics';

  @override
  void trackScreen({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) {
    try {
      final properties = <String, dynamic>{
        'screen_name': screenName,
        ...?parameters,
      };

      if (kDebugMode) {
        AppLogger.d(
          'Screen: $screenName | $properties',
          tag: _tag,
        );
      }

      unawaited(
        _amplitude.track(
          BaseEvent(
            'screen_view',
            eventProperties: properties,
          ),
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Error tracking screen',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  void trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) {
    try {
      if (kDebugMode) {
        AppLogger.d(
          'Event: $eventName | $parameters',
          tag: _tag,
        );
      }

      unawaited(
        _amplitude.track(
          BaseEvent(
            eventName,
            eventProperties: parameters,
          ),
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Error tracking event',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  void setUserId({String? userId}) {
    try {
      unawaited(
        _amplitude.setUserId(userId != null ? 'ninja_user_$userId' : null),
      );
    } catch (e, st) {
      AppLogger.e(
        'Error setting user ID',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    try {
      final identify = Identify();
      for (final entry in properties.entries) {
        identify.set(entry.key, entry.value);
      }
      unawaited(_amplitude.identify(identify));
    } catch (e, st) {
      AppLogger.e(
        'Error setting user properties',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> flush() async {
    try {
      await _amplitude.flush();
    } catch (e, st) {
      AppLogger.e(
        'Error flushing events',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }
}
