import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_contact_list.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_list_icon_full.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_season_additional_section.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/bed_count_display.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/booking_com_price.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/albergue_list_price.dart';
import 'package:camino_ninja_flutter/utils/booking_click_tracker.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:camino_ninja_flutter/widgets/booking_com_rating.dart';
import 'package:camino_ninja_flutter/widgets/ninja_rating.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

class AlbergueMainSection extends StatelessWidget {
  const AlbergueMainSection({
    required this.albergue,
    required this.surface,
    required this.routeId,
    super.key,
  });
  final AlbergueEntity albergue;
  final BookingEntrySurface surface;
  final int? routeId;

  @override
  Widget build(BuildContext context) {
    final closeTime = albergue.operatingHours.firstOrNull?.closeTime ?? '';
    final checkinTime = albergue.operatingHours.firstOrNull?.checkinTime ?? '';
    final checkoutTime =
        albergue.operatingHours.firstOrNull?.checkoutTime ?? '';
    final shouldShowOperatingHours = closeTime.isNotEmpty ||
        checkinTime.isNotEmpty ||
        checkoutTime.isNotEmpty;

    final bookingRating = albergue.reviews.firstOrNull?.bReviewScore ?? 0;
    final ninjaRating = albergue.ninjaRating ?? 0;
    final bookingComUrl = albergue.bookingComUrl;
    final isBookingComUrlValid = isLaunchableUrl(bookingComUrl);

    final shouldShowScore =
        (isBookingComUrlValid && bookingRating != 0) || ninjaRating != 0;

    final bookingPrice = albergue.bookingPrice;
    final bookingPriceUpdatedAt = DateTime.tryParse(
      albergue.bookingPriceUpdatedAt ?? '',
    );
    final price = albergue.prices.firstOrNull;
    final hasPrice =
        price?.hasPrice ?? false || (bookingPrice != null && bookingPrice > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              if (hasPrice) ...[
                Text(
                  '${AppLocalizations.of(context).price}:',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                if (price != null) ...[
                  const SizedBox(height: 8),
                  AlbergueListPrice(
                    price: price,
                    showLabel: true,
                  ),
                ],
                if (bookingPrice != null && bookingPrice > 0) ...[
                  const SizedBox(height: 24),
                  BookingComPrice(
                    price: bookingPrice,
                    updatedAt: bookingPriceUpdatedAt,
                    onTap: () async {
                      if (!isBookingComUrlValid) return;
                      await trackAndLaunchBookingClick(
                        albergue: albergue,
                        routeId: routeId,
                        surface: surface,
                        clickWidget: BookingClickWidget.bookingPriceRow,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
              ],
              Text(
                '${AppLocalizations.of(context).whatInHere}:',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              AlbergueListIconsFull(
                albergue: albergue,
                showFull: true,
              ),
              const SizedBox(height: 24),
              if (shouldShowScore) ...[
                Text(
                  '${AppLocalizations.of(context).ratings}:',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (ninjaRating != 0) ...[
                  NinjaRating(
                    rating: ninjaRating,
                  ),
                ],
                if (ninjaRating != 0 &&
                    bookingRating != 0 &&
                    isBookingComUrlValid) ...[
                  const SizedBox(height: 10),
                ],
                if (isBookingComUrlValid && bookingRating != 0) ...[
                  BookingComRating(
                    rating: bookingRating,
                    albergue: albergue,
                    routeId: routeId,
                    surface: surface,
                    clickWidget: BookingClickWidget.albergueDetailsRatingChip,
                  ),
                ],
                const SizedBox(height: 24),
              ],
              if (shouldShowOperatingHours) ...[
                if (checkinTime.isNotEmpty)
                  Text(
                    '${AppLocalizations.of(context).checkIn}: '
                    '$checkinTime',
                  ),
                if (closeTime.isNotEmpty)
                  Text(
                    '${AppLocalizations.of(context).doorsClose}: '
                    '$closeTime',
                  ),
                if (checkoutTime.isNotEmpty)
                  Text(
                    '${AppLocalizations.of(context).checkout}: '
                    '$checkoutTime',
                  ),
                const SizedBox(height: 16),
              ],
              if (albergue.placesInDormitory != null ||
                  albergue.numberOfDormitories != null) ...[
                BedCountDisplay(
                  placesInDormitory: albergue.placesInDormitory,
                  numberOfDormitories: albergue.numberOfDormitories,
                ),
              ],
              SeasonAndAdditionalInformation(
                albergue: albergue,
              ),
              AlbergueContactList(
                phones: albergue.phones,
                emails: albergue.emails,
                socialMedia: albergue.socialMedias.firstOrNull,
                website: albergue.web,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

}
