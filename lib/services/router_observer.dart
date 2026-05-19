import 'package:analytics_services/analytics_services.dart';
import 'package:flutter/material.dart';

class RouterObserver extends NavigatorObserver {
  RouterObserver({required this.analyticsUtils});

  final IAnalyticsService analyticsUtils;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      analyticsUtils.trackScreen(
        screenName: route.settings.name!,
        parameters: route.settings.arguments as Map<String, dynamic>?,
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != null) {
      analyticsUtils.trackScreen(
        screenName: newRoute!.settings.name!,
        parameters: newRoute.settings.arguments as Map<String, dynamic>?,
      );
    }
  }
}
