part of 'trail_builder_cubit.dart';

enum TrailBuilderStatus {
  initial,
  loading,
  routeSelection,
  citySelection,
  junction,
  complete,
  failure,
}

/// Information about a junction decision the user must make.
class JunctionInfo extends Equatable {
  const JunctionInfo({
    required this.city,
    required this.branchRoutes,
    required this.currentRoute,
    this.routeEndCity,
  });

  /// The junction city where the decision is made.
  final CityEntity city;

  /// Routes available to switch to at this junction.
  final List<RouteEntity> branchRoutes;

  /// The route the user is currently walking.
  final RouteEntity currentRoute;

  /// Display name of the current route's terminus, so the
  /// user knows where "continue" leads.
  final String? routeEndCity;

  @override
  List<Object?> get props => [
        city,
        branchRoutes,
        currentRoute,
        routeEndCity,
      ];
}

/// Data needed to render the mini junction graph.
class JunctionGraphData extends Equatable {
  const JunctionGraphData({
    required this.junctionCity,
    required this.branches,
  });

  /// The junction city (positioned at the bottom center).
  final CityEntity junctionCity;

  /// Each branch: a route with a few upcoming cities.
  /// The first branch is the "continue" route.
  final List<JunctionBranch> branches;

  @override
  List<Object?> get props => [junctionCity, branches];
}

/// A single branch in the junction graph.
class JunctionBranch extends Equatable {
  const JunctionBranch({
    required this.routeName,
    required this.colorValue,
    required this.cities,
    this.isContinue = false,
  });

  /// Display name of the route this branch follows.
  final String routeName;

  /// ARGB color int for drawing this branch.
  final int colorValue;

  /// A few cities along this branch (max 2-3),
  /// ordered by walking direction.
  final List<CityEntity> cities;

  /// True if this is the "continue on current route"
  /// branch.
  final bool isContinue;

  @override
  List<Object?> get props => [
        routeName,
        colorValue,
        cities,
        isContinue,
      ];
}

/// Snapshot of cubit state stored for undo support.
class _DecisionSnapshot {
  const _DecisionSnapshot({
    required this.segments,
    required this.currentRouteId,
    required this.pendingJunctions,
    required this.currentJunctionIndex,
    required this.segmentStartCityId,
  });

  final List<TrailSegment> segments;
  final int currentRouteId;
  final List<JunctionPoint> pendingJunctions;
  final int currentJunctionIndex;
  final int? segmentStartCityId;
}

class TrailBuilderState extends Equatable {
  const TrailBuilderState({
    this.status = TrailBuilderStatus.initial,
    this.routes = const [],
    this.routeCities = const [],
    this.segments = const [],
    this.currentRouteId,
    this.currentJunction,
    this.junctionGraphData,
    this.pendingJunctions = const [],
    this.currentJunctionIndex = 0,
    this.segmentStartCityId,
  });

  /// Current status of the builder flow.
  final TrailBuilderStatus status;

  /// All available routes the user can pick from.
  final List<RouteEntity> routes;

  /// Cities on the selected route, shown during the
  /// [TrailBuilderStatus.citySelection] phase.
  final List<CityEntity> routeCities;

  /// Trail segments built so far (finalized decisions).
  final List<TrailSegment> segments;

  /// The route the user is currently walking on.
  final int? currentRouteId;

  /// The junction decision currently presented to the user.
  final JunctionInfo? currentJunction;

  /// Graph data for the mini junction visualisation.
  final JunctionGraphData? junctionGraphData;

  /// Remaining junctions on the current route, loaded from
  /// [JunctionService.getJunctionsForRoute].
  final List<JunctionPoint> pendingJunctions;

  /// Index into [pendingJunctions] for the current junction.
  final int currentJunctionIndex;

  /// The city ID where the current in-progress segment
  /// starts. Null for the first segment (starts at route
  /// beginning).
  final int? segmentStartCityId;

  TrailBuilderState copyWith({
    TrailBuilderStatus? status,
    List<RouteEntity>? routes,
    List<CityEntity>? routeCities,
    List<TrailSegment>? segments,
    int? Function()? currentRouteId,
    JunctionInfo? Function()? currentJunction,
    JunctionGraphData? Function()? junctionGraphData,
    List<JunctionPoint>? pendingJunctions,
    int? currentJunctionIndex,
    int? Function()? segmentStartCityId,
  }) {
    return TrailBuilderState(
      status: status ?? this.status,
      routes: routes ?? this.routes,
      routeCities: routeCities ?? this.routeCities,
      segments: segments ?? this.segments,
      currentRouteId: currentRouteId != null
          ? currentRouteId()
          : this.currentRouteId,
      currentJunction: currentJunction != null
          ? currentJunction()
          : this.currentJunction,
      junctionGraphData: junctionGraphData != null
          ? junctionGraphData()
          : this.junctionGraphData,
      pendingJunctions:
          pendingJunctions ?? this.pendingJunctions,
      currentJunctionIndex:
          currentJunctionIndex ?? this.currentJunctionIndex,
      segmentStartCityId: segmentStartCityId != null
          ? segmentStartCityId()
          : this.segmentStartCityId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        routes,
        routeCities,
        segments,
        currentRouteId,
        currentJunction,
        junctionGraphData,
        pendingJunctions,
        currentJunctionIndex,
        segmentStartCityId,
      ];
}
