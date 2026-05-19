import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/albergue_list_price.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_details_screen.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:camino_ninja_flutter/widgets/booking_com_rating.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:camino_ninja_flutter/widgets/ninja_rating.dart';
import 'package:camino_ninja_flutter/widgets/stay_here_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:storage/storage.dart';

class StageAlbergueWidget extends StatelessWidget {
  const StageAlbergueWidget({
    required this.albergue,
    required this.onTap,
    required this.onViewDetailTap,
    required this.onStayHereTap,
    this.isExpanded = false,
    this.isBookmarked = false,
    this.compareDate,
    this.isSelected = false,
    this.routeId,
    super.key,
  });
  final AlbergueEntity albergue;
  final bool isExpanded;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onViewDetailTap;
  final VoidCallback onStayHereTap;
  final DateTime? compareDate;
  final bool isSelected;
  final int? routeId;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bookingComUrl = albergue.bookingComUrl ?? '';

    final bookingRating = albergue.reviews.firstOrNull?.bReviewScore ?? 0;
    final ninjaRating = albergue.ninjaRating ?? 0;

    final isBookingComUrlValid = isLaunchableUrl(bookingComUrl);

    return Ink(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.gray800 : AppColors.gray200,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBookmarked) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primary80 : AppColors.primary40,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/ic_bookmark_filled_small.svg',
                        width: 14,
                        colorFilter: ColorFilter.mode(
                          context.isDarkMode ? Colors.black : Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).savedAccommodation,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              context.isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Padding(
                padding: const EdgeInsets.only(right: 32),
                child: Text(
                  albergue.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color:
                            isDark ? AppColors.primary80 : AppColors.primary40,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (albergue.prices.isNotEmpty) ...[
                const SizedBox(height: 4),
                AlbergueListPrice(price: albergue.prices.first),
                const SizedBox(height: 4),
              ],
              Wrap(
                spacing: 4,
                children: [
                  StatusIndicator.buildIndicator(
                    context,
                    isUnknownOpenSeason: albergue
                            .operatingHours.firstOrNull?.unknownOpenSeason ??
                        false,
                    opensAllYear:
                        albergue.operatingHours.firstOrNull?.opensAllYear ??
                            false,
                    isWithinOpenSeason:
                        albergue.isWithinOpenSeason(compareDate: compareDate),
                    compareDate: compareDate,
                    status: albergue.status,
                    opensDate: (albergue.operatingHours.firstOrNull?.opens !=
                                null &&
                            albergue.operatingHours.firstOrNull?.opens != '')
                        ? DateTime.parse(albergue.operatingHours.first.opens!)
                        : null,
                  ),
                  if (ninjaRating != 0) ...[
                    NinjaRating(
                      rating: ninjaRating,
                      showInisdeRating: true,
                    ),
                  ],
                  if (isBookingComUrlValid && bookingRating != 0) ...[
                    BookingComRating(
                      rating: bookingRating,
                      albergue: albergue,
                      routeId: routeId,
                      showInisdeRating: true,
                      surface: BookingEntrySurface.stagePlanner,
                      clickWidget: BookingClickWidget.stageAlbergueRatingChip,
                    ),
                  ],
                ],
              ),
              RepaintBoundary(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(
                    begin: 0,
                    end: isExpanded ? 1.0 : 0.0,
                  ),
                  builder: (context, value, child) {
                    return ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StayHereButton(
                            isSelected: isSelected,
                            onTap: onStayHereTap,
                          ),
                          CustomOutlineButton(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            text: AppLocalizations.of(context).viewDetail,
                            onTap: onViewDetailTap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
