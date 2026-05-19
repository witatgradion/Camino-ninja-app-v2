part of 'repository.dart';

const _userNotificationsTag = 'RepositoryUserNotifications';

extension RepositoryUserNotifications on Repository {
  Future<UserNotificationsPageResponse> getUserNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    final apiResult = await _networkService.getUserNotifications(
      limit: limit,
      offset: offset,
    );
    switch (apiResult) {
      case ApiSuccess(data: final page):
        return page;
      case ApiFailure(message: final message):
        throw Exception(message);
    }
  }

  Future<int> getUserNotificationsUnreadCount() async {
    final apiResult = await _networkService.getUserNotificationsUnreadCount();
    switch (apiResult) {
      case ApiSuccess(data: final r):
        return r.unreadCount;
      case ApiFailure(message: final message):
        throw Exception(message);
    }
  }

  Future<void> markUserNotificationRead({required int id}) async {
    final apiResult =
        await _networkService.markUserNotificationRead(id: id);
    switch (apiResult) {
      case ApiSuccess():
        return;
      case ApiFailure(message: final message):
        AppLogger.w(
          'markUserNotificationRead failed: $message',
          tag: _userNotificationsTag,
        );
        throw Exception(message);
    }
  }

  Future<void> markAllUserNotificationsRead() async {
    final apiResult = await _networkService.markAllUserNotificationsRead();
    switch (apiResult) {
      case ApiSuccess():
        return;
      case ApiFailure(message: final message):
        AppLogger.w(
          'markAllUserNotificationsRead failed: $message',
          tag: _userNotificationsTag,
        );
        throw Exception(message);
    }
  }

  Future<void> deleteUserNotification({required int id}) async {
    final apiResult = await _networkService.deleteUserNotification(id: id);
    switch (apiResult) {
      case ApiSuccess():
        return;
      case ApiFailure(message: final message):
        throw Exception(message);
    }
  }
}

