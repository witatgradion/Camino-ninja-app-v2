import 'package:animations/animations.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/cubit/add_edit_stage_cubit.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/widgets/main_option_selector.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/widgets/stage_overview_card.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/widgets/sub_option_selector.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_albergue/stage_select_albergue_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_end_city/stage_select_end_city_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_start_city/stage_select_start_city_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/stage_map_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/name_plan_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/plan_type_choice_sheet.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/stage_note_bottom_sheet.dart';
import 'package:camino_ninja_flutter/utils/animated_mixin.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class AddEditStageScreenArguments {
  const AddEditStageScreenArguments({
    this.stage,
    this.startCity,
    this.routeId,
    this.stagePlanId,
    this.startAlbergue,
    this.startAlbergueNotes,
    this.planName,
    this.trail,
    this.maxEndCity,
    this.insertAfterStageNumber,
    this.minStartCity,
    this.maxStartCity,
    this.planType,
  });
  final StageModel? stage;
  final CityEntity? startCity;
  final AlbergueEntity? startAlbergue;
  final String? startAlbergueNotes;
  final int? routeId;
  final int? stagePlanId;
  final String? planName;
  final MultiRouteTrail? trail;
  final CityEntity? maxEndCity;
  final int? insertAfterStageNumber;

  /// Lower bound (inclusive) for start city selection.
  final CityEntity? minStartCity;

  /// Upper bound (inclusive) for start city selection.
  final CityEntity? maxStartCity;

  /// Which option the user selected on the plan-type choice sheet
  /// for the create-plan flow. Null when this screen is reached
  /// from an existing-plan path (e.g. add/edit stage on a saved
  /// plan).
  final PlanType? planType;
}

class AddEditStageScreen extends StatefulWidget {
  const AddEditStageScreen({required this.arguments, super.key});
  final AddEditStageScreenArguments arguments;

  @override
  State<AddEditStageScreen> createState() => _AddEditStageScreenState();
}

class _AddEditStageScreenState extends State<AddEditStageScreen>
    with TickerProviderStateMixin, AnimatedListMixin<AddEditStageScreen> {
  late AddEditStageCubit _cubit;
  late AnimationController _fadeAnimationController;
  late AnimationController _stageOverviewAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _stageOverviewAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonAnimation;
  late final TextEditingController _noteController;
  bool _noteDirty = false;
  @override
  void initState() {
    super.initState();
    final routeId = widget.arguments.routeId ?? widget.arguments.stage?.routeId;
    _noteController = TextEditingController(
      text: widget.arguments.stage?.stageNotes ?? '',
    );
    _cubit = AddEditStageCubit(
      routeId: routeId,
      stagePlanId: widget.arguments.stagePlanId,
      insertAfterStageNumber:
          widget.arguments.insertAfterStageNumber,
      planName: widget.arguments.planName,
      trail: widget.arguments.trail,
      planType: widget.arguments.planType,
    )..init(
        stage: widget.arguments.stage,
        startCity: widget.arguments.startCity,
        startAlbergue: widget.arguments.startAlbergue,
        startAlbergueNotes: widget.arguments.startAlbergueNotes,
      );

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _stageOverviewAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _stageOverviewAnimation = CurvedAnimation(
      parent: _stageOverviewAnimationController,
      curve: Curves.easeOutCubic,
    );
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _buttonAnimation = CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOutCubic,
    );
    initListAnimation(duration: const Duration(milliseconds: 1000));
    _fadeAnimationController.forward();
    _buttonAnimationController.forward();
    listAnimationController.forward();
  }

  @override
  void dispose() {
    disposeListAnimation();
    _fadeAnimationController.dispose();
    _stageOverviewAnimationController.dispose();
    _buttonAnimationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaminoNinjaAppBar(
        title: AppLocalizations.of(context).createNewStage,
      ),
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<AddEditStageCubit, AddEditStageState>(
          listenWhen: (previous, current) =>
              previous.stageOverviewVisibility !=
                  current.stageOverviewVisibility ||
              previous.saveButtonVisibility != current.saveButtonVisibility ||
              previous.saveStageStatus != current.saveStageStatus,
          listener: (context, state) {
            if (state.stageOverviewVisibility ==
                StageOverviewVisibility.visible) {
              _stageOverviewAnimationController.forward();
            } else {
              _stageOverviewAnimationController.reverse();
            }

            if (state.saveStageStatus == SaveStageStatus.success) {
              _handleSaveSuccess(state);
            }
          },
          child: BlocBuilder<AddEditStageCubit, AddEditStageState>(
            builder: (context, state) {
              final startAlbergueText = state.stage?.customStartNotes ??
                  state.stage?.startAlbergue?.name;
              final endAlbergueText =
                  state.stage?.customEndNotes ?? state.stage?.endAlbergue?.name;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sticky banner at the top.
                      _buildHeader(state),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.trail != null || state.route != null)
                                _buildRouteSummary(state),
                              Container(
                          decoration: BoxDecoration(
                            color: context.isDarkMode
                                ? AppColors.gray800
                                : AppColors.primary95,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            children: [
                              buildAnimatedListItem(
                                index: 0,
                                itemDuration: 0.6,
                                child: _buildOptionSelector(
                                  childBuilder: (openContainer) {
                                    return StageMainOptionSelector(
                                      index: 1,
                                      title: AppLocalizations.of(context)
                                          .startOfStage,
                                      value: state.stage?.startCity?.name,
                                      placeholder: AppLocalizations.of(context)
                                          .selectStartingCity,
                                      onTap: () {
                                        openContainer();
                                      },
                                    );
                                  },
                                  openBuilder: (context, _) =>
                                      StageSelectStartCityScreen(
                                    arguments:
                                        StageSelectStartCityScreenArguments(
                                      route: state.route!,
                                      selectedCity: state.stage?.startCity,
                                      trail: state.trail,
                                      minCity:
                                          widget.arguments.minStartCity,
                                      maxCity:
                                          widget.arguments.maxStartCity,
                                    ),
                                  ),
                                  onClosed: (data) {
                                    if (data != null && data is CityEntity) {
                                      _cubit.selectStartCity(city: data);
                                    }
                                  },
                                ),
                              ),
                              buildAnimatedListItem(
                                index: 1,
                                itemDuration: 0.6,
                                child: _buildOptionSelector(
                                  tappable: state.stage?.startCity != null,
                                  childBuilder: (openContainer) {
                                    return StageSubOptionSelector(
                                      title: startAlbergueText.isNotNullOrEmpty
                                          ? AppLocalizations.of(context)
                                              .iWillStayHere
                                          : AppLocalizations.of(context)
                                              .iWillStayHereOptional,
                                      value: startAlbergueText,
                                      placeholder: AppLocalizations.of(context)
                                          .selectOrSpecify,
                                      onTap: () {
                                        if (state.stage?.startCity == null ||
                                            state.route == null) {
                                          return;
                                        }
                                        openContainer();
                                      },
                                    );
                                  },
                                  openBuilder: (context, _) =>
                                      state.stage?.startCity == null
                                          ? const SizedBox.shrink()
                                          : StageSelectAlbergueScreen(
                                              arguments:
                                                  StageSelectAlbergueScreenArguments(
                                                compareDate: state.stage?.date,
                                                title:
                                                    AppLocalizations.of(context)
                                                        .iWillStayHere,
                                                city: state.stage!.startCity!,
                                                route: state.route!,
                                                selectedAlbergue:
                                                    state.stage?.startAlbergue,
                                                customNotes: state
                                                    .stage?.customStartNotes,
                                                onSelectedAlbergueChanged:
                                                    (albergue, notes) {
                                                  _cubit.updateStage(
                                                    startAlbergue: albergue,
                                                    customStartNotes: notes,
                                                    forceClearStart: true,
                                                  );
                                                },
                                              ),
                                            ),
                                  onClosed: (data) {
                                    if (data != null &&
                                        data is AlbergueEntity) {
                                      _cubit.updateStage(
                                        startAlbergue: data,
                                        forceClearStart: true,
                                      );
                                    }
                                    if (data != null && data is String) {
                                      _cubit.updateStage(
                                        customStartNotes: data,
                                        forceClearStart: true,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              buildAnimatedListItem(
                                index: 2,
                                itemDuration: 0.6,
                                child: _buildOptionSelector(
                                  childBuilder: (openContainer) {
                                    return StageMainOptionSelector(
                                      index: 2,
                                      title: AppLocalizations.of(context)
                                          .endOfStage,
                                      value: state.stage?.endCity?.name,
                                      placeholder: AppLocalizations.of(context)
                                          .selectDestinationCity,
                                      onTap: () {
                                        if (state.stage?.startCity == null) {
                                          return;
                                        }
                                        openContainer();
                                      },
                                    );
                                  },
                                  openBuilder: (context, _) =>
                                      StageSelectEndCityScreen(
                                    arguments:
                                        StageSelectEndCityScreenArguments(
                                      route: state.route!,
                                      selectedCity: state.stage?.endCity,
                                      selectedStartCity:
                                          state.stage!.startCity!,
                                      trail: state.trail,
                                      maxEndCity:
                                          widget.arguments.maxEndCity,
                                    ),
                                  ),
                                  onClosed: (data) {
                                    if (data != null && data is CityEntity) {
                                      _cubit.selectEndCity(city: data);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              buildAnimatedListItem(
                                index: 3,
                                itemDuration: 0.6,
                                child: _buildOptionSelector(
                                  tappable: state.stage?.endCity != null,
                                  childBuilder: (openContainer) {
                                    return StageSubOptionSelector(
                                      title: endAlbergueText.isNotNullOrEmpty
                                          ? AppLocalizations.of(context)
                                              .iWillStayHere
                                          : AppLocalizations.of(context)
                                              .iWillStayHereOptional,
                                      value: endAlbergueText,
                                      placeholder: AppLocalizations.of(context)
                                          .selectOrSpecify,
                                      onTap: () {
                                        if (state.stage?.endCity == null ||
                                            state.route == null) {
                                          return;
                                        }
                                        openContainer();
                                      },
                                    );
                                  },
                                  openBuilder: (context, _) =>
                                      state.stage?.endCity == null
                                          ? const SizedBox.shrink()
                                          : StageSelectAlbergueScreen(
                                              arguments:
                                                  StageSelectAlbergueScreenArguments(
                                                title:
                                                    AppLocalizations.of(context)
                                                        .iWillStayHere,
                                                city: state.stage!.endCity!,
                                                route: state.route!,
                                                selectedAlbergue:
                                                    state.stage?.endAlbergue,
                                                compareDate: state.stage?.date,
                                                customNotes:
                                                    state.stage?.customEndNotes,
                                                onSelectedAlbergueChanged:
                                                    (albergue, notes) {
                                                  _cubit.updateStage(
                                                    endAlbergue: albergue,
                                                    customEndNotes: notes,
                                                    forceClearEnd: true,
                                                  );
                                                },
                                              ),
                                            ),
                                  onClosed: (data) {
                                    if (data != null &&
                                        data is AlbergueEntity) {
                                      _cubit.updateStage(
                                        endAlbergue: data,
                                        forceClearEnd: true,
                                      );
                                    }
                                    if (data != null && data is String) {
                                      _cubit.updateStage(
                                        customEndNotes: data,
                                        forceClearEnd: true,
                                      );
                                    }
                                  },
                                ),
                              ),
                              if (!(state.stage?.overviewDataIsEmpty() ??
                                  true)) ...[
                                const SizedBox(height: 8),
                                buildFadeAnimation(
                                  animation: _stageOverviewAnimation,
                                  child: StageOverviewCard(
                                    stage: state.stage!,
                                    onMapTap: () => _openStageMap(state.stage!),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              buildAnimatedListItem(
                                index: 4,
                                itemDuration: 0.6,
                                child: _buildNotesField(context),
                              ),
                            ],
                          ),
                        ),
                              const SizedBox(height: 65),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildFadeAnimation(
                          animation: _buttonAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CustomButton(
                              isDisabled: !(state.stage?.isValid() ?? false),
                              isLoading: state.saveStageStatus ==
                                  SaveStageStatus.loading,
                              text: AppLocalizations.of(context).save,
                              onTap: () async {
                                if (_noteDirty) {
                                  _cubit
                                      .updateStageNote(_noteController.text);
                                }
                                await _cubit.saveStage();
                                if (context.mounted) {
                                  await context
                                      .read<AppCubit>()
                                      .loadShowNewLabelOnPlanTab();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotesField(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryColor = isDark ? AppColors.primary80 : AppColors.primary40;
    return TextField(
      controller: _noteController,
      maxLength: StageNoteBottomSheet.maxLength,
      minLines: 3,
      maxLines: 6,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
      style: context.textTheme.bodyMedium,
      onChanged: (_) {
        if (!_noteDirty) _noteDirty = true;
      },
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).notesOptional,
        alignLabelWithHint: true,
        filled: true,
        fillColor: isDark ? Colors.black : Colors.white,
        counterStyle: context.textTheme.bodySmall?.copyWith(
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildOptionSelector({
    required Widget Function(VoidCallback) childBuilder,
    required Widget Function(BuildContext, void Function()) openBuilder,
    required void Function(Object?) onClosed,
    bool tappable = true,
  }) {
    return OpenContainer(
      closedElevation: 0,
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      middleColor: Colors.transparent,
      openBuilder: openBuilder,
      onClosed: onClosed,
      tappable: tappable,
      closedBuilder: (context, openContainer) {
        return childBuilder(() => openContainer());
      },
    );
  }

  Widget _buildHeader(AddEditStageState state) {
    final primaryColor =
        context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
    return buildFadeAnimation(
      animation: _fadeAnimation,
      child: Container(
        color: context.isDarkMode ? AppColors.gray800 : AppColors.primary95,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).creatingStagesFor,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.planName ??
                            AppLocalizations.of(context).namePlanOptional,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: state.planName != null
                                  ? (context.isDarkMode
                                      ? Colors.white
                                      : Colors.black)
                                  : (context.isDarkMode
                                      ? Colors.white38
                                      : Colors.black38),
                            ),
                      ),
                    ],
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
      ),
    );
  }

  /// Route summary displayed below the dark banner.
  Widget _buildRouteSummary(AddEditStageState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _TrailSummaryCard(state: state),
    );
  }

  Future<void> _editPlanName(AddEditStageState state) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => NamePlanDialog(initialName: state.planName),
    );
    if (result == null || !mounted) return;
    final name = result.isEmpty ? null : result;
    _cubit.updatePlanName(name);
    final stagePlanId = widget.arguments.stagePlanId;
    if (stagePlanId != null) {
      await _cubit.savePlanName(stagePlanId: stagePlanId, name: name);
    }
  }

  void _openStageMap(StageModel stage) {
    final routeId = widget.arguments.routeId ?? widget.arguments.stage?.routeId;
    if (routeId == null) {
      return;
    }
    context.push(
      '/plan/stage-map',
      extra: StageMapScreenArguments(
        routeId: routeId,
        selectedStage: stage,
        stagePlanId: widget.arguments.stagePlanId ?? stage.stagePlanId,
      ),
    );
  }

  Future<void> _handleSaveSuccess(AddEditStageState state) async {
    context.pop((state.updatedPlan, state.updatedStage));
  }
}

/// Placeholder Camino city names used until the real
/// junction city name is plumbed through the plan state.
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

String _placeholderJunctionName(int index) {
  return _kFakeJunctionCities[index % _kFakeJunctionCities.length];
}

/// Floating trail card with a collapsible list of
/// transferred routes. Shows the first route by default;
/// tap the outlined button to expand and reveal all
/// transferred routes (each in its own inner container
/// with a brand-coloured arrow circle).
class _TrailSummaryCard extends StatefulWidget {
  const _TrailSummaryCard({required this.state});

  final AddEditStageState state;

  @override
  State<_TrailSummaryCard> createState() => _TrailSummaryCardState();
}

class _TrailSummaryCardState extends State<_TrailSummaryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryColor =
        isDark ? AppColors.primary80 : AppColors.primary40;
    final cardBg = isDark ? AppColors.gray800 : AppColors.primary95;
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark ? Colors.white70 : Colors.black54,
        );
    final nameStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: primaryColor,
        );

    // (routeName, routeColor) pairs so each row can show
    // its designated route color regardless of source.
    final List<(String name, Color color)> routes;
    if (widget.state.trail != null && widget.state.trail!.isMultiRoute) {
      routes = widget.state.trail!.segments
          .map<(String, Color)>(
            (s) => (s.routeName, Color(s.colorValue)),
          )
          .toList();
    } else if (widget.state.route != null) {
      routes = [
        (widget.state.route!.routeName, primaryColor),
      ];
    } else {
      routes = const [];
    }
    if (routes.isEmpty) return const SizedBox.shrink();

    final transferredCount = routes.length - 1;

    Widget buildRouteRow((String, Color) entry) {
      final (name, color) = entry;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
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
                        text: _placeholderJunctionName(i - 1),
                        style: labelStyle?.copyWith(
                          color: routes[i].$2,
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
                  color: primaryColor,
                ),
                label: Text(
                  // TODO(l10n): expand/collapse trail
                  _expanded
                      ? 'Hide transferred routes'
                      : 'Show all transferred routes ($transferredCount)',
                  style: nameStyle?.copyWith(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor),
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
