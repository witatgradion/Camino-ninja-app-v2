import 'package:equatable/equatable.dart';
import 'package:storage/storage.dart';

class RouteDistanceElevation extends Equatable {
  RouteDistanceElevation({
    required this.routeId,
    required this.routeName,
    this.routeSubName,
    required this.distance,
    required this.minElevation,
    required this.maxElevation,
    required this.elevationGain,
    required this.elevationLoss,
    required this.route,
  });

  final int routeId;
  final String routeName;
  final String? routeSubName;
  final double distance;
  final int minElevation;
  final int maxElevation;
  final int elevationGain;
  final int elevationLoss;
  final RouteEntity route;

  @override
  List<Object?> get props => [
        routeId,
        routeName,
        routeSubName,
        distance,
        minElevation,
        maxElevation,
        elevationGain,
        elevationLoss,
        route,
  ];
}
