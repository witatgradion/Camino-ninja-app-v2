part of 'select_route_cubit.dart';

enum SelectRouteInitStatus {
  initial,
  loading,
  success,
  failure,
}

enum SelectRouteFilteringStatus {
  initial,
  loading,
  success,
  failure,
}

class SelectRouteState extends Equatable {
  const SelectRouteState({
    this.filteredRoutes = const [],
    this.routePointsByRouteId = const {},
    this.selectedRouteId,
    this.selectedIndex,
    this.error,
    this.filteringStatus = SelectRouteFilteringStatus.initial,
    this.initStatus = SelectRouteInitStatus.initial,
    this.selectedMode = SelectRouteMode.list,
    this.isSearchActive = false,
  });

  final List<RouteDistanceElevation> filteredRoutes;
  final Map<int, List<RoutePointEntity>> routePointsByRouteId;
  final int? selectedRouteId;
  final int? selectedIndex;
  final String? error;
  final SelectRouteFilteringStatus filteringStatus;
  final SelectRouteInitStatus initStatus;
  final SelectRouteMode selectedMode;
  final bool isSearchActive;

  SelectRouteState copyWith({
    List<RouteDistanceElevation>? filteredRoutes,
    Map<int, List<RoutePointEntity>>? routePointsByRouteId,
    int? selectedRouteId,
    int? selectedIndex,
    String? error,
    SelectRouteFilteringStatus? filteringStatus,
    SelectRouteInitStatus? initStatus,
    SelectRouteMode? selectedMode,
    bool? isSearchActive,
  }) {
    return SelectRouteState(
      filteredRoutes: filteredRoutes ?? this.filteredRoutes,
      routePointsByRouteId:
          routePointsByRouteId ?? this.routePointsByRouteId,
      selectedRouteId: selectedRouteId ?? this.selectedRouteId,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      error: error ?? this.error,
      filteringStatus: filteringStatus ?? this.filteringStatus,
      initStatus: initStatus ?? this.initStatus,
      selectedMode: selectedMode ?? this.selectedMode,
      isSearchActive: isSearchActive ?? this.isSearchActive,
    );
  }

  @override
  List<Object?> get props => [
        filteredRoutes,
        routePointsByRouteId,
        selectedRouteId,
        selectedIndex,
        filteringStatus,
        initStatus,
        error,
        selectedMode,
        isSearchActive,
      ];
}
