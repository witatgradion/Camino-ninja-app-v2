import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:flutter/material.dart';

class PolylineStyleDefs {
  PolylineStyleDefs._();

  static int get routeColor => Colors.red.toARGB32();
  static const double routeWidth = 5;

  static int altRouteColor(String? hex) =>
      HexColor.fromHex('88${hex ?? 'FF0000'}').toARGB32();
  static const double altRouteWidth = 2;
}
