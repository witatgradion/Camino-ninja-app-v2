import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BookingComPrice extends StatelessWidget {
  const BookingComPrice({
    required this.price,
    this.updatedAt,
    this.onTap,
    super.key,
  });
  final double price;
  final DateTime? updatedAt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF273B7D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context).latestPriceOn}:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: onTap,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      height: 18,
                      context.isDarkMode
                          ? 'assets/logo_booking_com_dark.svg'
                          : 'assets/logo_booking_com_light.svg',
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '${price.floor()}€',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (updatedAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${AppLocalizations.of(context).lastUpdated}: ${updatedAt!.formatBookingUpdatedAt()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
