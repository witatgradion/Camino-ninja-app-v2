import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:flutter/material.dart';

/// Urgency banner shown on the Plan list and Plan detail screens when the
/// user is logged out and has a plan with at least the configured stage
/// threshold, nudging them to sign in so their data is backed up.
///
/// Visually a solid bright golden rectangle (matching the ninja accent),
/// intentionally identical in light and dark mode so the alert pops in
/// both themes. Tapping the body opens the login reminder bottomsheet;
/// the trailing X dismisses for the current session.
class LoginReminderBanner extends StatelessWidget {
  const LoginReminderBanner({
    required this.stageCount,
    required this.onTap,
    required this.onDismiss,
    super.key,
  });

  /// Stage count included in the banner copy for urgency.
  final int stageCount;

  /// Invoked when the user taps the banner body (opens the login
  /// reminder bottomsheet). The trailing dismiss (X) button does not
  /// trigger this callback.
  final VoidCallback onTap;

  /// Invoked when the user taps the trailing dismiss (X) button.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dismissLabel = l10n.loginReminderBannerDismissLabel;

    final bodyStyle = context.textTheme.bodySmall?.copyWith(
      color: AppColors.gray900,
      fontWeight: FontWeight.w500,
    );
    final boldStyle = bodyStyle?.copyWith(fontWeight: FontWeight.w700);

    return Container(
      color: AppColors.yellow300,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.loginReminderBannerCallToAction,
                        style: boldStyle,
                      ),
                      TextSpan(
                        text: l10n.loginReminderBannerCallToActionRest(
                          stageCount,
                        ),
                      ),
                    ],
                    style: bodyStyle,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Plain gesture-wrapped icon rather than IconButton so the
              // dismiss hit-area doesn't inflate the banner to Material's
              // 48-dp touch-target minimum. Outer GestureDetector swallows
              // taps that would otherwise bubble to the banner body.
              Semantics(
                label: dismissLabel,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDismiss,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.gray900,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
