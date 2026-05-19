import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MarkerHelper {
  // Cache for circle bitmap descriptors to improve performance
  static final Map<String, Uint8List> _circleCache = {};

  // Cache for widget-based markers
  static final Map<String, Uint8List> _widgetMarkerCache = {};

  static Future<Uint8List> createCircleBitmapDescriptor({
    int size = 40,
    Color color = const Color(0xFF0E9F6E),
    double strokeWidth = 5.0,
    Color strokeColor = Colors.white,
  }) async {
    // Create cache key based on parameters
    final cacheKey =
        '${size}_${color.value}_${strokeWidth}_${strokeColor.value}';

    // Return cached bitmap if available
    if (_circleCache.containsKey(cacheKey)) {
      return _circleCache[cacheKey]!;
    }
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final radius = size / 2;

    // Draw stroke
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw the circle in the center of the canvas
    canvas
      ..drawCircle(
        Offset(radius, radius),
        radius - (strokeWidth / 2),
        strokePaint,
      )
      ..drawCircle(
        Offset(radius, radius),
        radius - strokeWidth,
        fillPaint,
      );

    final img =
        await pictureRecorder.endRecording().toImage(size, size);
    final byteData =
        await img.toByteData(format: ui.ImageByteFormat.png);

    final result = byteData!.buffer.asUint8List();

    // Cache the result for future use
    _circleCache[cacheKey] = result;

    return result;
  }

  /// Clears the circle bitmap cache to free memory
  static void clearCache() {
    _circleCache.clear();
    _widgetMarkerCache.clear();
  }

  /// Clears only widget marker cache
  static void clearWidgetMarkerCache() {
    _widgetMarkerCache.clear();
  }

  /// Converts a Flutter widget to a Uint8List for use as a map
  /// marker annotation image.
  /// [cacheKey] if provided, caches the result for faster
  /// subsequent calls.
  static Future<Uint8List> widgetToBitmapDescriptor({
    required BuildContext context,
    required Widget widget,
    String? cacheKey,
  }) async {
    if (cacheKey != null &&
        _widgetMarkerCache.containsKey(cacheKey)) {
      return _widgetMarkerCache[cacheKey]!;
    }
    try {
      final repaintBoundary = RenderRepaintBoundary();

      final renderView = RenderView(
        view: WidgetsBinding
            .instance.platformDispatcher.views.first,
        child: RenderPositionedBox(
          child: repaintBoundary,
        ),
        configuration: ViewConfiguration.fromView(
          WidgetsBinding
              .instance.platformDispatcher.views.first,
        ),
      );

      final pipelineOwner = PipelineOwner();
      final buildOwner =
          BuildOwner(focusManager: FocusManager());

      pipelineOwner.rootNode = renderView;
      renderView.prepareInitialFrame();

      // Get theme from current context
      final theme = Theme.of(context);

      final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: MediaQuery.of(context),
            child: Theme(
              data: theme,
              child: Material(
                type: MaterialType.transparency,
                child: widget,
              ),
            ),
          ),
        ),
      ).attachToRenderTree(buildOwner);

      buildOwner
        ..buildScope(rootElement)
        ..finalizeTree();

      // Pump the render pipeline a few times with small
      // delays to give asynchronously loaded content (e.g.
      // SvgPicture.asset) a chance to resolve and paint
      // before we capture the image.
      const pumpCount = 3;
      for (var i = 0; i < pumpCount; i++) {
        pipelineOwner
          ..flushLayout()
          ..flushCompositingBits()
          ..flushPaint();
        // Roughly one frame at 60fps.
        await Future<void>.delayed(
          const Duration(milliseconds: 16),
        );
      }

      final size = repaintBoundary.size;
      if (size.width <= 0 || size.height <= 0) {
        AppLogger.w(
          'Widget size is invalid: '
          '${size.width}x${size.height}',
          tag: 'MarkerHelper',
        );
        // Return an empty marker if size is invalid
        return Uint8List(0);
      }

      final image =
          await repaintBoundary.toImage(pixelRatio: 2);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        AppLogger.e(
          'Failed to convert widget to byte data',
          tag: 'MarkerHelper',
        );
        return Uint8List(0);
      }

      final uint8List = byteData.buffer.asUint8List();

      if (cacheKey != null) {
        _widgetMarkerCache[cacheKey] = uint8List;
      }

      return uint8List;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error converting widget to marker',
        tag: 'MarkerHelper',
        error: e,
        stackTrace: stackTrace,
      );
      return Uint8List(0);
    }
  }

  /// Calculate bearing between two points for arrow rotation
  static double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    // Convert degrees to radians
    final dLng = (endLng - startLng) * (math.pi / 180);
    final startLatRad = startLat * (math.pi / 180);
    final endLatRad = endLat * (math.pi / 180);

    // Calculate bearing using the standard formula
    final y = math.sin(dLng) * math.cos(endLatRad);
    final x = math.cos(startLatRad) * math.sin(endLatRad) -
        math.sin(startLatRad) *
            math.cos(endLatRad) *
            math.cos(dLng);

    // Convert back to degrees and normalize
    final bearing = math.atan2(y, x) * (180 / math.pi);
    final normalizedBearing = (bearing + 360) % 360;

    return normalizedBearing;
  }
}
