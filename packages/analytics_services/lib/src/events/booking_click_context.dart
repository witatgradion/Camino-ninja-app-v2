/// The top-level surface from which a Booking.com click originated.
///
/// NOTE: The wire [value]s are consumed downstream by Amplitude/Firebase and
/// must remain stable. In particular [routeBrowse] serializes as `'route'`
/// (not `'route_browse'`) to preserve joinability with historical events
/// emitted since v2.2.383-prod.
enum BookingEntrySurface {
  /// The route-browse flow (route tab: city details, albergue details opened
  /// from the route tab, etc.).
  routeBrowse('route'),

  /// The stage planner flow (plan tab: selecting albergues for a stage, etc.).
  stagePlanner('stage_planner');

  const BookingEntrySurface(this.value);

  /// The stable wire value sent to analytics.
  final String value;
}

/// The specific UI element that triggered a Booking.com click.
///
/// Granular per-widget attribution — pairs with [BookingEntrySurface] to
/// identify exactly which control the user tapped.
enum BookingClickWidget {
  /// The "Booking.com" CTA button on the albergue details screen.
  albergueDetailsButton('albergue_details_button'),

  /// The Booking.com rating chip on the albergue details screen.
  albergueDetailsRatingChip('albergue_details_rating_chip'),

  /// The booking price row on the albergue details screen.
  bookingPriceRow('booking_price_row'),

  /// The "Booking.com" CTA button on the city details screen.
  cityDetailsButton('city_details_button'),

  /// The Booking.com rating chip on the city details screen.
  cityDetailsRatingChip('city_details_rating_chip'),

  /// The Booking.com rating chip on the stage planner albergue card.
  stageAlbergueRatingChip('stage_albergue_rating_chip');

  const BookingClickWidget(this.value);

  /// The stable wire value sent to analytics.
  final String value;
}
