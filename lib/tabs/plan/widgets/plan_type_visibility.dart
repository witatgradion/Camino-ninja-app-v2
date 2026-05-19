import 'package:camino_ninja_flutter/tabs/plan/widgets/plan_type_choice_sheet.dart';
import 'package:storage/storage.dart';

abstract final class PlanTypeVisibility {
  static bool isVisible(
    PlanType type, {
    required Flavor flavor,
    required bool customTrailEnabled,
    required bool journeyPlannerEnabled,
  }) {
    if (type == PlanType.singleRoute) {
      return true;
    }
    if (flavor != Flavor.production) {
      return true;
    }
    return switch (type) {
      PlanType.singleRoute => true,
      PlanType.customTrail => customTrailEnabled,
      PlanType.journey => journeyPlannerEnabled,
    };
  }

  static Set<PlanType> visibleTypes({
    required Flavor flavor,
    required bool customTrailEnabled,
    required bool journeyPlannerEnabled,
  }) {
    return PlanType.values
        .where(
          (type) => isVisible(
            type,
            flavor: flavor,
            customTrailEnabled: customTrailEnabled,
            journeyPlannerEnabled: journeyPlannerEnabled,
          ),
        )
        .toSet();
  }
}
