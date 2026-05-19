import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/screens/login/cubit/login_cubit.dart';
import 'package:camino_ninja_flutter/screens/login/login_button_controls.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/sequential_lottie.dart';
import 'package:camino_ninja_flutter/widgets/top_notification_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

/// Shows the login reminder bottomsheet; mirrors the structure of
/// `showLoginRequiredBottomsheet` but with copy and visuals tailored to
/// the urgency banner on the Plan tab. Returns `true` if the user
/// successfully signed in, otherwise `null` (dismissed).
Future<bool?> showLoginReminderBottomsheet(BuildContext context) {
  return showModalBottomSheet<bool?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(),
    backgroundColor: AppColors.barrierColor,
    builder: (context) => const LoginReminderBottomSheet(),
  );
}

class LoginReminderBottomSheet extends StatefulWidget {
  const LoginReminderBottomSheet({super.key});

  @override
  State<LoginReminderBottomSheet> createState() =>
      _LoginReminderBottomSheetState();
}

class _LoginReminderBottomSheetState extends State<LoginReminderBottomSheet> {
  final _cubit = LoginCubit();
  late TopNotificationController _topNotificationController;
  StreamSubscription<LoginState>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _topNotificationController = TopNotificationController();
    _streamSubscription = _cubit.stream.listen(_handleState);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _topNotificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final l10n = AppLocalizations.of(context);
    final iconColor =
        isDarkMode ? AppColors.primary80 : AppColors.primary40;

    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              context.pop();
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.gray800 : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: SingleChildScrollView(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: SequentialLottie(
                            firstLottie: 'assets/lottie/login_start.json',
                            secondLottie: 'assets/lottie/login_loop.json',
                            width: 195,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.loginReminderSheetTitle,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.loginReminderSheetSubtitle,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _FeatureRow(
                          icon: Icons.cloud_outlined,
                          iconColor: iconColor,
                          title: l10n.loginReminderSheetCloudSyncTitle,
                          description:
                              l10n.loginReminderSheetCloudSyncDescription,
                        ),
                        const SizedBox(height: 16),
                        _FeatureRow(
                          icon: Icons.people_outline,
                          iconColor: iconColor,
                          title: l10n.loginReminderSheetCommunityTitle,
                          description:
                              l10n.loginReminderSheetCommunityDescription,
                        ),
                        const SizedBox(height: 16),
                        _FeatureRow(
                          icon: Icons.sentiment_satisfied_outlined,
                          iconColor: iconColor,
                          title: l10n.loginReminderSheetPeaceOfMindTitle,
                          description:
                              l10n.loginReminderSheetPeaceOfMindDescription,
                        ),
                        const SizedBox(height: 32),
                        SafeArea(
                          child: LoginButtonControls(
                            onSignInWithGoogle: _cubit.signInWithGoogle,
                            onSignInWithApple: _cubit.signInWithApple,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        StreamBuilder(
          stream: _cubit.stream,
          builder: (context, snapshot) {
            final isLoading = snapshot.data == LoginState.loading;
            if (isLoading) {
              return const ColoredBox(
                color: AppColors.barrierColor,
                child: Center(child: LoadingWidget()),
              );
            }
            return const SizedBox();
          },
        ),
        SafeArea(
          child: TopNotificationOverlay(
            controller: _topNotificationController,
          ),
        ),
      ],
    );
  }

  void _handleState(LoginState event) {
    if (event == LoginState.success) {
      context.read<AppCubit>().notifyAuthChanged();
      context.pop(true);
      return;
    }
    if (event == LoginState.error) {
      _topNotificationController.changeNotificationType(
        TopNotificationBarType.commonError,
      );
      return;
    }
  }
}

/// Single feature row: leading icon, bold title, and description below.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: iconColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
