import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:camino_ninja_flutter/widgets/elevation_chart_panel/camino_animated_switcher.dart';
import 'package:camino_ninja_flutter/widgets/elevation_chart_panel/elevation_chart.dart';
import 'package:flutter/material.dart';

/// Elevation chart with an indicator that displays the elevation at the current
/// position (0..1).
class ElevationChartWithIndicator extends StatefulWidget {
  const ElevationChartWithIndicator({
    required this.profile,
    this.onTouchDown,
    this.onTouchUp,
    this.onTouchMove,
    this.indicatorPosition,
    this.unit = UnitEnum.metric,
    super.key,
  });

  final UnitEnum unit;

  /// Elevation profile to display.
  final List<ChartRoutePoint> profile;

  /// Callback for touch down event.
  final void Function(ChartRoutePoint)? onTouchDown;

  /// Callback for touch up event.
  final VoidCallback? onTouchUp;

  /// Callback for touch move event.
  final void Function(ChartRoutePoint)? onTouchMove;

  /// Position of the indicator on the elevation chart. If set, the indicator
  /// will be displayed at the specified position on the chart and touch events
  /// will be disabled.
  final double? indicatorPosition;

  @override
  _ElevationChartWithIndicatorState createState() =>
      _ElevationChartWithIndicatorState();
}

class _ElevationChartWithIndicatorState
    extends State<ElevationChartWithIndicator> {
  final ValueNotifier<double?> _positionNotifier = ValueNotifier(null);

  @override
  void initState() {
    _positionNotifier.value = widget.indicatorPosition;
    super.initState();
  }

  @override
  void dispose() {
    _positionNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ElevationChartWithIndicator oldWidget) {
    if (oldWidget.indicatorPosition != widget.indicatorPosition) {
      _positionNotifier.value = widget.indicatorPosition;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final minElevation =
        widget.profile.map((e) => e.ele).reduce((a, b) => a < b ? a : b);
    final maxElevation =
        widget.profile.map((e) => e.ele).reduce((a, b) => a > b ? a : b);
    return Stack(
      children: [
        ElevationChart(
          unit: widget.unit,
          profile: widget.profile,
          onTouchDown: widget.onTouchDown,
          onTouchUp: widget.onTouchUp,
          onTouchMove: widget.onTouchMove,
          touchEnabled: widget.indicatorPosition == null,
        ),
        Positioned(
          left: 48,
          right: 0,
          top: 0,
          bottom: 22,
          child: ValueListenableBuilder(
            valueListenable: _positionNotifier,
            builder: (context, position, _) => CaminoAnimatedSwitcher(
              child: position != null
                  ? _ElevationChartIndicator(
                      position: position,
                      elevationAtPosition: _getElevationPoint(position),
                      minElevation: minElevation,
                      maxElevation: maxElevation,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  double _getElevationPoint(double position) {
    final distances = widget.profile.map((e) => e.distance).toList();
    final elevation = widget.profile.map((e) => e.ele).toList();
    final maxDistance = distances.last;
    final currentDistance = maxDistance * position;
    final index = distances.indexWhere((d) => d >= currentDistance);
    final coeff = index > 0
        ? (currentDistance - distances[index - 1]) /
            (distances[index] - distances[index - 1])
        : 1.0;
    return index > 0
        ? (elevation[index - 1] +
            coeff * (elevation[index] - elevation[index - 1]))
        : elevation[0];
  }
}

/// Indicator that displays the elevation at the specified position on the
/// elevation chart.
class _ElevationChartIndicator extends StatelessWidget {
  const _ElevationChartIndicator({
    required this.position,
    required this.elevationAtPosition,
    required this.minElevation,
    required this.maxElevation,
  });

  /// Position of the indicator on the elevation chart (0..1).
  final double position;

  /// Elevation at the specified position.
  final double elevationAtPosition;

  /// Minimum elevation in the elevation profile.
  final double minElevation;

  /// Maximum elevation in the elevation profile.
  final double maxElevation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final xPosition = constraints.maxWidth * position;
        final yPosition = (1 -
                (elevationAtPosition - minElevation) /
                    (maxElevation - minElevation)) *
            constraints.maxHeight;
        const color = Color(0xFF0E9F6E);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: xPosition - 2,
              top: yPosition,
              bottom: 0,
              child: Container(
                width: 4,
                color: color,
              ),
            ),
            Positioned(
              left: xPosition - 10,
              top: yPosition - 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: xPosition - 50,
              top: yPosition - 54,
              width: 100,
              child: Align(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${elevationAtPosition.toStringAsFixed(0)} m',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
