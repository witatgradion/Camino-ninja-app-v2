import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:flutter/material.dart';

// -- CHART INTERVAL CONFIGURATION --

/// Configuration for chart axis intervals.
///
/// This class allows customization of the grid line and label intervals
/// for both X-axis (distance) and Y-axis (elevation) on the elevation chart.
///
/// All interval values are stored in base units (meters) regardless of the
/// display unit system:
/// - yAxisInterval: elevation interval in meters
/// - xAxisInterval: distance interval in meters
///
/// ## Usage Examples:
///
/// ```dart
/// // Use default intervals based on unit system
/// final config = ChartIntervalConfig.forUnit(UnitEnum.metric);
/// // Results in: yAxisInterval: 100m, xAxisInterval: 250m
///
/// final config = ChartIntervalConfig.forUnit(UnitEnum.imperial);
/// // Results in: yAxisInterval: 60.96m (200 feet), xAxisInterval: 402.336m (0.25 miles)
///
/// // Use custom intervals
/// final config = ChartIntervalConfig.custom(
///   yAxisIntervalMeters: 50.0, // 50 meter elevation intervals
///   xAxisIntervalMeters: 500.0, // 500 meter distance intervals
/// );
/// ```
///
/// ## Unit System Mapping:
///
/// ### Metric System:
/// - Y-axis: 100 meters (displayed as "100m")
/// - X-axis: 250 meters (displayed as "0.25km")
///
/// ### Imperial System:
/// - Y-axis: 60.96 meters = 200 feet (displayed as "200ft")
/// - X-axis: 402.336 meters = 0.25 miles (displayed as "0.25mi")
class ChartIntervalConfig {
  const ChartIntervalConfig({
    required this.yAxisInterval,
    required this.xAxisInterval,
  });

  /// Factory constructor that creates appropriate intervals for each unit system
  factory ChartIntervalConfig.forUnit(UnitEnum unit) {
    switch (unit) {
      case UnitEnum.metric:
        return const ChartIntervalConfig(
          yAxisInterval: 100, // 100 meters
          xAxisInterval: 0.250, // 250 meters
        );
      case UnitEnum.imperial:
        return const ChartIntervalConfig(
          yAxisInterval: 152.4, // 500 feet in meters (500 * 0.3048)
          xAxisInterval: 0.402336, // 0.25 miles in meters (0.25 * 1609.344)
        );
    }
  }

  /// Custom factory for specific intervals
  factory ChartIntervalConfig.custom({
    required double yAxisIntervalMeters,
    required double xAxisIntervalMeters,
  }) {
    return ChartIntervalConfig(
      yAxisInterval: yAxisIntervalMeters,
      xAxisInterval: xAxisIntervalMeters,
    );
  }

  /// Y-axis interval in meters (elevation)
  final double yAxisInterval;

  /// X-axis interval in meters (distance)
  final double xAxisInterval;
}

// -- GRANULAR STYLE CLASSES --

/// Style configuration for unit labels (distance and elevation labels)
class UnitLabelStyle {
  const UnitLabelStyle({
    this.textStyle = const TextStyle(),
    this.containerColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.borderRadius = const Radius.circular(4),
  });
  final TextStyle textStyle;
  final Color containerColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets padding;
  final Radius borderRadius;
}

/// Style configuration for chart grid lines
class GridStyle {
  const GridStyle({
    this.backgroundColor = Colors.white,
    this.lineWidth = 1.0,
    this.lineColor = const Color(0xFFE0E0E0),
  });
  final Color backgroundColor;
  final double lineWidth;
  final Color lineColor;
}

/// Style configuration for city markers on the chart
class CityContainerStyle {
  const CityContainerStyle({
    this.containerWidth = 40.0,
    this.color = const Color(0x8066BB6A),
    this.separatorColor = Colors.grey,
    this.separatorWidth = 1.0,
    this.cityTextStyle = const TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    this.distanceTextStyle =
        const TextStyle(color: Colors.black87, fontSize: 10),
  });
  final double containerWidth;
  final Color color;
  final Color separatorColor;
  final double separatorWidth;
  final TextStyle cityTextStyle;
  final TextStyle distanceTextStyle;
}

/// Style configuration for the elevation chart line and fill
class ChartLineStyle {
  const ChartLineStyle({
    this.lineWidth = 3.0,
    this.lineColor = Colors.blue,
    this.fillColor = const Color(0x330D47A1), // Light blue fill
  });
  final double lineWidth;
  final Color lineColor;
  final Color? fillColor;
}

/// Style configuration for current user location indicator
class CurrentLocationStyle {
  const CurrentLocationStyle({
    this.label,
    this.lineWidth = 2.0,
    this.lineColor = Colors.red,
    this.circleSize = 6.0,
    this.circleColor = Colors.red,
    this.textStyle = const TextStyle(
      color: Colors.red,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      shadows: [Shadow(color: Colors.white, blurRadius: 2)],
    ),
  });
  final double lineWidth;
  final Color lineColor;
  final double circleSize;
  final Color circleColor;
  final TextStyle textStyle;
  final String? label;
}

// -- MAIN STYLE CONTAINER CLASS --

/// Combined style configuration for the elevation chart
class ElevationChartStyle {
  const ElevationChartStyle({
    this.unitLabelStyle = const UnitLabelStyle(),
    this.gridStyle = const GridStyle(),
    this.cityContainerStyle = const CityContainerStyle(),
    this.chartLineStyle = const ChartLineStyle(),
    this.currentLocationStyle = const CurrentLocationStyle(),
    this.intervalConfig =
        const ChartIntervalConfig(yAxisInterval: 100, xAxisInterval: 250),
  });
  final UnitLabelStyle unitLabelStyle;
  final GridStyle gridStyle;
  final CityContainerStyle cityContainerStyle;
  final ChartLineStyle chartLineStyle;
  final CurrentLocationStyle currentLocationStyle;
  final ChartIntervalConfig intervalConfig;
}

