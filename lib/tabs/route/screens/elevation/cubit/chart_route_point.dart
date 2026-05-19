import 'package:equatable/equatable.dart';

class ChartRoutePoint {
  ChartRoutePoint({
    required this.id,
    required this.lat,
    required this.lon,
    required this.ele,
    required this.distance,
  });

  final int id;
  final double lat;
  final double lon;
  final double ele;
  final double distance;

  double get distanceInMeters => distance * 1000;
}

class ChartCity extends Equatable {
  const ChartCity({
    required this.name,
    required this.routePointId,
    required this.distance,
  });

  final String name;
  final int routePointId;
  final double distance;

  double get distanceInMeters => distance * 1000;

  @override
  List<Object> get props => [name, routePointId, distance];
}
