import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:storage/storage.dart';

part 'stage_select_route_state.dart';

class StageSelectRouteCubit extends Cubit<StageSelectRouteState>
    with SafeEmitMixin {
  StageSelectRouteCubit() : super(const StageSelectRouteState());

  Future<void> loadData() async {
    // try {
    //   safeEmit(state.copyWith(initStatus: SelectRouteInitStatus.loading));

    //   final routes = await _repository.getRoutesFromDb();

    //   safeEmit(state.copyWith(initStatus: SelectRouteInitStatus.success, routes: routes));
    // } catch (_) {
    //   safeEmit(state.copyWith(initStatus: SelectRouteInitStatus.failure));
    // }
  }
}
