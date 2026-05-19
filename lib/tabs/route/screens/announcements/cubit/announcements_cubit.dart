import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';

part 'announcements_state.dart';

class AnnouncementsCubit extends Cubit<AnnouncementsState>
    with SafeEmitMixin {
  AnnouncementsCubit() : super(const AnnouncementsState());

  final Repository _repository = GetIt.instance<Repository>();

  bool _markingAll = false;

  int _computeUnreadCount(
    List<AnnouncementResponse> announcements,
    Set<int> readIds,
  ) =>
      announcements.where((a) => !readIds.contains(a.id)).length;

  Future<void> loadAnnouncements() async {
    try {
      safeEmit(state.copyWith(status: AnnouncementsStatus.loading));
      final announcements = await _repository.getAnnouncements();
      announcements.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
      final readIds = await _repository.getAnnouncementReadIds();
      safeEmit(
        state.copyWith(
          status: AnnouncementsStatus.success,
          announcements: announcements,
          readAnnouncementIds: readIds,
          unreadCount: _computeUnreadCount(announcements, readIds),
        ),
      );
    } catch (e) {
      AppLogger.e(
        'Error loading announcements',
        tag: 'AnnouncementsCubit',
        error: e,
      );
      safeEmit(state.copyWith(status: AnnouncementsStatus.failure));
    }
  }

  bool isRead(int id) => state.readAnnouncementIds.contains(id);

  Future<void> markAsRead(int id) async {
    if (state.readAnnouncementIds.contains(id)) return;
    await _repository.addAnnouncementReadId(id);
    final updatedReadIds = {...state.readAnnouncementIds, id};
    safeEmit(
      state.copyWith(
        readAnnouncementIds: updatedReadIds,
        unreadCount: _computeUnreadCount(state.announcements, updatedReadIds),
      ),
    );
  }

  Future<void> markAllAsRead() async {
    if (_markingAll) return;
    _markingAll = true;
    try {
      if (state.status != AnnouncementsStatus.success) return;
      final allIds = state.announcements.map((a) => a.id).toSet();
      if (allIds.isEmpty) return;
      if (state.readAnnouncementIds.containsAll(allIds)) return;

      final previousIds = state.readAnnouncementIds;
      safeEmit(
        state.copyWith(
          readAnnouncementIds: allIds,
          unreadCount: 0,
        ),
      );
      try {
        await _repository.setAnnouncementReadIds(allIds);
      } catch (e) {
        AppLogger.e(
          'markAllAsRead failed',
          tag: 'AnnouncementsCubit',
          error: e,
        );
        safeEmit(
          state.copyWith(
            readAnnouncementIds: previousIds,
            unreadCount:
                _computeUnreadCount(state.announcements, previousIds),
          ),
        );
      }
    } finally {
      _markingAll = false;
    }
  }
}
