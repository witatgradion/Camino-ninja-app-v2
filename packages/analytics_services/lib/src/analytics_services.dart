import 'dart:async';

import 'package:analytics_services/src/analytics_event.dart';
import 'package:core/core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

abstract class IAnalyticsService {
  void trackScreen({
    required String screenName,
    Map<String, dynamic>? parameters,
  });

  void trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  });

  void setUserId({String? userId});

  void setUserProperties(Map<String, dynamic> properties);

  Future<void> flush();
}

/// Extension that adds a typed [track] helper to every
/// [IAnalyticsService] implementation without requiring them
/// to override it.
extension AnalyticsServiceTrackExt on IAnalyticsService {
  /// Convenience method that delegates to [trackEvent] using
  /// the typed [AnalyticsEvent]'s name and properties.
  void track(AnalyticsEvent event) {
    trackEvent(
      eventName: event.name,
      parameters: event.properties,
    );
  }
}

class AnalyticsService implements IAnalyticsService {
  AnalyticsService({
    required this.supportedLocales,
    required this.appPreferences,
    required FirebaseAnalytics firebaseAnalytics,
  }) : _analytics = firebaseAnalytics;

  final FirebaseAnalytics _analytics;
  final List<Locale> supportedLocales;
  final AppPreferences appPreferences;

  static const _tag = 'Analytics';
  static const _divider = '───────────────────────────────────────';

  Future<String> _getDeviceLanguage() async {
    final language = await appPreferences.getLanguage();
    if (language != null) {
      return language;
    }
    final deviceLocale = PlatformDispatcher.instance.locale;
    final matchedLocale = supportedLocales.firstWhere(
      (locale) => locale.languageCode == deviceLocale.languageCode,
      orElse: () => const Locale('en'),
    );
    return matchedLocale.languageCode;
  }

  @override
  void trackScreen({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) {
    _getDeviceLanguage().then((language) {
      final updatedParameters = Map<String, dynamic>.from(parameters ?? {});

      if (!updatedParameters.containsKey('language')) {
        updatedParameters['language'] = language;
      }

      if (kDebugMode) {
        _logAnalyticsEvent('SCREEN', screenName, updatedParameters);
      }

      unawaited(
        _analytics.logScreenView(
          screenName: screenName,
          parameters: updatedParameters.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        ),
      );
    });
  }

  @override
  void trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) {
    _getDeviceLanguage().then((language) {
      final updatedParameters = Map<String, dynamic>.from(parameters ?? {});

      if (!updatedParameters.containsKey('language')) {
        updatedParameters['language'] = language;
      }

      if (kDebugMode) {
        _logAnalyticsEvent('EVENT', eventName, updatedParameters);
      }

      final firebaseParams = _flattenListValues(updatedParameters);

      unawaited(() async {
        try {
          return _analytics.logEvent(
            name: eventName,
            parameters: firebaseParams.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          );
        } catch (e) {
          AppLogger.e('Error logging event', tag: _tag, error: e);
        }
      }());
    });
  }

  Map<String, dynamic> _flattenListValues(
    Map<String, dynamic> params,
  ) {
    return params.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.join(','));
      }
      return MapEntry(key, value);
    });
  }

  void _logAnalyticsEvent(
    String type,
    String name,
    Map<String, dynamic> parameters,
  ) {
    final buffer = StringBuffer()
      ..writeln('┌$_divider')
      ..writeln('│ $type: $name')
      ..writeln('├$_divider');

    if (parameters.isNotEmpty) {
      for (final entry in parameters.entries) {
        buffer.writeln('│ ${entry.key}: ${entry.value}');
      }
    } else {
      buffer.writeln('│ (no parameters)');
    }

    buffer.write('└$_divider');

    AppLogger.d(buffer.toString(), tag: _tag);
  }

  @override
  void setUserId({String? userId}) {
    unawaited(_analytics.setUserId(id: userId));
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    for (final entry in properties.entries) {
      unawaited(
        _analytics.setUserProperty(
          name: entry.key,
          value: entry.value.toString(),
        ),
      );
    }
  }

  @override
  Future<void> flush() => Future.value();
}
