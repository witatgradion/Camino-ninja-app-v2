import 'dart:async';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/services/deep_link_service.dart';
import 'package:camino_ninja_flutter/tabs/plan/cubit/plan_cubit.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/add_edit_stage_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/journey_planner/journey_planner_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/plan_detail_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/widgets/delete_plan_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/widgets/delete_stage_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_export/qr_export_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_scanner/qr_scanner_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_scanner/select_import_plan_bottomsheet.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_route/stage_select_route_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/trail_builder/trail_builder_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/expandable_plan_card.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/export_plan_selection_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/feature_flag_exposure_tracker.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/incomplete_plan_card.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/name_plan_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/plan_controls.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/plan_type_choice_sheet.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/plan_type_visibility.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/stage_note_bottom_sheet.dart';
import 'package:camino_ninja_flutter/utils/animated_mixin.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/router_locations.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/required_upgrade_dialog.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/login_required_bottomsheet.dart';
import 'package:camino_ninja_flutter/widgets/top_notification_overlay.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class PlanListScreen extends StatefulWidget {
  const PlanListScreen({super.key});

  static bool pendingCreatePlan = false;

  @override
  State<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends State<PlanListScreen>
    with
        TickerProviderStateMixin,
        AnimatedListMixin<PlanListScreen>,
        WidgetsBindingObserver {
  final PlanCubit _cubit = PlanCubit();
  late AnimationController _fadeAnimationController;
  late TopNotificationController _topNotificationController;
  late CurvedAnimation _logoAnimation;
  late CurvedAnimation _textAnimation;
  late CurvedAnimation _buttonAnimation;
  StreamSubscription<DateTime?>? _dataFetchCompletedSubscription;
  StreamSubscription<DateTime?>? _authChangedSubscription;
  StreamSubscription<String>? _deepLinkSubscription;
  DateTime? _lastDataFetchCompletedAt;
  DateTime? _lastAuthChangedAt;
  bool _needsReload = false;
  bool _wasActive = true;
  bool _isHandlingDeepLink = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _topNotificationController = TopNotificationController();
    initListAnimation(duration: const Duration(milliseconds: 1200));

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: const Interval(0, 0.4, curve: Curves.easeOutCubic),
    );
    _textAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    );
    _buttonAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: const Interval(0.6, 1, curve: Curves.easeOutCubic),
    );
    _cubit
      ..init()
      ..loadData();

    final deepLinkService = GetIt.instance<DeepLinkService>();
    _deepLinkSubscription =
        deepLinkService.planImportRequests.listen(_handleDeepLinkImport);

    // Check for pending plan import that arrived before this screen subscribed
    final pendingCode = deepLinkService.consumePendingPlanImport();
    if (pendingCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleDeepLinkImport(pendingCode);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disposeListAnimation();
    _logoAnimation.dispose();
    _textAnimation.dispose();
    _buttonAnimation.dispose();
    _fadeAnimationController.dispose();
    _topNotificationController.dispose();
    _dataFetchCompletedSubscription?.cancel();
    _authChangedSubscription?.cancel();
    _deepLinkSubscription?.cancel();
    _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _needsReload) {
      _needsReload = false;
      unawaited(_cubit.loadData());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isActive = TickerMode.of(context);
    if (isActive && !_wasActive) {
      if (_needsReload) {
        _needsReload = false;
        unawaited(_cubit.loadData());
      }
      if (PlanListScreen.pendingCreatePlan) {
        PlanListScreen.pendingCreatePlan = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _goToAddPlan();
        });
      }
    }
    _wasActive = isActive;
    if (_dataFetchCompletedSubscription == null) {
      final appCubit = context.read<AppCubit>();
      _lastDataFetchCompletedAt = appCubit.state.dataFetchCompletedAt;
      _dataFetchCompletedSubscription = appCubit.stream
          .map((s) => s.dataFetchCompletedAt)
          .distinct()
          .listen(_onDataFetchCompleted);
      _lastAuthChangedAt = appCubit.state.authChangedAt;
      _authChangedSubscription = appCubit.stream
          .map((s) => s.authChangedAt)
          .distinct()
          .listen(_onAuthChanged);
    }
  }

  void _onDataFetchCompleted(DateTime? completedAt) {
    if (completedAt == null || !mounted) return;
    if (_lastDataFetchCompletedAt == completedAt) return;
    _lastDataFetchCompletedAt = completedAt;
    unawaited(_cubit.loadData(shouldShowLoading: false));
  }

  void _onAuthChanged(DateTime? changedAt) {
    if (changedAt == null || !mounted) return;
    if (_lastAuthChangedAt == changedAt) return;
    _lastAuthChangedAt = changedAt;
    unawaited(_cubit.loadData(shouldShowLoading: false));
    // Sync is triggered by [AppCubit.notifyAuthChanged] itself —
    // calling it from this listener would double-fire (issue 027).
  }

  Future<void> _handleDeepLinkImport(String shortCode) async {
    if (_isHandlingDeepLink || !mounted) return;
    _isHandlingDeepLink = true;

    // Show loading dialog
    if (mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: LoadingWidget()),
      );
    }

    try {
      final planModel = await _cubit.getSharedPlanPreview(shortCode);

      // Dismiss loading dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;

      if (planModel != null) {
        final selectedPlan = await showSelectImportPlanBottomsheet(
          context,
          plan: planModel,
        );

        if (selectedPlan != null && mounted) {
          final planId = await _cubit.importSharedPlan(selectedPlan);
          if (planId != null && mounted) {
            _needsReload = true;
            await context.push<StagePlanModel?>(
              '/plan/plan-detail',
              extra: PlanDetailScreenArguments(planId: planId),
            );
            if (mounted) {
              _needsReload = false;
              await _cubit.loadData();
            }
          }
        }
      } else {
        if (mounted) {
          _topNotificationController.changeNotificationType(
            TopNotificationBarType.commonError,
          );
        }
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
      }
      AppLogger.e(
        'Failed to import shared plan',
        tag: 'PlanListScreen',
        error: e,
      );
      if (mounted) {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.commonError,
        );
      }
    } finally {
      _isHandlingDeepLink = false;
    }
  }

  Future<void> _syncPlans() async {
    await _cubit.syncPlans();
  }

  Widget _buildSignInToSyncBanner() {
    return GestureDetector(
      onTap: () async {
        await context.push('/login');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? AppColors.gray800
              : AppColors.primary80.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cloud_sync_outlined,
              size: 18,
              color: context.isDarkMode
                  ? AppColors.primary80
                  : AppColors.primary40,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context).signInToSync,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.isDarkMode
                      ? AppColors.primary80
                      : AppColors.primary40,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: context.isDarkMode
                  ? AppColors.primary80
                  : AppColors.primary40,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToAddPlan() async {
    final dialogResult = await showDialog<String?>(
      context: context,
      builder: (context) => const NamePlanDialog(),
    );
    if (dialogResult == null || !mounted) return;

    final planName = dialogResult.isEmpty ? null : dialogResult;

    final repository = GetIt.instance<Repository>();
    final flagValues = await Future.wait([
      repository.getCustomTrailEnabled(),
      repository.getJourneyPlannerEnabled(),
    ]);
    if (!mounted) return;

    final analytics = GetIt.instance<IAnalyticsService>();
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_custom_trail_enabled',
      flagValue: flagValues[0],
    );
    FeatureFlagExposureTracker.report(
      analytics: analytics,
      flagName: 'feature_journey_planner_enabled',
      flagValue: flagValues[1],
    );

    final visibleTypes = PlanTypeVisibility.visibleTypes(
      flavor: AppConfig.flavor,
      customTrailEnabled: flagValues[0],
      journeyPlannerEnabled: flagValues[1],
    );

    final planType = await showPlanTypeChoiceSheet(
      context,
      visibleTypes: visibleTypes,
    );
    if (planType == null || !mounted) return;

    switch (planType) {
      case PlanType.singleRoute:
        await _goToSingleRoutePlan(planName);
      case PlanType.customTrail:
        await _goToCustomTrailPlan(planName);
      case PlanType.journey:
        await _goToJourneyPlan(planName);
    }
  }

  Future<void> _goToSingleRoutePlan(
    String? planName,
  ) async {
    final result = await context.push(
      '/plan/stage-select-route',
      extra: StageSelectRouteScreenArguments(
        planName: planName,
      ),
    );
    if (result is StageModel && context.mounted) {
      final planId = result.stagePlanId;
      if (planId == null) return;

      if (mounted) {
        _needsReload = true;
        await context.push<StagePlanModel?>(
          RouterLocations.planDetail(
            planId: planId,
            scrollToStageId: result.id,
          ),
          extra: PlanDetailScreenArguments(
            planId: planId,
            scrollToStage: result,
          ),
        );
        if (mounted) {
          _needsReload = false;
          await _cubit.loadData();
        }
      }
    }
  }

  Future<void> _goToCustomTrailPlan(
    String? planName,
  ) async {
    final trail = await context.push<MultiRouteTrail>(
      '/plan/trail-builder',
      extra: TrailBuilderScreenArguments(
        planName: planName,
      ),
    );
    if (trail == null || !mounted) return;

    final stageResult = await context.push(
      '/plan/add-edit-stage',
      extra: AddEditStageScreenArguments(
        routeId: trail.primaryRouteId,
        planName: planName,
        trail: trail,
        planType: PlanType.customTrail,
      ),
    );

    if (stageResult != null && mounted) {
      final (updatedPlan, _) = stageResult as (StagePlanModel?, StageModel?);
      if (updatedPlan != null && mounted) {
        _needsReload = true;
        await context.push<StagePlanModel?>(
          '/plan/plan-detail',
          extra: PlanDetailScreenArguments(
            planId: updatedPlan.id,
          ),
        );
        if (mounted) {
          _needsReload = false;
          await _cubit.loadData();
        }
      }
    }
  }

  Future<void> _goToJourneyPlan(
    String? planName,
  ) async {
    final trail = await context.push<MultiRouteTrail>(
      '/plan/journey-planner',
      extra: JourneyPlannerScreenArguments(
        planName: planName,
      ),
    );
    if (trail == null || !mounted) return;

    final stageResult = await context.push(
      '/plan/add-edit-stage',
      extra: AddEditStageScreenArguments(
        routeId: trail.primaryRouteId,
        planName: planName,
        trail: trail,
        planType: PlanType.journey,
      ),
    );

    if (stageResult != null && mounted) {
      final (updatedPlan, _) =
          stageResult as (StagePlanModel?, StageModel?);
      if (updatedPlan != null && mounted) {
        _needsReload = true;
        await context.push<StagePlanModel?>(
          '/plan/plan-detail',
          extra: PlanDetailScreenArguments(
            planId: updatedPlan.id,
          ),
        );
        if (mounted) {
          _needsReload = false;
          await _cubit.loadData();
        }
      }
    }
  }

  Widget _buildEmptyState(PlanState state) {
    return BlocBuilder<PlanCubit, PlanState>(
      buildWhen: (previous, current) => previous.isSyncing != current.isSyncing,
      builder: (context, syncState) {
        return Column(
          children: [
            buildFadeAnimation(
              animation: _textAnimation,
              child: CaminoNinjaAppBar(
                title: AppLocalizations.of(context).myPlans,
                showLeading: false,
              ),
            ),
            if (!state.isLoggedIn) _buildSignInToSyncBanner(),
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildFadeAnimation(
                            animation: _logoAnimation,
                            child: Lottie.asset(
                              'assets/lottie/planning.json',
                              width: 250,
                            ),
                          ),
                          const SizedBox(height: 34),
                          buildFadeAnimation(
                            animation: _textAnimation,
                            child: Text(
                              AppLocalizations.of(context).noSavedPlans,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: context.isDarkMode
                                        ? AppColors.primary80
                                        : AppColors.primary40,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 16,
                    right: 16,
                    child: buildFadeAnimation(
                      animation: _buttonAnimation,
                      child: PlanControls(
                        onImport: _openCameraScanner,
                        onCreate: _goToAddPlan,
                        onSync: state.isLoggedIn ? _syncPlans : null,
                        isSyncing: syncState.isSyncing,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanList(PlanState state) {
    final stagePlans = state.stagePlans;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildFadeAnimation(
          animation: _textAnimation,
          child: CaminoNinjaAppBar(
            title: AppLocalizations.of(context).myPlans,
            showLeading: false,
          ),
        ),
        if (!state.isLoggedIn) _buildSignInToSyncBanner(),
        const SizedBox(height: 12),
        BlocBuilder<PlanCubit, PlanState>(
          buildWhen: (previous, current) =>
              previous.isSyncing != current.isSyncing,
          builder: (context, syncState) {
            return buildFadeAnimation(
              animation: _buttonAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: PlanControls(
                  onCreate: _goToAddPlan,
                  onImport: _openCameraScanner,
                  onShare: _exportPlan,
                  onSync: state.isLoggedIn ? _syncPlans : null,
                  isSyncing: syncState.isSyncing,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SlidableAutoCloseBehavior(
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemCount: stagePlans.length + state.incompletePlans.length,
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 24,
              ),
              itemBuilder: (context, index) {
                if (index < stagePlans.length) {
                  final plan = stagePlans[index];
                  final planRouteMap = state.multiRouteMap[plan.id];
                  return buildAnimatedListItem(
                    index: index,
                    delay: 0.15,
                    itemDuration: 0.5,
                    child: ExpandablePlanCard(
                      plan: plan,
                      multiRouteMap: planRouteMap,
                      onViewPlanTap: () => _onViewPlanTap(plan),
                      onStageTap: (stage) => _onStageTap(plan, stage),
                      onEditStageTap: (stage) => _onStageTap(plan, stage),
                      onAddStageTap: () => _onAddStageTap(plan),
                      onInsertStageBetweenTap: (afterStageIndex) =>
                          _onInsertStageBetween(
                        plan,
                        afterStageIndex,
                      ),
                      onToggleExpandTap: (isExpanded) => _onToggleExpandTap(
                        plan,
                        isExpanded,
                      ),
                      onDeletePlanTap: () => _onDeletePlanTap(plan),
                      onDeleteStageTap: (stage) =>
                          _onDeleteStageTap(plan, stage),
                      onStageNoteTap: (stage) =>
                          _onStageNoteTap(plan, stage),
                    ),
                  );
                }
                final incompletePlan =
                    state.incompletePlans[index - stagePlans.length];
                return buildAnimatedListItem(
                  index: index,
                  delay: 0.15,
                  itemDuration: 0.5,
                  child: IncompletePlanCard(
                    plan: incompletePlan,
                    onDeleteTap: () => _onDeleteIncompletePlanTap(
                      incompletePlan,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (_) => _cubit,
          child: BlocListener<PlanCubit, PlanState>(
            listenWhen: (previous, current) =>
                previous.initStatus != current.initStatus ||
                previous.planActionStatus != current.planActionStatus ||
                (previous.stagePlans.isEmpty &&
                    current.stagePlans.isNotEmpty) ||
                (previous.incompletePlans.isEmpty &&
                    current.incompletePlans.isNotEmpty),
            listener: (context, state) {
              if (state.initStatus == PlanInitStatus.success ||
                  state.initStatus == PlanInitStatus.failure) {
                final hasPlans = state.stagePlans.isNotEmpty ||
                    state.incompletePlans.isNotEmpty;
                if (!hasPlans) {
                  _fadeAnimationController.forward();
                } else {
                  _fadeAnimationController.forward().then((_) {
                    listAnimationController.forward();
                  });
                }
              }

              if (state.planActionStatus == PlanActionStatus.failure ||
                  state.initStatus == PlanInitStatus.failure) {
                _topNotificationController.changeNotificationType(
                  TopNotificationBarType.commonError,
                );
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BlocBuilder<PlanCubit, PlanState>(
                    builder: (context, state) {
                      final status = state.initStatus;
                      if (status == PlanInitStatus.loading) {
                        return const Center(
                          child: LoadingWidget(),
                        );
                      }

                      final hasPlans = state.stagePlans.isNotEmpty ||
                          state.incompletePlans.isNotEmpty;
                      if (!hasPlans) {
                        return _buildEmptyState(state);
                      }

                      return _buildPlanList(state);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: CaminoNinjaAppBar.height,
                  ),
                  child: TopNotificationOverlay(
                    key: const ValueKey(
                      'top_notification_overlay',
                    ),
                    controller: _topNotificationController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onViewPlanTap(StagePlanModel plan) async {
    _needsReload = true;
    final result = await context.push<StagePlanModel?>(
      RouterLocations.planDetail(planId: plan.id),
    );
    if (mounted) {
      _needsReload = false;
      if (result != null) {
        await _cubit.updatePlan(
          result,
          preserveExpandedState: true,
        );
      } else {
        await _cubit.loadData();
      }
    }
  }

  Future<void> _onAddStageTap(StagePlanModel plan) async {
    final currentStages = plan.stages;
    final lastStage = currentStages.lastOrNull;

    // Reconstruct trail for multi-route plans so the
    // city picker shows the correct segment data.
    MultiRouteTrail? trail;
    if (plan.isMultiRoute) {
      try {
        trail = await GetIt.instance<StagePlanRepository>()
            .buildTrailForPlan(plan);
      } catch (e, st) {
        AppLogger.e(
          'Failed to build trail for plan ${plan.id}',
          tag: 'PlanScreen',
          error: e,
          stackTrace: st,
        );
      }
    }

    if (!mounted) return;

    final result = await context.push(
      '/plan/add-edit-stage',
      extra: AddEditStageScreenArguments(
        routeId: plan.route.id,
        stagePlanId: plan.id,
        planName: plan.name,
        startCity: lastStage?.endCity,
        trail: trail,
        startAlbergue: lastStage?.endAlbergue,
        startAlbergueNotes: lastStage?.customEndNotes,
        minStartCity: lastStage?.endCity,
      ),
    );
    if (result != null && mounted) {
      final (updatedPlan, updatedStage) =
          result as (StagePlanModel?, StageModel?);
      if (updatedPlan != null && mounted) {
        _needsReload = true;
        final planResult = await context.push<StagePlanModel?>(
          '/plan/plan-detail',
          extra: PlanDetailScreenArguments(
            planId: plan.id,
            scrollToStage: updatedStage,
          ),
        );
        if (mounted) {
          _needsReload = false;
          if (planResult != null) {
            await _cubit.updatePlan(
              planResult,
              preserveExpandedState: true,
            );
          } else {
            await _cubit.loadData();
          }
        }
      }
    }
  }

  Future<void> _onInsertStageBetween(
    StagePlanModel plan,
    int afterStageIndex,
  ) async {
    final stages = plan.stages;
    final currentStage = stages[afterStageIndex];
    final nextStage = afterStageIndex + 1 < stages.length
        ? stages[afterStageIndex + 1]
        : null;

    final result = await context.push(
      '/plan/add-edit-stage',
      extra: AddEditStageScreenArguments(
        routeId: plan.route.id,
        stagePlanId: plan.id,
        planName: plan.name,
        startCity: currentStage.endCity,
        startAlbergue: currentStage.endAlbergue,
        startAlbergueNotes: currentStage.customEndNotes,
        maxEndCity: nextStage?.startCity,
        minStartCity: currentStage.endCity,
        maxStartCity: nextStage?.startCity,
        insertAfterStageNumber:
            currentStage.stageNumber ?? (afterStageIndex + 1),
      ),
    );
    if (result != null && mounted) {
      final (updatedPlan, updatedStage) =
          result as (StagePlanModel?, StageModel?);
      if (updatedPlan != null && mounted) {
        _needsReload = true;
        final planResult = await context.push<StagePlanModel?>(
          RouterLocations.planDetail(
            planId: updatedPlan.id,
            scrollToStageId: updatedStage?.id,
          ),
          extra: updatedStage?.id == null
              ? PlanDetailScreenArguments(
                  planId: updatedPlan.id,
                  scrollToStage: updatedStage,
                )
              : null,
        );
        if (mounted) {
          _needsReload = false;
          if (planResult != null) {
            await _cubit.updatePlan(
              planResult,
              preserveExpandedState: true,
            );
          } else {
            await _cubit.loadData();
          }
        }
      }
    }
  }

  Future<void> _onToggleExpandTap(
    StagePlanModel plan,
    bool isExpanded,
  ) async {
    unawaited(
      _cubit.updatePlan(plan.copyWith(isExpanded: isExpanded)),
    );
  }

  Future<void> _onStageTap(
    StagePlanModel plan,
    StageModel stage,
  ) async {
    _needsReload = true;
    final result = await context.push<StagePlanModel?>(
      RouterLocations.planDetail(
        planId: plan.id,
        scrollToStageId: stage.id,
      ),
      extra: stage.id == null
          ? PlanDetailScreenArguments(
              planId: plan.id,
              scrollToStage: stage,
            )
          : null,
    );
    if (mounted) {
      _needsReload = false;
      if (result != null) {
        await _cubit.updatePlan(
          result,
          preserveExpandedState: true,
        );
      } else {
        await _cubit.loadData();
      }
    }
  }

  Future<void> _onDeleteIncompletePlanTap(
    IncompletePlanInfo plan,
  ) async {
    if (!mounted) return;
    await _cubit.deleteIncompletePlan(plan);
    _topNotificationController.changeNotificationType(
      TopNotificationBarType.deletePlanSuccess,
    );
  }

  Future<void> _onDeletePlanTap(StagePlanModel plan) async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => DeletePlanDialog(plan: plan),
    );
    if (result != null && result && mounted) {
      await _cubit.deletePlan(plan);
      _topNotificationController.changeNotificationType(
        TopNotificationBarType.deletePlanSuccess,
      );
    }
  }

  Future<void> _onStageNoteTap(
    StagePlanModel plan,
    StageModel stage,
  ) async {
    final result = await showStageNoteBottomSheet(
      context,
      initialNote: stage.stageNotes,
    );
    if (result == null || !mounted) return;
    final note = switch (result) {
      StageNoteClearResult() => null,
      StageNoteSaveResult(text: final t) => t,
    };
    await _cubit.updateStageNote(plan: plan, stage: stage, note: note);
  }

  Future<void> _onDeleteStageTap(
    StagePlanModel plan,
    StageModel stage,
  ) async {
    final stages = plan.stages;
    if (stages.length == 1) {
      await _onDeletePlanTap(plan);
      return;
    }
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => DeleteStageDialog(stage: stage),
    );
    if (result != null && result && mounted && stage.id != null) {
      await _cubit.deleteStage(plan, stage);
      _topNotificationController.changeNotificationType(
        TopNotificationBarType.deleteStageSuccess,
      );
    }
  }

  Future<void> _openCameraScanner() async {
    final result = await context.push<int>(
      '/plan/qr-scanner',
      extra: QrScannerScreenArguments(
        plans: _cubit.state.stagePlans,
      ),
    );
    if (!mounted) return;

    if (result != null) {
      _needsReload = true;
      await context.push<StagePlanModel?>(
        RouterLocations.planDetail(planId: result),
      );
      if (mounted) {
        _needsReload = false;
        await _cubit.loadData();
      }
    }
  }

  Future<void> _exportPlan() async {
    var isLoggedIn = await _cubit.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      return _showExportPlanDialog();
    }

    final shouldUpgrade = await _cubit.shouldUpgradeToUseFeature();
    if (!mounted) return;
    if (shouldUpgrade) {
      return showDialog(
        context: context,
        builder: (context) => const RequiredUpgradeDialog(),
      );
    }

    isLoggedIn = (await showLoginRequiredBottomsheet(
          context,
          title: AppLocalizations.of(context).loginToShare,
          description: AppLocalizations.of(context).plansLinkedDescription,
        )) ??
        false;

    if (isLoggedIn) {
      return _showExportPlanDialog();
    }
  }

  Future<void> _showExportPlanDialog() async {
    final plans = _cubit.state.stagePlans;
    if (plans.isEmpty) return;

    final result = await showDialog<List<StagePlanModel>>(
      context: context,
      builder: (context) => ExportPlanSelectionDialog(plans: plans),
    );

    if (result != null && mounted) {
      if (result.isNotEmpty) {
        await _navigateToShareScreen(result);
      }
    }
  }

  Future<void> _navigateToShareScreen(
    List<StagePlanModel> plans,
  ) async {
    await context.push(
      '/plan/qr-export',
      extra: QrExportScreenArguments(plans: plans),
    );
  }
}
