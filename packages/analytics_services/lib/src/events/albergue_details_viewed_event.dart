import 'package:analytics_services/src/analytics_event.dart';
import 'package:analytics_services/src/events/booking_click_context.dart';

/// Fired once per `AlbergueDetailsScreen` mount, the first time the albergue
/// has finished loading.
///
/// Pairs with `BookingComClickedEvent` to compute view → click CTR on the
/// details surface.
class AlbergueDetailsViewedEvent extends AnalyticsEvent {
  /// Creates an [AlbergueDetailsViewedEvent].
  AlbergueDetailsViewedEvent({
    required this.albergueId,
    required this.albergueName,
    required this.cityId,
    required this.entrySurface,
    required this.hasBookingComUrl,
    required this.hasBookingPrice,
    required this.bookingRating,
    required this.ninjaRating,
    this.cityName,
    this.routeId,
  });

  /// The albergue ID.
  final int albergueId;

  /// The albergue name.
  final String albergueName;

  /// The city ID (resolved — falls back to albergue.cityId when needed).
  final int cityId;

  /// The city name, when available.
  final String? cityName;

  /// The resolved route ID, when available.
  final int? routeId;

  /// The top-level surface the user arrived from.
  final BookingEntrySurface entrySurface;

  /// Whether the albergue exposes a launchable Booking.com URL.
  final bool hasBookingComUrl;

  /// Whether the albergue exposes a positive Booking.com price.
  final bool hasBookingPrice;

  /// The Booking.com review score (0 when absent).
  final double bookingRating;

  /// The Camino Ninja rating (0 when absent).
  final double ninjaRating;

  @override
  String get name => 'albergue_details_viewed';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'albergue_name': albergueName,
        'city_id': cityId,
        'city_name': cityName,
        'route_id': routeId,
        'entry_surface': entrySurface.value,
        'has_booking_com_url': hasBookingComUrl,
        'has_booking_price': hasBookingPrice,
        'booking_rating': bookingRating,
        'ninja_rating': ninjaRating,
      };
}
