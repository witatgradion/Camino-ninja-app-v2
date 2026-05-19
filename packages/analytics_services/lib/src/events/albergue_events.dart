import 'package:analytics_services/src/analytics_event.dart';
import 'package:analytics_services/src/events/booking_click_context.dart';

/// Fired when the feedback form is opened.
class OpenFeedbackEvent extends AnalyticsEvent {
  /// Creates an [OpenFeedbackEvent].
  OpenFeedbackEvent({
    required this.albergueId,
    this.albergueName,
    required this.source,
  });

  /// The albergue ID.
  final int albergueId;

  /// The albergue name.
  final String? albergueName;

  /// Where the feedback was opened from.
  final String source;

  @override
  String get name => 'open_feedback';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'albergue_name': albergueName,
        'source': source,
      };
}

/// Fired when an albergue is shared.
class ShareAlbergueEvent extends AnalyticsEvent {
  /// Creates a [ShareAlbergueEvent].
  ShareAlbergueEvent({
    required this.albergueId,
    this.albergueName,
    required this.shareUrl,
    required this.source,
  });

  /// The albergue ID.
  final int albergueId;

  /// The albergue name.
  final String? albergueName;

  /// The share URL.
  final String shareUrl;

  /// Where the share was initiated from.
  final String source;

  @override
  String get name => 'share_albergue';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'albergue_name': albergueName,
        'share_url': shareUrl,
        'source': source,
      };
}

/// Fired when a Booking.com link is clicked.
class BookingComClickedEvent extends AnalyticsEvent {
  /// Creates a [BookingComClickedEvent].
  BookingComClickedEvent({
    required this.bookingUrl,
    required this.clickId,
    required this.surface,
    required this.widget,
    required this.albergueId,
    required this.albergueName,
    required this.cityId,
    this.cityName,
    this.routeId,
    this.daysUntilTripStart,
  });

  /// The Booking.com URL.
  final String bookingUrl;

  /// Per-click attribution id mirrored into the Booking.com `label` param so
  /// affiliate reports can be joined back to this event.
  final String clickId;

  /// The top-level surface from which the click originated.
  ///
  /// Serialized as `source` on the wire for backwards compatibility with
  /// events emitted before this field was typed.
  final BookingEntrySurface surface;

  /// The specific UI element that was tapped.
  final BookingClickWidget widget;

  /// The albergue ID.
  final int albergueId;

  /// The albergue name.
  final String albergueName;

  /// The city ID.
  final int cityId;

  /// The city name.
  final String? cityName;

  /// The route ID.
  final int? routeId;

  /// Days between "now" and the user's active stage plan starting_date.
  ///
  /// `null` when the user has no plan or no plan has a starting date.
  /// Can be negative when the trip has already started (or is in the past).
  final int? daysUntilTripStart;

  @override
  String get name => 'booking_com_clicked';

  @override
  Map<String, dynamic> get properties => {
        'booking_url': bookingUrl,
        'click_id': clickId,
        'source': surface.value,
        'widget': widget.value,
        'albergue_id': albergueId,
        'albergue_name': albergueName,
        'city_id': cityId,
        'city_name': cityName,
        'route_id': routeId,
        'days_until_trip_start': daysUntilTripStart,
      };
}

/// Fired when Maps.me is opened for an albergue.
class OpenMapsMeEvent extends AnalyticsEvent {
  /// Creates an [OpenMapsMeEvent].
  OpenMapsMeEvent({
    required this.albergueId,
    this.albergueName,
    required this.source,
  });

  final int albergueId;
  final String? albergueName;
  final String source;

  @override
  String get name => 'open_maps_me';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'albergue_name': albergueName,
        'source': source,
      };
}

/// Fired when opening Maps.me fails.
class OpenMapsMeErrorEvent extends AnalyticsEvent {
  /// Creates an [OpenMapsMeErrorEvent].
  OpenMapsMeErrorEvent({
    required this.albergueId,
    this.albergueName,
    required this.source,
  });

  final int albergueId;
  final String? albergueName;
  final String source;

  @override
  String get name => 'open_maps_me_error';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'albergue_name': albergueName,
        'source': source,
      };
}

/// Fired when a photo is uploaded for an albergue.
class UploadAlberguePhotoEvent extends AnalyticsEvent {
  /// Creates an [UploadAlberguePhotoEvent].
  UploadAlberguePhotoEvent({
    required this.albergueId,
    this.albergueName,
    required this.source,
  });

  final int albergueId;
  final String? albergueName;
  final String source;

  @override
  String get name => 'upload_albergue_photo';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'albergue_name': albergueName,
        'source': source,
      };
}

/// Fired when a reserve button is clicked.
class ReserveClickedEvent extends AnalyticsEvent {
  /// Creates a [ReserveClickedEvent].
  ReserveClickedEvent({
    required this.url,
    required this.source,
  });

  /// The reservation URL.
  final String url;

  /// Where the click originated from.
  ///
  /// Stringly-typed to match callers that pass raw source names
  /// (e.g. 'route', 'stage_planner'). Deliberately not migrated to the
  /// typed `BookingEntrySurface` enum — scoped out of the
  /// booking_com_clicked enrichment work (see PR #377). Follow-up:
  /// unify reserve with the same typed enum so all revenue-adjacent
  /// events share vocabulary.
  final String source;

  @override
  String get name => 'reserve_clicked';

  @override
  Map<String, dynamic> get properties => {
        'url': url,
        'source': source,
      };
}

/// Fired when an albergue is added to favorites.
class FavoriteAddedEvent extends AnalyticsEvent {
  /// Creates a [FavoriteAddedEvent].
  FavoriteAddedEvent({
    required this.albergueId,
    required this.cityId,
    required this.routeId,
  });

  /// The albergue ID.
  final int albergueId;

  /// The city ID.
  final int cityId;

  /// The route ID.
  final int routeId;

  @override
  String get name => 'favorite_added';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'city_id': cityId,
        'route_id': routeId,
      };
}

/// Fired when an albergue is removed from favorites.
class FavoriteRemovedEvent extends AnalyticsEvent {
  /// Creates a [FavoriteRemovedEvent].
  FavoriteRemovedEvent({
    required this.albergueId,
    required this.cityId,
    required this.routeId,
  });

  /// The albergue ID.
  final int albergueId;

  /// The city ID.
  final int cityId;

  /// The route ID.
  final int routeId;

  @override
  String get name => 'favorite_removed';

  @override
  Map<String, dynamic> get properties => {
        'albergue_id': albergueId,
        'city_id': cityId,
        'route_id': routeId,
      };
}
