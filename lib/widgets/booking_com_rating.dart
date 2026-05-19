import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/booking_click_tracker.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:storage/storage.dart';

class BookingComRating extends StatelessWidget {
  const BookingComRating({
    required this.rating,
    required this.surface,
    required this.clickWidget,
    required this.albergue,
    this.routeId,
    this.showInisdeRating = false,
    super.key,
  });
  final double rating;
  final AlbergueEntity albergue;
  final int? routeId;
  final bool showInisdeRating;
  final BookingEntrySurface surface;
  final BookingClickWidget clickWidget;

  @override
  Widget build(BuildContext context) {
    final normalizedRating = (rating / 10) * 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: showInisdeRating
                      ? Colors.transparent
                      : const Color(0xFF273B7D),
                  border: !showInisdeRating
                      ? null
                      : Border.all(
                          color: const Color(0xFF273B7D),
                          width: 2,
                        ),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: SvgPicture.asset(
                        showInisdeRating
                            ? (context.isDarkMode
                                ? 'assets/logo_booking_com_dark.svg'
                                : 'assets/logo_booking_com_light.svg')
                            : 'assets/logo_booking_com_dark.svg',
                        // color: Colors.black,
                      ),
                    ),
                    if (showInisdeRating) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: SvgPicture.asset(
                          'assets/ic_star_full.svg',
                          width: 16,
                          height: 16,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        normalizedRating.toStringAsFixed(1),
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!showInisdeRating) ...[
                const SizedBox(width: 8),
                CustomRatingBar(
                  initialRating: rating,
                  inputRatingScale: 10,
                  allowHalfRating: true,
                  enable: false,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onTap() => trackAndLaunchBookingClick(
        albergue: albergue,
        routeId: routeId,
        surface: surface,
        clickWidget: clickWidget,
      );
}
