import 'dart:math';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/new_elevation_chart.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/new_elevation_chart_utils.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide Position;

// Your main widget
class ElevationChartV2 extends StatefulWidget {
  const ElevationChartV2({
    required this.routePoints,
    required this.cities,
    required this.unit,
    super.key,
    this.currentPosition,
    this.isFullScreen = false,
  });
  final List<ChartRoutePoint> routePoints;
  final List<ChartCity> cities;
  final Position? currentPosition;
  final UnitEnum unit;
  final bool isFullScreen;

  @override
  State<ElevationChartV2> createState() => _ElevationChartV2State();
}

class _ElevationChartV2State extends State<ElevationChartV2> {
  late List<ChartRoutePoint> _chartData;
  late List<ChartCity> _cityData;
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  late NumericAxis _primaryXAxis;
  NumericAxisController? _numericAxisController;
  late ChartIntervalConfig _chartIntervalConfig;
  bool _alreadyZoomToUserPosition = false;

  // Current user location (distance in km along the route)
  double? _currentUserDistance;

  // Track visible range for dynamic intervals
  double _visibleMinimum = 0;
  double _visibleMaximum = 0;

  // Track previous zoom state to avoid unnecessary rebuilds
  double _previousZoomFactor = 1;

  @override
  void initState() {
    super.initState();
    _chartData = widget.routePoints;
    _cityData = widget.cities;
    _chartIntervalConfig = ChartIntervalConfig.forUnit(widget.unit);
    _visibleMaximum = _chartData.isNotEmpty ? _chartData.last.distance : 0;
    _primaryXAxis = NumericAxis(
      minimum: 0,
      maximum: _chartData.last.distance,
      // Make axis completely invisible to eliminate reserved space
      isVisible: false,
      // CRITICAL: Remove axis padding that causes top space
      rangePadding: ChartRangePadding.none,
      plotOffset: 0,
      plotOffsetStart: 0,
      plotOffsetEnd: 0,
      // DISABLE auto interval - we handle this manually
      // enableAutoIntervalOnZooming: true,
      onRendererCreated: (p0) {
        _numericAxisController = p0;
      },
    );
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true, // This allows dragging on chart
      enableDoubleTapZooming: true,
      enableMouseWheelZooming: true,
      zoomMode: ZoomMode.x, // Only horizontal zoom/pan
      enableSelectionZooming: true,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_numericAxisController != null) {
          _numericAxisController!.visibleMinimum = 0;
          _numericAxisController!.visibleMaximum = _chartData.last.distance;
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      color: Theme.of(context).colorScheme.surface,
      header: AppLocalizations.of(context).youAreHere,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
          int seriesIndex,) {
        if (data is ChartRoutePoint) {
          final formattedDistance = UnitConverter.displayDistance(
            kilometers: data.distance,
            unit: widget.unit,
          );
          final formattedElevation = UnitConverter.displayElevation(
            meters: data.ele,
            unit: widget.unit,
          );

          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context).distance.capitalizeFirstLetter()}: $formattedDistance',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${AppLocalizations.of(context).elevation.capitalizeFirstLetter()}: $formattedElevation',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Helper method to select cities hierarchically using stable grid
  List<ChartCity> _selectCitiesHierarchically(
      List<ChartCity> cities, int targetCount, double totalDistance,) {
    if (cities.isEmpty || targetCount <= 0) return [];
    if (cities.length <= targetCount) return cities;

    // Use a stable grid system
    const fixedGridSize = 100; // More buckets for better granularity
    final bucketSize = totalDistance > 0 ? totalDistance / fixedGridSize : 1.0;
    final gridBuckets = <int, List<ChartCity>>{};

    // Group cities into fixed buckets
    for (final city in cities) {
      final bucketIndex = (city.distance / bucketSize).floor();
      gridBuckets.putIfAbsent(bucketIndex, () => []).add(city);
    }

    // Select cities from buckets with stable spacing
    final selectedCities = <ChartCity>[];
    final bucketIndices = gridBuckets.keys.toList()..sort();

    if (bucketIndices.length <= targetCount) {
      // If we have fewer buckets than target, show all cities
      selectedCities.addAll(cities);
    } else {
      // Select cities from buckets with stable spacing
      final step = bucketIndices.length / targetCount;
      for (var i = 0; i < targetCount; i++) {
        final bucketIndex = bucketIndices[(i * step).floor()];
        final citiesInBucket = gridBuckets[bucketIndex]!;

        // Select the city closest to the bucket center
        final bucketCenter = bucketIndex * bucketSize + bucketSize / 2;
        final closestCity = citiesInBucket.reduce((a, b) =>
            (a.distance - bucketCenter).abs() <
                    (b.distance - bucketCenter).abs()
                ? a
                : b,);
        selectedCities.add(closestCity);
      }
    }

    return selectedCities;
  }

  // Helper method to get elevation at specific distance
  double _getElevationAtDistance(double distance) {
    // Find the closest data point or interpolate between two points
    for (var i = 0; i < _chartData.length - 1; i++) {
      final current = _chartData[i];
      final next = _chartData[i + 1];

      if (distance >= current.distance && distance <= next.distance) {
        // Linear interpolation between two points
        final ratio =
            (distance - current.distance) / (next.distance - current.distance);
        return current.ele + (next.ele - current.ele) * ratio;
      }
    }

    // If not found, return closest point
    return _chartData.first.ele;
  }

  double? _calculateUserDistance(Position? currentPosition) {
    if (currentPosition == null) return null;
    if (widget.routePoints.isEmpty) return null;

    final nearestRoutePoint = NewElevationChartUtils.findNearestWaypoint(
        currentPosition, widget.routePoints,);

    if (nearestRoutePoint.distance >
        NewElevationChartUtils.maxDistanceFromRoute) {
      // User is too far from route, don't scroll
      return null;
    }

    return nearestRoutePoint.routeDistance;
  }

  (double, double) _calculateVisibleRange(double distance) {
    const bound = 0.5;
    final lowerBound = distance - bound;
    final upperBound = distance + bound;

    // Clamp the bounds to the min and max values
    final double number1 = max(0, lowerBound);
    final double number2 = min(_chartData.last.distance, upperBound);

    return (number1, number2);
  }

  /// Calculate dynamic x-axis interval to prevent label overlap
  double _calculateDynamicXAxisInterval(BuildContext context) {
    // Step 1: Calculate maximum labels that can fit on screen
    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth = screenWidth * 0.9; // Chart takes 90% of screen width

    // Estimate label width with some spacing
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    const sampleLabelText = '19999km';
    final textPainter = TextPainter(
      text: TextSpan(text: sampleLabelText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelWidthWithSpacing =
        textPainter.width + 30; // Add spacing between labels

    final maxLabels = (chartWidth / labelWidthWithSpacing).floor();
    final safeMaxLabels = max(2, maxLabels); // At least 2 labels

    // Step 2: Get current visible range from zoom level
    final currentVisibleRange = _visibleMaximum - _visibleMinimum;

    // Step 3: Calculate ideal interval for current range
    final idealInterval = currentVisibleRange / safeMaxLabels;

    // Step 4: Find the nearest multiple of base interval
    final baseInterval = _chartIntervalConfig.xAxisInterval;
    final multiplier = (idealInterval / baseInterval).ceil();
    final finalInterval = baseInterval * multiplier;

    return max(baseInterval, finalInterval);
  }

  @override
  void didUpdateWidget(covariant ElevationChartV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPosition != oldWidget.currentPosition) {
      _currentUserDistance = _calculateUserDistance(widget.currentPosition);
      if (_currentUserDistance != null &&
          !_alreadyZoomToUserPosition &&
          _numericAxisController != null) {
        final zoomRange = _calculateVisibleRange(_currentUserDistance!);
        _alreadyZoomToUserPosition = true;
        _numericAxisController!.visibleMinimum = zoomRange.$1;
        _numericAxisController!.visibleMaximum = zoomRange.$2;
        _visibleMaximum = zoomRange.$2;
        _visibleMinimum = zoomRange.$1;
      }
    }
  }

  // Helper method to build Y-axis labels widget
  Widget _buildFixedYAxisLabels(
      BuildContext context, double maxElevationWithPadding,) {
    final isDarkMode = context.isDarkMode;

    return Positioned(
      left: 10,
      top: 0,
      bottom: 0,
      width: 60, // Fixed width for Y-axis labels
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartHeight = constraints.maxHeight;
          // Dynamically compute an effective Y-axis interval to avoid overlapping labels
          final baseInterval = _chartIntervalConfig.yAxisInterval;
          final textStyle = context.textTheme.bodyMedium
                  ?.copyWith(fontSize: 10, fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 10, fontWeight: FontWeight.bold);
          // Use a sample label to estimate the rendered height (includes text height + container vertical padding)
          final sampleLabelText = UnitConverter.displayElevation(
            meters: maxElevationWithPadding,
            unit: widget.unit,
            space: false,
          );
          final textPainter = TextPainter(
            text: TextSpan(text: sampleLabelText, style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          final estimatedLabelHeight =
              textPainter.height + 6; // container vertical padding = 3 + 3
          final minimumGap = estimatedLabelHeight + 4; // add 4px breathing room

          // Pixels for one base interval in the current chart height
          final pixelsPerBaseInterval =
              chartHeight * (baseInterval / maxElevationWithPadding);
          // If pixels per base interval are too small, scale up the interval (2x, 3x, ...)
          final multiplier = pixelsPerBaseInterval <= 0
              ? 1
              : (minimumGap / pixelsPerBaseInterval).ceil().clamp(1, 1000000);
          final effectiveInterval = baseInterval * multiplier;

          return ColoredBox(
            color: Colors.transparent,
            child: Stack(
              children: List.generate(
                (maxElevationWithPadding / effectiveInterval).floor() + 2,
                (index) {
                  final elevation = (index + 1) * effectiveInterval;
                  if (elevation <= maxElevationWithPadding) {
                    // Calculate relative position from bottom (0) to top (maxElevationWithPadding)
                    final relativePosition =
                        elevation / maxElevationWithPadding;
                    // Convert to Flutter coordinates (top-down) and position from bottom
                    final topPosition = chartHeight * (1 - relativePosition) -
                        10; // -10 to center the label

                    return Positioned(
                      top: topPosition,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2.5,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.gray300
                              : AppColors.gray400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          UnitConverter.displayElevation(
                            meters: elevation,
                            unit: widget.unit,
                            space: false,
                          ),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ).where((widget) => widget is! SizedBox).toList(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    double? currentElevation;
    if (_currentUserDistance != null) {
      currentElevation = _getElevationAtDistance(_currentUserDistance!);
    }
    final maxElevation =
        _chartData.map((e) => e.ele).reduce((a, b) => a > b ? a : b);
    // Add padding to Y-axis to prevent chart line from hitting the top
    final maxElevationWithPadding = maxElevation + 150;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox.expand(
          child: Stack(
            children: [
              // Main chart with left margin for fixed Y-axis
              Positioned(
                left: 0, // Make room for fixed Y-axis
                top: 0,
                right: 0,
                bottom: 0,
                child: SfCartesianChart(
                  // Completely remove title - don't even define it

                  // Remove all borders and padding
                  plotAreaBorderWidth: 0,
                  plotAreaBorderColor: Colors.transparent,

                  // Remove all margins and make backgrounds transparent
                  margin: EdgeInsets.zero,

                  // Set backgrounds to transparent for fullscreen edge-to-edge
                  plotAreaBackgroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,

                  // Enable zooming and panning directly on chart
                  zoomPanBehavior: _zoomPanBehavior,

                  // Enable interactive tooltips
                  tooltipBehavior: _tooltipBehavior,

                  // Listen to zoom events to trigger recalculation
                  onZooming: (ZoomPanArgs args) {
                    final newZoomFactor = args.currentZoomFactor;

                    if (newZoomFactor != _previousZoomFactor) {
                      setState(() {
                        // Get actual visible range from the axis controller
                        if (_numericAxisController != null) {
                          _visibleMinimum =
                              _numericAxisController!.visibleMinimum ?? 0.0;
                          _visibleMaximum =
                              _numericAxisController!.visibleMaximum ?? 0.0;
                        }
                        _previousZoomFactor = newZoomFactor;
                      });
                    }
                  },

                  // Define the axes as completely invisible to eliminate reserved space
                  primaryXAxis: _primaryXAxis,
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum:
                        _chartData.isNotEmpty ? maxElevationWithPadding : 600,
                    // Make axis completely invisible to eliminate reserved space
                    isVisible: false,
                    // CRITICAL: Remove axis padding that causes top space
                    rangePadding: ChartRangePadding.none,
                    plotOffset: 0,
                    plotOffsetStart: 0,
                    plotOffsetEnd: 0,
                  ),

                  // Define the series (including manual gridlines)
                  series: <CartesianSeries<dynamic, double>>[
                    // Manual horizontal gridlines (Y-axis) - density aware
                    ...(() {
                      final baseY = _chartIntervalConfig.yAxisInterval;
                      // Cap number of horizontal lines to a reasonable amount based on screen height
                      final screenHeight = MediaQuery.of(context).size.height;
                      final maxLines = (screenHeight / 60).floor().clamp(4, 16);
                      final requiredLines =
                          (maxElevationWithPadding / baseY).ceil();
                      final multiplier =
                          (requiredLines / maxLines).ceil().clamp(1, 1000);
                      final effectiveY = baseY * multiplier;

                      final grid = <LineSeries<ChartRoutePoint, double>>[];
                      for (var elevation = effectiveY;
                          elevation <= maxElevationWithPadding;
                          elevation += effectiveY) {
                        grid.add(
                          LineSeries<ChartRoutePoint, double>(
                            dataSource: [
                              ChartRoutePoint(
                                id: 0,
                                lat: 0,
                                lon: 0,
                                ele: elevation,
                                distance: 0,
                              ),
                              ChartRoutePoint(
                                id: _chartData.last.id,
                                lat: _chartData.last.lat,
                                lon: _chartData.last.lon,
                                ele: elevation,
                                distance: _chartData.last.distance,
                              ),
                            ],
                            xValueMapper: (ChartRoutePoint data, _) =>
                                data.distance,
                            yValueMapper: (ChartRoutePoint data, _) => data.ele,
                            name: 'Grid Y $elevation',
                            color: isDarkMode
                                ? AppColors.gray600
                                : AppColors.gray400,
                            width: 0.5,
                          ),
                        );
                      }
                      return grid;
                    })(),

                    // Manual vertical gridlines (X-axis) - visible range only
                    ...(() {
                      final dynamicInterval =
                          _calculateDynamicXAxisInterval(context);
                      final totalDistance = _chartData.isNotEmpty
                          ? _chartData.last.distance
                          : 0.0;

                      // Match the X-axis labels logic exactly
                      final totalLabels =
                          (totalDistance / dynamicInterval).round() + 1;

                      final gridLines = <LineSeries<ChartRoutePoint, double>>[];
                      for (var index = 0; index < totalLabels; index++) {
                        final distance = (index + 1) * dynamicInterval;
                        if (distance <= totalDistance) {
                          gridLines.add(LineSeries<ChartRoutePoint, double>(
                            dataSource: [
                              ChartRoutePoint(
                                id: 0,
                                lat: 0,
                                lon: 0,
                                ele: 0,
                                distance: distance,
                              ),
                              ChartRoutePoint(
                                id: 0,
                                lat: _chartData.last.lat,
                                lon: _chartData.last.lon,
                                ele: maxElevationWithPadding,
                                distance: distance,
                              ),
                            ],
                            xValueMapper: (ChartRoutePoint data, _) =>
                                data.distance,
                            yValueMapper: (ChartRoutePoint data, _) => data.ele,
                            name: 'Grid X $distance',
                            color: isDarkMode
                                ? AppColors.gray600
                                : AppColors.gray400,
                            width: 0.5,
                          ),);
                        }
                      }
                      return gridLines;
                    })(),

                    // Main elevation profile
                    SplineAreaSeries<ChartRoutePoint, double>(
                      dataSource: _chartData,
                      xValueMapper: (ChartRoutePoint data, _) => data.distance,
                      yValueMapper: (ChartRoutePoint data, _) => data.ele,
                      name: 'Elevation',
                      color: isDarkMode
                          ? AppColors.gray600.withOpacity(0.8)
                          : AppColors.gray700.withOpacity(0.8),
                      borderColor: isDarkMode
                          ? AppColors.primary80
                          : AppColors.primary40,
                      borderWidth: 3,
                    ),
                  ],

                  // Custom axis labels and annotations inside the chart
                  annotations: [
                    // City name annotations (density-aware, always include first/last city)
                    ...(() {
                      if (_cityData.isEmpty) {
                        return <CartesianChartAnnotation>[];
                      }

                      final firstCity = _cityData.first;
                      final lastCity = _cityData.last;

                      // Consider only interior cities for density logic
                      final interior = _cityData.skip(1).take(
                          _cityData.length > 1 ? _cityData.length - 2 : 0,);

                      // Do NOT return early if there are no interior visible cities.
                      // We still want to render edge cities (first/last) at all zoom levels.

                      // Get current visible range to determine zoom level
                      final visibleMin =
                          _numericAxisController?.visibleMinimum ?? 0.0;
                      final visibleMax =
                          _numericAxisController?.visibleMaximum ??
                              (_chartData.isNotEmpty
                                  ? _chartData.last.distance
                                  : 0.0);
                      final visibleRange = visibleMax - visibleMin;
                      final totalChartDistance = _chartData.isNotEmpty
                          ? _chartData.last.distance
                          : 0.0;

                      // Calculate zoom level (0 = fully zoomed out, 1 = fully zoomed in)
                      final zoomLevel = totalChartDistance > 0
                          ? ((totalChartDistance - visibleRange) /
                                  totalChartDistance)
                              .clamp(0.0, 1.0)
                          : 0.0;

                      // Estimate how many columns can fit based on screen width
                      final screenWidth = MediaQuery.of(context).size.width;
                      const baseMinPixelsPerCity =
                          80.0; // Base spacing for fully zoomed out
                      const zoomedMinPixelsPerCity =
                          40.0; // Closer spacing when zoomed in

                      // Interpolate between base and zoomed spacing based on zoom level
                      final minPixelsPerCity = baseMinPixelsPerCity -
                          (baseMinPixelsPerCity - zoomedMinPixelsPerCity) *
                              zoomLevel;

                      final maxColumns = (screenWidth / minPixelsPerCity)
                          .floor()
                          .clamp(1, 999);

                      final finalCities = <ChartCity>[];

                      // Implement hierarchical city selection to prevent blinking
                      // Cities visible at higher zoom levels (more detail) should always remain visible
                      // at lower zoom levels (less detail)
                      final allCities = interior.toList();

                      // Define hierarchical zoom levels with different city densities
                      // Each level includes all cities from higher levels plus additional ones
                      final hierarchicalCities = <ChartCity>[];

                      // Level 1: Base cities (always visible) - very sparse
                      final level1Count = max(2, (maxColumns * 0.3).round());
                      final level1Cities = _selectCitiesHierarchically(
                          allCities, level1Count, totalChartDistance,);
                      hierarchicalCities.addAll(level1Cities);

                      // Level 2: Medium density cities (visible when zoomed in more)
                      var level2Count = level1Count;
                      if (zoomLevel > 0.3) {
                        level2Count =
                            max(level1Count, (maxColumns * 0.6).round());
                        // Only add cities that aren't already in level 1
                        final level2Cities = _selectCitiesHierarchically(
                            allCities, level2Count, totalChartDistance,);
                        final newCities = level2Cities
                            .where((city) => !level1Cities.any((existing) =>
                                existing.distance == city.distance,),)
                            .toList();
                        hierarchicalCities.addAll(newCities);
                      }

                      // Level 3: High density cities (visible when zoomed in even more)
                      var level3Count = level2Count;
                      if (zoomLevel > 0.6) {
                        level3Count =
                            max(level2Count, (maxColumns * 0.9).round());
                        final level3Cities = _selectCitiesHierarchically(
                            allCities, level3Count, totalChartDistance,);
                        final newCities = level3Cities
                            .where((city) => !hierarchicalCities.any(
                                (existing) =>
                                    existing.distance == city.distance,),)
                            .toList();
                        hierarchicalCities.addAll(newCities);
                      }

                      // Level 4: Maximum density (visible when fully zoomed in)
                      if (zoomLevel > 0.8) {
                        final level4Count = maxColumns;
                        final level4Cities = _selectCitiesHierarchically(
                            allCities, level4Count, totalChartDistance,);
                        final newCities = level4Cities
                            .where((city) => !hierarchicalCities.any(
                                (existing) =>
                                    existing.distance == city.distance,),)
                            .toList();
                        hierarchicalCities.addAll(newCities);
                      }

                      finalCities.addAll(hierarchicalCities);

                      // Remove duplicates and sort by distance
                      final uniqueCities = <ChartCity>[];
                      final seenDistances = <double>{};
                      for (final city in finalCities) {
                        if (!seenDistances.contains(city.distance)) {
                          seenDistances.add(city.distance);
                          uniqueCities.add(city);
                        }
                      }
                      uniqueCities
                          .sort((a, b) => a.distance.compareTo(b.distance));

                      // Always include first and last city
                      final withEdgeCities = <ChartCity>[
                        firstCity,
                        ...uniqueCities,
                        if (_cityData.length > 1 &&
                            lastCity.distance != firstCity.distance)
                          lastCity,
                      ]..sort((a, b) => a.distance.compareTo(b.distance));

                      return withEdgeCities.map((city) {
                        return CartesianChartAnnotation(
                          widget: RotatedBox(
                            quarterTurns: 3, // Rotate 90° counter-clockwise
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: city.distance == 0 ? 20 : 0,
                                  bottom:
                                      city.distance == _chartData.last.distance
                                          ? 20
                                          : 0,),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF323232)
                                    : Colors.white,
                                border: const Border(
                                  right: BorderSide(),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Text(
                                    '${city.distance.toInt()}km',
                                    style:
                                        context.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      city.name,
                                      style:
                                          context.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Text(
                                    '${city.distance.toInt()}km',
                                    style:
                                        context.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                              ),
                            ),
                          ),
                          coordinateUnit: CoordinateUnit.point,
                          x: city.distance,
                          y: maxElevationWithPadding / 2,
                        );
                      }).toList();
                    })(),

                    // Custom X-axis labels inside chart (distance labels at bottom)
                    ...(() {
                      final dynamicInterval =
                          _calculateDynamicXAxisInterval(context);
                      final totalDistance =
                          _chartData.isNotEmpty ? _chartData.last.distance : 0;
                      final totalLabels =
                          (totalDistance / dynamicInterval).round() + 1;

                      // Calculate Y position as data value that corresponds to 30px from bottom
                      final chartHeight = constraints.maxHeight;
                      final elevationPerPixel =
                          maxElevationWithPadding / chartHeight;
                      final elevationFor30pxFromBottom = elevationPerPixel * 20;

                      final labels = <CartesianChartAnnotation>[];
                      for (var index = 0; index < totalLabels; index++) {
                        final distance = (index + 1) *
                            dynamicInterval; // Start from first interval instead of 0km
                        if (distance <= totalDistance) {
                          labels.add(
                            CartesianChartAnnotation(
                              widget: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2.5,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppColors.gray300
                                      : AppColors.gray400,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  UnitConverter.displayDistance(
                                    kilometers: distance,
                                    unit: widget.unit,
                                    space: false,
                                  ),
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              coordinateUnit: CoordinateUnit.point,
                              x: distance,
                              y: elevationFor30pxFromBottom, // Data value equivalent to 20px from bottom
                            ),
                          );
                        }
                      }
                      return labels;
                    })(),

                    // Y-axis labels are now handled by the fixed overlay widget
                    // Removed from here to prevent scrolling with chart

                    // Current user position annotations (rendered LAST to appear on top)
                    if (_currentUserDistance != null &&
                        currentElevation != null) ...[
                      ...List.generate(
                        currentElevation.toInt(),
                        (value) => CartesianChartAnnotation(
                          widget: Container(
                            width: 3,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0E9F6E),
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(
                                  color: Color(0xFF0E9F6E),
                                ),
                              ),
                            ),
                          ),
                          coordinateUnit: CoordinateUnit.point,
                          x: _currentUserDistance,
                          y: value,
                        ),
                      ),

                      // Current location point marker
                      CartesianChartAnnotation(
                        widget: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0E9F6E),
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(
                                color: Color(0xFF0E9F6E),
                              ),
                            ),
                          ),
                        ),
                        coordinateUnit: CoordinateUnit.point,
                        x: _currentUserDistance,
                        y: currentElevation,
                      ),

                      // "You are here" text
                      CartesianChartAnnotation(
                        widget: Text(
                          AppLocalizations.of(context).youAreHere,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF0E9F6E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        coordinateUnit: CoordinateUnit.point,
                        x: _currentUserDistance,
                        y: currentElevation + 30,
                      ),
                    ],
                  ],
                ),
              ),

              // Fixed Y-axis labels overlay
              _buildFixedYAxisLabels(context, maxElevationWithPadding),
            ],
          ),
        );
      },
    );
  }
}
