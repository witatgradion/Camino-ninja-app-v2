import 'dart:typed_data';
import 'dart:ui';

import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/city_marker_style.dart';
import 'package:flutter/material.dart';

class RouteMarkerHelper {
  static Color _contrastingColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static CityMarkerStyle _routeMarkerStyle(
    Color routeColor,
    Color textColor,
  ) =>
      CityMarkerStyle(
        fontFamily: appFontFamily,
        fontSize: 14,
        textColor: textColor,
        backgroundColor: routeColor,
        backgroundOpacity: 1,
        borderColor: Colors.transparent,
        borderWidth: 0,
        borderRadius: 6,
        paddingHorizontal: 8,
        paddingVertical: 4,
      );

  static Future<Uint8List> _createRouteCanvas({
    required String label,
    required CityMarkerStyle style,
    double devicePixelRatio = 2.0,
  }) async {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: style.textColor,
          fontSize: style.fontSize,
          fontWeight: FontWeight.w600,
          fontFamily: style.fontFamily,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity);

    const minLogicalWidth = 48.0;
    const minLogicalHeight = 24.0;
    final contentWidth = textPainter.width;
    final contentHeight = textPainter.height;
    final logicalWidth =
        (contentWidth + (style.paddingHorizontal * 2))
            .clamp(minLogicalWidth, double.infinity);
    final logicalHeight =
        (contentHeight + (style.paddingVertical * 2))
            .clamp(minLogicalHeight, double.infinity);
    final physicalWidth =
        (logicalWidth * devicePixelRatio).round();
    final physicalHeight =
        (logicalHeight * devicePixelRatio).round();

    if (physicalWidth < 1 || physicalHeight < 1) {
      throw Exception('Route marker dimensions too small');
    }

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(devicePixelRatio);

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

    canvas.drawRRect(rrect, backgroundPaint);
    if (style.borderWidth > 0) {
      canvas.drawRRect(rrect, borderPaint);
    }

    final textOffset = Offset(
      (logicalWidth - contentWidth) / 2,
      (logicalHeight - contentHeight) / 2,
    );
    textPainter.paint(canvas, textOffset);

    final picture = recorder.endRecording();
    final image =
        await picture.toImage(physicalWidth, physicalHeight);
    final byteData =
        await image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) {
      throw Exception(
        'Failed to generate route marker image',
      );
    }

    return byteData.buffer.asUint8List();
  }

  static Future<Uint8List> createRouteIcon({
    required String label,
    required Color routeColor,
    required BuildContext context,
  }) async {
    final textColor = _contrastingColor(routeColor);
    final style = _routeMarkerStyle(routeColor, textColor);
    return _createRouteCanvas(
      label: label,
      style: style,
      devicePixelRatio:
          MediaQuery.devicePixelRatioOf(context),
    );
  }
}
