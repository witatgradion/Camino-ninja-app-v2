# Flutter Expert Agent Memory

## Feedback
- [Atomic merge phase A: do not commit](feedback_atomic_merge_phase_a.md) — stop after staging + analyze; orchestrator commits later

## Project
- [LatLngBridge shim](lat_lng_bridge.md) — gmaps↔latlong2 conversions for dual-SDK boundary; drop when issues C3–C5 are done
- [Android Kotlin + dual maps SDKs](android_kotlin_dual_maps.md) — google_maps_flutter_android@2.19.8 + Kotlin 2.1.0 crashes; iOS unaffected

## flutter_quill v11.5.0 API
- `QuillEditor.basic()` uses `config` parameter (type `QuillEditorConfig`), NOT `configurations` (type `QuillEditorConfigurations`)
- `Document.fromJson()` takes the `ops` LIST directly (`content['ops']`), not the whole content map
- `FlutterQuillEmbeds.editorBuilders()` is the correct method from `flutter_quill_extensions` v11.0.0

## Key Widget Locations
- `CaminoNinjaAppBar`: `lib/widgets/camino_ninja_title.dart` (has `foregroundColor: Colors.transparent` default -- icons invisible without explicit color)
- `LoadingWidget`: `lib/widgets/loading_widget.dart`
- `AppColors`: `lib/utils/app_theme.dart` (includes `gray200`, primary tonal palette)
- `context.isDarkMode`: `lib/utils/context_ext.dart`

## Announcements Feature Files
- List screen: `lib/tabs/route/screens/announcements/announcements_screen.dart`
- Detail screen: `lib/tabs/route/screens/announcement_detail/announcement_detail_screen.dart`
- Banner widget: `lib/tabs/route/widgets/announcements_banner.dart`
- Cubits: `cubit/` subdirs under each screen directory
- Model: `packages/remote_data/lib/src/models/announcement/announcement_response.dart`

## Localization Keys Needed (Phase 3)
- `announcements`, `announcementDetail`, `errorLoadingAnnouncements`, `noAnnouncements`, `newsAndAnnouncements`

## FCM Push Notifications (dev flavor only)
- `NotificationService`: `lib/services/notification_service.dart`
- Registered in GetIt only when `router` param is passed to `setupDependencies()`
- `appRouter` is a top-level `GoRouter` in `lib/app/view/app.dart` (extracted from private field)
- Background handler: top-level `_firebaseMessagingBackgroundHandler` in `main_development.dart`
- Topic: `announcements_dev` (for dev flavor)
- Foreground display: SnackBar in `RootScreen._showNotificationSnackBar()`
- Notification data key: `message.data['announcement_id']`
- iOS entitlement: `aps-environment=development` in `Runner.entitlements`
- `firebase_messaging: ^16.1.0` (compatible with `firebase_core: ^4.3.0`; `^15.x` is NOT compatible)
- `setForegroundNotificationPresentationOptions` defaults all to `false` -- only set what differs

## Multi-Route Plan Display & Trail Persistence
- `StagePlanModel.isMultiRoute` / `uniqueRouteIds` getters on the model (both use `MultiRouteTrail.parseDescriptors`)
- `parseRouteColor(RouteEntity, {bool isDark})` and `parseRouteColorValue(RouteEntity, {bool isDark})` shared utilities in `lib/utils/hex_color.dart` — single source of truth for theme-aware route color resolution (light/dark legend color -> fallback legendColor -> default blue)
- `PlanDetailState.routeMap`: `Map<int, RouteEntity>?` fetched in `PlanDetailCubit._fetchRouteMap()` using `Future.wait`
- `PlanState.multiRouteMap`: `Map<int, Map<int, RouteEntity>>` resolved in `PlanCubit._resolveMultiRouteMaps()`
- Plan detail header: `_MultiRouteList` widget shows colored dots + route names vertically
- Plan list cards: `_MultiRouteBreadcrumb` widget shows abbreviated route names inline (`Frances > Primitivo`)
- `StageDetailCard.routeAccentColor`: optional color overrides header background for multi-route stage cards
- `RouteEntity` has three color fields: `lightLegendColor`, `darkLegendColor`, `legendColor` (all nullable hex `#RRGGBB`). Cubits that compute route colors store `isDark` as a mutable field set from the widget layer's `context.isDarkMode`
- **Trail serialization**: `MultiRouteTrail.toStorageString()` produces JSON `[{"r":1},{"r":3,"j":250}]`
- **Trail reconstruction**: `StagePlanRepository.buildTrailForPlan(plan)` rebuilds trail with sliced city segments from DB
- **Backward compat**: `MultiRouteTrail.parseDescriptors()` handles both JSON and old comma-separated `"1,3"` formats
- **`_parseColorValue`** moved to `StagePlanRepository` as static method (removed from `PlanDetailCubit`)
- `TrailSegmentDescriptor` class in `multi_route_trail.dart` for lightweight serialization/deserialization

## Journey Planner Feature
- Screen: `lib/tabs/plan/screens/journey_planner/journey_planner_screen.dart`
- Cubit: `lib/tabs/plan/screens/journey_planner/cubit/journey_planner_cubit.dart`
- State: `lib/tabs/plan/screens/journey_planner/cubit/journey_planner_state.dart` (part file)
- Uses `RoutePathFinder` from repository package (registered in GetIt as lazy singleton)
- Uses repository's `JourneyOption` model (in `packages/repository/lib/src/models/route_graph.dart`)
- `RoutePathFinder.findJourneyOptions()` does BFS path finding with city ordering validation
- `RoutePathFinder.buildGraph()` builds/caches `RouteGraph` from junction data
- `RouteGraph.findReachableRoutes(Set<int>)` BFS to find all reachable route IDs (fast, ~20-30 nodes)
- `JourneyPlannerCubit.buildTrailFromOption()` converts `JourneyOption` -> `MultiRouteTrail`
- `JourneyPlannerCubit.selectStartCity()` is async -- computes forward-reachable city sets: slices each shared route after the start-city index for `directlyReachableCityIds`, then BFS via `findReachableRoutes` with `startCityIndices` for via-junction routes
- Wired into `PlanType.journey` enum in `plan_type_choice_sheet.dart`
- Route: `/plan/journey-planner` in `app.dart`
- Navigation: `_goToJourneyPlan()` in `plan_screen.dart` follows same pattern as `_goToCustomTrailPlan()`
- **Phase 2 - Reachability**: `CityReachability` enum (direct/viaJunction/notReachable), `JourneyPlannerState.reachabilityOf(cityId)` method
- State fields: `cityRouteIds` (city->route ID set), `directlyReachableCityIds` (cities AFTER start on shared routes), `viaJunctionReachableCityIds` (cities on non-direct forward-reachable routes, approximation — may over-include)
- Reachability is position-aware: "Direct" badge only shown when destination comes AFTER start city in walking order. Prevents false-positive "Direct" followed by "No routes found"
- Destination search: `_DestinationCitySearchBody` (sorted by reachability), `_DestinationCityListItem` with `_ReachabilityBadge`
- Badge colors: Direct = `AppColors.primary40`, Via junction = `AppColors.tertiary50`, Not reachable = gray text
- Not-reachable cities: 0.45 opacity, no chevron, not tappable
- `_JunctionInfoRow`: uses "and" for 2+ junction names ("Via A and B")

## city_route_points schema (gotcha)
- Table columns are `(id, city_id, route_point_id)` ONLY -- NO `route_id` column
- To get `(cityId, routeId) -> routePointId`, must join with `route_points` on `route_point_id` and pull `route_points.route_id`
- `AppDatabase.getAllCityRoutePointMappings()` (in `app_database_cities.dart`) returns `Map<(int cityId, int routeId), int>` via that join
- Exposed on Repository via `getAllCityRoutePointMappings()` in `repository_queries.dart`
- Used by `RoutePathFinder.buildGraph()` to filter junctions where the two routes' touching points are > 1 km apart (impractical detour)

## Junction Detection / Route City Overview
- `JunctionService`: `packages/repository/lib/src/junction_service.dart` (shared service for junction detection)
- `JunctionPoint` model: `packages/repository/lib/src/models/junction_point.dart`
- Registered as lazy singleton in GetIt (`lib/di/dependency_injection.dart`), depends on `Repository`
- Must call `initialize()` before queries -- loads `cityRouteMap` from `city_routes` DB table
- `RouteCityOverviewCubit` delegates to `JunctionService` for city lists, route mapping, forward-cities checks
- `_buildSegment` in the cubit still does inline junction detection (builds `CityOverviewEntry` for every city, not just junctions)
- `getJunctionsForRoute` requires `allRoutes` param to resolve route IDs to `RouteEntity` objects
