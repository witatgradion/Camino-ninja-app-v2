part of 'stage_select_date_cubit.dart';

enum SelectDateLoadDataStatus {
  initial,
  loading,
  success,
  failure,
}

class StageSelectDateState extends Equatable {
  const StageSelectDateState({
    this.date,
    this.currentStage,
    this.stagePlanId,
    this.conflictingStage,
    this.conflictingStageIndex,
    this.loadDataStatus = SelectDateLoadDataStatus.initial,
    this.stages = const [],
  });

  final SelectDateLoadDataStatus loadDataStatus;
  final DateTime? date;
  final StageModel? currentStage;
  final int? stagePlanId;
  final StageModel? conflictingStage;
  final int? conflictingStageIndex;
  final List<StageModel> stages;

  StageSelectDateState copyWith({
    DateTime? date,
    StageModel? currentStage,
    int? stagePlanId,
    StageModel? conflictingStage,
    SelectDateLoadDataStatus? loadDataStatus,
    int? conflictingStageIndex,
    List<StageModel>? stages,
  }) {
    return StageSelectDateState(
      date: date ?? this.date,
      currentStage: currentStage ?? this.currentStage,
      loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      stagePlanId: stagePlanId ?? this.stagePlanId,
      conflictingStageIndex: conflictingStageIndex,
      conflictingStage: conflictingStage,
      stages: stages ?? this.stages,
    );
  }

  @override
  List<Object?> get props => [
        date,
        currentStage,
        stagePlanId,
        conflictingStage,
        loadDataStatus,
        conflictingStageIndex,
        stages,
      ];

  bool get hasConflictingStage => conflictingStage != null;

  bool get isPastDate {
    if (date == null) {
      return false;
    }
    return date!.isPastDate();
  }
}
