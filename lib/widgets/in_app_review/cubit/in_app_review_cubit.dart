import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';

part 'in_app_review_state.dart';

class InAppReviewCubit extends Cubit<InAppReviewState> with SafeEmitMixin {
  InAppReviewCubit() : super(const InAppReviewState());

  final Repository _repository = GetIt.instance<Repository>();

  Stream<bool> get doNotAskAgainStream =>
      stream.map((s) => s.doNotAskAgain).distinct();

  Stream<int> get showTimesStream => stream.map((s) => s.showTimes).distinct();

  Future<void> init() async {
    final doNotAskAgain = await _repository.getDoNotAskInAppReview();
    final showTimes = await _repository.getInAppReviewShowTimes();
    safeEmit(
      state.copyWith(
        doNotAskAgain: doNotAskAgain,
        showTimes: showTimes ?? 0,
      ),
    );
  }

  Future<void> setDoNotAskAgain(bool value) async {
    await _repository.setDoNotAskInAppReview(value);
    safeEmit(
      state.copyWith(
        doNotAskAgain: value,
      ),
    );
  }

  Future<void> setShowTimes(int value) async {
    await _repository.setInAppReviewShowTimes(value);
    safeEmit(
      state.copyWith(
        showTimes: value,
      ),
    );
  }

  Future<void> resetDestinationCheckPoints() async {
    await _repository.setSelectDestinationCheckPoints(null);
  }

  Future<void> updateDestinationCheckPoints(DateTime value) async {
    await _repository.setSelectDestinationCheckPoints(value);
  }
}
