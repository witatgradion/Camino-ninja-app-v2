part of 'app_database.dart';

/// Albergue operations for AppDatabase
extension AppDatabaseAlbergues on AppDatabase {
  /// Get all images for an albergue (from both albergue_images and user images)
  Future<List<ImageEntity>> getAllAlbergueImages({
    required int albergueId,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.rawQuery('''
      SELECT 
        id,albergue_id,file_name,title,type,width,height,
        'albergue' as source FROM albergue_images 
      WHERE albergue_id = ?
      UNION ALL
      SELECT 
        id,albergue_id,file_name,title,type,width,height,
        'user' as source
      FROM albergue_user_images 
      WHERE albergue_id = ?
      ''', [albergueId, albergueId]);
      return result.map(ImageEntity.fromJson).toList();
    });
  }

  /// Get albergues with all nested objects (facilities, prices, etc.)
  Future<List<AlbergueEntity>> getAlberguesWithNestedObjects({
    int? albergueId,
    int? cityId,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final query = _buildAlbergueQuery(albergueId: albergueId, cityId: cityId);
      final arguments = <dynamic>[];
      if (albergueId != null) {
        arguments.add(albergueId);
      } else if (cityId != null) {
        arguments.add(cityId);
      }

      final result = await txn.rawQuery(query, arguments);
      return _mapAlbergueResults(result);
    });
  }

  /// Same as [getAlberguesWithNestedObjects] but for many albergue IDs in one query.
  Future<List<AlbergueEntity>> getAlberguesWithNestedObjectsByIds(
    List<int> albergueIds,
  ) async {
    if (albergueIds.isEmpty) return [];
    final db = await database;
    return db.transaction((txn) async {
      final uniqueIds = albergueIds.toSet().toList();
      final placeholders = List.filled(uniqueIds.length, '?').join(',');
      final query =
          '${_buildAlbergueQuery(albergueId: null, cityId: null)} WHERE a.id IN ($placeholders)';
      final result = await txn.rawQuery(query, uniqueIds);
      return _mapAlbergueResults(result);
    });
  }

  /// Build the complex albergue query with all joins
  String _buildAlbergueQuery({int? albergueId, int? cityId}) {
    var query = '''
        SELECT a.*,
        f.id AS facility_id,
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
        f.albergue_id,
        f.has_vegan_option,
        f.has_cotton_sheets,
        f.is_dinner_included,
        p.id AS price_id,
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
        o.id AS operating_hours_id,
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
        r.id AS review_id,
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
        sm.messenger TEXT,
        ar.id AS albergue_rating_id,
        ar.rating AS ninja_rating,
        ar.total_approved_reviews AS number_of_reviews
        FROM albergues a 
        LEFT JOIN albergue_facilities f ON a.id = f.albergue_id 
        LEFT JOIN albergue_prices p ON a.id = p.albergue_id 
        LEFT JOIN albergue_operating_hours o ON a.id = o.albergue_id
        LEFT JOIN albergue_reviews r ON a.id = r.albergue_id
        LEFT JOIN albergue_emails e ON a.id = e.albergue_id
        LEFT JOIN albergue_phones ph ON a.id = ph.albergue_id  
        LEFT JOIN albergue_social_medias sm ON a.id = sm.albergue_id
        LEFT JOIN albergues_rating ar ON a.id = ar.albergue_id
        ''';

    if (albergueId != null) {
      query += ' WHERE a.id = ?';
    } else if (cityId != null) {
      query += ' WHERE a.city_id = ?';
    }

    return query;
  }

  /// Map raw query results to AlbergueEntity objects
  List<AlbergueEntity> _mapAlbergueResults(List<Map<String, dynamic>> result) {
    final Map<int, AlbergueEntity> albergueMap = {};

    for (final row in result) {
      final albergueId = row['id'] as int;
      if (!albergueMap.containsKey(albergueId)) {
        albergueMap[albergueId] = AlbergueEntity.fromJson(row);
      }

      _addNestedEntities(albergueMap[albergueId]!, row);
    }

    return albergueMap.values.toList();
  }

  /// Add nested entities to an albergue from a query row
  void _addNestedEntities(AlbergueEntity albergue, Map<String, dynamic> row) {
    if (row['facility_id'] != null) {
      final facility = FacilityEntity.fromJson(row);
      albergue.facilities.add(facility);
    }
    if (row['price_id'] != null) {
      final price = PriceEntity.fromJson(row);
      albergue.prices.add(price);
    }
    if (row['operating_hours_id'] != null) {
      final operatingHours = OperatingHoursEntity.fromJson(row);
      albergue.operatingHours.add(operatingHours);
    }
    if (row['review_id'] != null) {
      final review = ReviewEntity.fromJson(row);
      albergue.reviews.add(review);
    }
    if (row['email_id'] != null) {
      final email = EmailEntity.fromJson(row);
      if (albergue.emails
          .where((e) => e.emailAddress == email.emailAddress)
          .isEmpty) {
        albergue.emails.add(email);
      }
    }
    if (row['phone_id'] != null) {
      final phone = PhoneEntity.fromJson(row);
      if (albergue.phones
          .where((p) => p.phoneNumber == phone.phoneNumber)
          .isEmpty) {
        albergue.phones.add(phone);
      }
    }
    if (row['social_media_id'] != null) {
      final socialMedia = SocialMediaEntity.fromJson(row);
      albergue.socialMedias.add(socialMedia);
    }

    // Set rating data from albergues_rating table
    albergue.ninjaRating = double.tryParse(row['ninja_rating'].toString());
    albergue.numberOfReviews =
        int.tryParse(row['number_of_reviews'].toString());
  }

  /// [city_id] from [albergues] row, if any.
  Future<int?> getCityIdForAlbergue(int albergueId) async {
    final db = await database;
    final rows = await db.query(
      'albergues',
      columns: ['city_id'],
      where: 'id = ?',
      whereArgs: [albergueId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['city_id'];
    if (raw == null) return null;
    final id = raw is int ? raw : int.tryParse(raw.toString());
    if (id == null || id <= 0) return null;
    return id;
  }

  /// Check if albergue exists - wrapped in transaction to ensure fresh read
  Future<bool> albergueExists(int albergueId) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.query(
        'albergues',
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [albergueId],
        limit: 1,
      );
      return result.isNotEmpty;
    });
  }

  /// Batch fetch albergues by IDs - only basic albergue data, no nested objects
  Future<Map<int, AlbergueEntity>> getAlberguesByIds(
      List<int> albergueIds) async {
    if (albergueIds.isEmpty) return {};

    final db = await database;
    final uniqueIds = albergueIds.toSet().toList();
    final placeholders = List.filled(uniqueIds.length, '?').join(',');

    final result = await db.rawQuery('''
      SELECT * FROM albergues WHERE id IN ($placeholders)
    ''', uniqueIds);

    final Map<int, AlbergueEntity> albergueMap = {};
    for (final row in result) {
      final albergue = AlbergueEntity.fromJson(row);
      albergueMap[albergue.id] = albergue;
    }
    return albergueMap;
  }
}
