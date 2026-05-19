part of 'stage_map_cubit.dart';

enum StageMapInitStatus {
  initial,
  loading,
  success,
  failure,
}

class StageMapState extends Equatable {
  const StageMapState({
    this.selectedStage,
    this.stagePlan,
    this.route,
    this.allStages = const [],
    this.routePoints = const [],
    this.trailRoutePointsList = const [],
    this.altRoutePoints = const [],
    this.combineMarkerDataList = const [],
    this.junctionMarkerDataList = const [],
    this.initStatus = StageMapInitStatus.initial,
  });

  final StageMapInitStatus initStatus;
  final StageModel? selectedStage;
  final List<StageModel> allStages;
  final StagePlanModel? stagePlan;
  final List<CombineMarkerData> combineMarkerDataList;
  final List<JunctionMarkerData> junctionMarkerDataList;
  final List<RoutePointEntity> routePoints;

  /// Per-route point lists for multi-route trails.
  /// Each inner list contains route points for one trail route,
  /// kept separate so they can be drawn as separate polylines.
  final List<List<RoutePointEntity>> trailRoutePointsList;
  final List<AltRoutePointEntity> altRoutePoints;
  final RouteEntity? route;

  StageMapState copyWith({
    StageModel? selectedStage,
    List<StageModel>? allStages,
    StagePlanModel? stagePlan,
    List<CombineMarkerData>? combineMarkerDataList,
    List<JunctionMarkerData>? junctionMarkerDataList,
    StageMapInitStatus? initStatus,
    List<RoutePointEntity>? routePoints,
    List<List<RoutePointEntity>>? trailRoutePointsList,
    List<AltRoutePointEntity>? altRoutePoints,
    RouteEntity? route,
  }) {
    return StageMapState(
      selectedStage: selectedStage ?? this.selectedStage,
      combineMarkerDataList:
          combineMarkerDataList ?? this.combineMarkerDataList,
      junctionMarkerDataList:
          junctionMarkerDataList ?? this.junctionMarkerDataList,
      allStages: allStages ?? this.allStages,
      stagePlan: stagePlan ?? this.stagePlan,
      routePoints: routePoints ?? this.routePoints,
      trailRoutePointsList:
          trailRoutePointsList ?? this.trailRoutePointsList,
      altRoutePoints: altRoutePoints ?? this.altRoutePoints,
      initStatus: initStatus ?? this.initStatus,
      route: route ?? this.route,
    );
  }

  @override
  List<Object?> get props => [
        selectedStage,
        combineMarkerDataList,
        junctionMarkerDataList,
        allStages,
        stagePlan,
        initStatus,
        routePoints,
        trailRoutePointsList,
        altRoutePoints,
        route,
      ];
}
