import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';

part 'user_inbox_state.dart';

const _pageSize = 20;

class UserInboxCubit extends Cubit<UserInboxState> with SafeEmitMixin {
  UserInboxCubit() : super(const UserInboxState());

  final Repository _repository = GetIt.instance<Repository>();

  bool _markingAll = false;
  bool _loadingMore = false;

  Future<void> load({bool refresh = false}) async {
    try {
      if (refresh) {
        safeEmit(
          state.copyWith(
            status: UserInboxStatus.loading,
            notifications: const [],
            offset: 0,
            hasMore: true,
          ),
        );
      } else {
        safeEmit(state.copyWith(status: UserInboxStatus.loading));
      }
      final page = await _repository.getUserNotifications(
        limit: _pageSize,
        offset: 0,
      );
      safeEmit(
        state.copyWith(
          status: UserInboxStatus.success,
          notifications: page.notifications,
          unreadCount: page.unreadCount,
          offset: page.notifications.length,
          hasMore: page.notifications.length >= _pageSize,
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Error loading user notifications',
        tag: 'UserInboxCubit',
        error: e,
      );
      safeEmit(state.copyWith(status: UserInboxStatus.failure));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status != UserInboxStatus.success) return;
    if (_loadingMore) return;
    _loadingMore = true;
    try {
      final page = await _repository.getUserNotifications(
        limit: _pageSize,
        offset: state.offset,
      );
      safeEmit(
        state.copyWith(
          notifications: [...state.notifications, ...page.notifications],
          unreadCount: page.unreadCount,
          offset: state.offset + page.notifications.length,
          hasMore: page.notifications.length >= _pageSize,
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Error loading more notifications',
        tag: 'UserInboxCubit',
        error: e,
      );
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> markAsRead(int id) async {
    final idx = state.notifications.indexWhere((n) => n.id == id);
    if (idx < 0) return;
    final n = state.notifications[idx];
    if (n.isRead) return;

    final previous = state.notifications;
    final previousUnread = state.unreadCount;
    final updated = List<UserNotificationResponse>.from(previous);
    updated[idx] = n.copyWith(isRead: true);
    final newUnread = (previousUnread > 0) ? previousUnread - 1 : 0;
    safeEmit(
      state.copyWith(
        notifications: updated,
        unreadCount: newUnread,
      ),
    );

    try {
      await _repository.markUserNotificationRead(id: id);
    } catch (e) {
      AppLogger.e(
        'markAsRead failed',
        tag: 'UserInboxCubit',
        error: e,
      );
      safeEmit(
        state.copyWith(
          notifications: previous,
          unreadCount: previousUnread,
        ),
      );
    }
  }

  Future<void> markAllAsRead() async {
    if (_markingAll) return;
    _markingAll = true;
    try {
      final unread =
          state.notifications.where((n) => !n.isRead).toList();
      if (unread.isEmpty) return;

      final previous = state.notifications;
      final previousUnread = state.unreadCount;
      final updated = state.notifications
          .map((n) => n.isRead ? n : n.copyWith(isRead: true))
          .toList();
      safeEmit(state.copyWith(notifications: updated, unreadCount: 0));

      try {
        await _repository.markAllUserNotificationsRead();
      } catch (e) {
        AppLogger.e(
          'markAllAsRead failed',
          tag: 'UserInboxCubit',
          error: e,
        );
        safeEmit(
          state.copyWith(
            notifications: previous,
            unreadCount: previousUnread,
          ),
        );
      }
    } finally {
      _markingAll = false;
    }
  }
}
