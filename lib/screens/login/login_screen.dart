import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/screens/login/cubit/login_cubit.dart';
import 'package:camino_ninja_flutter/screens/login/login_button_controls.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/sequential_lottie.dart';
import 'package:camino_ninja_flutter/widgets/top_notification_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    return Scaffold(
      backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const SequentialLottie(
                    firstLottie: 'assets/lottie/login_start.json',
                    secondLottie: 'assets/lottie/login_loop.json',
                    width: 195,
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context).signInSignUp,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.isDarkMode
                                        ? AppColors.primary80
                                        : AppColors.primary40,
                                  ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).recommendLogin,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: (context.isDarkMode
                                            ? Colors.white
                                            : Colors.black)
                                        .withOpacity(0.7),
                                  ),
                          textAlign: TextAlign.left,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)
                                    .loginRequiredUpload,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: (context.isDarkMode
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(0.7),
                                    ),
                              ),
                              TextSpan(
                                text:
                                    ' ${AppLocalizations.of(context).photosAndReviews}.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: (context.isDarkMode
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        LoginButtonControls(
                          onSignInWithGoogle: _cubit.signInWithGoogle,
                          onSignInWithApple: _cubit.signInWithApple,
                        ),
                        const SizedBox(height: 32),
                        CustomOutlineButton(
                          text: AppLocalizations.of(context).proceedAsAGuest,
                          onTap: _cubit.proceedAsGuest,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/ic_heart.svg',
                              height: 24,
                              color: context.isDarkMode
                                  ? AppColors.primary80
                                  : AppColors.primary40,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).useWithoutLogin,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: (context.isDarkMode
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(0.7),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: SvgPicture.asset(
                      'assets/ic_close.svg',
                      color: context.isDarkMode
                          ? AppColors.primary80
                          : AppColors.primary40,
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
      ),
    );
  }

  void _handleState(LoginState event) {
    if (event == LoginState.success) {
      context.read<AppCubit>().notifyAuthChanged();
      context.pop(true);
      return;
    }
    if (event == LoginState.successWithGuest) {
      context.pop();
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
