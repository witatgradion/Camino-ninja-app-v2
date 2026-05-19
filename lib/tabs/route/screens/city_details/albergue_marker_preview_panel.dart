import 'package:analytics_services/analytics_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_list_icon_full.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/albergue_list_price.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_details_screen.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:camino_ninja_flutter/widgets/booking_com_button.dart';
import 'package:camino_ninja_flutter/widgets/booking_com_rating.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:camino_ninja_flutter/widgets/ninja_rating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:storage/storage.dart';

class AlberguePreviewPanel extends StatelessWidget {
  const AlberguePreviewPanel({
    required this.albergue,
    required this.onCancel,
    required this.onViewDetail,
    this.images = const [],
    this.onImageTap,
    this.routeId,
    super.key,
  });

  final AlbergueEntity albergue;
  final VoidCallback onCancel;
  final VoidCallback onViewDetail;
  final List<ImageEntity> images;
  final void Function(int index)? onImageTap;
  final int? routeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;
    final isBookingComUrlValid = isLaunchableUrl(albergue.bookingComUrl);
    final bookingRating = albergue.reviews.firstOrNull?.bReviewScore ?? 0;
    final ninjaRating = albergue.ninjaRating ?? 0;
    final opensRaw = albergue.operatingHours.firstOrNull?.opens;
    final opensDate = (opensRaw != null && opensRaw.isNotEmpty)
        ? DateTime.tryParse(opensRaw)
        : null;

    final showNinjaRating = ninjaRating != 0;
    final showBookingRating = isBookingComUrlValid && bookingRating != 0;
    final showRatingRow = showNinjaRating || showBookingRating;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.gray800 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (images.isNotEmpty)
                  _PreviewHeroImage(
                    imageUrl: images.first.fileName.toPhotoUrl(),
                    onTap: () => onImageTap?.call(0),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Text(
                    albergue.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.primary80
                              : AppColors.primary40,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusIndicator.buildIndicator(
                      context,
                      isUnknownOpenSeason: albergue
                              .operatingHours.firstOrNull?.unknownOpenSeason ??
                          false,
                      opensAllYear:
                          albergue.operatingHours.firstOrNull?.opensAllYear ??
                              false,
                      isWithinOpenSeason: albergue.isWithinOpenSeason(),
                      status: albergue.status,
                      opensDate: opensDate,
                    ),
                    if (showRatingRow)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (showNinjaRating)
                            NinjaRating(
                              rating: ninjaRating,
                              showInisdeRating: true,
                            ),
                          if (showBookingRating)
                            BookingComRating(
                              rating: bookingRating,
                              albergue: albergue,
                              routeId: routeId,
                              showInisdeRating: true,
                              surface: BookingEntrySurface.routeBrowse,
                              clickWidget:
                                  BookingClickWidget.cityDetailsRatingChip,
                            ),
                        ],
                      ),
                  ],
                ),
                if (albergue.prices.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  AlbergueListPrice(price: albergue.prices.first),
                ],
                if (albergue.facilities.firstOrNull != null) ...[
                  const SizedBox(height: 12),
                  AlbergueListIconsFull(albergue: albergue),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (isBookingComUrlValid) ...[
                      BookingComButton(
                        albergue: albergue,
                        routeId: routeId,
                        surface: BookingEntrySurface.routeBrowse,
                        clickWidget: BookingClickWidget.cityDetailsButton,
                        height: 48,
                      ),
                      const SizedBox(width: 12),
                    ],
                    CustomOutlineButton(
                      padding: const EdgeInsets.symmetric(horizontal: 21),
                      text: l10n.viewDetail,
                      onTap: onViewDetail,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _PreviewCloseButton(onTap: onCancel),
        ),
      ],
    );
  }
}

class _PreviewCloseButton extends StatelessWidget {
  const _PreviewCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.gray800 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/ic_close.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.primary80 : AppColors.primary40,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewHeroImage extends StatelessWidget {
  const _PreviewHeroImage({
    required this.imageUrl,
    required this.onTap,
  });

  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 126,
              width: double.infinity,
              child: Image(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      placeholder: (context, url) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: const SizedBox(
            height: 126,
            width: double.infinity,
            child: ColoredBox(
              color: Color(0x80f2f1f1),
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => const SizedBox.shrink(),
    );
  }
}
