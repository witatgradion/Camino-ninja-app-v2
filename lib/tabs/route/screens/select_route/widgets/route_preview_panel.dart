// ---------------------------------------------------------------------------
// Route preview bottom panel
// ---------------------------------------------------------------------------
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:camino_ninja_flutter/widgets/elevation_gain_loss_widget.dart';
import 'package:camino_ninja_flutter/widgets/route_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:storage/storage.dart';

class RoutePreviewPanel extends StatelessWidget {
  const RoutePreviewPanel({
    required this.route,
    required this.unit,
    required this.isSelected,
    required this.onCancel,
    required this.onContinue,
    super.key,
  });

  final RouteDistanceElevation route;
  final UnitEnum unit;
  final bool isSelected;
  final VoidCallback onCancel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;

    final distance = UnitConverter.displayDistance(
      kilometers: route.distance,
      unit: unit,
    );
    final elevationGain = UnitConverter.displayElevation(
      meters: route.elevationGain.toDouble(),
      unit: unit,
    );
    final elevationLoss = UnitConverter.displayElevation(
      meters: route.elevationLoss.toDouble(),
      unit: unit,
    );

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.routeName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.primary80
                                  : AppColors.primary40,
                            ),
                      ),
                      if (route.routeSubName?.isNotEmpty ?? false)
                        RouteNameText(
                          routeSubName: route.routeSubName!,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.primary80
                                        : AppColors.primary40,
                                  ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: isDark ? AppColors.primary80 : AppColors.primary40,
                    size: 22,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/ic_walk.svg',
                  width: 24,
                  color: isDark ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  '${l10n.stageDistance.toLowerCase().capitalizeFirstLetter()}: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  distance,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/ic_mountain.svg',
                  width: 24,
                  color: isDark ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.elevationGainLossRouteScreen.capitalizeFirstLetter()}:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      ElevationGainLossWidget(
                        elevationGain: elevationGain,
                        elevationLoss: elevationLoss,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color:
                            isDark ? AppColors.primary80 : AppColors.primary40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                        color:
                            isDark ? AppColors.primary80 : AppColors.primary40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? AppColors.primary80 : AppColors.primary40,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.continueAction),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
