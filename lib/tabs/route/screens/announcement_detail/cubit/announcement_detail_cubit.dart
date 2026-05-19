import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';

part 'announcement_detail_state.dart';

class AnnouncementDetailCubit extends Cubit<AnnouncementDetailState>
    with SafeEmitMixin {
  AnnouncementDetailCubit({
    required this.announcementId,
    this.onMarkedAsRead,
  }) : super(const AnnouncementDetailState());

  final int announcementId;
  final VoidCallback? onMarkedAsRead;
  final Repository _repository = GetIt.instance<Repository>();

  Future<void> loadAnnouncement() async {
    try {
      safeEmit(state.copyWith(status: AnnouncementDetailStatus.loading));
      final announcement = await _repository.getAnnouncementById(
        id: announcementId,
      );
      await _repository.addAnnouncementReadId(announcementId);
      onMarkedAsRead?.call();
      safeEmit(
        state.copyWith(
          status: AnnouncementDetailStatus.success,
          announcement: announcement,
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Error loading announcement detail',
        tag: 'AnnouncementDetailCubit',
        error: e,
      );
      safeEmit(
        state.copyWith(status: AnnouncementDetailStatus.failure),
      );
    }
  }
}
