part of 'stage_select_route_cubit.dart';

enum SelectRouteInitStatus {
  initial,
  loading,
  success,
  failure,
}

class StageSelectRouteState extends Equatable {
  const StageSelectRouteState({
    this.routes = const [],
    this.initStatus = SelectRouteInitStatus.initial,
    this.selectedRoute,
  });

  final SelectRouteInitStatus initStatus;
  final List<RouteEntity> routes;
  final RouteEntity? selectedRoute;

  StageSelectRouteState copyWith({
    List<RouteEntity>? routes,
    SelectRouteInitStatus? initStatus,
    RouteEntity? selectedRoute,
  }) {
    return StageSelectRouteState(
      routes: routes ?? this.routes,
      initStatus: initStatus ?? this.initStatus,
      selectedRoute: selectedRoute ?? this.selectedRoute,
    );
  }

  @override
  List<Object?> get props => [
        routes,
        initStatus,
        selectedRoute,
      ];
}
