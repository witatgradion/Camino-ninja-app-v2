part of 'plan_detail_cubit.dart';

enum PlanDetailInitStatus {
  initial,
  loading,
  success,
  failure,
}

enum PlanDetailActionStatus {
  initial,
  loading,
  success,
  failure,
}

class PlanDetailState extends Equatable {
  const PlanDetailState({
    this.plan,
    this.initStatus = PlanDetailInitStatus.initial,
    this.routePoints = const [],
    this.altRoutePoints = const [],
    this.scrollToIndex,
    this.shouldShowOverlayLoading = false,
    this.planActionStatus = PlanDetailActionStatus.initial,
    this.routeMap,
    this.trail,
    this.isLoggedIn = false,
  });

  final PlanDetailInitStatus initStatus;
  final StagePlanModel? plan;
  final List<RoutePointEntity> routePoints;
  final List<AltRoutePointEntity> altRoutePoints;
  final int? scrollToIndex;
  final bool shouldShowOverlayLoading;
  final PlanDetailActionStatus planActionStatus;
  final bool isLoggedIn;

  /// Whether the urgency login reminder banner should be shown on the Plan
  /// detail screen. True when the user is logged out AND the current plan
  /// has more than [kLoginReminderStageThreshold] stages.
  bool get shouldShowLoginReminder =>
      !isLoggedIn &&
      (plan?.stages.length ?? 0) > kLoginReminderStageThreshold;

  /// Maps routeId to RouteEntity for multi-route plans.
  /// Null when the plan uses only a single route.
  final Map<int, RouteEntity>? routeMap;

  /// Reconstructed trail for multi-route plans, used to pass
  /// to city selection screens so they show all trail cities.
  final MultiRouteTrail? trail;

  /// Whether this plan spans multiple routes.
  bool get isMultiRoute => routeMap != null && routeMap!.length > 1;

  PlanDetailState copyWith({
    StagePlanModel? plan,
    PlanDetailInitStatus? initStatus,
    List<RoutePointEntity>? routePoints,
    List<AltRoutePointEntity>? altRoutePoints,
    int? scrollToIndex,
    bool? shouldShowOverlayLoading,
    PlanDetailActionStatus? planActionStatus,
    Map<int, RouteEntity>? routeMap,
    MultiRouteTrail? trail,
    bool? isLoggedIn,
  }) {
    return PlanDetailState(
      plan: plan ?? this.plan,
      initStatus: initStatus ?? this.initStatus,
      routePoints: routePoints ?? this.routePoints,
      altRoutePoints: altRoutePoints ?? this.altRoutePoints,
      scrollToIndex: scrollToIndex,
      shouldShowOverlayLoading:
          shouldShowOverlayLoading ?? this.shouldShowOverlayLoading,
      planActionStatus: planActionStatus ?? this.planActionStatus,
      routeMap: routeMap ?? this.routeMap,
      trail: trail ?? this.trail,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  List<Object?> get props => [
        plan,
        initStatus,
        routePoints,
        altRoutePoints,
        scrollToIndex,
        shouldShowOverlayLoading,
        planActionStatus,
        routeMap,
        trail,
        isLoggedIn,
      ];
}
