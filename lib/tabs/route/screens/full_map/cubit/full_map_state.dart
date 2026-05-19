part of 'full_map_cubit.dart';

class FullMapState extends Equatable {
  const FullMapState({
    this.mapReady = false,
    this.albergue,
    this.routePoints,
    this.altRoutePoints,
    this.city,
  });

  final bool mapReady;
  final CityEntity? city;
  final AlbergueEntity? albergue;
  final List<LatLng>? routePoints;
  final List<AltRoutePointEntity>? altRoutePoints;

  FullMapState copyWith({
    bool? mapReady,
    CityEntity? city,
    AlbergueEntity? albergue,
    List<LatLng>? routePoints,
    List<AltRoutePointEntity>? altRoutePoints,
  }) {
    return FullMapState(
      mapReady: mapReady ?? this.mapReady,
      city: city ?? this.city,
      albergue: albergue ?? this.albergue,
      routePoints: routePoints ?? this.routePoints,
      altRoutePoints: altRoutePoints ?? this.altRoutePoints,
    );
  }

  @override
  List<Object?> get props =>
      [mapReady, city, albergue, routePoints, altRoutePoints];
}
