part of 'user_inbox_cubit.dart';

enum UserInboxStatus { initial, loading, success, failure }

class UserInboxState extends Equatable {
  const UserInboxState({
    this.status = UserInboxStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.offset = 0,
    this.hasMore = true,
  });

  final UserInboxStatus status;
  final List<UserNotificationResponse> notifications;
  final int unreadCount;
  final int offset;
  final bool hasMore;

  UserInboxState copyWith({
    UserInboxStatus? status,
    List<UserNotificationResponse>? notifications,
    int? unreadCount,
    int? offset,
    bool? hasMore,
  }) {
    return UserInboxState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props =>
      [status, notifications, unreadCount, offset, hasMore];
}
