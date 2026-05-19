part of 'app_database.dart';

/// Top-level package-private helper: create all app database tables.
///
/// Single source of truth shared between the [AppDatabaseSchema]
/// extension on [AppDatabase] and the standalone
/// [appDatabaseDropAndRecreate] helper used by tests + the
/// destructive `oldVersion < 7` upgrade branch.
void _createAppDatabaseTables(Batch batch) {
  batch.execute('''
        CREATE TABLE IF NOT EXISTS latest_data_updated (
          id INTEGER PRIMARY KEY,
          albergues_updated_at TEXT,
          albergue_user_images_updated_at TEXT,
          cities_updated_at TEXT,
          routes_updated_at TEXT,
          route_points_updated_at TEXT,
          alt_route_points_updated_at TEXT
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS routes (
          id INTEGER PRIMARY KEY,
          order_key INTEGER NOT NULL,
          route_name TEXT,
          route_sub_name TEXT,
          legend_color TEXT,
          light_legend_color TEXT,
          dark_legend_color TEXT
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS route_points (
          id INTEGER PRIMARY KEY,
          order_key INTEGER NOT NULL,
          elevation REAL,
          route_id INTEGER,
          latitude REAL,
          longitude REAL,
          FOREIGN KEY (route_id) REFERENCES routes(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS cities (
          id INTEGER PRIMARY KEY,
          order_key INTEGER NOT NULL,
          name TEXT,
          country TEXT,
          region TEXT,
          province TEXT,
          slug TEXT,
          km REAL,
          has_atm INTEGER,
          has_bar_cafe INTEGER,
          has_shop INTEGER,
          has_med_clinic INTEGER,
          has_pharmacy INTEGER,
          has_fountain INTEGER,
          has_post_office INTEGER,
          has_train_station INTEGER,
          etape_city INTEGER,
          share_url TEXT,
          search TEXT,
          b_city_id TEXT,
          openweathermap_id TEXT,
          notes_translation_id TEXT,
          has_tobacco_store INTEGER,
          has_airport INTEGER,
          has_bus_station INTEGER,
          has_restaurant INTEGER,
          has_albergues INTEGER,
          latitude REAL,
          longitude REAL
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS city_routes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          city_id INTEGER NOT NULL,
          route_id INTEGER NOT NULL,
          FOREIGN KEY (city_id) REFERENCES cities(id),
          FOREIGN KEY (route_id) REFERENCES routes(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS city_route_points (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          city_id INTEGER NOT NULL,
          route_point_id INTEGER NOT NULL,
          FOREIGN KEY (city_id) REFERENCES cities(id),
          FOREIGN KEY (route_point_id) REFERENCES route_points(id)
        )
      ''');

  _createAppDatabaseAlbergueTables(batch);
  _createAppDatabaseAltRoutePointsTables(batch);
  _createAppDatabaseAnnouncementsTable(batch);
}

void _createAppDatabaseAlbergueTables(Batch batch) {
  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergues (
          id INTEGER PRIMARY KEY,
          order_key INTEGER,
          name TEXT,
          slug TEXT,
          city_slug TEXT,
          status INTEGER,
          is_municipal INTEGER,
          is_albergue INTEGER,
          address TEXT,
          postal_code TEXT,
          province TEXT,
          region TEXT,
          country TEXT,
          share_url TEXT,
          web TEXT,
          booking_com_url TEXT,
          dist_costa INTEGER,
          dist_litoral INTEGER,
          reserve_url TEXT,
          city_id INTEGER,
          city_name TEXT,
          places_in_dormitory INTEGER,
          number_of_dormitories INTEGER,
          latitude REAL,
          longitude REAL,
          reservation_translation_id INTEGER,
          open_season_translation_id INTEGER,
          booking_price REAL,
          booking_price_updated_at TEXT,
          FOREIGN KEY (city_id) REFERENCES cities(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergue_facilities (
          id INTEGER PRIMARY KEY,
          has_kitchen INTEGER,
          has_cooktops INTEGER,
          has_microwave INTEGER,
          has_water_boiler INTEGER,
          has_plates_utensils INTEGER,
          has_cooking_pots INTEGER,
          has_breakfast INTEGER,
          is_breakfast_included INTEGER,
          has_clothes_line INTEGER,
          has_wifi INTEGER,
          has_tv INTEGER,
          has_restaurant INTEGER,
          has_community_dinner INTEGER,
          has_dinner INTEGER,
          has_washing_machine INTEGER,
          has_spin_dryer INTEGER,
          has_hand_washing_sink INTEGER,
          has_tumble_dryer INTEGER,
          has_individual_powerplug INTEGER,
          has_private_lockers INTEGER,
          has_curtains INTEGER,
          has_oven INTEGER,
          has_vending_machine INTEGER,
          has_full_laundry_service INTEGER,
          has_fridge INTEGER,
          has_lunch INTEGER,
          has_vegetarian_option INTEGER,
          has_swimming_pool INTEGER,
          has_donativo_breakfast INTEGER,
          has_cube_beds INTEGER,
          has_community_lunch INTEGER,
          is_vegetarian INTEGER,
          is_vegan INTEGER,
          is_organic INTEGER,
          pets_allowed INTEGER,
          albergue_id INTEGER,
          has_vegan_option INTEGER,
          has_cotton_sheets INTEGER,
          is_dinner_included INTEGER,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergue_images (
          id INTEGER PRIMARY KEY,
          albergue_id INTEGER NOT NULL,
          file_name TEXT,
          title TEXT,
          type TEXT,
          width INTEGER,
          height INTEGER,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergue_user_images (
          id INTEGER PRIMARY KEY,
          albergue_id INTEGER NOT NULL,
          file_name TEXT,
          title TEXT,
          type TEXT,
          width INTEGER,
          height INTEGER,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergue_phones (
          id INTEGER PRIMARY KEY,
          albergue_id INTEGER NOT NULL,
          phone_number TEXT,
          whatsapp INTEGER,
          private INTEGER,
          signal INTEGER,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergue_emails (
          id INTEGER PRIMARY KEY,
          albergue_id INTEGER NOT NULL,
          email_address TEXT,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergue_social_medias (
          id INTEGER PRIMARY KEY,
          albergue_id INTEGER NOT NULL,
          facebook_url TEXT,
          facebook_id TEXT,
          instagram_handle TEXT,
          messenger TEXT,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergue_operating_hours (
          id INTEGER PRIMARY KEY,
          albergue_id INTEGER NOT NULL,
          checkin_time TEXT,
          checkout_time TEXT,
          close_time TEXT,
          open_from TEXT,
          open_from_ex TEXT,
          open_from_ex2 TEXT,
          open_to TEXT,
          open_to_ex TEXT,
          open_to_ex2 TEXT,
          opens TEXT,
          open_additional_information TEXT,
          unknown_open_season INTEGER,
          opens_all_year INTEGER,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergue_prices (
          id INTEGER PRIMARY KEY,
          albergue_id INTEGER NOT NULL,
          price_from_dormitory REAL,
          price_from_double_room REAL,
          price_from_single_room REAL,
          price_from_bed_shared_room REAL,
          price_to_dormitory REAL,
          price_to_double_room REAL,
          price_to_single_room REAL,
          price_to_quatro_room REAL,
          price_from_apartment REAL,
          price_to_apartment REAL,
          price_from_triple_room REAL,
          price_from_quatro_room REAL,
          price_to_triple_room REAL,
          price_to_bed_shared_room REAL,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergue_reviews (
          id INTEGER PRIMARY KEY,
          albergue_id INTEGER NOT NULL,
          g_rating REAL,
          b_review_score REAL,
          b_id INTEGER,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS albergue_wifis (
          id INTEGER PRIMARY KEY,
          albergue_id INTEGER NOT NULL,
          name TEXT,
          url TEXT,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id)
        )
      ''');
}

void _createAppDatabaseAnnouncementsTable(Batch batch) {
  batch.execute('''
        CREATE TABLE IF NOT EXISTS announcements (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          content TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          deleted_at TEXT
        )
      ''');
}

void _createAppDatabaseAltRoutePointsTables(Batch batch) {
  batch.execute('''
        CREATE TABLE IF NOT EXISTS alt_route_points (
          id INTEGER PRIMARY KEY,
          order_key INTEGER NOT NULL,
          color TEXT,
          dotted INTEGER,
          route_id INTEGER,
          FOREIGN KEY (route_id) REFERENCES routes(id)
        )
      ''');

  batch.execute('''
        CREATE TABLE IF NOT EXISTS alt_route_points_values (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_key INTEGER NOT NULL,
          alt_route_points_id INTEGER,
          latitude REAL,
          longitude REAL,
          FOREIGN KEY (alt_route_points_id) REFERENCES alt_route_points(id)
        )
      ''');
}

/// Top-level package-private helper: create all app database indexes.
///
/// Single source of truth shared between the [AppDatabaseSchema]
/// extension on [AppDatabase] and [appDatabaseDropAndRecreate].
void _createAppDatabaseIndexes(Batch batch) {
  // Route Points Indexes
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_route_points_route_id ON route_points(route_id);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_route_points_order_key ON route_points(order_key);');

  // Cities Indexes
  batch.execute('CREATE INDEX IF NOT EXISTS idx_cities_id ON cities(id)');
  batch
      .execute('CREATE INDEX IF NOT EXISTS idx_cities_slug ON cities(slug);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_cities_order_key ON cities(order_key);');

  // Albergues Indexes
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_albergues_city_id ON albergues(city_id);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_albergues_slug ON albergues(slug);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_albergues_order_key ON albergues(order_key);');

  // Alt Route Points Indexes
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_alt_route_points_route_id ON alt_route_points(route_id);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_alt_route_points_order_key ON alt_route_points(order_key);');

  // Alt Route Points Values Indexes
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_alt_route_points_values_alt_route_points_id ON alt_route_points_values(alt_route_points_id);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_alt_route_points_values_order_key ON alt_route_points_values(order_key);');

  // Related Tables Indexes
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_albergue_facilities_albergue_id ON albergue_facilities(albergue_id);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_albergue_images_albergue_id ON albergue_images(albergue_id);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_albergue_phones_albergue_id ON albergue_phones(albergue_id);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_albergue_emails_albergue_id ON albergue_emails(albergue_id);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_albergue_social_medias_albergue_id ON albergue_social_medias(albergue_id);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_albergue_operating_hours_albergue_id ON albergue_operating_hours(albergue_id);');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_albergue_reviews_albergue_id ON albergue_reviews(albergue_id);');

  // Junction tables indexes
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_city_routes_city_id ON city_routes(city_id)');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_city_routes_route_id ON city_routes(route_id)');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_city_route_points_city_id ON city_route_points(city_id)');
  batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_city_route_points_route_point_id ON city_route_points(route_point_id)');
}

/// Schema definitions for AppDatabase - Tables and Indexes
extension AppDatabaseSchema on AppDatabase {
  /// Create all database tables.
  ///
  /// Thin delegate to the top-level [_createAppDatabaseTables] helper
  /// so the schema is defined exactly once for both production
  /// (via this extension) and tests + destructive recreate (via the
  /// top-level helper).
  void createTables(Batch batch) => _createAppDatabaseTables(batch);

  /// Create all database indexes.
  ///
  /// Thin delegate to the top-level [_createAppDatabaseIndexes].
  void createIndexes(Batch batch) => _createAppDatabaseIndexes(batch);
}
