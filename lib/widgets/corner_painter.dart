
import 'package:flutter/material.dart';

class CornerPainter extends CustomPainter {
  CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas
      ..drawLine(
        Offset(0, radius),
        Offset(0, cornerLength),
        paint,
      )
      ..drawArc(
        Rect.fromLTWH(0, 0, radius * 2, radius * 2),
        3.14159,
        3.14159 / 2,
        false,
        paint,
      )
      ..drawLine(
        Offset(radius, 0),
        Offset(cornerLength, 0),
        paint,
      )

      // Top-right corner
      ..drawLine(
        Offset(size.width - cornerLength, 0),
        Offset(size.width - radius, 0),
        paint,
      )
      ..drawArc(
        Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
        -3.14159 / 2,
        3.14159 / 2,
        false,
        paint,
      )
      ..drawLine(
        Offset(size.width, radius),
        Offset(size.width, cornerLength),
        paint,
      )

      // Bottom-right corner
      ..drawLine(
        Offset(size.width, size.height - cornerLength),
        Offset(size.width, size.height - radius),
        paint,
      )
      ..drawArc(
        Rect.fromLTWH(
          size.width - radius * 2,
          size.height - radius * 2,
          radius * 2,
          radius * 2,
        ),
        0,
        3.14159 / 2,
        false,
        paint,
      )
      ..drawLine(
        Offset(size.width - radius, size.height),
        Offset(size.width - cornerLength, size.height),
        paint,
      )

      // Bottom-left corner
      ..drawLine(
        Offset(cornerLength, size.height),
        Offset(radius, size.height),
        paint,
      )
      ..drawArc(
        Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2),
        3.14159 / 2,
        3.14159 / 2,
        false,
        paint,
      )
      ..drawLine(
        Offset(0, size.height - radius),
        Offset(0, size.height - cornerLength),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}