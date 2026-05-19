part of 'repository.dart';

bool _isSyncingFavorites = false;
bool _favoritesSyncQueued = false;

/// Favorites management operations for Repository
extension RepositoryFavorites on Repository {
  /// Add albergue to favorites
  Future<void> addFavoriteAlbergue({
    required int albergueId,
    required int cityId,
    required int routeId,
  }) async {
    await _appDatabase.addFavoriteAlbergue(
      albergueId: albergueId,
      cityId: cityId,
      routeId: routeId,
    );
    _analyticsService.track(
      FavoriteAddedEvent(
        albergueId: albergueId,
        cityId: cityId,
        routeId: routeId,
      ),
    );
    unawaited(_trySyncFavorites());
  }

  /// Remove albergue from favorites
  Future<void> removeFavoriteAlbergue({
    required int albergueId,
    required int cityId,
    required int routeId,
  }) async {
    await _appDatabase.removeFavoriteAlbergue(
      albergueId: albergueId,
      cityId: cityId,
      routeId: routeId,
    );
    _analyticsService.track(
      FavoriteRemovedEvent(
        albergueId: albergueId,
        cityId: cityId,
        routeId: routeId,
      ),
    );
    unawaited(_trySyncFavorites());
  }

  /// Check if albergue is favorite
  Future<bool> isFavoriteAlbergue({
    required int albergueId,
    required int cityId,
    required int routeId,
  }) {
    return _appDatabase.isFavoriteAlbergue(
      albergueId: albergueId,
      cityId: cityId,
      routeId: routeId,
    );
  }

  /// Get list of favorite albergue IDs
  Future<List<int>> getFavoriteAlbergueIds() {
    return _appDatabase.getFavoriteAlbergueIds();
  }

  /// Get list of favorite albergues
  Future<List<AlbergueEntity>> getFavoriteAlbergues() {
    return _appDatabase.getFavoriteAlbergues();
  }

  /// Sync saved accommodations with the server.
  /// Returns true if sync succeeded, false otherwise.
  Future<bool> syncSavedAccommodations() async {
    if (_isSyncingFavorites) {
      _favoritesSyncQueued = true;
      return false;
    }
    _isSyncingFavorites = true;
    try {
      final credential =
          await _appPreferences.getUserCredential();
      if (credential?.accessToken == null) return false;

      final localFavorites =
          await _appDatabase.getAllFavoritesForSync();

      final items = localFavorites.map((row) {
        return SyncSavedAccommodationItem(
          albergueId: row['albergue_id'] as int,
          updatedAt: row['updated_at'] as String? ??
              DateTime.now().toUtc().toIso8601String(),
          deletedAt: row['deleted_at'] as String?,
        );
      }).toList();

      final sentAlbergueIds =
          items.map((i) => i.albergueId).toSet();

      final request =
          SyncSavedAccommodationsRequest(items: items);

      final result =
          await _networkService.syncSavedAccommodations(
        request: request,
      );

      if (result
          is ApiSuccess<SyncSavedAccommodationsResponse>) {
        final response = result.data;

        final serverItems = response.items
            .map((item) => {
                  'albergue_id': item.albergueId,
                  'updated_at': item.updatedAt,
                })
            .toList();

        await _appDatabase.replaceFavoritesFromSync(
          serverItems,
          sentAlbergueIds,
        );

        AppLogger.d(
          'Favorites sync success: '
          'sent ${items.length}, '
          'received ${response.items.length}',
          tag: 'Repository',
        );
        return true;
      }

      if (result is ApiFailure) {
        final failure = result as ApiFailure;
        AppLogger.w(
          'Favorites sync failed: '
          '${failure.message}',
          tag: 'Repository',
        );
      }
      return false;
    } catch (e) {
      AppLogger.e(
        'Favorites sync error',
        tag: 'Repository',
        error: e,
      );
      return false;
    } finally {
      _isSyncingFavorites = false;
      if (_favoritesSyncQueued) {
        _favoritesSyncQueued = false;
        unawaited(_trySyncFavorites());
      }
    }
  }

  /// Fire-and-forget sync wrapper
  Future<void> _trySyncFavorites() async {
    try {
      await syncSavedAccommodations();
    } catch (_) {
      // Silently fail — will retry on next trigger
    }
  }
}
