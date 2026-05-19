part of 'journey_planner_cubit.dart';

enum JourneyPlannerStatus {
  initial,
  loadingCities,
  startCitySelection,
  destinationCitySelection,
  loadingRoutes,
  routeOptions,
  failure,
}

/// Reachability of a city relative to the selected
/// start city in the route network.
enum CityReachability {
  /// City shares a route with the start city.
  direct,

  /// City is reachable via one or more junctions.
  viaJunction,

  /// No path exists from the start city.
  notReachable,
}

class JourneyPlannerState extends Equatable {
  const JourneyPlannerState({
    this.status = JourneyPlannerStatus.initial,
    this.allCities = const [],
    this.allRoutes = const [],
    this.startCity,
    this.endCity,
    this.journeyOptions = const [],
    this.errorMessage,
    this.cityRouteNames = const {},
    this.cityRouteIds = const {},
    this.directlyReachableCityIds = const {},
    this.viaJunctionReachableCityIds = const {},
    this.destinationRouteNames = const {},
    this.selectedOptionIndex,
  });

  /// Current status of the journey planner wizard.
  final JourneyPlannerStatus status;

  /// All cities across all routes (deduplicated by ID).
  final List<CityEntity> allCities;

  /// All available routes.
  final List<RouteEntity> allRoutes;

  /// The selected start city.
  final CityEntity? startCity;

  /// The selected destination city.
  final CityEntity? endCity;

  /// Computed journey options from start to end.
  final List<JourneyOption> journeyOptions;

  /// Error message when status is
  /// [JourneyPlannerStatus.failure].
  final String? errorMessage;

  /// Maps city ID to a list of route names that pass
  /// through it, for display as subtitles.
  final Map<int, List<String>> cityRouteNames;

  /// Maps city ID to the set of route IDs that pass
  /// through it. Used for reachability computation.
  final Map<int, Set<int>> cityRouteIds;

  /// City IDs that are forward-reachable from the start
  /// city on a shared (direct) route — meaning the city
  /// comes AFTER the start city in walking order on at
  /// least one route they share.
  final Set<int> directlyReachableCityIds;

  /// City IDs reachable from the start city via at least
  /// one forward junction but not directly. These lie on
  /// routes you can reach by taking a junction ahead of
  /// the start city.
  ///
  /// Note: This set is an approximation — some cities may
  /// not actually be reachable because the junction lies
  /// after the required city on an intermediate route.
  /// Such false positives surface as "No routes found"
  /// after the user selects the destination, which is
  /// acceptable UX for the reachability badge.
  final Set<int> viaJunctionReachableCityIds;

  /// For each destination city reachable from the start
  /// city, the subset of route names where walking forward
  /// from start actually reaches the destination. Used to
  /// filter the subtitle in destination search.
  final Map<int, List<String>> destinationRouteNames;

  /// Returns the forward-walkable route names for a
  /// destination city, or null if the city has no
  /// precomputed entry (e.g., not reachable).
  List<String>? routeNamesForDestination(int cityId) {
    return destinationRouteNames[cityId];
  }

  /// Index of the selected journey option on the map.
  /// When null, all options are shown at equal weight.
  final int? selectedOptionIndex;

  /// Computes the reachability of a city based on the
  /// pre-computed forward-reachable city sets.
  CityReachability reachabilityOf(int cityId) {
    if (directlyReachableCityIds.contains(cityId)) {
      return CityReachability.direct;
    }
    if (viaJunctionReachableCityIds.contains(cityId)) {
      return CityReachability.viaJunction;
    }
    return CityReachability.notReachable;
  }

  JourneyPlannerState copyWith({
    JourneyPlannerStatus? status,
    List<CityEntity>? allCities,
    List<RouteEntity>? allRoutes,
    CityEntity? Function()? startCity,
    CityEntity? Function()? endCity,
    List<JourneyOption>? journeyOptions,
    String? Function()? errorMessage,
    Map<int, List<String>>? cityRouteNames,
    Map<int, Set<int>>? cityRouteIds,
    Set<int>? directlyReachableCityIds,
    Set<int>? viaJunctionReachableCityIds,
    Map<int, List<String>>? destinationRouteNames,
    int? Function()? selectedOptionIndex,
  }) {
    return JourneyPlannerState(
      status: status ?? this.status,
      allCities: allCities ?? this.allCities,
      allRoutes: allRoutes ?? this.allRoutes,
      startCity: startCity != null ? startCity() : this.startCity,
      endCity: endCity != null ? endCity() : this.endCity,
      journeyOptions: journeyOptions ?? this.journeyOptions,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      cityRouteNames: cityRouteNames ?? this.cityRouteNames,
      cityRouteIds: cityRouteIds ?? this.cityRouteIds,
      directlyReachableCityIds:
          directlyReachableCityIds ?? this.directlyReachableCityIds,
      viaJunctionReachableCityIds:
          viaJunctionReachableCityIds ?? this.viaJunctionReachableCityIds,
      destinationRouteNames:
          destinationRouteNames ?? this.destinationRouteNames,
      selectedOptionIndex: selectedOptionIndex != null
          ? selectedOptionIndex()
          : this.selectedOptionIndex,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allCities,
        allRoutes,
        startCity,
        endCity,
        journeyOptions,
        errorMessage,
        cityRouteNames,
        cityRouteIds,
        directlyReachableCityIds,
        viaJunctionReachableCityIds,
        destinationRouteNames,
        selectedOptionIndex,
      ];
}
