import 'package:camino_ninja_flutter/tabs/plan/widgets/plan_type_choice_sheet.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/plan_type_visibility.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

void main() {
  group('PlanTypeVisibility.isVisible', () {
    group('singleRoute', () {
      for (final flavor in Flavor.values) {
        test('always visible on $flavor regardless of flags', () {
          for (final customTrail in const [true, false]) {
            for (final journey in const [true, false]) {
              expect(
                PlanTypeVisibility.isVisible(
                  PlanType.singleRoute,
                  flavor: flavor,
                  customTrailEnabled: customTrail,
                  journeyPlannerEnabled: journey,
                ),
                isTrue,
                reason: 'flavor=$flavor customTrail=$customTrail '
                    'journey=$journey',
              );
            }
          }
        });
      }
    });

    group('customTrail', () {
      test('visible on development regardless of flag', () {
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.customTrail,
            flavor: Flavor.development,
            customTrailEnabled: false,
            journeyPlannerEnabled: false,
          ),
          isTrue,
        );
      });

      test('visible on staging regardless of flag', () {
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.customTrail,
            flavor: Flavor.staging,
            customTrailEnabled: false,
            journeyPlannerEnabled: false,
          ),
          isTrue,
        );
      });

      test('visible on production when customTrailEnabled is true', () {
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.customTrail,
            flavor: Flavor.production,
            customTrailEnabled: true,
            journeyPlannerEnabled: false,
          ),
          isTrue,
        );
      });

      test('hidden on production when customTrailEnabled is false', () {
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.customTrail,
            flavor: Flavor.production,
            customTrailEnabled: false,
            journeyPlannerEnabled: true,
          ),
          isFalse,
        );
      });

      test('production visibility independent of journey flag', () {
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.customTrail,
            flavor: Flavor.production,
            customTrailEnabled: true,
            journeyPlannerEnabled: true,
          ),
          isTrue,
        );
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.customTrail,
            flavor: Flavor.production,
            customTrailEnabled: true,
            journeyPlannerEnabled: false,
          ),
          isTrue,
        );
      });
    });

    group('journey', () {
      test('visible on development regardless of flag', () {
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.journey,
            flavor: Flavor.development,
            customTrailEnabled: false,
            journeyPlannerEnabled: false,
          ),
          isTrue,
        );
      });

      test('visible on staging regardless of flag', () {
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.journey,
            flavor: Flavor.staging,
            customTrailEnabled: false,
            journeyPlannerEnabled: false,
          ),
          isTrue,
        );
      });

      test('visible on production when journeyPlannerEnabled is true', () {
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.journey,
            flavor: Flavor.production,
            customTrailEnabled: false,
            journeyPlannerEnabled: true,
          ),
          isTrue,
        );
      });

      test('hidden on production when journeyPlannerEnabled is false', () {
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.journey,
            flavor: Flavor.production,
            customTrailEnabled: true,
            journeyPlannerEnabled: false,
          ),
          isFalse,
        );
      });

      test('production visibility independent of customTrail flag', () {
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.journey,
            flavor: Flavor.production,
            customTrailEnabled: true,
            journeyPlannerEnabled: true,
          ),
          isTrue,
        );
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.journey,
            flavor: Flavor.production,
            customTrailEnabled: false,
            journeyPlannerEnabled: true,
          ),
          isTrue,
        );
      });
    });

    group('production with both flags off', () {
      test('only singleRoute is visible', () {
        const flavor = Flavor.production;
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.singleRoute,
            flavor: flavor,
            customTrailEnabled: false,
            journeyPlannerEnabled: false,
          ),
          isTrue,
        );
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.customTrail,
            flavor: flavor,
            customTrailEnabled: false,
            journeyPlannerEnabled: false,
          ),
          isFalse,
        );
        expect(
          PlanTypeVisibility.isVisible(
            PlanType.journey,
            flavor: flavor,
            customTrailEnabled: false,
            journeyPlannerEnabled: false,
          ),
          isFalse,
        );
      });
    });
  });

  group('PlanTypeVisibility.visibleTypes', () {
    test('dev flavor returns all three types', () {
      expect(
        PlanTypeVisibility.visibleTypes(
          flavor: Flavor.development,
          customTrailEnabled: false,
          journeyPlannerEnabled: false,
        ),
        equals(PlanType.values.toSet()),
      );
    });

    test('staging flavor returns all three types', () {
      expect(
        PlanTypeVisibility.visibleTypes(
          flavor: Flavor.staging,
          customTrailEnabled: false,
          journeyPlannerEnabled: false,
        ),
        equals(PlanType.values.toSet()),
      );
    });

    test('production with both flags off returns only singleRoute', () {
      expect(
        PlanTypeVisibility.visibleTypes(
          flavor: Flavor.production,
          customTrailEnabled: false,
          journeyPlannerEnabled: false,
        ),
        equals({PlanType.singleRoute}),
      );
    });

    test(
      'production with customTrail on returns singleRoute + customTrail',
      () {
        expect(
          PlanTypeVisibility.visibleTypes(
            flavor: Flavor.production,
            customTrailEnabled: true,
            journeyPlannerEnabled: false,
          ),
          equals({PlanType.singleRoute, PlanType.customTrail}),
        );
      },
    );

    test('production with journey on returns singleRoute + journey', () {
      expect(
        PlanTypeVisibility.visibleTypes(
          flavor: Flavor.production,
          customTrailEnabled: false,
          journeyPlannerEnabled: true,
        ),
        equals({PlanType.singleRoute, PlanType.journey}),
      );
    });

    test('production with both flags on returns all three types', () {
      expect(
        PlanTypeVisibility.visibleTypes(
          flavor: Flavor.production,
          customTrailEnabled: true,
          journeyPlannerEnabled: true,
        ),
        equals(PlanType.values.toSet()),
      );
    });
  });
}
