import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// The types of plans a user can create.
enum PlanType {
  singleRoute,
  customTrail,
  journey,
}

/// Snake-case identifier used as the `plan_type` property in
/// plan-creation analytics events.
extension PlanTypeAnalytics on PlanType {
  String get analyticsValue {
    switch (this) {
      case PlanType.singleRoute:
        return 'single_route';
      case PlanType.customTrail:
        return 'custom_trail';
      case PlanType.journey:
        return 'journey';
    }
  }
}

/// Shows a modal bottom sheet letting the user choose between
/// creating a single-route plan or a custom multi-route trail.
///
/// [visibleTypes] controls which options render. The set must contain
/// at least [PlanType.singleRoute] (guaranteed by the visibility resolver).
///
/// Returns the selected [PlanType], or null if dismissed.
Future<PlanType?> showPlanTypeChoiceSheet(
  BuildContext context, {
  required Set<PlanType> visibleTypes,
}) {
  GetIt.instance<IAnalyticsService>().track(
    PlanTypeChoiceShownEvent(),
  );
  return showModalBottomSheet<PlanType>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) => PlanTypeChoiceContent(visibleTypes: visibleTypes),
  );
}

@visibleForTesting
class PlanTypeChoiceContent extends StatelessWidget {
  const PlanTypeChoiceContent({required this.visibleTypes, super.key});

  final Set<PlanType> visibleTypes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    void selectAndPop(PlanType type) {
      GetIt.instance<IAnalyticsService>().track(
        PlanTypeChoiceSelectedEvent(planType: type.analyticsValue),
      );
      Navigator.of(context).pop(type);
    }

    final options = <Widget>[
      if (visibleTypes.contains(PlanType.singleRoute))
        _PlanTypeOption(
          icon: Icons.route_rounded,
          // TODO(l10n): single route title
          title: 'Single Route',
          // TODO(l10n): single route description
          subtitle: 'Plan stages along one Camino route',
          onTap: () => selectAndPop(PlanType.singleRoute),
        ),
      if (visibleTypes.contains(PlanType.customTrail))
        _PlanTypeOption(
          icon: Icons.call_split_rounded,
          // TODO(l10n): custom trail title
          title: 'Custom Trail',
          // TODO(l10n): custom trail description
          subtitle: 'Build a multi-route trail '
              'with junctions',
          badge: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.yellow300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Beta',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          onTap: () => selectAndPop(PlanType.customTrail),
        ),
      if (visibleTypes.contains(PlanType.journey))
        _PlanTypeOption(
          icon: Icons.explore_rounded,
          // TODO(l10n): journey planner title
          title: 'Plan a Journey',
          // TODO(l10n): journey planner description
          subtitle: 'Pick a start and destination',
          onTap: () => selectAndPop(PlanType.journey),
        ),
    ];

    final interspersed = <Widget>[];
    for (var i = 0; i < options.length; i++) {
      if (i > 0) interspersed.add(const SizedBox(height: 8));
      interspersed.add(options[i]);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withAlpha(64),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              // TODO(l10n): choose plan type header
              'Choose plan type',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...interspersed,
          ],
        ),
      ),
    );
  }
}

class _PlanTypeOption extends StatelessWidget {
  const _PlanTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isDark ? AppColors.gray800 : AppColors.primary95,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary40.withAlpha(64)
                      : AppColors.primary80.withAlpha(64),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isDark ? AppColors.primary80 : AppColors.primary40,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.primary80
                                : AppColors.primary20,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          badge!,
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
