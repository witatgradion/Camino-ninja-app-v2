import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Parses deep-link style payloads and checks them against a [GoRouter]
/// configuration (reuse for push notifications, universal links, etc.).
///
/// Widget code: use [matchesLocation] so callers only import this file, not
/// package:go_router (for lookup only). Services that hold a [GoRouter] use
/// [matchesRouter].
abstract final class DeepLinkRouteUtils {
  DeepLinkRouteUtils._();

  /// Normalizes [raw] from FCM/backend into a location string for
  /// [GoRouter.go], or null if unusable. Supports absolute paths, relative
  /// paths, and `http(s)` URLs (path + query only; host is ignored).
  static String? parseLocation(Object? raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    if (s.isEmpty || s == 'null') return null;
    try {
      if (s.startsWith('http://') || s.startsWith('https://')) {
        final u = Uri.parse(s);
        final path = u.path;
        final q = u.hasQuery ? '?${u.query}' : '';
        if (path.isEmpty) return null;
        return '${path.startsWith('/') ? path : '/$path'}$q';
      }
      return s.startsWith('/') ? s : '/$s';
    } catch (_) {
      return null;
    }
  }

  /// Whether [location] matches the [GoRouter] above [context]'s route table
  /// (same matching as [RouteConfiguration.findMatch]; redirects are not
  /// applied). Returns false if no router is found.
  static bool matchesLocation(BuildContext context, String location) {
    final router = GoRouter.maybeOf(context);
    if (router == null) return false;
    return matchesRouter(router, location);
  }

  /// Whether [location] matches [router]'s route table (same matching as
  /// [RouteConfiguration.findMatch]; redirects are not applied here).
  static bool matchesRouter(GoRouter router, String location) {
    try {
      final uri = Uri.parse(location);
      final match = router.configuration.findMatch(uri);
      return match.isNotEmpty && !match.isError;
    } catch (_) {
      return false;
    }
  }
}
