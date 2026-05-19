import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:storage/src/app_config.dart';
import 'package:storage/src/models/models.dart';

part 'app_database_schema.dart';
part 'app_database_routes.dart';
part 'app_database_cities.dart';
part 'app_database_albergues.dart';
part 'app_database_favorites.dart';
part 'app_database_announcements.dart';

/// Current schema version for the main app database.
///
/// Exposed so tests and tooling can reopen the DB at this version
/// without duplicating the number.
const int appDatabaseVersion = 8;

/// Runs the non-destructive v7 -> v8 schema migration for the main
/// app database: adds light/dark legend color columns to `routes`.
///
/// Extracted so the migration test harness can exercise the exact
/// production code path.
Future<void> appDatabaseOnUpgrade(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  if (oldVersion < 8 && newVersion >= 8) {
    final hasLight = await _appDbColumnExists(
      db,
      'routes',
      'light_legend_color',
    );
    if (!hasLight) {
      await db.execute(
        'ALTER TABLE routes ADD COLUMN light_legend_color TEXT',
      );
    }
    final hasDark = await _appDbColumnExists(
      db,
      'routes',
      'dark_legend_color',
    );
    if (!hasDark) {
      await db.execute(
        'ALTER TABLE routes ADD COLUMN dark_legend_color TEXT',
      );
    }
  }
}

Future<bool> _appDbColumnExists(
  Database db,
  String tableName,
  String columnName,
) async {
  final result = await db.rawQuery('PRAGMA table_info($tableName)');
  for (final row in result) {
    if (row['name'] == columnName) return true;
  }
  return false;
}

/// Drops every app database table except `favorites_albergues` and
/// recreates them fresh at the current ([appDatabaseVersion]) schema.
///
/// Used by [AppDatabase._initDatabase] for any `oldVersion < 7`
/// upgrade path — those versions diverge from v8 in shape (not just
/// in column-add migrations) so a non-destructive migration is
/// infeasible. After this returns, the caller must seed the empty
/// tables (production: from the bundled asset; tests: from a fixture
/// or by leaving them empty).
///
/// `favorites_albergues` is preserved across the recreate so users
/// don't lose their saved accommodations on the upgrade. Tables not
/// built by [_createAppDatabaseTables] (currently `albergues_rating`,
/// lazily created by `_ensureAlberguesRatingTableExists` after
/// `_initDatabase` returns) are also implicitly preserved — do not
/// add them to the drop list without updating the migration tests.
///
/// Extracted so the migration test harness can exercise the exact
/// production code path.
Future<void> appDatabaseDropAndRecreate(Database db) async {
  await _dropAllAppDatabaseTables(db);
  final batch = db.batch();
  _createAppDatabaseTables(batch);
  _createAppDatabaseIndexes(batch);
  await batch.commit();
}

/// Drops all app database tables except `favorites_albergues`.
///
/// Package-private top-level helper so production and tests share a
/// single source of truth.
Future<void> _dropAllAppDatabaseTables(Database db) async {
  await db.execute('DROP TABLE IF EXISTS latest_data_updated');
  await db.execute('DROP TABLE IF EXISTS alt_route_points_values');
  await db.execute('DROP TABLE IF EXISTS alt_route_points');
  await db.execute('DROP TABLE IF EXISTS albergue_wifis');
  await db.execute('DROP TABLE IF EXISTS albergue_reviews');
  await db.execute('DROP TABLE IF EXISTS albergue_prices');
  await db.execute('DROP TABLE IF EXISTS albergue_operating_hours');
  await db.execute('DROP TABLE IF EXISTS albergue_social_medias');
  await db.execute('DROP TABLE IF EXISTS albergue_emails');
  await db.execute('DROP TABLE IF EXISTS albergue_phones');
  await db.execute('DROP TABLE IF EXISTS albergue_user_images');
  await db.execute('DROP TABLE IF EXISTS albergue_images');
  await db.execute('DROP TABLE IF EXISTS albergue_facilities');
  await db.execute('DROP TABLE IF EXISTS albergues');
  await db.execute('DROP TABLE IF EXISTS city_route_points');
  await db.execute('DROP TABLE IF EXISTS city_routes');
  await db.execute('DROP TABLE IF EXISTS cities');
  await db.execute('DROP TABLE IF EXISTS route_points');
  await db.execute('DROP TABLE IF EXISTS announcements');
  await db.execute('DROP TABLE IF EXISTS routes');
}

/// Database Helper - Core functionality
///
/// Operations are organized into extensions:
/// - [AppDatabaseSchema] - Table and index definitions
/// - [AppDatabaseRoutes] - Route and route point operations
/// - [AppDatabaseCities] - City operations
/// - [AppDatabaseAlbergues] - Albergue operations
/// - [AppDatabaseFavorites] - Favorites management
/// - [AppDatabaseAnnouncements] - Announcements cache
class AppDatabase {
  /// DatabaseHelper Factory
  factory AppDatabase() => _instance;

  AppDatabase._internal();

  /// Bulk insert chunk size
  static const int CHUNK_SIZE = 50;

  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;
  static Completer<Database>? _initCompleter;

  /// Close and reset the database instance
  Future<void> closeDatabase() async {
    final completer = _initCompleter;
    _initCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(
        StateError('Database closed during initialization'),
      );
    }
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    _database = null;
  }

  /// Database instance getter
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    if (_initCompleter != null) return _initCompleter!.future;

    final completer = Completer<Database>();
    _initCompleter = completer;

    try {
      _database = await _initDatabase();
      completer.complete(_database!);
      return _database!;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _initCompleter = null;
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA cache_size = -8000');
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'camino_database.db');

    Database db;
    try {
      db = await openDatabase(
        path,
        version: 8,
        onConfigure: _onConfigure,
        onCreate: (Database db, int version) async {
          var batch = db.batch();
          createTables(batch);
          createIndexes(batch);
          await batch.commit();
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 7) {
            await appDatabaseDropAndRecreate(db);
          }
          await appDatabaseOnUpgrade(db, oldVersion, newVersion);
        },
        onDowngrade: onDatabaseDowngradeDelete,
      );
    } on DatabaseException catch (e) {
      AppLogger.e(
        'Failed to open database, deleting corrupt file and '
        're-seeding',
        tag: 'AppDatabase',
        error: e,
      );
      try {
        await deleteDatabase(path);
      } catch (_) {}
      return _seedDatabase(path);
    }

    if (await isDatabaseEmpty(db)) {
      return _seedDatabase(path, db: db);
    } else {
      AppLogger.d('Database is not empty, no seeding needed',
          tag: 'AppDatabase');
    }

    await _ensureAlberguesRatingTableExists(db);
    await _ensureFavoritesTableExists(db);

    return db;
  }

  /// Drop all tables except favorites
  ///
  /// Thin wrapper kept so `_createFallbackDatabase` (and any future
  /// in-class callers) keep their existing call sites. Delegates to
  /// the top-level [_dropAllAppDatabaseTables] which is the single
  /// source of truth shared with [appDatabaseDropAndRecreate].
  Future<void> _dropAllTables(Database db) =>
      _dropAllAppDatabaseTables(db);

  /// Seed database from asset
  Future<Database> _seedDatabase(String path, {Database? db}) async {
    AppLogger.i('Database is empty, seeding data...', tag: 'AppDatabase');
    try {
      if (db != null && db.isOpen) {
        await db.close();
      }
      await deleteDatabase(path);

      await Directory(dirname(path)).create(recursive: true);
      ByteData data = await rootBundle.load(AppConfig.seedDatabasePath);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);

      final seededDb = await openDatabase(
        path,
        version: 8,
        onConfigure: _onConfigure,
        onCreate: (Database db, int version) async {
          var batch = db.batch();
          createTables(batch);
          createIndexes(batch);
          await batch.commit();
        },
        onUpgrade: appDatabaseOnUpgrade,
        onDowngrade: onDatabaseDowngradeDelete,
      );

      if (await isDatabaseEmpty(seededDb)) {
        AppLogger.e('Database is still empty after seeding',
            tag: 'AppDatabase');
        throw Exception('Failed to seed database');
      }

      AppLogger.i('Database seeded successfully', tag: 'AppDatabase');
      await _ensureAlberguesRatingTableExists(seededDb);
      await _ensureFavoritesTableExists(seededDb);
      return seededDb;
    } catch (e) {
      AppLogger.e('Error seeding empty database', tag: 'AppDatabase', error: e);
      return _createFallbackDatabase(path);
    }
  }

  /// Create a fallback database when seeding fails
  Future<Database> _createFallbackDatabase(String path) async {
    final fallbackDb = await openDatabase(
      path,
      version: 8,
      onConfigure: _onConfigure,
      onCreate: (Database db, int version) async {
        var batch = db.batch();
        createTables(batch);
        createIndexes(batch);
        await batch.commit();
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        await _dropAllTables(db);
        var batch = db.batch();
        createTables(batch);
        createIndexes(batch);
        await batch.commit();
      },
      onDowngrade: onDatabaseDowngradeDelete,
    );

    await _ensureAlberguesRatingTableExists(fallbackDb);
    await _ensureFavoritesTableExists(fallbackDb);
    return fallbackDb;
  }

  /// Updates query planner statistics after bulk syncs for better performance.
  Future<void> analyze() async {
    final db = await database;
    await db.execute('ANALYZE');
  }

  // ==========================================================================
  // Table Management
  // ==========================================================================

  /// Ensure favorites table exists with correct schema
  Future<void> _ensureFavoritesTableExists(Database db) async {
    final tableExists = await _tableExists(db, 'favorites_albergues');

    if (!tableExists) {
      await db.execute('''
        CREATE TABLE favorites_albergues (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          albergue_id INTEGER NOT NULL,
          city_id INTEGER NOT NULL,
          route_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          deleted_at TEXT,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id),
          UNIQUE(albergue_id)
        )
      ''');
    } else {
      final hasRouteId =
          await _columnExists(db, 'favorites_albergues', 'route_id');
      final hasCityId =
          await _columnExists(db, 'favorites_albergues', 'city_id');

      if (!hasRouteId || !hasCityId) {
        AppLogger.i(
          'Recreating favorites_albergues table with new schema...',
          tag: 'AppDatabase',
        );
        await db.execute('DROP TABLE favorites_albergues');
        await db.execute('''
          CREATE TABLE favorites_albergues (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            albergue_id INTEGER NOT NULL,
            city_id INTEGER NOT NULL,
            route_id INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT,
            deleted_at TEXT,
            FOREIGN KEY (albergue_id) REFERENCES albergues(id),
            UNIQUE(albergue_id)
          )
        ''');
        AppLogger.i(
          'Successfully recreated favorites_albergues table',
          tag: 'AppDatabase',
        );
      }

      // Add sync columns if missing
      final hasUpdatedAt = await _columnExists(
        db,
        'favorites_albergues',
        'updated_at',
      );
      if (!hasUpdatedAt) {
        AppLogger.i(
          'Adding updated_at column to favorites_albergues',
          tag: 'AppDatabase',
        );
        await db.execute(
          'ALTER TABLE favorites_albergues '
          'ADD COLUMN updated_at TEXT',
        );
        await db.execute(
          'UPDATE favorites_albergues '
          'SET updated_at = created_at '
          'WHERE updated_at IS NULL',
        );
      }
      final hasDeletedAt = await _columnExists(
        db,
        'favorites_albergues',
        'deleted_at',
      );
      if (!hasDeletedAt) {
        AppLogger.i(
          'Adding deleted_at column to favorites_albergues',
          tag: 'AppDatabase',
        );
        await db.execute(
          'ALTER TABLE favorites_albergues '
          'ADD COLUMN deleted_at TEXT',
        );
      }
    }

    // Create indexes
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_favorites_albergues_albergue_id ON favorites_albergues(albergue_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_favorites_albergues_created_at ON favorites_albergues(created_at)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_favorites_albergues_city_id ON favorites_albergues(city_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_favorites_albergues_route_id ON favorites_albergues(route_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_favorites_albergues_deleted_at ON favorites_albergues(deleted_at)');
  }

  /// Ensure albergues rating table exists
  Future<void> _ensureAlberguesRatingTableExists(Database db) async {
    final tableExists = await _tableExists(db, 'albergues_rating');

    if (!tableExists) {
      await db.execute('''
        CREATE TABLE albergues_rating (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          albergue_id INTEGER NOT NULL,
          rating REAL NOT NULL,
          total_approved_reviews INTEGER NOT NULL,
          FOREIGN KEY (albergue_id) REFERENCES albergues(id),
          UNIQUE(albergue_id)
        )
      ''');

      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_albergues_rating_albergue_id ON albergues_rating(albergue_id)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_albergues_rating_rating ON albergues_rating(rating)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_albergues_rating_total_approved_reviews ON albergues_rating(total_approved_reviews)');
    }
  }

  /// Check if a table exists
  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// Check if a column exists in a table
  Future<bool> _columnExists(
      Database db, String tableName, String columnName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    for (final row in result) {
      if (row['name'] == columnName) {
        return true;
      }
    }
    return false;
  }

  // ==========================================================================
  // Generic Operations
  // ==========================================================================

  /// Query all rows from a table
  Future<List<Map<String, dynamic>>> queryList({required String table}) async {
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.query(table);
      return result;
    });
  }

  /// Insert a single row
  Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  /// Delete a row by ID
  Future<void> delete({
    required String table,
    required int id,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  /// Bulk insert data in chunks
  Future<void> bulkInsert(
    String table,
    List<Map<String, dynamic>> objects,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var i = 0; i < objects.length; i += CHUNK_SIZE) {
        final batch = txn.batch();
        final endIdx = min(i + CHUNK_SIZE, objects.length);
        for (var j = i; j < endIdx; j++) {
          batch.insert(
            table,
            objects[j],
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      }
    });
  }

  // ==========================================================================
  // Database Utilities
  // ==========================================================================

  /// Check if database is empty (missing core data)
  Future<bool> isDatabaseEmpty(Database db) async {
    AppLogger.d('Checking for empty tables', tag: 'AppDatabase');
    try {
      return db.transaction((txn) async {
        try {
          final tablesExist = await _checkTablesExist(txn);
          if (!tablesExist) {
            AppLogger.d('Core tables do not exist - database is empty',
                tag: 'AppDatabase');
            return true;
          }

          bool routeTableEmpty = await _isTableEmpty(txn, 'routes');
          bool alberguesTableEmpty = await _isTableEmpty(txn, 'albergues');
          bool citiesTableEmpty = await _isTableEmpty(txn, 'cities');
          bool routePointsTableEmpty = await _isTableEmpty(txn, 'route_points');

          final isEmpty = routeTableEmpty ||
              alberguesTableEmpty ||
              citiesTableEmpty ||
              routePointsTableEmpty;

          AppLogger.d(
              'Database empty check: routes=$routeTableEmpty, albergues=$alberguesTableEmpty, cities=$citiesTableEmpty, routePoints=$routePointsTableEmpty, overall=$isEmpty',
              tag: 'AppDatabase');
          return isEmpty;
        } catch (e) {
          AppLogger.e('Error checking individual tables',
              tag: 'AppDatabase', error: e);
          return true;
        }
      });
    } catch (e) {
      AppLogger.e('Error in isDatabaseEmpty transaction',
          tag: 'AppDatabase', error: e);
      return true;
    }
  }

  /// Check if a table is empty
  Future<bool> _isTableEmpty(Transaction txn, String tableName) async {
    try {
      final result = await txn.query(tableName, limit: 1);
      return result.isEmpty;
    } catch (e) {
      AppLogger.e('Error querying $tableName', tag: 'AppDatabase', error: e);
      return true;
    }
  }

  /// Check if core tables exist in the database
  Future<bool> _checkTablesExist(Transaction txn) async {
    try {
      final result = await txn.rawQuery("""
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name IN ('routes', 'albergues', 'cities', 'route_points')
      """);

      final existingTables = result.map((row) => row['name'] as String).toSet();
      final requiredTables = {'routes', 'albergues', 'cities', 'route_points'};

      final allTablesExist =
          requiredTables.every((table) => existingTables.contains(table));
      AppLogger.d(
          'Tables exist check: ${existingTables.join(', ')} - All required: $allTablesExist',
          tag: 'AppDatabase');

      return allTablesExist;
    } catch (e) {
      AppLogger.e('Error checking table existence',
          tag: 'AppDatabase', error: e);
      return false;
    }
  }

  /// Notify that the main database has been updated
  Future<void> notifyDatabaseUpdated() async {
    try {
      AppLogger.d(
          'Main database updated - stage planner validation will be triggered',
          tag: 'AppDatabase');
    } catch (e) {
      AppLogger.e('Error notifying stage planner of database update',
          tag: 'AppDatabase', error: e);
    }
  }
}
