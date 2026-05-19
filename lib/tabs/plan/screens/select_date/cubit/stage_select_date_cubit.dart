import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';

part 'stage_select_date_state.dart';

class StageSelectDateCubit extends Cubit<StageSelectDateState>
    with SafeEmitMixin {
  StageSelectDateCubit() : super(const StageSelectDateState());

  final StagePlanRepository _stagePlanRepository =
      GetIt.instance<StagePlanRepository>();

  Future<void> init(StageModel? stage, int? stagePlanId) async {
    if (stagePlanId == null) {
      safeEmit(
        state.copyWith(
          date: stage?.date,
          currentStage: stage,
        ),
      );
      return;
    }
    try {
      emit(state.copyWith(loadDataStatus: SelectDateLoadDataStatus.loading));
      final stages = await _stagePlanRepository.getStagesByPlanId(stagePlanId);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      emit(
        state.copyWith(
          date: stage?.date,
          currentStage: stage,
          stagePlanId: stagePlanId,
          stages: stages,
          loadDataStatus: SelectDateLoadDataStatus.success,
        ),
      );
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      emit(
        state.copyWith(
          date: stage?.date,
          currentStage: stage,
          stagePlanId: stagePlanId,
          loadDataStatus: SelectDateLoadDataStatus.success,
        ),
      );
    }
  }

  void checkConflictingStage(DateTime date) {
    try {
      // Convert to local date to preserve the selected day regardless of timezone
      // TableCalendar returns UTC midnight, which can shift backward when converted
      // to local time in western timezones (e.g., US)
      final localDate = DateTime(date.year, date.month, date.day);

      final stagePlanId = state.stagePlanId ?? state.currentStage?.stagePlanId;
      if (stagePlanId == null) {
        safeEmit(
          state.copyWith(
            date: localDate,
          ),
        );
        return;
      }

      final stages = state.stages;
      StageModel? conflictingStage;
      int? conflictingStageIndex;

      // Normalize the input date to remove time component for comparison
      final normalizedDate = localDate;

      // Check all stages across all plans for the same date
      for (var i = 0; i < stages.length; i++) {
        final stage = stages[i];
        if (stage.date != null) {
          // Normalize stage date for comparison
          final stageNormalizedDate = DateTime(
            stage.date!.year,
            stage.date!.month,
            stage.date!.day,
          );

          // Check if dates match and it's not the current stage being edited
          if (stageNormalizedDate.isAtSameMomentAs(normalizedDate) &&
              stage.id != state.currentStage?.id) {
            conflictingStage = stage;
            conflictingStageIndex = i;
            break;
          }
        }
      }

      if (conflictingStage?.id == state.currentStage?.id) {
        safeEmit(
          state.copyWith(
            date: localDate,
          ),
        );
        return;
      }

      safeEmit(
        state.copyWith(
          date: localDate,
          conflictingStage: conflictingStage,
          conflictingStageIndex: conflictingStageIndex,
        ),
      );
    } catch (_) {}
  }
}
