import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'saved_accommodations_state.dart';

class SavedAccommodationsCubit extends Cubit<SavedAccommodationsState>
    with SafeEmitMixin {
  SavedAccommodationsCubit({this.onSyncComplete}) : super(const SavedAccommodationsState());

  final _repository = GetIt.instance<Repository>();

  /// Called after sync completes successfully, so the screen can
  /// refresh other cubits (e.g., FavoritesCubit cache).
  final void Function()? onSyncComplete;

  Future<void> init() async {
    final albergues = await _repository.getFavoriteAlbergues();
    safeEmit(
      state.copyWith(
        albergues: albergues,
        filteredAlbergues: albergues,
      ),
    );
    // Sync in background, then refresh if successful
    unawaited(_syncAndRefresh());
  }

  Future<void> _syncAndRefresh() async {
    try {
      final synced =
          await _repository.syncSavedAccommodations();
      if (synced) {
        await refresh();
        onSyncComplete?.call();
      }
    } catch (_) {
      // Silently fail — local data already shown
    }
  }

  void filterAlbergues(String query) {
    final filteredAlbergues = state.albergues
        ?.where(
          (albergue) =>
              albergue.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    safeEmit(
      state.copyWith(
        filteredAlbergues: filteredAlbergues,
        searchQuery: query,
      ),
    );
  }

  void removeAlbergue(AlbergueEntity albergueEntity) {
    final albergues = state.albergues
        ?.where((albergue) => albergue.id != albergueEntity.id)
        .toList();
    final filteredAlbergues = albergues
        ?.where(
          (albergue) => albergue.name.toLowerCase().contains(
                state.searchQuery.toLowerCase(),
              ),
        )
        .toList();
    safeEmit(
      state.copyWith(
        albergues: albergues,
        filteredAlbergues: filteredAlbergues,
      ),
    );
  }

  Future<void> refresh() async {
    final albergues = await _repository.getFavoriteAlbergues();
    final filteredAlbergues = albergues
        .where(
          (albergue) => albergue.name.toLowerCase().contains(
                state.searchQuery.toLowerCase(),
              ),
        )
        .toList();
    safeEmit(
      state.copyWith(
        albergues: albergues,
        filteredAlbergues: filteredAlbergues,
      ),
    );
  }
}
