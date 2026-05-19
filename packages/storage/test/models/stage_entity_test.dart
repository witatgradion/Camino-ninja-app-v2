import 'package:flutter_test/flutter_test.dart';
import 'package:storage/src/models/stage_entity.dart';

void main() {
  StageEntity buildBase() => StageEntity(
        id: 1,
        stagePlanId: 10,
        routeId: 100,
        stageUuid: 'uuid-1',
        date: DateTime(2025, 6, 1),
        startCityId: 5,
        endCityId: 6,
        startAlbergueId: 50,
        endAlbergueId: 60,
        customStartNotes: 'start',
        customEndNotes: 'end',
        stageNotes: 'notes',
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 2),
        stageNumber: 3,
        daysToStay: 2,
      );

  group('StageEntity.copyWith', () {
    test('preserves all fields when called with no arguments', () {
      final original = buildBase();
      final copy = original.copyWith();

      expect(copy, equals(original));
      expect(copy.id, equals(original.id));
      expect(copy.stagePlanId, equals(original.stagePlanId));
      expect(copy.routeId, equals(original.routeId));
      expect(copy.stageUuid, equals(original.stageUuid));
      expect(copy.date, equals(original.date));
      expect(copy.startCityId, equals(original.startCityId));
      expect(copy.endCityId, equals(original.endCityId));
      expect(copy.startAlbergueId, equals(original.startAlbergueId));
      expect(copy.endAlbergueId, equals(original.endAlbergueId));
      expect(copy.customStartNotes, equals(original.customStartNotes));
      expect(copy.customEndNotes, equals(original.customEndNotes));
      expect(copy.stageNotes, equals(original.stageNotes));
      expect(copy.createdAt, equals(original.createdAt));
      expect(copy.updatedAt, equals(original.updatedAt));
      expect(copy.stageNumber, equals(original.stageNumber));
      expect(copy.daysToStay, equals(original.daysToStay));
    });

    test('overrides only the provided non-null fields', () {
      final original = buildBase();
      final copy = original.copyWith(
        startCityId: 999,
        daysToStay: 7,
      );

      expect(copy.startCityId, equals(999));
      expect(copy.daysToStay, equals(7));
      // Everything else preserved.
      expect(copy.endCityId, equals(original.endCityId));
      expect(copy.stageUuid, equals(original.stageUuid));
      expect(copy.date, equals(original.date));
      expect(copy.startAlbergueId, equals(original.startAlbergueId));
    });

    test('explicit nullification works on every nullable field', () {
      final original = buildBase();
      final copy = original.copyWith(
        stageUuid: null,
        date: null,
        startAlbergueId: null,
        endAlbergueId: null,
        customStartNotes: null,
        customEndNotes: null,
        stageNotes: null,
        createdAt: null,
        updatedAt: null,
        stageNumber: null,
      );

      expect(copy.stageUuid, isNull);
      expect(copy.date, isNull);
      expect(copy.startAlbergueId, isNull);
      expect(copy.endAlbergueId, isNull);
      expect(copy.customStartNotes, isNull);
      expect(copy.customEndNotes, isNull);
      expect(copy.stageNotes, isNull);
      expect(copy.createdAt, isNull);
      expect(copy.updatedAt, isNull);
      expect(copy.stageNumber, isNull);

      // Required fields untouched.
      expect(copy.id, equals(original.id));
      expect(copy.stagePlanId, equals(original.stagePlanId));
      expect(copy.routeId, equals(original.routeId));
      expect(copy.startCityId, equals(original.startCityId));
      expect(copy.endCityId, equals(original.endCityId));
      expect(copy.daysToStay, equals(original.daysToStay));
    });

    test('equality holds for unchanged copy', () {
      final a = buildBase();
      final b = a.copyWith();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality after a single field change', () {
      final a = buildBase();
      final b = a.copyWith(startCityId: 999);
      expect(a, isNot(equals(b)));
    });
  });
}
