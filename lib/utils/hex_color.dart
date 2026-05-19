import 'dart:ui';

import 'package:storage/storage.dart';

/// Default fallback color when a route has no legend color.
const _kDefaultRouteColor = Color(0xFF42A5F5);

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc"
  /// with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0);
  }

  /// Prefixes a hash sign if [leadingHashSign] is set
  /// to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) {
    int c(double v) => (v * 255.0).round() & 0xff;
    return '${leadingHashSign ? '#' : ''}'
        '${c(a).toRadixString(16).padLeft(2, '0')}'
        '${c(r).toRadixString(16).padLeft(2, '0')}'
        '${c(g).toRadixString(16).padLeft(2, '0')}'
        '${c(b).toRadixString(16).padLeft(2, '0')}';
  }
}

/// Parses a [RouteEntity]'s hex legend color into a Flutter
/// [Color], selecting the light or dark variant when
/// [isDark] is specified. Falls back through
/// `lightLegendColor`/`darkLegendColor` -> `legendColor`
/// -> [_kDefaultRouteColor].
Color parseRouteColor(
  RouteEntity route, {
  bool isDark = false,
}) {
  final hex = (isDark
          ? route.darkLegendColor
          : route.lightLegendColor) ??
      route.legendColor;
  if (hex != null && hex.isNotEmpty) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      final value = int.tryParse('FF$cleaned', radix: 16);
      if (value != null) return Color(value);
    }
  }
  return _kDefaultRouteColor;
}

/// Parses a [RouteEntity]'s hex legend color into an ARGB
/// int value, selecting the light or dark variant when
/// [isDark] is specified. Falls back through
/// `lightLegendColor`/`darkLegendColor` -> `legendColor`
/// -> default blue (0xFF42A5F5).
int parseRouteColorValue(
  RouteEntity route, {
  bool isDark = false,
}) {
  final hex = (isDark
          ? route.darkLegendColor
          : route.lightLegendColor) ??
      route.legendColor;
  if (hex != null && hex.isNotEmpty) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      final value = int.tryParse('FF$cleaned', radix: 16);
      if (value != null) return value;
    }
  }
  return 0xFF42A5F5;
}
