import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/feature_flag_exposure_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAnalyticsService implements IAnalyticsService {
  final List<({String name, Map<String, dynamic> params})> tracked = [];

  @override
  void trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) {
    tracked.add((name: eventName, params: parameters ?? const {}));
  }

  @override
  void trackScreen({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) {}

  @override
  void setUserId({String? userId}) {}

  @override
  void setUserProperties(Map<String, dynamic> properties) {}

  @override
  Future<void> flush() async {}
}

void main() {
  late _RecordingAnalyticsService analytics;

  setUp(() {
    FeatureFlagExposureTracker.reset();
    analytics = _RecordingAnalyticsService();
  });

  test('fires a feature_flag_exposure event on first report', () {
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_custom_trail_enabled',
      flagValue: true,
    );

    expect(analytics.tracked, hasLength(1));
    expect(analytics.tracked.single.name, 'feature_flag_exposure');
    expect(
      analytics.tracked.single.params,
      {
        'flag_name': 'feature_custom_trail_enabled',
        'flag_value': true,
      },
    );
  });

  test('subsequent reports with the same flag_name are no-ops', () {
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_custom_trail_enabled',
      flagValue: true,
    );
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_custom_trail_enabled',
      flagValue: false,
    );
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_custom_trail_enabled',
      flagValue: true,
    );

    expect(analytics.tracked, hasLength(1));
    expect(
      analytics.tracked.single.params['flag_value'],
      true,
      reason: 'second/third report must not re-emit, even if value changed',
    );
  });

  test('different flag_names emit independently', () {
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_custom_trail_enabled',
      flagValue: true,
    );
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_journey_planner_enabled',
      flagValue: false,
    );

    expect(analytics.tracked, hasLength(2));
    expect(
      analytics.tracked.map((e) => e.params['flag_name']),
      ['feature_custom_trail_enabled', 'feature_journey_planner_enabled'],
    );
  });

  test('a second flag_name still de-dupes after the first fired', () {
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_journey_planner_enabled',
      flagValue: true,
    );
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_journey_planner_enabled',
      flagValue: true,
    );

    expect(analytics.tracked, hasLength(1));
  });

  test('reset clears the in-memory set so events fire again', () {
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_custom_trail_enabled',
      flagValue: true,
    );
    expect(analytics.tracked, hasLength(1));

    FeatureFlagExposureTracker.reset();

    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_custom_trail_enabled',
      flagValue: true,
    );
    expect(analytics.tracked, hasLength(2));
  });
}
