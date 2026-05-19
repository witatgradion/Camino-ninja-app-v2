import 'dart:async';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/utils/deep_link_route_utils.dart';
import 'package:camino_ninja_flutter/utils/router_locations.dart';
import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

/// Data class representing a foreground notification message.
class NotificationMessage {
  const NotificationMessage({
    required this.title,
    required this.body,
    this.type = NotificationType.unknown,
    this.announcementId,
    this.albergueId,
    this.reviewId,
    this.route,
  });

  final String title;
  final String body;
  final NotificationType type;
  final String? announcementId;
  final int? albergueId;
  final int? reviewId;
  final String? route;
}

String? _fcmDataString(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value == null) return null;
  final s = value.toString().trim();
  if (s.isEmpty || s == 'null') return null;
  return s;
}

/// Service that manages Firebase Cloud Messaging for push
/// notifications. Handles permission requests, topic subscriptions,
/// and message routing for foreground, background, and terminated
/// app states.
class NotificationService {
  NotificationService({required GoRouter router}) : _router = router;

  final GoRouter _router;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final StreamController<NotificationMessage> _foregroundController =
      StreamController<NotificationMessage>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _backgroundTapSubscription;

  /// Stream of foreground notification messages for the UI to
  /// listen to and display in-app banners.
  Stream<NotificationMessage> get foregroundNotifications =>
      _foregroundController.stream;

  /// Initializes FCM listeners without requesting permissions.
  /// Call this on app start to handle foreground, background,
  /// and terminated-tap messages.
  Future<void> initListeners() async {
    await _configureForegroundPresentation();
    _setupForegroundListener();
    _setupBackgroundTapListener();
    _handleTerminatedTap();
    _logFcmToken();
  }

  Future<void> _logFcmToken() async {
    try {
      final token = await _messaging.getToken();
      AppLogger.d('FCM token: $token', tag: 'NotificationService');
    } catch (e, st) {
      AppLogger.e(
        'FCM token fetch failed',
        tag: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Requests notification permission and subscribes to topics.
  /// Call this only after the user consents via the
  /// pre-permission prompt.
  Future<bool> requestPermissionAndSubscribe({
    required bool isLoggedIn,
  }) async {
    _trackAnalyticsEvent(
      NotificationPermissionPromptedEvent(),
    );
    final granted = await _requestPermission();
    if (granted) {
      _trackAnalyticsEvent(
        NotificationPermissionGrantedEvent(),
      );
      await _subscribeToTopic(isLoggedIn: isLoggedIn);
    } else {
      _trackAnalyticsEvent(
        NotificationPermissionDeniedEvent(),
      );
    }
    return granted;
  }

  /// Checks current permission status without triggering
  /// the system dialog.
  Future<bool> isPermissionGranted() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus ==
            AuthorizationStatus.authorized ||
        settings.authorizationStatus ==
            AuthorizationStatus.provisional;
  }

  /// Returns the current authorization status without
  /// triggering the system dialog.
  Future<AuthorizationStatus> getPermissionStatus() async {
    final settings =
        await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// Subscribes to a Firebase Messaging topic.
  Future<void> subscribeToTopic(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) {
      AppLogger.w(
        'Ignoring subscribeToTopic with empty topic name',
        tag: 'NotificationService',
      );
      return;
    }
    try {
      await _messaging.subscribeToTopic(trimmed);
      AppLogger.d('Subscribed to $trimmed', tag: 'NotificationService');
    } catch (e, st) {
      AppLogger.e(
        'Subscribe to $trimmed failed',
        tag: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Unsubscribes from a Firebase Messaging topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) {
      AppLogger.w(
        'Ignoring unsubscribeFromTopic with empty topic name',
        tag: 'NotificationService',
      );
      return;
    }
    try {
      await _messaging.unsubscribeFromTopic(trimmed);
      AppLogger.d('Unsubscribed from $trimmed', tag: 'NotificationService');
    } catch (e, st) {
      AppLogger.e(
        'Unsubscribe from $trimmed failed',
        tag: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<bool> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission();
      final granted = settings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          settings.authorizationStatus ==
              AuthorizationStatus.provisional;
      AppLogger.d(
        'Permission status: ${settings.authorizationStatus}',
        tag: 'NotificationService',
      );
      return granted;
    } catch (e, st) {
      AppLogger.e(
        'Permission request failed',
        tag: 'NotificationService',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Future<void> _subscribeToTopic({required bool isLoggedIn}) async {
    // approved_review has no user-facing toggle today — always
    // subscribe. announcements + albergue_review_request must
    // respect the user's saved preference / server state so a
    // permission re-grant does not silently re-enable topics the
    // user has turned off.

    // approved_review: unconditional.
    await subscribeToTopic(NotificationType.approvedReview.wireValue);

    // announcements: respect AppPreferences. The pref defaults
    // to true when unset (first-run), so new users still get
    // announcements. If the prefs read fails, default to true so
    // a transient DI/storage error does not silently opt the user
    // out, and proceed to the review-request block below.
    bool announcementsEnabled;
    try {
      final prefs = GetIt.instance<AppPreferences>();
      announcementsEnabled = await prefs.getAnnouncementsSubscribed();
    } catch (e, st) {
      AppLogger.e(
        'AppPreferences read failed; defaulting announcements to on',
        tag: 'NotificationService',
        error: e,
        stackTrace: st,
      );
      announcementsEnabled = true;
    }
    if (announcementsEnabled) {
      await subscribeToTopic(
        NotificationType.announcements.wireValue,
      );
    } else {
      AppLogger.d(
        'Skipping announcements subscribe; user pref is off',
        tag: 'NotificationService',
      );
    }

    // albergue_review_request: respect server-side
    // notifyReviewReminders. Null is treated as true (first-run
    // default). If the repository call fails, fall back to
    // subscribing so users are not silently opted out of review
    // reminders by a transient network error.
    // Skip entirely for guests: getUserSettings requires auth and
    // would 403; the review-reminder topic should only be
    // subscribed after a successful login.
    if (isLoggedIn) {
      try {
        final repository = GetIt.instance<Repository>();
        final settings = await repository.getUserSettings();
        final reviewRemindersEnabled =
            settings.notifyReviewReminders ?? true;
        if (reviewRemindersEnabled) {
          await subscribeToTopic(
            NotificationType.albergueReviewRequest.wireValue,
          );
        } else {
          AppLogger.d(
            'Skipping albergue_review_request subscribe; '
            'notifyReviewReminders is off',
            tag: 'NotificationService',
          );
        }
      } catch (e, st) {
        AppLogger.e(
          'getUserSettings failed; falling back to subscribing '
          'albergue_review_request',
          tag: 'NotificationService',
          error: e,
          stackTrace: st,
        );
        await subscribeToTopic(
          NotificationType.albergueReviewRequest.wireValue,
        );
      }
    } else {
      AppLogger.d(
        'Skipping albergue_review_request subscribe; '
        'user is not logged in',
        tag: 'NotificationService',
      );
    }

    AppLogger.d(
      'Topic subscription pass complete',
      tag: 'NotificationService',
    );
  }

  Future<void> _configureForegroundPresentation() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
    );
  }

  void _setupForegroundListener() {
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        _logMessage('Foreground message', message);
        final parsed = _parseMessage(message);
        _trackAnalyticsEvent(
          PushNotificationReceivedEvent(
            type: parsed.type.wireValue,
            announcementId: parsed.announcementId ?? '',
          ),
        );
        if (parsed.type != NotificationType.unknown) {
          _foregroundController.add(parsed);
        }
      },
      onError: (Object error) {
        AppLogger.e(
          'Foreground stream error',
          tag: 'NotificationService',
          error: error,
        );
      },
    );
  }

  void _setupBackgroundTapListener() {
    _backgroundTapSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        _logMessage('Background tap', message);
        _trackNotificationTapped(message, 'background');
        _navigateFromTap(message);
      },
      onError: (Object error) {
        AppLogger.e(
          'Background tap stream error',
          tag: 'NotificationService',
          error: error,
        );
      },
    );
  }

  /// Handles the case where the app was opened from a terminated
  /// state by tapping a notification. Defers navigation until after
  /// two frames so the widget tree and GoRouter are ready.
  void _handleTerminatedTap() {
    _messaging.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        _logMessage('Terminated tap', initialMessage);
        _trackNotificationTapped(initialMessage, 'terminated');
        // Defer past first frame(s) so GoRouter / shell are ready.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateFromTap(initialMessage);
          });
        });
      }
    });
  }

  void _logMessage(String label, RemoteMessage message) {
    AppLogger.d(
      '$label: id=${message.messageId}, '
      'title=${message.notification?.title}, '
      'body=${message.notification?.body}, '
      'data=${message.data}',
      tag: 'NotificationService',
    );
  }

  NotificationMessage _parseMessage(RemoteMessage message) {
    final data = message.data;
    final title = message.notification?.title ?? 'New Announcement';
    final body = message.notification?.body ?? '';
    final type = NotificationType.fromString(_fcmDataString(data, 'type'));
    final announcementId = _fcmDataString(data, 'announcement_id');
    final albergueIdRaw = data['albergue_id'];
    final albergueId =
        albergueIdRaw != null ? int.tryParse(albergueIdRaw.toString()) : null;
    final reviewIdRaw = data['review_id'];
    final reviewId =
        reviewIdRaw != null ? int.tryParse(reviewIdRaw.toString()) : null;
    final route = _fcmDataString(data, 'route');

    return NotificationMessage(
      title: title,
      body: body,
      type: type,
      announcementId: announcementId,
      albergueId: albergueId,
      reviewId: reviewId,
      route: route,
    );
  }

  void _navigateFromTap(RemoteMessage message) {
    // New navigation logic for notifications with a route
    final path = DeepLinkRouteUtils.parseLocation(
      _fcmDataString(message.data, 'route'),
    );
    if (path != null) {
      if (DeepLinkRouteUtils.matchesRouter(_router, path)) {
        _router.go(path);
      } else {
        _router.go('/');
      }
      return;
    }

    // Alternative navigation logic for legacy notifications
    final parsed = _parseMessage(message);
    if (parsed.type == NotificationType.announcements &&
        parsed.announcementId != null) {
      final announcementIdRaw = parsed.announcementId;
      final announcementId = int.tryParse(announcementIdRaw!);
      if (announcementId != null) {
        _router.go(RouterLocations.announcementDetail(id: announcementId));
      } else {
        _router.go('/');
      }
    } else if (parsed.type == NotificationType.approvedReview &&
        parsed.reviewId != null &&
        parsed.albergueId != null) {
      _router.go(
        RouterLocations.albergueDetails(
          albergueId: parsed.albergueId!,
          reviewId: parsed.reviewId,
        ),
      );
    } else {
      _router.go('/');
    }
  }

  /// Emits a fake foreground notification for testing the banner UI.
  void sendTestNotification() {
    _foregroundController.add(
      const NotificationMessage(
        title: 'New trail update available!',
        body: 'Check out the latest news about Camino routes.',
        type: NotificationType.announcements,
        announcementId: '1',
      ),
    );
  }

  void _trackNotificationTapped(
    RemoteMessage message,
    String appState,
  ) {
    final data = message.data;
    final type = NotificationType.fromString(_fcmDataString(data, 'type'));
    final announcementId = _fcmDataString(data, 'announcement_id');
    _trackAnalyticsEvent(
      PushNotificationTappedEvent(
        type: type.wireValue,
        announcementId: announcementId ?? '',
        appState: appState,
      ),
    );
  }

  void _trackAnalyticsEvent(AnalyticsEvent event) {
    GetIt.instance<IAnalyticsService>().track(event);
  }

  /// Releases resources held by this service.
  void dispose() {
    _foregroundSubscription?.cancel();
    _backgroundTapSubscription?.cancel();
    _foregroundController.close();
  }
}
