import 'package:auto_size_text/auto_size_text.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/widgets/expandable_route_selection.dart';
import 'package:camino_ninja_flutter/tabs/route/widgets/offline_no_data_widget.dart';
import 'package:camino_ninja_flutter/tabs/route/widgets/progress_indicator_widget.dart';
import 'package:camino_ninja_flutter/tabs/route/widgets/update_now_widget.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/router_locations.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/city_list_item.dart';
import 'package:camino_ninja_flutter/widgets/notification_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _expandedKey = GlobalKey();
  final GlobalKey _collapsedKey = GlobalKey();
  final _distanceGroupKey = AutoSizeGroup();

  // Dynamic spacer at the bottom of the list to ensure we always have
  // enough scroll distance to fully collapse the header even when the
  // planned route is very short.
  double _bottomSpace = 0;
  bool _bottomSpaceCalculated = false;
  int _lastPlannedRouteLength = -1;
  bool _recalculationScheduledFromListener = false;

  double? _expandedHeight;
  double? _collapsedHeight;
  bool _announcementsBadgeLoaded = false;

  // Auto-snap state
  bool _isSnapping = false;
  double _lastScrollOffset = 0;
  DateTime _lastScrollTime = DateTime.now();
  double _lastScrollVelocity = 0;
  static const double _snapThreshold = 0.5; // 50% threshold
  static const double _velocityThreshold = 300; // px/sec for momentum snap

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeights());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_announcementsBadgeLoaded) {
      _announcementsBadgeLoaded = true;
      context.read<AppCubit>().refreshNotificationsBadge();
    }
  }

  void _onScrollControllerUpdate() {
    // When scroll metrics change (e.g., after list layout completes),
    // we may need to recalculate bottom space if our previous calculation
    // was based on incomplete layout information.
    if (!_scrollController.hasClients) return;

    // Prevent multiple simultaneous recalculations from this listener
    if (_recalculationScheduledFromListener) return;

    // Only recheck if we think calculation is complete
    if (_bottomSpaceCalculated &&
        _expandedHeight != null &&
        _collapsedHeight != null) {
      final headerDiff = _expandedHeight! - _collapsedHeight!;
      final currentMax = _scrollController.position.maxScrollExtent;

      // If we don't have enough scroll extent to fully collapse,
      // trigger recalculation (this handles the case where initial
      // calculation happened before the list was fully laid out)
      if (currentMax < headerDiff - 1.0) {
        AppLogger.d(
          '[ROUTE_BOTTOM_SPACE] Scroll metrics changed, insufficient extent '
          '($currentMax < $headerDiff), scheduling recalculation',
        );
        _bottomSpaceCalculated = false;
        _recalculationScheduledFromListener = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _recalculationScheduledFromListener = false;
          _recalculateBottomSpace();
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollControllerUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  void _measureHeights() {
    final expandedContext = _expandedKey.currentContext;
    final collapsedContext = _collapsedKey.currentContext;

    if (expandedContext != null && collapsedContext != null) {
      final expandedBox = expandedContext.findRenderObject() as RenderBox?;
      final collapsedBox = collapsedContext.findRenderObject() as RenderBox?;

      if (expandedBox != null && collapsedBox != null && mounted) {
        final newExpandedHeight = expandedBox.size.height;
        final newCollapsedHeight = collapsedBox.size.height;

        if (_expandedHeight != newExpandedHeight ||
            _collapsedHeight != newCollapsedHeight) {
          setState(() {
            _expandedHeight = newExpandedHeight;
            _collapsedHeight = newCollapsedHeight;
            // Heights changed → recalculate dynamic bottom space next frame.
            _bottomSpace = 0.0;
            _bottomSpaceCalculated = false;
          });

          AppLogger.d(
            '[ROUTE_BOTTOM_SPACE] _measureHeights '
            'expanded=$_expandedHeight collapsed=$_collapsedHeight',
          );

          // Wait for the scroll view to layout with the new header heights,
          // then compute how much extra scroll distance we need so the
          // header can fully collapse.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _recalculateBottomSpace();
          });
        }
      }
    }
  }

  /// Computes the minimum bottom spacer needed so that the maximum
  /// scroll extent is at least the header's collapse distance.
  ///
  /// Let:
  ///  - H_exp = expanded header height
  ///  - H_coll = collapsed header height
  ///  - D_hdr = H_exp - H_coll (how far the header needs to collapse)
  ///  - maxScrollExtent = how far we can currently scroll
  ///
  /// To guarantee we can fully collapse the header, we need:
  ///   maxScrollExtent >= D_hdr
  ///
  /// Adding extra bottom space increases maxScrollExtent one-to-one,
  /// so we add:
  ///   extra = max(0, D_hdr - maxScrollExtent)
  ///
  /// When the list itself is long enough (maxScrollExtent >= D_hdr),
  /// this yields 0 so we don't show any extra padding at the bottom.
  ///
  /// The optional [attempt] parameter lets us reschedule the calculation
  /// across a few frames until both header heights and scroll metrics are
  /// available (important after a cold start / app restart).
  void _recalculateBottomSpace({int attempt = 0}) {
    if (attempt > 10) {
      // Give up after several frames to avoid an infinite loop in case
      // something goes wrong with layout.
      AppLogger.d(
        '[ROUTE_BOTTOM_SPACE] _recalculateBottomSpace giving up '
        '(attempt=$attempt, expanded=$_expandedHeight, '
        'collapsed=$_collapsedHeight, hasClients=${_scrollController.hasClients})',
      );
      return;
    }

    // If already calculated, only skip if the scroll extent is sufficient
    if (_bottomSpaceCalculated && _scrollController.hasClients) {
      final headerDiff = (_expandedHeight ?? 0) - (_collapsedHeight ?? 0);
      final currentMax = _scrollController.position.maxScrollExtent;
      if (currentMax >= headerDiff - 1.0) {
        // We have enough scroll extent (with 1px tolerance for rounding)
        AppLogger.d(
          '[ROUTE_BOTTOM_SPACE] _recalculateBottomSpace skipped '
          '(sufficient scroll extent: $currentMax >= $headerDiff, '
          'bottomSpace=$_bottomSpace, attempt=$attempt)',
        );
        return;
      } else {
        // Not enough scroll extent, recalculate
        AppLogger.d(
          '[ROUTE_BOTTOM_SPACE] _recalculateBottomSpace retrying '
          '(insufficient scroll extent: $currentMax < $headerDiff, '
          'bottomSpace=$_bottomSpace, attempt=$attempt)',
        );
        _bottomSpaceCalculated = false;
      }
    }
    if (_expandedHeight == null || _collapsedHeight == null) {
      AppLogger.d(
        '[ROUTE_BOTTOM_SPACE] _recalculateBottomSpace deferred '
        '(missing heights, attempt=$attempt, '
        'expanded=$_expandedHeight, collapsed=$_collapsedHeight)',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recalculateBottomSpace(attempt: attempt + 1);
      });
      return;
    }
    if (!_scrollController.hasClients) {
      AppLogger.d(
        '[ROUTE_BOTTOM_SPACE] _recalculateBottomSpace deferred '
        '(no scroll clients, attempt=$attempt)',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recalculateBottomSpace(attempt: attempt + 1);
      });
      return;
    }

    // Special case: no planned route items.
    //
    // Historically, when there was no planned route, we only showed a
    // small aesthetic padding (24 px) at the bottom and did NOT try to
    // guarantee that the header can fully collapse. Computing a full
    // "headerDiff" spacer here leads to a huge blank area on fresh
    // app start with an empty route, which is what you're observing.
    //
    // To keep the previous UX, we short‑circuit in this case.
    if (_lastPlannedRouteLength <= 0) {
      const newBottomSpace = 24;

      AppLogger.d(
        '[ROUTE_BOTTOM_SPACE] _recalculateBottomSpace no-content '
        '(routeLength=$_lastPlannedRouteLength, '
        'bottomSpace=$newBottomSpace, attempt=$attempt)',
      );

      if (!mounted ||
          _bottomSpaceCalculated && _bottomSpace == newBottomSpace) {
        return;
      }

      setState(() {
        _bottomSpace = newBottomSpace.toDouble();
        _bottomSpaceCalculated = true;
      });
      return;
    }

    final headerDiff =
        (_expandedHeight! - _collapsedHeight!).clamp(0.0, double.infinity);
    if (headerDiff <= 0) {
      AppLogger.d(
        '[ROUTE_BOTTOM_SPACE] _recalculateBottomSpace aborted '
        '(headerDiff=$headerDiff, attempt=$attempt)',
      );
      return;
    }

    // IMPORTANT: For a pinned SliverAppBar, we need maxScrollExtent to be
    // AT LEAST headerDiff to allow full collapse. The current maxScrollExtent
    // already includes any existing bottom spacer we added previously.
    //
    // To calculate the required bottom space:
    // 1. Get current maxScrollExtent (includes any previous bottom space)
    // 2. Subtract current bottom space to get the "natural" scroll extent
    // 3. Calculate how much more we need: max(0, headerDiff - naturalScrollExtent)
    //
    // We add a small buffer (8px) to account for any rounding errors or
    // layout quirks that might prevent full collapse.
    final rawMaxScrollExtent = _scrollController.position.maxScrollExtent;
    final currentSpacer = _bottomSpace;
    final naturalScrollExtent =
        (rawMaxScrollExtent - currentSpacer).clamp(0.0, double.infinity);

    // Safeguard: If natural scroll extent is 0 or very small and we have items,
    // it likely means the list hasn't laid out yet. Defer calculation.
    if (_lastPlannedRouteLength > 0 &&
        naturalScrollExtent < 10.0 &&
        attempt < 5) {
      AppLogger.d(
        '[ROUTE_BOTTOM_SPACE] _recalculateBottomSpace deferred '
        '(scroll extent too small: $naturalScrollExtent, likely incomplete layout, '
        'attempt=$attempt)',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recalculateBottomSpace(attempt: attempt + 1);
      });
      return;
    }

    // Calculate the required bottom space with a buffer
    final scrollDeficit = headerDiff - naturalScrollExtent;
    final requiredBottomSpace = scrollDeficit > 0
        ? scrollDeficit + 8.0 // Add buffer for rounding errors
        : 0.0;

    // Add aesthetic padding (24px) to the total
    final newBottomSpace = requiredBottomSpace + 24.0;

    AppLogger.d(
      '[ROUTE_BOTTOM_SPACE] _recalculateBottomSpace computed '
      'headerDiff=$headerDiff, rawMaxScrollExtent=$rawMaxScrollExtent, '
      'currentSpacer=$currentSpacer, naturalScrollExtent=$naturalScrollExtent, '
      'scrollDeficit=$scrollDeficit, requiredBottomSpace=$requiredBottomSpace, '
      'newBottomSpace=$newBottomSpace, attempt=$attempt, routeLength=$_lastPlannedRouteLength',
    );

    if (!mounted || _bottomSpaceCalculated && _bottomSpace == newBottomSpace) {
      return;
    }

    setState(() {
      _bottomSpace = newBottomSpace;
      _bottomSpaceCalculated = true;
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    // If we're in the middle of a snap animation, ignore scroll updates from the animation itself
    if (_isSnapping) {
      return false;
    }

    // Track scroll velocity for momentum-based snapping
    if (notification is ScrollUpdateNotification) {
      final now = DateTime.now();
      final timeDelta = now.difference(_lastScrollTime).inMilliseconds;

      if (timeDelta > 0) {
        final offset = notification.metrics.pixels;
        final offsetDelta = offset - _lastScrollOffset;

        // Calculate velocity in pixels per second
        _lastScrollVelocity = (offsetDelta / timeDelta) * 1000;

        _lastScrollOffset = offset;
        _lastScrollTime = now;
      }
    }

    // Auto-snap: Wait for scroll to completely settle
    // ScrollEndNotification fires when momentum scrolling ends
    if (notification is ScrollEndNotification) {
      // The drag has ended, but we should wait to ensure scroll has completely settled
      // This delay allows any momentum scrolling to finish
      AppLogger.d('[ROUTE_SNAP] Scroll ended, will check for snap in 200ms');
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_isSnapping && _scrollController.hasClients) {
          _handleAutoSnap();
        }
      });
    }

    return false;
  }

  void _handleAutoSnap() {
    if (!_scrollController.hasClients) {
      AppLogger.d('[ROUTE_SNAP] Skipped: no scroll clients');
      return;
    }
    if (_expandedHeight == null || _collapsedHeight == null) {
      AppLogger.d('[ROUTE_SNAP] Skipped: heights not measured');
      return;
    }

    final currentOffset = _scrollController.offset;
    final headerDiff = _expandedHeight! - _collapsedHeight!;

    // Don't snap if header diff is too small
    if (headerDiff < 1.0) {
      AppLogger.d('[ROUTE_SNAP] Skipped: header diff too small');
      return;
    }

    // Calculate how much of the header is collapsed (0.0 = fully expanded, 1.0 = fully collapsed)
    final collapseProgress = (currentOffset / headerDiff).clamp(0.0, 1.0);

    // If already at fully expanded or fully collapsed, no need to snap
    if (collapseProgress <= 0.01) {
      AppLogger.d('[ROUTE_SNAP] Skipped: already fully expanded');
      return;
    }
    if (collapseProgress >= 0.99) {
      AppLogger.d('[ROUTE_SNAP] Skipped: already fully collapsed');
      return;
    }

    // Determine target position based on:
    // 1. Scroll velocity (momentum-based snapping for better UX)
    // 2. Current position relative to threshold (fallback)
    double targetOffset;

    final velocity = _lastScrollVelocity;

    // If scrolling fast, continue in that direction (momentum snap)
    // Otherwise, snap to nearest state based on threshold
    if (velocity.abs() > _velocityThreshold) {
      // Fast scroll detected - snap in direction of momentum
      // Positive velocity = scrolling down = collapsing header
      targetOffset = velocity > 0 ? headerDiff : 0.0;
      AppLogger.d(
        '[ROUTE_SNAP] Momentum snap: velocity=${velocity.toStringAsFixed(1)} px/s, '
        'current=${(collapseProgress * 100).toStringAsFixed(1)}%, '
        'target=${velocity > 0 ? "collapsed" : "expanded"}',
      );
    } else {
      // Slow/normal scroll - snap based on position threshold
      targetOffset = collapseProgress >= _snapThreshold ? headerDiff : 0.0;
      AppLogger.d(
        '[ROUTE_SNAP] Position-based snap: current=${(collapseProgress * 100).toStringAsFixed(1)}%, '
        'threshold=${(_snapThreshold * 100).toStringAsFixed(0)}%, '
        'target=${collapseProgress >= _snapThreshold ? "collapsed" : "expanded"}',
      );
    }

    // Only animate if we're not already at the target
    if ((currentOffset - targetOffset).abs() > 1.0) {
      _animateToOffset(targetOffset);
    } else {
      AppLogger.d('[ROUTE_SNAP] Skipped: already at target position');
    }

    // Reset velocity after handling snap
    _lastScrollVelocity = 0.0;
  }

  void _animateToOffset(double targetOffset) {
    if (!_scrollController.hasClients || _isSnapping) return;

    final currentOffset = _scrollController.offset;
    final distance = (targetOffset - currentOffset).abs();

    // Skip if we're already very close to the target
    if (distance < 0.5) {
      AppLogger.d('[ROUTE_SNAP] Already at target, skipping animation');
      return;
    }

    setState(() {
      _isSnapping = true;
    });

    // Adjust animation duration based on distance for smoother UX
    // Shorter distances = faster animation
    final duration = Duration(
      milliseconds: (250 + (distance / 2)).clamp(250, 350).toInt(),
    );

    AppLogger.d(
      '[ROUTE_SNAP] Starting animation from ${currentOffset.toStringAsFixed(1)} '
      'to ${targetOffset.toStringAsFixed(1)} (distance: ${distance.toStringAsFixed(1)}px, '
      'duration: ${duration.inMilliseconds}ms)',
    );

    _scrollController
        .animateTo(
      targetOffset,
      duration: duration,
      curve: Curves.easeInOutCubic,
    )
        .then((_) {
      AppLogger.d('[ROUTE_SNAP] Animation completed successfully');
      if (mounted) {
        setState(() {
          _isSnapping = false;
        });
      }
    }).catchError((Object error) {
      AppLogger.d('[ROUTE_SNAP] Animation error: $error');
      if (mounted) {
        setState(() {
          _isSnapping = false;
        });
      }
    });
  }

  void _toggleExpanded() {
    // Don't toggle during auto-snap animation
    if (_isSnapping || !_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final headerDiff = (_expandedHeight ?? 480.0) - (_collapsedHeight ?? 200.0);

    // Determine target based on current state
    // If we're closer to expanded (< 50% scrolled), collapse it
    // If we're closer to collapsed (>= 50% scrolled), expand it
    final targetOffset =
        currentOffset < headerDiff * _snapThreshold ? headerDiff : 0.0;

    _animateToOffset(targetOffset);
  }

  Widget _buildCircleAction({
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
    IconData? icon,
    String? iconAsset,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NotificationBadge(
        badgeCount: badgeCount,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
          ),
          child: Stack(
            children: [
              Center(
                child: iconAsset != null
                    ? SvgPicture.asset(
                        iconAsset,
                        width: 20,
                        height: 20,
                        colorFilter:
                            ColorFilter.mode(iconColor, BlendMode.srcIn),
                      )
                    : Icon(icon, size: 22, color: iconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use fallback heights until measured
    final expandedH = _expandedHeight ?? 480.0;
    final collapsedH = _collapsedHeight ?? 200.0;
    return BlocListener<AppCubit, AppState>(
      listenWhen: (previous, current) =>
          previous.selectedRoute?.id != current.selectedRoute?.id ||
          previous.selectedStartingPoint?.id !=
              current.selectedStartingPoint?.id ||
          previous.selectedDestination?.id != current.selectedDestination?.id,
      listener: (context, state) {
        // Recalculate header heights after the frame in which new AppState
        // data has been rendered. Using a post-frame callback is the
        // recommended way to run layout-dependent code.
        WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeights());
      },
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          final primaryColor =
              context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
          final iconColor = context.isDarkMode ? Colors.black : Colors.white;
          return Scaffold(
            appBar: CaminoNinjaAppBar.main(
              actions: [
                _buildCircleAction(
                  icon: Icons.campaign_outlined,
                  backgroundColor: primaryColor,
                  iconColor: iconColor,
                  badgeCount: state.unreadNotificationsBadgeCount,
                  onTap: () async {
                    await context.push('/announcements');
                    if (context.mounted) {
                      context.read<AppCubit>().refreshNotificationsBadge();
                    }
                  },
                ),
                const SizedBox(width: 8),
                _buildCircleAction(
                  iconAsset: 'assets/ic_bookmark_outline.svg',
                  backgroundColor: primaryColor,
                  iconColor: iconColor,
                  onTap: () => context.push('/more/saved-accommodations'),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: Builder(
              builder: (context) {
                if (state.loadingData || state.updatingData) {
                  return ProgressIndicatorWidget(state: state);
                }
                if (state.offlineAndNoData) {
                  return const OfflineNoDataWidget();
                }

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Offstage(
                      child: Column(
                        children: [
                          _buildExpandedContent(
                            state,
                            key: _expandedKey,
                            enableAnimation: false,
                          ),
                          _buildCollapsedContent(
                            state,
                            key: _collapsedKey,
                            enableAnimation: false,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildBody(state, expandedH, collapsedH),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedContent(
    AppState state, {
    Key? key,
    bool enableAnimation = true,
  }) {
    return ExpandableRouteSelection(
      state: state,
      key: key,
      isExpanded: true,
      enableAnimation: enableAnimation,
      onToggleExpandTap: _toggleExpanded,
    );
  }

  Widget _buildCollapsedContent(
    AppState state, {
    Key? key,
    bool enableAnimation = true,
  }) {
    return ExpandableRouteSelection(
      state: state,
      key: key,
      isExpanded: false,
      enableAnimation: enableAnimation,
      onToggleExpandTap: _toggleExpanded,
    );
  }

  Widget _buildBody(
    AppState state,
    double expandedHeight,
    double collapsedHeight,
  ) {
    final plannedRoute = state.plannedRoute ?? [];

    // Detect changes in list length and force a recompute of bottom space
    // on the next frame so that short/long content updates are reflected.
    if (_lastPlannedRouteLength != plannedRoute.length) {
      AppLogger.d(
        '[ROUTE_BOTTOM_SPACE] plannedRoute length changed: '
        '$_lastPlannedRouteLength -> ${plannedRoute.length}',
      );

      _lastPlannedRouteLength = plannedRoute.length;
      _bottomSpaceCalculated = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recalculateBottomSpace();
      });
    }

    final screenHeight = MediaQuery.of(context).size.height;

    final bottomSpace = plannedRoute.isEmpty ? screenHeight : _bottomSpace;
    return Column(
      children: [
        if (state.dataUpdateAvailable) ...[
          const UpdateNowWidget(),
        ],
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: expandedHeight,
                  collapsedHeight: collapsedHeight,
                  toolbarHeight: collapsedHeight,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 4,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final settings =
                          context.dependOnInheritedWidgetOfExactType<
                              FlexibleSpaceBarSettings>();

                      if (settings == null) {
                        return _buildCollapsedContent(state);
                      }

                      final deltaExtent =
                          settings.maxExtent - settings.minExtent;
                      final t = deltaExtent > 0
                          ? (1.0 -
                                  (settings.currentExtent -
                                          settings.minExtent) /
                                      deltaExtent)
                              .clamp(0.0, 1.0)
                          : 1.0;

                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 1.0 - t,
                              child: IgnorePointer(
                                ignoring: t > 0.5,
                                child: _buildExpandedContent(state),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Opacity(
                              opacity: t,
                              child: IgnorePointer(
                                ignoring: t < 0.5,
                                child: _buildCollapsedContent(state),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SliverList.builder(
                  itemCount: plannedRoute.length,
                  itemBuilder: (context, index) {
                    return CityListItem(
                      distanceGroupKey: _distanceGroupKey,
                      destination: plannedRoute[index],
                      isFirst: index == 0,
                      showInBetweenDistance: true,
                      showFullText: false,
                      onClick: () {
                        context.push(
                          RouterLocations.cityDetails(
                            cityId: plannedRoute[index].id,
                          ),
                        );
                      },
                    );
                  },
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: bottomSpace,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
