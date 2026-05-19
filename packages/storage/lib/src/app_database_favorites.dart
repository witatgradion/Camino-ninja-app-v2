part of 'app_database.dart';

/// Favorites management operations for AppDatabase
extension AppDatabaseFavorites on AppDatabase {
  /// Add an albergue to favorites
  Future<void> addFavoriteAlbergue({
    required int albergueId,
    required int cityId,
    required int routeId,
  }) async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.transaction((txn) async {
      // Check if row already exists
      final existing = await txn.query(
        'favorites_albergues',
        where: 'albergue_id = ?',
        whereArgs: [albergueId],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        // Update existing row (handles both
        // soft-deleted re-add and route/city change)
        await txn.update(
          'favorites_albergues',
          {
            'deleted_at': null,
            'updated_at': now,
            'city_id': cityId,
            'route_id': routeId,
          },
          where: 'albergue_id = ?',
          whereArgs: [albergueId],
        );
      } else {
        await txn.insert(
          'favorites_albergues',
          {
            'albergue_id': albergueId,
            'city_id': cityId,
            'route_id': routeId,
            'created_at': now,
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  /// Soft-delete an albergue from favorites
  Future<void> removeFavoriteAlbergue({
    required int albergueId,
    required int routeId,
    required int cityId,
  }) async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.transaction((txn) async {
      await txn.update(
        'favorites_albergues',
        {
          'deleted_at': now,
          'updated_at': now,
        },
        where: 'albergue_id = ?',
        whereArgs: [albergueId],
      );
    });
  }

  /// Check if an albergue is in favorites
  Future<bool> isFavoriteAlbergue({
    required int albergueId,
    required int routeId,
    required int cityId,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.query(
        'favorites_albergues',
        where: 'albergue_id = ? AND route_id = ? '
            'AND city_id = ? AND deleted_at IS NULL',
        whereArgs: [albergueId, routeId, cityId],
        limit: 1,
      );
      return result.isNotEmpty;
    });
  }

  /// Get all favorite albergue IDs
  Future<List<int>> getFavoriteAlbergueIds() async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.query(
        'favorites_albergues',
        columns: ['albergue_id'],
        where: 'deleted_at IS NULL',
        orderBy: 'created_at DESC',
      );
      return result
          .map((row) => row['albergue_id'] as int)
          .toList();
    });
  }

  /// Get all favorite albergues with full details
  Future<List<AlbergueEntity>> getFavoriteAlbergues() async {
    final db = await database;
    return db.transaction((txn) async {
      final query = _buildFavoriteAlberguesQuery();
      final result = await txn.rawQuery(query);
      return _mapFavoriteAlbergueResults(result);
    });
  }

  /// Get all favorites (including soft-deleted) for sync
  Future<List<Map<String, dynamic>>>
      getAllFavoritesForSync() async {
    final db = await database;
    return db.transaction((txn) async {
      return txn.query(
        'favorites_albergues',
        columns: ['albergue_id', 'updated_at', 'deleted_at'],
      );
    });
  }

  /// Merge server sync response with local favorites.
  ///
  /// [serverItems] is the canonical list from the server.
  /// [sentAlbergueIds] are the IDs that were part of the
  /// original sync request. Local items added after the
  /// request was sent are preserved.
  Future<void> replaceFavoritesFromSync(
    List<Map<String, dynamic>> serverItems,
    Set<int> sentAlbergueIds,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Delete rows that were part of the sync request.
      //    Server response is authoritative for these.
      for (final id in sentAlbergueIds) {
        await txn.delete(
          'favorites_albergues',
          where: 'albergue_id = ?',
          whereArgs: [id],
        );
      }

      // 2. Insert canonical list from server
      for (final item in serverItems) {
        final albergueId = item['albergue_id'] as int;
        final updatedAt = item['updated_at'] as String;

        // Look up city_id from albergues table
        final albergueRow = await txn.query(
          'albergues',
          columns: ['city_id'],
          where: 'id = ?',
          whereArgs: [albergueId],
          limit: 1,
        );

        if (albergueRow.isEmpty) continue;

        final cityId =
            albergueRow.first['city_id'] as int;

        // Look up route_id from city_routes
        final cityRouteRow = await txn.rawQuery(
          'SELECT route_id FROM city_routes '
          'WHERE city_id = ? LIMIT 1',
          [cityId],
        );
        final routeId = cityRouteRow.isNotEmpty
            ? cityRouteRow.first['route_id']
                    as int? ??
                0
            : 0;

        await txn.insert(
          'favorites_albergues',
          {
            'albergue_id': albergueId,
            'city_id': cityId,
            'route_id': routeId,
            'created_at': updatedAt,
            'updated_at': updatedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // 3. Local items not in sentAlbergueIds are
      //    untouched — they'll sync on the next cycle
    });
  }

  /// Build the favorites query with all joins
  String _buildFavoriteAlberguesQuery() {
    return '''
        SELECT DISTINCT
        a.id,
        a.order_key,
        a.name,
        a.slug,
        a.city_slug,
        a.status,
        a.is_municipal,
        a.is_albergue,
        a.address,
        a.postal_code,
        a.province,
        a.region,
        a.country,
        a.share_url,
        a.web,
        a.booking_com_url,
        a.dist_costa,
        a.dist_litoral,
        a.reserve_url,
        a.city_id,
        a.city_name,
        a.places_in_dormitory,
        a.number_of_dormitories,
        a.latitude,
        a.longitude,
        a.reservation_translation_id,
        a.open_season_translation_id,
        a.booking_price,
        a.booking_price_updated_at,
        f.id as facility_id,
        f.has_kitchen,
        f.has_cooktops,
        f.has_microwave,
        f.has_water_boiler,
        f.has_plates_utensils,
        f.has_cooking_pots,
        f.has_breakfast,
        f.is_breakfast_included,
        f.has_clothes_line,
        f.has_wifi,
        f.has_tv,
        f.has_restaurant,
        f.has_community_dinner,
        f.has_dinner,
        f.has_washing_machine,
        f.has_spin_dryer,
        f.has_hand_washing_sink,
        f.has_tumble_dryer,
        f.has_individual_powerplug,
        f.has_private_lockers,
        f.has_curtains,
        f.has_oven,
        f.has_vending_machine,
        f.has_full_laundry_service,
        f.has_fridge,
        f.has_lunch,
        f.has_vegetarian_option,
        f.has_swimming_pool,
        f.has_donativo_breakfast,
        f.has_cube_beds,
        f.has_community_lunch,
        f.is_vegetarian,
        f.is_vegan,
        f.is_organic,
        f.pets_allowed,
        f.has_vegan_option,
        f.has_cotton_sheets,
        f.is_dinner_included,
        p.id as price_id,
        p.price_from_dormitory,
        p.price_from_double_room,
        p.price_from_single_room,
        p.price_from_bed_shared_room,
        p.price_to_dormitory,
        p.price_to_double_room,
        p.price_to_single_room,
        p.price_to_quatro_room,
        p.price_from_apartment,
        p.price_to_apartment,
        p.price_from_triple_room,
        p.price_from_quatro_room,
        p.price_to_triple_room,
        p.price_to_bed_shared_room,
        o.id as operating_hours_id,
        o.checkin_time,
        o.checkout_time,
        o.close_time,
        o.open_from,
        o.open_from_ex,
        o.open_from_ex2,
        o.open_to,
        o.open_to_ex,
        o.open_to_ex2,
        o.opens,
        o.open_additional_information,
        o.unknown_open_season,
        o.opens_all_year,
        r.id as review_id,
        r.g_rating,
        r.b_review_score,
        r.b_id,
        e.id as email_id,
        e.albergue_id,
        e.email_address,
        ph.id AS phone_id,
        ph.albergue_id,
        ph.phone_number,
        ph.whatsapp,
        ph.private,
        ph.signal,
        sm.id AS social_media_id,
        sm.albergue_id,
        sm.facebook_url,
        sm.facebook_id,
        sm.instagram_handle,
        sm.messenger,
        fav.city_id AS fav_city_id,
        fav.route_id AS fav_route_id,
        ar.id AS albergue_rating_id,
        ar.rating AS ninja_rating,
        ar.total_approved_reviews AS number_of_reviews
        FROM favorites_albergues fav
        INNER JOIN albergues a ON fav.albergue_id = a.id
        LEFT JOIN albergue_facilities f ON a.id = f.albergue_id
        LEFT JOIN albergue_prices p ON a.id = p.albergue_id
        LEFT JOIN albergue_operating_hours o ON a.id = o.albergue_id
        LEFT JOIN albergue_reviews r ON a.id = r.albergue_id
        LEFT JOIN albergue_emails e ON a.id = e.albergue_id
        LEFT JOIN albergue_phones ph ON a.id = ph.albergue_id
        LEFT JOIN albergue_social_medias sm ON a.id = sm.albergue_id
        LEFT JOIN albergues_rating ar ON a.id = ar.albergue_id
        WHERE fav.deleted_at IS NULL
        ORDER BY fav.created_at DESC
        ''';
  }

  /// Map favorite albergue query results
  List<AlbergueEntity> _mapFavoriteAlbergueResults(
    List<Map<String, dynamic>> result,
  ) {
    final Map<int, AlbergueEntity> albergueMap = {};

    for (final row in result) {
      final albergueId = row['id'] as int;
      if (!albergueMap.containsKey(albergueId)) {
        albergueMap[albergueId] =
            AlbergueEntity.fromJson(row);
      }

      _addFavoriteNestedEntities(
        albergueMap[albergueId]!,
        row,
      );
    }

    return albergueMap.values.toList();
  }

  /// Add nested entities for favorite albergue
  void _addFavoriteNestedEntities(
    AlbergueEntity albergue,
    Map<String, dynamic> row,
  ) {
    if (row['facility_id'] != null) {
      final facility = FacilityEntity.fromJson(row);
      albergue.facilities.add(facility);
    }
    if (row['price_id'] != null) {
      final price = PriceEntity.fromJson(row);
      albergue.prices.add(price);
    }
    if (row['operating_hours_id'] != null) {
      final operatingHours =
          OperatingHoursEntity.fromJson(row);
      albergue.operatingHours.add(operatingHours);
    }
    if (row['review_id'] != null) {
      final review = ReviewEntity.fromJson(row);
      albergue.reviews.add(review);
    }
    if (row['email_id'] != null) {
      final email = EmailEntity.fromJson(row);
      if (albergue.emails
          .where(
            (e) => e.emailAddress == email.emailAddress,
          )
          .isEmpty) {
        albergue.emails.add(email);
      }
    }
    if (row['phone_id'] != null) {
      final phone = PhoneEntity.fromJson(row);
      if (albergue.phones
          .where(
            (p) => p.phoneNumber == phone.phoneNumber,
          )
          .isEmpty) {
        albergue.phones.add(phone);
      }
    }
    if (row['social_media_id'] != null) {
      final socialMedia = SocialMediaEntity.fromJson(row);
      albergue.socialMedias.add(socialMedia);
    }
    if (row['fav_city_id'] != null) {
      albergue.externalCityId =
          int.tryParse(row['fav_city_id'].toString());
    }
    if (row['fav_route_id'] != null) {
      albergue.externalRouteId =
          int.tryParse(row['fav_route_id'].toString());
    }

    // Set rating data
    albergue.ninjaRating =
        double.tryParse(row['ninja_rating'].toString());
    albergue.numberOfReviews =
        int.tryParse(row['number_of_reviews'].toString());
  }
}
