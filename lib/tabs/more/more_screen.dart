import 'dart:async';
import 'dart:io';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/di/dependency_injection.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/more/cubit/more_cubit.dart';
import 'package:camino_ninja_flutter/tabs/more/widgets/buy_me_a_coffee_banner.dart';
import 'package:camino_ninja_flutter/tabs/more/widgets/delete_account_dialog.dart';
import 'package:camino_ninja_flutter/tabs/more/widgets/version_text.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_nav_scope.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_bottomsheet.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_type.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/required_upgrade_dialog.dart';
import 'package:camino_ninja_flutter/widgets/in_app_review/in_app_review_helper.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/sequential_lottie.dart';
import 'package:camino_ninja_flutter/widgets/settings_list_item.dart';
import 'package:camino_ninja_flutter/widgets/top_notification_overlay.dart';
import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:repository/repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:storage/storage.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  /// Number of taps on the version text required to trigger the
  /// hidden DB export flow. The window resets if the user pauses
  /// for [_dbExportTapWindow] without tapping again.
  static const int _dbExportTapsRequired = 7;
  static const Duration _dbExportTapWindow = Duration(seconds: 3);

  late TopNotificationController _topNotificationController;
  final _cubit = MoreCubit();
  StreamSubscription<DateTime?>? _authChangedSubscription;
  DateTime? _lastAuthChangedAt;
  late final Future<PackageInfo> _packageInfoFuture;
  int _dbExportTapCount = 0;
  Timer? _dbExportTapResetTimer;
  bool _dbExportInProgress = false;

  @override
  void initState() {
    _cubit.init();
    _topNotificationController = TopNotificationController();
    _packageInfoFuture = PackageInfo.fromPlatform();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_authChangedSubscription == null) {
      final appCubit = context.read<AppCubit>();
      _lastAuthChangedAt = appCubit.state.authChangedAt;
      _authChangedSubscription = appCubit.stream
          .map((s) => s.authChangedAt)
          .distinct()
          .listen(_onAuthChanged);
    }
  }

  void _onAuthChanged(DateTime? changedAt) {
    if (changedAt == null || !mounted) return;
    if (_lastAuthChangedAt == changedAt) return;
    _lastAuthChangedAt = changedAt;
    _cubit.init();
  }

  @override
  void dispose() {
    _authChangedSubscription?.cancel();
    _dbExportTapResetTimer?.cancel();
    _topNotificationController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        context.isDarkMode ? const Color(0xFF48454E) : AppColors.gray200;
    final iconColor = context.isDarkMode ? Colors.white : Colors.black;
    final titleColor =
        context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
    final borderColor =
        context.isDarkMode ? AppColors.primary20 : AppColors.gray200;
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocListener<MoreCubit, MoreState>(
        listenWhen: (previous, current) =>
            previous.deleteAccountStatus != current.deleteAccountStatus,
        listener: (context, state) async {
          if (state.deleteAccountStatus == MoreDeleteAccountStatus.loading) {
            LoadingFullScreen.show(context);
            return;
          }
          LoadingFullScreen.hide();
          if (state.deleteAccountStatus == MoreDeleteAccountStatus.success) {
            await _signOut();
            await Future<void>.delayed(const Duration(milliseconds: 250));
            if (mounted) {
              _topNotificationController.changeNotificationType(
                TopNotificationBarType.deleteAccountSuccess,
              );
            }
            return;
          }
          if (state.deleteAccountStatus == MoreDeleteAccountStatus.failure) {
            _topNotificationController.changeNotificationType(
              TopNotificationBarType.commonError,
            );
            return;
          }
        },
        child: BlocBuilder<MoreCubit, MoreState>(
          builder: (context, state) {
            final isLoading = state.initStatus == MoreInitStatus.loading;
            final user = state.userEntity;
            final isLoggedIn = user != null;

            return Scaffold(
              appBar: CaminoNinjaAppBar.main(),
              body: Stack(
                children: [
                  ListView(
                    children: [
                      _buildHeader(
                        isLoading: isLoading,
                        isLoggedIn: isLoggedIn,
                        user: user,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SettingsListItem(
                          titleColor: titleColor,
                          title:
                              AppLocalizations.of(context).notificationSettings,
                          trailing: const Icon(
                            Icons.notifications_outlined,
                          ),
                          onClick: () {
                            context.push('/more/notification-settings');
                          },
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SettingsListItem(
                          titleColor: titleColor,
                          title:
                              AppLocalizations.of(context).savedAccommodations,
                          subtitle: AppLocalizations.of(context).savedStaysNote,
                          trailing: SvgPicture.asset(
                            'assets/ic_bookmark_filled.svg',
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          onClick: () {
                            context.push('/more/saved-accommodations');
                          },
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isLoggedIn) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SettingsListItem(
                            titleColor: titleColor,
                            title: AppLocalizations.of(context).myReviews,
                            subtitle: AppLocalizations.of(context)
                                .reviewsIHaveWritten,
                            trailing: SvgPicture.asset(
                              'assets/ic_star.svg',
                              colorFilter: ColorFilter.mode(
                                iconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            onClick: () {
                              context.push('/more/my-reviews');
                            },
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      SettingsListItem(
                        titleColor: titleColor,
                        title: AppLocalizations.of(context).preferences,
                        trailing: const Icon(Icons.settings),
                        onClick: () {
                          context.push('/more/preferences');
                        },
                      ),
                      Divider(
                        color: dividerColor,
                        height: 1,
                      ),
                      SettingsListItem(
                        titleColor: titleColor,
                        title: 'Play with Ninja',
                        trailing: SvgPicture.asset(
                          'assets/ic_how_to_ninja.svg',
                        ),
                        onClick: () {
                          context.go('/more/how-to-ninja');
                        },
                      ),
                      Divider(
                        color: dividerColor,
                        height: 1,
                      ),
                      SettingsListItem(
                        titleColor: titleColor,
                        title:
                            AppLocalizations.of(context).reportTechnicalIssue,
                        trailing: SvgPicture.asset(
                          'assets/ic_bug_report.svg',
                          colorFilter: ColorFilter.mode(
                            iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        onClick: _openReportTechnicalIssueBottomSheet,
                      ),
                      Divider(
                        color: dividerColor,
                        height: 1,
                      ),
                      SettingsListItem(
                        titleColor: titleColor,
                        title: AppLocalizations.of(context).reviewApp,
                        trailing: SvgPicture.asset(
                          'assets/ic_review_app.svg',
                          colorFilter: ColorFilter.mode(
                            iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        onClick: () {
                          InAppReviewHelper.showInAppReviewDialog(
                            context,
                            showDoNotAskAgain: false,
                          );
                        },
                      ),
                      Divider(
                        color: dividerColor,
                        height: 1,
                      ),
                      if (!isLoading && isLoggedIn) ...[
                        SettingsListItem(
                          titleColor: AppColors.error40,
                          title: AppLocalizations.of(context).deleteAction,
                          trailing: const Icon(Icons.delete_outline),
                          onClick: _showDeleteAccountDialog,
                        ),
                        Divider(
                          color: dividerColor,
                          height: 1,
                        ),
                      ],
                      if (appFlavor == 'development') ...[
                        SettingsListItem(
                          titleColor: titleColor,
                          title: AppLocalizations.of(context).clearCache,
                          trailing: const Icon(Icons.bug_report),
                          onClick: () async {
                            await context.read<AppCubit>().clearCache();
                          },
                        ),
                        Divider(color: dividerColor),
                        SettingsListItem(
                          titleColor: titleColor,
                          title: 'Route Junction Graph',
                          trailing: const Icon(Icons.account_tree),
                          onClick: () {
                            context.push('/more/route-junction-graph');
                          },
                        ),
                        Divider(color: dividerColor),
                        SettingsListItem(
                          titleColor: titleColor,
                          title: 'Route City Overview',
                          trailing: const Icon(Icons.list_alt),
                          onClick: () {
                            context.push('/more/route-city-overview');
                          },
                        ),
                        Divider(color: dividerColor),
                        SettingsListItem(
                          titleColor: titleColor,
                          title: 'Debug Route Map',
                          trailing: const Icon(Icons.map),
                          onClick: () {
                            context.push('/more/debug-route-map');
                          },
                        ),
                        Divider(color: dividerColor),
                      ],
                      if (Platform.isAndroid) ...[
                        const SizedBox(height: 16),
                        const BuyMeACoffeeBanner(),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 32,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 135,
                              child: CustomButton(
                                height: 32,
                                text: AppLocalizations.of(context).contact,
                                prefixIcon: (color) => SvgPicture.asset(
                                  'assets/ic_contact.svg',
                                  colorFilter: ColorFilter.mode(
                                    color,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onTap: () {
                                  context.push('/more/contact');
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 135,
                              child: CustomButton(
                                height: 32,
                                text: AppLocalizations.of(context).website,
                                prefixIcon: (color) => SvgPicture.asset(
                                  'assets/ic_website.svg',
                                  colorFilter: ColorFilter.mode(
                                    color,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onTap: () {
                                  launchUrlSafely(
                                    'https://caminoninja.com',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await launchUrlSafely(
                                'https://www.jakobsweg.de/ninja-legal/',
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context).legalAndPrivacy,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      VersionText(
                        packageInfoFuture: _packageInfoFuture,
                        // Easter-egg: only wire the secret-tap handler
                        // outside production so the hidden DB-export
                        // flow can never trigger for end users.
                        onSecretTap: AppConfig.flavor == Flavor.production
                            ? null
                            : _onVersionTextTap,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                  TopNotificationOverlay(
                    controller: _topNotificationController,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader({
    required bool isLoading,
    required bool isLoggedIn,
    UserEntity? user,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary20,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 50,
            spreadRadius: 5,
            offset: const Offset(0, 25),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  key: ValueKey('loader'),
                  child: LoadingWidget(),
                ),
              )
            : isLoggedIn
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      key: const ValueKey('authenticated'),
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Buen Camino,',
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user.displayName,
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: AppColors.primary80,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomOutlineButton(
                          text: AppLocalizations.of(context).signOut,
                          height: 31,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          textColor: AppColors.primary80,
                          borderColor: AppColors.primary80,
                          onTap: _signOut,
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      key: const ValueKey('unauthenticated'),
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SequentialLottie(
                              firstLottie: 'assets/lottie/login_start.json',
                              secondLottie: 'assets/lottie/login_loop.json',
                              width: 100,
                            ),
                          ],
                        ),
                        CustomButton(
                          text: AppLocalizations.of(context).signInSignUp,
                          onTap: _signIn,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => const ConfirmDeleteAccountDialog(),
    );
    if (result != null && result) {
      await _cubit.deleteAccount();
    }
  }

  Future<void> _openReportTechnicalIssueBottomSheet() async {
    final result = await showReviewFeedbackBottomSheet(
      context,
      type: ReviewFeedbackType.bugReportInMoreTab,
      galleryRoutePath: AlbergueDetailsNavScope.moreTab.galleryPath,
    );

    if (result != null) {
      if (result) {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.bugReportSuccess,
        );
      } else {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.bugReportError,
        );
      }
    }
  }

  Future<void> _signIn() async {
    final shouldUpgrade = await _cubit.shouldUpgradeToUseFeature();
    if (!mounted) return;
    if (shouldUpgrade) {
      return showDialog(
        context: context,
        builder: (context) => const RequiredUpgradeDialog(),
      );
    }
    final result = await context.push('/login');
    if (result is bool && result && mounted) {
      await _cubit.init();
    }
  }

  /// Counts taps in a sliding [_dbExportTapWindow] window. On the
  /// [_dbExportTapsRequired]th tap, kicks off the hidden DB export.
  /// Resets if the user pauses without reaching the threshold.
  void _onVersionTextTap(PackageInfo info) {
    if (_dbExportInProgress) return;
    _dbExportTapCount += 1;
    _dbExportTapResetTimer?.cancel();

    if (_dbExportTapCount >= _dbExportTapsRequired) {
      _dbExportTapCount = 0;
      // Fire-and-forget — the handler manages its own UI feedback.
      unawaited(_handleDbExportTap(info));
      return;
    }

    _dbExportTapResetTimer = Timer(_dbExportTapWindow, () {
      _dbExportTapCount = 0;
    });
  }

  Future<void> _handleDbExportTap(PackageInfo info) async {
    if (_dbExportInProgress) return;
    _dbExportInProgress = true;
    // Capture the messenger before the first await so we don't
    // depend on `context` after async gaps.
    final messenger = ScaffoldMessenger.of(context);
    try {
      // No localization for the toast text — this is an internal
      // beta utility, not a user-facing flow.
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Preparing DB export…'),
          duration: Duration(seconds: 2),
        ),
      );

      final archive = await DbExporter().exportAnonymizedArchive(
        appVersion: info.version,
        buildNumber: info.buildNumber,
        flavorName: AppConfig.flavor.name,
      );

      // Share sheet completion is unreliable across platforms;
      // we deliberately do not await the result.
      unawaited(
        SharePlus.instance.share(
          ShareParams(
            files: [XFile(archive.path)],
            subject: 'Camino Ninja DB export',
          ),
        ),
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('DB export shared'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'DB export failed',
        tag: 'MoreScreen',
        error: e,
        stackTrace: st,
      );
      // Generic toast — the full exception (including any path
      // strings that contain the iOS app UUID) goes to AppLogger,
      // not the UI. A screenshot of the toast must not leak
      // device-specific paths.
      messenger.showSnackBar(
        const SnackBar(
          content: Text('DB export failed. Check logs.'),
        ),
      );
    } finally {
      _dbExportInProgress = false;
    }
  }

  Future<void> _signOut() async {
    final analytics = GetIt.instance<IAnalyticsService>()
      ..track(SignOutEvent());
    await analytics.flush();
    analytics.setUserId();
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      AppLogger.e('Error getting FCM token: $e');
    }
    await getIt<Repository>().logout(fcmToken: fcmToken);
    if (mounted) {
      context.read<AppCubit>().notifyAuthChanged();
      await _cubit.init();
    }
  }
}
