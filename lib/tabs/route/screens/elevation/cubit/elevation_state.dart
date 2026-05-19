part of 'elevation_cubit.dart';

class ElevationState extends Equatable {
  const ElevationState({
    this.routePoints,
    this.cities,
    this.currentPosition,
    this.closestRoutePoint,
    this.distanceFromRoute,
    this.error,
  });

  final List<ChartRoutePoint>? routePoints;
  final List<ChartCity>? cities;
  final Position? currentPosition;
  final ChartRoutePoint? closestRoutePoint;
  final double? distanceFromRoute;
  final String? error;

  ElevationState copyWith({
    List<ChartRoutePoint>? routePoints,
    List<ChartCity>? cities,
    Position? currentPosition,
    ChartRoutePoint? closestRoutePoint,
    double? distanceFromRoute,
    String? error,
  }) {
    return ElevationState(
      routePoints: routePoints ?? this.routePoints,
      cities: cities ?? this.cities,
      currentPosition: currentPosition ?? this.currentPosition,
      closestRoutePoint: closestRoutePoint ?? this.closestRoutePoint,
      distanceFromRoute: distanceFromRoute ?? this.distanceFromRoute,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        routePoints,
        cities,
        currentPosition,
        closestRoutePoint,
        distanceFromRoute,
        error,
      ];
}
