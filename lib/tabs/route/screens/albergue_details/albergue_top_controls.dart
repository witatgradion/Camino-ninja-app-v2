import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/favorite_button/favorite_button.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:camino_ninja_flutter/widgets/booking_com_button.dart';
import 'package:camino_ninja_flutter/widgets/reserve_button.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

class AlbergueTopControls extends StatelessWidget {
  const AlbergueTopControls({
    required this.albergue,
    required this.cityId,
    required this.routeId,
    required this.surface,
    super.key,
  });
  final AlbergueEntity albergue;
  final int cityId;
  final int? routeId;
  final BookingEntrySurface surface;

  @override
  Widget build(BuildContext context) {
    final bookingComUrl = albergue.bookingComUrl;
    final reserveUrl = albergue.reserveUrl ?? '';
    final isBookingComUrlValid = isLaunchableUrl(bookingComUrl);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 6,
      ),
      color: context.isDarkMode ? AppColors.primary20 : AppColors.primary95,
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (isBookingComUrlValid) ...[
            BookingComButton(
              albergue: albergue,
              routeId: routeId,
              surface: surface,
              clickWidget: BookingClickWidget.albergueDetailsButton,
            ),
          ],
          if (reserveUrl.isNotEmpty) ...[
            ReserveButton(reserveUrl: reserveUrl, source: surface.value),
          ],
          if (cityId > 0 && (routeId ?? 0) > 0)
            FavoriteButton(
              albergue: albergue,
              cityId: cityId,
              routeId: routeId!,
              isLarge: true,
            ),
        ],
      ),
    );
  }
}
