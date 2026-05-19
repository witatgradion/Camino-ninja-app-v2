part of 'add_edit_stage_cubit.dart';

enum AddEditStageInitStatus {
  initial,
  loading,
  success,
  failure,
}

enum StageOverviewVisibility {
  visible,
  hidden,
}

enum SaveButtonVisibility {
  visible,
  hidden,
}

enum SaveStageStatus {
  initial,
  loading,
  success,
  failure,
}

class AddEditStageState extends Equatable {
  const AddEditStageState({
    this.stage,
    this.route,
    this.updatedPlan,
    this.updatedStage,
    this.planName,
    this.trail,
    this.initStatus = AddEditStageInitStatus.initial,
    this.stageOverviewVisibility = StageOverviewVisibility.hidden,
    this.saveButtonVisibility = SaveButtonVisibility.hidden,
    this.saveStageStatus = SaveStageStatus.initial,
    this.routePoints = const [],
    this.altRoutePoints = const [],
    this.clearStageNotes = false,
  });

  final AddEditStageInitStatus initStatus;
  final StageOverviewVisibility stageOverviewVisibility;
  final StageModel? stage;
  final RouteEntity? route;
  final SaveButtonVisibility saveButtonVisibility;
  final SaveStageStatus saveStageStatus;
  final List<RoutePointEntity> routePoints;
  final List<AltRoutePointEntity> altRoutePoints;
  final StagePlanModel? updatedPlan;
  final StageModel? updatedStage;
  final String? planName;
  final MultiRouteTrail? trail;

  /// When true, the user explicitly cleared the stage note
  /// (used on update to write `stage_notes = NULL`).
  final bool clearStageNotes;

  AddEditStageState copyWith({
    StageModel? stage,
    StagePlanModel? updatedPlan,
    StageModel? updatedStage,
    AddEditStageInitStatus? initStatus,
    RouteEntity? route,
    StageOverviewVisibility? stageOverviewVisibility,
    SaveButtonVisibility? saveButtonVisibility,
    SaveStageStatus? saveStageStatus,
    List<RoutePointEntity>? routePoints,
    List<AltRoutePointEntity>? altRoutePoints,
    String? planName,
    bool clearPlanName = false,
    MultiRouteTrail? trail,
    bool? clearStageNotes,
  }) {
    return AddEditStageState(
      stage: stage ?? this.stage,
      updatedPlan: updatedPlan ?? this.updatedPlan,
      updatedStage: updatedStage ?? this.updatedStage,
      initStatus: initStatus ?? this.initStatus,
      route: route ?? this.route,
      stageOverviewVisibility:
          stageOverviewVisibility ?? this.stageOverviewVisibility,
      saveButtonVisibility: saveButtonVisibility ?? this.saveButtonVisibility,
      saveStageStatus: saveStageStatus ?? this.saveStageStatus,
      routePoints: routePoints ?? this.routePoints,
      altRoutePoints: altRoutePoints ?? this.altRoutePoints,
      planName: clearPlanName ? null : (planName ?? this.planName),
      trail: trail ?? this.trail,
      clearStageNotes: clearStageNotes ?? this.clearStageNotes,
    );
  }

  @override
  List<Object?> get props => [
        stage,
        initStatus,
        route,
        stageOverviewVisibility,
        saveButtonVisibility,
        saveStageStatus,
        routePoints,
        altRoutePoints,
        updatedPlan,
        updatedStage,
        planName,
        trail,
        clearStageNotes,
      ];
}
