import 'dart:async';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_start_city/cubit/trail_start_city_cubit.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/segment_header.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_starting_point/cubit/select_starting_point_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_starting_point/cubit/use_my_location_container.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_starting_point/select_starting_point_screen.dart';
import 'package:camino_ninja_flutter/utils/animated_mixin.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/location_accuracy_dialog.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/location_service_dialog.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:storage/storage.dart';

class StageSelectStartCityScreenArguments {
  const StageSelectStartCityScreenArguments({
    required this.route,
    this.selectedCity,
    this.trail,
    this.minCity,
    this.maxCity,
  });
  final RouteEntity route;
  final CityEntity? selectedCity;
  final MultiRouteTrail? trail;

  /// Lower bound (inclusive) for city selection.
  /// Typically the previous stage's end city.
  final CityEntity? minCity;

  /// Upper bound (inclusive) for city selection.
  /// Typically the next stage's start city.
  final CityEntity? maxCity;
}

class StageSelectStartCityScreen extends StatefulWidget {
  const StageSelectStartCityScreen({
    required this.arguments,
    super.key,
  });
  final StageSelectStartCityScreenArguments arguments;

  @override
  State<StageSelectStartCityScreen> createState() =>
      _StageSelectStartCityScreenState();
}

class _StageSelectStartCityScreenState
    extends State<StageSelectStartCityScreen>
    with
        TickerProviderStateMixin,
        AnimatedListMixin<StageSelectStartCityScreen> {
  // Flag to enable/disable animations
  static const bool _enableAnimations = false;

  bool get _isTrailMode => widget.arguments.trail != null;

  // Single-route cubits/subscriptions
  SelectStartingPointCubit? _cubit;
  StreamSubscription<int?>? _nearestCitySubscription;

  // Trail-mode cubit
  TrailStartCityCubit? _trailCubit;

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
      _trailCubit = TrailStartCityCubit(
        trail: widget.arguments.trail!,
        selectedCity: widget.arguments.selectedCity,
        minCity: widget.arguments.minCity,
        maxCity: widget.arguments.maxCity,
      )..loadCities();
    } else {
      _cubit = SelectStartingPointCubit(
        selectedRoute: widget.arguments.route,
        selectedStartingPoint:
            widget.arguments.selectedCity,
        minCity: widget.arguments.minCity,
        maxCity: widget.arguments.maxCity,
      )..filterCities();
      _nearestCitySubscription =
          _cubit!.nearestCityIndexStream.listen((index) {
        if (index != null && index >= 0) {
          const delay = _enableAnimations
              ? Duration(milliseconds: 800)
              : Duration.zero;
          Future.delayed(delay, () {
            if (!mounted) return;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              // Check if list exists and has items before scrolling
              final state = _cubit!.state;
              if (state.filteredCities.isEmpty) return;
              if (index >= state.filteredCities.length) {
                return;
              }
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
    _nearestCitySubscription?.cancel();
    disposeListAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaminoNinjaAppBar(
        titleWidget: StepTitle(
          step: 2,
          title: AppLocalizations.of(context).iWillStartHere,
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
  // Trail-aware grouped city list
  // -------------------------------------------------------

  Widget _buildTrailBody() {
    return BlocProvider(
      create: (_) => _trailCubit!,
      child: BlocBuilder<TrailStartCityCubit,
          TrailStartCityState>(
        builder: (context, state) {
          if (state.status == TrailStartCityStatus.loading) {
            return const Center(child: LoadingWidget());
          }

          return Column(
            children: [
              SearchField(
                enableDebouncer: true,
                onChanged: (value) {
                  _trailCubit!.searchCities(value);
                },
              ),
              Expanded(
                child: _TrailCityList(
                  state: state,
                  onCityTap: (city) => context.pop(city),
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
      child: BlocConsumer<SelectStartingPointCubit,
          SelectStartingPointState>(
        listener: (context, state) async {
          if (state.accuracyDenied) {
            await _showAccuracyDialog(
              context,
              isSelectCurrentLocation:
                  state.isSelectCurrentLocation,
            );
          } else {
            if (state.isSelectCurrentLocation) {
              await _onUseCurrentLocation();
            }
          }
        },
        builder: (context, state) {
          return BlocListener<SelectStartingPointCubit,
              SelectStartingPointState>(
            listenWhen: (previous, current) =>
                previous.initStatus != current.initStatus ||
                previous.filteringStatus !=
                    current.filteringStatus,
            listener: (context, state) {
              if (state.initStatus ==
                  SelectStartingPointInitStatus.success) {
                if (_enableAnimations) {
                  _fadeAnimationController.forward();
                } else {
                  _fadeAnimationController.value = 1.0;
                }
              }
              if (state.filteringStatus ==
                      SelectStartingPointFilteringStatus
                          .success &&
                  state.filteredCities.isEmpty) {
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
            child: BlocBuilder<SelectStartingPointCubit,
                SelectStartingPointState>(
              builder: (context, state) {
                if (state.initStatus ==
                    SelectStartingPointInitStatus.loading) {
                  return const Center(
                    child: LoadingWidget(),
                  );
                }

                return _buildSingleRouteList(state);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleRouteList(
    SelectStartingPointState state,
  ) {
    return Column(
      children: [
        buildFadeAnimation(
          animation: _headerAnimation,
          child: UseMyLocationContainer(
            onTap: _onUseCurrentLocation,
          ),
        ),
        buildFadeAnimation(
          animation: _searchAnimation,
          child: SearchField(
            enableDebouncer: true,
            onChanged: (value) {
              _cubit!.searchCities(value);
            },
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (state.filteredCities.isEmpty) {
                return buildFadeAnimation(
                  animation: _emptyAnimation,
                  child: const EmplyStateWidget(),
                );
              }

              return ScrollablePositionedList.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                itemCount: state.filteredCities.length,
                itemBuilder: (context, index) {
                  return buildAnimatedListItem(
                    index: index,
                    delay:
                        _enableAnimations ? 0.15 : 0.0,
                    itemDuration:
                        _enableAnimations ? 0.5 : 1.0,
                    child: Column(
                      children: [
                        StartingPointListItem(
                          isSelected: state
                                  .selectedStartingPoint
                                  ?.id ==
                              state
                                  .filteredCities[index]
                                  .id,
                          name: state
                              .filteredCities[index].name,
                          onClick: () {
                            context.pop(
                              state.filteredCities[index],
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

  Future<void> _showAccuracyDialog(
    BuildContext mainContext, {
    bool isSelectCurrentLocation = false,
  }) async {
    if (!mounted) return;

    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return LocationAccuracyDialog(
          onAllow: _cubit!.selectNearestCity,
          onDeny: (permanentlyDenied) async {
            await GetIt.instance<Repository>()
                .setLocationAccuracyDenied(
              permanentlyDenied,
            );
            late final bool result;
            if (permanentlyDenied) {
              result =
                  await _cubit!.selectNearestCity();
            } else {
              result =
                  await _cubit!.selectNearestCity(
                locationAccuracyOff: true,
              );
            }
            if (result && isSelectCurrentLocation) {
              await _onUseCurrentLocation();
            }
          },
        );
      },
    );
  }

  Future<void> _onUseCurrentLocation() async {
    final state = _cubit!.state;

    if (!mounted) return;

    if (state.nearestCity == null ||
        state.nearestCityDistance == null) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const LocationServiceDialog(
            shouldShowDoNotShowAgain: false,
          );
        },
      );
      return;
    }

    if (state.nearestCityDistance! > maxAllowedDistance) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.of(context).youAreTooFar}...',
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)
                          .youAreDistanceFromCity(
                        state.nearestCity!.name,
                        (state.nearestCityDistance! / 1000)
                            .toStringAsFixed(2),
                      ),
                      style:
                          context.textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: widget
                          .arguments.route.routeName,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppLocalizations.of(context)
                    .appNotBelieveYouAreOnRoute(
                  widget.arguments.route.routeName,
                ),
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            CustomButton(
              text: AppLocalizations.of(context)
                  .returnToAllLocations,
              onTap: () => context.pop(),
            ),
          ],
        ),
      );
      return;
    }
    if (!mounted) return;
    context.pop(state.nearestCity);
  }
}

/// Grouped city list for trail mode. Displays cities
/// organized under sticky segment headers.
class _TrailCityList extends StatefulWidget {
  const _TrailCityList({
    required this.state,
    required this.onCityTap,
  });

  final TrailStartCityState state;
  final ValueChanged<CityEntity> onCityTap;

  @override
  State<_TrailCityList> createState() =>
      _TrailCityListState();
}

class _TrailCityListState extends State<_TrailCityList> {
  final _selectedKey = GlobalKey();
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _scheduleAutoScroll();
  }

  @override
  void didUpdateWidget(_TrailCityList oldWidget) {
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
        groups.every((g) => g.cities.isEmpty)) {
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
                final city = group.cities[index];
                final isSelected =
                    widget.state.selectedCity?.id ==
                        city.id;
                return Column(
                  key: isSelected
                      ? _selectedKey
                      : null,
                  children: [
                    StartingPointListItem(
                      isSelected: isSelected,
                      name: city.name,
                      onClick: () =>
                          widget.onCityTap(city),
                    ),
                    const Divider(height: 1),
                  ],
                );
              },
              childCount: group.cities.length,
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
