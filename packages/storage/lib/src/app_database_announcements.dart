part of 'app_database.dart';

/// Announcement cache operations for AppDatabase
extension AppDatabaseAnnouncements on AppDatabase {
  static bool _announcementsTableInitialized = false;

  /// Ensures the announcements table exists without bumping
  /// the database version (lazy initialization via
  /// CREATE TABLE IF NOT EXISTS).
  Future<void> _ensureAnnouncementsTable() async {
    if (_announcementsTableInitialized) return;
    final db = await database;
    await db.execute('''
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
    _announcementsTableInitialized = true;
  }

  /// Returns all cached announcements ordered by newest first.
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    await _ensureAnnouncementsTable();
    final db = await database;
    return db.transaction((txn) async {
      return txn.query(
        'announcements',
        orderBy: 'created_at DESC',
      );
    });
  }

  /// Returns a single cached announcement by [id], or null
  /// if not found.
  Future<Map<String, dynamic>?> getAnnouncementById(
    int id,
  ) async {
    await _ensureAnnouncementsTable();
    final db = await database;
    return db.transaction((txn) async {
      final result = await txn.query(
        'announcements',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isEmpty ? null : result.first;
    });
  }

  /// Replaces the entire announcements cache with [rows].
  ///
  /// Runs a delete-all + batch insert inside a single
  /// transaction so the cache is always consistent.
  Future<void> insertAnnouncements(
    List<Map<String, dynamic>> rows,
  ) async {
    await _ensureAnnouncementsTable();
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('announcements');
      final batch = txn.batch();
      for (final row in rows) {
        batch.insert(
          'announcements',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}
