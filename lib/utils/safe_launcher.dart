import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launches the given URL if it can be launched.
Future<bool> launchUrlSafely(
  String url, {
  BuildContext? context,
  bool trackEvent = true,
  void Function({Object? error})? onError,
}) async {
  if (trackEvent) {
    GetIt.instance<IAnalyticsService>().track(
      LaunchUrlSafelyEvent(url: url),
    );
  }

  final uri = Uri.tryParse(url);

  try {
    if (uri != null && isLaunchableUrl(url)) {
      return launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  } catch (e) {
    onError?.call(error: e);
    AppLogger.e(
      'Error launching URL',
      tag: 'SafeLauncher',
      error: e,
    );
  }

  try {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  } catch (e) {
    AppLogger.e(
      'Error showing snack bar',
      tag: 'SafeLauncher',
      error: e,
    );
  }

  return false;
}

bool isLaunchableUrl(String? url) {
  // 1. Handle null or empty strings immediately.
  if (url == null || url.isEmpty) {
    AppLogger.d(
      'URL validation failed: Input is null or empty.',
      tag: 'SafeLauncher',
    );
    return false;
  }

  // 2. Trim whitespace from the URL.
  final trimmedUrl = url.trim();
  if (trimmedUrl.isEmpty) {
    AppLogger.d(
      'URL validation failed: Input is only whitespace.',
      tag: 'SafeLauncher',
    );
    return false;
  }

  // 3. Use the robust Uri.tryParse() to handle most validation.
  // This is the recommended approach as it's part of the core Dart library and
  // is well-tested to handle complex URLs, including international characters.
  final uri = Uri.tryParse(trimmedUrl);

  // 4. Check if parsing was successful and if a scheme is present.
  // A scheme is crucial for url_launcher to know how to handle the URL.
  if (uri == null || !uri.hasScheme) {
    AppLogger.d(
      'URL validation failed: Parsing failed or scheme is missing '
      "for '$trimmedUrl'.",
      tag: 'SafeLauncher',
    );
    // As a fallback for common cases where users omit the scheme for web URLs,
    // we can try parsing it again by prepending a default scheme.
    final prependedUrl = 'https://$trimmedUrl';
    final secondAttemptUri = Uri.tryParse(prependedUrl);
    if (secondAttemptUri == null ||
        !secondAttemptUri.hasScheme ||
        !secondAttemptUri.hasAuthority) {
      AppLogger.d(
        "URL validation fallback failed for '$prependedUrl'.",
        tag: 'SafeLauncher',
      );
      return false;
    }
    // If the second attempt is successful, the original URL
    // (with prepended scheme) is valid.
    return true;
  }

  // 5. Check for a minimum level of authority (host) for common schemes.
  // This helps filter out malformed URLs like "http://".
  if ((uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'ftp') &&
      uri.host.isEmpty) {
    AppLogger.d(
      'URL validation failed: HTTP/HTTPS/FTP scheme requires a host '
      "for '$trimmedUrl'.",
      tag: 'SafeLauncher',
    );
    return false;
  }

  // 6. For `tel` and `mailto`, the path is more important than the host.
  if ((uri.scheme == 'mailto' || uri.scheme == 'tel') && uri.path.isEmpty) {
    AppLogger.d(
      'URL validation failed: mailto/tel scheme requires a path '
      "for '$trimmedUrl'.",
      tag: 'SafeLauncher',
    );
    return false;
  }

  // If all checks pass, the URL is considered launchable.
  AppLogger.d(
    "URL validation successful for '$trimmedUrl'.",
    tag: 'SafeLauncher',
  );
  return true;
}
