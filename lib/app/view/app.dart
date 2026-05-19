import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/di/dependency_injection.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/root_screen.dart';
import 'package:camino_ninja_flutter/screens/login/login_screen.dart';
import 'package:camino_ninja_flutter/services/router_observer.dart';
import 'package:camino_ninja_flutter/tabs/map/cubit/map_tab_cubit.dart';
import 'package:camino_ninja_flutter/tabs/map/map_screen.dart';
import 'package:camino_ninja_flutter/tabs/map/map_tab_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/more_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/contact/contact_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/debug_route_map/debug_route_map_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/how_to_ninja/how_to_ninja_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/legal_privacy/legal_privacy_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/notification_settings/notification_settings_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/offline_settings/offline_settings_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/preferences/preferences_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/route_city_overview/route_city_overview_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/route_junction_graph/route_junction_graph_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/update/update_screen.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/useful_links/useful_links_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/plan_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/add_edit_stage_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/journey_planner/journey_planner_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/plan_detail/plan_detail_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_export/qr_export_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_scanner/qr_scanner_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_albergue/stage_select_albergue_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_date/stage_select_date_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_end_city/stage_select_end_city_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_route/stage_select_route_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_start_city/stage_select_start_city_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/stage_map_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/trail_builder/trail_builder_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/route_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_nav_scope.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/gallery_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/announcement_detail/announcement_detail_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_details_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_full_map_route_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_full_map_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/distance/distance_route_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/distance/distance_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/elevation_full_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/elevation_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/favorite_button/cubit/favorite_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/full_map/full_map_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/my_reviews/my_reviews_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/notifications/notifications_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/saved_accommodations/saved_accommodations_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_destination/select_destination_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_language/select_language.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_route/select_route_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_starting_point/select_starting_point_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_theme/select_theme.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_unit/select_unit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final GlobalKey appGlobalKey = GlobalKey();

/// Root navigator key for GoRouter. Gallery routes use parentNavigatorKey so
/// pushes stack above modal bottom sheets (e.g. review / photo preview).
final GlobalKey<NavigatorState> appRootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'appRouterRoot');

int _queryInt(GoRouterState state, String key, {int fallback = 0}) =>
    int.tryParse(state.uri.queryParameters[key] ?? '') ?? fallback;

int? _queryIntOptional(GoRouterState state, String key) {
  final raw = state.uri.queryParameters[key];
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return int.tryParse(raw);
}

/// Positive route/city ids from query; missing or `0` -> null (resolved in DB).
int? _optionalNavId(GoRouterState state, String key) {
  final v = _queryIntOptional(state, key);
  if (v == null || v <= 0) return null;
  return v;
}

bool? _optionalBool(GoRouterState state, String key) {
  final raw = state.uri.queryParameters[key];
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return bool.tryParse(raw);
}

Widget _buildAlbergueDetailsScreen(
  GoRouterState state, {
  required AlbergueDetailsNavScope navScope,
  bool isStagePlannerFlow = false,
}) {
  final extra = state.extra;
  final reviewIdFromQuery = _optionalNavId(state, 'reviewId');
  final requestReviewFromQuery =
      _optionalBool(state, 'requestReview');
  if (extra is AlbergueDetailsScreenArguments) {
    return AlbergueDetailsScreen(
      arguments: AlbergueDetailsScreenArguments(
        albergueId: extra.albergueId,
        cityId: extra.cityId,
        routeId: extra.routeId,
        scrollToReviewId: extra.scrollToReviewId ?? reviewIdFromQuery,
        isStagePlannerFlow: extra.isStagePlannerFlow || isStagePlannerFlow,
        compareDate: extra.compareDate,
        isSelected: extra.isSelected,
        requestReview: requestReviewFromQuery ?? extra.requestReview,
        onSelectedAlbergueChanged: extra.onSelectedAlbergueChanged,
        navScope: navScope,
      ),
    );
  }
  final albergueId = _queryInt(state, 'albergueId');
  if (albergueId <= 0) {
    return const SizedBox.shrink();
  }
  return AlbergueDetailsScreen(
    arguments: AlbergueDetailsScreenArguments(
      albergueId: albergueId,
      cityId: _optionalNavId(state, 'cityId'),
      routeId: _optionalNavId(state, 'routeId'),
      scrollToReviewId: reviewIdFromQuery,
      requestReview: requestReviewFromQuery ?? false,
      isStagePlannerFlow: isStagePlannerFlow,
      navScope: navScope,
    ),
  );
}

Widget _buildFullMapScreen(GoRouterState state) {
  final albergueId = _queryInt(state, 'albergueId');
  if (albergueId <= 0) {
    return const SizedBox.shrink();
  }
  return FullMapScreen(
    albergueId: albergueId,
    cityId: _optionalNavId(state, 'cityId'),
    routeId: _optionalNavId(state, 'routeId'),
  );
}

Widget _buildGalleryScreen(GoRouterState state) {
  final extra = state.extra;
  if (extra is GalleryScreenArguments) {
    return GalleryScreen(
      arguments: extra,
    );
  }
  return const SizedBox.shrink();
}

/// Top-level GoRouter instance used by the app. Exposed so that
/// services (e.g. NotificationService) can navigate on notification
/// taps without requiring a BuildContext.
final GoRouter appRouter = GoRouter(
  navigatorKey: appRootNavigatorKey,
  initialLocation: '/',
  observers: [RouterObserver(analyticsUtils: GetIt.instance())],
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return RootScreen(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        // Tab 0: Route
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              name: 'route',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: RouteScreen(),
              ),
              routes: <RouteBase>[
                GoRoute(
                  path: 'select-route',
                  name: 'select-route',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SelectRouteScreen();
                  },
                ),
                GoRoute(
                  path: 'select-starting-point',
                  name: 'select-starting-point',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SelectStartingPointScreen();
                  },
                ),
                GoRoute(
                  path: 'select-destination',
                  name: 'select-destination',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SelectDestinationScreen();
                  },
                ),
                GoRoute(
                  path: 'city-details',
                  name: 'city-details',
                  builder: (BuildContext context, GoRouterState state) {
                    return CityDetailsScreen(
                      cityId: int.tryParse(
                            state.uri.queryParameters['cityId'] ?? '0',
                          ) ??
                          0,
                    );
                  },
                ),
                GoRoute(
                  path: 'albergue-details',
                  name: 'albergue-details',
                  builder: (BuildContext context, GoRouterState state) {
                    return _buildAlbergueDetailsScreen(
                      state,
                      navScope: AlbergueDetailsNavScope.routeTab,
                    );
                  },
                ),
                GoRoute(
                  path: 'full-map',
                  name: 'full-map',
                  builder: (BuildContext context, GoRouterState state) {
                    return _buildFullMapScreen(state);
                  },
                ),
                GoRoute(
                  path: 'elevation',
                  name: 'elevation',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is ElevationScreenArguments) {
                      return ElevationScreen(
                        arguments: extra,
                      );
                    }
                    final routeId = _queryInt(state, 'routeId');
                    final startingCityId =
                        _queryInt(state, 'startingCityId');
                    final destCityId = _queryInt(state, 'destCityId');
                    final l10n = AppLocalizations.of(context);
                    return ElevationScreen(
                      arguments: ElevationScreenArguments(
                        routeId: routeId,
                        startingCityId: startingCityId,
                        destCityId: destCityId,
                        title: l10n.elevation_342,
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'distance',
                  name: 'distance',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is DistanceScreenArguments) {
                      return DistanceScreen(
                        arguments: extra,
                      );
                    }
                    final routeId = _queryInt(state, 'routeId');
                    final destinationCityId =
                        _queryInt(state, 'destinationCityId');
                    return DistanceRouteScreen(
                      routeId: routeId,
                      destinationCityId: destinationCityId,
                    );
                  },
                ),
                GoRoute(
                  path: 'city-full-map',
                  name: 'city-full-map',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is CityFullMapScreenArguments) {
                      return CityFullMapScreen(
                        arguments: extra,
                      );
                    }
                    final routeId = _queryInt(state, 'routeId');
                    final cityId = _queryInt(state, 'cityId');
                    return CityFullMapRouteScreen(
                      routeId: routeId,
                      cityId: cityId,
                    );
                  },
                ),
                GoRoute(
                  path: 'announcements',
                  name: 'announcements',
                  builder: (BuildContext context, GoRouterState state) {
                    return const NotificationsScreen();
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: ':id',
                      name: 'announcement-detail',
                      builder: (
                        BuildContext context,
                        GoRouterState state,
                      ) {
                        final id = int.tryParse(
                              state.pathParameters['id'] ?? '0',
                            ) ??
                            0;
                        return AnnouncementDetailScreen(
                          announcementId: id,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: '/elevation-full-screen',
                  name: 'elevation-full-screen',
                  builder: (BuildContext context, GoRouterState state) {
                    return const ElevationFullScreen();
                  },
                ),
                GoRoute(
                  path: '/gallery',
                  name: 'gallery',
                  parentNavigatorKey: appRootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    return _buildGalleryScreen(state);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 1: Map
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/map',
              name: 'map',
              pageBuilder: (BuildContext context, GoRouterState state) {
                MapScreenArguments? arguments;
                MapTabMode? initialMode;
                final extra = state.extra;
                if (extra is MapTabPageArguments) {
                  arguments = extra.routeArguments;
                  initialMode = extra.initialMode;
                } else if (extra is MapScreenArguments) {
                  arguments = extra;
                  initialMode = MapTabMode.route;
                }
                return NoTransitionPage(
                  child: MapTabScreen(
                    arguments: arguments,
                    initialMode: initialMode,
                  ),
                );
              },
            ),
          ],
        ),
        // Tab 2: Plan
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/plan',
              name: 'plan',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PlanListScreen(),
              ),
              routes: <RouteBase>[
                GoRoute(
                  path: 'add-edit-stage',
                  name: 'add-edit-stage',
                  builder: (BuildContext context, GoRouterState state) {
                    if (state.extra is AddEditStageScreenArguments) {
                      return AddEditStageScreen(
                        arguments: state.extra! as AddEditStageScreenArguments,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                GoRoute(
                  name: 'stage-select-start-city',
                  path: 'stage-select-start-city',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is StageSelectStartCityScreenArguments) {
                      return StageSelectStartCityScreen(
                        arguments: extra,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                GoRoute(
                  name: 'stage-select-end-city',
                  path: 'stage-select-end-city',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is StageSelectEndCityScreenArguments) {
                      return StageSelectEndCityScreen(
                        arguments: extra,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                GoRoute(
                  name: 'stage-select-route',
                  path: 'stage-select-route',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is StageSelectRouteScreenArguments) {
                      return StageSelectRouteScreen(
                        arguments: extra,
                      );
                    }
                    return const StageSelectRouteScreen();
                  },
                ),
                GoRoute(
                  name: 'stage-select-date',
                  path: 'stage-select-date',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is StageSelectDateScreenArguments) {
                      return StageSelectDateScreen(
                        arguments: extra,
                      );
                    }
                    return const StageSelectDateScreen();
                  },
                ),
                GoRoute(
                  name: 'stage-select-albergue',
                  path: 'stage-select-albergue',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is StageSelectAlbergueScreenArguments) {
                      return StageSelectAlbergueScreen(
                        arguments: extra,
                      );
                    }
                    return const StageSelectRouteScreen();
                  },
                ),
                GoRoute(
                  name: 'plan-detail',
                  path: 'plan-detail',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is PlanDetailScreenArguments) {
                      return PlanDetailScreen(
                        arguments: extra,
                      );
                    }
                    final planId = _queryInt(state, 'planId');
                    if (planId <= 0) {
                      return const SizedBox.shrink();
                    }
                    final scrollRaw =
                        _queryIntOptional(state, 'scrollToStageId');
                    final scrollToStageId =
                        scrollRaw == null || scrollRaw == 0
                            ? null
                            : scrollRaw;
                    return PlanDetailScreen(
                      arguments: PlanDetailScreenArguments(
                        planId: planId,
                        scrollToStageId: scrollToStageId,
                      ),
                    );
                  },
                ),
                GoRoute(
                  name: 'stage-distance',
                  path: 'stage-distance',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is DistanceScreenArguments) {
                      return DistanceScreen(
                        arguments: extra,
                      );
                    }
                    final routeId = _queryInt(state, 'routeId');
                    final destinationCityId =
                        _queryInt(state, 'destinationCityId');
                    return DistanceRouteScreen(
                      routeId: routeId,
                      destinationCityId: destinationCityId,
                    );
                  },
                ),
                GoRoute(
                  name: 'stage-elevation',
                  path: 'stage-elevation',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is ElevationScreenArguments) {
                      return ElevationScreen(
                        arguments: extra,
                      );
                    }
                    final routeId = _queryInt(state, 'routeId');
                    final startingCityId =
                        _queryInt(state, 'startingCityId');
                    final destCityId = _queryInt(state, 'destCityId');
                    final l10n = AppLocalizations.of(context);
                    return ElevationScreen(
                      arguments: ElevationScreenArguments(
                        routeId: routeId,
                        startingCityId: startingCityId,
                        destCityId: destCityId,
                        title: l10n.stageElevation,
                      ),
                    );
                  },
                ),
                GoRoute(
                  name: 'stage-map',
                  path: 'stage-map',
                  builder: (BuildContext context, GoRouterState state) {
                    final data = state.extra;
                    if (data is StageMapScreenArguments) {
                      return StageMapScreen(arguments: data);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                GoRoute(
                  name: 'stage-albergue-details',
                  path: 'stage-albergue-details',
                  builder: (BuildContext context, GoRouterState state) {
                    return _buildAlbergueDetailsScreen(
                      state,
                      navScope: AlbergueDetailsNavScope.planTab,
                      isStagePlannerFlow: true,
                    );
                  },
                ),
                GoRoute(
                  name: 'plan-full-map',
                  path: 'full-map',
                  builder: (BuildContext context, GoRouterState state) {
                    return _buildFullMapScreen(state);
                  },
                ),
                GoRoute(
                  name: 'plan-gallery',
                  path: 'gallery',
                  parentNavigatorKey: appRootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    return _buildGalleryScreen(state);
                  },
                ),
                GoRoute(
                  name: 'qr-export',
                  path: 'qr-export',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is QrExportScreenArguments) {
                      return QrExportScreen(plans: extra.plans);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                GoRoute(
                  name: 'qr-scanner',
                  path: 'qr-scanner',
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra;
                    if (extra is QrScannerScreenArguments) {
                      return QrScannerScreen(plans: extra.plans);
                    }
                    return const QrScannerScreen();
                  },
                ),
                GoRoute(
                  path: 'trail-builder',
                  name: 'trail-builder',
                  builder: (
                    BuildContext context,
                    GoRouterState state,
                  ) {
                    final extra = state.extra;
                    if (extra is TrailBuilderScreenArguments) {
                      return TrailBuilderScreen(
                        arguments: extra,
                      );
                    }
                    return const TrailBuilderScreen();
                  },
                ),
                GoRoute(
                  path: 'journey-planner',
                  name: 'journey-planner',
                  builder: (
                    BuildContext context,
                    GoRouterState state,
                  ) {
                    final extra = state.extra;
                    if (extra
                        is JourneyPlannerScreenArguments) {
                      return JourneyPlannerScreen(
                        arguments: extra,
                      );
                    }
                    return const JourneyPlannerScreen();
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 4: More
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/more',
              name: 'more',
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage(
                child: MoreScreen(),
              ),
              routes: <RouteBase>[
                GoRoute(
                  path: 'offline-settings',
                  name: 'offline-settings',
                  builder: (BuildContext context, GoRouterState state) {
                    return const OfflineSettingsScreen();
                  },
                ),
                GoRoute(
                  path: 'updates',
                  name: 'updates',
                  builder: (BuildContext context, GoRouterState state) {
                    return const UpdatesScreen();
                  },
                ),
                GoRoute(
                  path: 'useful-links',
                  name: 'useful-links',
                  builder: (BuildContext context, GoRouterState state) {
                    return const UsefulLinksScreen();
                  },
                ),
                GoRoute(
                  path: 'contact',
                  name: 'contact',
                  builder: (BuildContext context, GoRouterState state) {
                    return const ContactScreen();
                  },
                ),
                GoRoute(
                  path: 'legal-privacy',
                  name: 'legal-privacy',
                  builder: (BuildContext context, GoRouterState state) {
                    return const LegalPrivacyScreen();
                  },
                ),
                GoRoute(
                  path: 'select-language',
                  name: 'select-language',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SelectLanguageScreen();
                  },
                ),
                GoRoute(
                  path: 'select-unit',
                  name: 'select-unit',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SelectUnitScreen();
                  },
                ),
                GoRoute(
                  path: 'select-theme',
                  name: 'select-theme',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SelectThemeScreen();
                  },
                ),
                GoRoute(
                  path: 'notification-settings',
                  name: 'notification-settings',
                  builder: (BuildContext context, GoRouterState state) {
                    return const NotificationSettingsScreen();
                  },
                ),
                GoRoute(
                  path: 'how-to-ninja',
                  name: 'how-to-ninja',
                  builder: (BuildContext context, GoRouterState state) {
                    return const HowToNinjaScreen();
                  },
                ),
                GoRoute(
                  path: 'preferences',
                  name: 'preferences',
                  builder: (BuildContext context, GoRouterState state) {
                    return const PreferencesScreen();
                  },
                ),
                GoRoute(
                  path: 'route-junction-graph',
                  name: 'route-junction-graph',
                  builder: (BuildContext context, GoRouterState state) {
                    return const RouteJunctionGraphScreen();
                  },
                ),
                GoRoute(
                  path: 'route-city-overview',
                  name: 'route-city-overview',
                  builder: (BuildContext context, GoRouterState state) {
                    return const RouteCityOverviewScreen();
                  },
                ),
                GoRoute(
                  path: 'debug-route-map',
                  name: 'debug-route-map',
                  builder: (BuildContext context, GoRouterState state) {
                    return const DebugRouteMapScreen();
                  },
                ),
                GoRoute(
                  path: 'saved-accommodations',
                  name: 'saved-accommodations',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SavedAccommodationsScreen();
                  },
                ),
                GoRoute(
                  path: 'my-reviews',
                  name: 'my-reviews',
                  builder: (BuildContext context, GoRouterState state) {
                    return const MyReviewsScreen();
                  },
                ),
                GoRoute(
                  path: 'albergue-details',
                  name: 'more-albergue-details',
                  builder: (BuildContext context, GoRouterState state) {
                    return _buildAlbergueDetailsScreen(
                      state,
                      navScope: AlbergueDetailsNavScope.moreTab,
                    );
                  },
                ),
                GoRoute(
                  path: 'full-map',
                  name: 'more-full-map',
                  builder: (BuildContext context, GoRouterState state) {
                    return _buildFullMapScreen(state);
                  },
                ),
                GoRoute(
                  path: 'gallery',
                  name: 'more-gallery',
                  parentNavigatorKey: appRootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    return _buildGalleryScreen(state);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppCubit()..onLoadCachedData()),
        BlocProvider(create: (context) => FavoritesCubit(getIt())),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          // Get the device locale as fallback
          final deviceLocale = View.of(context).platformDispatcher.locale;
          final matchedLocale = AppLocalizations.supportedLocales.firstWhere(
            (locale) => locale.languageCode == deviceLocale.languageCode,
            orElse: () => const Locale('en'),
          );

          // Use app state language or fallback to device locale
          final currentLocale = appState.language != null
              ? Locale(appState.language!)
              : matchedLocale;

          return RepaintBoundary(
            key: appGlobalKey,
            child: MaterialApp.router(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: currentLocale,
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              theme: lightTheme, // Default light theme
              darkTheme: darkTheme, // Dark theme
              themeMode: appState.theme == AppTheme.system
                  ? null
                  : (appState.theme == AppTheme.dark
                      ? ThemeMode.dark
                      : ThemeMode.light),
            ),
          );
        },
      ),
    );
  }
}
