import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:repository/repository.dart';

void main() {
  const testBuildNumber = 123456; // 6 digits
  const testPlatform = QrPlatform.android;

  group('StagePlanCodec', () {
    group('encode/decode symmetry', () {
      test('single stage plan roundtrip', () {
        final original = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024, 6, 15),
              startCityId: 100,
              endCityId: 200,
              startAlbergueId: 1001,
              endAlbergueId: 2001,
            ),
          ],
        );

        final encoded = StagePlanCodec.encode(
          original,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan.routeId, original.routeId);
        expect(result.firstPlan.stages.length, original.stages.length);
        expect(result.firstPlan.stages[0].startCityId, original.stages[0].startCityId);
        expect(result.firstPlan.stages[0].endCityId, original.stages[0].endCityId);
        expect(
          result.firstPlan.stages[0].startAlbergueId,
          original.stages[0].startAlbergueId,
        );
        expect(
          result.firstPlan.stages[0].endAlbergueId,
          original.stages[0].endAlbergueId,
        );
        expect(result.buildNumber, testBuildNumber);
        expect(result.platform, testPlatform);
      });

      test('single stage plan with name roundtrip', () {
        final original = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024, 6, 15),
              startCityId: 100,
              endCityId: 200,
            ),
          ],
          name: 'My Camino Trip',
        );

        final encoded = StagePlanCodec.encode(
          original,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan.routeId, original.routeId);
        expect(result.firstPlan.name, 'My Camino Trip');
        expect(result.firstPlan.stages.length, original.stages.length);
      });

      test('plan with null name roundtrip', () {
        final original = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024, 6, 15),
              startCityId: 100,
              endCityId: 200,
            ),
          ],
        );

        final encoded = StagePlanCodec.encode(
          original,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan.name, isNull);
      });

      test('plan with empty name roundtrip', () {
        final original = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024, 6, 15),
              startCityId: 100,
              endCityId: 200,
            ),
          ],
          name: '',
        );

        final encoded = StagePlanCodec.encode(
          original,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        // Empty name should be decoded as null
        expect(result.firstPlan.name, isNull);
      });

      test('plan name with special characters roundtrip', () {
        final original = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024, 6, 15),
              startCityId: 100,
              endCityId: 200,
            ),
          ],
          name: 'Camino Francés 2024 🚶‍♂️',
        );

        final encoded = StagePlanCodec.encode(
          original,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan.name, 'Camino Francés 2024 🚶‍♂️');
      });

      test('plan name with non-latin characters roundtrip', () {
        final original = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024, 6, 15),
              startCityId: 100,
              endCityId: 200,
            ),
          ],
          name: '我的朝圣之旅 カミノ旅行',
        );

        final encoded = StagePlanCodec.encode(
          original,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan.name, '我的朝圣之旅 カミノ旅行');
      });

      test('multi-stage plan roundtrip', () {
        final original = StagePlanData(
          routeId: 5,
          stages: [
            StageData(
              date: DateTime(2025, 3),
              startCityId: 10,
              endCityId: 20,
            ),
            StageData(
              date: DateTime(2025, 3, 2),
              startCityId: 20,
              endCityId: 30,
              endAlbergueId: 300,
            ),
            StageData(
              date: DateTime(2025, 3, 4),
              startCityId: 30,
              endCityId: 40,
              startAlbergueId: 310,
              endAlbergueId: 400,
            ),
          ],
        );

        final encoded = StagePlanCodec.encode(
          original,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan, equals(original));
      });

      test('null albergue ids encoded as 0', () {
        final original = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 100,
              endCityId: 200,
            ),
          ],
        );

        final encoded = StagePlanCodec.encode(
          original,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan.stages[0].startAlbergueId, isNull);
        expect(result.firstPlan.stages[0].endAlbergueId, isNull);
      });

      test('maximum values roundtrip', () {
        final original = StagePlanData(
          routeId: 65535,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 65535,
              endCityId: 65535,
              startAlbergueId: 65534,
              endAlbergueId: 65534,
            ),
          ],
        );

        final encoded = StagePlanCodec.encode(
          original,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan, equals(original));
      });

      test('stages sorted by date during encoding', () {
        final unordered = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024, 6, 3),
              startCityId: 30,
              endCityId: 40,
            ),
            StageData(
              date: DateTime(2024, 6),
              startCityId: 10,
              endCityId: 20,
            ),
            StageData(
              date: DateTime(2024, 6, 2),
              startCityId: 20,
              endCityId: 30,
            ),
          ],
        );

        final encoded = StagePlanCodec.encode(
          unordered,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan.stages[0].startCityId, 10);
        expect(result.firstPlan.stages[1].startCityId, 20);
        expect(result.firstPlan.stages[2].startCityId, 30);
      });

      test('255 stages roundtrip (max capacity)', () {
        final stages = List.generate(
          255,
          (i) => StageData(
            date: DateTime(2024).add(Duration(days: i)),
            startCityId: i,
            endCityId: i + 1,
          ),
        );

        final original = StagePlanData(routeId: 1, stages: stages);
        final encoded = StagePlanCodec.encode(
          original,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan.stages.length, 255);
        expect(result.firstPlan.routeId, 1);
      });
    });

    group('encoding constraints', () {
      test('throws on empty stages', () {
        const plan = StagePlanData(routeId: 1, stages: []);

        expect(
          () => StagePlanCodec.encode(
            plan,
            buildNumber: testBuildNumber,
            platform: testPlatform,
          ),
          throwsA(isA<CodecException>()),
        );
      });

      test('throws on more than 255 stages', () {
        final stages = List.generate(
          256,
          (i) => StageData(
            date: DateTime(2024).add(Duration(days: i)),
            startCityId: i % 65535,
            endCityId: (i + 1) % 65535,
          ),
        );
        final plan = StagePlanData(routeId: 1, stages: stages);

        expect(
          () => StagePlanCodec.encode(
            plan,
            buildNumber: testBuildNumber,
            platform: testPlatform,
          ),
          throwsA(isA<CodecException>()),
        );
      });

      test('throws on date delta > 255 days', () {
        final plan = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 10,
              endCityId: 20,
            ),
            StageData(
              date: DateTime(2024, 10),
              startCityId: 20,
              endCityId: 30,
            ),
          ],
        );

        expect(
          () => StagePlanCodec.encode(
            plan,
            buildNumber: testBuildNumber,
            platform: testPlatform,
          ),
          throwsA(isA<CodecException>()),
        );
      });

      test('throws on date before epoch (2020)', () {
        final plan = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2019, 12, 31), // Before Jan 1, 2020
              startCityId: 10,
              endCityId: 20,
            ),
          ],
        );

        expect(
          () => StagePlanCodec.encode(
            plan,
            buildNumber: testBuildNumber,
            platform: testPlatform,
          ),
          throwsA(
            isA<CodecException>().having(
              (e) => e.message,
              'message',
              'Start date out of encodable range',
            ),
          ),
        );
      });

      test('throws on negative build number', () {
        final plan = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 10,
              endCityId: 20,
            ),
          ],
        );

        expect(
          () => StagePlanCodec.encode(
            plan,
            buildNumber: -1,
            platform: testPlatform,
          ),
          throwsA(
            isA<CodecException>().having(
              (e) => e.message,
              'message',
              'Build number must be non-negative',
            ),
          ),
        );
      });

      test('throws on plan name too long (> 255 bytes)', () {
        // Create a name that's > 255 bytes when UTF-8 encoded
        final longName = 'A' * 256;
        final plan = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 10,
              endCityId: 20,
            ),
          ],
          name: longName,
        );

        expect(
          () => StagePlanCodec.encode(
            plan,
            buildNumber: testBuildNumber,
            platform: testPlatform,
          ),
          throwsA(
            isA<CodecException>().having(
              (e) => e.message,
              'message',
              'Plan name too long (max 255 bytes)',
            ),
          ),
        );
      });

      test('plan name at max length (255 bytes) succeeds', () {
        final maxName = 'A' * 255;
        final plan = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 10,
              endCityId: 20,
            ),
          ],
          name: maxName,
        );

        final encoded = StagePlanCodec.encode(
          plan,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final result = StagePlanCodec.decode(encoded);

        expect(result.firstPlan.name, maxName);
      });
    });

    group('decoding validation', () {
      test('throws on invalid Base45', () {
        expect(
          () => StagePlanCodec.decode('!!!invalid!!!'),
          throwsA(isA<CodecException>()),
        );
      });

      test('throws on data too short', () {
        final shortData = Base45.encode(Uint8List(5));

        expect(
          () => StagePlanCodec.decode(shortData),
          throwsA(isA<CodecException>()),
        );
      });

      test('throws on CRC mismatch', () {
        final valid = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 10,
              endCityId: 20,
            ),
          ],
        );
        final encoded = StagePlanCodec.encode(
          valid,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final bytes = Base45.decode(encoded);

        // Corrupt one byte (after common header)
        bytes[10] = (bytes[10] + 1) % 256;

        final corrupted = Base45.encode(bytes);

        expect(
          () => StagePlanCodec.decode(corrupted),
          throwsA(isA<CodecException>()),
        );
      });

      test('throws on unsupported version', () {
        final valid = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 10,
              endCityId: 20,
            ),
          ],
        );
        final encoded = StagePlanCodec.encode(
          valid,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final bytes = Base45.decode(encoded);

        // Change version byte (at index 7, after magic[2] + buildNumber[4] + platform[1]) and fix CRC
        bytes[7] = 99;
        final dataBytes = Uint8List.view(bytes.buffer, 0, bytes.length - 2);
        final newCrc = Crc16Ccitt.compute(dataBytes);
        final buffer = ByteData.view(bytes.buffer);
        buffer.setUint16(bytes.length - 2, newCrc, Endian.little);

        final modified = Base45.encode(bytes);

        expect(
          () => StagePlanCodec.decode(modified),
          throwsA(isA<CodecException>()),
        );
      });
    });

    group('binary size verification (version 2 format)', () {
      // Version 2 layout:
      // - Magic: 2 bytes ("CN")
      // - Build Number: 4 bytes (uint32)
      // - Platform: 1 byte
      // - Header: 2 bytes (version + planCount)
      // - Per plan: 5 bytes (routeId + stageCount + startDate) + 9 bytes per stage + 1 byte name length + name bytes
      // - Footer: 2 bytes (CRC16)
      
      test('single stage without name uses 26 bytes', () {
        final plan = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 10,
              endCityId: 20,
            ),
          ],
        );

        final encoded = StagePlanCodec.encode(
          plan,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final bytes = Base45.decode(encoded);

        // 2 magic + 4 buildNumber + 1 platform + 2 header + 5 plan header + 9 stage + 1 nameLength + 2 footer = 26
        expect(bytes.length, 26);
      });

      test('single stage with name adds name length to size', () {
        final plan = StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 10,
              endCityId: 20,
            ),
          ],
          name: 'Test', // 4 bytes
        );

        final encoded = StagePlanCodec.encode(
          plan,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final bytes = Base45.decode(encoded);

        // 2 magic + 4 buildNumber + 1 platform + 2 header + 5 plan header + 9 stage + 1 nameLength + 4 name + 2 footer = 30
        expect(bytes.length, 30);
      });

      test('10 stages without name uses 107 bytes', () {
        final stages = List.generate(
          10,
          (i) => StageData(
            date: DateTime(2024).add(Duration(days: i)),
            startCityId: i,
            endCityId: i + 1,
          ),
        );
        final plan = StagePlanData(routeId: 1, stages: stages);

        final encoded = StagePlanCodec.encode(
          plan,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final bytes = Base45.decode(encoded);

        // 2 magic + 4 buildNumber + 1 platform + 2 header + 5 plan header + (9 * 10) stages + 1 nameLength + 2 footer = 107
        expect(bytes.length, 107);
      });

      test('255 stages without name uses 2312 bytes', () {
        final stages = List.generate(
          255,
          (i) => StageData(
            date: DateTime(2024).add(Duration(days: i)),
            startCityId: i,
            endCityId: i + 1,
          ),
        );
        final plan = StagePlanData(routeId: 1, stages: stages);

        final encoded = StagePlanCodec.encode(
          plan,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        );
        final bytes = Base45.decode(encoded);

        // 2 magic + 4 buildNumber + 1 platform + 2 header + 5 plan header + (9 * 255) stages + 1 nameLength + 2 footer = 2312
        expect(bytes.length, 2312);
      });
    });
  });

  group('Crc16Ccitt', () {
    test('empty data returns init value XORed properly', () {
      final result = Crc16Ccitt.compute(Uint8List(0));
      expect(result, 0xFFFF);
    });

    test('known test vectors', () {
      // "123456789" ASCII
      final data = Uint8List.fromList([0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39]);
      final crc = Crc16Ccitt.compute(data);
      // CRC-16/CCITT-FALSE for "123456789" = 0x29B1
      expect(crc, 0x29B1);
    });

    test('different data produces different CRC', () {
      final data1 = Uint8List.fromList([1, 2, 3]);
      final data2 = Uint8List.fromList([1, 2, 4]);

      expect(Crc16Ccitt.compute(data1), isNot(Crc16Ccitt.compute(data2)));
    });
  });

  group('Base45', () {
    test('empty data', () {
      expect(Base45.encode(Uint8List(0)), '');
      expect(Base45.decode(''), Uint8List(0));
    });

    test('single byte', () {
      final data = Uint8List.fromList([0xAB]);
      final encoded = Base45.encode(data);
      final decoded = Base45.decode(encoded);
      expect(decoded, data);
    });

    test('two bytes', () {
      final data = Uint8List.fromList([0xAB, 0xCD]);
      final encoded = Base45.encode(data);
      final decoded = Base45.decode(encoded);
      expect(decoded, data);
    });

    test('roundtrip various lengths', () {
      for (var len = 1; len <= 20; len++) {
        final data = Uint8List.fromList(
          List.generate(len, (i) => (i * 37) % 256),
        );
        final encoded = Base45.encode(data);
        final decoded = Base45.decode(encoded);
        expect(decoded, data, reason: 'Failed for length $len');
      }
    });

    test('RFC 9285 test vectors', () {
      // "Hello!!" -> "UJCLQE7W581"
      final hello = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21, 0x21]);
      expect(Base45.encode(hello), '%69 VD92EX0');
      expect(Base45.decode('%69 VD92EX0'), hello);

      // "AB" -> "BB8"
      final ab = Uint8List.fromList([0x41, 0x42]);
      expect(Base45.encode(ab), 'BB8');
      expect(Base45.decode('BB8'), ab);
    });

    test('throws on invalid character', () {
      expect(() => Base45.decode('abc'), throwsFormatException);
      expect(() => Base45.decode('#'), throwsFormatException);
    });

    test('encodes to QR alphanumeric charset', () {
      final data = Uint8List.fromList(List.generate(100, (i) => i));
      final encoded = Base45.encode(data);

      // All characters should be in QR alphanumeric mode charset
      const validChars = r'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:';
      for (final char in encoded.split('')) {
        expect(validChars.contains(char), isTrue,
            reason: 'Character "$char" not in valid charset',);
      }
    });
  });

  group('StageData equality', () {
    test('equal stages with same date (ignoring time)', () {
      final a = StageData(
        date: DateTime(2024, 6, 15, 10, 30),
        startCityId: 100,
        endCityId: 200,
      );
      final b = StageData(
        date: DateTime(2024, 6, 15, 14, 45),
        startCityId: 100,
        endCityId: 200,
      );

      expect(a, equals(b));
    });

    test('not equal with different dates', () {
      final a = StageData(
        date: DateTime(2024, 6, 15),
        startCityId: 100,
        endCityId: 200,
      );
      final b = StageData(
        date: DateTime(2024, 6, 16),
        startCityId: 100,
        endCityId: 200,
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('StagePlanData equality', () {
    test('equal plans with same name', () {
      final a = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024, 6, 15),
            startCityId: 100,
            endCityId: 200,
          ),
        ],
        name: 'My Plan',
      );
      final b = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024, 6, 15),
            startCityId: 100,
            endCityId: 200,
          ),
        ],
        name: 'My Plan',
      );

      expect(a, equals(b));
    });

    test('not equal with different names', () {
      final a = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024, 6, 15),
            startCityId: 100,
            endCityId: 200,
          ),
        ],
        name: 'Plan A',
      );
      final b = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024, 6, 15),
            startCityId: 100,
            endCityId: 200,
          ),
        ],
        name: 'Plan B',
      );

      expect(a, isNot(equals(b)));
    });

    test('equal plans with null names', () {
      final a = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024, 6, 15),
            startCityId: 100,
            endCityId: 200,
          ),
        ],
      );
      final b = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024, 6, 15),
            startCityId: 100,
            endCityId: 200,
          ),
        ],
      );

      expect(a, equals(b));
    });

    test('not equal when one has name and other does not', () {
      final a = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024, 6, 15),
            startCityId: 100,
            endCityId: 200,
          ),
        ],
        name: 'Named Plan',
      );
      final b = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024, 6, 15),
            startCityId: 100,
            endCityId: 200,
          ),
        ],
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('Multi-plan codec (version 2)', () {
    const testBuildNumber = 123456;
    const testPlatform = QrPlatform.ios;

    test('multiple plans roundtrip', () {
      final plans = [
        StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024, 6),
              startCityId: 10,
              endCityId: 20,
            ),
            StageData(
              date: DateTime(2024, 6, 2),
              startCityId: 20,
              endCityId: 30,
            ),
          ],
          name: 'First Plan',
        ),
        StagePlanData(
          routeId: 2,
          stages: [
            StageData(
              date: DateTime(2024, 7),
              startCityId: 100,
              endCityId: 200,
              startAlbergueId: 1001,
              endAlbergueId: 2001,
            ),
          ],
          // No name for second plan
        ),
        StagePlanData(
          routeId: 3,
          stages: [
            StageData(
              date: DateTime(2024, 8),
              startCityId: 500,
              endCityId: 600,
            ),
            StageData(
              date: DateTime(2024, 8, 2),
              startCityId: 600,
              endCityId: 700,
            ),
            StageData(
              date: DateTime(2024, 8, 3),
              startCityId: 700,
              endCityId: 800,
            ),
          ],
          name: 'Third Plan 🎉',
        ),
      ];

      final encoded = StagePlanCodec.encodeMultiple(
        plans,
        buildNumber: testBuildNumber,
        platform: testPlatform,
      );
      final result = StagePlanCodec.decode(encoded);

      expect(result.plans.length, 3);
      expect(result.plans[0].routeId, 1);
      expect(result.plans[0].stages.length, 2);
      expect(result.plans[0].name, 'First Plan');
      expect(result.plans[1].routeId, 2);
      expect(result.plans[1].stages.length, 1);
      expect(result.plans[1].stages[0].startAlbergueId, 1001);
      expect(result.plans[1].name, isNull);
      expect(result.plans[2].routeId, 3);
      expect(result.plans[2].stages.length, 3);
      expect(result.plans[2].name, 'Third Plan 🎉');
      expect(result.buildNumber, testBuildNumber);
      expect(result.platform, testPlatform);
    });

    test('single plan via encodeMultiple roundtrip', () {
      final original = StagePlanData(
        routeId: 42,
        stages: [
          StageData(
            date: DateTime(2024, 5),
            startCityId: 10,
            endCityId: 20,
          ),
        ],
        name: 'My Solo Plan',
      );

      final encoded = StagePlanCodec.encodeMultiple(
        [original],
        buildNumber: testBuildNumber,
        platform: testPlatform,
      );
      final result = StagePlanCodec.decode(encoded);

      expect(result.plans.length, 1);
      expect(result.plans[0].routeId, original.routeId);
      expect(result.plans[0].stages.length, original.stages.length);
      expect(result.plans[0].name, 'My Solo Plan');
    });

    test('firstPlan returns first plan for backward compatibility', () {
      final plans = [
        StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024, 6),
              startCityId: 10,
              endCityId: 20,
            ),
          ],
        ),
        StagePlanData(
          routeId: 2,
          stages: [
            StageData(
              date: DateTime(2024, 7),
              startCityId: 100,
              endCityId: 200,
            ),
          ],
        ),
      ];

      final encoded = StagePlanCodec.encodeMultiple(
        plans,
        buildNumber: testBuildNumber,
        platform: testPlatform,
      );
      final result = StagePlanCodec.decode(encoded);

      // firstPlan should return the first plan
      expect(result.firstPlan.routeId, 1);
    });

    test('throws on empty plans list', () {
      expect(
        () => StagePlanCodec.encodeMultiple(
          [],
          buildNumber: testBuildNumber,
          platform: testPlatform,
        ),
        throwsA(isA<CodecException>()),
      );
    });

    test('throws on more than 255 plans', () {
      final plans = List.generate(
        256,
        (i) => StagePlanData(
          routeId: i,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: i,
              endCityId: i + 1,
            ),
          ],
        ),
      );

      expect(
        () => StagePlanCodec.encodeMultiple(
          plans,
          buildNumber: testBuildNumber,
          platform: testPlatform,
        ),
        throwsA(isA<CodecException>()),
      );
    });

    test('multi-plan binary size calculation', () {
      // 2 plans with 2 and 3 stages respectively
      final plans = [
        StagePlanData(
          routeId: 1,
          stages: List.generate(
            2,
            (i) => StageData(
              date: DateTime(2024).add(Duration(days: i)),
              startCityId: i,
              endCityId: i + 1,
            ),
          ),
        ),
        StagePlanData(
          routeId: 2,
          stages: List.generate(
            3,
            (i) => StageData(
              date: DateTime(2024, 2).add(Duration(days: i)),
              startCityId: i + 10,
              endCityId: i + 11,
            ),
          ),
        ),
      ];

      final encoded = StagePlanCodec.encodeMultiple(
        plans,
        buildNumber: testBuildNumber,
        platform: testPlatform,
      );
      final bytes = Base45.decode(encoded);

      // Magic: 2 bytes
      // Build Number: 4 bytes
      // Platform: 1 byte
      // Header: 2 bytes (version + planCount)
      // Plan 1: 5 (header) + 9*2 (stages) + 1 (nameLength) = 24 bytes
      // Plan 2: 5 (header) + 9*3 (stages) + 1 (nameLength) = 33 bytes
      // Footer: 2 bytes
      // Total: 2 + 4 + 1 + 2 + 24 + 33 + 2 = 68 bytes
      expect(bytes.length, 68);
    });

    test('multi-plan binary size with names', () {
      // 2 plans with names
      final plans = [
        StagePlanData(
          routeId: 1,
          stages: [
            StageData(
              date: DateTime(2024),
              startCityId: 10,
              endCityId: 20,
            ),
          ],
          name: 'ABC', // 3 bytes
        ),
        StagePlanData(
          routeId: 2,
          stages: [
            StageData(
              date: DateTime(2024, 2),
              startCityId: 30,
              endCityId: 40,
            ),
          ],
          name: 'XYZ12', // 5 bytes
        ),
      ];

      final encoded = StagePlanCodec.encodeMultiple(
        plans,
        buildNumber: testBuildNumber,
        platform: testPlatform,
      );
      final bytes = Base45.decode(encoded);

      // Magic: 2 bytes
      // Build Number: 4 bytes
      // Platform: 1 byte
      // Header: 2 bytes (version + planCount)
      // Plan 1: 5 (header) + 9*1 (stages) + 1 (nameLength) + 3 (name) = 18 bytes
      // Plan 2: 5 (header) + 9*1 (stages) + 1 (nameLength) + 5 (name) = 20 bytes
      // Footer: 2 bytes
      // Total: 2 + 4 + 1 + 2 + 18 + 20 + 2 = 49 bytes
      expect(bytes.length, 49);
    });

    test('encoded data starts with magic, build number, and platform', () {
      final plan = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024),
            startCityId: 10,
            endCityId: 20,
          ),
        ],
      );

      final encoded = StagePlanCodec.encode(
        plan,
        buildNumber: 123456,
        platform: QrPlatform.ios,
      );
      final bytes = Base45.decode(encoded);

      // Magic number "CN" = 0x43 0x4E
      expect(bytes[0], 0x43);
      expect(bytes[1], 0x4E);
      // Build number 123456 as uint32 LE
      expect(bytes[2], 0x40); // 123456 & 0xFF
      expect(bytes[3], 0xE2); // (123456 >> 8) & 0xFF
      expect(bytes[4], 0x01); // (123456 >> 16) & 0xFF
      expect(bytes[5], 0x00); // (123456 >> 24) & 0xFF
      // Platform iOS = 2
      expect(bytes[6], 2);
    });

    test('throws on non-Camino Ninja QR code', () {
      // Create a valid-looking but non-Camino Ninja encoded data
      final fakeData = Uint8List.fromList([
        0x41, 0x42, // "AB" instead of "CN"
        0x40, 0xE2, 0x01, 0x00, // fake build number (uint32)
        0x01, // fake platform
        0x02, // version 2
        0x01, // 1 plan
        0x01, 0x00, // routeId = 1
        0x01, // stageCount = 1
        0x00, 0x00, // startDate
        0x00, 0x0A, 0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, // stage record
      ]);
      // Add valid CRC for the fake data
      final crc = Crc16Ccitt.compute(fakeData);
      final withCrc = Uint8List(fakeData.length + 2);
      withCrc.setAll(0, fakeData);
      final buffer = ByteData.view(withCrc.buffer);
      buffer.setUint16(fakeData.length, crc, Endian.little);
      
      final encoded = Base45.encode(withCrc);

      expect(
        () => StagePlanCodec.decode(encoded),
        throwsA(
          isA<CodecException>().having(
            (e) => e.message,
            'message',
            'Not a valid Camino Ninja QR code',
          ),
        ),
      );
    });

    test('DecodeResult.isMultiplePlans returns correct value', () {
      // Single plan
      final singlePlan = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024),
            startCityId: 10,
            endCityId: 20,
          ),
        ],
      );
      final singleEncoded = StagePlanCodec.encode(
        singlePlan,
        buildNumber: testBuildNumber,
        platform: testPlatform,
      );
      final singleResult = StagePlanCodec.decode(singleEncoded);
      expect(singleResult.isMultiplePlans, isFalse);

      // Multiple plans
      final multiplePlans = [
        singlePlan,
        StagePlanData(
          routeId: 2,
          stages: [
            StageData(
              date: DateTime(2024, 2),
              startCityId: 30,
              endCityId: 40,
            ),
          ],
        ),
      ];
      final multiEncoded = StagePlanCodec.encodeMultiple(
        multiplePlans,
        buildNumber: testBuildNumber,
        platform: testPlatform,
      );
      final multiResult = StagePlanCodec.decode(multiEncoded);
      expect(multiResult.isMultiplePlans, isTrue);
    });

    test('unknown platform value falls back to QrPlatform.unknown', () {
      // Create valid data with unknown platform value (99)
      final plan = StagePlanData(
        routeId: 1,
        stages: [
          StageData(
            date: DateTime(2024),
            startCityId: 10,
            endCityId: 20,
          ),
        ],
      );
      final encoded = StagePlanCodec.encode(
        plan,
        buildNumber: testBuildNumber,
        platform: testPlatform,
      );
      final bytes = Base45.decode(encoded);

      // Change platform byte (at index 6) to invalid value and fix CRC
      bytes[6] = 99;
      final dataBytes = Uint8List.view(bytes.buffer, 0, bytes.length - 2);
      final newCrc = Crc16Ccitt.compute(dataBytes);
      final buffer = ByteData.view(bytes.buffer);
      buffer.setUint16(bytes.length - 2, newCrc, Endian.little);

      final modified = Base45.encode(bytes);
      final result = StagePlanCodec.decode(modified);

      expect(result.platform, QrPlatform.unknown);
    });

    test('QrPlatform.fromValue handles all valid values', () {
      expect(QrPlatform.fromValue(0), QrPlatform.unknown);
      expect(QrPlatform.fromValue(1), QrPlatform.android);
      expect(QrPlatform.fromValue(2), QrPlatform.ios);
      expect(QrPlatform.fromValue(255), QrPlatform.unknown); // Invalid falls back
    });
  });

}

