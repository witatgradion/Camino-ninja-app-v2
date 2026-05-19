// Sanity-check that [FakeNetworkService]'s underlying [Dio] is wired
// to a throwing [HttpClientAdapter]. If this guarantee ever regresses,
// integration tests can silently start hitting the real network.
//
// We exercise an arbitrary inherited method (`getRoutesOnly`) that we
// have NOT overridden in the fake. The expectation is that the real
// Dio call surfaces — and our throwing adapter slams the door.

import 'package:flutter_test/flutter_test.dart';
import 'package:remote_data/remote_data.dart';

import 'fake_network_service.dart';

void main() {
  test(
      'FakeNetworkService surfaces a StateError naming the offending '
      'method+URL when an unmocked endpoint is hit', () async {
    final fake = FakeNetworkService();

    // `getRoutesOnly` is NOT overridden by the fake, so it falls
    // through to the inherited NetworkService implementation, which
    // hits the underlying Dio. The Dio is wired to a throwing
    // adapter — the call surfaces an ApiFailure (because
    // NetworkService catches & wraps), so we inspect the failure
    // message to confirm our explicit error reached it.
    final result = await fake.getRoutesOnly();

    expect(result, isA<ApiFailure<List<RouteResponse>>>());
    final message = (result as ApiFailure<List<RouteResponse>>).message;
    expect(
      message,
      contains('FakeNetworkService received an unexpected real-Dio'),
      reason: 'The throwing adapter must produce a loud, '
          'self-describing error so failing tests are easy to '
          'diagnose.',
    );
    expect(
      message,
      contains('GET'),
      reason: 'Method should be present in the error message.',
    );
    expect(
      message,
      contains('/api/'),
      reason: 'Endpoint path should be present in the error message '
          'so the failing test points at the exact endpoint that was '
          'hit (Dio uses relative paths, not full URLs).',
    );
  });

  test(
      'FakeNetworkService.syncStagePlanner does NOT go through the '
      'throwing adapter (overrides the inherited path)', () async {
    final fake = FakeNetworkService();

    // Build a minimal request — the fake should merge it into its
    // in-memory remote state and return success without ever
    // touching the underlying Dio.
    final result = await fake.syncStagePlanner(
      deviceId: 'test-device',
      request: const SyncStagePlannerRequest(plans: []),
    );

    expect(result, isA<ApiSuccess<SyncStagePlannerResponse>>());
    expect(fake.recordedRequests, hasLength(1));
  });
}
