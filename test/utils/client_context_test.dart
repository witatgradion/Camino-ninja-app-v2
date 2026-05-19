import 'dart:convert';

import 'package:camino_ninja_flutter/utils/client_context.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClientContext', () {
    const ctx = ClientContext(
      appVersion: '2.2.395',
      buildNumber: '202395',
      platform: 'ios',
      osVersion: 'iOS 18.0',
      deviceModel: 'iPhone17,2',
    );

    test('schemaVersion is 1', () {
      expect(ClientContext.schemaVersion, 1);
    });

    test('toJson returns the expected wire shape', () {
      final json = ctx.toJson();

      expect(json, {
        'schema_version': 1,
        'app_version': '2.2.395',
        'build_number': '202395',
        'platform': 'ios',
        'os_version': 'iOS 18.0',
        'device_model': 'iPhone17,2',
      });
    });

    test('toJson keys match the wire spec exactly', () {
      // Backend contract — failing this means we drifted from the
      // documented JSON schema. Update both ends or revert.
      expect(
        ctx.toJson().keys.toSet(),
        {
          'schema_version',
          'app_version',
          'build_number',
          'platform',
          'os_version',
          'device_model',
        },
      );
    });

    test('toJson is JSON-encodable (no non-primitive values)', () {
      final encoded = jsonEncode(ctx.toJson());
      // Round-trip: decoded JSON is structurally equal to the source.
      expect(jsonDecode(encoded), ctx.toJson());
    });

    test('schema_version is always emitted, even with empty fields', () {
      const empty = ClientContext(
        appVersion: '',
        buildNumber: '',
        platform: '',
        osVersion: '',
        deviceModel: '',
      );
      expect(empty.toJson()['schema_version'], 1);
    });

    test('equality is value-based', () {
      const a = ClientContext(
        appVersion: '1.0.0',
        buildNumber: '1',
        platform: 'ios',
        osVersion: 'iOS 18.0',
        deviceModel: 'iPhone17,2',
      );
      const b = ClientContext(
        appVersion: '1.0.0',
        buildNumber: '1',
        platform: 'ios',
        osVersion: 'iOS 18.0',
        deviceModel: 'iPhone17,2',
      );
      const c = ClientContext(
        appVersion: '1.0.1',
        buildNumber: '1',
        platform: 'ios',
        osVersion: 'iOS 18.0',
        deviceModel: 'iPhone17,2',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('platform string is lowercase by convention', () {
      // Documenting our wire convention so anyone tempted to write
      // "iOS" / "Android" gets caught here.
      expect(ctx.platform, ctx.platform.toLowerCase());
    });
  });
}
