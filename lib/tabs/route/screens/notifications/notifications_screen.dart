import 'dart:convert';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/announcements/cubit/announcements_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/announcements/widget/announcement_list_tile.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/notifications/cubit/user_inbox_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/notifications/widget/inbox_notification_list_tile.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/deep_link_route_utils.dart';
import 'package:camino_ninja_flutter/utils/router_locations.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_tabbar.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationsScreenTab _tab = NotificationsScreenTab.inbox;
  bool? _showInboxTab;

  @override
  void initState() {
    super.initState();
    _loadInboxAvailability();
  }

  Future<void> _loadInboxAvailability() async {
    final credential = await GetIt.instance<Repository>().getCredential();
    final loggedIn =
        credential?.accessToken != null && credential!.accessToken!.isNotEmpty;
    if (mounted) {
      setState(() => _showInboxTab = loggedIn);
    }
  }

  Map<String, dynamic>? _parsePayload(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  void _onInboxItemTap(
    BuildContext context,
    UserNotificationResponse n,
  ) {
    context.read<UserInboxCubit>().markAsRead(n.id);
    GetIt.instance<IAnalyticsService>().track(
      InboxNotificationTappedEvent(
        type: n.type.wireValue,
        notificationId: n.id.toString(),
      ),
    );
    final route = n.route;
    final path = DeepLinkRouteUtils.parseLocation(route);
    if (path != null) {
      if (DeepLinkRouteUtils.matchesLocation(context, path)) {
        context.go(path);
      } else {
        context.go('/');
      }
      return;
    }
    if (n.type == NotificationType.approvedReview) {
      final data = _parsePayload(n.data);
      final reviewId = (data?['review_id'] as num?)?.toInt();
      final albergueId = (data?['albergue_id'] as num?)?.toInt();
      if (reviewId != null &&
          reviewId > 0 &&
          albergueId != null &&
          albergueId > 0) {
        context.push(
          RouterLocations.albergueDetails(
            albergueId: albergueId,
            reviewId: reviewId,
          ),
        );
      } else {
        AppLogger.w(
          'approved_review notification missing valid ids: '
          'reviewId=$reviewId, albergueId=$albergueId',
          tag: 'NotificationsScreen',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showInboxTab == null) {
      return Scaffold(
        appBar: CaminoNinjaAppBar(
          title: AppLocalizations.of(context).announcements,
        ),
        body: const Center(child: LoadingWidget(size: 70)),
      );
    }

    final showInbox = _showInboxTab!;

    return MultiBlocProvider(
      providers: [
        if (showInbox)
          BlocProvider(
            create: (_) => UserInboxCubit()..load(),
          ),
        BlocProvider(
          create: (_) => AnnouncementsCubit()..loadAnnouncements(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: CaminoNinjaAppBar(
              title: showInbox
                  ? AppLocalizations.of(context).notifications
                  : AppLocalizations.of(context).announcements,
              actions: [
                _MarkAllAsReadAction(
                  showInbox: showInbox,
                  activeTab: _tab,
                ),
              ],
            ),
            body: showInbox
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BlocBuilder<UserInboxCubit, UserInboxState>(
                        buildWhen: (prev, curr) =>
                            prev.unreadCount != curr.unreadCount ||
                            prev.status != curr.status,
                        builder: (context, inboxState) {
                          return BlocBuilder<AnnouncementsCubit,
                              AnnouncementsState>(
                            buildWhen: (prev, curr) =>
                                prev.status != curr.status ||
                                prev.unreadCount != curr.unreadCount,
                            builder: (context, announcementsState) {
                              final inboxHasUnread = inboxState.unreadCount > 0;
                              final announcementsHasUnread =
                                  announcementsState.unreadCount > 0;

                              return CustomTabBar<NotificationsScreenTab>(
                                items: NotificationsScreenTab.values,
                                onTap: (tab) => setState(() => _tab = tab),
                                label: (e) => e.label(context),
                                isSelected: (e) => e == _tab,
                                prefixIcon: (tab) {
                                  final hasUnread = switch (tab) {
                                    NotificationsScreenTab.inbox =>
                                      inboxHasUnread,
                                    NotificationsScreenTab.announcements =>
                                      announcementsHasUnread,
                                  };
                                  return hasUnread
                                      ? const _TabUnreadDotIndicator()
                                      : null;
                                },
                              );
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: _tab == NotificationsScreenTab.inbox
                            ? _InboxTabBody(onItemTap: _onInboxItemTap)
                            : const _AnnouncementsTabBody(),
                      ),
                    ],
                  )
                : const _AnnouncementsTabBody(),
          );
        },
      ),
    );
  }
}

enum NotificationsScreenTab {
  inbox,
  announcements;

  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      NotificationsScreenTab.inbox => l10n.inbox,
      NotificationsScreenTab.announcements => l10n.announcements,
    };
  }
}

class _InboxTabBody extends StatelessWidget {
  const _InboxTabBody({required this.onItemTap});

  final void Function(BuildContext context, UserNotificationResponse n)
      onItemTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserInboxCubit, UserInboxState>(
      builder: (context, state) {
        switch (state.status) {
          case UserInboxStatus.initial:
          case UserInboxStatus.loading:
            return const Center(child: LoadingWidget(size: 70));
          case UserInboxStatus.failure:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).couldNotLoadNotifications,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          context.read<UserInboxCubit>().load(refresh: true),
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ),
            );
          case UserInboxStatus.success:
            if (state.notifications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    AppLocalizations.of(context).noNotificationsYet,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  context.read<UserInboxCubit>().loadMore();
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: context.isDarkMode
                      ? const Color(0xFF48454E)
                      : AppColors.gray200,
                ),
                itemBuilder: (context, index) {
                  final n = state.notifications[index];
                  return InboxNotificationListTile(
                    notification: n,
                    onTap: () => onItemTap(context, n),
                  );
                },
              ),
            );
        }
      },
    );
  }
}

class _AnnouncementsTabBody extends StatelessWidget {
  const _AnnouncementsTabBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
      builder: (context, state) {
        if (state.status == AnnouncementsStatus.loading ||
            state.status == AnnouncementsStatus.initial) {
          return const Center(child: LoadingWidget(size: 70));
        }
        if (state.status == AnnouncementsStatus.failure) {
          return Center(
            child: Text(
              AppLocalizations.of(context).errorLoadingAnnouncements,
            ),
          );
        }
        if (state.announcements.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context).noAnnouncements,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.announcements.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: context.isDarkMode
                ? const Color(0xFF48454E)
                : AppColors.gray200,
          ),
          itemBuilder: (context, index) {
            final announcement = state.announcements[index];
            final cubit = context.read<AnnouncementsCubit>();
            return AnnouncementListTile(
              announcement: announcement,
              isRead: cubit.isRead(announcement.id),
              onTap: () {
                cubit.markAsRead(announcement.id);
                context.push(
                  RouterLocations.announcementDetail(id: announcement.id),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MarkAllAsReadAction extends StatelessWidget {
  const _MarkAllAsReadAction({
    required this.showInbox,
    required this.activeTab,
  });

  final bool showInbox;
  final NotificationsScreenTab activeTab;

  @override
  Widget build(BuildContext context) {
    if (showInbox) {
      return _MarkAllAsReadWithInbox(activeTab: activeTab);
    }
    return BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
      buildWhen: (prev, curr) =>
          prev.unreadCount != curr.unreadCount ||
          prev.status != curr.status,
      builder: (context, state) {
        final cubit = context.read<AnnouncementsCubit>();
        final appCubit = context.read<AppCubit>();
        final hasUnread = state.unreadCount > 0;
        if (!hasUnread) return const SizedBox.shrink();
        return _MarkAllAsReadButton(
          onPressed: () async {
            await cubit.markAllAsRead();
            await appCubit.refreshNotificationsBadge();
          },
        );
      },
    );
  }
}

class _MarkAllAsReadWithInbox extends StatelessWidget {
  const _MarkAllAsReadWithInbox({required this.activeTab});

  final NotificationsScreenTab activeTab;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserInboxCubit, UserInboxState>(
      buildWhen: (prev, curr) =>
          prev.unreadCount != curr.unreadCount || prev.status != curr.status,
      builder: (context, inboxState) {
        return BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
          buildWhen: (prev, curr) =>
              prev.unreadCount != curr.unreadCount ||
              prev.status != curr.status,
          builder: (context, announcementsState) {
            final announcementsCubit = context.read<AnnouncementsCubit>();
            final inboxCubit = context.read<UserInboxCubit>();
            final appCubit = context.read<AppCubit>();
            final hasUnread = switch (activeTab) {
              NotificationsScreenTab.inbox => inboxState.unreadCount > 0,
              NotificationsScreenTab.announcements =>
                announcementsState.unreadCount > 0,
            };
            if (!hasUnread) return const SizedBox.shrink();
            return _MarkAllAsReadButton(
              onPressed: () async {
                switch (activeTab) {
                  case NotificationsScreenTab.inbox:
                    await inboxCubit.markAllAsRead();
                  case NotificationsScreenTab.announcements:
                    await announcementsCubit.markAllAsRead();
                }
                await appCubit.refreshNotificationsBadge();
              },
            );
          },
        );
      },
    );
  }
}

class _MarkAllAsReadButton extends StatelessWidget {
  const _MarkAllAsReadButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color =
        context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
    return IconButton(
      onPressed: () => _showMenu(context),
      icon: Icon(Icons.more_vert, color: color),
    );
  }

  void _showMenu(BuildContext context) {
    final button = context.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<String>(
          value: 'mark_all',
          child: Text(AppLocalizations.of(context).markAllAsRead),
        ),
      ],
    ).then((selected) {
      if (selected == 'mark_all') onPressed();
    });
  }
}

class _TabUnreadDotIndicator extends StatelessWidget {
  const _TabUnreadDotIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.red700,
        shape: BoxShape.circle,
      ),
    );
  }
}
