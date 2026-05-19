import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/day_gaps_widget.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/stage_card.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/stages_not_connected_card.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:camino_ninja_flutter/widgets/route_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class ExpandablePlanCard extends StatefulWidget {
  const ExpandablePlanCard({
    required this.plan,
    required this.onViewPlanTap,
    required this.onAddStageTap,
    required this.onInsertStageBetweenTap,
    required this.onEditStageTap,
    required this.onToggleExpandTap,
    required this.onStageTap,
    required this.onDeletePlanTap,
    required this.onDeleteStageTap,
    required this.onStageNoteTap,
    this.multiRouteMap,
    super.key,
  });
  final StagePlanModel plan;
  final VoidCallback onViewPlanTap;
  final VoidCallback onAddStageTap;
  final void Function(int afterStageIndex) onInsertStageBetweenTap;
  final void Function(StageModel stage) onEditStageTap;
  final void Function(StageModel stage) onStageTap;
  final void Function(bool) onToggleExpandTap;
  final VoidCallback onDeletePlanTap;
  final void Function(StageModel stage) onDeleteStageTap;
  final void Function(StageModel stage) onStageNoteTap;

  /// Route map for multi-route plans. Null for single-route.
  final Map<int, RouteEntity>? multiRouteMap;

  @override
  State<ExpandablePlanCard> createState() => _ExpandablePlanCardState();
}

class _ExpandablePlanCardState extends State<ExpandablePlanCard>
    with TickerProviderStateMixin {
  late SlidableController _slidableController;
  late AnimationController _controller;
  late CurvedAnimation _animation;
  final Map<int, SlidableController> _stageSlidableControllers = {};

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _syncAnimationWithExpandedState();
  }

  SlidableController _getSlidableController(int stageId) {
    return _stageSlidableControllers.putIfAbsent(
      stageId,
      () => SlidableController(this),
    );
  }

  @override
  void dispose() {
    _slidableController.dispose();
    for (final controller in _stageSlidableControllers.values) {
      controller.dispose();
    }
    _stageSlidableControllers.clear();
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ExpandablePlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentStageIds =
        widget.plan.stages.map((s) => s.id).whereType<int>().toSet();
    _cleanupUnusedControllers(currentStageIds);

    if (oldWidget.plan.isExpanded != widget.plan.isExpanded) {
      if (widget.plan.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _cleanupUnusedControllers(Set<int> currentStageIds) {
    final keysToRemove = _stageSlidableControllers.keys
        .where((key) => !currentStageIds.contains(key))
        .toList();
    for (final key in keysToRemove) {
      final controller = _stageSlidableControllers.remove(key);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller?.dispose();
      });
    }
  }

  void _syncAnimationWithExpandedState() {
    _controller.value = widget.plan.isExpanded ? 1.0 : 0.0;
  }

  void _toggleExpand() {
    _slidableController.close();
    for (final controller in _stageSlidableControllers.values) {
      controller.close();
    }
    final isExpanded = !widget.plan.isExpanded;
    widget.onToggleExpandTap(isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            IgnorePointer(
              child: Opacity(
                opacity: 0,
                child: _buildMainPlanCard(),
              ),
            ),
            RepaintBoundary(child: _buildStagesList()),
          ],
        ),
        RepaintBoundary(child: _buildPlanCardWithShadow()),
      ],
    );
  }

  Widget _buildMainPlanCard() {
    final stages = widget.plan.stages;
    final totalStages = stages.length;
    final stagesText =
        '$totalStages ${totalStages <= 1 ? AppLocalizations.of(context).stageSingular : AppLocalizations.of(context).stagePlural}';
    final startDate = widget.plan.computeStageDate(0);
    final endDate = widget.plan.planEndDate;
    final mainColor =
        context.isDarkMode ? AppColors.primary80 : AppColors.primary40;

    return Slidable(
      key: ValueKey('plan_${widget.plan.id}'),
      controller: _slidableController,
      groupTag: 'plan_slidables',
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.2,
        children: [
          CustomSlidableAction(
            onPressed: (context) {
              widget.onDeletePlanTap();
            },
            backgroundColor: const Color(0xFFE02424),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: SvgPicture.asset(
                'assets/ic_trash_outline.svg',
                width: 32,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: _toggleExpand,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.isDarkMode ? AppColors.gray800 : AppColors.gray200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.plan.isImported) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.yellow300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppLocalizations.of(context).imported,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (widget.plan.planUuid != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary40,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppLocalizations.of(context).syncedCopy,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/ic_shellfish.svg',
                          width: 20,
                          color:
                              context.isDarkMode ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.plan.name != null) ...[
                                Text(
                                  widget.plan.name!,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: mainColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.multiRouteMap != null)
                                  _MultiRouteBreadcrumb(
                                    routeMap: widget.multiRouteMap!,
                                    plan: widget.plan,
                                    expanded: false,
                                  )
                                else ...[
                                  Text(
                                    widget.plan.route.routeName,
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: context.isDarkMode
                                          ? AppColors.primary80
                                          : AppColors.primary40,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.plan.route.routeSubName
                                          ?.isNotEmpty ??
                                      false)
                                    RouteNameText(
                                      routeSubName:
                                          widget.plan.route.routeSubName ?? '',
                                      maxLines: 1,
                                      textStyle:
                                          context.textTheme.bodySmall?.copyWith(
                                        color: context.isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                ],
                              ] else ...[
                                if (widget.multiRouteMap != null) ...[
                                  _MultiRouteBreadcrumb(
                                    routeMap: widget.multiRouteMap!,
                                    plan: widget.plan,
                                    useBoldStyle: true,
                                    expanded: false,
                                  ),
                                ] else ...[
                                  Text(
                                    widget.plan.route.routeName,
                                    style:
                                        context.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: context.isDarkMode
                                          ? AppColors.primary80
                                          : AppColors.primary40,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.plan.route.routeSubName
                                          ?.isNotEmpty ??
                                      false)
                                    RouteNameText(
                                      routeSubName:
                                          widget.plan.route.routeSubName ?? '',
                                      maxLines: 2,
                                      textStyle: context.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: mainColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ],
                              const SizedBox(height: 8),
                              Text(
                                stagesText,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              if (startDate != null &&
                                  endDate != null)
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
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      WidgetSpan(
                                        child: Container(
                                          margin:
                                              const EdgeInsets
                                                  .symmetric(
                                            horizontal: 2,
                                          ),
                                          child: SvgPicture.asset(
                                            'assets/ic_arrow_left_outline.svg',
                                            width: 15,
                                            color: context.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                        text: endDate
                                            .toHumanReadableDate(),
                                        style: context
                                            .textTheme.bodySmall
                                            ?.copyWith(
                                          color: context.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              CustomOutlineButton(
                                height: 32,
                                text: AppLocalizations.of(context).viewPlan,
                                onTap: widget.onViewPlanTap,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: widget.plan.isExpanded ? 0.75 : 0.25,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: AnimatedScale(
                  scale: widget.plan.isExpanded ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutCubic,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: mainColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.chevron_right,
                      color: context.isDarkMode ? Colors.black : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCardWithShadow() {
    final spreadRadius = context.isDarkMode ? 24.0 : 2.0;
    final blurRadius = context.isDarkMode ? 24.0 : 12.0;
    final opacity = context.isDarkMode ? 0.4 : 0.2;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  (opacity * _animation.value).clamp(0.0, opacity),
                ),
                spreadRadius:
                    (spreadRadius * _animation.value).clamp(0.0, spreadRadius),
                blurRadius: blurRadius,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: _buildMainPlanCard(),
    );
  }

  Widget _buildStagesList() {
    return SizeTransition(
      sizeFactor: _animation,
      axisAlignment: -1,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            ..._buildStagesWithGaps(),
            Row(
              children: [
                const SizedBox(width: 52),
                Expanded(
                  child: CustomOutlineButton(
                    height: 32,
                    text: AppLocalizations.of(context).addStage,
                    prefixIcon: (color) => SvgPicture.asset(
                      'assets/ic_plus_rounded.svg',
                      color: color,
                      width: 18,
                    ),
                    onTap: () {
                      _slidableController.close();
                      for (final controller
                          in _stageSlidableControllers.values) {
                        controller.close();
                      }
                      widget.onAddStageTap();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStagesWithGaps() {
    final stages = widget.plan.stages;
    final widgets = <Widget>[];
    final routeMap = widget.multiRouteMap;
    var junctionIndex = 0;

    for (var i = 0; i < stages.length; i++) {
      widgets.add(_buildStageCardWithAnimation(i, stages[i]));

      if (i < stages.length - 1) {
        final stage = stages[i];
        final nextStage = stages[i + 1];

        if (stage.daysToStay > 1) {
          widgets.add(
            DayGapsWidget(daysDifference: stage.daysToStay),
          );
        }

        // City-junction marker between consecutive stages
        // that belong to different routes.
        if (routeMap != null && stage.routeId != nextStage.routeId) {
          final nextRoute = routeMap[nextStage.routeId];
          if (nextRoute != null) {
            widgets.add(
              _StageJunctionDivider(
                nextRoute: nextRoute,
                junctionIndex: junctionIndex,
              ),
            );
            junctionIndex++;
          }
        }

        // Check if stages are disconnected
        if (stage.endCity?.id != nextStage.startCity?.id) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(
                left: 52,
                bottom: 8,
              ),
              child: StagesNotConnectedCard(
                onTap: () => widget.onInsertStageBetweenTap(i),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  Widget _buildStageCardWithAnimation(int index, StageModel stage) {
    return _buildStageCard(index, stage);
  }

  Widget _buildStageCard(int index, StageModel stage) {
    final stageId = stage.id ?? index;
    final controller = _getSlidableController(stageId);
    final routeMap = widget.multiRouteMap;
    final route = routeMap?[stage.routeId];
    final routeColor = route != null
        ? parseRouteColor(route, isDark: context.isDarkMode)
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        key: ValueKey('stage_${stage.id}'),
        controller: controller,
        groupTag: 'plan_slidables',
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.2,
          children: [
            CustomSlidableAction(
              onPressed: (context) {
                widget.onDeleteStageTap(stage);
              },
              backgroundColor: const Color(0xFFE02424),
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: SvgPicture.asset(
                  'assets/ic_trash_outline.svg',
                  width: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        child: StageCard(
          onTap: () {
            controller.close();
            widget.onStageTap(stage);
          },
          stage: stage,
          index: index,
          routeColor: routeColor,
          computedDate: widget.plan.computeStageDate(index),
          onEditTap: () {
            controller.close();
            widget.onEditStageTap(stage);
          },
          onNoteTap: () {
            controller.close();
            widget.onStageNoteTap(stage);
          },
        ),
      ),
    );
  }
}

/// Sample Camino-relevant city names used as placeholders
/// when the real junction city isn't available from the
/// plan data. Picked deterministically by index so the
/// same plan shows the same names across rebuilds.
const List<String> _fakeJunctionCities = [
  'Caminha',
  'Padrãoda Legua',
  'Pamplona',
  'Burgos',
  'León',
  'Astorga',
  'Ponferrada',
  'Sarria',
  'Portomarín',
  'Palas de Rei',
];

String _placeholderJunctionName(int index) {
  return _fakeJunctionCities[index % _fakeJunctionCities.length];
}

/// Vertical breadcrumb of route names with a coloured
/// pill-stripe per route. Collapsed: just the routes.
/// Expanded: also shows "City junction: [name]" between
/// each pair of routes, with the city name in the next
/// route's colour so users see which route they transfer
/// into at that junction.
class _MultiRouteBreadcrumb extends StatelessWidget {
  const _MultiRouteBreadcrumb({
    required this.routeMap,
    required this.plan,
    this.useBoldStyle = false,
    this.expanded = false,
  });

  final Map<int, RouteEntity> routeMap;
  final StagePlanModel plan;
  final bool useBoldStyle;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    // Build ordered route list by first appearance in stages
    final orderedRouteIds = <int>[];
    for (final stage in plan.stages) {
      if (!orderedRouteIds.contains(stage.routeId)) {
        orderedRouteIds.add(stage.routeId);
      }
    }

    final isDark = context.isDarkMode;
    final mutedColor = isDark ? Colors.white70 : Colors.black54;
    final boldColor = isDark ? AppColors.primary80 : AppColors.primary40;
    final nameStyle = useBoldStyle
        ? context.textTheme.bodyMedium?.copyWith(
            color: boldColor,
            fontWeight: FontWeight.w700,
          )
        : context.textTheme.bodySmall?.copyWith(
            color: boldColor,
            fontWeight: FontWeight.w600,
          );
    final junctionLabelStyle = context.textTheme.bodySmall?.copyWith(
      color: mutedColor,
    );

    final routes = orderedRouteIds
        .map((id) => routeMap[id])
        .whereType<RouteEntity>()
        .toList();
    if (routes.isEmpty) return const SizedBox.shrink();

    Widget buildRouteRow(RouteEntity route) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: parseRouteColor(route, isDark: isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              route.routeName,
              style: nameStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    Widget buildJunctionRow(int junctionIndex, RouteEntity nextRoute) {
      final nextColor = parseRouteColor(nextRoute, isDark: isDark);
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 0, 6),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                // TODO(l10n): city junction label
                text: 'City junction: ',
                style: junctionLabelStyle?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              TextSpan(
                text: _placeholderJunctionName(junctionIndex),
                style: junctionLabelStyle?.copyWith(color: nextColor),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildRouteRow(routes.first),
          for (var i = 1; i < routes.length; i++) ...[
            if (expanded) buildJunctionRow(i - 1, routes[i]),
            Padding(
              padding: EdgeInsets.only(top: expanded ? 0 : 4),
              child: buildRouteRow(routes[i]),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Continues on [Route]" banner inserted between two
/// consecutive stage cards on different routes. Mirrors
/// the junction divider on Plan Detail: pill stripe in
/// the next route's color, colored dot, and the route
/// name in bold.
class _StageJunctionDivider extends StatelessWidget {
  const _StageJunctionDivider({
    required this.nextRoute,
    required this.junctionIndex,
  });

  final RouteEntity nextRoute;
  final int junctionIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final routeColor = parseRouteColor(nextRoute, isDark: isDark);

    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 0, 0, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: isDark ? AppColors.gray800 : AppColors.gray100,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: routeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      12, 10, 12, 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  // TODO(l10n): localize
                                  text: 'Continues on ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white70
                                            : AppColors.gray500,
                                      ),
                                ),
                                TextSpan(
                                  text: nextRoute.routeName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.gray800,
                                      ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
