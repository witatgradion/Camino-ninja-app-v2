import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/utils/booking_click_tracker.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

class BookingComButton extends StatelessWidget {
  const BookingComButton({
    required this.albergue,
    required this.surface,
    required this.clickWidget,
    this.routeId,
    this.height = 36,
    super.key,
  });

  final AlbergueEntity albergue;
  final BookingEntrySurface surface;
  final BookingClickWidget clickWidget;
  final int? routeId;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF003895),
            borderRadius: BorderRadius.circular(100),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            splashColor: const Color(0xFF003895),
            highlightColor: const Color(0xFF003895),
            onTap: () => trackAndLaunchBookingClick(
              albergue: albergue,
              routeId: routeId,
              surface: surface,
              clickWidget: clickWidget,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 39),
              child: Image.asset(
                'assets/booking_com.png',
                width: 80,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
