import 'dart:async';

import 'package:analytics_services/analytics_services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/services/notification_service.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

/// Screen that lets users manage their notification
/// preferences: enable/disable notifications and toggle
/// individual topic subscriptions.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  AuthorizationStatus _permissionStatus =
      AuthorizationStatus.notDetermined;
  bool _isLoading = true;
  bool _isRequesting = false;
  bool _announcementsEnabled = true;
  bool _hasRequestedPermission = false;
  bool _albergueReviewEnabled = true;
  int _albergueReviewRequestId = 0;
  int _loadRequestId = 0;
  bool _didAnnouncementsSelfHeal = false;
  bool _didAlbergueSelfHeal = false;
  UserSettingsResponse? _userSettings;

  NotificationService? _notificationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initService();
  }

  void _initService() {
    if (GetIt.instance
        .isRegistered<NotificationService>()) {
      _notificationService =
          GetIt.instance<NotificationService>();
      _loadPermissionStatus();
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _loadPermissionStatus();
    }
  }

  Future<void> _loadPermissionStatus() async {
    final service = _notificationService;
    if (service == null) return;

    final isLoggedIn = context.read<AppCubit>().state.isLoggedIn;
    final requestId = ++_loadRequestId;

    final status = await service.getPermissionStatus();
    if (requestId != _loadRequestId) return;
    final prefs = GetIt.instance<AppPreferences>();
    final savedToggle =
        await prefs.getAnnouncementsSubscribed();
    if (requestId != _loadRequestId) return;
    final hasRequested =
        await prefs.getHasRequestedNotificationPermission();
    if (requestId != _loadRequestId) return;

    // If permission is granted, self-heal the announcements topic
    // to match the saved toggle in both directions — mirrors the
    // albergue branch below so a previously-failed unsubscribe
    // gets retried. Only runs once per screen lifetime so that
    // every resume does not re-issue sub/unsub calls.
    final isAuthorized =
        status == AuthorizationStatus.authorized ||
            status == AuthorizationStatus.provisional;
    if (isAuthorized && !_didAnnouncementsSelfHeal) {
      if (savedToggle) {
        await service.subscribeToTopic(
          NotificationType.announcements.wireValue,
        );
      } else {
        await service.unsubscribeFromTopic(
          NotificationType.announcements.wireValue,
        );
      }
      if (requestId != _loadRequestId) return;
      _didAnnouncementsSelfHeal = true;
    }

    // Initialize from current state so a reload failure preserves
    // last-known-good values instead of clobbering them with
    // defaults.
    var userSettings = _userSettings;
    var albergueReviewEnabled = _albergueReviewEnabled;
    // Skip the server settings fetch and the albergue self-heal
    // for guest users: getUserSettings/updateUserSettings require
    // auth, and we hide the toggle in that case anyway.
    if (isLoggedIn) {
      var settingsLoaded = false;
      try {
        final repository = GetIt.instance<Repository>();
        final fetched = await repository.getUserSettings();
        if (requestId != _loadRequestId) return;
        userSettings = fetched;
        albergueReviewEnabled =
            fetched.notifyReviewReminders ?? true;
        settingsLoaded = true;
      } catch (e, st) {
        AppLogger.e(
          'Failed to fetch user settings',
          tag: 'NotificationSettingsScreen',
          error: e,
          stackTrace: st,
        );
      }

      if (settingsLoaded && isAuthorized && !_didAlbergueSelfHeal) {
        if (albergueReviewEnabled) {
          await service.subscribeToTopic(
            NotificationType.albergueReviewRequest.wireValue,
          );
        } else {
          await service.unsubscribeFromTopic(
            NotificationType.albergueReviewRequest.wireValue,
          );
        }
        if (requestId != _loadRequestId) return;
        _didAlbergueSelfHeal = true;
      }
    }

    if (requestId != _loadRequestId) return;
    if (mounted) {
      setState(() {
        _permissionStatus = status;
        _announcementsEnabled = savedToggle;
        _hasRequestedPermission = hasRequested;
        _userSettings = userSettings;
        _albergueReviewEnabled = albergueReviewEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _enableNotifications() async {
    final service = _notificationService;
    if (service == null || _isRequesting) return;

    _isRequesting = true;
    try {
      final isLoggedIn =
          context.read<AppCubit>().state.isLoggedIn;
      final prefs = GetIt.instance<AppPreferences>();
      await prefs.setHasRequestedNotificationPermission(
        value: true,
      );
      await service.requestPermissionAndSubscribe(
        isLoggedIn: isLoggedIn,
      );
      // Regardless of the grant result, re-sync everything
      // (permission status, announcements pref, albergue review
      // state from the server) via the shared loader so the UI
      // matches reality. Manually setting _announcementsEnabled
      // here would clobber the server-driven albergue toggle.
      await _loadPermissionStatus();
    } finally {
      _isRequesting = false;
    }
  }

  Future<void> _toggleAnnouncements({
    required bool value,
  }) async {
    final service = _notificationService;
    if (service == null) return;

    final previous = _announcementsEnabled;
    setState(() => _announcementsEnabled = value);

    try {
      final topic = NotificationType.announcements.wireValue;
      if (value) {
        await service.subscribeToTopic(topic);
        GetIt.instance<IAnalyticsService>().track(
          NotificationTopicSubscribedEvent(topic: topic),
        );
      } else {
        await service.unsubscribeFromTopic(topic);
        GetIt.instance<IAnalyticsService>().track(
          NotificationTopicUnsubscribedEvent(topic: topic),
        );
      }
      final prefs = GetIt.instance<AppPreferences>();
      await prefs.setAnnouncementsSubscribed(value: value);
    } catch (_) {
      if (mounted) {
        setState(() => _announcementsEnabled = previous);
      }
    }
  }

  Future<void> _toggleAlbergueReview({required bool value}) async {
    final service = _notificationService;
    if (service == null) return;
    // Defensive guard: the UI hides this toggle for guest users,
    // but bail out here too in case it's reached through some
    // other code path — updateUserSettings would fail anyway.
    if (!context.read<AppCubit>().state.isLoggedIn) return;

    final requestId = ++_albergueReviewRequestId;
    final previous = _albergueReviewEnabled;
    setState(() => _albergueReviewEnabled = value);

    try {
      final topic = NotificationType.albergueReviewRequest.wireValue;
      final repository = GetIt.instance<Repository>();
      final next = _userSettings?.copyWith(
            notifyReviewReminders: value,
          ) ??
          UserSettingsResponse(notifyReviewReminders: value);

      final updated = await repository.updateUserSettings(next);
      final confirmed = updated.notifyReviewReminders ?? value;

      if (!mounted || requestId != _albergueReviewRequestId) return;
      setState(() {
        _userSettings = updated;
        _albergueReviewEnabled = confirmed;
      });

      unawaited(
        confirmed
            ? service.subscribeToTopic(topic)
            : service.unsubscribeFromTopic(topic),
      );

      GetIt.instance<IAnalyticsService>().track(
        confirmed
            ? NotificationTopicSubscribedEvent(topic: topic)
            : NotificationTopicUnsubscribedEvent(topic: topic),
      );
      GetIt.instance<IAnalyticsService>().track(
        ReviewReminderSettingChangedEvent(enabled: confirmed),
      );
    } catch (_) {
      if (!mounted || requestId != _albergueReviewRequestId) return;
      setState(() => _albergueReviewEnabled = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).failedToUpdateSettings,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: CaminoNinjaAppBar(
        title: l10n.notificationSettings,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _notificationService == null
              ? _ServiceUnavailableBody(
                  text: l10n.notificationsUnavailable,
                )
              : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // On Android 13+, status is `denied` even before the
    // system dialog is shown. Use our persisted flag to
    // distinguish "never asked" from "permanently denied".
    final neverAsked =
        _permissionStatus == AuthorizationStatus.notDetermined ||
            (_permissionStatus == AuthorizationStatus.denied &&
                !_hasRequestedPermission);

    if (neverAsked) {
      return _NotDeterminedBody(
        onEnable: _enableNotifications,
      );
    }

    if (_permissionStatus == AuthorizationStatus.denied) {
      return const _DeniedBody();
    }

    // authorized and provisional both show topic toggles
    return _AuthorizedBody(
      announcementsEnabled: _announcementsEnabled,
      onAnnouncementsChanged: (value) =>
          _toggleAnnouncements(value: value),
      albergueReviewEnabled: _albergueReviewEnabled,
      onAlbergueReviewChanged: (value) =>
          _toggleAlbergueReview(value: value),
      isLoggedIn: context.watch<AppCubit>().state.isLoggedIn,
    );
  }
}

/// Body shown when permission has never been requested.
class _NotDeterminedBody extends StatelessWidget {
  const _NotDeterminedBody({required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 64,
            color: isDark
                ? AppColors.primary80
                : AppColors.primary40,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.notificationSettingsDescription,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.notificationPromptDescription,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.neutral70
                  : AppColors.neutral40,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onEnable,
            icon: const Icon(Icons.notifications_active),
            label: Text(l10n.enableNotifications),
            style: FilledButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.primary80
                  : AppColors.primary40,
              foregroundColor: isDark
                  ? AppColors.primary20
                  : Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Body shown when permission is permanently denied.
class _DeniedBody extends StatelessWidget {
  const _DeniedBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.error20.withValues(alpha: 0.3)
                  : AppColors.error95,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AppColors.error40
                    : AppColors.error80,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  color: isDark
                      ? AppColors.error80
                      : AppColors.error40,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.notificationsDisabledTitle,
                        style:
                            textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.error80
                              : AppColors.error40,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n
                            .notificationsDisabledDescription,
                        style:
                            textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.neutral70
                              : AppColors.neutral40,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              AppSettings.openAppSettings(
                type: AppSettingsType.notification,
              );
            },
            icon: const Icon(Icons.settings),
            label: Text(l10n.openSettings),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.primary80
                  : AppColors.primary40,
              side: BorderSide(
                color: isDark
                    ? AppColors.primary80
                    : AppColors.primary40,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Body shown when permission is granted/provisional.
class _AuthorizedBody extends StatelessWidget {
  const _AuthorizedBody({
    required this.announcementsEnabled,
    required this.onAnnouncementsChanged,
    required this.albergueReviewEnabled,
    required this.onAlbergueReviewChanged,
    required this.isLoggedIn,
  });

  final bool announcementsEnabled;
  final ValueChanged<bool> onAnnouncementsChanged;
  final bool albergueReviewEnabled;
  final ValueChanged<bool> onAlbergueReviewChanged;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;
    final textTheme = Theme.of(context).textTheme;
    final activeTrackColor =
        isDark ? AppColors.primary80 : AppColors.primary40;
    final subtitleColor =
        isDark ? AppColors.neutral70 : AppColors.neutral40;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Text(
            l10n.notificationSettingsDescription,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          title: Text(
            l10n.announcementsTopic,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.announcementsTopicDescription,
            style: textTheme.bodyMedium?.copyWith(
              color: subtitleColor,
            ),
          ),
          value: announcementsEnabled,
          onChanged: onAnnouncementsChanged,
          activeTrackColor: activeTrackColor,
        ),
        if (isLoggedIn)
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            title: Text(
              l10n.albergueReviewRequestTopic,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.albergueReviewRequestTopicDescription,
              style: textTheme.bodyMedium?.copyWith(
                color: subtitleColor,
              ),
            ),
            value: albergueReviewEnabled,
            onChanged: onAlbergueReviewChanged,
            activeTrackColor: activeTrackColor,
          ),
      ],
    );
  }
}

/// Shown when NotificationService is not registered
/// (e.g., in staging builds).
class _ServiceUnavailableBody extends StatelessWidget {
  const _ServiceUnavailableBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
