import 'package:analytics_services/src/analytics_event.dart';

/// Fired when the my-location button is clicked.
class MyLocationClickedEvent extends AnalyticsEvent {
  /// Creates a [MyLocationClickedEvent].
  MyLocationClickedEvent({
    this.routeId,
    this.routeName,
    required this.source,
    this.hasLocationPermission,
    this.distanceFromRoute,
  });

  /// The route ID.
  final int? routeId;

  /// The route name.
  final String? routeName;

  /// Where the click originated from.
  final String source;

  /// Whether location permission is granted.
  final bool? hasLocationPermission;

  /// Distance from the route (formatted string or
  /// double).
  final Object? distanceFromRoute;

  @override
  String get name => 'my_location_clicked';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
        'route_name': routeName,
        'source': source,
        'has_location_permission': hasLocationPermission,
        'distance_from_route': distanceFromRoute,
      };
}

/// Fired when find transportation is clicked.
class FindTransportationClickedEvent extends AnalyticsEvent {
  /// Creates a [FindTransportationClickedEvent].
  FindTransportationClickedEvent({required this.routeId});

  /// The route ID.
  final int routeId;

  @override
  String get name => 'find_transportation_clicked';

  @override
  Map<String, dynamic> get properties => {
        'route_id': routeId,
      };
}
