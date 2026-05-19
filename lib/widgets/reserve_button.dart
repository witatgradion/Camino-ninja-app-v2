import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/booking_url_mapper.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReserveButton extends StatelessWidget {
  const ReserveButton({
    required this.reserveUrl,
    required this.source,
    super.key,
  });

  final String reserveUrl;
  final String source;

  @override
  Widget build(BuildContext context) {
    return CustomOutlineButton(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      text: AppLocalizations.of(context).reserve,
      onTap: () async {
        final resolvedUrl = await bookingUrl(reserveUrl);
        GetIt.instance<IAnalyticsService>().track(
          ReserveClickedEvent(
            url: resolvedUrl,
            source: source,
          ),
        );
        await launchUrlSafely(
          resolvedUrl,
          trackEvent: false,
        );
      },
    );
  }
}
