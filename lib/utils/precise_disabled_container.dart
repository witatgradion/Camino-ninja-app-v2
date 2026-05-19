import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/location_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PreciseDisabledContainer extends StatelessWidget {
  const PreciseDisabledContainer({
    super.key,
    this.onReloadLocation,
  });
  final VoidCallback? onReloadLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning,
            color: AppColors.tertiary80,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '${AppLocalizations.of(context).preciseLocationWarning} ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context).clickHereToTurnItOn,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary80,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary80,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await LocationService.openAppSettings();
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
