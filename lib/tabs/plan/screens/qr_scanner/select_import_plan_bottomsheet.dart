import 'dart:async';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/stage_card.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/route_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';

Future<StagePlanModel?> showSelectImportPlanBottomsheet(
  BuildContext context, {
  required StagePlanModel plan,
}) {
  return showModalBottomSheet<StagePlanModel?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.barrierColor,
    builder: (context) => SelectImportPlanBottomsheet(
      plan: plan,
    ),
  );
}

class SelectImportPlanBottomsheet extends StatefulWidget {
  const SelectImportPlanBottomsheet({
    required this.plan,
    super.key,
  });
  final StagePlanModel plan;

  @override
  State<SelectImportPlanBottomsheet> createState() =>
      _SelectImportPlanBottomsheetState();
}

class _SelectImportPlanBottomsheetState
    extends State<SelectImportPlanBottomsheet> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final stages = widget.plan.stages;
    final totalStages = stages.length;
    final stagesText =
        '$totalStages ${totalStages <= 1 ? AppLocalizations.of(context).stageSingular : AppLocalizations.of(context).stagePlural}';
    final startDate = widget.plan.computeStageDate(0);
    final endDate = widget.plan.planEndDate;
    final maxHeight = MediaQuery.of(context).size.height * 4 / 5;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => context.pop(),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.gray800 : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button - fixed
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: SvgPicture.asset(
                            'assets/ic_close.svg',
                            color: isDarkMode
                                ? AppColors.primary80
                                : AppColors.primary40,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title - fixed
                  Text(
                    AppLocalizations.of(context).importingPlans,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Plan card - fixed
                  _buildPlanCard(
                    isDarkMode: isDarkMode,
                    stagesText: stagesText,
                    startDate: startDate,
                    endDate: endDate,
                  ),
                  const SizedBox(height: 16),
                  // Stage list - scrollable, takes remaining space
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: stages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: StageCard(
                            backgroundColor: isDarkMode
                                ? AppColors.gray900
                                : AppColors.gray200,
                            stage: stages[index],
                            index: index,
                            showEditButton: false,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Import button - fixed at bottom
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: CustomButton(
                        text: AppLocalizations.of(context).import,
                        onTap: _onImport,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required bool isDarkMode,
    required String stagesText,
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gray900 : AppColors.gray200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 24),
          SvgPicture.asset(
            'assets/ic_shellfish.svg',
            width: 20,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RouteNameText(
                  routeName: widget.plan.route.routeName,
                  routeSubName: widget.plan.route.routeSubName ?? '',
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.primary80
                            : AppColors.primary40,
                      ),
                ),
                Text(
                  stagesText,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                if (startDate != null)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: startDate.toHumanReadableDate(),
                          style:
                              context.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        WidgetSpan(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 2,
                            ),
                            child: SvgPicture.asset(
                              'assets/ic_arrow_left_outline.svg',
                              width: 15,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: endDate.toHumanReadableDate(),
                          style:
                              context.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onImport() {
    context.pop(widget.plan);
  }
}
