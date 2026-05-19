import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/preferences/preferences_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/sequential_lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

Future<bool?> showStagePlannerAnnouncementBottomsheet(BuildContext context) {
  return showModalBottomSheet<bool?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BlocProvider(
      create: (context) => PreferencesCubit(),
      child: const StagePlannerAnnouncementBottomsheet(),
    ),
  );
}

class StagePlannerAnnouncementBottomsheet extends StatelessWidget {
  const StagePlannerAnnouncementBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesCubit = context.read<PreferencesCubit>();

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final isDarkMode = context.isDarkMode;
        return SafeArea(
          bottom: false,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.gray800 : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: context.getBottomPadding(context, additionalPadding: 16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: SvgPicture.asset(
                        'assets/ic_close.svg',
                        color: isDarkMode
                            ? AppColors.primary80
                            : AppColors.primary40,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SequentialLottie(
                        firstLottie: 'assets/lottie/news_start.json',
                        secondLottie: 'assets/lottie/news_loop.json',
                        width: 100,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context).newStagePlanner,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).stagePlannerDescription,
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: AppLocalizations.of(context).remindMeLater,
                        onTap: () {
                          context.pop();
                        },
                      ),
                      const SizedBox(height: 24),
                      StreamBuilder(
                        stream: preferencesCubit
                            .doNotAskStagePlannerAnnouncementStream,
                        builder: (context, snapshot) {
                          final doNotAskStagePlannerAnnouncement =
                              snapshot.data ?? false;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox.adaptive(
                                value: doNotAskStagePlannerAnnouncement,
                                onChanged: (value) {
                                  preferencesCubit
                                      .setDoNotAskStagePlannerAnnouncement(
                                          value ?? false,);
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  preferencesCubit
                                      .setDoNotAskStagePlannerAnnouncement(
                                          !doNotAskStagePlannerAnnouncement,);
                                },
                                child: Text(
                                  AppLocalizations.of(context)
                                      .doNotShowThisAgain,
                                  style: context.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
