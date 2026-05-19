import 'dart:math';

import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/new_elevation_chart_styles.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/new_elevation_chart_utils.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// -- FIXED Y-AXIS PAINTER --

/// CustomPainter for the fixed Y-axis column showing elevation labels
class YAxisPainter extends CustomPainter {
  YAxisPainter({
    required this.maxElevation,
    required this.style,
    required this.unit,
  });
  final double maxElevation;
  final ElevationChartStyle style;
  final double topPadding = 50;
  final double bottomPadding = 30;
  final UnitEnum unit;

  @override
  void paint(Canvas canvas, Size size) {
    final chartDrawableHeight = size.height - topPadding - bottomPadding;
    if (chartDrawableHeight <= 0 || maxElevation == 0) return;

    // --- New robust scaling logic ---
    final scaledMaxElevation =
        (maxElevation / style.intervalConfig.yAxisInterval).ceil() *
            style.intervalConfig.yAxisInterval;

    final pixelsPerMeterY = chartDrawableHeight / scaledMaxElevation;
    final labelStyle = style.unitLabelStyle;
    final labelBgPaint = Paint()..color = labelStyle.containerColor;
    final labelBorderPaint = Paint()
      ..color = labelStyle.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = labelStyle.borderWidth;

    final yAxisInterval = style.intervalConfig.yAxisInterval;
    final yLineCount = (scaledMaxElevation / yAxisInterval).floor();
    for (var i = 1; i <= yLineCount; i++) {
      final elevation = i * yAxisInterval;

      final y =
          topPadding + chartDrawableHeight - (elevation * pixelsPerMeterY);
      final textPainter = _createTextPainter(
          UnitConverter.displayElevation(
            meters: elevation,
            unit: unit,
            space: false,
          ),
          labelStyle.textStyle,
          textAlign: TextAlign.center,);
      final labelSize = textPainter.size;
      final rect = Rect.fromCenter(
          center: Offset(size.width / 2, y),
          width: labelSize.width + labelStyle.padding.horizontal,
          height: labelSize.height + labelStyle.padding.vertical,);
      final rrect = RRect.fromRectAndRadius(rect, labelStyle.borderRadius);
      canvas
        ..drawRRect(rrect, labelBgPaint)
        ..drawRRect(rrect, labelBorderPaint);
      textPainter.paint(
          canvas,
          Offset(rect.left + labelStyle.padding.left,
              rect.top + labelStyle.padding.top,),);
    }
  }

  TextPainter _createTextPainter(String? text, TextStyle style,
      {TextSpan? textSpan, TextAlign textAlign = TextAlign.left,}) {
    final span = textSpan ?? TextSpan(text: text, style: style);
    final textPainter = TextPainter(
        text: span, textAlign: textAlign, textDirection: TextDirection.ltr,)
      ..layout();
    return textPainter;
  }

  @override
  bool shouldRepaint(covariant YAxisPainter oldDelegate) {
    return oldDelegate.maxElevation != maxElevation ||
        oldDelegate.style != style;
  }
}

// -- OPTIMIZED SCROLLABLE CHART PAINTER --

/// CustomPainter for the scrollable elevation chart area
class OptimizedElevationChartPainter extends CustomPainter {
  OptimizedElevationChartPainter({
    required this.elevationPoints,
    required this.cities,
    required this.currentUserLocation,
    required this.style,
    required this.leftAxisWidth,
    required this.maxElevation,
    required this.unit,
    required this.scrollController,
    required this.viewportWidth,
  });
  final List<ChartRoutePoint> elevationPoints;
  final List<ChartCity> cities;
  final Position? currentUserLocation;
  final ElevationChartStyle style;
  final double leftAxisWidth;
  final double maxElevation;
  final UnitEnum unit;
  final ScrollController scrollController;
  final double viewportWidth;
  final double topPadding = 50;
  final double bottomPadding = 30;
  final double rightPadding = 20;

  // Cache for expensive calculations
  static Path? _cachedPath;
  static List<ChartRoutePoint>? _cachedPoints;
  static double? _cachedMaxElevation;
  static double? _cachedChartWidth;
  static double? _cachedChartHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (elevationPoints.length < 2) return;

    final chartDrawableWidth = size.width - rightPadding;
    final chartDrawableHeight = size.height - topPadding - bottomPadding;

    if (chartDrawableWidth <= 0 || chartDrawableHeight <= 0) return;

    final totalDistance = elevationPoints.last.distanceInMeters;
    if (totalDistance == 0) return;

    // Calculate viewport bounds for culling
    final scrollOffset =
        scrollController.hasClients ? scrollController.offset : 0.0;
    final viewportStart = scrollOffset;
    final viewportEnd = scrollOffset + viewportWidth;

    // --- New robust scaling logic ---
    final scaledMaxElevation =
        (maxElevation / style.intervalConfig.yAxisInterval).ceil() *
            style.intervalConfig.yAxisInterval;
    final pixelsPerMeterX = chartDrawableWidth / totalDistance;
    final pixelsPerMeterY = chartDrawableHeight / scaledMaxElevation;

    // Only draw grid lines that are visible in viewport
    _drawOptimizedGridLines(
        canvas,
        size,
        chartDrawableWidth,
        chartDrawableHeight,
        scaledMaxElevation,
        totalDistance,
        pixelsPerMeterX,
        pixelsPerMeterY,
        viewportStart,
        viewportEnd,);

    // Use cached path if available and valid
    final path = _getCachedPath(chartDrawableWidth, chartDrawableHeight,
        pixelsPerMeterX, pixelsPerMeterY,);

    final filledPath = Path.from(path)
      ..lineTo(chartDrawableWidth, size.height)
      ..lineTo(0, size.height)
      ..close();

    if (style.chartLineStyle.fillColor != null) {
      final fillPaint = Paint()..color = style.chartLineStyle.fillColor!;
      canvas.drawPath(filledPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = style.chartLineStyle.lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.chartLineStyle.lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Only draw city markers that are visible in viewport
    _drawOptimizedCityMarkers(canvas, size, chartDrawableHeight,
        pixelsPerMeterX, viewportStart, viewportEnd,);

    _drawCurrentUserLocation(canvas, chartDrawableHeight, chartDrawableWidth,
        pixelsPerMeterX, pixelsPerMeterY, path,);

    // Only draw axis labels that are visible in viewport
    _drawOptimizedAxisLabels(
        canvas,
        size,
        chartDrawableWidth,
        chartDrawableHeight,
        scaledMaxElevation,
        totalDistance,
        pixelsPerMeterX,
        pixelsPerMeterY,
        viewportStart,
        viewportEnd,);
  }

  Path _getCachedPath(double chartWidth, double chartHeight,
      double pixelsPerMeterX, double pixelsPerMeterY,) {
    // Check if we can use cached path
    if (_cachedPath != null &&
        _cachedPoints == elevationPoints &&
        _cachedMaxElevation == maxElevation &&
        _cachedChartWidth == chartWidth &&
        _cachedChartHeight == chartHeight) {
      return _cachedPath!;
    }

    // Create new path with level-of-detail optimization
    final path = _createOptimizedSmoothLinePath(
        chartWidth, chartHeight, pixelsPerMeterX, pixelsPerMeterY,);

    // Cache the path
    _cachedPath = path;
    _cachedPoints = elevationPoints;
    _cachedMaxElevation = maxElevation;
    _cachedChartWidth = chartWidth;
    _cachedChartHeight = chartHeight;

    return path;
  }

  Path _createOptimizedSmoothLinePath(double chartWidth, double chartHeight,
      double pixelsPerMeterX, double pixelsPerMeterY,) {
    // Apply level-of-detail optimization
    final optimizedPoints =
        _applyLevelOfDetail(elevationPoints, pixelsPerMeterX);

    final points = optimizedPoints.map((p) {
      final x = p.distanceInMeters * pixelsPerMeterX;
      final y = (topPadding + chartHeight - (p.ele * pixelsPerMeterY))
          .clamp(topPadding, topPadding + chartHeight);
      return Offset(x, y);
    }).toList();

    if (points.length < 2) {
      return Path();
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // Calculate a midpoint to serve as the endpoint of the quadratic curve
      final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

      path.quadraticBezierTo(p1.dx, p1.dy, midPoint.dx, midPoint.dy);
    }

    // Draw the final line to the very last point
    path.lineTo(points.last.dx, points.last.dy);

    return path;
  }

  List<ChartRoutePoint> _applyLevelOfDetail(
      List<ChartRoutePoint> points, double pixelsPerMeterX,) {
    if (points.isEmpty) return points;

    // If we have very dense data (more than 1 point per 2 pixels), thin it out
    final totalPixelWidth = points.last.distanceInMeters * pixelsPerMeterX;
    final pointsPerPixel = points.length / totalPixelWidth;

    if (pointsPerPixel <= 0.5) {
      return points; // No need to thin out
    }

    final optimizedPoints = <ChartRoutePoint>[];
    final skipInterval = max(1, (pointsPerPixel * 2).round());

    for (var i = 0; i < points.length; i += skipInterval) {
      optimizedPoints.add(points[i]);
    }

    // Always include the last point
    if (optimizedPoints.isNotEmpty &&
        points.isNotEmpty &&
        optimizedPoints.last != points.last) {
      optimizedPoints.add(points.last);
    }

    return optimizedPoints;
  }

  void _drawOptimizedGridLines(
      Canvas canvas,
      Size size,
      double chartWidth,
      double chartHeight,
      double scaledMaxElevation,
      double totalDistance,
      double pixelsPerMeterX,
      double pixelsPerMeterY,
      double viewportStart,
      double viewportEnd,) {
    final gridPaint = Paint()
      ..color = style.gridStyle.lineColor
      ..strokeWidth = style.gridStyle.lineWidth;

    // Draw Y-axis grid lines (always visible)
    final yAxisInterval = style.intervalConfig.yAxisInterval;
    final yLineCount = (scaledMaxElevation / yAxisInterval).floor();
    for (var i = 1; i <= yLineCount; i++) {
      final elevation = i * yAxisInterval;
      final y = topPadding + chartHeight - (elevation * pixelsPerMeterY);
      canvas.drawLine(
          Offset(-leftAxisWidth, y), Offset(size.width, y), gridPaint,);
    }

    // Draw X-axis grid lines (only visible ones)
    final xAxisInterval = style.intervalConfig.xAxisInterval;
    final startDistance =
        ((viewportStart / pixelsPerMeterX) / xAxisInterval).floor() *
            xAxisInterval;
    final endDistance =
        ((viewportEnd / pixelsPerMeterX) / xAxisInterval).ceil() *
            xAxisInterval;

    for (var distance = startDistance;
        distance <= endDistance;
        distance += xAxisInterval) {
      if (distance <= 0 || distance >= totalDistance) continue;
      final x = distance * pixelsPerMeterX;
      if (x >= viewportStart && x <= viewportEnd) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
    }
  }

  void _drawOptimizedAxisLabels(
      Canvas canvas,
      Size size,
      double chartWidth,
      double chartHeight,
      double scaledMaxElevation,
      double totalDistance,
      double pixelsPerMeterX,
      double pixelsPerMeterY,
      double viewportStart,
      double viewportEnd,) {
    final labelStyle = style.unitLabelStyle;
    final labelBgPaint = Paint()..color = labelStyle.containerColor;
    final labelBorderPaint = Paint()
      ..color = labelStyle.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = labelStyle.borderWidth;

    // Only draw labels that are visible in viewport
    final xAxisInterval = style.intervalConfig.xAxisInterval;
    final startDistance =
        ((viewportStart / pixelsPerMeterX) / xAxisInterval).floor() *
            xAxisInterval;
    final endDistance =
        ((viewportEnd / pixelsPerMeterX) / xAxisInterval).ceil() *
            xAxisInterval;

    for (var distance = startDistance;
        distance <= endDistance;
        distance += xAxisInterval) {
      if (distance <= 0 || distance >= totalDistance) continue;

      final x = distance * pixelsPerMeterX;
      if (x >= viewportStart && x <= viewportEnd) {
        final textPainter = _createTextPainter(
            UnitConverter.displayDistance(
              kilometers: distance / 1000,
              unit: unit,
              space: false,
              fractionDigits: 2,
            ),
            labelStyle.textStyle,
            textAlign: TextAlign.center,);
        final labelSize = textPainter.size;
        final rect = Rect.fromCenter(
            center: Offset(x, size.height - bottomPadding / 2 - 25),
            width: labelSize.width + labelStyle.padding.horizontal,
            height: labelSize.height + labelStyle.padding.vertical,);
        final rrect = RRect.fromRectAndRadius(rect, labelStyle.borderRadius);

        canvas
          ..drawRRect(rrect, labelBgPaint)
          ..drawRRect(rrect, labelBorderPaint);
        textPainter.paint(
          canvas,
          Offset(
            rect.left + labelStyle.padding.left,
            rect.top + labelStyle.padding.top,
          ),
        );
      }
    }
  }

  void _drawOptimizedCityMarkers(Canvas canvas, Size size, double chartHeight,
      double pixelsPerMeterX, double viewportStart, double viewportEnd,) {
    final cityStyle = style.cityContainerStyle;
    final cityMarkerPaint = Paint()..color = cityStyle.color;
    final citySeparatorPaint = Paint()
      ..color = cityStyle.separatorColor
      ..strokeWidth = cityStyle.separatorWidth;

    final elevationPointMap = <String, ChartRoutePoint>{
      for (final p in elevationPoints) p.id.toString(): p,
    };
    final citiesByPointId = <String, List<ChartCity>>{};

    for (final city in cities) {
      citiesByPointId
          .putIfAbsent(city.routePointId.toString(), () => [])
          .add(city);
    }

    citiesByPointId.forEach((pointId, cityList) {
      final point = elevationPointMap[pointId];
      if (point == null) return;

      final baseX = point.distanceInMeters * pixelsPerMeterX;
      final cityMarkerWidth = cityStyle.containerWidth;

      // Only draw city markers that are visible in viewport
      if (baseX >= viewportStart - cityMarkerWidth &&
          baseX <= viewportEnd + cityMarkerWidth) {
        for (var i = 0; i < cityList.length; i++) {
          final city = cityList[i];
          final currentX = baseX + (i * cityMarkerWidth);
          final rect = Rect.fromLTWH(
              currentX - cityMarkerWidth / 2, 0, cityMarkerWidth, size.height,);
          canvas
            ..drawRect(rect, cityMarkerPaint)
            ..drawLine(
              Offset(rect.right, rect.top),
              Offset(rect.right, rect.bottom),
              citySeparatorPaint,
            )
            ..save();
          final namePainter = _createTextPainter(
              city.name, cityStyle.cityTextStyle,
              textAlign: TextAlign.center,);
          canvas
            ..translate(currentX, size.height / 2)
            ..rotate(-pi / 2);
          namePainter.paint(
              canvas, Offset(-namePainter.width / 2, -namePainter.height / 2),);
          canvas
            ..restore()
            ..save();
          final distancePainter = _createTextPainter(
              UnitConverter.displayDistance(
                kilometers: city.distance,
                unit: unit,
                fractionDigits: 2,
              ),
              cityStyle.distanceTextStyle,
              textAlign: TextAlign.center,);
          canvas
            ..translate(currentX, topPadding)
            ..rotate(-pi / 2);
          distancePainter.paint(canvas,
              Offset(-distancePainter.width / 2, -distancePainter.height / 2),);
          canvas.restore();
        }
      }
    });
  }

  void _drawCurrentUserLocation(
      Canvas canvas,
      double chartHeight,
      double chartWidth,
      double pixelsPerMeterX,
      double pixelsPerMeterY,
      Path path,) {
    if (currentUserLocation == null) return;
    final locationStyle = style.currentLocationStyle;
    if (locationStyle.label == null || locationStyle.label!.isEmpty) return;

    // Edge case: Check for valid data
    if (elevationPoints.length < 2) return;

    final totalDistance = elevationPoints.lastOrNull?.distanceInMeters ?? 0;
    if (totalDistance <= 0) return;

    // Find nearest waypoint and check distance using shared function
    final result = NewElevationChartUtils.findNearestWaypoint(
      currentUserLocation!,
      elevationPoints,
    );

    if (result.distance > NewElevationChartUtils.maxDistanceFromRoute) {
      // Don't show "You're here" if user is too far from route
      return;
    }

    var userDistance = result.routeDistance;
    final userElevation = result.elevation;

    // Edge case: Ensure values are within valid bounds
    userDistance = userDistance.clamp(0.0, totalDistance);

    final x = userDistance * pixelsPerMeterX;
    final y = topPadding + chartHeight - (userElevation * pixelsPerMeterY);

    final locationPaint = Paint()
      ..color = locationStyle.lineColor
      ..strokeWidth = locationStyle.lineWidth;
    canvas.drawLine(
        Offset(x, chartHeight + topPadding + 20), Offset(x, y), locationPaint,);

    final circlePaint = Paint()..color = locationStyle.circleColor;
    canvas.drawCircle(Offset(x, y), locationStyle.circleSize, circlePaint);

    final textPainter =
        _createTextPainter(locationStyle.label ?? '', locationStyle.textStyle);
    textPainter.paint(canvas, Offset(x, y - textPainter.height - 8));
  }

  TextPainter _createTextPainter(String? text, TextStyle style,
      {TextSpan? textSpan, TextAlign textAlign = TextAlign.left,}) {
    final span = textSpan ?? TextSpan(text: text, style: style);
    final textPainter = TextPainter(
        text: span, textAlign: textAlign, textDirection: TextDirection.ltr,)
      ..layout();
    return textPainter;
  }

  @override
  bool shouldRepaint(covariant OptimizedElevationChartPainter oldDelegate) {
    return oldDelegate.elevationPoints != elevationPoints ||
        oldDelegate.cities != cities ||
        oldDelegate.currentUserLocation != currentUserLocation ||
        oldDelegate.style != style ||
        oldDelegate.maxElevation != maxElevation ||
        oldDelegate.scrollController != scrollController;
  }
}

