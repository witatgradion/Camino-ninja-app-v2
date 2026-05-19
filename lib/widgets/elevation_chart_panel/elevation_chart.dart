import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const _kSideTitleReservedExtent = 12.0;
final _kChartBorderSide = BorderSide(
  color: const Color(0xFF767680).withOpacity(0.7),
);

/// Helper function to calculate nice rounded intervals for elevation axis
double _calculateNiceElevationInterval(
    double minElevation, double maxElevation, UnitEnum unit,) {
  final range = maxElevation - minElevation;

  if (unit == UnitEnum.metric) {
    // Use simple, consistent intervals based on range
    // Target 4-6 intervals for good readability
    const targetIntervals = 5;
    final rawInterval = range / targetIntervals;

    // Round to nice values allowing sub-100m intervals for small ranges
    final niceIntervals = [
      5.0,
      10.0,
      20.0,
      25.0,
      50.0,
      100.0,
      200.0,
      500.0,
      1000.0,
      2000.0,
      5000.0,
      10000.0,
    ];

    for (final interval in niceIntervals) {
      if (interval >= rawInterval) {
        return interval;
      }
    }
    return niceIntervals.last;
  } else {
    // For imperial (feet), convert range to feet first
    final rangeFeet = range * UnitConversions.metersToFeet;
    const targetIntervals = 5;
    final rawIntervalFeet = rangeFeet / targetIntervals;

    // Round to nice values in feet, allowing sub-100ft intervals for small ranges
    final niceIntervalsFeet = [
      10.0,
      20.0,
      25.0,
      50.0,
      100.0,
      200.0,
      500.0,
      1000.0,
      2000.0,
      5000.0,
      10000.0,
    ];

    for (final interval in niceIntervalsFeet) {
      if (interval >= rawIntervalFeet) {
        return interval / UnitConversions.metersToFeet; // Convert back to meters
      }
    }
    return niceIntervalsFeet.last / UnitConversions.metersToFeet;
  }
}

/// Helper function to calculate nice rounded minimum elevation with padding
double _calculateNiceMinElevation(double dataMinElevation, UnitEnum unit) {
  if (unit == UnitEnum.metric) {
    // Round down to the nearest 100m for a clean starting point
    return (dataMinElevation / 100).floor() * 100.0;
  } else {
    // Convert to feet, round down to nearest 100ft, convert back
    final dataMinFeet = dataMinElevation * UnitConversions.metersToFeet;
    final roundedMinFeet = (dataMinFeet / 100).floor() * 100.0;
    return roundedMinFeet / UnitConversions.metersToFeet;
  }
}

/// Helper function to calculate nice rounded maximum elevation with padding
double _calculateNiceMaxElevation(double dataMaxElevation, UnitEnum unit) {
  if (unit == UnitEnum.metric) {
    // Add padding (at least 50m, but round up to next 100m boundary)
    final paddedMaxElevation = dataMaxElevation + 50;
    return (paddedMaxElevation / 100).ceil() * 100.0;
  } else {
    // Convert to feet, add padding (at least 150ft), round up to next 100ft boundary
    final dataMaxFeet = dataMaxElevation * UnitConversions.metersToFeet;
    final paddedMaxFeet = dataMaxFeet + 150;
    final roundedMaxFeet = (paddedMaxFeet / 100).ceil() * 100.0;
    return roundedMaxFeet / UnitConversions.metersToFeet;
  }
}

/// Helper function to calculate nice rounded intervals for distance axis
double _calculateNiceDistanceInterval(
    double totalDistance, UnitEnum unit, int targetSteps,) {
  if (unit == UnitEnum.metric) {
    // For metric (km), use nice intervals like 0.5, 1, 2, 5, 10, 20, 50
    final rawStep = totalDistance / targetSteps;
    final niceSteps = [
      0.5,
      1.0,
      2.0,
      5.0,
      10.0,
      20.0,
      50.0,
      100.0,
      200.0,
      500.0,
      1000.0,
      2000.0,
      5000.0,
      10000.0,
    ];

    for (final step in niceSteps) {
      if (step >= rawStep) {
        return step;
      }
    }
    return niceSteps.last;
  } else {
    // For imperial (miles), convert to miles first, then use nice intervals
    final totalMiles = totalDistance * UnitConversions.kmToMiles;
    final rawStepMiles = totalMiles / targetSteps;

    // Nice intervals for miles: 0.25, 0.5, 1, 2, 5, 10, 20, 50
    final niceStepsMiles = [
      0.25,
      0.5,
      1.0,
      2.0,
      5.0,
      10.0,
      20.0,
      50.0,
      100.0,
      200.0,
      500.0,
      1000.0,
      2000.0,
      5000.0,
      10000.0,
    ];

    var selectedStepMiles = niceStepsMiles.last;
    for (final step in niceStepsMiles) {
      if (step >= rawStepMiles) {
        selectedStepMiles = step;
        break;
      }
    }

    // Convert back to kilometers for internal calculations
    return selectedStepMiles / UnitConversions.kmToMiles;
  }
}

/// Helper function to generate nice rounded values for distance axis
List<double> _generateNiceDistanceValues(
    double totalDistance, double interval, UnitEnum unit,) {
  final values = <double>[];

  if (unit == UnitEnum.metric) {
    // For metric, work directly with kilometers
    for (double value = 0; value <= totalDistance; value += interval) {
      final roundedValue = double.parse(value.toStringAsFixed(2));
      if (roundedValue <= totalDistance) {
        values.add(roundedValue);
      }
    }
  } else {
    // For imperial, work with miles but return kilometer values
    final intervalMiles = interval * UnitConversions.kmToMiles;
    final totalMiles = totalDistance * UnitConversions.kmToMiles;

    for (double valueMiles = 0;
        valueMiles <= totalMiles;
        valueMiles += intervalMiles) {
      final valueKm = valueMiles / UnitConversions.kmToMiles;
      if (valueKm <= totalDistance) {
        values.add(valueKm);
      }
    }
  }

  return values;
}

class ElevationChart extends StatelessWidget {
  const ElevationChart({
    required this.profile,
    this.onTouchDown,
    this.onTouchUp,
    this.onTouchMove,
    this.gridShown = true,
    this.borderShown = true,
    this.touchEnabled = true,
    this.titlesShown = true,
    this.unit = UnitEnum.metric,
    super.key,
  });

  final List<ChartRoutePoint> profile;
  final void Function(ChartRoutePoint)? onTouchDown;
  final VoidCallback? onTouchUp;
  final void Function(ChartRoutePoint)? onTouchMove;
  final bool gridShown;
  final bool borderShown;
  final bool touchEnabled;
  final bool titlesShown;
  final UnitEnum unit;

  /// Handles touch events on the elevation chart.
  void _handleTouchCallback(FlTouchEvent event, LineTouchResponse? response) {
    if (event is FlLongPressEnd ||
        event is FlTapUpEvent ||
        event is FlPanEndEvent ||
        event is FlPanCancelEvent) {
      onTouchUp?.call();
      return;
    }

    if (response is! LineTouchResponse) {
      return;
    }

    if (response.lineBarSpots == null) {
      return;
    }

    final spotIndex = response.lineBarSpots!.first.spotIndex;
    if (event is FlPanDownEvent) {
      onTouchDown?.call(profile[spotIndex]);
    } else if (event is FlPanUpdateEvent || event is FlLongPressMoveUpdate) {
      onTouchMove?.call(profile[spotIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profile.isEmpty) {
      return const SizedBox.shrink();
    }

    final dataMinElevation =
        profile.map((e) => e.ele).reduce((a, b) => a < b ? a : b);
    final dataMaxElevation =
        profile.map((e) => e.ele).reduce((a, b) => a > b ? a : b);
    final totalDistance = profile.last.distance;

    // Calculate nice rounded min and max elevations with padding
    final minElevation = _calculateNiceMinElevation(dataMinElevation, unit);
    final maxElevation = _calculateNiceMaxElevation(dataMaxElevation, unit);

    // Calculate nice intervals for both axes based on unit system
    final elevationInterval =
        _calculateNiceElevationInterval(minElevation, maxElevation, unit);

    final distanceInterval =
        _calculateNiceDistanceInterval(totalDistance, unit, 4);
    final distanceValues =
        _generateNiceDistanceValues(totalDistance, distanceInterval, unit);

    // Create spots from ChartRoutePoint data
    final spots =
        profile.map((point) => FlSpot(point.distance, point.ele)).toList();
    final chartBarData = LineChartBarData(
      spots: spots,
      isCurved: true,
      isStrokeCapRound: true,
      color: context.isDarkMode ? AppColors.primary80 : AppColors.primary40,
      barWidth: 4,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            if (context.isDarkMode)
              AppColors.primary80
            else
              AppColors.primary40,
            if (context.isDarkMode)
              AppColors.primary80.withValues(alpha: 0)
            else
              AppColors.primary40.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
    return LineChart(
      LineChartData(
        minY: minElevation,
        maxY: maxElevation,
        gridData: FlGridData(
          show: gridShown,
          verticalInterval: distanceInterval,
          horizontalInterval: elevationInterval,
        ),
        borderData: FlBorderData(
          show: borderShown,
          border: Border(
            top: _kChartBorderSide,
            bottom: _kChartBorderSide,
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: touchEnabled,
          longPressDuration: const Duration(days: 365),
          touchCallback: _handleTouchCallback,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xBBFFFFFF),
            getTooltipItems: (tooltipItems) => tooltipItems
                .map(
                  (spot) => LineTooltipItem(
                    UnitConverter.displayElevation(
                      meters: spot.y,
                      unit: unit,
                      space: false,
                    ),
                    context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary40,
                          fontWeight: FontWeight.bold,
                        ) ??
                        const TextStyle(),
                  ),
                )
                .toList(),
          ),
        ),
        titlesData: FlTitlesData(
          show: titlesShown,
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: _calculateTextSize(
                    text: UnitConverter.displayElevation(
                      meters: maxElevation,
                      unit: unit,
                      space: false,
                    ),
                    style: context.textTheme.bodyMedium,
                    context: context,
                  ).width +
                  _kSideTitleReservedExtent +
                  10,
              interval: elevationInterval,
              getTitlesWidget: (value, meta) {
                // Skip 0 and the max value, show only the interval values
                if (value <= 0 || value >= maxElevation) {
                  return const SizedBox.shrink();
                }

                // For metric: ensure the value is a proper multiple of the elevation interval
                // This prevents showing intermediate values like 100m when interval is 200m
                if (unit == UnitEnum.metric) {
                  final remainder = value % elevationInterval;
                  if (remainder.abs() > 0.01) {
                    return const SizedBox.shrink();
                  }
                } else {
                  // For imperial: convert to feet and check if it's a proper multiple
                  final valueFeet = value * UnitConversions.metersToFeet;
                  final intervalFeet = elevationInterval * UnitConversions.metersToFeet;
                  final remainder = valueFeet % intervalFeet;
                  if (remainder.abs() > 0.3) {
                    // ~0.01m tolerance in feet
                    return const SizedBox.shrink();
                  }
                }

                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    UnitConverter.displayElevation(
                      meters: value,
                      unit: unit,
                      space: false,
                    ),
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium,
                    textScaler: TextScaler.noScaling,
                  ),
                );
              },
              showTitles: true,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: _calculateTextSize(
                    text: '${totalDistance.round()} km',
                    style: context.textTheme.bodyMedium,
                    context: context,
                  ).height +
                  _kSideTitleReservedExtent,
              interval: distanceInterval,
              getTitlesWidget: (value, meta) {
                // Only show titles for our calculated nice values
                if (!distanceValues.contains(value)) {
                  return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    UnitConverter.displayDistance(
                      kilometers: value,
                      unit: unit,
                      space: false,
                      fractionDigits: 0,
                    ),
                    style: context.textTheme.bodyMedium,
                    textScaler: TextScaler.noScaling,
                  ),
                );
              },
              showTitles: true,
            ),
          ),
        ),
        lineBarsData: [chartBarData],
      ),
    );
  }

  static Size _calculateTextSize({
    required String text,
    required BuildContext context,
    TextStyle? style,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();

    return textPainter.size;
  }
}
