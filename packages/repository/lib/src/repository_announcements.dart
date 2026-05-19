part of 'repository.dart';

const _tag = 'RepositoryAnnouncements';

/// Announcement operations for Repository.
///
/// Uses an API-first strategy with SQLite cache as fallback:
/// try the network request first; on success cache the result
/// and return it; on failure return cached data if available.
extension RepositoryAnnouncements on Repository {
  /// Fetches all announcements, falling back to cached data
  /// when the API is unreachable.
  Future<List<AnnouncementResponse>> getAnnouncements() async {
    final apiResult = await _networkService.getAnnouncements();

    switch (apiResult) {
      case ApiSuccess(data: final announcements):
        await _cacheAnnouncements(announcements);
        return announcements;

      case ApiFailure(message: final errorMessage):
        AppLogger.w(
          'API failed, attempting cache fallback',
          tag: _tag,
        );
        final cached = await _getCachedAnnouncements();
        if (cached != null) return cached;
        throw Exception(errorMessage);
    }
  }

  /// Fetches a single announcement by [id], falling back to
  /// cached data when the API is unreachable.
  Future<AnnouncementResponse> getAnnouncementById({
    required int id,
  }) async {
    final apiResult =
        await _networkService.getAnnouncementById(id: id);

    switch (apiResult) {
      case ApiSuccess(data: final announcement):
        return announcement;

      case ApiFailure(message: final errorMessage):
        AppLogger.w(
          'API failed for id=$id, attempting cache fallback',
          tag: _tag,
        );
        final cached = await _getCachedAnnouncementById(id);
        if (cached != null) return cached;
        throw Exception(errorMessage);
    }
  }

  // ----------------------------------------------------------
  // Cache helpers
  // ----------------------------------------------------------

  /// Serializes [announcements] to row maps and writes them
  /// to the local database, fully replacing any previous cache.
  Future<void> _cacheAnnouncements(
    List<AnnouncementResponse> announcements,
  ) async {
    try {
      final rows = announcements.map((a) {
        return <String, dynamic>{
          'id': a.id,
          'title': a.title,
          'description': a.description,
          'content':
              a.content != null ? jsonEncode(a.content) : null,
          'created_at': a.createdAt,
          'updated_at': a.updatedAt,
          'deleted_at': a.deletedAt,
        };
      }).toList();

      await _appDatabase.insertAnnouncements(rows);
      AppLogger.d(
        'Cached ${rows.length} announcements',
        tag: _tag,
      );
    } catch (e) {
      AppLogger.e(
        'Failed to cache announcements',
        tag: _tag,
        error: e,
      );
    }
  }

  /// Reads all cached announcements from SQLite and
  /// reconstructs [AnnouncementResponse] objects.
  ///
  /// Returns null when no cached data is available so the
  /// caller can distinguish "empty cache" from "empty list".
  Future<List<AnnouncementResponse>?> _getCachedAnnouncements(
  ) async {
    try {
      final rows = await _appDatabase.getAnnouncements();
      if (rows.isEmpty) return null;

      final announcements = rows.map(_rowToAnnouncement).toList();
      AppLogger.d(
        'Returning ${announcements.length} cached announcements',
        tag: _tag,
      );
      return announcements;
    } catch (e) {
      AppLogger.e(
        'Failed to read cached announcements',
        tag: _tag,
        error: e,
      );
      return null;
    }
  }

  /// Reads a single cached announcement by [id].
  Future<AnnouncementResponse?> _getCachedAnnouncementById(
    int id,
  ) async {
    try {
      final row = await _appDatabase.getAnnouncementById(id);
      if (row == null) return null;

      final announcement = _rowToAnnouncement(row);
      AppLogger.d(
        'Returning cached announcement id=$id',
        tag: _tag,
      );
      return announcement;
    } catch (e) {
      AppLogger.e(
        'Failed to read cached announcement id=$id',
        tag: _tag,
        error: e,
      );
      return null;
    }
  }

  /// Converts a raw SQLite row map into an
  /// [AnnouncementResponse], deserializing the JSON-encoded
  /// `content` column back to a `Map<String, dynamic>?`.
  AnnouncementResponse _rowToAnnouncement(
    Map<String, dynamic> row,
  ) {
    final contentString = row['content'] as String?;
    Map<String, dynamic>? contentMap;
    if (contentString != null && contentString.isNotEmpty) {
      contentMap =
          jsonDecode(contentString) as Map<String, dynamic>;
    }

    return AnnouncementResponse(
      id: row['id'] as int,
      title: row['title'] as String,
      description: row['description'] as String?,
      content: contentMap,
      createdAt: row['created_at'] as String,
      updatedAt: row['updated_at'] as String,
      deletedAt: row['deleted_at'] as String?,
    );
  }
}
