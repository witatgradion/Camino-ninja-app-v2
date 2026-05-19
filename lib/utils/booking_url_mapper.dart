import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

Future<String> bookingUrl(String rawUrl, {String? clickId}) async {
  var url = rawUrl;
  final packageInfo = await PackageInfo.fromPlatform();
  final clickIdSuffix = clickId == null ? '' : '-$clickId';
  if (url.contains('booking.com') && url.contains('?')) {
    url = '${url.substring(0, url.indexOf('?') + 1)}'
        'aid=1447662&label=NinjaApp-'
        '${Platform.isIOS ? 'i' : 'a'}'
        '-'
        '${packageInfo.version.replaceAll('.', '_')}'
        '$clickIdSuffix';
  } else if (url.contains('booking.com')) {
    url = '$url'
        '?aid=1447662&label=NinjaApp-'
        '${Platform.isIOS ? 'i' : 'a'}'
        '-'
        '${packageInfo.version.replaceAll('.', '_')}'
        '$clickIdSuffix';
  }
  return url;
}
