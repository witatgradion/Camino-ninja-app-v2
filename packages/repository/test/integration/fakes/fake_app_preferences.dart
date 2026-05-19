import 'package:storage/storage.dart';

/// Stub [AppPreferences] for integration tests.
///
/// The real implementation talks to FlutterSecureStorage, which has no
/// pure-Dart implementation; subclassing and overriding only the
/// methods exercised by `StagePlanRepository.syncPlans()` lets us
/// instantiate the repo without pulling in platform channels.
class FakeAppPreferences extends AppPreferences {
  FakeAppPreferences({
    CredentialEntity? credential,
    this.deviceId = 'fake-device-id',
    this.deviceName = 'fake-device-name',
  }) : _credential = credential;

  CredentialEntity? _credential;
  String deviceId;
  String? deviceName;

  /// Set the credential post-construction (e.g. to simulate sign-in
  /// during a test).
  // ignore: use_setters_to_change_properties
  void setCredential(CredentialEntity? credential) {
    _credential = credential;
  }

  @override
  Future<CredentialEntity?> getUserCredential() async => _credential;

  @override
  Future<String> getDeviceId() async => deviceId;

  @override
  Future<String> getDeviceName() async => deviceName ?? 'fake-device-name';
}
