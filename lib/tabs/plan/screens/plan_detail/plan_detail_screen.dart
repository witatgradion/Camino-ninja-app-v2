import 'dart:async';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/services/login_reminder_session.dart';
import 'package:camino_ninja_flutter/tabs/plan/login_reminder_config.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/add_edit_stage_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/cubit/plan_detail_cubit.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/stage_detail_card.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/widgets/delete_plan_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/widgets/delete_stage_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/widgets/general_save_change_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/widgets/reselect_destination_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_export/qr_export_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_albergue/stage_select_albergue_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_end_city/stage_select_end_city_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_start_city/stage_select_start_city_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/stage_map_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/sync_indicator_status.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/sync_manager.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/day_gaps_widget.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/login_reminder_banner.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/name_plan_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/stage_note_bottom_sheet.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/stages_not_connected_card.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_nav_scope.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_bottomsheet.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_type.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/required_upgrade_dialog.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/login_reminder_bottomsheet.dart';
import 'package:camino_ninja_flutter/widgets/login_required_bottomsheet.dart';
import 'package:camino_ninja_flutter/widgets/top_notification_overlay.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:storage/storage.dart';

class PlanDetailScreenArguments {
  const PlanDetailScreenArguments({
    required this.planId,
    this.scrollToStage,
    this.scrollToStageId,
  });
  final int planId;
  final StageModel? scrollToStage;
  final int? scrollToStageId;
}

class PlanDetailScreen extends StatefulWidget {
  const PlanDetailScreen({required this.arguments, super.key});
  final PlanDetailScreenArguments arguments;

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  final _disableActionNotifier = ValueNotifier<bool>(false);
  late PlanDetailCubit _cubit;
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  late TopNotificationController _topNotificationController;
  late SyncManager _syncManager;
  final LoginReminderSession _loginReminderSession =
      GetIt.instance<LoginReminderSession>();
  bool _hasTrackedLoginReminderShown = false;
  StreamSubscription<DateTime?>? _authChangedSubscription;
  DateTime? _lastAuthChangedAt;

  @override
  void initState() {
    super.initState();
    _topNotificationController = TopNotificationController();
    _cubit = PlanDetailCubit(planId: widget.arguments.planId);
    _syncManager = GetIt.instance<SyncManager>();
    _syncManager.syncStatus.addListener(_onSyncStatusChanged);

    // Defer initialization until after page transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAfterTransition();
    });
  }

  void _onSyncStatusChanged() {
    if (_syncManager.syncStatus.value == SyncIndicatorStatus.success) {
      _cubit.reloadPlan();
    }
  }

  void _initAfterTransition() {
    final route = ModalRoute.of(context);
    if (route?.animation != null && !route!.animation!.isCompleted) {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          route.animation!.removeStatusListener(listener);
          _startInitialization();
        }
      }

      route.animation!.addStatusListener(listener);
    } else {
      _startInitialization();
    }
  }

  void _startInitialization() {
    if (!mounted) return;
    _cubit.init(
      scrollToStage: widget.arguments.scrollToStage,
      scrollToStageId: widget.arguments.scrollToStageId,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_authChangedSubscription == null) {
      final appCubit = context.read<AppCubit>();
      _lastAuthChangedAt = appCubit.state.authChangedAt;
      _authChangedSubscription = appCubit.stream
          .map((s) => s.authChangedAt)
          .distinct()
          .listen(_onAuthChanged);
    }
  }

  void _onAuthChanged(DateTime? changedAt) {
    if (changedAt == null || !mounted) return;
    if (_lastAuthChangedAt == changedAt) return;
    _lastAuthChangedAt = changedAt;
    unawaited(_cubit.refreshLoginState());
  }

  @override
  void dispose() {
    _syncManager.syncStatus.removeListener(_onSyncStatusChanged);
    _authChangedSubscription?.cancel();
    _disableActionNotifier.dispose();
    _topNotificationController.dispose();
    super.dispose();
  }

  void _onBackPressed() {
    context.pop(_cubit.state.plan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaminoNinjaAppBar(
        title: AppLocalizations.of(context).planDetail,
        onBackTap: _onBackPressed,
        actions: [
          ValueListenableBuilder(
            valueListenable: _disableActionNotifier,
            builder: (context, isDisabled, child) {
              return InkWell(
                onTap: isDisabled ? null : _onSharePlan,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.isDarkMode
                          ? AppColors.primary80
                          : AppColors.primary40,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/ic_share_outline.svg',
                    width: 18.5,
                    color: context.isDarkMode
                        ? AppColors.primary80
                        : AppColors.primary40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          ValueListenableBuilder(
            valueListenable: _disableActionNotifier,
            builder: (context, isDisabled, child) {
              return InkWell(
                onTap: isDisabled ? null : _onDeletePlan,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE02424),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/ic_trash_outline.svg',
                    width: 18.5,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<PlanDetailCubit, PlanDetailState>(
          listenWhen: (previous, current) =>
              previous.scrollToIndex != current.scrollToIndex ||
              previous.initStatus != current.initStatus ||
              previous.planActionStatus != current.planActionStatus,
          listener: (context, state) {
            final scrollIndex = state.scrollToIndex;
            if (scrollIndex != null && scrollIndex >= 0) {
              // Use addPostFrameCallback to ensure scroll happens after rebuild
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
                final stageCount = state.plan?.stages.length ?? 0;
                // Validate index is within bounds
                if (scrollIndex < stageCount) {
                  // +2: skip trail card (0) and starting date card (1).
                  final targetIndex = scrollIndex + 2;
                  final positions =
                      _itemPositionsListener.itemPositions.value;
                  final alreadyVisible = positions.any(
                    (p) =>
                        p.index == targetIndex &&
                        p.itemLeadingEdge >= 0 &&
                        p.itemTrailingEdge <= 1,
                  );
                  if (!alreadyVisible) {
                    await _itemScrollController.scrollTo(
                      index: targetIndex,
                      duration: const Duration(milliseconds: 250),
                    );
                  }
                }
                await _cubit.setOverlayLoading(false);
              });
            }
            if (state.planActionStatus == PlanDetailActionStatus.failure ||
                state.initStatus == PlanDetailInitStatus.failure) {
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
                child: BlocBuilder<PlanDetailCubit, PlanDetailState>(
                  buildWhen: (previous, current) =>
                      previous.initStatus != current.initStatus ||
                      previous.plan != current.plan ||
                      previous.shouldShowOverlayLoading !=
                          current.shouldShowOverlayLoading,
                  builder: (context, state) {
                    final isLoading =
                        state.initStatus != PlanDetailInitStatus.success;
                    if (isLoading) {
                      return const Center(
                        child: LoadingWidget(),
                      );
                    }
                    return ValueListenableBuilder(
                      valueListenable: _disableActionNotifier,
                      builder: (context, isDisabled, child) {
                        return Stack(
                          children: [
                            IgnorePointer(
                              ignoring: isDisabled,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildHeader(state),
                                  _buildLoginReminderBanner(state),
                                  Expanded(child: _buildBody(state)),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: CustomOutlineButton(
                                  backgroundColor: context.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                  text: AppLocalizations.of(context).addStage,
                                  prefixIcon: (color) => SvgPicture.asset(
                                    'assets/ic_plus.svg',
                                    color: color,
                                    width: 18,
                                  ),
                                  onTap: () {
                                    if (isDisabled) return;
                                    _goToCreateStage(state);
                                  },
                                ),
                              ),
                            ),
                            if (state.shouldShowOverlayLoading) ...[
                              const Positioned(
                                child: ColoredBox(
                                  color: AppColors.barrierColor,
                                  child: Center(
                                    child: LoadingWidget(),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              TopNotificationOverlay(
                key: const ValueKey('top_notification_overlay'),
                controller: _topNotificationController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginReminderBanner(PlanDetailState state) {
    final shouldShow = state.shouldShowLoginReminder &&
        !_loginReminderSession.isDismissedThisSession;
    if (!shouldShow) {
      if (_hasTrackedLoginReminderShown) {
        // Reset after the current frame so we can re-fire the shown event
        // if the banner becomes visible again.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _hasTrackedLoginReminderShown = false;
        });
      }
      return const SizedBox.shrink();
    }

    final stageCount = state.plan?.stages.length ?? 0;
    if (!_hasTrackedLoginReminderShown) {
      // Defer analytics fire + flag mutation to after the current frame so
      // we never mutate state or trigger side effects during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _hasTrackedLoginReminderShown) return;
        _hasTrackedLoginReminderShown = true;
        try {
          GetIt.instance<IAnalyticsService>().track(
            LoginReminderShownEvent(
              stageCount: stageCount,
              source: kLoginReminderSourcePlanDetail,
            ),
          );
        } catch (e) {
          AppLogger.e(
            'Failed to track login reminder shown',
            tag: 'PlanDetailScreen',
            error: e,
          );
        }
      });
    }

    return LoginReminderBanner(
      stageCount: stageCount,
      onTap: () async {
        try {
          GetIt.instance<IAnalyticsService>().track(
            LoginReminderTappedEvent(
              stageCount: stageCount,
              source: kLoginReminderSourcePlanDetail,
            ),
          );
        } catch (e) {
          AppLogger.e(
            'Failed to track login reminder tapped',
            tag: 'PlanDetailScreen',
            error: e,
          );
        }
        await showLoginReminderBottomsheet(context);
      },
      onDismiss: () {
        try {
          GetIt.instance<IAnalyticsService>().track(
            LoginReminderDismissedEvent(
              stageCount: stageCount,
              source: kLoginReminderSourcePlanDetail,
            ),
          );
        } catch (e) {
          AppLogger.e(
            'Failed to track login reminder dismissed',
            tag: 'PlanDetailScreen',
            error: e,
          );
        }
        _loginReminderSession.dismiss();
        setState(() {});
      },
    );
  }

  Widget _buildHeader(PlanDetailState state) {
    final hasPlanName = state.plan?.name != null;
    final primaryColor =
        context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
    return Container(
      color: context.isDarkMode ? AppColors.gray800 : AppColors.primary95,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hasPlanName
                      ? state.plan!.name!
                      : AppLocalizations.of(context).namePlanOptional,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasPlanName
                            ? (context.isDarkMode ? Colors.white : Colors.black)
                            : (context.isDarkMode
                                ? Colors.white38
                                : Colors.black38),
                      ),
                ),
              ),
              GestureDetector(
                onTap: () => _editPlanName(state),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 1.5),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/ic_edit.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartingDateCard(PlanDetailState state) {
    final startingDate = state.plan?.startingDate;
    final hasDate = startingDate != null;
    final primaryColor = context.isDarkMode
        ? AppColors.primary80
        : AppColors.primary40;

    return GestureDetector(
      onTap: () => _selectStartingDate(state),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? AppColors.gray800
              : AppColors.primary95,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.calendar_today,
                size: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)
                        .setStartingDateOptional,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDate
                        ? startingDate.toHumanReadableDate()
                        : AppLocalizations.of(context)
                            .selectStartDate,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: hasDate
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (hasDate)
              GestureDetector(
                onTap: () => _cubit.updateStartingDate(null),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: primaryColor,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                size: 32,
                color: context.isDarkMode
                    ? Colors.white
                    : AppColors.primary40,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartingDate(PlanDetailState state) async {
    final initialDate =
        state.plan?.startingDate ?? DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (result != null && mounted) {
      await _cubit.updateStartingDate(result);
    }
  }

  Future<void> _editPlanName(PlanDetailState state) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => NamePlanDialog(initialName: state.plan?.name),
    );
    if (result == null || !mounted) return;
    await _cubit.updatePlanName(result.isEmpty ? null : result);
  }

  Widget _buildBody(PlanDetailState state) {
    final stages = state.plan?.stages ?? [];
    final primaryColor =
        context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
    // +1 for the trail summary card at index 0
    // +1 for the starting date card at index 1
    final totalItems = stages.length + 2;
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 80,
        top: 8,
      ),
      itemBuilder: (context, index) {
        // Index 0 → trail summary card
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RouteSummary(
              state: state,
              primaryColor: primaryColor,
            ),
          );
        }
        // Index 1 → starting date card
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildStartingDateCard(state),
          );
        }

        final stageIndex = index - 2;
        final stage = stages[stageIndex];
        final isLastStage = stageIndex == stages.length - 1;

        final showJunction = !isLastStage &&
            state.isMultiRoute &&
            stage.routeId != stages[stageIndex + 1].routeId;

        return Column(
          children: [
            StageDetailCard(
              key: ValueKey('stage_${stage.id}'),
              stage: stage,
              plan: state.plan,
              index: stageIndex,
              onDeleteTap: () => _onDeleteStage(stage),
              onEditTap: (type) => _onEditStage(type, stage),
              onMapTap: () => _onMapTap(stage, state),
              onReviewTap: _onReviewAlbergue,
              onDaysToStayChanged: (days) {
                if (stage.id != null) {
                  _cubit.updateStageDaysToStay(
                    stageId: stage.id!,
                    daysToStay: days,
                  );
                }
              },
              onNoteTap: () => _onEditStageNote(stage),
            ),
            if (showJunction)
              _JunctionSplitIndicator(
                nextStage: stages[stageIndex + 1],
                routeMap: state.routeMap,
              ),
            _buildDayGapWidget(
              stages,
              stageIndex,
              isLastStage,
              state,
              hasJunctionAbove: showJunction,
            ),
          ],
        );
      },
      itemCount: totalItems,
    );
  }

  Widget _buildDayGapWidget(
    List<StageModel> stages,
    int index,
    bool isLast,
    PlanDetailState state, {
    bool hasJunctionAbove = false,
  }) {
    if (isLast) return const SizedBox(height: 16);

    final currentStage = stages[index];
    final nextStage = stages[index + 1];
    final isDisconnected =
        currentStage.endCity?.id != nextStage.startCity?.id;

    return Column(
      children: [
        if (currentStage.daysToStay > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 16),
            child: DayGapsWidget(
              daysDifference: currentStage.daysToStay,
              showSpaceAhead: false,
            ),
          ),
        if (isDisconnected)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: StagesNotConnectedCard(
              onTap: () => _insertStageBetween(
                state: state,
                afterStageIndex: index,
              ),
            ),
          ),
        // Default spacing between stages; skipped when the
        // junction divider above already provides symmetric
        // vertical padding.
        if (!isDisconnected &&
            currentStage.daysToStay <= 1 &&
            !hasJunctionAbove)
          const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _goToCreateStage(PlanDetailState state) async {
    final lastStage = state.plan?.stages.lastOrNull;
    final result = await context.push(
      '/plan/add-edit-stage',
      extra: AddEditStageScreenArguments(
        routeId: state.plan?.route.id ?? 0,
        stagePlanId: state.plan?.id ?? 0,
        planName: state.plan?.name,
        startCity: lastStage?.endCity,
        startAlbergue: lastStage?.endAlbergue,
        startAlbergueNotes: lastStage?.customEndNotes,
        trail: state.trail,
        minStartCity: lastStage?.endCity,
      ),
    );
    if (result != null && context.mounted) {
      final (plan, stage) = result as (StagePlanModel?, StageModel?);
      if (plan != null) {
        await _cubit.setPlanDirectly(plan: plan, scrollToStageId: stage?.id);
      }
    }
  }

  Future<void> _insertStageBetween({
    required PlanDetailState state,
    required int afterStageIndex,
  }) async {
    final stages = state.plan?.stages ?? [];
    final currentStage = stages[afterStageIndex];
    final nextStage = afterStageIndex + 1 < stages.length
        ? stages[afterStageIndex + 1]
        : null;

    final result = await context.push(
      '/plan/add-edit-stage',
      extra: AddEditStageScreenArguments(
        routeId: state.plan?.route.id ?? 0,
        stagePlanId: state.plan?.id ?? 0,
        planName: state.plan?.name,
        startCity: currentStage.endCity,
        startAlbergue: currentStage.endAlbergue,
        startAlbergueNotes: currentStage.customEndNotes,
        trail: state.trail,
        maxEndCity: nextStage?.startCity,
        minStartCity: currentStage.endCity,
        maxStartCity: nextStage?.startCity,
        insertAfterStageNumber:
            currentStage.stageNumber ??
                (afterStageIndex + 1),
      ),
    );
    if (result != null && context.mounted) {
      final (plan, stage) =
          result as (StagePlanModel?, StageModel?);
      if (plan != null) {
        await _cubit.setPlanDirectly(
          plan: plan,
          scrollToStageId: stage?.id,
        );
      }
    }
  }

  Future<void> _onEditStageNote(StageModel stage) async {
    final stageId = stage.id;
    if (stageId == null) return;
    final result = await showStageNoteBottomSheet(
      context,
      initialNote: stage.stageNotes,
    );
    if (result == null || !mounted) return;
    final note = switch (result) {
      StageNoteClearResult() => null,
      StageNoteSaveResult(text: final t) => t,
    };
    await _cubit.updateStageNote(stageId: stageId, note: note);
  }

  Future<void> _onDeleteStage(StageModel stage) async {
    final stages = _cubit.state.plan?.stages ?? [];
    if (stages.length == 1) {
      await _onDeletePlan();
      return;
    }
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => DeleteStageDialog(stage: stage),
    );
    if (result != null && result && mounted && stage.id != null) {
      await _cubit.deleteStage(stage.id!);
      _topNotificationController.changeNotificationType(
        TopNotificationBarType.deleteStageSuccess,
      );
    }
  }

  Future<void> _onEditStage(StageDetailCardType type, StageModel stage) async {
    if (type == StageDetailCardType.startCity) {
      return _openSelectStartCity(stage);
    }
    if (type == StageDetailCardType.endCity) {
      return _openSelectEndCity(stage);
    }
    if (type == StageDetailCardType.startAlbergue) {
      return _openSelectStartAlbergue(stage);
    }
    if (type == StageDetailCardType.endAlbergue) {
      return _openSelectEndAlbergue(stage);
    }
  }

  Future<void> _onDeletePlan() async {
    final plan = _cubit.state.plan;
    if (plan == null) {
      return;
    }
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => DeletePlanDialog(plan: plan),
    );
    if (result != null && result && mounted) {
      await _cubit.deletePlan();
      _disableActionNotifier.value = true;
      _topNotificationController.changeNotificationType(
        TopNotificationBarType.deletePlanSuccess,
      );
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        context.pop();
      }
    }
  }

  void _onMapTap(StageModel stage, PlanDetailState state) {
    context.push(
      '/plan/stage-map',
      extra: StageMapScreenArguments(
        routeId: state.plan?.route.id ?? 0,
        stagePlanId: state.plan?.id,
        selectedStage: stage,
      ),
    );
  }

  Future<void> _openSelectStartCity(StageModel stage) async {
    final route = _cubit.state.plan?.route;
    if (route == null) {
      return;
    }

    // Calculate bounds from neighboring stages
    final stages = _cubit.state.plan?.stages ?? [];
    final stageIndex =
        stages.indexWhere((s) => s.id == stage.id);
    final prevStage =
        stageIndex > 0 ? stages[stageIndex - 1] : null;
    final nextStage = stageIndex < stages.length - 1
        ? stages[stageIndex + 1]
        : null;

    final startCityResult = await context.push(
      '/plan/stage-select-start-city',
      extra: StageSelectStartCityScreenArguments(
        route: route,
        selectedCity: stage.startCity,
        trail: _cubit.state.trail,
        minCity: prevStage?.endCity,
        maxCity: nextStage?.startCity,
      ),
    );
    if (startCityResult is CityEntity && context.mounted) {
      final isDiff = startCityResult.id != stage.startCity?.id;
      if (!isDiff) {
        return;
      }

      final isEndCityStillValid = await _cubit.checkIfEndCityStillValid(
        startCity: startCityResult,
        stage: stage,
      );

      if (!isEndCityStillValid) {
        var continueReselectEnd = true;
        continueReselectEnd = await _showReselectDestinationDialog();
        if (!continueReselectEnd || !mounted) {
          return;
        }

        final endCityResult = await context.push(
          '/plan/stage-select-end-city',
          extra: StageSelectEndCityScreenArguments(
            route: route,
            selectedCity: stage.endCity,
            selectedStartCity: startCityResult,
            trail: _cubit.state.trail,
            maxEndCity: nextStage?.startCity,
          ),
        );
        if (endCityResult is CityEntity && context.mounted) {
          final isDiff = endCityResult.id != stage.endCity?.id;
          if (!isDiff) {
            return;
          }

          await _cubit.updateStageStartCity(
            startCity: startCityResult,
            endCity: endCityResult,
            stage: stage,
          );
          return;
        }
        // User cancelled end city selection - don't update anything
        return;
      }

      await _cubit.updateStageStartCity(
        stage: stage,
        startCity: startCityResult,
      );
    }
  }

  Future<void> _openSelectEndCity(StageModel stage) async {
    final route = _cubit.state.plan?.route;
    if (route == null) {
      return;
    }
    if (stage.startCity == null) {
      return;
    }

    // Find next stage's start city as upper bound
    final stages = _cubit.state.plan?.stages ?? [];
    final stageIndex =
        stages.indexWhere((s) => s.id == stage.id);
    final nextStage = stageIndex < stages.length - 1
        ? stages[stageIndex + 1]
        : null;

    final result = await context.push(
      '/plan/stage-select-end-city',
      extra: StageSelectEndCityScreenArguments(
        route: route,
        selectedCity: stage.endCity,
        selectedStartCity: stage.startCity!,
        trail: _cubit.state.trail,
        maxEndCity: nextStage?.startCity,
      ),
    );
    if (result is CityEntity && context.mounted) {
      final isDiff = result.id != stage.endCity?.id;
      if (!isDiff) {
        return;
      }

      final shouldSave = await _showGeneralSaveChangeDialog();
      if (shouldSave) {
        await _cubit.updateStageEndCity(city: result, stage: stage);
      }
    }
  }

  void _openSelectStartAlbergue(StageModel stage) {
    final route = _cubit.state.plan?.route;
    if (route == null) {
      return;
    }
    if (stage.startCity == null) {
      return;
    }
    context.push(
      '/plan/stage-select-albergue',
      extra: StageSelectAlbergueScreenArguments(
        title: AppLocalizations.of(context).iWillStayHere,
        city: stage.startCity!,
        route: route,
        selectedAlbergue: stage.startAlbergue,
        compareDate: _computeDateForStage(stage),
        customNotes: stage.customStartNotes,
        onSelectedAlbergueChanged: (albergue, notes) async {
          await _cubit.updateStageStartAlbergue(
            albergue: albergue,
            customStartNotes: notes,
            stage: stage,
          );
        },
      ),
    );
  }

  void _openSelectEndAlbergue(StageModel stage) {
    final route = _cubit.state.plan?.route;
    if (route == null) {
      return;
    }
    if (stage.endCity == null) {
      return;
    }
    context.push(
      '/plan/stage-select-albergue',
      extra: StageSelectAlbergueScreenArguments(
        title: AppLocalizations.of(context).iWillStayHere,
        city: stage.endCity!,
        route: route,
        selectedAlbergue: stage.endAlbergue,
        compareDate: _computeDateForStage(stage),
        customNotes: stage.customEndNotes,
        onSelectedAlbergueChanged: (albergue, notes) async {
          await _cubit.updateStageEndAlbergue(
            albergue: albergue,
            stage: stage,
            customEndNotes: notes,
          );
        },
      ),
    );
  }

  DateTime? _computeDateForStage(StageModel stage) {
    final plan = _cubit.state.plan;
    if (plan == null) return null;
    final index = plan.stages.indexWhere((s) => s.id == stage.id);
    if (index < 0) return null;
    return plan.computeStageDate(index);
  }

  Future<bool> _showGeneralSaveChangeDialog() async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => const GeneralSaveChangeDialog(),
    );
    return result ?? false;
  }

  Future<bool> _showReselectDestinationDialog() async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => const ReselectDestinationDialog(),
    );
    return result ?? false;
  }

  Future<void> _onReviewAlbergue(AlbergueEntity albergue) async {
    var isLoggedIn = await _cubit.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      return _showReviewBottomSheet(context, albergue);
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
          title: AppLocalizations.of(context).registerForReview,
          description: AppLocalizations.of(context).qualityReasonReviews,
        )) ??
        false;

    if (isLoggedIn) {
      await Future<void>.delayed(Durations.medium1);
      if (!mounted) return;
      return _showReviewBottomSheet(context, albergue);
    }
  }

  Future<void> _showReviewBottomSheet(
    BuildContext context,
    AlbergueEntity albergue,
  ) async {
    GetIt.instance<IAnalyticsService>().track(
      OpenReviewEvent(
        albergueId: albergue.id,
        albergueName: albergue.name,
        source: 'stage_planner',
      ),
    );

    final result = await showReviewFeedbackBottomSheet(
      context,
      type: ReviewFeedbackType.reviewAlbergue,
      albergueId: albergue.id,
      galleryRoutePath: AlbergueDetailsNavScope.planTab.galleryPath,
    );
    if (!context.mounted) {
      return;
    }
    if (result != null) {
      if (result) {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.reviewSuccess,
        );
      } else {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.reviewError,
        );
      }
    }
  }

  Future<void> _onSharePlan() async {
    var isLoggedIn = await _cubit.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      return _navigateToSharePlanScreen();
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
      return _navigateToSharePlanScreen();
    }
  }

  Future<void> _navigateToSharePlanScreen() async {
    final plan = _cubit.state.plan;
    if (plan == null) {
      return;
    }
    await context.push(
      '/plan/qr-export',
      extra: QrExportScreenArguments(plans: [plan]),
    );
  }
}

/// Compact indicator shown between stage cards when the next
/// stage belongs to a different route in a multi-route plan.
class _JunctionSplitIndicator extends StatelessWidget {
  const _JunctionSplitIndicator({
    required this.nextStage,
    required this.routeMap,
  });

  final StageModel nextStage;
  final Map<int, RouteEntity>? routeMap;

  @override
  Widget build(BuildContext context) {
    final route = routeMap?[nextStage.routeId];
    if (route == null) return const SizedBox.shrink();

    final isDark = context.isDarkMode;
    final routeColor = parseRouteColor(route, isDark: isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: isDark ? AppColors.gray800 : AppColors.gray100,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pill-shaped stripe, inset from top/bottom
                // so it matches the segment header style.
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
                                // TODO(l10n): localize
                                TextSpan(
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
                                  text: route.routeName,
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

/// Walks the plan's stages and pulls the real junction
/// city for every transition where the route changes —
/// `stage[N].endCity` is the same city as
/// `stage[N+1].startCity`, which is the junction.
///
/// Falls back to a placeholder name if the stages haven't
/// been recorded yet (e.g., the user is still picking the
/// starting city) so the UI never shows an empty value.
List<String> _resolveJunctionCityNames(
  PlanDetailState state,
  List<RouteEntity> routes,
) {
  final junctions = <String>[];
  final stages = state.plan?.stages ?? const [];
  for (var i = 0; i + 1 < stages.length; i++) {
    final current = stages[i];
    final next = stages[i + 1];
    if (current.routeId != next.routeId) {
      junctions.add(
        current.endCity?.name ?? next.startCity?.name ?? '',
      );
    }
  }
  // Pad with placeholders if we have fewer real names
  // than transitions (e.g., new plan with no stages yet).
  final transferredCount = routes.length - 1;
  while (junctions.length < transferredCount) {
    junctions.add(_kFakeJunctionCities[
        junctions.length % _kFakeJunctionCities.length]);
  }
  return junctions;
}

const List<String> _kFakeJunctionCities = [
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

/// Floating card showing the plan's trail. Collapsed by
/// default: shows the small "Trail" label, the first
/// route name, and a "Show all transferred routes" button.
/// When expanded, lists each transferred route in its own
/// inner container with a brand-coloured arrow circle.
class _RouteSummary extends StatefulWidget {
  const _RouteSummary({
    required this.state,
    required this.primaryColor,
  });

  final PlanDetailState state;
  final Color primaryColor;

  @override
  State<_RouteSummary> createState() => _RouteSummaryState();
}

class _RouteSummaryState extends State<_RouteSummary> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardBg = isDark ? AppColors.gray800 : AppColors.primary95;
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark ? Colors.white70 : Colors.black54,
        );
    final nameStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: widget.primaryColor,
        );

    final List<RouteEntity> routes;
    if (widget.state.isMultiRoute && widget.state.routeMap != null) {
      routes = widget.state.routeMap!.values.toList();
    } else {
      final r = widget.state.plan?.route;
      routes = [if (r != null) r];
    }
    if (routes.isEmpty) return const SizedBox.shrink();

    final transferredCount = routes.length - 1;
    final junctionNames = _resolveJunctionCityNames(widget.state, routes);

    Widget buildRouteRow(RouteEntity route) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: parseRouteColor(route, isDark: isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              route.routeName,
              style: nameStyle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // TODO(l10n): "Trail" label
            'Trail',
            style: labelStyle,
          ),
          const SizedBox(height: 6),
          buildRouteRow(routes.first),
          if (_expanded)
            for (var i = 1; i < routes.length; i++) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 0, 8),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        // TODO(l10n): city junction label
                        text: 'City junction: ',
                        style: labelStyle?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: junctionNames[i - 1],
                        style: labelStyle?.copyWith(
                          color: parseRouteColor(
                            routes[i],
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              buildRouteRow(routes[i]),
            ],
          if (transferredCount > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 18,
                  color: widget.primaryColor,
                ),
                label: Text(
                  // TODO(l10n): expand/collapse trail
                  _expanded
                      ? 'Hide transferred routes'
                      : 'Show all transferred routes ($transferredCount)',
                  style: nameStyle?.copyWith(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

