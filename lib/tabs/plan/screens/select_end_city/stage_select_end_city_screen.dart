import 'dart:async';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_end_city/cubit/trail_end_city_cubit.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/segment_header.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_destination/cubit/select_destination_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_destination/select_destination_screen.dart';
import 'package:camino_ninja_flutter/utils/animated_mixin.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/city_list_item.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:storage/storage.dart';

class StageSelectEndCityScreenArguments {
  const StageSelectEndCityScreenArguments({
    required this.route,
    required this.selectedStartCity,
    this.selectedCity,
    this.trail,
    this.maxEndCity,
  });
  final RouteEntity route;
  final CityEntity selectedStartCity;
  final CityEntity? selectedCity;
  final MultiRouteTrail? trail;
  final CityEntity? maxEndCity;
}

class StageSelectEndCityScreen extends StatefulWidget {
  const StageSelectEndCityScreen({
    required this.arguments,
    super.key,
  });
  final StageSelectEndCityScreenArguments arguments;

  @override
  State<StageSelectEndCityScreen> createState() =>
      _StageSelectEndCityScreenState();
}

class _StageSelectEndCityScreenState
    extends State<StageSelectEndCityScreen>
    with
        TickerProviderStateMixin,
        AnimatedListMixin<StageSelectEndCityScreen> {
  // Flag to enable/disable animations
  static const bool _enableAnimations = false;

  bool get _isTrailMode => widget.arguments.trail != null;

  // Single-route cubit/subscription
  SelectDestinationCubit? _cubit;
  StreamSubscription<int?>? _selectedDestinationSubscription;

  // Trail-mode cubit
  TrailEndCityCubit? _trailCubit;

  late AnimationController _fadeAnimationController;
  late AnimationController _emptyAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _searchAnimation;
  late Animation<double> _emptyAnimation;
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();

    if (_isTrailMode) {
      _trailCubit = TrailEndCityCubit(
        trail: widget.arguments.trail!,
        startCity: widget.arguments.selectedStartCity,
        selectedCity: widget.arguments.selectedCity,
        maxEndCity: widget.arguments.maxEndCity,
      )..loadCities();
    } else {
      _cubit = SelectDestinationCubit(
        selectedRoute: widget.arguments.route,
        selectedStartingPoint: widget.arguments.selectedStartCity,
        selectedDestination: widget.arguments.selectedCity,
        maxEndCity: widget.arguments.maxEndCity,
      )
        ..filterDestinations()
        ..getCityPairs();
      _selectedDestinationSubscription =
          _cubit!.nearestCityIndexStream.listen((index) {
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
              final state = _cubit!.state;
              if (state.destinationData.isEmpty) return;
              if (index >= state.destinationData.length) {
                return;
              }
              try {
                // Skip scroll if the item is already fully visible —
                // calling scrollTo on an in-view item causes a spurious
                // snap animation on iOS.
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
                  alignment: 0.5,
                );
              } catch (e) {
                // Controller not attached yet, ignore
              }
            });
          });
        }
      });
    }

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
    initListAnimation(
      duration: _enableAnimations
          ? const Duration(milliseconds: 800)
          : Duration.zero,
    );
    _headerAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: _enableAnimations
          ? const Interval(0, 0.4, curve: Curves.easeOutCubic)
          : const Interval(0, 1),
    );
    _searchAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: _enableAnimations
          ? const Interval(
              0.3,
              0.7,
              curve: Curves.easeOutCubic,
            )
          : const Interval(0, 1),
    );
    _emptyAnimation = CurvedAnimation(
      parent: _emptyAnimationController,
      curve: _enableAnimations
          ? const Interval(
              0.3,
              1,
              curve: Curves.easeOutCubic,
            )
          : const Interval(0, 1),
    );

    if (!_enableAnimations) {
      _fadeAnimationController.value = 1.0;
      _emptyAnimationController.value = 1.0;
      listAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _cubit?.close();
    _trailCubit?.close();
    _fadeAnimationController.dispose();
    _emptyAnimationController.dispose();
    _selectedDestinationSubscription?.cancel();
    disposeListAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaminoNinjaAppBar(
        titleWidget: StepTitle(
          step: 3,
          title: AppLocalizations.of(context).iWillGoThere,
        ),
      ),
      body: SafeArea(
        child: _isTrailMode
            ? _buildTrailBody()
            : _buildSingleRouteBody(),
      ),
    );
  }

  // -------------------------------------------------------
  // Trail-aware end city list with segment grouping
  // -------------------------------------------------------

  Widget _buildTrailBody() {
    return BlocProvider(
      create: (_) => _trailCubit!,
      child: BlocBuilder<TrailEndCityCubit,
          TrailEndCityState>(
        builder: (context, state) {
          if (state.status == TrailEndCityStatus.loading) {
            return const Center(child: LoadingWidget());
          }

          return Column(
            children: [
              DestinationFilter(
                selectedValue: state.cityFilter,
                onChanged: (newValue) {
                  _trailCubit!.changeCityFilter(newValue);
                },
              ),
              SearchField(
                enableDebouncer: true,
                onChanged: (value) {
                  _trailCubit!.searchCities(value);
                },
              ),
              Expanded(
                child: _TrailDestinationList(
                  state: state,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------
  // Original single-route body (unchanged behavior)
  // -------------------------------------------------------

  Widget _buildSingleRouteBody() {
    return BlocProvider(
      create: (context) => _cubit!,
      child: BlocListener<SelectDestinationCubit,
          SelectDestinationState>(
        listenWhen: (previous, current) =>
            previous.initStatus != current.initStatus ||
            previous.filteringStatus !=
                current.filteringStatus,
        listener: (context, state) {
          if (state.initStatus ==
              SelectDestinationInitStatus.success) {
            if (_enableAnimations) {
              _fadeAnimationController.forward();
            } else {
              _fadeAnimationController.value = 1.0;
            }
          }
          if (state.filteringStatus ==
                  SelectDestinationFilteringStatus
                      .success &&
              state.destinationData.isEmpty) {
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
        child: BlocBuilder<SelectDestinationCubit,
            SelectDestinationState>(
          builder: (context, state) {
            if (state.initStatus ==
                SelectDestinationInitStatus.loading) {
              return const Center(
                child: LoadingWidget(),
              );
            }

            return _buildSingleRouteList(state);
          },
        ),
      ),
    );
  }

  Widget _buildSingleRouteList(
    SelectDestinationState state,
  ) {
    return Column(
      children: [
        buildFadeAnimation(
          animation: _headerAnimation,
          child: DestinationFilter(
            selectedValue: state.cityFilter,
            onChanged: (newValue) {
              _cubit!.changeCityFilter(newValue);
            },
          ),
        ),
        buildFadeAnimation(
          animation: _searchAnimation,
          child: SearchField(
            enableDebouncer: true,
            onChanged: (value) {
              _cubit!.filterDestinations(
                query: value,
                isInitial: false,
              );
            },
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              final isLoading = state.initStatus ==
                      SelectDestinationInitStatus
                          .loading ||
                  state.filteringStatus ==
                      SelectDestinationFilteringStatus
                          .loading;
              if (isLoading) {
                return const LoadingWidget();
              }
              if (state.destinationData.isEmpty) {
                return buildFadeAnimation(
                  animation: _emptyAnimation,
                  child: const EmplyStateWidget(),
                );
              }
              return ScrollablePositionedList.builder(
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: state.destinationData.length,
                itemBuilder: (context, index) {
                  return buildAnimatedListItem(
                    index: index,
                    delay: _enableAnimations
                        ? 0.15
                        : 0.0,
                    itemDuration: _enableAnimations
                        ? 0.5
                        : 1.0,
                    child: Column(
                      children: [
                        CityListItem(
                          isSelected: state
                                  .selectedDestination
                                  ?.id ==
                              state
                                  .destinationData[index]
                                  .id,
                          showTrailingIcon: false,
                          destination: state
                              .destinationData[index],
                          percentage: context
                              .read<SelectDestinationCubit>()
                              .getPercentage(
                                state
                                    .destinationData[index]
                                    .id,
                              ),
                          cityPairRank: context
                              .read<SelectDestinationCubit>()
                              .cityPairRankFor(
                                state
                                    .destinationData[index]
                                    .id,
                              ),
                          startCityName:
                              state.startCityName,
                          onClick: () {
                            context.pop(
                              state
                                  .destinationData[index]
                                  .city,
                            );
                          },
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Grouped destination list for trail mode with sticky
/// segment headers.
class _TrailDestinationList extends StatefulWidget {
  const _TrailDestinationList({required this.state});

  final TrailEndCityState state;

  @override
  State<_TrailDestinationList> createState() =>
      _TrailDestinationListState();
}

class _TrailDestinationListState
    extends State<_TrailDestinationList> {
  final _selectedKey = GlobalKey();
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _scheduleAutoScroll();
  }

  @override
  void didUpdateWidget(_TrailDestinationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasScrolled &&
        widget.state.selectedCity != null) {
      _scheduleAutoScroll();
    }
  }

  void _scheduleAutoScroll() {
    if (widget.state.selectedCity == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasScrolled) return;
      final keyContext = _selectedKey.currentContext;
      if (keyContext == null) return;
      _hasScrolled = true;
      Scrollable.ensureVisible(
        keyContext,
        alignment: 0.5,
        duration: Durations.medium2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.state.filteredGroups;
    if (groups.isEmpty ||
        groups.every((g) => g.destinations.isEmpty)) {
      return const EmplyStateWidget();
    }

    return CustomScrollView(
      slivers: [
        for (final group in groups) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _SegmentHeaderDelegate(
              segment: group.segment,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dest =
                    group.destinations[index];
                final isSelected =
                    widget.state.selectedCity?.id ==
                        dest.id;
                return Column(
                  key: isSelected
                      ? _selectedKey
                      : null,
                  children: [
                    CityListItem(
                      isSelected: isSelected,
                      showTrailingIcon: false,
                      destination: dest,
                      onClick: () =>
                          context.pop(dest.city),
                    ),
                    const Divider(height: 1),
                  ],
                );
              },
              childCount: group.destinations.length,
            ),
          ),
        ],
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 24),
        ),
      ],
    );
  }
}

/// Delegate for pinned segment headers in city lists.
class _SegmentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  _SegmentHeaderDelegate({required this.segment});

  final TrailSegment segment;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: SegmentHeader(segment: segment),
    );
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => 44;

  @override
  bool shouldRebuild(
    covariant _SegmentHeaderDelegate oldDelegate,
  ) =>
      segment != oldDelegate.segment;
}
