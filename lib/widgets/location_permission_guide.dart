import 'dart:io';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';

class LocationPermissionGuide extends StatelessWidget {
  const LocationPermissionGuide({super.key, this.textAlign = TextAlign.center});
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final boldStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.bold);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          textAlign: textAlign,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: l10n.locationPermissionGuideHeaderPart1),
              TextSpan(
                text: l10n.locationPermissionGuideHeaderPart2Bold,
                style: boldStyle,
              ),
              TextSpan(text: l10n.locationPermissionGuideHeaderPart3),
            ],
          ),
        ),

        // Android-specific Instructions
        if (Platform.isAndroid) ...[
          RichText(
            textAlign: textAlign,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(text: l10n.locationPermissionGuideAndroidStep1Part1),
                TextSpan(
                  text: l10n.locationPermissionGuideAndroidStep1Part2BoldPath,
                  style: boldStyle,
                ),
                TextSpan(text: l10n.locationPermissionGuideAndroidStep1Part3),
                TextSpan(
                  text: l10n.locationPermissionGuideAndroidStep1Part4BoldAction,
                  style: boldStyle,
                ),
                TextSpan(text: l10n.locationPermissionGuideAndroidStep2Part1),
                TextSpan(
                  text:
                      l10n.locationPermissionGuideAndroidStep2Part2BoldAppName,
                  style: boldStyle,
                ),
                TextSpan(text: l10n.locationPermissionGuideAndroidStep2Part3),
              ],
            ),
          ),
        ],

        // iOS-specific Instructions
        if (Platform.isIOS) ...[
          RichText(
            textAlign: textAlign,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(text: l10n.locationPermissionGuideIosStep1Part1),
                TextSpan(
                  text: l10n.locationPermissionGuideIosStep1Part2BoldPath,
                  style: boldStyle,
                ),
                TextSpan(text: l10n.locationPermissionGuideIosStep1Part3),
                TextSpan(
                  text: l10n.locationPermissionGuideIosStep1Part4BoldAction,
                  style: boldStyle,
                ),
                TextSpan(text: l10n.locationPermissionGuideIosStep2Part1),
                TextSpan(
                  text: l10n.locationPermissionGuideIosStep2Part2BoldTerm,
                  style: boldStyle,
                ),
                TextSpan(text: l10n.locationPermissionGuideIosStep2Part3),
                TextSpan(text: l10n.locationPermissionGuideIosStep3Part1),
                TextSpan(
                  text: l10n.locationPermissionGuideIosStep3Part2BoldAction,
                  style: boldStyle,
                ),
                // This extra TextSpan handles sentence-ending grammar for
                // languages like Korean and Chinese, where it is defined.
                // For other languages, it will be an empty string.
                TextSpan(text: l10n.locationPermissionGuideIosStep3Part4),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
