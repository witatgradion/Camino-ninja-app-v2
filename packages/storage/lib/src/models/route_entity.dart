import 'dart:math';

import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage/src/models/city_entity.dart';
import 'package:storage/src/models/route_distance_elevation.dart';
import 'package:storage/src/models/route_point_entity.dart';

part 'route_entity.g.dart';

@JsonSerializable()
class RouteEntity extends Equatable {
  const RouteEntity({
    required this.id,
    required this.orderKey,
    required this.routeName,
    this.routeSubName,
    this.legendColor,
    this.lightLegendColor,
    this.darkLegendColor,
    this.shortName,
  });

  final int id;
  @JsonKey(name: 'order_key')
  final int orderKey;
  @JsonKey(name: 'route_name')
  final String routeName;
  @JsonKey(name: 'route_sub_name')
  final String? routeSubName;
  @JsonKey(name: 'legend_color')
  final String? legendColor;
  @JsonKey(name: 'light_legend_color')
  final String? lightLegendColor;
  @JsonKey(name: 'dark_legend_color')
  final String? darkLegendColor;
  @JsonKey(name: 'short_name')
  final String? shortName;

  @override
  List<Object?> get props => [
        id,
        orderKey,
        routeName,
        routeSubName,
        legendColor,
        lightLegendColor,
        darkLegendColor,
        shortName,
      ];

  RouteDistanceElevation calculateRouteStatistics({
    CityEntity? startingCity,
    CityEntity? destCity,
    List<RoutePointEntity>? currentRoutePoints,
  }) {
    if (currentRoutePoints == null || currentRoutePoints.isEmpty == true) {
      return RouteDistanceElevation(
        routeId: id,
        routeName: routeName,
        routeSubName: routeSubName,
        distance: 0,
        elevationGain: 0,
        elevationLoss: 0,
        minElevation: 0,
        maxElevation: 0,
        route: this,
      );
    }

    var routeLength = 0.0;
    var up = 0.0;
    var down = 0.0;
    var minAlt = 100000.0;
    var maxAlt = 0.0;

    var sortedRoutePoints = currentRoutePoints;
    if (startingCity != null && destCity != null) {
      // Get route points for the current route
      final startingRoutePoint = startingCity.routePoints.firstWhere(
        (rp) => rp.routeId == id,
        orElse: () => startingCity.routePoints.first,
      );
      final destRoutePoint = destCity.routePoints.firstWhere(
        (rp) => rp.routeId == id,
        orElse: () => destCity.routePoints.first,
      );

      final startIdx = currentRoutePoints
          .indexWhere((point) => point.id == startingRoutePoint.id);
      final endIdx = currentRoutePoints
          .indexWhere((point) => point.id == destRoutePoint.id);

      // Only re-slice if both route points are found in the list.
      // When the caller already sliced the points (e.g. via
      // getRoutePointsByRouteIdFromDb), the city's route point may
      // not match — in that case, use the list as-is.
      if (startIdx >= 0 && endIdx >= 0 && endIdx >= startIdx) {
        sortedRoutePoints =
            currentRoutePoints.sublist(startIdx, endIdx + 1);
      }
    }

    for (var j = 0; j < sortedRoutePoints.length; j++) {
      final lat = sortedRoutePoints[j].latitude;
      final lon = sortedRoutePoints[j].longitude;
      final ele = sortedRoutePoints[j].elevation;

      if (maxAlt < ele) {
        maxAlt = ele;
      }
      if (minAlt > ele) {
        minAlt = ele;
      }
    
      if (j == 0) {
        routeLength = 0;
        up = 0;
        down = 0;
      } else {
        final prevLat = sortedRoutePoints[j - 1].latitude;
        final prevLon = sortedRoutePoints[j - 1].longitude;
        final prevEle = sortedRoutePoints[j - 1].elevation;

        final dist = _getDistance(lat, lon, prevLat, prevLon);
        final height = (ele - prevEle).abs();
        routeLength += sqrt((dist * dist) + (height * height));

        final eleDiff = ele - prevEle;
        if (eleDiff > 0) {
          up += eleDiff;
        } else if (eleDiff < 0) {
          down += eleDiff.abs();
        }
      }
    }

    return RouteDistanceElevation(
      routeId: id,
      routeName: routeName,
      routeSubName: routeSubName,
      distance: routeLength / 1000,
      elevationGain: up.toInt(),
      elevationLoss: down.toInt(),
      minElevation: minAlt.toInt(),
      maxElevation: maxAlt.toInt(),
      route: this,
    );
  }

  double _getDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = GeoConstants.earthRadiusM;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
  }

  factory RouteEntity.fromJson(Map<String, dynamic> json) =>
      _$RouteEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RouteEntityToJson(this);
}
