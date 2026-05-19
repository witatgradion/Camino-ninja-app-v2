import 'dart:io';

import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Triage-relevant context attached to bug reports.
///
/// Sent as a `client_context` multipart Part on
/// `POST /api/v1/bug_reports`. Always included (not opt-in) so
/// engineering can correlate reports against app/build/platform/OS
/// without asking the user to fill in version fields.
///
/// Fields are restricted to non-PII triage info — flavor and user
/// identity are deliberately omitted (backend infers flavor from
/// infra and user from the auth header).
class ClientContext extends Equatable {
  const ClientContext({
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
  });

  /// Schema version of the JSON payload. Bump on breaking changes
  /// to the wire format so the backend can branch.
  static const int schemaVersion = 1;

  static const String _logTag = 'ClientContext';

  final String appVersion;
  final String buildNumber;

  /// Platform identifier, lowercase: `'ios'`, `'android'`, …
  final String platform;

  /// Human-readable OS version, e.g. `'iOS 18.0'` or
  /// `'Android 14 (SDK 34)'`.
  final String osVersion;

  /// Device model identifier. iOS uses the hardware identifier
  /// (e.g. `iPhone17,2`) — not the marketing name — because that's
  /// what Apple uses for compatibility. Android uses
  /// `${manufacturer} ${model}` (e.g. `Google Pixel 8 Pro`).
  final String deviceModel;

  /// Builds a [ClientContext] from `package_info_plus` +
  /// `device_info_plus`. Returns `null` on platforms we don't
  /// support (web, desktop, …) — callers should treat `null` as
  /// "skip the client_context Part".
  ///
  /// Never throws: any failure during capture is logged and
  /// surfaced as `null` so the bug-report submit path is not
  /// blocked by diagnostic capture problems.
  static Future<ClientContext?> capture({
    PackageInfo? packageInfo,
    DeviceInfoPlugin? deviceInfo,
  }) async {
    try {
      final info = packageInfo ?? await PackageInfo.fromPlatform();
      final plugin = deviceInfo ?? DeviceInfoPlugin();

      if (Platform.isIOS) {
        final ios = await plugin.iosInfo;
        return ClientContext(
          appVersion: info.version,
          buildNumber: info.buildNumber,
          platform: 'ios',
          osVersion: 'iOS ${ios.systemVersion}',
          deviceModel: ios.utsname.machine,
        );
      }
      if (Platform.isAndroid) {
        final android = await plugin.androidInfo;
        final release = android.version.release;
        final sdk = android.version.sdkInt;
        return ClientContext(
          appVersion: info.version,
          buildNumber: info.buildNumber,
          platform: 'android',
          osVersion: 'Android $release (SDK $sdk)',
          deviceModel: '${android.manufacturer} ${android.model}',
        );
      }

      // Web / desktop are not shipping platforms for this app.
      // Return null so the caller skips the Part rather than
      // sending a half-populated payload. This is expected
      // behavior, not a failure — log at info level.
      AppLogger.i(
        'client_context capture skipped: unsupported platform '
        '${Platform.operatingSystem}',
        tag: _logTag,
      );
      return null;
    } catch (e, st) {
      AppLogger.w(
        'client_context capture failed: $e',
        tag: _logTag,
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'schema_version': schemaVersion,
        'app_version': appVersion,
        'build_number': buildNumber,
        'platform': platform,
        'os_version': osVersion,
        'device_model': deviceModel,
      };

  @override
  List<Object?> get props => [
        appVersion,
        buildNumber,
        platform,
        osVersion,
        deviceModel,
      ];
}
