import 'package:analytics_services/src/analytics_event.dart';

/// Fired once per `CityDetailsScreen` mount, the first time accommodations
/// have finished loading.
///
/// Pairs with `BookingComClickedEvent` to compute view → click CTR on the
/// city details surface.
class CityDetailsViewedEvent extends AnalyticsEvent {
  /// Creates a [CityDetailsViewedEvent].
  CityDetailsViewedEvent({
    required this.cityId,
    required this.cityName,
    required this.numAccommodations,
    this.routeId,
  });

  /// The city ID.
  final int cityId;

  /// The city name.
  final String cityName;

  /// The route ID the city was browsed from.
  final int? routeId;

  /// The number of accommodations available at view time.
  final int numAccommodations;

  @override
  String get name => 'city_details_viewed';

  @override
  Map<String, dynamic> get properties => {
        'city_id': cityId,
        'city_name': cityName,
        'route_id': routeId,
        'num_accommodations': numAccommodations,
      };
}
