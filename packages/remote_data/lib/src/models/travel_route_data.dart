import 'package:equatable/equatable.dart';

final class TravelRouteData extends Equatable {
  const TravelRouteData({
    required this.routeId,
    required this.routeName,
    required this.distance, required this.minElevation, required this.maxElevation, required this.elevationGain, required this.elevationLoss, this.routeSubName,
  });

  final int routeId;
  final String routeName;
  final String? routeSubName;
  final double distance;
  final int minElevation;
  final int maxElevation;
  final int elevationGain;
  final int elevationLoss;

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
      ];
}
