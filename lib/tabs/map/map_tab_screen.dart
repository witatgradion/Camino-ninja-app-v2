import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/map/cubit/map_tab_cubit.dart';
import 'package:camino_ninja_flutter/tabs/map/map_screen.dart';
import 'package:camino_ninja_flutter/tabs/map/widgets/embedded_stage_map.dart';
import 'package:camino_ninja_flutter/tabs/map/widgets/plan_selection_bottomsheet.dart';
import 'package:camino_ninja_flutter/tabs/plan/plan_screen.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

const double kMapModeBarHeight = 45;

class MapTabPageArguments {
  const MapTabPageArguments({
    this.routeArguments,
    this.initialMode,
  });
  final MapScreenArguments? routeArguments;
  final MapTabMode? initialMode;
}

class MapTabScreen extends StatefulWidget {
  const MapTabScreen({
    this.arguments,
    this.initialMode,
    super.key,
  });
  final MapScreenArguments? arguments;
  final MapTabMode? initialMode;

  @override
  State<MapTabScreen> createState() => _MapTabScreenState();
}

class _MapTabScreenState extends State<MapTabScreen> {
  late MapTabCubit _cubit;
  bool _wasActive = true;

  @override
  void initState() {
    super.initState();
    _cubit = MapTabCubit()..loadPlans();
    if (widget.initialMode != null) {
      _cubit.selectMode(widget.initialMode!);
    }
  }

  @override
  void didUpdateWidget(covariant MapTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMode != null) {
      _cubit.selectMode(widget.initialMode!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isActive = TickerMode.of(context);
    if (isActive && !_wasActive && _cubit.state.mode == MapTabMode.plan) {
      _cubit.loadPlans(shouldShowLoading: false);
    }
    _wasActive = isActive;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _MapTabView(arguments: widget.arguments),
    );
  }
}

class _MapTabView extends StatelessWidget {
  const _MapTabView({this.arguments});
  final MapScreenArguments? arguments;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return BlocBuilder<MapTabCubit, MapTabState>(
      builder: (context, state) {
        return Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: state.mode == MapTabMode.route
                  ? MapScreen(arguments: arguments)
                  : _PlanMapBody(state: state),
            ),
            Positioned(
                top: statusBarHeight,
                left: 0,
                right: 0,
                child: _MapModeBar(state: state)),
          ],
        );
      },
    );
  }
}

class _MapModeBar extends StatelessWidget {
  const _MapModeBar({required this.state});
  final MapTabState state;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      height: kMapModeBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral20 : AppColors.neutral95,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.neutral80 : AppColors.neutral40)
                  .withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: _ModeButton(
                label: AppLocalizations.of(context).route,
                isSelected: state.mode == MapTabMode.route,
                onTap: () {
                  context.read<MapTabCubit>().selectMode(MapTabMode.route);
                },
              ),
            ),
            Expanded(
              child: _ModeButton(
                label: AppLocalizations.of(context).plan,
                isSelected: state.mode == MapTabMode.plan,
                showDropdown: state.hasMultiplePlans,
                onTap: () => _onPlanTap(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPlanTap(BuildContext context, MapTabState state) {
    final cubit = context.read<MapTabCubit>();
    final wasAlreadyPlanMode = state.mode == MapTabMode.plan;

    if (!wasAlreadyPlanMode) {
      cubit.selectMode(MapTabMode.plan);
    }

    if (state.hasMultiplePlans) {
      _showPlanPicker(context, cubit, state);
    }
  }

  Future<void> _showPlanPicker(
    BuildContext context,
    MapTabCubit cubit,
    MapTabState state,
  ) async {
    final selected = await showPlanSelectionBottomsheet(
      context,
      plans: state.plans,
      selectedPlan: state.selectedPlan,
    );
    if (selected != null) {
      cubit.selectPlan(selected);
    }
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showDropdown = false,
  });

  final String label;
  final bool isSelected;
  final bool showDropdown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : (isDark ? AppColors.neutral80 : AppColors.neutral40),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (showDropdown) ...[
              const SizedBox(width: 8),
              Transform.scale(
                scale: 1.5,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : (isDark ? AppColors.neutral80 : AppColors.neutral40),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanMapBody extends StatelessWidget {
  const _PlanMapBody({required this.state});
  final MapTabState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state.planLoadStatus == MapTabPlanLoadStatus.loading ||
        state.planLoadStatus == MapTabPlanLoadStatus.initial) {
      return const Center(child: LoadingWidget());
    }

    if (state.planLoadStatus == MapTabPlanLoadStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<MapTabCubit>().loadPlans(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state.plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/planning.json',
                width: 250,
              ),
              const SizedBox(height: 34),
              Text(
                AppLocalizations.of(context).noSavedPlans,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.isDarkMode
                          ? AppColors.primary80
                          : AppColors.primary40,
                    ),
              ),
              const SizedBox(height: 34),
              CustomButton(
                text: AppLocalizations.of(context).createPlan,
                onTap: () {
                  PlanListScreen.pendingCreatePlan = true;
                  StatefulNavigationShell.of(context)
                      .goBranch(2, initialLocation: true);
                },
                prefixIcon: (color) => SvgPicture.asset(
                  'assets/ic_plus.svg',
                  color: color,
                  width: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final selectedPlan = state.selectedPlan;
    if (selectedPlan == null || selectedPlan.stages.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    final firstStage = selectedPlan.stages.first;
    final stageIds = selectedPlan.stages.map((s) => '${s.id}').join(',');

    return EmbeddedStageMap(
      key: ValueKey(
        'plan-map-${selectedPlan.id}'
        '-$stageIds'
        '-${selectedPlan.startingDate}',
      ),
      selectedStage: firstStage,
      routeId: selectedPlan.route.id,
      stagePlanId: selectedPlan.id,
      isEmbedded: true,
    );
  }
}
