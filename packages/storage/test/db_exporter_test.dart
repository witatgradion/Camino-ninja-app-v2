import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:storage/src/db_exporter.dart';
import 'package:storage/src/stage_planner_database.dart';

/// Routes `path_provider`'s `getTemporaryDirectory()` to a per-test
/// directory so the exporter writes its zip somewhere we can clean
/// up. Without this the test would either fail (no platform
/// implementation) or pollute a shared OS temp location.
///
/// All non-temp paths throw [UnimplementedError] — the default
/// `PathProviderPlatform` returns `null` from un-overridden methods,
/// which silently produces a confusing late failure if production
/// code calls one of them. Throwing surfaces the missing override
/// at the actual call site.
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.tmpRoot);

  final String tmpRoot;

  @override
  Future<String?> getTemporaryPath() async => tmpRoot;

  @override
  Future<String?> getApplicationSupportPath() async =>
      throw UnimplementedError('getApplicationSupportPath');

  @override
  Future<String?> getLibraryPath() async =>
      throw UnimplementedError('getLibraryPath');

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      throw UnimplementedError('getApplicationDocumentsPath');

  @override
  Future<String?> getApplicationCachePath() async =>
      throw UnimplementedError('getApplicationCachePath');

  @override
  Future<String?> getExternalStoragePath() async =>
      throw UnimplementedError('getExternalStoragePath');

  @override
  Future<List<String>?> getExternalCachePaths() async =>
      throw UnimplementedError('getExternalCachePaths');

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async =>
      throw UnimplementedError('getExternalStoragePaths');

  @override
  Future<String?> getDownloadsPath() async =>
      throw UnimplementedError('getDownloadsPath');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory testTmp;
  late Directory dbHome;

  setUp(() async {
    // Reset the production singleton between tests so each
    // test starts with a fresh-on-disk DB.
    await StagePlannerDatabase().closeDatabase();

    testTmp = await Directory.systemTemp.createTemp('db_exporter_test_');
    PathProviderPlatform.instance = _FakePathProvider(testTmp.path);

    // Route sqflite's getDatabasesPath() into the per-test dir
    // so the singleton we don't control still lands somewhere
    // we own.
    dbHome = Directory(p.join(testTmp.path, 'databases'))
      ..createSync(recursive: true);
    await databaseFactoryFfi.setDatabasesPath(dbHome.path);

    // Wipe any pre-existing DB file from previous runs.
    final f = File(p.join(dbHome.path, 'stage_planner_database.db'));
    if (f.existsSync()) await f.delete();
  });

  tearDown(() async {
    await StagePlannerDatabase().closeDatabase();
    if (testTmp.existsSync()) {
      try {
        await testTmp.delete(recursive: true);
      } catch (_) {}
    }
  });

  /// Initializes the stage planner DB at current version through
  /// the real production `_initDatabase` flow (via the singleton)
  /// so we exercise the same migrations / table creation the
  /// exporter sees in production.
  Future<void> seedStagePlanner({
    required List<
            ({
              String? name,
              List<
                  ({
                    String? customStartNotes,
                    String? customEndNotes,
                    String? stageNotes,
                    DateTime date,
                  })> stages,
            })>
        plans,
  }) async {
    final db = StagePlannerDatabase();
    for (final plan in plans) {
      final planId = await db.createStagePlan(
        routeId: 1,
        name: plan.name,
      );
      for (final stage in plan.stages) {
        await db.createStage(
          stagePlanId: planId,
          routeId: 1,
          date: stage.date,
          startCityId: 1,
          endCityId: 2,
          customStartNotes: stage.customStartNotes,
          customEndNotes: stage.customEndNotes,
          stageNotes: stage.stageNotes,
        );
      }
    }
  }

  /// Unzip [zip] into a fresh subdir of [testTmp] and return the
  /// extraction directory.
  Future<Directory> unzip(File zip) async {
    final outDir = Directory(p.join(testTmp.path, 'unzipped'))
      ..createSync(recursive: true);
    final bytes = await zip.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final entry in archive.files) {
      if (!entry.isFile) continue;
      final outPath = p.join(outDir.path, entry.name);
      final outFile = File(outPath);
      await outFile.parent.create(recursive: true);
      await outFile.writeAsBytes(entry.content as List<int>);
    }
    return outDir;
  }

  group('DbExporter', () {
    test(
      'happy path: produces zip containing stage planner DB + '
      'manifest, scrubs PII, preserves row counts/dates/FKs/schema',
      () async {
        await seedStagePlanner(
          plans: [
            (
              name: "Mom's birthday camino",
              stages: [
                (
                  customStartNotes: 'Pick up John at airport',
                  customEndNotes: 'Meet Sarah at the cafe',
                  stageNotes: 'Remember to call mom',
                  date: DateTime(2024, 6, 15),
                ),
                (
                  customStartNotes: null,
                  customEndNotes: 'Stay overnight',
                  stageNotes: '',
                  date: DateTime(2024, 6, 16),
                ),
              ],
            ),
            (
              name: 'Solo trip',
              stages: [
                (
                  customStartNotes: 'Start early',
                  customEndNotes: null,
                  stageNotes: null,
                  date: DateTime(2024, 7, 1),
                ),
              ],
            ),
          ],
        );

        final zipFile = await DbExporter().exportAnonymizedArchive(
          appVersion: '2.2.395',
          buildNumber: '202395',
          flavorName: 'staging',
        );

        addTearDown(() async {
          if (zipFile.existsSync()) await zipFile.delete();
        });

        // Filename includes the flavor + version.
        expect(
          p.basename(zipFile.path),
          startsWith('db_export_staging_2.2.395_'),
        );
        expect(p.extension(zipFile.path), equals('.zip'));

        final outDir = await unzip(zipFile);
        final files = outDir
            .listSync()
            .whereType<File>()
            .map((f) => p.basename(f.path))
            .toSet();
        // Schema v2: only the stage planner DB ships.
        expect(files, equals(<String>{
          'stage_planner_database.db',
          'manifest.json',
        }));

        // ---- Manifest ----
        final manifest = jsonDecode(
          await File(p.join(outDir.path, 'manifest.json')).readAsString(),
        ) as Map<String, dynamic>;

        expect(manifest['schemaVersion'], equals(2));
        expect(manifest['appVersion'], equals('2.2.395'));
        expect(manifest['buildNumber'], equals('202395'));
        expect(manifest['flavor'], equals('staging'));
        expect(manifest['platform'], equals(Platform.operatingSystem));
        expect(
          manifest['osVersion'],
          equals(Platform.operatingSystemVersion),
        );
        // appDatabaseVersion is gone in schema v2.
        expect(manifest.containsKey('appDatabaseVersion'), isFalse);
        expect(
          manifest['stagePlannerDatabaseVersion'],
          equals(stagePlannerDatabaseVersion),
        );
        // ISO8601 round-trip parse — guards against stamp drift.
        expect(
          DateTime.tryParse(manifest['exportedAt'] as String),
          isNotNull,
        );

        final scrubbed = manifest['scrubbedColumns'] as List<dynamic>;
        expect(scrubbed, isNotEmpty);
        // Document a representative entry; not exhaustive on
        // purpose so the test isn't a copy of the const.
        final stageNotesEntry = scrubbed.firstWhere(
          (e) =>
              (e as Map)['table'] == 'stages' &&
              (e['database'] as String) == 'stage_planner',
        ) as Map<String, dynamic>;
        expect(
          stageNotesEntry['columns'],
          containsAll(<String>[
            'custom_start_notes',
            'custom_end_notes',
            'stage_notes',
          ]),
        );
        // No `app`-tagged scrub entries in v2.
        for (final entry in scrubbed) {
          expect((entry as Map)['database'], isNot(equals('app')));
        }

        final rowCounts =
            manifest['rowCounts'] as Map<String, dynamic>;
        // No `app` key in rowCounts in v2.
        expect(rowCounts.containsKey('app'), isFalse);
        final plannerCounts = rowCounts['stage_planner']
            as Map<String, dynamic>;
        expect(plannerCounts['stage_plans'], equals(2));
        expect(plannerCounts['stages'], equals(3));

        // ---- Anonymized DB ----
        final scrubbedPlannerDb = await databaseFactoryFfi.openDatabase(
          p.join(outDir.path, 'stage_planner_database.db'),
        );
        try {
          // PII columns nulled across all rows.
          final stagesDump = await scrubbedPlannerDb.query('stages');
          expect(stagesDump, hasLength(3));
          for (final row in stagesDump) {
            expect(row['custom_start_notes'], isNull);
            expect(row['custom_end_notes'], isNull);
            expect(row['stage_notes'], isNull);
          }
          final plansDump = await scrubbedPlannerDb.query('stage_plans');
          expect(plansDump, hasLength(2));
          for (final row in plansDump) {
            expect(row['name'], isNull);
          }

          // FK integrity check passes.
          final fkRows = await scrubbedPlannerDb
              .rawQuery('PRAGMA foreign_key_check');
          expect(fkRows, isEmpty);

          // Schema preserved on a representative table.
          final stagesSchema = await scrubbedPlannerDb
              .rawQuery('PRAGMA table_info(stages)');
          final stagesCols = stagesSchema
              .map((r) => r['name']! as String)
              .toSet();
          expect(
            stagesCols,
            containsAll(<String>[
              'id',
              'stage_plan_id',
              'route_id',
              'stage_uuid',
              'date',
              'days_to_stay',
              'custom_start_notes',
              'custom_end_notes',
              'stage_notes',
            ]),
          );

          // Dates round-tripped — not nulled by the scrub.
          final dates = stagesDump
              .map((r) => r['date'] as String?)
              .where((d) => d != null)
              .toList();
          expect(dates, hasLength(3));
          // Dates are stored normalized to yyyy-MM-dd.
          expect(dates, contains('2024-06-15'));
          expect(dates, contains('2024-06-16'));
          expect(dates, contains('2024-07-01'));

          // created_at preserved (non-null on every row).
          for (final row in stagesDump) {
            expect(row['created_at'], isNotNull);
          }
        } finally {
          await scrubbedPlannerDb.close();
        }

        // ---- Production singleton unaffected ----
        // Re-querying the live DB after export must still work
        // and return the original PII (proves we copied, not
        // mutated).
        final liveDb = StagePlannerDatabase();
        final livePlans = await liveDb.getStagePlansByRouteId(1);
        expect(livePlans, hasLength(2));
        final livePlan = await liveDb.getStagePlanById(livePlans.first.id);
        expect(livePlan, isNotNull);
        expect(
          [
            for (final p in livePlans) p.name,
          ],
          containsAll(<String>["Mom's birthday camino", 'Solo trip']),
        );

        // Live singleton must still be *writable* — the export must
        // not have left the connection in a read-only or otherwise
        // wedged state. Lock in the "still usable" guarantee.
        final newPlanId = await liveDb.createStagePlan(
          routeId: 1,
          name: 'Post-export plan',
        );
        expect(newPlanId, greaterThan(0));
        final livePlansAfter = await liveDb.getStagePlansByRouteId(1);
        expect(livePlansAfter, hasLength(3));
      },
    );

    test(
      'empty database: produces a valid archive with zero-row '
      'counts and no errors',
      () async {
        // Initialize stage planner with no plans/stages by simply
        // opening it.
        await StagePlannerDatabase().database;

        final zipFile = await DbExporter().exportAnonymizedArchive(
          appVersion: '2.2.395',
          buildNumber: '202395',
          flavorName: 'development',
        );
        addTearDown(() async {
          if (zipFile.existsSync()) await zipFile.delete();
        });

        final outDir = await unzip(zipFile);
        final manifest = jsonDecode(
          await File(p.join(outDir.path, 'manifest.json')).readAsString(),
        ) as Map<String, dynamic>;

        final rowCounts =
            manifest['rowCounts'] as Map<String, dynamic>;
        final plannerCounts =
            rowCounts['stage_planner'] as Map<String, dynamic>;
        expect(plannerCounts['stage_plans'], equals(0));
        expect(plannerCounts['stages'], equals(0));
        expect(rowCounts.containsKey('app'), isFalse);

        final plannerDb = await databaseFactoryFfi.openDatabase(
          p.join(outDir.path, 'stage_planner_database.db'),
        );
        try {
          final stages = await plannerDb.query('stages');
          expect(stages, isEmpty);
          final fkRows =
              await plannerDb.rawQuery('PRAGMA foreign_key_check');
          expect(fkRows, isEmpty);
        } finally {
          await plannerDb.close();
        }
      },
    );

    test(
      'idempotent: scrubbing a DB whose PII columns are already '
      'NULL is a no-op',
      () async {
        await seedStagePlanner(
          plans: [
            (
              name: null,
              stages: [
                (
                  customStartNotes: null,
                  customEndNotes: null,
                  stageNotes: null,
                  date: DateTime(2024, 6, 15),
                ),
              ],
            ),
          ],
        );

        final zipFile = await DbExporter().exportAnonymizedArchive(
          appVersion: '2.2.395',
          buildNumber: '202395',
          flavorName: 'staging',
        );
        addTearDown(() async {
          if (zipFile.existsSync()) await zipFile.delete();
        });

        final outDir = await unzip(zipFile);
        final plannerDb = await databaseFactoryFfi.openDatabase(
          p.join(outDir.path, 'stage_planner_database.db'),
        );
        try {
          final plans = await plannerDb.query('stage_plans');
          expect(plans, hasLength(1));
          expect(plans.first['name'], isNull);

          final stages = await plannerDb.query('stages');
          expect(stages, hasLength(1));
          for (final col in const [
            'custom_start_notes',
            'custom_end_notes',
            'stage_notes',
          ]) {
            expect(stages.first[col], isNull);
          }

          final fkRows =
              await plannerDb.rawQuery('PRAGMA foreign_key_check');
          expect(fkRows, isEmpty);
        } finally {
          await plannerDb.close();
        }

        final manifest = jsonDecode(
          await File(p.join(outDir.path, 'manifest.json')).readAsString(),
        ) as Map<String, dynamic>;
        final rowCounts =
            manifest['rowCounts'] as Map<String, dynamic>;
        final plannerCounts =
            rowCounts['stage_planner'] as Map<String, dynamic>;
        expect(plannerCounts['stage_plans'], equals(1));
        expect(plannerCounts['stages'], equals(1));
      },
    );
  });
}

