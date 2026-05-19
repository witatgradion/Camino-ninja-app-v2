import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:storage/storage.dart';

class DirectionalArrowClusterItem {
  DirectionalArrowClusterItem({
    required this.point,
    required this.rotation,
  });
  final RoutePointEntity point;
  final double rotation;

  LatLng get location =>
      LatLng(point.latitude, point.longitude);
}

class DirectionalArrowsHelper {
  /// Returns evenly-spaced directional arrows for route points
  /// that fall within the given viewport bounds.
  static List<DirectionalArrowClusterItem> getViewportArrows(
    List<RoutePointEntity> allPoints, {
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    int targetCount = 5,
  }) {
    if (allPoints.length < 2) return [];

    final visibleIndices = <int>[];
    for (var i = 0; i < allPoints.length; i++) {
      final p = allPoints[i];
      if (p.latitude >= minLat &&
          p.latitude <= maxLat &&
          p.longitude >= minLng &&
          p.longitude <= maxLng) {
        visibleIndices.add(i);
      }
    }

    if (visibleIndices.isEmpty) return [];

    final count = visibleIndices.length;
    final arrows = <DirectionalArrowClusterItem>[];

    if (count <= targetCount) {
      final step = max(1, count ~/ targetCount);
      for (var i = 0;
          i < count && arrows.length < targetCount;
          i += step) {
        final idx = visibleIndices[i];
        if (idx + 1 < allPoints.length) {
          arrows.add(_createArrowAt(allPoints, idx));
        }
      }
    } else {
      final step = count / targetCount;
      for (var i = 0; i < targetCount; i++) {
        final idx = visibleIndices[(i * step).floor()];
        if (idx + 1 < allPoints.length) {
          arrows.add(_createArrowAt(allPoints, idx));
        }
      }
    }

    return arrows;
  }

  static DirectionalArrowClusterItem _createArrowAt(
    List<RoutePointEntity> points,
    int index,
  ) {
    final current = points[index];
    final next = points[index + 1];
    final bearing = _calculateBearing(
      current.latitude,
      current.longitude,
      next.latitude,
      next.longitude,
    );
    return DirectionalArrowClusterItem(
      point: current,
      rotation: bearing - 90,
    );
  }

  /// Creates a single arrow icon image as Uint8List.
  /// The rotation is applied via PointAnnotationOptions,
  /// not baked into the image.
  static Future<Uint8List> createArrowImage() async {
    return _createArrowIcon();
  }

  /// Create a custom arrow icon for direction markers
  static Future<Uint8List> _createArrowIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const size = 20.0;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = ui.Path()
      ..moveTo(size * 0.02, size * 0.5)
      ..lineTo(size, size * 0.5)
      ..moveTo(size * 0.98, size * 0.5)
      ..lineTo(size * 0.48, size * 0.2)
      ..moveTo(size * 0.98, size * 0.5)
      ..lineTo(size * 0.48, size * 0.8);

    final outlinePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..drawPath(path, outlinePaint)
      ..drawPath(path, paint);

    final picture = recorder.endRecording();
    final img =
        await picture.toImage(size.toInt(), size.toInt());
    final bytes =
        await img.toByteData(format: ui.ImageByteFormat.png);

    return bytes!.buffer.asUint8List();
  }

  /// Calculate bearing between two points for arrow rotation
  static double _calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final dLng = (endLng - startLng) * (pi / 180);
    final startLatRad = startLat * (pi / 180);
    final endLatRad = endLat * (pi / 180);

    final y = sin(dLng) * cos(endLatRad);
    final x = cos(startLatRad) * sin(endLatRad) -
        sin(startLatRad) * cos(endLatRad) * cos(dLng);

    final bearing = atan2(y, x) * (180 / pi);
    final normalizedBearing = (bearing + 360) % 360;

    return normalizedBearing;
  }
}
