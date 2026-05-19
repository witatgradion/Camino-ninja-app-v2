part of 'repository.dart';

/// Authentication operations for Repository
extension RepositoryAuth on Repository {
  /// Refresh user token
  Future<LoginResponse?> refreshToken({
    required String refreshToken,
  }) async {
    final refreshTokenResult =
        await _networkService.refreshToken(refreshToken: refreshToken);
    switch (refreshTokenResult) {
      case ApiSuccess(data: final response):
        if (response.user != null) {
          await _appPreferences
              .setUserCredential(Mappers.convertToCredential(response));
        }
        return response;
      case ApiFailure(message: final _):
        return null;
    }
  }

  /// Login user
  Future<LoginResponse> login({
    required String token,
    required String loginType,
    String? name,
  }) async {
    final loginResult = await _networkService.login(
      token: token,
      loginType: loginType,
      name: name,
    );
    switch (loginResult) {
      case ApiSuccess(data: final response):
        if (response.user != null) {
          await _appPreferences
              .setUserCredential(Mappers.convertToCredential(response));
        }
        return response;
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }

  /// Register FCM device token for push notifications. Call after login.
  /// Fails silently so login flow is not blocked.
  Future<void> registerDeviceToken(String fcmToken) async {
    if (fcmToken.isEmpty) return;
    try {
      final deviceId = await _appPreferences.getDeviceId();
      final platform = Platform.isIOS ? 'ios' : 'android';
      final result = await _networkService.registerDeviceToken(
        deviceId: deviceId,
        platform: platform,
        token: fcmToken,
      );
      switch (result) {
        case ApiSuccess():
          break;
        case ApiFailure():
          break;
      }
    } catch (_) {}
  }

  /// Get stored user credential
  Future<CredentialEntity?> getCredential() {
    return _appPreferences.getUserCredential();
  }

  /// Check if user proceeded as guest
  Future<bool> isProceedAsGuest() {
    return _appPreferences.isProceedAsGuest();
  }

  /// Set proceed as guest flag
  Future<void> setProceedAsGuest(bool value) {
    return _appPreferences.setProceedAsGuest(value);
  }

  /// Remove FCM device token. Fails silently.
  Future<void> removeDeviceToken(String fcmToken) async {
    if (fcmToken.isEmpty) return;
    try {
      final result =
          await _networkService.removeDeviceToken(token: fcmToken);
      switch (result) {
        case ApiSuccess():
        case ApiFailure():
          break;
      }
    } catch (_) {}
  }

  /// Logout user. Pass [fcmToken] to remove device token on server before clearing credentials.
  Future<void> logout({String? fcmToken}) async {
    if (fcmToken != null && fcmToken.isNotEmpty) {
      await removeDeviceToken(fcmToken);
    }
    await _appPreferences.setProceedAsGuest(false);
    return _appPreferences.logout();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final credential = await getCredential();
    return credential?.isLoggedIn ?? false;
  }
}

