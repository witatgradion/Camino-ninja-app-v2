import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:core/core.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:storage/src/stage_planner_database.dart';

/// Free-text columns that may contain user PII and are nulled
/// before the DB copy is shared. The list is intentionally
/// conservative — preserve schema, row counts, FKs, dates, IDs;
/// scrub anything users typed.
///
/// `(database, table, columns)` — `database` is `'stage_planner'`
/// for the user-plan DB. The export only ships the stage-planner
/// DB (see [DbExporter] header comment), so this list contains
/// only `stage_planner` entries.
const List<({String database, String table, List<String> columns})>
    dbExporterScrubbedColumns = [
  // Stage planner — user-typed plan + stage content.
  (
    database: 'stage_planner',
    table: 'stage_plans',
    columns: ['name'],
  ),
  (
    database: 'stage_planner',
    table: 'stages',
    columns: [
      'custom_start_notes',
      'custom_end_notes',
      'stage_notes',
    ],
  ),
];

/// Exports an anonymized copy of the stage-planner SQLite
/// database into a single zip archive suitable for sharing with
/// the product owner for golden-DB collection (see Phase 3a of
/// `docs/db-test-harness-plan.md`).
///
/// As of schema v2 the export ships only `stage_planner_database`.
/// `app_database` is mostly server-seeded reference data the user
/// can't easily get into a weird shape, and dropping it cuts the
/// archive size from ~11 MB to tens of KB so beta testers can
/// attach it to bug reports without friction.
///
/// Behavior:
/// 1. Uses `VACUUM INTO` to produce a point-in-time copy of the
///    stage-planner DB without disturbing the live singleton.
/// 2. Opens the copy and runs `UPDATE ... SET col = NULL`
///    against every column in [dbExporterScrubbedColumns].
/// 3. Writes `manifest.json` with version + row counts +
///    scrubbed-column metadata.
/// 4. Zips the `.db` file plus the manifest into a single
///    archive in the OS temp directory.
///
/// The caller is responsible for sharing and/or deleting the
/// returned [File].
class DbExporter {
  /// Creates an exporter. The stage-planner DB singleton can be
  /// injected for tests; production callers can use the default
  /// argument which delegates to the global singleton.
  DbExporter({
    StagePlannerDatabase? stagePlannerDatabase,
  }) : _stagePlannerDatabase =
            stagePlannerDatabase ?? StagePlannerDatabase();

  final StagePlannerDatabase _stagePlannerDatabase;

  static const String _logTag = 'DbExporter';
  static const String _stagePlannerCopyName =
      'stage_planner_database.db';
  static const String _manifestName = 'manifest.json';
  // Bumped to 2 when `app_database.db` was dropped from the
  // archive. Consumers that key off the old shape (one DB +
  // manifest with `appDatabaseVersion`) need to handle v2 as a
  // single-DB archive without `appDatabaseVersion`.
  static const int _manifestSchemaVersion = 2;

  /// Builds the anonymized archive and returns a [File] pointing
  /// at the resulting zip. The zip lives in `getTemporaryDirectory()`;
  /// the caller decides when to share or delete it.
  ///
  /// [appVersion], [buildNumber], and [flavorName] are stamped
  /// into the manifest verbatim.
  Future<File> exportAnonymizedArchive({
    required String appVersion,
    required String buildNumber,
    required String flavorName,
  }) async {
    // Belt-and-suspenders: the More-tab gate already excludes
    // production builds, but assert here too so a future regression
    // (e.g. someone removes the gate, or wires the exporter into a
    // different code path) fails loudly.
    assert(
      flavorName != 'production',
      'DbExporter must not run in production builds',
    );
    if (flavorName == 'production') {
      throw StateError(
        'DbExporter must not run in production builds',
      );
    }

    AppLogger.i(
      'Starting DB export (flavor=$flavorName '
      'appVersion=$appVersion build=$buildNumber)',
      tag: _logTag,
    );

    // Best-effort: purge any stale archives from previous exports.
    // On Android, getTemporaryDirectory() == cache dir which is
    // not auto-purged, so without this, every export accumulates.
    // Safe to do *before* writing the new zip — we are deleting
    // only old exports, not the one we are about to share.
    await _purgeStaleArchives();

    final workDir = await Directory.systemTemp.createTemp('db_export_');
    try {
      final stagePlannerCopyPath =
          p.join(workDir.path, _stagePlannerCopyName);

      await _vacuumInto(
        _stagePlannerDatabase,
        stagePlannerCopyPath,
      );

      final plannerRowCounts = await _scrubAndCount(
        copyPath: stagePlannerCopyPath,
        databaseTag: 'stage_planner',
      );

      final manifestPath = p.join(workDir.path, _manifestName);
      await _writeManifest(
        manifestPath: manifestPath,
        appVersion: appVersion,
        buildNumber: buildNumber,
        flavorName: flavorName,
        plannerRowCounts: plannerRowCounts,
      );

      final archiveFile = await _zipArchive(
        stagePlannerCopyPath: stagePlannerCopyPath,
        manifestPath: manifestPath,
        appVersion: appVersion,
        flavorName: flavorName,
      );

      AppLogger.i(
        'DB export complete: ${archiveFile.path} '
        '(${await archiveFile.length()} bytes)',
        tag: _logTag,
      );
      return archiveFile;
    } finally {
      // Best-effort cleanup of the working dir; the zip lives
      // in a separate temp directory so it survives.
      try {
        if (await workDir.exists()) {
          await workDir.delete(recursive: true);
        }
      } catch (e) {
        AppLogger.w(
          'Failed to clean up temp work dir: $e',
          tag: _logTag,
        );
      }
    }
  }

  /// Produces a clean point-in-time copy of [source]'s database
  /// at [destPath] using SQLite's `VACUUM INTO`. The live
  /// connection is NOT closed; callers can keep using it.
  ///
  /// May briefly block if another write transaction is in flight
  /// against the same connection — `VACUUM INTO` requires no open
  /// transaction. Reads on the live connection are not blocked
  /// for any longer than the time it takes to write the copy.
  ///
  /// `VACUUM INTO` accepts an arbitrary SQL expression for the
  /// destination filename (per https://sqlite.org/lang_vacuum.html),
  /// so parameter binding via `?` is supported and is the safe
  /// choice — it dodges quoting bugs that string interpolation
  /// would invite. Verified on SQLite 3.51 (FFI test harness).
  Future<void> _vacuumInto(Object source, String destPath) async {
    final db = await _databaseFor(source);
    // VACUUM INTO requires no transaction be open. sqflite's
    // execute() does not wrap statements in implicit transactions
    // unless inside `.transaction()`, so this is safe to call
    // directly on the connection.
    try {
      await db.execute('VACUUM INTO ?', [destPath]);
    } on DatabaseException catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('database is locked') || msg.contains('busy')) {
        throw StateError(
          'DB export busy: another write is in flight. '
          'Try again in a moment.',
        );
      }
      rethrow;
    }
  }

  Future<Database> _databaseFor(Object source) async {
    if (source is StagePlannerDatabase) return source.database;
    throw ArgumentError('Unsupported source: $source');
  }

  /// Opens the copied DB at [copyPath], scrubs every PII column
  /// listed in [dbExporterScrubbedColumns] for [databaseTag], and
  /// returns a `{table: rowCount}` map for the manifest.
  Future<Map<String, int>> _scrubAndCount({
    required String copyPath,
    required String databaseTag,
  }) async {
    // Match production by enabling FK enforcement on the copy. The
    // current scrub list is all nullable text columns, so no FK
    // constraint can fire today — but if a future column added to
    // [dbExporterScrubbedColumns] references a parent row, an
    // `UPDATE ... SET col = NULL` against an FK with `ON DELETE
    // RESTRICT` would silently no-op without this. Reuse the
    // top-level helper from `stage_planner_database.dart` so the
    // production and exporter paths cannot drift.
    final db = await openDatabase(
      copyPath,
      onConfigure: stagePlannerOnConfigure,
    );
    try {
      // 1) Scrub PII columns. We iterate explicitly so the list
      // doubles as runtime documentation.
      for (final entry in dbExporterScrubbedColumns) {
        if (entry.database != databaseTag) continue;
        // Skip if the table doesn't exist in this DB (e.g. older
        // schema). PRAGMA-based existence check is robust and
        // avoids relying on sqlite_master.
        final tableInfo = await db.rawQuery(
          'PRAGMA table_info(${entry.table})',
        );
        if (tableInfo.isEmpty) continue;
        final existingCols = tableInfo
            .map((row) => row['name']! as String)
            .toSet();
        for (final column in entry.columns) {
          if (!existingCols.contains(column)) continue;
          await db.execute(
            'UPDATE ${entry.table} SET $column = NULL',
          );
        }
      }

      // 2) Collect row counts for every user table.
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master "
        "WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' "
        "AND name NOT LIKE 'android_metadata' "
        'ORDER BY name ASC',
      );
      final counts = <String, int>{};
      for (final row in tables) {
        final name = row['name']! as String;
        final result = await db.rawQuery(
          'SELECT COUNT(*) AS c FROM "$name"',
        );
        counts[name] = Sqflite.firstIntValue(result) ?? 0;
      }
      return counts;
    } finally {
      await db.close();
    }
  }

  Future<void> _writeManifest({
    required String manifestPath,
    required String appVersion,
    required String buildNumber,
    required String flavorName,
    required Map<String, int> plannerRowCounts,
  }) async {
    final scrubbed = dbExporterScrubbedColumns
        .map(
          (e) => <String, Object>{
            'database': e.database,
            'table': e.table,
            'columns': e.columns,
          },
        )
        .toList();

    final manifest = <String, Object>{
      'schemaVersion': _manifestSchemaVersion,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'flavor': flavorName,
      'platform': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'stagePlannerDatabaseVersion': stagePlannerDatabaseVersion,
      'scrubbedColumns': scrubbed,
      'rowCounts': <String, Object>{
        'stage_planner': plannerRowCounts,
      },
    };

    const encoder = JsonEncoder.withIndent('  ');
    await File(manifestPath).writeAsString(encoder.convert(manifest));
  }

  Future<File> _zipArchive({
    required String stagePlannerCopyPath,
    required String manifestPath,
    required String appVersion,
    required String flavorName,
  }) async {
    final outputDir = await getTemporaryDirectory();
    final timestamp =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final archiveName =
        'db_export_${flavorName}_${appVersion}_$timestamp.zip';
    final zipPath = p.join(outputDir.path, archiveName);

    final encoder = ZipFileEncoder()..create(zipPath);
    try {
      await encoder.addFile(
        File(stagePlannerCopyPath),
        _stagePlannerCopyName,
      );
      await encoder.addFile(File(manifestPath), _manifestName);
    } finally {
      await encoder.close();
    }

    // Belt-and-suspenders: assert the archive is well-formed by
    // re-decoding the central directory. Bad zips would produce
    // a file that can't be opened on the receiving end.
    final bytes = await File(zipPath).readAsBytes();
    final decoded = ZipDecoder().decodeBytes(bytes);
    if (decoded.files.length != 2) {
      throw StateError(
        'Archive integrity check failed: expected 2 entries, '
        'found ${decoded.files.length}',
      );
    }

    return File(zipPath);
  }

  /// Deletes any `db_export_*.zip` files left in the OS temp dir
  /// from earlier exports. Best-effort: failures here must not
  /// abort the export. On Android, `getTemporaryDirectory()` is
  /// the cache dir and is not auto-purged, so without this
  /// archives accumulate every time the user re-runs the flow.
  ///
  /// Filters by mtime: only deletes archives older than
  /// [_staleArchiveAge]. Race rationale — if the user double-taps
  /// the export trigger, a second invocation can start before the
  /// first's share-sheet is dismissed. Without the mtime filter,
  /// the second's purge would nuke the in-flight zip the first
  /// invocation is about to share.
  Future<void> _purgeStaleArchives() async {
    final cutoff = DateTime.now().subtract(_staleArchiveAge);
    try {
      final dir = await getTemporaryDirectory();
      if (!dir.existsSync()) return;
      final entries = dir.listSync();
      for (final entry in entries) {
        if (entry is! File) continue;
        final name = p.basename(entry.path);
        if (!name.startsWith('db_export_') || !name.endsWith('.zip')) {
          continue;
        }
        try {
          final stat = await entry.stat();
          if (!stat.modified.isBefore(cutoff)) continue;
          await entry.delete();
        } catch (e) {
          AppLogger.w(
            'Failed to delete stale export ${entry.path}: $e',
            tag: _logTag,
          );
        }
      }
    } catch (e) {
      AppLogger.w(
        'Failed to scan temp dir for stale exports: $e',
        tag: _logTag,
      );
    }
  }

  /// Archives younger than this are left alone — they may belong
  /// to a concurrent export in flight (double-tap race).
  static const Duration _staleArchiveAge = Duration(seconds: 30);
}
