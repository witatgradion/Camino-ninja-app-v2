part of 'route_city_overview_cubit.dart';

enum RouteCityOverviewStatus { initial, loading, success, failure }

/// A city annotated with the other routes that pass through it.
class CityOverviewEntry extends Equatable {
  const CityOverviewEntry({
    required this.city,
    required this.junctionRoutes,
  });

  final CityEntity city;

  /// Routes OTHER than the selected segment's route that also
  /// pass through this city. Non-empty = junction city.
  final List<RouteEntity> junctionRoutes;

  bool get isJunction => junctionRoutes.isNotEmpty;

  @override
  List<Object?> get props => [city, junctionRoutes];
}

/// A segment of the user's journey on a single route.
class OverviewSegment extends Equatable {
  const OverviewSegment({
    required this.routeId,
    required this.routeName,
    required this.routeColor,
    required this.allEntries,
    this.routeSubName,
    this.splitAtCityId,
    this.routePoints = const [],
  });

  final int routeId;
  final String routeName;
  final String? routeSubName;
  final Color routeColor;

  /// Full city list for this route (from start or junction),
  /// never mutated.
  final List<CityOverviewEntry> allEntries;

  /// If the user split at a junction, this is the city ID where
  /// they split. Entries after this city are hidden. Null = show
  /// all (this is the active/final segment).
  final int? splitAtCityId;

  /// Route points for drawing the segment on a map.
  /// Not included in [props] — purely display data.
  final List<RoutePointEntity> routePoints;

  /// Entries visible in the UI.
  List<CityOverviewEntry> get visibleEntries {
    if (splitAtCityId == null) return allEntries;
    final idx = allEntries.indexWhere(
      (e) => e.city.id == splitAtCityId,
    );
    if (idx < 0) return allEntries;
    return allEntries.sublist(0, idx + 1);
  }

  OverviewSegment copyWith({
    int? Function()? splitAtCityId,
    List<RoutePointEntity>? routePoints,
  }) {
    return OverviewSegment(
      routeId: routeId,
      routeName: routeName,
      routeSubName: routeSubName,
      routeColor: routeColor,
      allEntries: allEntries,
      splitAtCityId: splitAtCityId != null
          ? splitAtCityId()
          : this.splitAtCityId,
      routePoints: routePoints ?? this.routePoints,
    );
  }

  @override
  List<Object?> get props => [
        routeId,
        allEntries,
        splitAtCityId,
      ];
}

class RouteCityOverviewState extends Equatable {
  const RouteCityOverviewState({
    this.status = RouteCityOverviewStatus.initial,
    this.routes = const [],
    this.selectedRouteId,
    this.segments = const [],
  });

  final RouteCityOverviewStatus status;
  final List<RouteEntity> routes;
  final int? selectedRouteId;

  /// The journey path — each segment is one route's city list.
  final List<OverviewSegment> segments;

  RouteCityOverviewState copyWith({
    RouteCityOverviewStatus? status,
    List<RouteEntity>? routes,
    int? selectedRouteId,
    List<OverviewSegment>? segments,
  }) {
    return RouteCityOverviewState(
      status: status ?? this.status,
      routes: routes ?? this.routes,
      selectedRouteId: selectedRouteId ?? this.selectedRouteId,
      segments: segments ?? this.segments,
    );
  }

  @override
  List<Object?> get props => [
        status,
        routes,
        selectedRouteId,
        segments,
      ];
}
