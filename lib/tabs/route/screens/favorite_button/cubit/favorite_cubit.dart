import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:repository/repository.dart';

part 'favorite_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository) : super(const FavoritesState());

  final Repository _repository;

  // Async operation management to prevent deadlocks
  final Map<int, Completer<bool>> _loadingCompleters = {};
  final Map<int, Timer> _timeoutTimers = {};

  // Constants for timeout and retry management
  static const Duration _loadTimeout = Duration(seconds: 30);
  static const Duration _ensureTimeout = Duration(seconds: 10);
  static const int _maxRetries = 3;

  Stream<Offset?> get flyingFavoriteOffsetStream =>
      stream.map((s) => s.latestFlyingOffset).distinct();

  @override
  Future<void> close() async {
    // Clean up all pending operations
    _cleanupPendingOperations();
    return super.close();
  }

  /// Clean up all pending operations and timers
  void _cleanupPendingOperations() {
    // Cancel all timeout timers
    for (final timer in _timeoutTimers.values) {
      timer.cancel();
    }
    _timeoutTimers.clear();

    // Complete all pending completers with errors
    for (final completer in _loadingCompleters.values) {
      if (!completer.isCompleted) {
        completer
            .completeError(Exception('Operation cancelled - cubit disposed'));
      }
    }
    _loadingCompleters.clear();
  }

  /// Internal method to complete loading operation
  void _completeLoadingOperation(int albergueId, bool result) {
    final completer = _loadingCompleters.remove(albergueId);
    final timer = _timeoutTimers.remove(albergueId);

    timer?.cancel();

    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  /// Internal method to fail loading operation
  void _failLoadingOperation(int albergueId, Object error) {
    final completer = _loadingCompleters.remove(albergueId);
    final timer = _timeoutTimers.remove(albergueId);

    timer?.cancel();

    if (completer != null && !completer.isCompleted) {
      completer.completeError(error);
    }
  }

  Future<void> loadFavoriteStatus(
    int albergueId,
    int cityId,
    int routeId, {
    int retryCount = 0,
  }) async {
    // Skip if already loaded
    if (state.favorites.containsKey(albergueId)) {
      return;
    }

    // Check if already loading and return existing completer
    if (state.loading.contains(albergueId)) {
      final existingCompleter = _loadingCompleters[albergueId];
      if (existingCompleter != null && !existingCompleter.isCompleted) {
        try {
          await existingCompleter.future.timeout(_loadTimeout);
          return;
        } catch (e) {
          // If existing operation failed, we'll retry below
          AppLogger.w(
            'Existing load operation failed for albergue $albergueId',
            tag: 'FavoritesCubit',
          );
        }
      }
    }

    // Create new completer for this operation
    final completer = Completer<bool>();
    _loadingCompleters[albergueId] = completer;

    // Set up timeout timer
    _timeoutTimers[albergueId] = Timer(_loadTimeout, () {
      if (!completer.isCompleted) {
        final error = TimeoutException(
          'Loading favorite status timed out after ${_loadTimeout.inSeconds}s',
          _loadTimeout,
        );
        _failLoadingOperation(albergueId, error);

        // Emit timeout error state
        if (!isClosed) {
          final newLoading = Set<int>.from(state.loading)..remove(albergueId);
          emit(state.copyWith(
            loading: newLoading,
            errors: {...state.errors, albergueId: 'Operation timed out'},
          ),);
        }
      }
    });

    try {
      // Emit loading state
      if (!isClosed) {
        emit(state.copyWith(
          loading: {...state.loading, albergueId},
        ),);
      }

      final isFavorite = await _repository.isFavoriteAlbergue(
        albergueId: albergueId,
        cityId: cityId,
        routeId: routeId,
      );

      // Complete successfully
      _completeLoadingOperation(albergueId, isFavorite);

      // Emit success state
      if (!isClosed) {
        final newLoading = Set<int>.from(state.loading)..remove(albergueId);
        final newErrors = Map<int, String>.from(state.errors)
          ..remove(albergueId);

        emit(state.copyWith(
          favorites: {...state.favorites, albergueId: isFavorite},
          loading: newLoading,
          errors: newErrors,
        ),);
      }
    } catch (e) {
      AppLogger.e(
        'Error loading favorite status for albergue $albergueId',
        tag: 'FavoritesCubit',
        error: e,
      );

      // Handle retries for transient errors
      if (retryCount < _maxRetries && _shouldRetry(e)) {
        AppLogger.d(
          'Retrying load operation for albergue $albergueId '
          '(attempt ${retryCount + 1}/$_maxRetries)',
          tag: 'FavoritesCubit',
        );

        // Clean up current operation
        _failLoadingOperation(albergueId, e);

        // Wait before retry
        await Future<void>.delayed(
          Duration(milliseconds: 500 * (retryCount + 1)),
        );

        // Retry if still needed and cubit not closed
        if (!isClosed && !state.favorites.containsKey(albergueId)) {
          return loadFavoriteStatus(albergueId, cityId, routeId,
              retryCount: retryCount + 1,);
        }
      } else {
        // Fail permanently
        _failLoadingOperation(albergueId, e);

        if (!isClosed) {
          final newLoading = Set<int>.from(state.loading)..remove(albergueId);
          emit(state.copyWith(
            loading: newLoading,
            errors: {...state.errors, albergueId: e.toString()},
          ),);
        }
      }
    }
  }

  /// Determine if an error is worth retrying
  bool _shouldRetry(Object error) {
    // Retry for network-related errors, but not for business logic errors
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('socket');
  }

  /// FIXED: Replaces dangerous infinite loop with proper async handling
  Future<void> ensureFavoriteStatusLoaded(
    int albergueId,
    int cityId,
    int routeId,
  ) async {
    // Return immediately if already loaded
    if (state.favorites.containsKey(albergueId)) {
      return;
    }

    // Check if currently loading
    if (state.loading.contains(albergueId)) {
      final completer = _loadingCompleters[albergueId];
      if (completer != null && !completer.isCompleted) {
        try {
          // Wait for existing operation with timeout
          await completer.future.timeout(_ensureTimeout);
          return;
        } on TimeoutException {
          AppLogger.w(
            'Ensure operation timed out for albergue $albergueId',
            tag: 'FavoritesCubit',
          );
          // Continue to start new load operation
        } catch (e) {
          AppLogger.w(
            'Existing load operation failed for albergue $albergueId',
            tag: 'FavoritesCubit',
          );
          // Continue to start new load operation
        }
      }
    }

    // Start new load operation if needed
    if (!state.favorites.containsKey(albergueId)) {
      await loadFavoriteStatus(albergueId, cityId, routeId);
    }
  }

  Future<void> toggleFavorite({
    required int albergueId,
    required int cityId,
    required int routeId,
    required Offset favoriteOffset,
  }) async {
    try {
      // Ensure we have the current status loaded first
      await ensureFavoriteStatusLoaded(albergueId, cityId, routeId);

      final currentStatus = state.favorites[albergueId] ?? false;
      final newStatus = !currentStatus;

      if (newStatus) {
        emit(state.copyWith(latestFlyingOffset: favoriteOffset));
      }

      // Optimistically update UI - remove any errors for this albergue
      final newErrors = Map<int, String>.from(state.errors)..remove(albergueId);

      if (!isClosed) {
        emit(state.copyWith(
          favorites: {...state.favorites, albergueId: newStatus},
          errors: newErrors,
        ),);
      }

      // Perform the actual repository operation
      if (newStatus) {
        await _repository.addFavoriteAlbergue(
          albergueId: albergueId,
          cityId: cityId,
          routeId: routeId,
        );
      } else {
        await _repository.removeFavoriteAlbergue(
          albergueId: albergueId,
          cityId: cityId,
          routeId: routeId,
        );
      }

      AppLogger.d(
        'Successfully toggled favorite for albergue $albergueId to $newStatus',
        tag: 'FavoritesCubit',
      );
    } catch (e) {
      AppLogger.e(
        'Error toggling favorite for albergue $albergueId',
        tag: 'FavoritesCubit',
        error: e,
      );

      // Revert optimistic update on error
      final currentStatus = state.favorites[albergueId] ?? false;

      if (!isClosed) {
        emit(state.copyWith(
          favorites: {...state.favorites, albergueId: currentStatus},
          errors: {
            ...state.errors,
            albergueId: 'Failed to update favorite: $e',
          },
        ),);
      }

      // Re-throw to allow UI to handle the error
      rethrow;
    } finally {
      // Reset flying favorite offset
      emit(state.copyWith());
    }
  }

  Future<void> refreshFavoriteStatus(
    int albergueId,
    int cityId,
    int routeId,
  ) async {
    // Cancel any pending operations for this albergue
    _cleanupAlbergueOperation(albergueId);

    // Force reload by removing from cache
    final newFavorites = Map<int, bool>.from(state.favorites);
    final newErrors = Map<int, String>.from(state.errors);
    final newLoading = Set<int>.from(state.loading);

    newFavorites.remove(albergueId);
    newErrors.remove(albergueId);
    newLoading.remove(albergueId);

    if (!isClosed) {
      emit(state.copyWith(
        favorites: newFavorites,
        errors: newErrors,
        loading: newLoading,
      ),);
    }

    // Load fresh status
    await loadFavoriteStatus(albergueId, cityId, routeId);
  }

  /// Clean up operations for a specific albergue
  void _cleanupAlbergueOperation(int albergueId) {
    final completer = _loadingCompleters.remove(albergueId);
    final timer = _timeoutTimers.remove(albergueId);

    timer?.cancel();

    if (completer != null && !completer.isCompleted) {
      completer.completeError(Exception('Operation cancelled'));
    }
  }

  Future<void> loadAllFavorites() async {
    try {
      final favoriteIds = await _repository.getFavoriteAlbergueIds();
      final favoritesMap = <int, bool>{};

      for (final id in favoriteIds) {
        favoritesMap[id] = true;
      }

      if (!isClosed) {
        emit(state.copyWith(favorites: favoritesMap));
      }

      AppLogger.d(
        'Loaded ${favoriteIds.length} favorite albergues',
        tag: 'FavoritesCubit',
      );
    } catch (e) {
      AppLogger.e('Error loading all favorites', tag: 'FavoritesCubit', error: e);

      if (!isClosed) {
        emit(state.copyWith(
          errors: {
            ...state.errors,
            -1: 'Failed to load favorites: $e',
          },
        ),);
      }
    }
  }

  /// Clear all errors (useful for UI retry mechanisms)
  void clearErrors() {
    if (!isClosed) {
      emit(state.copyWith(errors: {}));
    }
  }

  /// Cancel loading operation for specific albergue
  void cancelLoading(int albergueId) {
    _cleanupAlbergueOperation(albergueId);

    final newLoading = Set<int>.from(state.loading)..remove(albergueId);
    if (!isClosed) {
      emit(state.copyWith(loading: newLoading));
    }
  }

  bool isFavorite(int albergueId) {
    return state.favorites[albergueId] ?? false;
  }

  bool isLoading(int albergueId) {
    return state.loading.contains(albergueId);
  }

  bool hasError(int albergueId) {
    return state.errors.containsKey(albergueId);
  }

  String? getError(int albergueId) {
    return state.errors[albergueId];
  }

  /// Get overall loading state
  bool get hasAnyLoading => state.loading.isNotEmpty;

  /// Get overall error state
  bool get hasAnyErrors => state.errors.isNotEmpty;

  /// Get debug info about pending operations
  Map<String, dynamic> get debugInfo => {
        'active_completers': _loadingCompleters.length,
        'active_timers': _timeoutTimers.length,
        'loading_items': state.loading.toList(),
        'error_items': state.errors.keys.toList(),
        'favorite_items': state.favorites.length,
      };
}
