import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/map/cubit/map_cubit.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/precise_disabled_container.dart';
import 'package:flutter/material.dart';

class LocationWarningWidget extends StatelessWidget {
  const LocationWarningWidget({
    required this.locationPermissionNotifier,
    required this.onReloadLocation,
    super.key,
  });
  final ValueNotifier<LocationPermissionStatus> locationPermissionNotifier;
  final VoidCallback onReloadLocation;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: locationPermissionNotifier,
      builder: (context, value, child) {
        if (value == LocationPermissionStatus.serviceDisabled) {
          return Text(
            AppLocalizations.of(context).noLocationServices,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          );
        }
        if (value == LocationPermissionStatus.preciseLocationDisabled) {
          return PreciseDisabledContainer(
            onReloadLocation: onReloadLocation,
          );
        }
        return const SizedBox();
      },
    );
  }
}
