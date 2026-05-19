import 'dart:async';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/preferences/preferences_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

Future<bool?> showShakeToReportBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: context.isDarkMode ? AppColors.gray800 : Colors.white,
    builder: (context) => BlocProvider(
      create: (context) => PreferencesCubit(),
      child: const ShakeToReportBottomSheet(),
    ),
  );
}

class ShakeToReportBottomSheet extends StatelessWidget {
  const ShakeToReportBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final preferencesCubit = context.read<PreferencesCubit>();

    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: context.getBottomPadding(context, additionalPadding: 24),
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
                    color:
                        isDarkMode ? AppColors.primary80 : AppColors.primary40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).shakeNinja,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    AppLocalizations.of(context).toReportAProblemWithTheApp,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).bugReportContent,
                    style: context.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Lottie.asset(
                    'assets/lottie/issue_shake_loop.json',
                    height: 200,
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: AppLocalizations.of(context).reportAnIssue,
                    onTap: () {
                      context.pop(true);
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomOutlineButton(
                    text: AppLocalizations.of(context).notNow,
                    onTap: () {
                      context.pop(false);
                    },
                  ),
                  const SizedBox(height: 24),
                  StreamBuilder(
                    stream: preferencesCubit.doNotAskShakeToReportStream,
                    builder: (context, snapshot) {
                      final doNotAskShakeToReport = snapshot.data ?? false;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox.adaptive(
                            value: doNotAskShakeToReport,
                            onChanged: (value) {
                              preferencesCubit
                                  .setDoNotAskShakeToReport(value ?? false);
                            },
                          ),
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                preferencesCubit.setDoNotAskShakeToReport(
                                    !doNotAskShakeToReport,);
                              },
                              child: Text(
                                AppLocalizations.of(context).dontAskAgainAndDisable,
                                style: context.textTheme.bodyMedium,
                              ),
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
  }
}
