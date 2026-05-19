import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:storage/storage.dart';
import 'package:uuid/uuid.dart';

const _kErrSecInteractionNotAllowed = '-25308';

class AppPreferences {
  AppPreferences();

  final _preferences = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const USER_CREDENTIAL = 'user_credential';
  static const SELECTED_ROUTE = 'selected_route';
  static const SELECTED_START_CITY = 'selected_start_city';
  static const SELECTED_END_CITY = 'selected_end_city';
  static const LANGUAGE = 'language';
  static const DARK_MODE_ENABLED = 'dark_mode_enabled';
  static const ALBERGUES_LATEST_UPDATE = 'albergues_latest_update';
  static const ALBERGUE_USER_IMAGES_LATEST_UPDATE =
      'albergue_user_images_latest_update';
  static const CITIES_LATEST_UPDATE = 'cities_latest_update';
  static const ROUTES_LATEST_UPDATE = 'routes_latest_update';
  static const ROUTE_POINTS_LATEST_UPDATE = 'route_points_latest_update';
  static const ALT_ROUTE_POINTS_LATEST_UPDATE =
      'alt_route_points_latest_update';
  static const UNIT = 'unit';
  static const THEME = 'theme';
  static const DO_NOT_ASK_LOCATION_REQUIRED = 'do_not_ask_location_required';
  static const DO_NOT_ASK_SHARE_TO_REPORT = 'do_not_ask_share_to_report';
  static const LOCATION_ACCURACY_DENIED = 'location_accuracy_denied';
  static const DO_NOT_ASK_IN_APP_REVIEW = 'do_not_ask_in_app_review';
  static const IN_APP_REVIEW_SHOW_TIMES = 'in_app_review_show_times';
  static const SELECT_DESTINATION_CHECK_POINTS =
      'select_destination_check_points';
  static const PROCEED_AS_GUEST = 'proceed_as_guest';
  static const DO_NOT_ASK_STAGE_PLANNER_ANNOUNCEMENT =
      'do_not_ask_stage_planner_announcement';
  static const SHOW_NEW_LABEL_ON_PLAN_TAB = 'show_new_label_on_plan_tab';
  static const HAS_SEEN_NOTIFICATION_PROMPT =
      'HAS_SEEN_NOTIFICATION_PROMPT';
  static const HAS_REQUESTED_NOTIFICATION_PERMISSION =
      'has_requested_notification_permission';
  static const ANNOUNCEMENTS_SUBSCRIBED = 'announcements_subscribed';
  static const ANNOUNCEMENT_READ_IDS = 'announcement_read_ids';
  /// JSON blob: version + map of startCityId → { cachedAt, response }.
  /// See [CityPairsExportCache].
  static const CITY_PAIRS_EXPORT_CACHE = 'city_pairs_export_cache';
  static const DEVICE_ID = 'device_id';
  static const JUNCTION_MAX_DISTANCE_METERS =
      'junction_max_distance_meters';
  static const _uuid = Uuid();

  /// City pairs export: do not refetch network data more often than this.
  static const Duration cityPairsExportCacheTtl = Duration(days: 1);

  /// Max distinct start cities kept in [CITY_PAIRS_EXPORT_CACHE] (LRU by
  /// [CityPairsExportCache.keyCachedAt]).
  static const int cityPairsExportCacheMaxEntries = 20;

  Future<void> setAlberguesLatestUpdate(DateTime value) async {
    await _preferences.write(
        key: ALBERGUES_LATEST_UPDATE, value: value.toIso8601String());
  }

  Future<DateTime?> getAlberguesLatestUpdate() async {
    final value = await _safeRead(ALBERGUES_LATEST_UPDATE);
    return value != null ? DateTime.parse(value) : null;
  }

  Future<void> setAlbergueUserImagesLatestUpdate(DateTime value) async {
    await _preferences.write(
        key: ALBERGUE_USER_IMAGES_LATEST_UPDATE,
        value: value.toIso8601String());
  }

  Future<DateTime?> getAlbergueUserImagesLatestUpdate() async {
    final value = await _safeRead(ALBERGUE_USER_IMAGES_LATEST_UPDATE);
    return value != null ? DateTime.parse(value) : null;
  }

  Future<void> setCitiesLatestUpdate(DateTime value) async {
    await _preferences.write(
        key: CITIES_LATEST_UPDATE, value: value.toIso8601String());
  }

  Future<DateTime?> getCitiesLatestUpdate() async {
    final value = await _safeRead(CITIES_LATEST_UPDATE);
    return value != null ? DateTime.parse(value) : null;
  }

  Future<void> setRoutesLatestUpdate(DateTime value) async {
    await _preferences.write(
        key: ROUTES_LATEST_UPDATE, value: value.toIso8601String());
  }

  Future<DateTime?> getRoutesLatestUpdate() async {
    final value = await _safeRead(ROUTES_LATEST_UPDATE);
    return value != null ? DateTime.parse(value) : null;
  }

  Future<void> setAltRoutePointsLatestUpdate(DateTime value) async {
    await _preferences.write(
        key: ALT_ROUTE_POINTS_LATEST_UPDATE, value: value.toIso8601String());
  }

  Future<DateTime?> getAltRoutePointsLatestUpdate() async {
    final value = await _safeRead(ALT_ROUTE_POINTS_LATEST_UPDATE);
    return value != null ? DateTime.parse(value) : null;
  }

  Future<void> setRoutePointsLatestUpdate(DateTime value) async {
    await _preferences.write(
        key: ROUTE_POINTS_LATEST_UPDATE, value: value.toIso8601String());
  }

  Future<DateTime?> getRoutePointsLatestUpdate() async {
    final value = await _safeRead(ROUTE_POINTS_LATEST_UPDATE);
    return value != null ? DateTime.parse(value) : null;
  }

  Future<void> setSelectedRoute(int value) async {
    await _safeWrite(SELECTED_ROUTE, value.toString());
  }

  Future<int?> getSelectedRoute() async {
    final value = await _safeRead(SELECTED_ROUTE);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> setSelectedStartCity(int value) async {
    await _safeWrite(SELECTED_START_CITY, value.toString());
  }

  Future<int?> getSelectedStartCity() async {
    final value = await _safeRead(SELECTED_START_CITY);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> setSelectedEndCity(int value) async {
    await _safeWrite(SELECTED_END_CITY, value.toString());
  }

  Future<int?> getSelectedEndCity() async {
    final value = await _safeRead(SELECTED_END_CITY);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> setDarkModeEnabled(bool value) async {
    await _preferences.write(key: DARK_MODE_ENABLED, value: value.toString());
  }

  Future<bool> getDarkModeEnabled() async {
    final value = await _safeRead(DARK_MODE_ENABLED);
    return value == 'true';
  }

  Future<void> setLanguage(String value) async {
    await _safeWrite(LANGUAGE, value);
  }

  Future<String?> getLanguage() async {
    return await _safeRead(LANGUAGE);
  }

  Future<void> clearAll() async {
    await _preferences.deleteAll();
  }

  /// Safely reads a value from secure storage with error handling
  Future<String?> _safeRead(String key) async {
    try {
      return await _preferences.read(key: key);
    } catch (e) {
      // If decryption fails due to BadPaddingException, clear the corrupted data
      if (e is PlatformException && e.code == 'BadPaddingException') {
        await _preferences.deleteAll();
        return null;
      }
      if (e.toString().contains('BadPaddingException') ||
          e.toString().contains('BAD_DECRYPT')) {
        await _preferences.delete(key: key);
      }
      return null;
    }
  }

  /// Does not throw when iOS returns -25308 (keychain unavailable at launch/background).
  Future<void> _safeWrite(String key, String value) async {
    try {
      await _preferences.write(key: key, value: value);
    } on PlatformException catch (e) {
      if (e.code == _kErrSecInteractionNotAllowed ||
          e.message?.contains('User interaction is not allowed') == true) {
        return;
      }
      rethrow;
    }
  }

  Future<void> clearSelectedStartCity() async {
    await _preferences.delete(key: SELECTED_START_CITY);
  }

  Future<void> clearSelectedEndCity() async {
    await _preferences.delete(key: SELECTED_END_CITY);
  }

  Future<void> clearSelectedRoute() async {
    await _preferences.delete(key: SELECTED_ROUTE);
  }

  Future<void> setUnit(String value) async {
    await _safeWrite(UNIT, value);
  }

  Future<String?> getUnit() async {
    return await _safeRead(UNIT);
  }

  Future<void> setTheme(String value) async {
    await _safeWrite(THEME, value);
  }

  Future<String?> getTheme() async {
    return await _safeRead(THEME);
  }

  Future<void> setDoNotAskLocationRequired(bool value) async {
    await _preferences.write(
        key: DO_NOT_ASK_LOCATION_REQUIRED, value: value.toString());
  }

  Future<bool> getDoNotAskLocationRequired() async {
    final value = await _safeRead(DO_NOT_ASK_LOCATION_REQUIRED);
    return value != null ? bool.tryParse(value) ?? false : false;
  }

  Future<void> setDoNotAskShareToReport(bool value) async {
    await _preferences.write(
        key: DO_NOT_ASK_SHARE_TO_REPORT, value: value.toString());
  }

  Future<bool> getDoNotAskShareToReport() async {
    final value = await _safeRead(DO_NOT_ASK_SHARE_TO_REPORT);
    return value != null ? bool.tryParse(value) ?? false : false;
  }

  Future<void> setLocationAccuracyDenied(bool value) async {
    await _preferences.write(
        key: LOCATION_ACCURACY_DENIED, value: value.toString());
  }

  Future<bool> getLocationAccuracyDenied() async {
    final value = await _safeRead(LOCATION_ACCURACY_DENIED);
    return value != null ? bool.tryParse(value) ?? false : false;
  }

  Future<void> setDoNotAskInAppReview(bool value) async {
    await _preferences.write(
        key: DO_NOT_ASK_IN_APP_REVIEW, value: value.toString());
  }

  Future<bool> getDoNotAskInAppReview() async {
    final value = await _safeRead(DO_NOT_ASK_IN_APP_REVIEW);
    return value != null ? bool.tryParse(value) ?? false : false;
  }

  Future<void> setInAppReviewShowTimes(int value) async {
    await _preferences.write(
        key: IN_APP_REVIEW_SHOW_TIMES, value: value.toString());
  }

  Future<int?> getInAppReviewShowTimes() async {
    final value = await _safeRead(IN_APP_REVIEW_SHOW_TIMES);
    return value != null ? int.tryParse(value) ?? 0 : 0;
  }

  Future<void> setSelectDestinationCheckPoints(DateTime value) async {
    await _preferences.write(
        key: SELECT_DESTINATION_CHECK_POINTS, value: value.toIso8601String());
  }

  Future<DateTime?> getSelectDestinationCheckPoints() async {
    final value = await _safeRead(SELECT_DESTINATION_CHECK_POINTS);
    return DateTime.tryParse(value.toString());
  }

  Future<void> removeSelectDestinationCheckPoints() async {
    await _preferences.delete(key: SELECT_DESTINATION_CHECK_POINTS);
  }

  Future<void> setUserCredential(CredentialEntity value) async {
    await _preferences.write(
        key: USER_CREDENTIAL, value: jsonEncode(value.toJson()));
  }

  Future<CredentialEntity?> getUserCredential() async {
    try {
      final value = await _safeRead(USER_CREDENTIAL);
      return value != null
          ? CredentialEntity.fromJson(jsonDecode(value))
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    final userCredential = await getUserCredential();
    return userCredential?.accessToken;
  }

  Future<String?> getRefreshToken() async {
    final userCredential = await getUserCredential();
    return userCredential?.refreshToken;
  }

  Future<void> logout() async {
    await _preferences.delete(key: USER_CREDENTIAL);
  }

  Future<bool> isProceedAsGuest() async {
    final value = await _safeRead(PROCEED_AS_GUEST);
    return value != null ? bool.tryParse(value) ?? false : false;
  }

  Future<void> setProceedAsGuest(bool value) async {
    await _preferences.write(key: PROCEED_AS_GUEST, value: value.toString());
  }

  Future<void> setDoNotAskStagePlannerAnnouncement(bool value) async {
    await _preferences.write(
        key: DO_NOT_ASK_STAGE_PLANNER_ANNOUNCEMENT, value: value.toString());
  }

  Future<bool> getDoNotAskStagePlannerAnnouncement() async {
    final value = await _safeRead(DO_NOT_ASK_STAGE_PLANNER_ANNOUNCEMENT);
    return value != null ? bool.tryParse(value) ?? false : false;
  }

  Future<bool> getHasSeenNotificationPrompt() async {
    final value = await _safeRead(HAS_SEEN_NOTIFICATION_PROMPT);
    return value != null ? bool.tryParse(value) ?? false : false;
  }

  Future<void> setHasSeenNotificationPrompt({
    required bool value,
  }) async {
    await _preferences.write(
      key: HAS_SEEN_NOTIFICATION_PROMPT,
      value: value.toString(),
    );
  }

  Future<bool> getHasRequestedNotificationPermission() async {
    final value =
        await _safeRead(HAS_REQUESTED_NOTIFICATION_PERMISSION);
    return value != null
        ? bool.tryParse(value) ?? false
        : false;
  }

  Future<void> setHasRequestedNotificationPermission({
    required bool value,
  }) async {
    await _safeWrite(
      HAS_REQUESTED_NOTIFICATION_PERMISSION,
      value.toString(),
    );
  }

  Future<void> setShowNewLabelOnPlanTab(bool value) async {
    await _preferences.write(
        key: SHOW_NEW_LABEL_ON_PLAN_TAB, value: value.toString());
  }

  Future<bool> getShowNewLabelOnPlanTab() async {
    final value = await _safeRead(SHOW_NEW_LABEL_ON_PLAN_TAB);
    return value != null ? bool.tryParse(value) ?? true : true;
  }

  Future<bool> getAnnouncementsSubscribed() async {
    final value = await _safeRead(ANNOUNCEMENTS_SUBSCRIBED);
    return value != null ? bool.tryParse(value) ?? true : true;
  }

  Future<void> setAnnouncementsSubscribed({
    required bool value,
  }) async {
    await _safeWrite(ANNOUNCEMENTS_SUBSCRIBED, value.toString());
  }

  Future<Set<int>> getAnnouncementReadIds() async {
    final value = await _safeRead(ANNOUNCEMENT_READ_IDS);
    if (value == null || value.isEmpty) return {};
    try {
      final list = jsonDecode(value) as List<dynamic>;
      return list.map((e) => (e as num).toInt()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> addAnnouncementReadId(int id) async {
    final ids = await getAnnouncementReadIds();
    if (ids.contains(id)) return;
    ids.add(id);
    await _safeWrite(ANNOUNCEMENT_READ_IDS, jsonEncode(ids.toList()));
  }

  Future<void> setAnnouncementReadIds(Set<int> ids) async {
    await _safeWrite(ANNOUNCEMENT_READ_IDS, jsonEncode(ids.toList()));
  }

  /// Serialized city-pairs-by-start-city API response JSON when fresh.
  Future<Map<String, dynamic>?> getCityPairsExportCacheIfValid(
    int startCityId,
  ) async {
    final raw = await _safeRead(CITY_PAIRS_EXPORT_CACHE);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final nowUtc = DateTime.now().toUtc();
      final pruned = CityPairsExportCache.pruneExpired(
        decoded,
        nowUtc,
        cityPairsExportCacheTtl,
      );
      if (pruned.didRemoveAny) {
        await _safeWrite(
          CITY_PAIRS_EXPORT_CACHE,
          jsonEncode(pruned.document),
        );
      }
      return CityPairsExportCache.getValidResponse(
        pruned.document,
        startCityId,
        nowUtc,
        cityPairsExportCacheTtl,
      );
    } catch (_) {
      return null;
    }
  }

  /// Merges [responseJson] for [startCityId] into the shared cache document.
  Future<void> setCityPairsExportCache(
    int startCityId,
    Map<String, dynamic> responseJson,
  ) async {
    Map<String, dynamic> doc;
    final raw = await _safeRead(CITY_PAIRS_EXPORT_CACHE);
    try {
      if (raw != null && raw.isNotEmpty) {
        doc = jsonDecode(raw) as Map<String, dynamic>;
      } else {
        doc = <String, dynamic>{};
      }
    } catch (_) {
      doc = <String, dynamic>{};
    }
    final nowUtc = DateTime.now().toUtc();
    final pruned = CityPairsExportCache.pruneExpired(
      doc,
      nowUtc,
      cityPairsExportCacheTtl,
    );
    final updated = CityPairsExportCache.upsert(
      pruned.document,
      startCityId,
      responseJson,
      nowUtc,
      cityPairsExportCacheMaxEntries,
    );
    await _safeWrite(CITY_PAIRS_EXPORT_CACHE, jsonEncode(updated));
  }

  /// Dev/staging: persisted junction distance threshold
  /// (meters). Null when the user has not overridden the
  /// default.
  Future<double?> getJunctionMaxDistanceMeters() async {
    final value = await _safeRead(JUNCTION_MAX_DISTANCE_METERS);
    if (value == null) return null;
    return double.tryParse(value);
  }

  /// Persist the junction distance threshold override.
  Future<void> setJunctionMaxDistanceMeters(double meters) async {
    await _safeWrite(
      JUNCTION_MAX_DISTANCE_METERS,
      meters.toString(),
    );
  }

  /// Get or generate a persistent device ID for sync
  Future<String> getDeviceId() async {
    final existing = await _safeRead(DEVICE_ID);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _uuid.v4();
    await _safeWrite(DEVICE_ID, id);
    return id;
  }

  /// Get the device model name (e.g. "Pixel 7 Pro", "iPhone 15 Pro")
  String? _cachedDeviceName;
  Future<String> getDeviceName() async {
    if (_cachedDeviceName != null) return _cachedDeviceName!;
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        _cachedDeviceName = '${info.brand} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        _cachedDeviceName = info.utsname.machine;
      } else {
        _cachedDeviceName = Platform.operatingSystem;
      }
    } catch (_) {
      _cachedDeviceName = Platform.operatingSystem;
    }
    return _cachedDeviceName!;
  }
}
