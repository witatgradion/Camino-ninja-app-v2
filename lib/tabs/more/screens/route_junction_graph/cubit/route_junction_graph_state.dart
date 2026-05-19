part of 'route_junction_graph_cubit.dart';

enum RouteJunctionGraphStatus { initial, loading, success, failure }

class RouteJunctionGraphState extends Equatable {
  const RouteJunctionGraphState({
    this.status = RouteJunctionGraphStatus.initial,
    this.routes = const [],
    this.selectedRouteId,
    this.path = const [],
    this.resolvedJunctions = const [],
    this.pendingJunction,
    this.isComplete = false,
  });

  /// All available routes for the dropdown selector.
  final RouteJunctionGraphStatus status;

  /// All routes fetched from the database.
  final List<RouteEntity> routes;

  /// The initially selected route.
  final int? selectedRouteId;

  /// Segments the user has traversed so far, in order.
  final List<PathSegment> path;

  /// Junctions the user has already resolved.
  /// `resolvedJunctions[i]` is the junction after `path[i]`.
  final List<ResolvedJunction> resolvedJunctions;

  /// The current junction waiting for the user's choice.
  /// Null when no junction is pending (route just started
  /// or user hasn't reached one yet).
  final JunctionChoice? pendingJunction;

  /// True when the user has reached the end of a route
  /// with no more junctions.
  final bool isComplete;

  RouteJunctionGraphState copyWith({
    RouteJunctionGraphStatus? status,
    List<RouteEntity>? routes,
    int? selectedRouteId,
    List<PathSegment>? path,
    List<ResolvedJunction>? resolvedJunctions,
    JunctionChoice? Function()? pendingJunction,
    bool? isComplete,
  }) {
    return RouteJunctionGraphState(
      status: status ?? this.status,
      routes: routes ?? this.routes,
      selectedRouteId: selectedRouteId ?? this.selectedRouteId,
      path: path ?? this.path,
      resolvedJunctions: resolvedJunctions ?? this.resolvedJunctions,
      pendingJunction: pendingJunction != null
          ? pendingJunction()
          : this.pendingJunction,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [
        status,
        routes,
        selectedRouteId,
        path,
        resolvedJunctions,
        pendingJunction,
        isComplete,
      ];
}
