import 'dart:typed_data';
import 'dart:ui';

import 'package:camino_ninja_flutter/utils/marker_helpers/city_marker_style.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

class CityMarkerHelper {
  static Future<Uint8List> createCityImage(
    CityEntity city, {
    CityMarkerStyle? style,
  }) async {
    final effectiveStyle = style ??
        const CityMarkerStyle(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          borderColor: Colors.blueAccent,
        );

    return createCityCanvas(
      city: city,
      style: effectiveStyle,
    );
  }

  /// Creates a high-performance canvas-based marker with
  /// crisp rendering. Returns raw PNG bytes.
  static Future<Uint8List> createCityCanvas({
    required CityEntity city,
    required CityMarkerStyle style,
    bool isCluster = false,
    int? clusterCount,
    double devicePixelRatio = 2.0,
  }) async {
    // Calculate text dimensions to determine container size
    final textPainter = TextPainter(
      text: TextSpan(
        text: city.name,
        style: TextStyle(
          color: style.textColor,
          fontSize: style.fontSize,
          fontWeight: style.fontWeight,
          fontFamily: style.fontFamily,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    // Calculate logical container dimensions
    final logicalWidth =
        textPainter.width + (style.paddingHorizontal * 2);
    final logicalHeight =
        textPainter.height + (style.paddingVertical * 2);

    // Calculate physical dimensions for high-DPI rendering
    final physicalWidth =
        (logicalWidth * devicePixelRatio).round();
    final physicalHeight =
        (logicalHeight * devicePixelRatio).round();

    // Ensure minimum size
    if (physicalWidth < 1 || physicalHeight < 1) {
      throw Exception('Marker dimensions too small');
    }

    // Create high-resolution picture recorder
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Scale canvas for high-DPI rendering
    canvas.scale(devicePixelRatio);

    // Draw background with rounded corners
    final backgroundPaint = Paint()
      ..color = style.backgroundColor
          .withOpacity(style.backgroundOpacity)
      ..style = PaintingStyle.fill
      ..isAntiAlias = style.enableAntiAliasing;

    final borderPaint = Paint()
      ..color =
          style.borderColor.withOpacity(style.borderOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.borderWidth
      ..isAntiAlias = style.enableAntiAliasing;

    final rect =
        Rect.fromLTWH(0, 0, logicalWidth, logicalHeight);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(style.borderRadius),
    );

    // Draw background
    canvas.drawRRect(rrect, backgroundPaint);

    // Draw border
    if (style.borderWidth > 0) {
      canvas.drawRRect(rrect, borderPaint);
    }

    // Draw text centered
    final textOffset = Offset(
      style.paddingHorizontal,
      style.paddingVertical,
    );
    textPainter.paint(canvas, textOffset);

    // Convert to high-resolution image
    final picture = recorder.endRecording();
    final image =
        await picture.toImage(physicalWidth, physicalHeight);

    // Convert to bytes with high quality
    final byteData =
        await image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to generate marker image');
    }

    return byteData.buffer.asUint8List();
  }
}
