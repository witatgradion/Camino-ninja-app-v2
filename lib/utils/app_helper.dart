import 'dart:io';

import 'package:camino_ninja_flutter/app_env.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppHelper {
  static Future<bool> shouldUpgradeToUseFeature(
      int optionalUpgradeMinBuild,) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuildNumber = int.tryParse(packageInfo.buildNumber);
    if (currentBuildNumber == null) {
      return false;
    }
    return optionalUpgradeMinBuild > currentBuildNumber;
  }

  static Future<void> openStore() async {
    try {
      final appId = Platform.isAndroid ? AppEnv.appId : AppEnv.iosAppStoreId;
      final url = Uri.parse(
        Platform.isAndroid
            ? 'market://details?id=$appId'
            : 'https://apps.apple.com/app/id$appId',
      );
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.e('Error opening store', error: e);
    }
  }
}
