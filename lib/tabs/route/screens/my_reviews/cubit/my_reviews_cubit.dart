import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'my_reviews_state.dart';

class MyReviewsCubit extends Cubit<MyReviewsState> with SafeEmitMixin {
  MyReviewsCubit() : super(const MyReviewsState());

  final Repository _repository = GetIt.instance<Repository>();

  Future<void> loadMyReviews() async {
    try {
      safeEmit(
        state.copyWith(
          loadMyReviewsStatus: LoadMyReviewsStatus.loading,
        ),
      );
      final result = await _repository.getMyReviews();
      final albergueIds = result
          .map((r) => r.albergueId)
          .whereType<int>()
          .toSet()
          .toList();
      Map<int, AlbergueEntity>? byId;
      if (albergueIds.isNotEmpty) {
        try {
          final albergues =
              await _repository.getAlberguesWithNestedObjectsFromDbByIds(
            albergueIds,
          );
          byId = {for (final a in albergues) a.id: a};
        } catch (e, st) {
          AppLogger.e(
            'Batch albergue load for my reviews failed',
            error: e,
            stackTrace: st,
          );
        }
      }
      final enriched = result.map((r) {
        final id = r.albergueId;
        if (id == null || byId == null) return r;
        return r.copyWith(albergue: byId[id]);
      }).toList();
      safeEmit(
        state.copyWith(
          reviews: enriched,
          loadMyReviewsStatus: LoadMyReviewsStatus.loaded,
        ),
      );
    } catch (e) {
      safeEmit(state.copyWith(loadMyReviewsStatus: LoadMyReviewsStatus.error));
    }
  }

  void selectTab(MyReviewsTabMode tabMode) {
    safeEmit(state.copyWith(tabMode: tabMode));
  }
}
