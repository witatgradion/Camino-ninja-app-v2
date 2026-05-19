part of 'city_details_cubit.dart';

enum CityDetailsStatus {
  initial,
  loading,
  loaded,
}

enum CityDetailsFilteringStatus {
  initial,
  loading,
  success,
}

class CityDetailsState extends Equatable {
  const CityDetailsState({
    this.city,
    this.services = const [],
    this.albergues = const [],
    this.routePoints = const [],
    this.filteredAlbergues = const [],
    this.altRoutePoints = const [],
    this.status = CityDetailsStatus.initial,
    this.filteringStatus = CityDetailsFilteringStatus.initial,
    this.selectedIndex,
    this.albergueIdToBookmarked = const {},
    this.expandedAlbergueId,
  });

  final CityDetailsStatus status;
  final CityDetailsFilteringStatus filteringStatus;
  final int? selectedIndex;
  final CityEntity? city;
  final List<AvailableService> services;
  final List<AlbergueEntity> albergues;
  final List<AlbergueEntity> filteredAlbergues;
  final List<LatLng> routePoints;
  final List<AltRoutePointEntity> altRoutePoints;
  final Map<int, bool> albergueIdToBookmarked;
  final int? expandedAlbergueId;

  // copyWith
  CityDetailsState copyWith({
    CityDetailsStatus? status,
    CityEntity? city,
    List<AvailableService>? services,
    List<AlbergueEntity>? albergues,
    List<AlbergueEntity>? filteredAlbergues,
    List<LatLng>? routePoints,
    List<AltRoutePointEntity>? altRoutePoints,
    CityDetailsFilteringStatus? filteringStatus,
    int? selectedIndex,
    Map<int, bool>? albergueIdToBookmarked,
    int? expandedAlbergueId,
  }) {
    return CityDetailsState(
      status: status ?? this.status,
      city: city ?? this.city,
      services: services ?? this.services,
      albergues: albergues ?? this.albergues,
      routePoints: routePoints ?? this.routePoints,
      altRoutePoints: altRoutePoints ?? this.altRoutePoints,
      filteredAlbergues: filteredAlbergues ?? this.filteredAlbergues,
      filteringStatus: filteringStatus ?? this.filteringStatus,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      albergueIdToBookmarked:
          albergueIdToBookmarked ?? this.albergueIdToBookmarked,
      expandedAlbergueId: expandedAlbergueId,
    );
  }

  @override
  List<Object?> get props => [
        city,
        services,
        albergues,
        routePoints,
        filteredAlbergues,
        altRoutePoints,
        status,
        filteringStatus,
        selectedIndex,
        albergueIdToBookmarked,
        expandedAlbergueId,
      ];
}
