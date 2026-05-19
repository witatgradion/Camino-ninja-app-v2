import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camino_ninja_flutter/tabs/plan/screens/trail_builder/cubit/trail_builder_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

/// Renders a compact graph visualisation of a junction,
/// showing the junction city at the bottom center and
/// route branches fanning upward with a few city nodes
/// along each path.
///
/// This widget always renders with a dark colour scheme
/// regardless of the system theme, matching the design.
class JunctionMiniGraph extends StatelessWidget {
  const JunctionMiniGraph({
    required this.graphData,
    required this.junctionInfo,
    super.key,
  });

  final JunctionGraphData? graphData;
  final JunctionInfo junctionInfo;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final routeColor = Color(
      parseColorValue(
        junctionInfo.currentRoute,
        isDark: isDark,
      ),
    );

    final data = graphData;

    if (data != null) {
      return SizedBox(
        height: 280,
        width: double.infinity,
        child: CustomPaint(
          painter: _JunctionGraphPainter(
            graphData: data,
            routeColor: routeColor,
            isDark: isDark,
          ),
        ),
      );
    }

    return const SizedBox(height: 280);
  }

  /// Parses the route's hex legend color into an ARGB int,
  /// selecting the light or dark variant via [isDark].
  /// Delegates to [parseRouteColorValue] from hex_color.dart.
  static int parseColorValue(
    RouteEntity route, {
    bool isDark = false,
  }) =>
      parseRouteColorValue(route, isDark: isDark);
}

// ── Custom Painter ────────────────────────────────────────

class _JunctionGraphPainter extends CustomPainter {
  _JunctionGraphPainter({
    required this.graphData,
    required this.routeColor,
    required this.isDark,
  });

  final JunctionGraphData graphData;
  final Color routeColor;
  final bool isDark;

  // Node sizes
  static const double _junctionRadius = 12;
  static const double _junctionRingWidth = 3.5;
  static const double _cityNodeRadius = 7;
  static const double _terminalNodeRadius = 8;

  // Colors
  static const Color _waypointColor = Color(0xFFD4A843);
  static const Color _terminalColor = Color(0xFF6B6B6B);

  @override
  void paint(Canvas canvas, Size size) {
    final junctionPos = Offset(
      size.width / 2,
      size.height * 0.82,
    );

    // Stem top: the point where branches originate.
    final stemTop = Offset(
      junctionPos.dx,
      junctionPos.dy - 25,
    );

    // Draw the vertical stem line (dashed).
    _drawDashedLine(
      canvas,
      junctionPos,
      stemTop,
      Paint()
        ..color = routeColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Draw branches from stem top.
    final branchCount = graphData.branches.length;
    for (var i = 0; i < branchCount; i++) {
      final branch = graphData.branches[i];
      final branchPositions = _computeBranchPositions(
        branchIndex: i,
        branchCount: branchCount,
        origin: stemTop,
        cityCount: branch.cities.length,
        size: size,
      );

      _drawBranch(
        canvas: canvas,
        origin: stemTop,
        positions: branchPositions,
        branch: branch,
        size: size,
      );
    }

    // Draw junction node on top of everything.
    _drawJunctionNode(canvas, junctionPos);

    // Label the junction city.
    _drawCityLabel(
      canvas: canvas,
      position: junctionPos,
      label: graphData.junctionCity.name,
      size: size,
    );
  }

  /// Computes positions for city nodes along a branch.
  List<Offset> _computeBranchPositions({
    required int branchIndex,
    required int branchCount,
    required Offset origin,
    required int cityCount,
    required Size size,
  }) {
    if (cityCount == 0) return const [];

    // Spread branches evenly from the center.
    // For 1 branch: straight up. For 2: left/right.
    // For 3+: evenly spread.
    final spreadAngle = branchCount == 1
        ? 0.0
        : _mapBranchAngle(
            branchIndex,
            branchCount,
            size.width,
          );

    final topY = 12.0;
    final positions = <Offset>[];
    for (var c = 0; c < cityCount; c++) {
      // Vertical position: spread cities evenly
      // between origin (stem top) and top.
      final t = (c + 1) / (cityCount + 0.5);
      final y = origin.dy - (origin.dy - topY) * t;

      // Horizontal offset increases with distance
      // from origin.
      final x = origin.dx + spreadAngle * t;

      positions.add(Offset(x, y));
    }

    return positions;
  }

  /// Returns a horizontal offset factor for the given
  /// branch index.
  double _mapBranchAngle(
    int index,
    int count,
    double width,
  ) {
    // Maximum horizontal spread (pixels).
    final maxSpread =
        count >= 3 ? width * 0.45 : width * 0.42;

    if (count == 1) return 0;
    if (count == 2) {
      return index == 0 ? -maxSpread : maxSpread;
    }

    // For 3+ branches, spread from left to right.
    final step = (2 * maxSpread) / (count - 1);
    return -maxSpread + step * index;
  }

  void _drawBranch({
    required Canvas canvas,
    required Offset origin,
    required List<Offset> positions,
    required JunctionBranch branch,
    required Size size,
  }) {
    if (positions.isEmpty) return;

    final lineColor = isDark
        ? const Color(0xFFFFFFFF).withAlpha(200)
        : const Color(0xFF374151).withAlpha(180);

    // Draw dashed curves from origin to each city.
    // Only draw an arrow on the first segment.
    var prev = origin;
    for (var i = 0; i < positions.length; i++) {
      final pos = positions[i];
      _drawDashedCurve(canvas, prev, pos, lineColor);
      _drawArrowIndicator(canvas, prev, pos, lineColor);
      prev = pos;
    }

    // Draw city nodes and labels.
    for (var i = 0; i < positions.length; i++) {
      final pos = positions[i];
      final isTerminal = i == positions.length - 1;
      final cityName = branch.cities[i].name;

      if (isTerminal) {
        _drawTerminalNode(canvas, pos);
      } else {
        _drawWaypointNode(canvas, pos);
      }

      _drawCityLabel(
        canvas: canvas,
        position: pos,
        label: cityName,
        size: size,
      );
    }
  }

  /// Builds the S-curve path from [from] to [to].
  /// Goes vertical → smooth bend → vertical, like a git
  /// branch line.
  Path _buildBranchPath(Offset from, Offset to) {
    final totalDy = from.dy - to.dy; // positive (going up)
    // Vertical run at bottom: 25% of distance
    final bendStartY = from.dy - totalDy * 0.25;
    // Vertical run at top: 25% of distance
    final bendEndY = from.dy - totalDy * 0.75;

    return Path()
      ..moveTo(from.dx, from.dy)
      // Vertical segment going up from stem
      ..lineTo(from.dx, bendStartY)
      // S-curve transition to target X
      ..cubicTo(
        from.dx, bendEndY, // cp1: from.x at bend end
        to.dx, bendStartY, // cp2: to.x at bend start
        to.dx, bendEndY, // end: to.x at bend end
      )
      // Vertical segment going up to city
      ..lineTo(to.dx, to.dy);
  }

  void _drawDashedCurve(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = _buildBranchPath(from, to);

    // Draw dashed version using path metrics.
    const dashLength = 10.0;
    const gapLength = 8.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(
          distance + dashLength,
          metric.length,
        );
        final segment = metric.extractPath(
          distance,
          end,
        );
        canvas.drawPath(segment, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  void _drawArrowIndicator(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color,
  ) {
    final path = _buildBranchPath(from, to);

    // Place arrow at ~90% along the path (near the
    // destination city node).
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final pos = metric.getTangentForOffset(
      metric.length * 0.90,
    );
    if (pos == null) return;

    final paint = Paint()
      ..color = isDark
          ? const Color(0xFFFFFFFF).withAlpha(220)
          : const Color(0xFF374151).withAlpha(220)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Large upward-pointing chevron (^).
    const halfW = 10.0;
    const halfH = 8.0;

    canvas.save();
    canvas.translate(pos.position.dx, pos.position.dy);
    // Rotate so ^ points along the path direction.
    canvas.rotate(pos.angle + math.pi / 2);

    final arrowPath = Path()
      ..moveTo(-halfW, -halfH)
      ..lineTo(0, 0)
      ..lineTo(halfW, -halfH);

    canvas.drawPath(arrowPath, paint);
    canvas.restore();
  }

  void _drawJunctionNode(
    Canvas canvas,
    Offset center,
  ) {
    // Glow effect behind the node.
    final glowPaint = Paint()
      ..color = routeColor.withAlpha(80)
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(
      center,
      _junctionRadius + 5,
      glowPaint,
    );

    // Outer ring (route color).
    final ringPaint = Paint()
      ..color = routeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _junctionRingWidth;

    canvas.drawCircle(
      center,
      _junctionRadius,
      ringPaint,
    );

    // Inner fill (gray).
    final fillPaint = Paint()
      ..color = const Color(0xFF808080);

    canvas.drawCircle(
      center,
      _junctionRadius - _junctionRingWidth,
      fillPaint,
    );
  }

  void _drawWaypointNode(
    Canvas canvas,
    Offset center,
  ) {
    // Warm glow halo behind the node.
    final glowPaint = Paint()
      ..color = _waypointColor.withAlpha(70)
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      center,
      _cityNodeRadius + 4,
      glowPaint,
    );

    // Darker outer ring for definition.
    final ringPaint = Paint()
      ..color = _waypointColor.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      center,
      _cityNodeRadius + 1,
      ringPaint,
    );

    // Filled gold circle.
    final paint = Paint()..color = _waypointColor;
    canvas.drawCircle(center, _cityNodeRadius, paint);
  }

  void _drawTerminalNode(
    Canvas canvas,
    Offset center,
  ) {
    // Glow halo behind the node.
    final glowPaint = Paint()
      ..color = _terminalColor.withAlpha(60)
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(
      center,
      _terminalNodeRadius + 3,
      glowPaint,
    );

    // Filled gray circle.
    final paint = Paint()..color = _terminalColor;
    canvas.drawCircle(
      center,
      _terminalNodeRadius,
      paint,
    );

    // Outer ring for definition.
    final ringPaint = Paint()
      ..color = const Color(0xFF808080).withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(
      center,
      _terminalNodeRadius,
      ringPaint,
    );
  }

  void _drawCityLabel({
    required Canvas canvas,
    required Offset position,
    required String label,
    required Size size,
  }) {
    final textStyle = ui.TextStyle(
      color: isDark
          ? const Color(0xFFFFFFFF).withAlpha(200)
          : const Color(0xFF374151).withAlpha(220),
      fontSize: 12,
      fontWeight: ui.FontWeight.w500,
      fontFamily: appFontFamily,
    );

    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.left,
        maxLines: 1,
        ellipsis: '...',
      ),
    )
      ..pushStyle(textStyle)
      ..addText(label);

    final paragraph = paragraphBuilder.build()
      ..layout(
        const ui.ParagraphConstraints(width: 90),
      );

    // Position label to the right of the node,
    // or to the left if it would overflow.
    final labelX = position.dx + _cityNodeRadius + 6;
    final wouldOverflow = labelX + paragraph.longestLine > size.width - 8;

    final x = wouldOverflow
        ? position.dx - _cityNodeRadius - 6 - paragraph.longestLine
        : labelX;
    final y = position.dy - paragraph.height / 2;

    canvas.drawParagraph(paragraph, Offset(x, y));
  }

  /// Draws a dashed straight line between two points.
  void _drawDashedLine(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
  ) {
    const dashLength = 10.0;
    const gapLength = 8.0;

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..lineTo(to.dx, to.dy);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(
          distance + dashLength,
          metric.length,
        );
        final segment = metric.extractPath(
          distance,
          end,
        );
        canvas.drawPath(segment, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _JunctionGraphPainter oldDelegate,
  ) =>
      graphData != oldDelegate.graphData ||
      routeColor != oldDelegate.routeColor ||
      isDark != oldDelegate.isDark;
}
