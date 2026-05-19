import 'dart:io';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';

class LoginButtonControls extends StatelessWidget {
  const LoginButtonControls({
    required this.onSignInWithGoogle,
    required this.onSignInWithApple,
    super.key,
  });
  final VoidCallback onSignInWithGoogle;
  final VoidCallback onSignInWithApple;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPlatformLoginButton(
          context,
          text: AppLocalizations.of(context).continueWithGoogle,
          onTap: () {
            GetIt.instance<IAnalyticsService>().track(
              SignInClickedEvent(type: 'Google'),
            );
            onSignInWithGoogle();
          },
          icon: 'assets/ic_google.svg',
        ),
        if (Platform.isIOS) ...[
          const SizedBox(height: 16),
          _buildPlatformLoginButton(
            context,
            text: AppLocalizations.of(context).continueWithApple,
            onTap: () {
              GetIt.instance<IAnalyticsService>().track(
                SignInClickedEvent(type: 'Apple'),
              );
              onSignInWithApple();
            },
            icon: 'assets/ic_apple.svg',
          ),
        ],
      ],
    );
  }

  Widget _buildPlatformLoginButton(
    BuildContext context, {
    required String text,
    required VoidCallback onTap,
    required String icon,
  }) {
    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color:
                context.isDarkMode ? AppColors.primary80 : AppColors.primary40,
            borderRadius: BorderRadius.circular(100),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Stack(
                children: [
                  SvgPicture.asset(
                    icon,
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.isDarkMode
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
