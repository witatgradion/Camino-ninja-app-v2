import 'package:analytics_services/src/analytics_event.dart';

/// Fired when a route is selected.
class RouteSelectedEvent extends AnalyticsEvent {
  /// Creates a [RouteSelectedEvent].
  RouteSelectedEvent({
    required this.routeId,
    required this.routeName,
    this.routeSubName,
  });

  /// The selected route ID.
  final int routeId;

  /// The selected route name.
  final String routeName;

  /// The optional route sub-name.
  final String? routeSubName;

  @override
  String get name => 'route_selected';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'route_sub_name': routeSubName,
      };
}

/// Fired when a starting city is selected.
class StartingCitySelectedEvent extends AnalyticsEvent {
  /// Creates a [StartingCitySelectedEvent].
  StartingCitySelectedEvent({
    required this.cityId,
    required this.cityName,
  });

  /// The selected city ID.
  final int cityId;

  /// The selected city name.
  final String cityName;

  @override
  String get name => 'starting_city_selected';

  @override
  Map<String, dynamic> get properties => {
        'city_id': cityId,
        'city_name': cityName,
      };
}

/// Fired when a destination city is selected.
class DestinationCitySelectedEvent extends AnalyticsEvent {
  /// Creates a [DestinationCitySelectedEvent].
  DestinationCitySelectedEvent({
    required this.cityId,
    required this.cityName,
  });

  /// The selected city ID.
  final int cityId;

  /// The selected city name.
  final String cityName;

  @override
  String get name => 'destination_city_selected';

  @override
  Map<String, dynamic> get properties => {
        'city_id': cityId,
        'city_name': cityName,
      };
}

/// Fired when route points are loaded at destination
/// selection.
class RoutePointsAtSelectDestinationEvent extends AnalyticsEvent {
  /// Creates a [RoutePointsAtSelectDestinationEvent].
  RoutePointsAtSelectDestinationEvent({
    required this.routeId,
    required this.routeName,
    this.routeSubName,
    required this.cityId,
    required this.cityName,
    this.routePointsCount,
  });

  /// The route ID.
  final int routeId;

  /// The route name.
  final String routeName;

  /// The optional route sub-name.
  final String? routeSubName;

  /// The destination city ID.
  final int cityId;

  /// The destination city name.
  final String cityName;

  /// Number of route points available.
  final int? routePointsCount;

  @override
  String get name => 'route_points_at_select_destination';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'route_sub_name': routeSubName,
        'city_id': cityId,
        'city_name': cityName,
        'route_points_count': routePointsCount,
      };
}

/// Fired when destinations are filtered.
class FilterDestinationsEvent extends AnalyticsEvent {
  /// Creates a [FilterDestinationsEvent].
  FilterDestinationsEvent({
    required this.routeId,
    this.startingPointId,
    required this.cityFilter,
    required this.cityCount,
  });

  /// The route ID.
  final int routeId;

  /// The starting point city ID.
  final int? startingPointId;

  /// The applied city filter name.
  final String cityFilter;

  /// The city count after filtering.
  final int cityCount;

  @override
  String get name => 'filter_destinations';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'starting_point_id': startingPointId,
        'city_filter': cityFilter,
        'city_count': cityCount,
      };
}

/// Fired after destination list is filtered and computed.
class FilterDestinationsFilteredEvent extends AnalyticsEvent {
  /// Creates a [FilterDestinationsFilteredEvent].
  FilterDestinationsFilteredEvent({
    required this.routeId,
    this.startingPointId,
    required this.cityFilter,
    required this.cityCount,
  });

  /// The route ID.
  final int routeId;

  /// The starting point city ID.
  final int? startingPointId;

  /// The applied city filter name.
  final String cityFilter;

  /// The city count after filtering.
  final int cityCount;

  @override
  String get name => 'filter_destinations_filtered';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'starting_point_id': startingPointId,
        'city_filter': cityFilter,
        'city_count': cityCount,
      };
}

