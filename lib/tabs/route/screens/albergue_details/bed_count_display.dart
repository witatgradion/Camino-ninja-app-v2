import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:flutter/material.dart';

class BedCountDisplay extends StatelessWidget {
  const BedCountDisplay({
    super.key,
    this.placesInDormitory,
    this.numberOfDormitories,
  });

  final int? placesInDormitory;
  final int? numberOfDormitories;

  @override
  Widget build(BuildContext context) {
    if (placesInDormitory == null) {
      return const SizedBox.shrink();
    }

    // Case 1: Single place, no dormitories specified
    if (placesInDormitory == 1 && numberOfDormitories == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(AppLocalizations.of(context).bed),
      );
    }

    // Case 2: Multiple places, no dormitories specified
    if (placesInDormitory! > 1 && numberOfDormitories == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          AppLocalizations.of(context).beds(placesInDormitory!),
        ),
      );
    }

    // Case 3: Multiple places, single dormitory
    if (placesInDormitory! > 1 && numberOfDormitories == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          AppLocalizations.of(context).bedsDormitory(placesInDormitory!),
        ),
      );
    }

    // Case 4: Multiple places, multiple dormitories
    if (placesInDormitory! > 1 && numberOfDormitories! > 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          AppLocalizations.of(context).bedsDormitories(
            placesInDormitory!,
            numberOfDormitories!,
          ),
        ),
      );
    }

    // Default case if none of the conditions match
    return const SizedBox.shrink();
  }
}
