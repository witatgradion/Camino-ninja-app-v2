import 'dart:async';

import 'package:analytics_services/analytics_services.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/mixins/shake_detection_mixin.dart';
import 'package:camino_ninja_flutter/preferences/preferences_cubit.dart';
import 'package:camino_ninja_flutter/services/notification_service.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/sync_manager.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/favorite_button/cubit/favorite_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/favorite_button/flying_favorite.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_bottomsheet.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_type.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/shake_to_report_bottomsheet.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/auth_event_bus.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/deep_link_route_utils.dart';
import 'package:camino_ninja_flutter/utils/image_helper.dart';
import 'package:camino_ninja_flutter/utils/navigation_bar_helper.dart';
import 'package:camino_ninja_flutter/utils/router_locations.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_bottom_navigation_bar.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/required_upgrade_dialog.dart';
import 'package:camino_ninja_flutter/widgets/in_app_review/in_app_review_helper.dart';
import 'package:camino_ninja_flutter/widgets/notification_prompt_bottomsheet.dart';
import 'package:camino_ninja_flutter/widgets/stage_planner_announcement_bottomsheet.dart';
import 'package:camino_ninja_flutter/widgets/sync_indicator_pill.dart';
import 'package:camino_ninja_flutter/widgets/top_notification_overlay.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:remote_data/remote_data.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen>
    with ShakeDetectionMixin, TickerProviderStateMixin {
  static const int _planTabIndex = 2;
  final GlobalKey _bottomNavKey = GlobalKey();
  late PreferencesCubit _preferencesCubit;
  late TopNotificationController _topNotificationController;
  StreamSubscription<bool>? _shouldShowAppReviewSubscription;
  StreamSubscription<Offset?>? _flyingFavoriteSubscription;
  StreamSubscription<DateTime?>? _dataFetchCompletedSubscription;
  StreamSubscription<NotificationMessage>? _foregroundNotificationSubscription;
  StreamSubscription<AuthEvent>? _authEventSubscription;
  DateTime? _lastDataFetchCompletedAt;
  bool _pendingPlanTabReset = false;
  bool _isShowingShakeToReport = false;
  bool _initializing = true;

  // Push notification banner
  late AnimationController _pushBannerController;
  late Animation<Offset> _pushBannerSlide;
  NotificationMessage? _currentPushNotification;
  Timer? _pushBannerDismissTimer;

  @override
  void initState() {
    super.initState();
    _preferencesCubit = PreferencesCubit();
    _preferencesCubit.initNecessaryData().then((_) async {
      final doNotAskStagePlannerAnnouncement =
          _preferencesCubit.state.doNotAskStagePlannerAnnouncement;
      if (!doNotAskStagePlannerAnnouncement && mounted) {
        await showStagePlannerAnnouncementBottomsheet(
          context,
        );
      }

      if (mounted) {
        final hasSeenNotificationPrompt =
            _preferencesCubit.state.hasSeenNotificationPrompt;
        if (!hasSeenNotificationPrompt) {
          try {
            final notificationService = GetIt.instance<NotificationService>();
            final isAlreadyGranted =
                await notificationService.isPermissionGranted();
            if (!isAlreadyGranted && mounted) {
              final result = await showNotificationPromptBottomsheet(context);
              if (result != null) {
                await _preferencesCubit.setHasSeenNotificationPrompt();
              }
            } else {
              await notificationService.subscribeToTopic(
                NotificationType.announcements.wireValue,
              );
              await _preferencesCubit.setHasSeenNotificationPrompt();
            }
          } catch (_) {
            // NotificationService not registered
            // (staging/prod flavors)
          }
        }
      }

      final doNotAskShakeToReport =
          _preferencesCubit.state.doNotAskBugReportAgain;
      if (doNotAskShakeToReport) return;
      startShakeDetection();
    });
    _preferencesCubit.shouldUpgradeToUseFeature().then((shouldUpgrade) {
      if (shouldUpgrade && mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => const RequiredUpgradeDialog(),
        );
      }
    });
    _topNotificationController = TopNotificationController();
    _pushBannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pushBannerSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pushBannerController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _listenForForegroundNotifications();
    _listenForAuthEvents();
  }

  @override
  void dispose() {
    _shouldShowAppReviewSubscription?.cancel();
    _topNotificationController.dispose();
    _flyingFavoriteSubscription?.cancel();
    _dataFetchCompletedSubscription?.cancel();
    _foregroundNotificationSubscription?.cancel();
    _authEventSubscription?.cancel();
    _pushBannerDismissTimer?.cancel();
    _pushBannerController.dispose();
    stopShakeDetection();
    super.dispose();
  }

  @override
  Future<void> onShakeDetected() async {
    await _preferencesCubit.initNecessaryData();
    final doNotAskShakeToReport =
        _preferencesCubit.state.doNotAskBugReportAgain;
    if (doNotAskShakeToReport) return;

    if (_isShowingShakeToReport || !mounted) return;
    _isShowingShakeToReport = true;
    final shouldContinue =
        (await showShakeToReportBottomSheet(context)) ?? false;
    if (!shouldContinue || !mounted) {
      _isShowingShakeToReport = false;
      return;
    }
    await Future.delayed(const Duration(milliseconds: 350), () {});
    final capturedImage = await ImageHelper.captureScreenshot();
    if (!mounted) {
      _isShowingShakeToReport = false;
      return;
    }
    final result = await showReviewFeedbackBottomSheet(
      context,
      type: ReviewFeedbackType.bugReport,
      screenshot: capturedImage,
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
    _isShowingShakeToReport = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializing) {
      _initializing = false;
      _trackTab(widget.navigationShell.currentIndex);
      _shouldShowAppReviewSubscription =
          context.read<AppCubit>().shouldShowAppReviewStream.listen(
        (shouldShowAppReview) {
          if (shouldShowAppReview && mounted) {
            InAppReviewHelper.showInAppReviewDialog(context);
          }
        },
      );
      _flyingFavoriteSubscription =
          context.read<FavoritesCubit>().flyingFavoriteOffsetStream.listen(
        (offset) {
          if (offset != null && mounted) {
            _animateHeartToBottomNav(offset);
          }
        },
      );
      final appCubit = context.read<AppCubit>();
      unawaited(appCubit.refreshNotificationsBadge());
      // Initialize with current value to prevent reset on first subscription
      _lastDataFetchCompletedAt = appCubit.state.dataFetchCompletedAt;
      _dataFetchCompletedSubscription = appCubit.stream
          .map((s) => s.dataFetchCompletedAt)
          .distinct()
          .listen(_onDataFetchCompleted);
    }
  }

  Future<void> _updateAppIconBadge(int count) async {
    try {
      if (await AppBadgePlus.isSupported()) {
        await AppBadgePlus.updateBadge(count);
      }
    } catch (e) {
      AppLogger.e('Failed to update app icon badge', tag: 'RootScreen', error: e);
    }
  }

  void _onDataFetchCompleted(DateTime? completedAt) {
    if (completedAt == null || !mounted) return;
    if (_lastDataFetchCompletedAt == completedAt) return;
    _lastDataFetchCompletedAt = completedAt;

    final currentIndex = widget.navigationShell.currentIndex;
    if (currentIndex == _planTabIndex) {
      // User is on Plan tab - reset immediately
      widget.navigationShell.goBranch(_planTabIndex, initialLocation: true);
    } else {
      // User is on another tab - defer reset until they navigate to Plan tab
      _pendingPlanTabReset = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Capture the original bottom padding before Scaffold consumes it
    final originalBottomPadding = MediaQuery.of(context).viewPadding.bottom;
    NavigationBarHelper.setOriginalBottomPadding(originalBottomPadding);

    final deviceLocale = View.of(context).platformDispatcher.locale;

    final matchedLocale = AppLocalizations.supportedLocales.firstWhere(
      (locale) => locale.languageCode == deviceLocale.languageCode,
      orElse: () => const Locale('en'),
    );
    return BlocListener<AppCubit, AppState>(
      listenWhen: (prev, curr) =>
          prev.unreadNotificationsBadgeCount !=
          curr.unreadNotificationsBadgeCount,
      listener: (context, state) {
        _updateAppIconBadge(state.unreadNotificationsBadgeCount);
      },
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return Localizations.override(
            context: context,
            locale: (state.language == null)
                ? matchedLocale
                : Locale(state.language!),
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Stack(
                    children: [
                      widget.navigationShell,
                      SafeArea(
                        child: Container(
                          margin: const EdgeInsets.only(
                            top: CaminoNinjaAppBar.height,
                          ),
                          child: TopNotificationOverlay(
                            controller: _topNotificationController,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SyncIndicatorPill(
                              statusNotifier:
                                  GetIt.instance<SyncManager>().syncStatus,
                            ),
                          ),
                        ),
                      ),
                      // Push notification banner
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SlideTransition(
                          position: _pushBannerSlide,
                          child: _buildPushNotificationBanner(),
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: CustomBottomNavigationBar(
                    key: _bottomNavKey,
                    currentIndex: widget.navigationShell.currentIndex,
                    isDarkMode: context.isDarkMode,
                    shouldShowNewLabelOnPlanTab: true,
                    onTap: (index) {
                      if (index != widget.navigationShell.currentIndex) {
                        _trackTab(index);
                      }
                      // Check if navigating to Plan tab with pending reset
                      final shouldResetPlanTab =
                          index == _planTabIndex && _pendingPlanTabReset;
                      if (shouldResetPlanTab) {
                        _pendingPlanTabReset = false;
                      }
                      widget.navigationShell.goBranch(
                        index,
                        initialLocation:
                            index == widget.navigationShell.currentIndex ||
                                shouldResetPlanTab,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _listenForAuthEvents() {
    _authEventSubscription =
        GetIt.instance<AuthEventBus>().stream.listen(
      (event) {
        if (!mounted) return;
        switch (event) {
          case AuthEvent.sessionExpired:
            context.read<AppCubit>().notifyAuthChanged();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)
                      .sessionExpired,
                ),
                duration: const Duration(seconds: 4),
              ),
            );
        }
      },
    );
  }

  void _listenForForegroundNotifications() {
    if (!GetIt.instance.isRegistered<NotificationService>()) {
      return;
    }
    final notificationService = GetIt.instance<NotificationService>();
    _foregroundNotificationSubscription =
        notificationService.foregroundNotifications.listen(
      (message) {
        if (!mounted) return;
        context.read<AppCubit>().refreshNotificationsBadge();
        _showPushNotificationBanner(message);
      },
    );
  }

  void _showPushNotificationBanner(NotificationMessage message) {
    _pushBannerDismissTimer?.cancel();
    setState(() => _currentPushNotification = message);
    _pushBannerController.forward(from: 0);
    _pushBannerDismissTimer = Timer(
      const Duration(seconds: 5),
      _dismissPushBanner,
    );
  }

  void _dismissPushBanner() {
    _pushBannerDismissTimer?.cancel();
    _pushBannerController.reverse().then((_) {
      if (mounted) {
        setState(() => _currentPushNotification = null);
      }
    });
  }

  void _onPushBannerTap() {
    final message = _currentPushNotification;
    _dismissPushBanner();
    if (message == null) return;
    // New navigation logic for notifications with a route
    final route = message.route;
    final path = DeepLinkRouteUtils.parseLocation(route);
    if (path != null) {
      if (DeepLinkRouteUtils.matchesLocation(context, path)) {
        context.go(path);
      } else {
        context.go('/');
      }
      return;
    }
    if (message.type == NotificationType.announcements &&
        message.announcementId != null) {
      final id = int.tryParse(message.announcementId!);
      if (id != null) {
        context.go(RouterLocations.announcementDetail(id: id));
      } else {
        context.go('/');
      }
      return;
    }
    if (message.type == NotificationType.approvedReview &&
        message.reviewId != null &&
        (message.albergueId ?? 0) > 0) {
      context.go(
        RouterLocations.albergueDetails(
          albergueId: message.albergueId!,
          reviewId: message.reviewId,
        ),
      );
      return;
    }
    context.go('/');
  }

  Widget _buildPushNotificationBanner() {
    if (_currentPushNotification == null &&
        !_pushBannerController.isAnimating) {
      return const SizedBox.shrink();
    }
    final isDark = context.isDarkMode;
    return SafeArea(
      bottom: false,
      child: GestureDetector(
        onTap: _onPushBannerTap,
        onVerticalDragEnd: (details) {
          // Swipe up to dismiss
          if (details.velocity.pixelsPerSecond.dy < -100) {
            _dismissPushBanner();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primary80 : AppColors.primary40,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  size: 20,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentPushNotification?.title ?? '',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_currentPushNotification?.body.isNotEmpty ?? false) ...[
                      const SizedBox(height: 2),
                      Text(
                        _currentPushNotification!.body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _animateHeartToBottomNav(Offset startPosition) {
    final bottomNavBar =
        _bottomNavKey.currentContext?.findRenderObject() as RenderBox?;

    if (bottomNavBar == null) return;

    final bottomNavPosition = bottomNavBar.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;

    final endPosition = Offset(
      screenWidth * 0.833,
      bottomNavPosition.dy + 20,
    );

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => FlyingFavoriteWidget(
        startPosition: startPosition,
        endPosition: endPosition,
        onComplete: () {},
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 900), overlayEntry.remove);
  }

  void _trackTab(int currentIndex) {
    try {
      // Get the route configuration for the branch
      final branch = widget.navigationShell.route.branches[currentIndex];
      final tabRoute = branch.routes.first as GoRoute;
      final tabName = tabRoute.name ?? tabRoute.path;

      // Track tab switch
      GetIt.instance<IAnalyticsService>().trackScreen(
        screenName: tabName,
      );
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }
}
