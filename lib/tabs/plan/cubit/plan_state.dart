part of 'plan_cubit.dart';

enum PlanInitStatus {
  initial,
  loading,
  success,
  failure,
}

enum PlanActionStatus {
  initial,
  loading,
  success,
  failure,
}

class PlanState extends Equatable {
  const PlanState({
    this.stagePlans = const [],
    this.incompletePlans = const [],
    this.initStatus = PlanInitStatus.initial,
    this.planActionStatus = PlanActionStatus.initial,
    this.isSyncing = false,
    this.isLoggedIn = false,
    this.hasLoadedOnce = false,
    this.multiRouteMap = const {},
  });

  final PlanInitStatus initStatus;
  final PlanActionStatus planActionStatus;
  final List<StagePlanModel> stagePlans;
  final List<IncompletePlanInfo> incompletePlans;
  final bool isSyncing;
  final bool isLoggedIn;
  final bool hasLoadedOnce;

  /// Maps plan ID to a map of routeId -> RouteEntity,
  /// only populated for plans that span multiple routes.
  final Map<int, Map<int, RouteEntity>> multiRouteMap;

  PlanState copyWith({
    List<StagePlanModel>? stagePlans,
    List<IncompletePlanInfo>? incompletePlans,
    PlanInitStatus? initStatus,
    PlanActionStatus? planActionStatus,
    bool? isSyncing,
    bool? isLoggedIn,
    bool? hasLoadedOnce,
    Map<int, Map<int, RouteEntity>>? multiRouteMap,
  }) {
    return PlanState(
      stagePlans: stagePlans ?? this.stagePlans,
      incompletePlans: incompletePlans ?? this.incompletePlans,
      initStatus: initStatus ?? this.initStatus,
      planActionStatus: planActionStatus ?? this.planActionStatus,
      isSyncing: isSyncing ?? this.isSyncing,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      multiRouteMap: multiRouteMap ?? this.multiRouteMap,
    );
  }

  @override
  List<Object?> get props => [
        stagePlans,
        incompletePlans,
        initStatus,
        planActionStatus,
        isSyncing,
        isLoggedIn,
        hasLoadedOnce,
        multiRouteMap,
      ];
}
