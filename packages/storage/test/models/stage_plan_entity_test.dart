import 'package:flutter_test/flutter_test.dart';
import 'package:storage/src/models/stage_plan_entity.dart';

void main() {
  StagePlanEntity buildBase() => StagePlanEntity(
        id: 1,
        routeId: 100,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 2),
        isImported: true,
        name: 'Camino Frances',
        uuid: 'plan-uuid',
        planUuid: 'plan-uuid-2',
        deletedAt: '2025-06-01T00:00:00Z',
        startingDate: '2025-06-15',
      );

  group('StagePlanEntity.copyWith', () {
    test('preserves all fields when called with no arguments', () {
      final original = buildBase();
      final copy = original.copyWith();

      expect(copy, equals(original));
      expect(copy.updatedAt, equals(original.updatedAt));
      expect(copy.name, equals(original.name));
      expect(copy.uuid, equals(original.uuid));
      expect(copy.planUuid, equals(original.planUuid));
      expect(copy.deletedAt, equals(original.deletedAt));
      expect(copy.startingDate, equals(original.startingDate));
    });

    test('overrides only the provided non-null fields', () {
      final original = buildBase();
      final copy = original.copyWith(
        name: 'Camino Portugues',
        isImported: false,
      );

      expect(copy.name, equals('Camino Portugues'));
      expect(copy.isImported, isFalse);
      expect(copy.uuid, equals(original.uuid));
      expect(copy.deletedAt, equals(original.deletedAt));
      expect(copy.startingDate, equals(original.startingDate));
      // `updatedAt` is preserved when not passed.
      expect(copy.updatedAt, equals(original.updatedAt));
    });

    test('updatedAt: preserved when omitted, nullified via sentinel', () {
      final original = buildBase();

      // Omitting `updatedAt` keeps the original value (sentinel
      // distinguishes "not provided" from "explicit null").
      final omitted = original.copyWith(name: 'Other');
      expect(omitted.updatedAt, equals(original.updatedAt));

      // Passing `updatedAt: null` explicitly nullifies it.
      final nullified = original.copyWith(updatedAt: null);
      expect(nullified.updatedAt, isNull);
    });

    test('explicit nullification works on every nullable field', () {
      final original = buildBase();
      final copy = original.copyWith(
        updatedAt: null,
        name: null,
        uuid: null,
        planUuid: null,
        deletedAt: null,
        startingDate: null,
      );

      expect(copy.updatedAt, isNull);
      expect(copy.name, isNull);
      expect(copy.uuid, isNull);
      expect(copy.planUuid, isNull);
      expect(copy.deletedAt, isNull);
      expect(copy.startingDate, isNull);

      // Required fields untouched.
      expect(copy.id, equals(original.id));
      expect(copy.routeId, equals(original.routeId));
      expect(copy.createdAt, equals(original.createdAt));
      expect(copy.isImported, equals(original.isImported));
    });

    test('equality holds for unchanged copy', () {
      final a = buildBase();
      final b = a.copyWith();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
