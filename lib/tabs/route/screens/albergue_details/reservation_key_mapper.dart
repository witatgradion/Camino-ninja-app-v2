import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:flutter/material.dart';

class ReservationKeyMapper {
  ReservationKeyMapper(this.context);

  final BuildContext context;

  String? getKey(int originalKey) {
    return switch (originalKey) {
      240 => AppLocalizations.of(context).no,
      241 => AppLocalizations.of(context).dayBefore,
      242 => AppLocalizations.of(context).yes,
      243 => AppLocalizations.of(context).yesRequired,
      244 => AppLocalizations.of(context).recommended,
      245 => AppLocalizations.of(context).yes5DaysWebsite,
      246 => AppLocalizations.of(context).yesRecommended_246,
      247 => AppLocalizations.of(context).dependentMonth,
      248 => AppLocalizations.of(context).yesExceptSummer,
      249 => AppLocalizations.of(context)
          .yesRecommended_249, // Not in your list, but included for completeness
      250 => AppLocalizations.of(context).onlyLowSeason_250,
      251 => AppLocalizations.of(context).notSameDay,
      252 => AppLocalizations.of(context)
          .yesOneDayAdvance, // Not in your list, but included for completeness
      253 => AppLocalizations.of(context).yesSameDay,
      254 => AppLocalizations.of(context).onlyOffSeason,
      255 => AppLocalizations.of(context).yesRequiredWinter,
      256 => AppLocalizations.of(context)
          .yesExceptAugust, // Not in your list, but included for completeness
      257 => AppLocalizations.of(context).yesRequired_257,
      442 => AppLocalizations.of(context).xuntaReservation,
      575 => AppLocalizations.of(context).yesRecommendedWinter,
      605 => AppLocalizations.of(context).yesEmailPrepayment,
      632 => AppLocalizations.of(context)
          .yesRequiredFebMarch, // Not in your list, but included for completeness
      647 => AppLocalizations.of(context).noReservationCheck,
      666 => AppLocalizations.of(context).yesRecommendedChristmas,
      701 => AppLocalizations.of(context).yes24Hours,
      719 => AppLocalizations.of(context).yesOnline,
      _ => null
    };
  }
}
