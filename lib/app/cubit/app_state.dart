part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.selectedRoute,
    this.loadingData = false,
    this.updatingData = false,
    this.loadRoutesError,
    this.selectedStartingPoint,
    this.selectedDestination,
    this.plannedRoute,
    this.routeStats,
    this.language,
    this.routePoints,
    this.selectedRoutePoints,
    this.altRoutePoints,
    this.loadingMessage,
    this.offlineAndNoData = false,
    this.loadingProgress = 0,
    this.loadingTotal = 1,
    this.dataUpdateAvailable = false,
    this.unit = UnitEnum.metric,
    this.theme = AppTheme.system,
    this.shouldShowAppReview = false,
    this.showNewLabelOnPlanTab = false,
    this.unreadNotificationsBadgeCount = 0,
    this.dataFetchCompletedAt,
    this.authChangedAt,
    this.isLoggedIn = false,
  });

  final bool shouldShowAppReview;
  /// Unread route-tab badge: announcement items not marked read locally
  /// plus server inbox unread count when the user is logged in.
  final int unreadNotificationsBadgeCount;
  final RouteEntity? selectedRoute;
  final bool loadingData;
  final bool updatingData;
  final String? loadRoutesError;
  final CityEntity? selectedStartingPoint;
  final CityEntity? selectedDestination;
  final List<Destination>? plannedRoute;
  final RouteDistanceElevation? routeStats;
  final String? language;
  final List<RoutePointEntity>? routePoints;
  final List<RoutePointEntity>? selectedRoutePoints;
  final List<AltRoutePointEntity>? altRoutePoints;
  final String? loadingMessage;
  final bool offlineAndNoData;
  final int loadingProgress;
  final int loadingTotal;
  final bool dataUpdateAvailable;
  final UnitEnum unit;
  final AppTheme theme;
  final bool showNewLabelOnPlanTab;
  final DateTime? dataFetchCompletedAt;
  final DateTime? authChangedAt;
  final bool isLoggedIn;

  AppState copyWith({
    RouteEntity? selectedRoute,
    List<RouteResponse>? routes,
    bool? loadingData,
    bool? updatingData,
    String? loadRoutesError,
    CityEntity? selectedStartingPoint,
    CityEntity? selectedDestination,
    List<Destination>? plannedRoute,
    RouteDistanceElevation? routeStats,
    String? language,
    List<RoutePointEntity>? routePoints,
    List<RoutePointEntity>? selectedRoutePoints,
    List<AltRoutePointEntity>? altRoutePoints,
    String? loadingMessage,
    bool? offlineAndNoData,
    int? loadingProgress,
    int? loadingTotal,
    bool? dataUpdateAvailable,
    bool? shouldShowAppReview,
    UnitEnum? unit,
    AppTheme? theme,
    bool? showNewLabelOnPlanTab,
    int? unreadNotificationsBadgeCount,
    DateTime? dataFetchCompletedAt,
    DateTime? authChangedAt,
    bool? isLoggedIn,
  }) {
    return AppState(
      selectedRoute: selectedRoute ?? this.selectedRoute,
      loadingData: loadingData ?? this.loadingData,
      updatingData: updatingData ?? this.updatingData,
      loadRoutesError: loadRoutesError ?? this.loadRoutesError,
      selectedStartingPoint: selectedStartingPoint,
      selectedDestination: selectedDestination,
      plannedRoute: plannedRoute,
      routeStats: routeStats,
      routePoints: routePoints,
      selectedRoutePoints: selectedRoutePoints,
      altRoutePoints: altRoutePoints,
      language: language ?? this.language,
      loadingMessage: loadingMessage,
      offlineAndNoData: offlineAndNoData ?? false,
      loadingTotal: loadingTotal ?? 1,
      loadingProgress: loadingProgress ?? 0,
      dataUpdateAvailable: dataUpdateAvailable ?? this.dataUpdateAvailable,
      unit: unit ?? this.unit,
      theme: theme ?? this.theme,
      shouldShowAppReview: shouldShowAppReview ?? this.shouldShowAppReview,
      showNewLabelOnPlanTab:
          showNewLabelOnPlanTab ?? this.showNewLabelOnPlanTab,
      unreadNotificationsBadgeCount:
          unreadNotificationsBadgeCount ?? this.unreadNotificationsBadgeCount,
      dataFetchCompletedAt: dataFetchCompletedAt,
      authChangedAt: authChangedAt,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  AppState copyWithNoNull({
    RouteEntity? selectedRoute,
    List<RouteResponse>? routes,
    bool? loadingData,
    bool? updatingData,
    String? loadRoutesError,
    CityEntity? selectedStartingPoint,
    CityEntity? selectedDestination,
    List<Destination>? plannedRoute,
    RouteDistanceElevation? routeStats,
    String? language,
    List<RoutePointEntity>? routePoints,
    List<RoutePointEntity>? selectedRoutePoints,
    List<AltRoutePointEntity>? altRoutePoints,
    String? loadingMessage,
    bool? offlineAndNoData,
    int? loadingProgress,
    int? loadingTotal,
    bool? dataUpdateAvailable,
    bool? shouldShowAppReview,
    bool? showNewLabelOnPlanTab,
    int? unreadNotificationsBadgeCount,
    UnitEnum? unit,
    AppTheme? theme,
    DateTime? dataFetchCompletedAt,
    DateTime? authChangedAt,
    bool? isLoggedIn,
  }) {
    return AppState(
      selectedRoute: selectedRoute ?? this.selectedRoute,
      loadingData: loadingData ?? this.loadingData,
      updatingData: updatingData ?? this.updatingData,
      loadRoutesError: loadRoutesError ?? this.loadRoutesError,
      selectedStartingPoint:
          selectedStartingPoint ?? this.selectedStartingPoint,
      selectedDestination: selectedDestination ?? this.selectedDestination,
      plannedRoute: plannedRoute ?? this.plannedRoute,
      routeStats: routeStats ?? this.routeStats,
      routePoints: routePoints ?? this.routePoints,
      altRoutePoints: altRoutePoints ?? this.altRoutePoints,
      selectedRoutePoints: selectedRoutePoints ?? this.selectedRoutePoints,
      language: language ?? this.language,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      offlineAndNoData: offlineAndNoData ?? false,
      loadingTotal: loadingTotal ?? 1,
      loadingProgress: loadingProgress ?? 0,
      dataUpdateAvailable: dataUpdateAvailable ?? this.dataUpdateAvailable,
      unit: unit ?? this.unit,
      theme: theme ?? this.theme,
      shouldShowAppReview: shouldShowAppReview ?? this.shouldShowAppReview,
      showNewLabelOnPlanTab:
          showNewLabelOnPlanTab ?? this.showNewLabelOnPlanTab,
      unreadNotificationsBadgeCount:
          unreadNotificationsBadgeCount ?? this.unreadNotificationsBadgeCount,
      dataFetchCompletedAt: dataFetchCompletedAt,
      authChangedAt: authChangedAt,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  List<Object?> get props => [
        selectedRoute,
        loadingData,
        loadRoutesError,
        selectedStartingPoint,
        selectedDestination,
        plannedRoute,
        routeStats,
        language,
        routePoints,
        altRoutePoints,
        selectedRoutePoints,
        loadingMessage,
        loadingProgress,
        loadingTotal,
        dataUpdateAvailable,
        unit,
        theme,
        shouldShowAppReview,
        showNewLabelOnPlanTab,
        unreadNotificationsBadgeCount,
        dataFetchCompletedAt,
        authChangedAt,
        isLoggedIn,
      ];
}
