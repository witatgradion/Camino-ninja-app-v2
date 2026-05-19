import 'dart:math';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/utils/booking_url_mapper.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

/// Generates a 16-char lowercase hex id (8 random bytes) for per-click
/// attribution on Booking.com affiliate reports.
String _generateBookingClickId() {
  final random = Random.secure();
  final bytes = List<int>.generate(8, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Tracks a Booking.com click with per-click attribution and launches the
/// resolved affiliate URL.
///
/// The generated click id is mirrored both into the Booking.com `label` param
/// (so affiliate reports echo it back) and onto the emitted
/// [BookingComClickedEvent] as `click_id`, allowing reports to be joined back
/// to the originating click event in Amplitude.
///
/// No-op when [AlbergueEntity.bookingComUrl] is `null`.
Future<void> trackAndLaunchBookingClick({
  required AlbergueEntity albergue,
  required int? routeId,
  required BookingEntrySurface surface,
  required BookingClickWidget clickWidget,
}) async {
  final rawUrl = albergue.bookingComUrl;
  if (rawUrl == null) return;

  final clickId = _generateBookingClickId();
  final (resolvedUrl, daysUntilTripStart) = await (
    bookingUrl(rawUrl, clickId: clickId),
    _resolveDaysUntilTripStart(),
  ).wait;

  GetIt.instance<IAnalyticsService>().track(
    BookingComClickedEvent(
      bookingUrl: resolvedUrl,
      clickId: clickId,
      surface: surface,
      widget: clickWidget,
      albergueId: albergue.id,
      albergueName: albergue.name,
      cityId: albergue.cityId,
      cityName: albergue.cityName,
      routeId: routeId,
      daysUntilTripStart: daysUntilTripStart,
    ),
  );

  await launchUrlSafely(
    resolvedUrl,
    trackEvent: false,
  );
}

/// Resolves `days_until_trip_start` for the current user.
///
/// Queries [StagePlanRepository.getActivePlanStartingDate] — the soonest
/// upcoming stage plan's starting_date, falling back to the most recent
/// past plan if no upcoming plan exists. Returns the delta in days between
/// that date and today. Can be negative for trips already in progress or
/// past.
///
/// Returns `null` when the user has no plan or no plan has a starting date,
/// or when the lookup fails — analytics stays best-effort.
Future<int?> _resolveDaysUntilTripStart() async {
  try {
    final startingDate = await GetIt.instance<StagePlanRepository>()
        .getActivePlanStartingDate();
    if (startingDate == null) return null;

    final today = DateTime.now();
    final startDateOnly =
        DateTime(startingDate.year, startingDate.month, startingDate.day);
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    return startDateOnly.difference(todayDateOnly).inDays;
  } catch (_) {
    return null;
  }
}
