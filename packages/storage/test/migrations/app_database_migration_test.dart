import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' show Sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:storage/src/app_database.dart';

import 'migration_test_harness.dart';

void main() {
  late MigrationTestHarness harness;

  setUp(() {
    harness = MigrationTestHarness();
  });

  tearDown(() async {
    await harness.disposeAll();
  });

  group('app_database v7 -> v8', () {
    test(
      'non-destructively adds light_legend_color + dark_legend_color',
      () async {
        final seed = await harness.openAt('camino_v7.db', 7);
        await harness.seedFromSql(
          seed,
          'test/migrations/fixtures/app_db/v7.sql',
        );
        await seed.close();

        final db = await harness.reopenAtCurrent(
          'camino_v7.db',
          currentVersion: appDatabaseVersion,
          onUpgrade: appDatabaseOnUpgrade,
        );

        // Both new columns must exist.
        expect(
          await harness.columnExists(db, 'routes', 'light_legend_color'),
          isTrue,
        );
        expect(
          await harness.columnExists(db, 'routes', 'dark_legend_color'),
          isTrue,
        );

        // Legacy data must be preserved.
        expect(await harness.rowCount(db, 'routes'), 2);
        expect(await harness.rowCount(db, 'cities'), 2);
        expect(await harness.rowCount(db, 'albergues'), 2);

        // Existing rows should have NULL in the newly added columns
        // (ALTER TABLE ADD COLUMN without a default populates NULL).
        final rows = await db.query(
          'routes',
          columns: ['id', 'light_legend_color', 'dark_legend_color'],
          orderBy: 'id ASC',
        );
        for (final row in rows) {
          expect(row['light_legend_color'], isNull);
          expect(row['dark_legend_color'], isNull);
        }
      },
    );

    test('is idempotent — running twice does not duplicate columns',
        () async {
      final seed = await harness.openAt('camino_v7_idempotent.db', 7);
      await harness.seedFromSql(
        seed,
        'test/migrations/fixtures/app_db/v7.sql',
      );
      await seed.close();

      // First upgrade v7 -> v8.
      final db1 = await harness.reopenAtCurrent(
        'camino_v7_idempotent.db',
        currentVersion: appDatabaseVersion,
        onUpgrade: appDatabaseOnUpgrade,
      );
      expect(
        await harness.columnExists(db1, 'routes', 'light_legend_color'),
        isTrue,
      );
      final columnsBefore =
          await db1.rawQuery('PRAGMA table_info(routes)');
      final columnCountBefore = columnsBefore.length;
      await db1.close();

      // Manually call the upgrade again against the same DB — the
      // column existence check should short-circuit without error.
      final db2 = await databaseFactoryFfi.openDatabase(
        harness.pathFor('camino_v7_idempotent.db'),
      );
      await expectLater(
        appDatabaseOnUpgrade(db2, 7, 8),
        completes,
      );

      // Re-running the migration must NOT add duplicate columns.
      final columnsAfter =
          await db2.rawQuery('PRAGMA table_info(routes)');
      expect(
        columnsAfter.length,
        columnCountBefore,
        reason: 'routes column count must be unchanged after a '
            'second migration run',
      );
      await db2.close();
    });
  });

  group('app_database v6 -> v8 (destructive recreate)', () {
    // Helper: open the DB at v6, install the v6 fixture (incl.
    // favorites_albergues seed rows), close it, then reopen
    // at [appDatabaseVersion] without running the production
    // upgrade callback.
    //
    // We deliberately bypass `appDatabaseDropAndRecreate` /
    // `appDatabaseOnUpgrade` during reopen so each test can drive
    // those functions explicitly and inspect intermediate state.
    Future<Database> seedV6AndReopen(String dbName) async {
      final seed = await harness.openAt(dbName, 6);
      await harness.seedFromSql(
        seed,
        'test/migrations/fixtures/app_db/v6.sql',
      );
      await seed.close();

      // Reopen at the current version with NO migration callback so
      // the underlying SQLite file is left exactly as the v6 fixture
      // wrote it. The version mismatch is harmless when there's no
      // onUpgrade to dispatch — sqflite will only bump
      // PRAGMA user_version when an upgrade callback runs.
      final db = await databaseFactoryFfi.openDatabase(
        harness.pathFor(dbName),
      );
      return db;
    }

    Future<List<Map<String, Object?>>> readFavorites(Database db) async {
      return db.query('favorites_albergues', orderBy: 'id ASC');
    }

    test(
      'preserves favorites_albergues across the destructive recreate',
      () async {
        final db = await seedV6AndReopen('camino_v6_favorites.db');

        // Snapshot favorites before recreate.
        final before = await readFavorites(db);
        expect(before, hasLength(5));
        final beforeIds =
            before.map((row) => row['id']! as int).toList();
        final beforeAlbergueIds = before
            .map((row) => row['albergue_id']! as int)
            .toList();

        // Drive the production destructive branch end-to-end:
        //   1. drop + recreate at current schema
        //   2. apply non-destructive v7 -> v8 column adds
        // (production also runs `appDatabaseOnUpgrade(6, 8)` after
        //  the drop+recreate; it is a no-op here because the recreated
        //  routes table already has the legend color columns, but
        //  running it locks in that the chain stays idempotent.)
        await appDatabaseDropAndRecreate(db);
        await appDatabaseOnUpgrade(db, 6, 8);

        // favorites_albergues survived byte-for-byte.
        final after = await readFavorites(db);
        expect(after, hasLength(5));
        final afterIds = after.map((row) => row['id']! as int).toList();
        final afterAlbergueIds =
            after.map((row) => row['albergue_id']! as int).toList();
        expect(afterIds, beforeIds);
        expect(afterAlbergueIds, beforeAlbergueIds);
        // Full row equality on every column: nothing was rewritten.
        expect(after, before);

        // Reference tables exist at v8 shape but are empty — the test
        // does not replay the asset seed.
        for (final table in const [
          'routes',
          'route_points',
          'cities',
          'albergues',
          'announcements',
          'city_routes',
          'city_route_points',
          'latest_data_updated',
          'alt_route_points',
          'alt_route_points_values',
          'albergue_facilities',
          'albergue_images',
          'albergue_user_images',
          'albergue_phones',
          'albergue_emails',
          'albergue_social_medias',
          'albergue_operating_hours',
          'albergue_prices',
          'albergue_reviews',
          'albergue_wifis',
        ]) {
          expect(
            await harness.rowCount(db, table),
            0,
            reason: '$table must be empty after destructive recreate',
          );
        }

        // Legend color columns (v8 addition) must exist on routes.
        expect(
          await harness.columnExists(db, 'routes', 'light_legend_color'),
          isTrue,
        );
        expect(
          await harness.columnExists(db, 'routes', 'dark_legend_color'),
          isTrue,
        );
      },
    );

    test('recreates routes/cities/albergues at v8 shape', () async {
      final db = await seedV6AndReopen('camino_v6_shape.db');
      await appDatabaseDropAndRecreate(db);

      // routes — v8 shape includes legend color columns.
      await harness.expectTableSchema(db, 'routes', {
        'id',
        'order_key',
        'route_name',
        'route_sub_name',
        'legend_color',
        'light_legend_color',
        'dark_legend_color',
      });

      // cities — v8 shape includes the full set of POI flag columns
      // and lat/long.
      await harness.expectTableSchema(db, 'cities', {
        'id',
        'order_key',
        'name',
        'country',
        'region',
        'province',
        'slug',
        'km',
        'has_atm',
        'has_bar_cafe',
        'has_shop',
        'has_med_clinic',
        'has_pharmacy',
        'has_fountain',
        'has_post_office',
        'has_train_station',
        'etape_city',
        'share_url',
        'search',
        'b_city_id',
        'openweathermap_id',
        'notes_translation_id',
        'has_tobacco_store',
        'has_airport',
        'has_bus_station',
        'has_restaurant',
        'has_albergues',
        'latitude',
        'longitude',
      });

      // albergues — v8 shape.
      await harness.expectTableSchema(db, 'albergues', {
        'id',
        'order_key',
        'name',
        'slug',
        'city_slug',
        'status',
        'is_municipal',
        'is_albergue',
        'address',
        'postal_code',
        'province',
        'region',
        'country',
        'share_url',
        'web',
        'booking_com_url',
        'dist_costa',
        'dist_litoral',
        'reserve_url',
        'city_id',
        'city_name',
        'places_in_dormitory',
        'number_of_dormitories',
        'latitude',
        'longitude',
        'reservation_translation_id',
        'open_season_translation_id',
        'booking_price',
        'booking_price_updated_at',
      });

      // Indexes from createIndexes() are restored.
      expect(
        await harness.indexExists(db, 'idx_albergues_city_id'),
        isTrue,
      );
      expect(
        await harness.indexExists(db, 'idx_route_points_route_id'),
        isTrue,
      );
    });

    test('is idempotent on re-run', () async {
      final db = await seedV6AndReopen('camino_v6_idempotent.db');

      // First pass: drop+recreate then v7->v8 column adds.
      await appDatabaseDropAndRecreate(db);
      await appDatabaseOnUpgrade(db, 6, 8);

      final routesColumnsAfterFirst =
          await db.rawQuery('PRAGMA table_info(routes)');
      final favoritesAfterFirst = await readFavorites(db);
      final favoritesCountAfterFirst = await Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) AS c FROM favorites_albergues',
        ),
      );

      // Second pass: should be a no-op.
      await expectLater(
        appDatabaseDropAndRecreate(db),
        completes,
        reason: 'second drop+recreate must not raise '
            '"table already exists"',
      );
      await expectLater(
        appDatabaseOnUpgrade(db, 6, 8),
        completes,
      );

      final routesColumnsAfterSecond =
          await db.rawQuery('PRAGMA table_info(routes)');
      expect(
        routesColumnsAfterSecond.length,
        routesColumnsAfterFirst.length,
        reason: 'routes column count must be identical after a '
            'second drop+recreate (no duplicate columns)',
      );

      // favorites_albergues still preserved.
      final favoritesAfterSecond = await readFavorites(db);
      expect(favoritesAfterSecond, favoritesAfterFirst);
      expect(
        await Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) AS c FROM favorites_albergues',
          ),
        ),
        favoritesCountAfterFirst,
      );
    });
  });
}
