import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:storage/src/app_database.dart';
import 'package:storage/src/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AppDatabase', () {
    group('Singleton Pattern', () {
      test('factory returns singleton instance', () {
        final db1 = AppDatabase();
        final db2 = AppDatabase();

        expect(identical(db1, db2), isTrue);
      });

      test('multiple calls return same instance', () {
        final instances = List.generate(10, (_) => AppDatabase());

        for (var i = 1; i < instances.length; i++) {
          expect(identical(instances[0], instances[i]), isTrue);
        }
      });
    });

    group('Constants', () {
      test('CHUNK_SIZE is defined correctly', () {
        expect(AppDatabase.CHUNK_SIZE, equals(50));
      });

      test('CHUNK_SIZE is positive', () {
        expect(AppDatabase.CHUNK_SIZE, greaterThan(0));
      });

      test('CHUNK_SIZE is reasonable for batch operations', () {
        expect(AppDatabase.CHUNK_SIZE, greaterThanOrEqualTo(10));
        expect(AppDatabase.CHUNK_SIZE, lessThanOrEqualTo(1000));
      });
    });
  });

  group('AppDatabase Integration Tests', () {
    late Database testDb;

    setUp(() async {
      // Create in-memory database for testing
      testDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await _createTestTables(db);
          },
        ),
      );
    });

    tearDown(() async {
      await testDb.close();
    });

    group('Generic Operations', () {
      test('queryList returns all rows from table', () async {
        // Insert test data
        await testDb.insert('routes', {
          'id': 1,
          'order_key': 1,
          'route_name': 'Camino Frances',
        });
        await testDb.insert('routes', {
          'id': 2,
          'order_key': 2,
          'route_name': 'Camino Portuguese',
        });

        final result = await testDb.query('routes');

        expect(result.length, equals(2));
        expect(result[0]['route_name'], equals('Camino Frances'));
        expect(result[1]['route_name'], equals('Camino Portuguese'));
      });

      test('queryList returns empty list for empty table', () async {
        final result = await testDb.query('routes');
        expect(result, isEmpty);
      });

      test('insert adds a row to table', () async {
        await testDb.insert(
          'routes',
          {
            'id': 1,
            'order_key': 1,
            'route_name': 'Test Route',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final result = await testDb.query('routes');
        expect(result.length, equals(1));
        expect(result[0]['route_name'], equals('Test Route'));
      });

      test('insert with replace updates existing row', () async {
        await testDb.insert('routes', {
          'id': 1,
          'order_key': 1,
          'route_name': 'Original',
        });

        await testDb.insert(
          'routes',
          {
            'id': 1,
            'order_key': 1,
            'route_name': 'Updated',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final result = await testDb.query('routes');
        expect(result.length, equals(1));
        expect(result[0]['route_name'], equals('Updated'));
      });

      test('delete removes row by id', () async {
        await testDb.insert('routes', {
          'id': 1,
          'order_key': 1,
          'route_name': 'To Delete',
        });
        await testDb.insert('routes', {
          'id': 2,
          'order_key': 2,
          'route_name': 'To Keep',
        });

        await testDb.delete('routes', where: 'id = ?', whereArgs: [1]);

        final result = await testDb.query('routes');
        expect(result.length, equals(1));
        expect(result[0]['id'], equals(2));
      });

      test('bulkInsert adds multiple rows in batches', () async {
        final objects = List.generate(
          100,
          (i) => {
            'id': i + 1,
            'order_key': i + 1,
            'route_name': 'Route $i',
          },
        );

        final batch = testDb.batch();
        for (final obj in objects) {
          batch.insert('routes', obj, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);

        final result = await testDb.query('routes');
        expect(result.length, equals(100));
      });
    });

    group('Route Operations', () {
      setUp(() async {
        await testDb.insert('routes', {
          'id': 1,
          'order_key': 1,
          'route_name': 'Camino Frances',
          'route_sub_name': 'Main Route',
          'legend_color': '#FF0000',
        });
        await testDb.insert('routes', {
          'id': 2,
          'order_key': 2,
          'route_name': 'Camino Portuguese',
          'route_sub_name': null,
          'legend_color': '#00FF00',
        });
      });

      test('getRouteById returns route with correct id', () async {
        final result = await testDb.query(
          'routes',
          where: 'id = ?',
          whereArgs: [1],
        );

        expect(result.length, equals(1));
        final route = RouteEntity.fromJson(result.first);
        expect(route.id, equals(1));
        expect(route.routeName, equals('Camino Frances'));
      });

      test('getRouteById throws for non-existent route', () async {
        final result = await testDb.query(
          'routes',
          where: 'id = ?',
          whereArgs: [999],
        );

        expect(result, isEmpty);
      });
    });

    group('Route Point Operations', () {
      setUp(() async {
        await testDb.insert('routes', {
          'id': 1,
          'order_key': 1,
          'route_name': 'Test Route',
        });
        await testDb.insert('route_points', {
          'id': 1,
          'order_key': 1,
          'elevation': 100.5,
          'route_id': 1,
          'latitude': 42.8805,
          'longitude': -8.5456,
        });
        await testDb.insert('route_points', {
          'id': 2,
          'order_key': 2,
          'elevation': 150.0,
          'route_id': 1,
          'latitude': 42.8810,
          'longitude': -8.5450,
        });
        await testDb.insert('route_points', {
          'id': 3,
          'order_key': 1,
          'elevation': 200.0,
          'route_id': 2,
          'latitude': 43.0,
          'longitude': -8.0,
        });
      });

      test('getRoutePointsByRouteId returns points for route', () async {
        final result = await testDb.query(
          'route_points',
          where: 'route_id = ?',
          whereArgs: [1],
          orderBy: 'order_key ASC',
        );

        expect(result.length, equals(2));
        expect(result[0]['order_key'], equals(1));
        expect(result[1]['order_key'], equals(2));
      });

      test('getRoutePointsByRouteId returns empty for non-existent route', () async {
        final result = await testDb.query(
          'route_points',
          where: 'route_id = ?',
          whereArgs: [999],
        );

        expect(result, isEmpty);
      });

      test('route points are ordered by order_key', () async {
        await testDb.insert('route_points', {
          'id': 4,
          'order_key': 0,
          'elevation': 50.0,
          'route_id': 1,
          'latitude': 42.88,
          'longitude': -8.54,
        });

        final result = await testDb.query(
          'route_points',
          where: 'route_id = ?',
          whereArgs: [1],
          orderBy: 'order_key ASC',
        );

        expect(result.length, equals(3));
        expect(result[0]['order_key'], equals(0));
        expect(result[1]['order_key'], equals(1));
        expect(result[2]['order_key'], equals(2));
      });
    });

    group('City Operations', () {
      setUp(() async {
        await testDb.insert('routes', {
          'id': 1,
          'order_key': 1,
          'route_name': 'Test Route',
        });
        await testDb.insert('route_points', {
          'id': 1,
          'order_key': 1,
          'elevation': 100.0,
          'route_id': 1,
          'latitude': 42.88,
          'longitude': -8.54,
        });
        await testDb.insert('cities', {
          'id': 1,
          'order_key': 1,
          'name': 'Santiago',
          'has_albergues': 1,
        });
        await testDb.insert('cities', {
          'id': 2,
          'order_key': 2,
          'name': 'Sarria',
          'has_albergues': 1,
        });
        await testDb.insert('city_routes', {
          'city_id': 1,
          'route_id': 1,
        });
        await testDb.insert('city_routes', {
          'city_id': 2,
          'route_id': 1,
        });
        await testDb.insert('city_route_points', {
          'city_id': 1,
          'route_point_id': 1,
        });
      });

      test('getCitiesByRouteId returns cities for route', () async {
        final result = await testDb.rawQuery('''
          SELECT c.* FROM cities c
          INNER JOIN city_routes cr ON c.id = cr.city_id
          WHERE cr.route_id = ?
        ''', [1]);

        expect(result.length, equals(2));
      });

      test('getCityById returns city with correct id', () async {
        final result = await testDb.query(
          'cities',
          where: 'id = ?',
          whereArgs: [1],
        );

        expect(result.length, equals(1));
        expect(result[0]['name'], equals('Santiago'));
      });

      test('cityHasAlbergues returns true when city has albergues', () async {
        await testDb.insert('albergues', {
          'id': 1,
          'order_key': 1,
          'name': 'Test Albergue',
          'city_id': 1,
        });

        final result = await testDb.query(
          'albergues',
          where: 'city_id = ?',
          whereArgs: [1],
          limit: 1,
        );

        expect(result.isNotEmpty, isTrue);
      });

      test('cityHasAlbergues returns false when city has no albergues', () async {
        final result = await testDb.query(
          'albergues',
          where: 'city_id = ?',
          whereArgs: [1],
          limit: 1,
        );

        expect(result.isEmpty, isTrue);
      });
    });

    group('Albergue Operations', () {
      setUp(() async {
        await testDb.insert('cities', {
          'id': 1,
          'order_key': 1,
          'name': 'Santiago',
          'has_albergues': 1,
        });
        await testDb.insert('albergues', {
          'id': 1,
          'order_key': 1,
          'name': 'Albergue Test',
          'city_id': 1,
          'latitude': 42.88,
          'longitude': -8.54,
        });
        await testDb.insert('albergue_images', {
          'id': 1,
          'albergue_id': 1,
          'file_name': 'image1.jpg',
          'title': 'Main Image',
          'type': 'jpg',
          'width': 800,
          'height': 600,
        });
        await testDb.insert('albergue_user_images', {
          'id': 2,
          'albergue_id': 1,
          'file_name': 'user_image1.jpg',
          'title': 'User Image',
          'type': 'jpg',
          'width': 640,
          'height': 480,
        });
        await testDb.insert('albergue_facilities', {
          'id': 1,
          'albergue_id': 1,
          'has_wifi': 1,
          'has_kitchen': 1,
        });
      });

      test('getAllAlbergueImages returns both albergue and user images', () async {
        final result = await testDb.rawQuery('''
          SELECT id, albergue_id, file_name, title, type, width, height, 'albergue' as source 
          FROM albergue_images WHERE albergue_id = ?
          UNION ALL
          SELECT id, albergue_id, file_name, title, type, width, height, 'user' as source 
          FROM albergue_user_images WHERE albergue_id = ?
        ''', [1, 1]);

        expect(result.length, equals(2));
        expect(result.any((r) => r['source'] == 'albergue'), isTrue);
        expect(result.any((r) => r['source'] == 'user'), isTrue);
      });

      test('getAlberguesWithNestedObjects returns albergue with facilities', () async {
        final result = await testDb.rawQuery('''
          SELECT a.*, f.id as facility_id, f.has_wifi, f.has_kitchen
          FROM albergues a
          LEFT JOIN albergue_facilities f ON a.id = f.albergue_id
          WHERE a.id = ?
        ''', [1]);

        expect(result.length, equals(1));
        expect(result[0]['facility_id'], equals(1));
        expect(result[0]['has_wifi'], equals(1));
      });

      test('getAlberguesByCityId returns albergues for city', () async {
        await testDb.insert('albergues', {
          'id': 2,
          'order_key': 2,
          'name': 'Albergue 2',
          'city_id': 1,
        });

        final result = await testDb.query(
          'albergues',
          where: 'city_id = ?',
          whereArgs: [1],
        );

        expect(result.length, equals(2));
      });
    });

    group('Favorites Operations', () {
      setUp(() async {
        await testDb.insert('routes', {
          'id': 1,
          'order_key': 1,
          'route_name': 'Test Route',
        });
        await testDb.insert('cities', {
          'id': 1,
          'order_key': 1,
          'name': 'Santiago',
          'has_albergues': 1,
        });
        await testDb.insert('albergues', {
          'id': 1,
          'order_key': 1,
          'name': 'Favorite Albergue',
          'city_id': 1,
        });
      });

      test('addFavoriteAlbergue adds albergue to favorites', () async {
        await testDb.insert('favorites_albergues', {
          'albergue_id': 1,
          'city_id': 1,
          'route_id': 1,
          'created_at': DateTime.now().toIso8601String(),
        });

        final result = await testDb.query('favorites_albergues');
        expect(result.length, equals(1));
        expect(result[0]['albergue_id'], equals(1));
      });

      test('removeFavoriteAlbergue removes albergue from favorites', () async {
        await testDb.insert('favorites_albergues', {
          'albergue_id': 1,
          'city_id': 1,
          'route_id': 1,
          'created_at': DateTime.now().toIso8601String(),
        });

        await testDb.delete(
          'favorites_albergues',
          where: 'albergue_id = ? AND route_id = ? AND city_id = ?',
          whereArgs: [1, 1, 1],
        );

        final result = await testDb.query('favorites_albergues');
        expect(result, isEmpty);
      });

      test('isFavoriteAlbergue returns true for favorite', () async {
        await testDb.insert('favorites_albergues', {
          'albergue_id': 1,
          'city_id': 1,
          'route_id': 1,
          'created_at': DateTime.now().toIso8601String(),
        });

        final result = await testDb.query(
          'favorites_albergues',
          where: 'albergue_id = ? AND route_id = ? AND city_id = ?',
          whereArgs: [1, 1, 1],
          limit: 1,
        );

        expect(result.isNotEmpty, isTrue);
      });

      test('isFavoriteAlbergue returns false for non-favorite', () async {
        final result = await testDb.query(
          'favorites_albergues',
          where: 'albergue_id = ? AND route_id = ? AND city_id = ?',
          whereArgs: [1, 1, 1],
          limit: 1,
        );

        expect(result.isEmpty, isTrue);
      });

      test('getFavoriteAlbergueIds returns list of ids', () async {
        await testDb.insert('favorites_albergues', {
          'albergue_id': 1,
          'city_id': 1,
          'route_id': 1,
          'created_at': DateTime.now().toIso8601String(),
        });
        await testDb.insert('albergues', {
          'id': 2,
          'order_key': 2,
          'name': 'Albergue 2',
          'city_id': 1,
        });
        await testDb.insert('favorites_albergues', {
          'albergue_id': 2,
          'city_id': 1,
          'route_id': 1,
          'created_at': DateTime.now().toIso8601String(),
        });

        final result = await testDb.query(
          'favorites_albergues',
          columns: ['albergue_id'],
          orderBy: 'created_at DESC',
        );

        final ids = result.map((row) => row['albergue_id'] as int).toList();
        expect(ids.length, equals(2));
        expect(ids.contains(1), isTrue);
        expect(ids.contains(2), isTrue);
      });

      test('getFavoriteAlbergues returns albergues with details', () async {
        await testDb.insert('favorites_albergues', {
          'albergue_id': 1,
          'city_id': 1,
          'route_id': 1,
          'created_at': DateTime.now().toIso8601String(),
        });

        final result = await testDb.rawQuery('''
          SELECT a.*, fav.city_id as fav_city_id, fav.route_id as fav_route_id
          FROM favorites_albergues fav
          INNER JOIN albergues a ON fav.albergue_id = a.id
          ORDER BY fav.created_at DESC
        ''');

        expect(result.length, equals(1));
        expect(result[0]['name'], equals('Favorite Albergue'));
        expect(result[0]['fav_city_id'], equals(1));
        expect(result[0]['fav_route_id'], equals(1));
      });
    });

    group('Alt Route Point Operations', () {
      setUp(() async {
        await testDb.insert('routes', {
          'id': 1,
          'order_key': 1,
          'route_name': 'Test Route',
        });
        await testDb.insert('alt_route_points', {
          'id': 1,
          'order_key': 1,
          'route_id': 1,
          'name': 'Alt Route 1',
        });
        await testDb.insert('alt_route_points_values', {
          'id': 1,
          'order_key': 1,
          'alt_route_points_id': 1,
          'latitude': 42.88,
          'longitude': -8.54,
        });
        await testDb.insert('alt_route_points_values', {
          'id': 2,
          'order_key': 2,
          'alt_route_points_id': 1,
          'latitude': 42.89,
          'longitude': -8.55,
        });
      });

      test('getAltRoutePointsWithValues returns points with values', () async {
        final result = await testDb.rawQuery('''
          SELECT a.*, av.id as alt_route_points_value_id, av.order_key as value_order,
            av.latitude, av.longitude
          FROM alt_route_points a
          LEFT JOIN alt_route_points_values av ON a.id = av.alt_route_points_id
          WHERE a.route_id = ?
          ORDER BY a.order_key ASC
        ''', [1]);

        expect(result.length, equals(2));
        expect(result[0]['name'], equals('Alt Route 1'));
      });

      test('getAltRoutePointsWithValues returns empty for non-existent route', () async {
        final result = await testDb.rawQuery('''
          SELECT a.*, av.id as alt_route_points_value_id
          FROM alt_route_points a
          LEFT JOIN alt_route_points_values av ON a.id = av.alt_route_points_id
          WHERE a.route_id = ?
        ''', [999]);

        expect(result, isEmpty);
      });
    });

    group('Database Utilities', () {
      test('isDatabaseEmpty returns true for empty database', () async {
        final isEmpty = (await testDb.query('routes')).isEmpty &&
            (await testDb.query('cities')).isEmpty &&
            (await testDb.query('albergues')).isEmpty &&
            (await testDb.query('route_points')).isEmpty;

        expect(isEmpty, isTrue);
      });

      test('isDatabaseEmpty returns false when data exists', () async {
        await testDb.insert('routes', {
          'id': 1,
          'order_key': 1,
          'route_name': 'Test',
        });

        final isEmpty = (await testDb.query('routes')).isEmpty;
        expect(isEmpty, isFalse);
      });

      test('table existence check works correctly', () async {
        final result = await testDb.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          ['routes'],
        );

        expect(result.isNotEmpty, isTrue);
      });

      test('non-existent table check returns empty', () async {
        final result = await testDb.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          ['non_existent_table'],
        );

        expect(result.isEmpty, isTrue);
      });
    });

    group('Latest Data Update Operations', () {
      test('insert and query latest_data_updated', () async {
        final now = DateTime.now();
        await testDb.insert('latest_data_updated', {
          'id': 1,
          'routes_updated_at': now.toIso8601String(),
          'route_points_updated_at': now.toIso8601String(),
          'alt_route_points_updated_at': now.toIso8601String(),
          'cities_updated_at': now.toIso8601String(),
          'albergues_updated_at': now.toIso8601String(),
          'albergue_user_images_updated_at': now.toIso8601String(),
        });

        final result = await testDb.query('latest_data_updated');
        expect(result.length, equals(1));
        expect(result[0]['routes_updated_at'], equals(now.toIso8601String()));
      });

      test('update latest_data_updated replaces existing', () async {
        final oldTime = DateTime(2024, 1, 1);
        final newTime = DateTime(2024, 6, 1);

        await testDb.insert('latest_data_updated', {
          'id': 1,
          'routes_updated_at': oldTime.toIso8601String(),
        });

        await testDb.delete('latest_data_updated');
        await testDb.insert('latest_data_updated', {
          'id': 1,
          'routes_updated_at': newTime.toIso8601String(),
        });

        final result = await testDb.query('latest_data_updated');
        expect(result.length, equals(1));
        expect(result[0]['routes_updated_at'], equals(newTime.toIso8601String()));
      });
    });

    group('Albergue Rating Operations', () {
      setUp(() async {
        await testDb.insert('cities', {
          'id': 1,
          'order_key': 1,
          'name': 'Santiago',
          'has_albergues': 1,
        });
        await testDb.insert('albergues', {
          'id': 1,
          'order_key': 1,
          'name': 'Rated Albergue',
          'city_id': 1,
        });
      });

      test('insert and query albergue rating', () async {
        await testDb.insert('albergues_rating', {
          'id': 1,
          'albergue_id': 1,
          'rating': 4.5,
          'total_approved_reviews': 100,
        });

        final result = await testDb.query(
          'albergues_rating',
          where: 'albergue_id = ?',
          whereArgs: [1],
        );

        expect(result.length, equals(1));
        expect(result[0]['rating'], equals(4.5));
        expect(result[0]['total_approved_reviews'], equals(100));
      });

      test('join albergue with rating', () async {
        await testDb.insert('albergues_rating', {
          'id': 1,
          'albergue_id': 1,
          'rating': 4.5,
          'total_approved_reviews': 100,
        });

        final result = await testDb.rawQuery('''
          SELECT a.*, ar.rating as ninja_rating, ar.total_approved_reviews as number_of_reviews
          FROM albergues a
          LEFT JOIN albergues_rating ar ON a.id = ar.albergue_id
          WHERE a.id = ?
        ''', [1]);

        expect(result.length, equals(1));
        expect(result[0]['ninja_rating'], equals(4.5));
        expect(result[0]['number_of_reviews'], equals(100));
      });
    });

  });
}

/// Create test tables matching the app schema
Future<void> _createTestTables(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS routes (
      id INTEGER PRIMARY KEY,
      order_key INTEGER,
      route_name TEXT,
      route_sub_name TEXT,
      legend_color TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS route_points (
      id INTEGER PRIMARY KEY,
      order_key INTEGER,
      elevation REAL,
      route_id INTEGER,
      latitude REAL,
      longitude REAL
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS cities (
      id INTEGER PRIMARY KEY,
      order_key INTEGER,
      name TEXT,
      has_albergues INTEGER DEFAULT 0
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS city_routes (
      city_id INTEGER,
      route_id INTEGER,
      PRIMARY KEY (city_id, route_id)
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS city_route_points (
      city_id INTEGER,
      route_point_id INTEGER,
      PRIMARY KEY (city_id, route_point_id)
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS albergues (
      id INTEGER PRIMARY KEY,
      order_key INTEGER,
      name TEXT,
      city_id INTEGER,
      latitude REAL,
      longitude REAL
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS albergue_images (
      id INTEGER PRIMARY KEY,
      albergue_id INTEGER,
      file_name TEXT,
      title TEXT,
      type TEXT,
      width INTEGER,
      height INTEGER
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS albergue_user_images (
      id INTEGER PRIMARY KEY,
      albergue_id INTEGER,
      file_name TEXT,
      title TEXT,
      type TEXT,
      width INTEGER,
      height INTEGER
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS albergue_facilities (
      id INTEGER PRIMARY KEY,
      albergue_id INTEGER,
      has_wifi INTEGER,
      has_kitchen INTEGER
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS favorites_albergues (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      albergue_id INTEGER NOT NULL,
      city_id INTEGER NOT NULL,
      route_id INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      UNIQUE(albergue_id)
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS alt_route_points (
      id INTEGER PRIMARY KEY,
      order_key INTEGER,
      route_id INTEGER,
      name TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS alt_route_points_values (
      id INTEGER PRIMARY KEY,
      order_key INTEGER,
      alt_route_points_id INTEGER,
      latitude REAL,
      longitude REAL
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS latest_data_updated (
      id INTEGER PRIMARY KEY,
      routes_updated_at TEXT,
      route_points_updated_at TEXT,
      alt_route_points_updated_at TEXT,
      cities_updated_at TEXT,
      albergues_updated_at TEXT,
      albergue_user_images_updated_at TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS albergues_rating (
      id INTEGER PRIMARY KEY,
      albergue_id INTEGER NOT NULL,
      rating REAL NOT NULL,
      total_approved_reviews INTEGER NOT NULL,
      UNIQUE(albergue_id)
    )
  ''');
}
