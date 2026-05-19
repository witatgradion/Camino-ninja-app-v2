import 'package:storage/storage.dart';

enum RouteImportance { major, moderate, minor }

class RouteLabelResolver {
  const RouteLabelResolver._();

  static const Map<RouteImportance, double> _importanceWeight = {
    RouteImportance.major: 100.0,
    RouteImportance.moderate: 50.0,
    RouteImportance.minor: 10.0,
  };

  static RouteImportance importanceOf(RouteDistanceElevation route) {
    if (route.distance >= 500) return RouteImportance.major;
    if (route.distance >= 100) return RouteImportance.moderate;
    return RouteImportance.minor;
  }

  /// Higher value = higher priority for Mapbox symbol-sort-key.
  static double priorityOf(RouteDistanceElevation route) =>
      (_importanceWeight[importanceOf(route)] ?? 0) + route.distance;
}
