import 'dart:async';
import 'dart:math';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/elevation_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/new_elevation_chart_painters.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/new_elevation_chart_styles.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/new_elevation_chart_utils.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

// Re-export styles and painters for backwards compatibility
export 'package:camino_ninja_flutter/tabs/route/screens/elevation/new_elevation_chart_painters.dart';
export 'package:camino_ninja_flutter/tabs/route/screens/elevation/new_elevation_chart_styles.dart';

// -- MAIN APPLICATION WIDGET --

/// Main elevation chart widget that displays the route elevation profile
class NewElevationChartWiget extends StatefulWidget {
  const NewElevationChartWiget({
    required this.routePoints,
    required this.cities,
    required this.unit,
    super.key,
    this.currentPosition,
    this.yAxisPaddingMeters = 100.0, // Adjustable padding above max elevation
    this.isInteractive = false,
  });
  final List<ChartRoutePoint> routePoints;
  final List<ChartCity> cities;
  final Position? currentPosition;
  final double yAxisPaddingMeters; // Extra padding above max elevation
  final UnitEnum unit;
  final bool isInteractive;

  @override
  State<NewElevationChartWiget> createState() => _NewElevationChartWigetState();
}

class _NewElevationChartWigetState extends State<NewElevationChartWiget> {
  final ScrollController _scrollController = ScrollController();
  final double leftColumnWidth = 50;
  StreamSubscription<ElevationState>? _elevationSubscription;

  // Cached computed values to avoid recalculation on every build
  late double _cachedMaxElevation;
  late double _cachedTotalChartWidth;

  @override
  void initState() {
    super.initState();
    _computeCachedValues();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _elevationSubscription =
          context.read<ElevationCubit>().stream.listen((state) {
        if (state.currentPosition != null) {
          _scrollToCurrentUser(state.currentPosition!);
        }
      });
    });
  }

  @override
  void didUpdateWidget(NewElevationChartWiget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routePoints != widget.routePoints ||
        oldWidget.yAxisPaddingMeters != widget.yAxisPaddingMeters) {
      _computeCachedValues();
    }
  }

  void _computeCachedValues() {
    final totalDistance = widget.routePoints.isNotEmpty
        ? widget.routePoints.last.distanceInMeters
        : 0.0;
    _cachedTotalChartWidth = totalDistance / 2.5;
    _cachedMaxElevation = widget.routePoints.isNotEmpty
        ? widget.routePoints.map((p) => p.ele).reduce(max) +
            widget.yAxisPaddingMeters
        : widget.yAxisPaddingMeters;
  }

  /// Scrolls the elevation chart to center the user's current position.
  /// Only scrolls if user is within 3000 meters of the nearest route point.
  void _scrollToCurrentUser(Position currentPosition) {
    if (widget.routePoints.length < 2) return;

    // Edge case: Check for valid total distance
    final totalDistance = widget.routePoints.last.distanceInMeters;
    if (totalDistance <= 0) return;

    final totalChartWidth = totalDistance / 2.5;

    // Find nearest waypoint and check distance
    final result = NewElevationChartUtils.findNearestWaypoint(
        currentPosition, widget.routePoints,);
    if (result.distance > NewElevationChartUtils.maxDistanceFromRoute) {
      // User is too far from route, don't scroll
      return;
    }

    var userDistance = result.routeDistance;

    // Edge case: Ensure userDistance is within valid bounds
    userDistance = userDistance.clamp(0.0, totalDistance);

    // Calculate the pixel position
    final scrollableWidth = totalChartWidth;
    final userXPosition = (userDistance / totalDistance) * scrollableWidth;

    // Center the user's position in the available viewport
    final screenWidth = MediaQuery.of(context).size.width;
    final viewportWidth = screenWidth - leftColumnWidth;
    final targetScrollOffset = userXPosition - (viewportWidth / 2);

    // Edge case: Check if scroll controller is ready
    if (!_scrollController.hasClients) return;

    // Animate to the position, clamping to valid scroll extents
    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedTarget = targetScrollOffset.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      clampedTarget,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _elevationSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final chartStyle = _buildChartStyle(context, isDarkMode);

    // Use cached values instead of computing on every build
    final totalChartWidth = _cachedTotalChartWidth;
    final maxElevation = _cachedMaxElevation;

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4,
      scaleEnabled: widget.isInteractive,
      panEnabled: widget.isInteractive,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF141218) : AppColors.gray200,
        ),
        child: ClipRRect(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // --- SCROLLABLE CHART AREA (in the back) ---
                  RepaintBoundary(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        left: 60,
                      ),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: totalChartWidth,
                        height: constraints.maxHeight,
                        child: CustomPaint(
                          painter: OptimizedElevationChartPainter(
                            unit: widget.unit,
                            leftAxisWidth: leftColumnWidth,
                            elevationPoints: widget.routePoints,
                            cities: widget.cities,
                            currentUserLocation: widget.currentPosition,
                            style: chartStyle,
                            maxElevation: maxElevation,
                            scrollController: _scrollController,
                            viewportWidth: MediaQuery.of(context).size.width -
                                leftColumnWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // --- FIXED LEFT Y-AXIS COLUMN (in the front) ---
                  RepaintBoundary(
                    child: SizedBox(
                      width: leftColumnWidth,
                      height: constraints.maxHeight,
                      child: CustomPaint(
                        painter: YAxisPainter(
                          unit: widget.unit,
                          maxElevation: maxElevation,
                          style: chartStyle,
                        ),
                      ),
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

  ElevationChartStyle _buildChartStyle(BuildContext context, bool isDarkMode) {
    return ElevationChartStyle(
      unitLabelStyle: UnitLabelStyle(
        textStyle: context.textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.black : Colors.white,
            ) ??
            const TextStyle(),
        containerColor: isDarkMode ? AppColors.gray300 : AppColors.gray400,
        borderColor: Colors.transparent,
        borderWidth: 0,
        borderRadius: const Radius.circular(6),
        padding: const EdgeInsets.symmetric(
          horizontal: 2.5,
          vertical: 3,
        ),
      ),
      cityContainerStyle: CityContainerStyle(
        containerWidth: 24,
        color: isDarkMode ? const Color(0xFF323232) : Colors.white,
        separatorColor: Colors.black,
        cityTextStyle: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black,
            ) ??
            const TextStyle(),
        distanceTextStyle: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black,
            ) ??
            const TextStyle(),
      ),
      currentLocationStyle: CurrentLocationStyle(
        lineWidth: 1,
        lineColor: const Color(0xFF0E9F6E),
        circleSize: 4,
        circleColor: const Color(0xFF0E9F6E),
        textStyle: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0E9F6E),
            ) ??
            const TextStyle(),
        label: AppLocalizations.of(context).youAreHere,
      ),
      chartLineStyle: ChartLineStyle(
        lineColor: isDarkMode ? AppColors.primary80 : AppColors.primary40,
        fillColor: isDarkMode
            ? AppColors.gray600.withOpacity(0.8)
            : AppColors.gray700.withOpacity(0.8),
      ),
      gridStyle: GridStyle(
        lineWidth: 0.5,
        lineColor: isDarkMode ? AppColors.gray600 : AppColors.gray400,
      ),
      intervalConfig: ChartIntervalConfig.forUnit(widget.unit),
    );
  }
}
