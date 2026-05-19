import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/add_edit_stage_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/plan_type_choice_sheet.dart';

import 'package:camino_ninja_flutter/tabs/route/screens/select_route/cubit/select_route_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_route/select_route_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_route/widgets/select_route_map_widget.dart';
import 'package:camino_ninja_flutter/utils/animated_mixin.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:camino_ninja_flutter/widgets/select_route_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:storage/storage.dart';

class StageSelectRouteScreenArguments {
  const StageSelectRouteScreenArguments({this.route, this.planName});
  final RouteEntity? route;
  final String? planName;
}

class StageSelectRouteScreen extends StatefulWidget {
  const StageSelectRouteScreen({this.arguments, super.key});
  final StageSelectRouteScreenArguments? arguments;

  @override
  State<StageSelectRouteScreen> createState() =>
      _StageSelectRouteScreenState();
}

class _StageSelectRouteScreenState extends State<StageSelectRouteScreen>
    with TickerProviderStateMixin,
        AnimatedListMixin<StageSelectRouteScreen> {
  // Flag to enable/disable animations
  static const bool _enableAnimations = false;

  late SelectRouteCubit _cubit;
  late AnimationController _fadeAnimationController;
  late AnimationController _emptyAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _emptyAnimation;
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  StreamSubscription<int?>? _selectedRouteSubscription;

  @override
  void initState() {
    super.initState();
    _cubit = SelectRouteCubit()
      ..fetchRoutes(widget.arguments?.route?.id);
    _selectedRouteSubscription =
        _cubit.selectedIndexStream.listen((index) {
      if (index != null && index >= 0) {
        const delay = _enableAnimations
            ? Duration(milliseconds: 800)
            : Duration.zero;
        Future.delayed(delay, () {
          if (!mounted) return;
          // Use post-frame callback to ensure the list is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            // Check if list exists and has items before scrolling
            final state = _cubit.state;
            if (state.filteredRoutes.isEmpty) return;
            if (index >= state.filteredRoutes.length) return;
            try {
              final positions =
                  _itemPositionsListener.itemPositions.value;
              final alreadyVisible = positions.any(
                (p) =>
                    p.index == index &&
                    p.itemLeadingEdge >= 0 &&
                    p.itemTrailingEdge <= 1,
              );
              if (alreadyVisible) return;
              _itemScrollController.scrollTo(
                index: index,
                duration: Durations.medium2,
              );
            } catch (e) {
              // Controller not attached yet, ignore
            }
          });
        });
      }
    });
    _setupAnimations();
  }

  void _setupAnimations() {
    const duration = _enableAnimations
        ? Duration(milliseconds: 800)
        : Duration.zero;
    const emptyDuration = _enableAnimations
        ? Duration(milliseconds: 400)
        : Duration.zero;

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: duration,
    );
    _emptyAnimationController = AnimationController(
      vsync: this,
      duration: emptyDuration,
    );
    _searchAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: _enableAnimations
          ? const Interval(0.3, 0.7, curve: Curves.easeOutCubic)
          : const Interval(0, 1),
    );
    _emptyAnimation = CurvedAnimation(
      parent: _emptyAnimationController,
      curve: _enableAnimations
          ? const Interval(0.3, 1, curve: Curves.easeOutCubic)
          : const Interval(0, 1),
    );
    initListAnimation(
      duration: _enableAnimations
          ? const Duration(milliseconds: 800)
          : Duration.zero,
    );

    // If animations disabled, immediately complete them
    if (!_enableAnimations) {
      _fadeAnimationController.value = 1.0;
      _emptyAnimationController.value = 1.0;
      listAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _fadeAnimationController.dispose();
    _emptyAnimationController.dispose();
    _selectedRouteSubscription?.cancel();
    disposeListAnimation();
    super.dispose();
  }

  Future<void> _onRouteSelected(
    BuildContext context,
    int routeId,
  ) async {
    final result = await context.push(
      '/plan/add-edit-stage',
      extra: AddEditStageScreenArguments(
        routeId: routeId,
        planName: widget.arguments?.planName,
        planType: PlanType.singleRoute,
      ),
    );
    if (result != null && context.mounted) {
      final (_, stage) =
          result as (StagePlanModel?, StageModel?);
      if (stage != null) {
        context.pop(stage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaminoNinjaAppBar(
        title: AppLocalizations.of(context).selectRoute,
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => _cubit,
          child: BlocListener<SelectRouteCubit, SelectRouteState>(
            listenWhen: (previous, current) =>
                previous.initStatus != current.initStatus ||
                previous.filteringStatus !=
                    current.filteringStatus,
            listener: (context, state) {
              if (state.initStatus ==
                  SelectRouteInitStatus.success) {
                if (_enableAnimations) {
                  _fadeAnimationController.forward();
                } else {
                  _fadeAnimationController.value = 1.0;
                }
              }
              if (state.filteringStatus ==
                      SelectRouteFilteringStatus.success &&
                  state.filteredRoutes.isEmpty) {
                if (_enableAnimations) {
                  _emptyAnimationController
                    ..reset()
                    ..forward();
                } else {
                  _emptyAnimationController.value = 1.0;
                }
              } else {
                if (_enableAnimations) {
                  listAnimationController
                    ..reset()
                    ..forward();
                } else {
                  listAnimationController.value = 1.0;
                }
              }
            },
            child: BlocBuilder<SelectRouteCubit, SelectRouteState>(
              builder: (context, state) {
                if (state.initStatus ==
                    SelectRouteInitStatus.loading) {
                  return const Center(
                    child: LoadingWidget(),
                  );
                }

                return _buildBody(context, state);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SelectRouteState state,
  ) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (_, appState) {
        return Column(
          children: [
            buildFadeAnimation(
              animation: _searchAnimation,
              child: SearchField(
                enableDebouncer: true,
                onChanged: (value) {
                  _cubit.searchRoutes(value);
                },
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Builder(
                    builder: (context) {
                      if (state.filteredRoutes.isEmpty) {
                        return buildFadeAnimation(
                          animation: _emptyAnimation,
                          child: const EmplyStateWidget(),
                        );
                      }

                      return IndexedStack(
                        index: state.selectedMode.index,
                        children: [
                          ScrollablePositionedList.builder(
                            itemScrollController:
                                _itemScrollController,
                            itemPositionsListener:
                                _itemPositionsListener,
                            padding: const EdgeInsets.only(
                              bottom: 24,
                            ),
                            itemCount:
                                state.filteredRoutes.length,
                            itemBuilder: (context, index) {
                              return buildAnimatedListItem(
                                index: index,
                                delay: _enableAnimations
                                    ? index * 0.1
                                    : 0.0,
                                itemDuration:
                                    _enableAnimations ? 0.6 : 1.0,
                                child: Column(
                                  children: [
                                    RouteListItem(
                                      isSelected:
                                          state.selectedRouteId ==
                                              state
                                                  .filteredRoutes[
                                                      index]
                                                  .routeId,
                                      unit: appState.unit,
                                      travelRouteData: state
                                          .filteredRoutes[index],
                                      onClick: () =>
                                          _onRouteSelected(
                                        context,
                                        state
                                            .filteredRoutes[index]
                                            .routeId,
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              );
                            },
                          ),
                          SelectRouteMapWidget(
                            filteredRoutes:
                                state.filteredRoutes,
                            routePointsByRouteId:
                                state.routePointsByRouteId,
                            selectedRouteId:
                                state.selectedRouteId,
                            isSearchActive:
                                state.isSearchActive,
                            isDarkMode: context.isDarkMode,
                            unit: appState.unit,
                            onRouteSelected: (routeId) =>
                                _onRouteSelected(
                              context,
                              routeId,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (state.filteredRoutes.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 16,
                      child: SelectRouteModeFab(
                        currentMode: state.selectedMode,
                        onToggle: () {
                          context
                              .read<SelectRouteCubit>()
                              .changeMode(
                                state.selectedMode.toggled,
                              );
                        },
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
}
