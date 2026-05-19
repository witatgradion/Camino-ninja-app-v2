import 'package:core/core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseConfigDataSource {

  FirebaseConfigDataSource(Duration minimumFetchInterval) {
    _remoteConfig = FirebaseRemoteConfig.instance;
    _initialize(minimumFetchInterval);
  }
  late final FirebaseRemoteConfig _remoteConfig;

  Future<void> _initialize(Duration minimumFetchInterval) async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: minimumFetchInterval,
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      AppLogger.e(
        'Error initializing Firebase config',
        tag: 'FirebaseConfigDataSource',
        error: e,
      );
    }
  }

  int? getOptionalUpgradeMinBuild() {
    return _remoteConfig.getInt('optional_upgrade_min_build');
  }

  bool getCustomTrailEnabled() {
    return _remoteConfig.getBool('feature_custom_trail_enabled');
  }

  bool getJourneyPlannerEnabled() {
    return _remoteConfig.getBool('feature_journey_planner_enabled');
  }
}
