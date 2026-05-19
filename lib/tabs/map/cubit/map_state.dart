part of 'map_cubit.dart';

enum LoadUserLocationStatus {
  loading,
  success,
}

enum LocationPermissionStatus {
  loading,
  serviceDisabled,
  preciseLocationDisabled,
  fullGranted,
}

enum LoadDataMapStatus {
  initial,
  loading,
  loaded,
  error,
}

class MapState extends Equatable {
  const MapState({
    this.cities = const [],
    this.loadDataMapStatus = LoadDataMapStatus.initial,
    this.route,
  });

  final LoadDataMapStatus loadDataMapStatus;
  final List<CityEntity> cities;
  final RouteEntity? route;

  //copyWith
  MapState copyWith({
    List<CityEntity>? cities,
    LoadDataMapStatus? loadDataMapStatus,
    RouteEntity? route,
  }) {
    return MapState(
      cities: cities ?? this.cities,
      loadDataMapStatus: loadDataMapStatus ?? this.loadDataMapStatus,
      route: route ?? this.route,
    );
  }

  @override
  List<Object?> get props => [
        cities,
        loadDataMapStatus,
        route,
      ];
}
