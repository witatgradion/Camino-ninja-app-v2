part of 'map_tab_cubit.dart';

enum MapTabMode { route, plan }

enum MapTabPlanLoadStatus { initial, loading, success, failure }

class MapTabState extends Equatable {
  const MapTabState({
    this.mode = MapTabMode.route,
    this.plans = const [],
    this.selectedPlan,
    this.planLoadStatus = MapTabPlanLoadStatus.initial,
  });

  final MapTabMode mode;
  final List<StagePlanModel> plans;
  final StagePlanModel? selectedPlan;
  final MapTabPlanLoadStatus planLoadStatus;

  bool get hasMultiplePlans => plans.length > 1;

  MapTabState copyWith({
    MapTabMode? mode,
    List<StagePlanModel>? plans,
    StagePlanModel? selectedPlan,
    bool clearSelectedPlan = false,
    MapTabPlanLoadStatus? planLoadStatus,
  }) {
    return MapTabState(
      mode: mode ?? this.mode,
      plans: plans ?? this.plans,
      selectedPlan:
          clearSelectedPlan ? null : (selectedPlan ?? this.selectedPlan),
      planLoadStatus: planLoadStatus ?? this.planLoadStatus,
    );
  }

  @override
  List<Object?> get props => [mode, plans, selectedPlan, planLoadStatus];
}
