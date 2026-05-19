import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storage/storage.dart';

class SeasonAndAdditionalInformation extends StatelessWidget {
  const SeasonAndAdditionalInformation({required this.albergue, super.key});
  final AlbergueEntity albergue;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        final deviceLocale = View.of(context).platformDispatcher.locale;

        final matchedLocale = AppLocalizations.supportedLocales.firstWhere(
          (locale) => locale.languageCode == deviceLocale.languageCode,
          orElse: () => const Locale('en'),
        );

        final currentLanguageCode =
            appState.language ?? matchedLocale.languageCode;
        var fallbackOpenSeason =
            albergue.getFallbackOpenSeason(currentLanguageCode);
        final openAllYear =
            albergue.operatingHours.firstOrNull?.opensAllYear ?? false;
        if (fallbackOpenSeason == null && openAllYear) {
          fallbackOpenSeason = AppLocalizations.of(context).januaryToDecember;
        }
        final additionalInformation =
            albergue.additionalInformation(currentLanguageCode);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (fallbackOpenSeason != null) ...[
              Text(
                '${AppLocalizations.of(context).openSeason}: '
                '$fallbackOpenSeason',
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
            ],
            if (additionalInformation != null &&
                additionalInformation.isNotEmpty) ...[
              Text(
                '${AppLocalizations.of(context).additionalInformation}: '
                '$additionalInformation',
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}
