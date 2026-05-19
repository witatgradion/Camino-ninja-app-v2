import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' show Sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Harness for exercising real database migrations against
/// versioned schema fixtures.
///
/// Each harness instance keeps track of its own temp files and
/// open [Database] handles so multiple tests in the same run do
/// not collide. Call [disposeAll] in tearDown.
///
/// Typical use:
///
/// ```dart
/// final harness = MigrationTestHarness();
/// final db = await harness.openAt('plan.db', 5, onCreate: _v5Schema);
/// await harness.seedFromSql(db, 'test/.../fixtures/v5.sql');
/// await db.close();
/// final migrated = await harness.reopenAtCurrent(
///   'plan.db',
///   currentVersion: stagePlannerDatabaseVersion,
///   onUpgrade: stagePlannerOnUpgrade,
///   onConfigure: stagePlannerOnConfigure,
/// );
/// await harness.expectFkValid(migrated);
/// ```
class MigrationTestHarness {
  MigrationTestHarness() {
    sqfliteFfiInit();
  }

  /// A unique subdirectory for this harness instance so parallel
  /// tests do not collide on the same temp file names.
  final String _instanceSlot =
      '${DateTime.now().microsecondsSinceEpoch}_'
      '${Random().nextInt(1 << 32)}';

  final Map<String, String> _dbPaths = {};
  final List<Database> _openDatabases = [];

  /// Resolve (and memoize) the absolute temp path for [dbName].
  String pathFor(String dbName) {
    return _dbPaths.putIfAbsent(dbName, () {
      final dir = Directory(
        p.join(Directory.systemTemp.path, 'migration_harness',
            _instanceSlot),
      );
      dir.createSync(recursive: true);
      return p.join(dir.path, dbName);
    });
  }

  /// Open [dbName] at a specific historical [version].
  ///
  /// By default the database is opened empty — the caller is
  /// expected to install the schema via [seedFromSql] pointing at
  /// a fixture file that contains both CREATE and INSERT
  /// statements.
  ///
  /// If [onCreate] is supplied, the harness will run it when the
  /// DB is first created (useful when tests want to install the
  /// schema programmatically instead of via SQL). When both
  /// [onCreate] and a schema-containing fixture are used, the
  /// caller must ensure they do not overlap.
  ///
  /// If the file already exists it is deleted first so tests
  /// always start from a clean slate.
  Future<Database> openAt(
    String dbName,
    int version, {
    FutureOr<void> Function(Database db)? onCreate,
    FutureOr<void> Function(Database db)? onConfigure,
  }) async {
    final path = pathFor(dbName);
    final file = File(path);
    if (await file.exists()) await file.delete();

    final db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: onConfigure == null
            ? null
            : (db) async => onConfigure(db),
        onCreate: (db, _) async {
          if (onCreate != null) await onCreate(db);
        },
      ),
    );
    _openDatabases.add(db);
    return db;
  }

  /// Read a `.sql` fixture file and execute each statement against
  /// [db] in a transaction.
  ///
  /// Statements are split on trailing semicolons. Lines starting
  /// with `--` and blank lines are ignored. The input is expected
  /// to contain simple CREATE/INSERT statements — no triggers or
  /// multi-line strings that contain a semicolon.
  Future<void> seedFromSql(Database db, String sqlPath) async {
    final raw = await File(sqlPath).readAsString();
    final statements = _splitSqlStatements(raw);
    await db.transaction((txn) async {
      for (final stmt in statements) {
        await txn.execute(stmt);
      }
    });
  }

  /// Reopen [dbName] at [currentVersion], driving the real
  /// production migration functions.
  ///
  /// The caller passes [onUpgrade] (and optionally [onConfigure]).
  /// The harness does not duplicate migration logic — it is the
  /// caller's responsibility to pass the actual production
  /// functions (e.g. `stagePlannerOnUpgrade`).
  Future<Database> reopenAtCurrent(
    String dbName, {
    required int currentVersion,
    required Future<void> Function(Database, int, int) onUpgrade,
    FutureOr<void> Function(Database)? onConfigure,
  }) async {
    final path = pathFor(dbName);
    final db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: currentVersion,
        onConfigure: onConfigure == null
            ? null
            : (db) async => onConfigure(db),
        onUpgrade: onUpgrade,
      ),
    );
    _openDatabases.add(db);
    return db;
  }

  /// Assert that `PRAGMA foreign_key_check` returns no violations.
  Future<void> expectFkValid(Database db) async {
    final rows = await db.rawQuery('PRAGMA foreign_key_check');
    expect(
      rows,
      isEmpty,
      reason: 'foreign_key_check violations: $rows',
    );
  }

  /// Count rows in [table].
  Future<int> rowCount(Database db, String table) async {
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Returns true if [column] exists on [table].
  Future<bool> columnExists(
    Database db,
    String table,
    String column,
  ) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.any((row) => row['name'] == column);
  }

  /// Returns true if an index named [indexName] exists in the DB.
  Future<bool> indexExists(Database db, String indexName) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'index' AND name = ?",
      [indexName],
    );
    return rows.isNotEmpty;
  }

  /// Assert that [table] contains exactly [expectedColumns].
  ///
  /// Fails if any expected column is missing. Extra columns are
  /// permitted (migrations are additive by nature) but reported
  /// in the failure message for easier debugging.
  Future<void> expectTableSchema(
    Database db,
    String table,
    Set<String> expectedColumns,
  ) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    final actual = rows.map((r) => r['name']! as String).toSet();
    final missing = expectedColumns.difference(actual);
    expect(
      missing,
      isEmpty,
      reason:
          'Table $table missing columns: $missing '
          '(actual: $actual)',
    );
  }

  /// Close every [Database] opened through this harness and
  /// delete all temp files.
  Future<void> disposeAll() async {
    for (final db in _openDatabases) {
      if (db.isOpen) {
        try {
          await db.close();
        } catch (_) {
          // Ignore — best-effort teardown.
        }
      }
    }
    _openDatabases.clear();
    for (final path in _dbPaths.values) {
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
    _dbPaths.clear();
  }

  List<String> _splitSqlStatements(String raw) {
    // Strip line comments first so a ';' inside a comment cannot
    // terminate a statement prematurely.
    final stripped = _stripComments(raw);
    final buffer = StringBuffer();
    final statements = <String>[];
    var inSingleQuote = false;

    for (var i = 0; i < stripped.length; i++) {
      final ch = stripped[i];
      // '' inside a string toggles inSingleQuote twice, which is correct.
      if (ch == "'") inSingleQuote = !inSingleQuote;
      if (ch == ';' && !inSingleQuote) {
        final stmt = buffer.toString().trim();
        if (stmt.isNotEmpty) statements.add(stmt);
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    final tail = buffer.toString().trim();
    if (tail.isNotEmpty) statements.add(tail);
    return statements;
  }

  /// Strips full-line SQL `--` comments.
  ///
  /// NOTE: Trailing `-- …` comments on the same line as SQL are NOT
  /// stripped. Fixture authors must keep comments on their own lines.
  String _stripComments(String sql) {
    final lines = sql.split('\n');
    final kept = lines.where((line) {
      final trimmed = line.trim();
      return !trimmed.startsWith('--');
    });
    return kept.join('\n');
  }
}
