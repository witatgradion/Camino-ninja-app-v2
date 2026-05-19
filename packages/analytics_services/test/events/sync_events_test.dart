import 'package:analytics_services/analytics_services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MultiTrailPlanSyncSuccessEvent', () {
    test('uses multi_trail_plan_sync_success as the event name', () {
      final event = MultiTrailPlanSyncSuccessEvent(routeCount: 2);
      expect(event.name, 'multi_trail_plan_sync_success');
    });

    test('emits route_count verbatim', () {
      final event = MultiTrailPlanSyncSuccessEvent(routeCount: 3);
      expect(event.properties, {'route_count': 3});
    });

    test('round-trips a range of route counts', () {
      for (final n in const [2, 3, 5, 10]) {
        final event = MultiTrailPlanSyncSuccessEvent(routeCount: n);
        expect(event.properties['route_count'], n);
      }
    });
  });

  group('MultiTrailPlanSyncFailedEvent', () {
    test('uses multi_trail_plan_sync_failed as the event name', () {
      final event = MultiTrailPlanSyncFailedEvent(error: 'api_error: 500');
      expect(event.name, 'multi_trail_plan_sync_failed');
    });

    test('emits the error property verbatim', () {
      final event = MultiTrailPlanSyncFailedEvent(
        error: 'exception: TimeoutException',
      );
      expect(
        event.properties,
        {'error': 'exception: TimeoutException'},
      );
    });
  });
}
