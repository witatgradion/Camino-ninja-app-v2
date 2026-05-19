import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/widgets/route_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

Future<StagePlanModel?> showPlanSelectionBottomsheet(
  BuildContext context, {
  required List<StagePlanModel> plans,
  StagePlanModel? selectedPlan,
}) {
  return showModalBottomSheet<StagePlanModel?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PlanSelectionBottomsheet(
      plans: plans,
      selectedPlan: selectedPlan,
    ),
  );
}

class PlanSelectionBottomsheet extends StatefulWidget {
  const PlanSelectionBottomsheet({
    required this.plans,
    this.selectedPlan,
    super.key,
  });

  final List<StagePlanModel> plans;
  final StagePlanModel? selectedPlan;

  @override
  State<PlanSelectionBottomsheet> createState() =>
      _PlanSelectionBottomsheetState();
}

class _PlanSelectionBottomsheetState extends State<PlanSelectionBottomsheet> {
  final _itemScrollController = ItemScrollController();

  int get _selectedIndex {
    final plan = widget.selectedPlan;
    if (plan == null) return 0;
    final index = widget.plans.indexWhere((p) => p.id == plan.id);
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textTheme = Theme.of(context).textTheme;
    final plans = widget.plans;
    final selectedPlan = widget.selectedPlan;

    return SafeArea(
      bottom: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: EdgeInsets.only(
          top: 16,
          left: 24,
          right: 24,
          bottom: context.getBottomPadding(context, additionalPadding: 24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: SvgPicture.asset(
                    'assets/ic_close.svg',
                    color: isDark ? AppColors.primary80 : AppColors.primary40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 16),
                Text(
                  AppLocalizations.of(context).selectPlan,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            Flexible(
              child: ScrollablePositionedList.builder(
                itemScrollController: _itemScrollController,
                initialScrollIndex: _selectedIndex,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];

                  final stages = plan.stages;
                  final totalStages = stages.length;
                  final stagesText =
                      '$totalStages ${totalStages <= 1 ? AppLocalizations.of(context).stageSingular : AppLocalizations.of(context).stagePlural}';
                  final startDate = plan.computeStageDate(0);
                  final endDate = plan.planEndDate;
                  final mainColor = context.isDarkMode
                      ? AppColors.primary80
                      : AppColors.primary40;
                  final isSelected = selectedPlan?.id == plan.id;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index > 0) const Divider(height: 1),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.pop(plan),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (plan.name != null) ...[
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                plan.name!,
                                                style: context
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: mainColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (_isPlanContainingToday(
                                                plan)) ...[
                                              const SizedBox(width: 8),
                                              _buildTodayIndicator(context),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          plan.route.routeName,
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                            color: context.isDarkMode
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (plan.route.routeSubName
                                                ?.isNotEmpty ==
                                            true)
                                          RouteNameText(
                                            routeSubName:
                                                plan.route.routeSubName ?? '',
                                            maxLines: 1,
                                            textStyle: context
                                                .textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: context.isDarkMode
                                                  ? AppColors.primary80
                                                  : AppColors.primary40,
                                            ),
                                          ),
                                      ] else ...[
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                plan.route.routeName,
                                                style: context
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: mainColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (_isPlanContainingToday(
                                                plan)) ...[
                                              const SizedBox(width: 8),
                                              _buildTodayIndicator(context),
                                            ],
                                          ],
                                        ),
                                        if (plan.route.routeSubName
                                                ?.isNotEmpty ==
                                            true)
                                          RouteNameText(
                                            routeSubName:
                                                plan.route.routeSubName ?? '',
                                            maxLines: 2,
                                            textStyle: context
                                                .textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: context.isDarkMode
                                                  ? AppColors.primary80
                                                  : AppColors.primary40,
                                            ),
                                          ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        stagesText,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                          color: context.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      if (startDate != null)
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: startDate
                                                    .toHumanReadableDate(),
                                                style: context
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: context.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 2,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    'assets/ic_arrow_left_outline.svg',
                                                    width: 15,
                                                    color:
                                                        context.isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                  ),
                                                ),
                                              ),
                                              if (endDate != null)
                                                TextSpan(
                                                  text: endDate
                                                      .toHumanReadableDate(),
                                                  style: context
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color:
                                                        context.isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  SvgPicture.asset(
                                    'assets/ic_check_circle.svg',
                                    width: 24,
                                    color: isDark
                                        ? AppColors.primary80
                                        : AppColors.primary40,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPlanContainingToday(StagePlanModel plan) {
    if (plan.stages.isEmpty) return false;
    final (startDate, endDate) = _planStartEndDates(plan);
    if (startDate == null || endDate == null) return false;
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return !today.isBefore(startDate) && !today.isAfter(endDate);
  }

  (DateTime?, DateTime?) _planStartEndDates(StagePlanModel plan) {
    if (plan.stages.isEmpty) return (null, null);
    final startDate = plan.computeStageDate(0);
    final endDate = plan.planEndDate;
    if (startDate == null || endDate == null) return (null, null);
    final start = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );
    return (start, end);
  }

  Widget _buildTodayIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.5,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.yellow300,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppLocalizations.of(context).today,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
