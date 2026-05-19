/// On-disk shape for [AppPreferences] city-pairs export cache.
///
/// One secure-storage key holds a versioned document with many start-city
/// entries so we avoid one key per city (keychain size / read cost).
class CityPairsExportCache {
  CityPairsExportCache._();

  static const int version = 1;
  static const String keyVersion = 'v';
  static const String keyEntries = 'entries';
  static const String keyCachedAt = 'cachedAt';
  static const String keyResponse = 'response';

  static Map<String, dynamic> ensureDocument(Map<String, dynamic>? raw) {
    if (raw == null) {
      return {keyVersion: version, keyEntries: <String, dynamic>{}};
    }
    final v = raw[keyVersion];
    final entriesRaw = raw[keyEntries];
    if (v != version || entriesRaw is! Map) {
      return {keyVersion: version, keyEntries: <String, dynamic>{}};
    }
    return {
      keyVersion: version,
      keyEntries: Map<String, dynamic>.from(entriesRaw),
    };
  }

  /// Removes entries with missing [keyCachedAt], corrupt shape, or age
  /// [>= ttl] relative to [nowUtc] (same rule as [getValidResponse]).
  static ({Map<String, dynamic> document, bool didRemoveAny}) pruneExpired(
    Map<String, dynamic> doc,
    DateTime nowUtc,
    Duration ttl,
  ) {
    final d = ensureDocument(doc);
    final entries = Map<String, dynamic>.from(
      d[keyEntries] as Map<String, dynamic>,
    );
    final keysToRemove = <String>[];
    for (final e in entries.entries) {
      if (e.value is! Map) {
        keysToRemove.add(e.key);
        continue;
      }
      final m = e.value as Map;
      final at = DateTime.tryParse(m[keyCachedAt] as String? ?? '');
      if (at == null) {
        keysToRemove.add(e.key);
        continue;
      }
      if (nowUtc.difference(at.toUtc()) >= ttl) {
        keysToRemove.add(e.key);
      }
    }
    for (final k in keysToRemove) {
      entries.remove(k);
    }
    return (
      document: {keyVersion: version, keyEntries: entries},
      didRemoveAny: keysToRemove.isNotEmpty,
    );
  }

  /// Returns the cached API-style response map when [startCityId] is present
  /// and `nowUtc - cachedAt < ttl`. When `>= ttl`, returns null (refetch).
  static Map<String, dynamic>? getValidResponse(
    Map<String, dynamic> doc,
    int startCityId,
    DateTime nowUtc,
    Duration ttl,
  ) {
    final entries = doc[keyEntries];
    if (entries is! Map) return null;
    final entry = entries['$startCityId'];
    if (entry is! Map) return null;
    final at = DateTime.tryParse(entry[keyCachedAt] as String? ?? '');
    if (at == null) return null;
    if (nowUtc.difference(at.toUtc()) >= ttl) return null;
    final response = entry[keyResponse];
    if (response is! Map) return null;
    return Map<String, dynamic>.from(response);
  }

  /// Inserts or replaces [startCityId] and drops oldest entries when over
  /// [maxEntries] (by [keyCachedAt], ascending).
  static Map<String, dynamic> upsert(
    Map<String, dynamic> doc,
    int startCityId,
    Map<String, dynamic> responseJson,
    DateTime nowUtc,
    int maxEntries,
  ) {
    final d = ensureDocument(doc);
    final entries = Map<String, dynamic>.from(
      d[keyEntries] as Map<String, dynamic>,
    );
    final key = '$startCityId';
    entries[key] = {
      keyCachedAt: nowUtc.toUtc().toIso8601String(),
      keyResponse: responseJson,
    };

    while (entries.length > maxEntries) {
      String? oldestKey;
      var oldestAt = DateTime.now().toUtc();
      for (final e in entries.entries) {
        final rawEntry = e.value;
        if (rawEntry is! Map) {
          oldestKey = e.key;
          oldestAt = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
          break;
        }
        final at = DateTime.tryParse(
              rawEntry[keyCachedAt] as String? ?? '',
            ) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
        final atUtc = at.toUtc();
        if (oldestKey == null || atUtc.isBefore(oldestAt)) {
          oldestKey = e.key;
          oldestAt = atUtc;
        }
      }
      if (oldestKey != null) {
        entries.remove(oldestKey);
      } else {
        entries.remove(entries.keys.first);
      }
    }

    return {keyVersion: version, keyEntries: entries};
  }
}
