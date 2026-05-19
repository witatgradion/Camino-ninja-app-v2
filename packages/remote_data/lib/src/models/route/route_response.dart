import 'dart:math';

import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/city/city_response.dart';
import 'package:remote_data/src/models/route_point/route_point_response.dart';
import 'package:remote_data/src/models/travel_route_data.dart';

part 'route_response.g.dart';

@JsonSerializable()
class RouteResponse extends Equatable {

  const RouteResponse({
    required this.id,
    required this.orderKey,
    required this.routeName,
    this.routeSubName,
    this.legendColor,
    this.lightLegendColor,
    this.darkLegendColor,
    this.shortName,
    this.cities,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) =>
      _$RouteResponseFromJson(json);
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
  @JsonKey(name: 'cities', includeToJson: false)
  final List<CityResponse>? cities;

  Map<String, dynamic> toJson() => _$RouteResponseToJson(this);

  TravelRouteData calculateRouteStatistics({
    CityResponse? startingCity,
    CityResponse? destCity,
    List<RoutePointResponse>? currentRoutePoints,
  }) {
    if (currentRoutePoints == null || currentRoutePoints.isEmpty == true) {
      return TravelRouteData(
        routeId: id,
        routeName: routeName,
        routeSubName: routeSubName,
        distance: 0,
        elevationGain: 0,
        elevationLoss: 0,
        minElevation: 0,
        maxElevation: 0,
      );
    }

    var routeLength = 0.0;
    var up = 0.0;
    var down = 0.0;
    var minAlt = 100000.0;
    var maxAlt = 0.0;

    var sortedRoutePoints = currentRoutePoints;
    if (startingCity != null && destCity != null) {
      sortedRoutePoints = currentRoutePoints.sublist(
        currentRoutePoints
            .indexWhere((point) => point.id == startingCity.routePointIds.first),
        currentRoutePoints.indexWhere((point) => point.id == destCity.routePointIds.first) +
            1,
      );
    }

    for (var j = 0; j < sortedRoutePoints.length; j++) {
      final lat = sortedRoutePoints[j].geom.lat;
      final lon = sortedRoutePoints[j].geom.lon;
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
        final prevLat = sortedRoutePoints[j - 1].geom.lat;
        final prevLon = sortedRoutePoints[j - 1].geom.lon;
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

    return TravelRouteData(
      routeId: id,
      routeName: routeName,
      routeSubName: routeSubName,
      distance: routeLength / 1000,
      // Convert to km,
      elevationGain: up.toInt(),
      elevationLoss: down.toInt(),
      minElevation: minAlt.toInt(),
      maxElevation: maxAlt.toInt(),
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
        cities,
      ];
}
