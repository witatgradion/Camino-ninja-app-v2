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

Future<bool?> showLoginRequiredBottomsheet(
  BuildContext context, {
  String? title,
  String? description,
}) {
  return showModalBottomSheet<bool?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    shape:
        const RoundedRectangleBorder(),
    backgroundColor: AppColors.barrierColor,
    builder: (context) => LoginRequiredBottomSheet(
      title: title,
      description: description,
    ),
  );
}

class LoginRequiredBottomSheet extends StatefulWidget {
  const LoginRequiredBottomSheet({
    super.key,
    this.title,
    this.description,
  });
  final String? title;
  final String? description;

  @override
  State<LoginRequiredBottomSheet> createState() =>
      _LoginRequiredBottomSheetState();
}

class _LoginRequiredBottomSheetState extends State<LoginRequiredBottomSheet> {
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
              color: context.isDarkMode ? AppColors.gray800 : Colors.white,
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
                    children: [
                      Text(
                        widget.title ??
                            AppLocalizations.of(context)
                                .pleaseRegisterToReviewYourStay,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.description ??
                            AppLocalizations.of(context)
                                .reviewRequiredLoginDescription,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      const SequentialLottie(
                        firstLottie: 'assets/lottie/login_start.json',
                        secondLottie: 'assets/lottie/login_loop.json',
                        width: 195,
                      ),
                      const SizedBox(height: 40),
                      SafeArea(
                        child: LoginButtonControls(
                          onSignInWithGoogle: _cubit.signInWithGoogle,
                          onSignInWithApple: _cubit.signInWithApple,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
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
