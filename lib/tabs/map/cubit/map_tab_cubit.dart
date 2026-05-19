import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';

part 'map_tab_state.dart';

class MapTabCubit extends Cubit<MapTabState> with SafeEmitMixin {
  MapTabCubit() : super(const MapTabState());

  final StagePlanRepository _stagePlanRepository =
      GetIt.instance<StagePlanRepository>();

  Future<void> loadPlans({bool shouldShowLoading = true}) async {
    try {
      if (shouldShowLoading) {
        safeEmit(state.copyWith(planLoadStatus: MapTabPlanLoadStatus.loading));
      }

      final result = await _stagePlanRepository.getAllStagePlans();
      final plans = result.completePlans;

      final currentSelectedId = state.selectedPlan?.id;
      final stillExists = plans.any((p) => p.id == currentSelectedId);

      final StagePlanModel? selected;
      if (stillExists) {
        selected = plans.firstWhere((p) => p.id == currentSelectedId);
      } else if (plans.isNotEmpty) {
        selected = _pickBestPlan(plans);
      } else {
        selected = null;
      }

      safeEmit(
        state.copyWith(
          planLoadStatus: MapTabPlanLoadStatus.success,
          plans: plans,
          selectedPlan: selected,
          clearSelectedPlan: selected == null,
        ),
      );
    } catch (e) {
      AppLogger.e('Error loading plans', tag: 'MapTabCubit', error: e);
      safeEmit(state.copyWith(planLoadStatus: MapTabPlanLoadStatus.failure));
    }
  }

  StagePlanModel _pickBestPlan(List<StagePlanModel> plans) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final plan in plans) {
      for (var i = 0; i < plan.stages.length; i++) {
        final d = plan.computeStageDate(i);
        if (d == null) continue;
        if (today == DateTime(d.year, d.month, d.day)) return plan;
      }
    }
    return plans.first;
  }

  void selectMode(MapTabMode mode) {
    safeEmit(state.copyWith(mode: mode));
    if (mode == MapTabMode.plan) {
      loadPlans(shouldShowLoading: false);
    }
  }

  void selectPlan(StagePlanModel plan) {
    safeEmit(state.copyWith(selectedPlan: plan));
  }
}
