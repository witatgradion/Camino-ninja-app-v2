import 'dart:math';

import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/route_distance_calculator.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ElevationChart extends StatefulWidget {
  const ElevationChart({
    required this.routePoints,
    required this.cities,
    this.currentPosition,
    this.closestRoutePoint,
    this.distanceFromRoute,
    super.key,
  });

  final List<ChartRoutePoint> routePoints;
  final List<ChartCity> cities;
  final Position? currentPosition;
  final ChartRoutePoint? closestRoutePoint;
  final double? distanceFromRoute;

  @override
  ElevationChartState createState() => ElevationChartState();
}

class ElevationChartState extends State<ElevationChart> {
  late ScrollController _scrollController;
  double? _lastScrollPosition;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentPosition() {
    if (widget.closestRoutePoint == null) return;

    final maxDistance = widget.routePoints.lastOrNull?.distance ?? 0;
    final currentDistance = widget.closestRoutePoint!.distance;
    final scrollPercentage = currentDistance / maxDistance;

    // Calculate the target scroll position
    final targetPosition =
        _scrollController.position.maxScrollExtent * scrollPercentage;

    // Only scroll if the position has changed significantly (more than 10 pixels)
    if (_lastScrollPosition == null ||
        (targetPosition - _lastScrollPosition!).abs() > 10) {
      _lastScrollPosition = targetPosition;
      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void didUpdateWidget(ElevationChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.closestRoutePoint != oldWidget.closestRoutePoint) {
      _scrollToCurrentPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    return LayoutBuilder(
      builder: (context, constraints) {
        const endPadding = 50.0;
        final minWidth = constraints.maxWidth;
        final maxWidth = constraints.maxWidth *
            100; // Set a maximum width to prevent excessive zooming
        const pointSpacing =
            3.0; // Adjust this value to change the density of points
        final calculatedWidth = widget.routePoints.length * pointSpacing;
        final chartWidth =
            calculatedWidth.clamp(minWidth, maxWidth) + endPadding;
        final chartHeight = constraints.maxHeight;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: SizedBox(
            width: chartWidth,
            height: chartHeight,
            child: CustomPaint(
              painter: ElevationChartPainter(
                routePoints: widget.routePoints,
                cities: widget.cities,
                chartWidth: chartWidth,
                chartHeight: chartHeight,
                endPadding: endPadding,
                lineColor: isDarkMode ? Colors.black : const Color(0xff8c8c8c),
                fillColor: isDarkMode
                    ? const Color(0xff2d2d2d)
                    : const Color(0xffd3d3d3),
                textColor: isDarkMode ? Colors.white : Colors.black,
                checkpointColor: isDarkMode ? Colors.white : Colors.black,
                currentPosition: widget.currentPosition,
                closestRoutePoint: widget.closestRoutePoint,
                distanceFromRoute: widget.distanceFromRoute,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ElevationChartPainter extends CustomPainter {
  ElevationChartPainter({
    required this.routePoints,
    required this.cities,
    required this.chartWidth,
    required this.chartHeight,
    required this.endPadding,
    required this.lineColor,
    required this.fillColor,
    required this.textColor,
    required this.checkpointColor,
    this.currentPosition,
    this.closestRoutePoint,
    this.distanceFromRoute,
  });

  final List<ChartRoutePoint> routePoints;
  final List<ChartCity> cities;
  final double chartWidth;
  final double chartHeight;
  final double endPadding;
  final Color lineColor;
  final Color fillColor;
  final Color textColor;
  final Color checkpointColor;
  final Position? currentPosition;
  final ChartRoutePoint? closestRoutePoint;
  final double? distanceFromRoute;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final checkpointPaint = Paint()
      ..color = checkpointColor.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final locationPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final tooltipPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final tooltipBorderPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final minEle = (routePoints.map((p) => p.ele).reduce(min)) - 50;
    final maxEle = max((routePoints.map((p) => p.ele).reduce(max)) + 50, 1000);
    final maxDistance = routePoints.last.distance;

    final path = Path();
    var isFirstPoint = true;

    for (final point in routePoints) {
      final x = (point.distance / maxDistance) * (chartWidth - endPadding);
      final y = chartHeight -
          ((point.ele - minEle) / (maxEle - minEle) * chartHeight);

      if (isFirstPoint) {
        path.moveTo(x, y);
        isFirstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw fill
    final fillPath = Path.from(path)
      ..lineTo(chartWidth - endPadding, chartHeight)
      ..lineTo(0, chartHeight)
      ..close();
    canvas
      ..drawPath(fillPath, fillPaint)
      // Draw line
      ..drawPath(path, linePaint);

    // Draw checkpoints and city labels
    for (final city in cities) {
      final x = (city.distance / maxDistance) * (chartWidth - endPadding);
      canvas.drawLine(Offset(x, 0), Offset(x, chartHeight), checkpointPaint);

      // Draw city name
      _drawRotatedText(
        canvas,
        '${city.name} (${city.distance.toStringAsFixed(1)}km)',
        Offset(x + 16, chartHeight * 0.96),
        -pi / 2,
      );
    }

    // Draw current location indicator and tooltip
    if (currentPosition != null && closestRoutePoint != null) {
      final x = (closestRoutePoint!.distance / maxDistance) *
          (chartWidth - endPadding);
      final y = chartHeight -
          ((closestRoutePoint!.ele - minEle) / (maxEle - minEle) * chartHeight);

      // Draw tooltip
      const tooltipWidth = 230.0;
      const tooltipHeight = 80.0;
      const tooltipPadding = 8.0;
      const arrowSize = 10.0;

      // Calculate tooltip position with boundary checks
      var tooltipLeft = x - tooltipWidth / 2;
      final tooltipTop = y - tooltipHeight - arrowSize - 20;

      // Adjust horizontal position if tooltip would go outside chart boundaries
      if (tooltipLeft < 0) {
        tooltipLeft = 0;
      } else if (tooltipLeft + tooltipWidth > chartWidth - endPadding) {
        tooltipLeft = chartWidth - endPadding - tooltipWidth;
      }

      // Calculate arrow position relative to tooltip
      final arrowX = x - tooltipLeft;

      // Draw tooltip background with arrow
      final tooltipPath = Path()
        ..moveTo(tooltipLeft, tooltipTop)
        ..lineTo(tooltipLeft + tooltipWidth, tooltipTop)
        ..lineTo(tooltipLeft + tooltipWidth, tooltipTop + tooltipHeight)
        ..lineTo(tooltipLeft + arrowX + arrowSize, tooltipTop + tooltipHeight)
        ..lineTo(tooltipLeft + arrowX, tooltipTop + tooltipHeight + arrowSize)
        ..lineTo(tooltipLeft + arrowX - arrowSize, tooltipTop + tooltipHeight)
        ..lineTo(tooltipLeft, tooltipTop + tooltipHeight)
        ..close();

      canvas
        ..drawPath(tooltipPath, tooltipPaint)
        ..drawPath(tooltipPath, tooltipBorderPaint);

      // Draw tooltip text
      TextPainter(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Your closest location\n',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Distance from trail: '
                  '${RouteDistanceCalculator.formatDistance(distanceFromRoute ?? 0)}\n',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Elevation: ${closestRoutePoint!.ele.toStringAsFixed(0)} m',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: tooltipWidth - tooltipPadding * 2)

      ..paint(
        canvas,
        Offset(
          tooltipLeft + tooltipPadding,
          tooltipTop + tooltipPadding,
        ),
      );

      // Draw location indicator
      canvas..drawCircle(
        Offset(x, y),
        8,
        locationPaint,
      )

      // Draw white border around the location indicator
      ..drawCircle(
        Offset(x, y),
        8,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawRotatedText(
    Canvas canvas,
    String text,
    Offset offset,
    double angle,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text.trim(),
        style: TextStyle(color: textColor, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..rotate(angle);
    textPainter.paint(
      canvas,
      Offset(0, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
