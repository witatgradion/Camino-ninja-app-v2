import 'package:analytics_services/analytics_services.dart';
import 'package:flutter/foundation.dart';

/// Tracks which feature flags have already emitted a
/// [FeatureFlagExposureEvent] in the current process.
///
/// "Session" is interpreted as the process lifetime — the in-memory
/// set is reset when the OS kills the app, matching what the Amplitude
/// dashboard treats as a session for cohort accounting.
abstract final class FeatureFlagExposureTracker {
  static final Set<String> _emitted = <String>{};

  /// Fires a [FeatureFlagExposureEvent] via [analytics] the first time
  /// it is called for [flagName] in this process; subsequent calls
  /// with the same name are no-ops regardless of [flagValue].
  ///
  /// Different [flagName]s are tracked independently.
  static void report({
    required IAnalyticsService analytics,
    required String flagName,
    required bool flagValue,
  }) {
    if (!_emitted.add(flagName)) return;
    analytics.track(
      FeatureFlagExposureEvent(
        flagName: flagName,
        flagValue: flagValue,
      ),
    );
  }

  /// Clears the in-memory dedup set. Intended for tests only.
  @visibleForTesting
  static void reset() {
    _emitted.clear();
  }
}
