part of 'repository.dart';

/// Data synchronization operations for Repository
extension RepositoryDataSync on Repository {
  /// Get the latest data update status comparing local vs remote timestamps
  Future<LatestDataUpdate> getLatestDataUpdate() async {
    final result = await _networkService.getLatestDataUpdate();
    switch (result) {
      case ApiSuccess(data: final response):
        final data = await _appDatabase.queryList(table: 'latest_data_updated');
        if (data.isEmpty) {
          return LatestDataUpdate(
            shouldUpdateAlbergues: true,
            shouldUpdateAlbergueUserImages: true,
            shouldUpdateCities: true,
            shouldUpdateRoutes: true,
            shouldUpdateRoutePoints: true,
            shouldUpdateAltRoutePoints: true,
          );
        }
        final latestUpdated = LatestDataUpdateResponse.fromJson(data.first);
        final alberguesLatestUpdate = latestUpdated.albergues;
        final albergueUserImagesLatestUpdate = latestUpdated.albergueUserImages;
        final citiesLatestUpdate = latestUpdated.cities;
        final routesLatestUpdate = latestUpdated.routes;
        final routePointsLatestUpdate = latestUpdated.routePoints;
        final altRoutePointsLatestUpdate = latestUpdated.altRoutePoints;

        AppLogger.d(
          'Latest update - local: $alberguesLatestUpdate, remote: ${response.albergues}',
          tag: 'Repository',
        );

        return LatestDataUpdate(
          shouldUpdateAlbergues: response.albergues == null
              ? true
              : alberguesLatestUpdate == null ||
                  alberguesLatestUpdate.isBefore(response.albergues!),
          shouldUpdateAlbergueUserImages: response.albergueUserImages == null
              ? true
              : albergueUserImagesLatestUpdate == null ||
                  albergueUserImagesLatestUpdate
                      .isBefore(response.albergueUserImages!),
          shouldUpdateCities: response.cities == null
              ? true
              : citiesLatestUpdate == null ||
                  citiesLatestUpdate.isBefore(response.cities!),
          shouldUpdateRoutes: response.routes == null
              ? true
              : routesLatestUpdate == null ||
                  routesLatestUpdate.isBefore(response.routes!),
          shouldUpdateRoutePoints: response.routePoints == null
              ? true
              : routePointsLatestUpdate == null ||
                  routePointsLatestUpdate.isBefore(response.routePoints!),
          shouldUpdateAltRoutePoints: response.altRoutePoints == null
              ? true
              : altRoutePointsLatestUpdate == null ||
                  altRoutePointsLatestUpdate.isBefore(response.altRoutePoints!),
        );
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }

  /// Update the latest data update values in database
  Future<void> updateLatestDataUpdate() async {
    final result = await _networkService.getLatestDataUpdate();
    switch (result) {
      case ApiSuccess(data: final response):
        final db = await _appDatabase.database;
        await db.transaction((txn) async {
          final batch = txn.batch()
            ..delete('latest_data_updated')
            ..insert('latest_data_updated', response.toDatabaseMapping());
          await batch.commit();
        });
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }

  /// Update timestamps only for successful sync operations
  Future<void> updateLatestDataUpdatePartial({
    required bool routes,
    required bool routePoints,
    required bool altRoutePoints,
    required bool cities,
    required bool albergues,
    required bool albergueUserImages,
  }) async {
    if (!routes &&
        !routePoints &&
        !altRoutePoints &&
        !cities &&
        !albergues &&
        !albergueUserImages) {
      return;
    }

    final result = await _networkService.getLatestDataUpdate();
    switch (result) {
      case ApiSuccess(data: final response):
        final db = await _appDatabase.database;
        final existingData =
            await _appDatabase.queryList(table: 'latest_data_updated');
        final existing = existingData.isNotEmpty
            ? LatestDataUpdateResponse.fromJson(existingData.first)
            : const LatestDataUpdateResponse();

        final updatedMapping = <String, dynamic>{
          'id': 1,
          'routes_updated_at': routes
              ? response.routes?.toIso8601String()
              : existing.routes?.toIso8601String(),
          'route_points_updated_at': routePoints
              ? response.routePoints?.toIso8601String()
              : existing.routePoints?.toIso8601String(),
          'alt_route_points_updated_at': altRoutePoints
              ? response.altRoutePoints?.toIso8601String()
              : existing.altRoutePoints?.toIso8601String(),
          'cities_updated_at': cities
              ? response.cities?.toIso8601String()
              : existing.cities?.toIso8601String(),
          'albergues_updated_at': albergues
              ? response.albergues?.toIso8601String()
              : existing.albergues?.toIso8601String(),
          'albergue_user_images_updated_at': albergueUserImages
              ? response.albergueUserImages?.toIso8601String()
              : existing.albergueUserImages?.toIso8601String(),
        };

        await db.transaction((txn) async {
          final batch = txn.batch()
            ..delete('latest_data_updated')
            ..insert('latest_data_updated', updatedMapping);
          await batch.commit();
        });
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }

  /// Fetch and save routes from API to database
  Future<void> fetchAndSaveRoutes() async {
    final db = await _appDatabase.database;
    final result = await _networkService.getRoutesOnly();
    switch (result) {
      case ApiSuccess(data: final routeData):
        await db.transaction((txn) async {
          await txn.delete('routes');
          final batch = txn.batch();
          for (final route in routeData) {
            batch.insert(
              'routes',
              route.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await batch.commit();
        });
      case ApiFailure(message: final errorMessage):
        _analyticsService.track(
          DataFetchFailedEvent(entity: 'routes'),
        );
        throw Exception(errorMessage);
    }
  }

  /// Fetch and save route points from API to database
  Future<void> fetchAndSaveRoutePoints() async {
    final db = await _appDatabase.database;
    final routePointResult = await _networkService.getRoutePoints();
    switch (routePointResult) {
      case ApiSuccess(data: final routePointData):
        await db.transaction((txn) async {
          await txn.delete('route_points');
          final batch = txn.batch();
          for (final route in routePointData) {
            batch.insert(
              'route_points',
              route.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await batch.commit();
        });
      case ApiFailure(message: final errorMessage):
        _analyticsService.track(
          DataFetchFailedEvent(entity: 'route_points'),
        );
        throw Exception(errorMessage);
    }
  }

  /// Fetch and save alt route points from API to database
  Future<void> fetchAndSaveAltRoutePoints() async {
    final db = await _appDatabase.database;
    final altRoutePointResult = await _networkService.getAltRoutePoints();
    switch (altRoutePointResult) {
      case ApiSuccess(data: final altRoutePointData):
        await db.transaction((txn) async {
          await txn.delete('alt_route_points_values');
          await txn.delete('alt_route_points');
          final batch = txn.batch();
          for (final altRoutePoint in altRoutePointData) {
            batch.insert(
              'alt_route_points',
              altRoutePoint.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            for (final value in altRoutePoint.altRoutePointValues) {
              batch.insert(
                'alt_route_points_values',
                value.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          await batch.commit();
        });
      case ApiFailure(message: final errorMessage):
        _analyticsService.track(
          DataFetchFailedEvent(entity: 'alt_route_points'),
        );
        throw Exception(errorMessage);
    }
  }

  /// Fetch and save albergues from API to database
  Future<void> fetchAndSaveAlbergues() async {
    final albergueResult = await _networkService.getAlbergues();
    switch (albergueResult) {
      case ApiSuccess(data: final albergueData):
        final db = await _appDatabase.database;
        await db.transaction((txn) async {
          await txn.delete('albergue_wifis');
          await txn.delete('albergue_reviews');
          await txn.delete('albergue_prices');
          await txn.delete('albergue_operating_hours');
          await txn.delete('albergue_social_medias');
          await txn.delete('albergue_emails');
          await txn.delete('albergue_phones');
          await txn.delete('albergue_images');
          await txn.delete('albergue_facilities');
          await txn.delete('albergues');

          final batch = txn.batch();
          for (final albergue in albergueData) {
            batch
              ..insert(
                'albergues',
                albergue.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              )
              ..insert(
                'albergue_facilities',
                albergue.facilities.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            for (final image in albergue.images) {
              batch.insert(
                'albergue_images',
                image.toDatabaseMapping(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            for (final phone in albergue.phones) {
              batch.insert(
                'albergue_phones',
                phone.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            for (final email in albergue.emails) {
              batch.insert(
                'albergue_emails',
                email.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            if (albergue.socialMedias != null) {
              batch.insert(
                'albergue_social_medias',
                albergue.socialMedias!.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            if (albergue.operatingHours != null) {
              batch.insert(
                'albergue_operating_hours',
                albergue.operatingHours!.toDatabaseJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            batch.insert(
              'albergue_prices',
              albergue.prices.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            for (final wifi in albergue.wifis) {
              batch.insert(
                'albergue_wifis',
                wifi.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            if (albergue.reviews != null) {
              batch.insert(
                'albergue_reviews',
                albergue.reviews!.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          await batch.commit();
        });
      case ApiFailure(message: final errorMessage):
        _analyticsService.track(
          DataFetchFailedEvent(entity: 'albergues'),
        );
        throw Exception(errorMessage);
    }
    await updateCityAlbergueStatus();
  }

  /// Fetch and save albergue user images from API to database
  Future<void> fetchAndSaveAlbergueUserImages() async {
    final result = await _networkService.getAlbergueUserImages();
    switch (result) {
      case ApiSuccess(data: final albergueUserImages):
        final db = await _appDatabase.database;
        await db.transaction((txn) async {
          await txn.delete('albergue_user_images');
          final batch = txn.batch();
          for (final userImage in albergueUserImages) {
            batch.insert(
              'albergue_user_images',
              userImage.toDatabaseMapping(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await batch.commit();
        });
      case ApiFailure(message: final errorMessage):
        _analyticsService.track(
          DataFetchFailedEvent(entity: 'user_images'),
        );
        throw Exception(errorMessage);
    }
  }

  /// Fetch and save cities from API to database
  Future<void> fetchAndSaveCities() async {
    final cityResult = await _networkService.getCities();
    switch (cityResult) {
      case ApiSuccess(data: final cityData):
        final db = await _appDatabase.database;
        await db.transaction((txn) async {
          await txn.delete('city_route_points');
          await txn.delete('city_routes');
          await txn.delete('cities');

          final batch = txn.batch();
          for (final city in cityData) {
            batch.insert(
              'cities',
              city.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            for (final routeId in city.routeIds) {
              batch.insert(
                'city_routes',
                {'city_id': city.id, 'route_id': routeId},
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            for (final routePointId in city.routePointIds) {
              batch.insert(
                'city_route_points',
                {'city_id': city.id, 'route_point_id': routePointId},
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          await batch.commit();
        });
      case ApiFailure(message: final errorMessage):
        _analyticsService.track(
          DataFetchFailedEvent(entity: 'cities'),
        );
        throw Exception(errorMessage);
    }
  }

  /// Update city albergue status based on albergues table
  Future<void> updateCityAlbergueStatus() async {
    AppLogger.d('Updating city albergue status', tag: 'Repository');
    final db = await _appDatabase.database;

    await db.transaction((txn) async {
      await txn.update('cities', {'has_albergues': 0});
      await txn.execute('''
      UPDATE cities 
      SET has_albergues = 1 
      WHERE id IN (
        SELECT DISTINCT city_id 
        FROM albergues 
        WHERE city_id IS NOT NULL
      )
    ''');
    });
  }

  /// Fetch and save all albergues ratings from API to database
  Future<void> fetchAndSaveAlberguesRating() async {
    try {
      final albergueRatingResult =
          await _networkService.getAllAlberguesRating();
      switch (albergueRatingResult) {
        case ApiSuccess(data: final albergueRatingData):
          final db = await _appDatabase.database;
          await db.transaction((txn) async {
            await txn.delete('albergues_rating');
            final batch = txn.batch();
            for (final albergueRating in albergueRatingData) {
              batch.insert(
                'albergues_rating',
                albergueRating.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            await batch.commit();
          });
        case ApiFailure(message: final _):
          _analyticsService.track(
            DataFetchFailedEvent(entity: 'albergues_rating'),
          );
      }
    } catch (e) {
      AppLogger.e('Error fetching albergue rating',
          tag: 'Repository', error: e,);
    }
  }

  /// Fetch and save a single albergue rating from API to database
  Future<void> fetchAndSaveAlbergueRating({required int id}) async {
    try {
      final albergueRatingResult =
          await _networkService.getAlbergueRating(id: id);
      switch (albergueRatingResult) {
        case ApiSuccess(data: final albergueRatingData):
          final db = await _appDatabase.database;
          await db.transaction((txn) async {
            await txn.insert(
              'albergues_rating',
              albergueRatingData.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          });
        case ApiFailure(message: final _):
          return;
      }
    } catch (e) {
      AppLogger.e('Error fetching albergue rating',
          tag: 'Repository', error: e,);
    }
  }
}
