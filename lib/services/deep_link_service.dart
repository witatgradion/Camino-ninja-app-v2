import 'dart:async';

import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_screen.dart';
import 'package:chottu_link/chottu_link.dart';
import 'package:chottu_link/model/chottu_link_resolve_link.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final _alberguePathRegex =
    RegExp(r'^/albergue/(\d+)/route/(\d+)/routeId/(\d+)$');
final _planPathRegex = RegExp(r'^/plan/([A-Za-z0-9]{1,32})$');

class DeepLinkService {
  DeepLinkService({required GoRouter router}) : _router = router;

  final GoRouter _router;
  StreamSubscription<ResolvedLink>? _linkSubscription;
  bool _isReady = false;
  String? _pendingLink;

  final _planImportController = StreamController<String>.broadcast();
  Stream<String> get planImportRequests => _planImportController.stream;

  /// Cold: consumed in plan list initState via [consumePendingPlanImport].
  /// Warm (already subscribed, e.g. indexed stack): post-frame may emit on
  /// [planImportRequests] only if still pending and a listener exists.
  String? _pendingPlanShortCode;

  void markReady() {
    _isReady = true;
    if (_pendingLink != null) {
      _routeLink(_pendingLink!);
      _pendingLink = null;
    }
  }

  void initListeners() {
    _linkSubscription = ChottuLink.onLinkReceivedWithMeta.listen(
      (e) {
        _handleLink(e.shortLinkRaw ?? e.shortLink ?? '');
      },
      onError: (Object error) {
        AppLogger.e('Stream error', tag: 'DeepLinkService', error: error);
      },
    );
  }

  void _handleLink(String link) {
    AppLogger.d('Received link: $link', tag: 'DeepLinkService');

    if (!_isReady) {
      _pendingLink = link;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _routeLink(link);
    });
  }

  void _routeLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) {
      AppLogger.e('Invalid URI: $link', tag: 'DeepLinkService');
      return;
    }

    final path = uri.path;
    final params = uri.queryParameters;

    GetIt.instance<IAnalyticsService>().track(
      DeepLinkOpenedEvent(path: path, link: link),
    );

    final albergueMatch = _alberguePathRegex.firstMatch(path);
    final planMatch = _planPathRegex.firstMatch(path);

    if (albergueMatch != null) {
      final albergueId = int.tryParse(albergueMatch.group(1)!) ?? 0;
      final cityId = int.tryParse(albergueMatch.group(2)!) ?? 0;
      final routeId = int.tryParse(albergueMatch.group(3)!) ?? 0;
      _router.go(
        '/albergue-details',
        extra: AlbergueDetailsScreenArguments(
          albergueId: albergueId,
          cityId: cityId,
          routeId: routeId,
        ),
      );
    } else if (planMatch != null) {
      final shortCode = planMatch.group(1)!;
      _pendingPlanShortCode = shortCode;
      _router.go('/plan');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pendingPlanShortCode != shortCode) {
          return;
        }
        if (!_planImportController.hasListener) {
          return;
        }
        _planImportController.add(shortCode);
        _pendingPlanShortCode = null;
      });
    } else if (path == '/city' && params.containsKey('id')) {
      _router.go('/city-details?cityId=${params['id']}');
    } else if (path == '/announcement' && params.containsKey('id')) {
      _router.go('/announcements/${params['id']}');
    } else {
      AppLogger.d('Unhandled deep link path: $path', tag: 'DeepLinkService');
    }
  }

  String? consumePendingPlanImport() {
    final code = _pendingPlanShortCode;
    _pendingPlanShortCode = null;
    return code;
  }

  void dispose() {
    _linkSubscription?.cancel();
    _planImportController.close();
  }
}
