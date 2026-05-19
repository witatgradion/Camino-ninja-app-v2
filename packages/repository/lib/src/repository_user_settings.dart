part of 'repository.dart';

const _userSettingsTag = 'RepositoryUserSettings';

extension RepositoryUserSettings on Repository {
  Future<UserSettingsResponse> getUserSettings() async {
    final apiResult = await _networkService.getUserSettings();
    switch (apiResult) {
      case ApiSuccess(data: final settings):
        return settings;
      case ApiFailure(message: final message):
        AppLogger.w(
          'getUserSettings failed: $message',
          tag: _userSettingsTag,
        );
        throw Exception(message);
    }
  }

  Future<UserSettingsResponse> updateUserSettings(
    UserSettingsResponse settings,
  ) async {
    final apiResult = await _networkService.updateUserSettings(settings);
    switch (apiResult) {
      case ApiSuccess(data: final updated):
        return updated;
      case ApiFailure(message: final message):
        AppLogger.w(
          'updateUserSettings failed: $message',
          tag: _userSettingsTag,
        );
        throw Exception(message);
    }
  }
}
