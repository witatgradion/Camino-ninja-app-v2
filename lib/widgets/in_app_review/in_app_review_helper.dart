import 'dart:io';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:camino_ninja_flutter/widgets/in_app_review/cubit/in_app_review_cubit.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lottie/lottie.dart';

class InAppReviewHelper {
  static Future<void> showInAppReviewDialog(
    BuildContext context, {
    bool showDoNotAskAgain = true,
  }) async {
    final cubit = InAppReviewCubit();
    await cubit.init();

    if (!context.mounted) return;

    final result = await showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StreamBuilder<InAppReviewState>(
        stream: cubit.stream,
        builder: (context, asyncSnapshot) {
          final state = asyncSnapshot.data ?? cubit.state;
          return AlertDialog(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTitle(context, state.showTimes),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  '${_getDescription(context, state.showTimes)}\n${_getContent(context, state.showTimes)}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      child: Lottie.asset('assets/lottie/thank_heart_big.json'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
            actions: [
              CustomButton(
                text: AppLocalizations.of(context).provideARating,
                onTap: () {
                  Navigator.pop(context, true);
                },
              ),
              const SizedBox(height: 8),
              CustomOutlineButton(
                text: AppLocalizations.of(context).maybeLater,
                onTap: () async {
                  await cubit.updateDestinationCheckPoints(DateTime.now());
                  if (!context.mounted) return;
                  Navigator.pop(context, false);
                },
              ),
              if (showDoNotAskAgain) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox.adaptive(
                      value: state.doNotAskAgain,
                      onChanged: (value) {
                        cubit.setDoNotAskAgain(value ?? false);
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        cubit.setDoNotAskAgain(!state.doNotAskAgain);
                      },
                      child: Text(
                        AppLocalizations.of(context).doNotAskMeAgain,
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await cubit.setShowTimes(cubit.state.showTimes + 1);
    await cubit.close();

    if (result is! bool || !result) return;

    final isInAppReviewAvailable = await InAppReview.instance.isAvailable();
    if (!isInAppReviewAvailable) return;
    return InAppReview.instance.requestReview();
  }

  static String _getStoreName(BuildContext context) {
    return Platform.isIOS ? 'App Store' : 'Play Store';
  }

  static String _getTitle(BuildContext context, int showTimes) {
    return [
      AppLocalizations.of(context).inAppReviewTitleV1,
      AppLocalizations.of(context).inAppReviewTitleV2,
      AppLocalizations.of(context).inAppReviewTitleV3,
      AppLocalizations.of(context).inAppReviewTitleV4,
    ][showTimes % 4];
  }

  static String _getContent(BuildContext context, int showTimes) {
    return [
      AppLocalizations.of(context).inAppReviewContentV1(
        _getStoreName(context),
      ),
      AppLocalizations.of(context).inAppReviewContentV2(
        _getStoreName(context),
      ),
      AppLocalizations.of(context).inAppReviewContentV3(
        _getStoreName(context),
      ),
      AppLocalizations.of(context).inAppReviewContentV4(
        _getStoreName(context),
      ),
    ][showTimes % 4];
  }

  static String _getDescription(BuildContext context, int showTimes) {
    return [
      AppLocalizations.of(context).inAppReviewDescriptionV1,
      AppLocalizations.of(context).inAppReviewDescriptionV2,
      AppLocalizations.of(context).inAppReviewDescriptionV3,
      AppLocalizations.of(context).inAppReviewDescriptionV4,
    ][showTimes % 4];
  }
}
