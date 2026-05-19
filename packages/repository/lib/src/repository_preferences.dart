part of 'repository.dart';

/// Preferences and settings operations for Repository
extension RepositoryPreferences on Repository {
  /// Load cached preference data
  Future<PreferenceData> loadCachedData() async {
    return PreferenceData(
      selectedRouteId: await _appPreferences.getSelectedRoute(),
      selectedStartCityId: await _appPreferences.getSelectedStartCity(),
      selectedEndCityId: await _appPreferences.getSelectedEndCity(),
      darkModeEnabled: await _appPreferences.getDarkModeEnabled(),
      language: await _appPreferences.getLanguage(),
      unit: await _appPreferences.getUnit(),
      theme: await _appPreferences.getTheme(),
    );
  }

  /// Set selected route
  Future<void> setSelectedRoute(int value) async {
    await _appPreferences.setSelectedRoute(value);
  }

  /// Set selected start city
  Future<void> setSelectedStartCity(int value) async {
    await _appPreferences.setSelectedStartCity(value);
  }

  /// Set selected end city
  Future<void> setSelectedEndCity(int value) async {
    await _appPreferences.setSelectedEndCity(value);
  }

  /// Set dark mode enabled
  Future<void> setDarkModeEnabled(bool value) async {
    await _appPreferences.setDarkModeEnabled(value);
  }

  /// Set language
  Future<void> setLanguage(String value) async {
    await _appPreferences.setLanguage(value);
  }

  /// Clear all cached preferences
  Future<void> clearCache() async {
    await _appPreferences.clearAll();
  }

  /// Clear selected end city
  Future<void> clearSelectedEndCity() async {
    await _appPreferences.clearSelectedEndCity();
  }

  /// Clear selected start city
  Future<void> clearSelectedStartCity() async {
    await _appPreferences.clearSelectedStartCity();
  }

  /// Clear selected route
  Future<void> clearSelectedRoute() async {
    await _appPreferences.clearSelectedRoute();
  }

  /// Set unit preference
  Future<void> setUnit(String value) async {
    await _appPreferences.setUnit(value);
  }

  /// Set theme preference
  Future<void> setTheme(String value) async {
    await _appPreferences.setTheme(value);
  }

  /// Set do not ask location required flag
  Future<void> setDoNotAskLocationRequired(bool value) async {
    await _appPreferences.setDoNotAskLocationRequired(value);
  }

  /// Get do not ask location required flag
  Future<bool> getDoNotAskLocationRequired() async {
    return _appPreferences.getDoNotAskLocationRequired();
  }

  /// Set do not ask share to report flag
  Future<void> setDoNotAskShareToReport(bool value) async {
    await _appPreferences.setDoNotAskShareToReport(value);
  }

  /// Get do not ask share to report flag
  Future<bool> getDoNotAskShareToReport() async {
    return _appPreferences.getDoNotAskShareToReport();
  }

  /// Set location accuracy denied flag
  Future<void> setLocationAccuracyDenied(bool value) async {
    await _appPreferences.setLocationAccuracyDenied(value);
  }

  /// Get location accuracy denied flag
  Future<bool> getLocationAccuracyDenied() async {
    return _appPreferences.getLocationAccuracyDenied();
  }

  /// Set do not ask in app review flag
  Future<void> setDoNotAskInAppReview(bool value) async {
    await _appPreferences.setDoNotAskInAppReview(value);
  }

  /// Get do not ask in app review flag
  Future<bool> getDoNotAskInAppReview() async {
    return _appPreferences.getDoNotAskInAppReview();
  }

  /// Set in app review show times
  Future<void> setInAppReviewShowTimes(int value) async {
    await _appPreferences.setInAppReviewShowTimes(value);
  }

  /// Get in app review show times
  Future<int?> getInAppReviewShowTimes() async {
    return _appPreferences.getInAppReviewShowTimes();
  }

  /// Set select destination check points
  Future<void> setSelectDestinationCheckPoints(DateTime? value) async {
    if (value == null) {
      return _appPreferences.removeSelectDestinationCheckPoints();
    }
    return _appPreferences.setSelectDestinationCheckPoints(value);
  }

  /// Get select destination check points
  Future<DateTime?> getSelectDestinationCheckPoints() async {
    return _appPreferences.getSelectDestinationCheckPoints();
  }

  /// Set do not ask stage planner announcement flag
  Future<void> setDoNotAskStagePlannerAnnouncement(bool value) async {
    await _appPreferences.setDoNotAskStagePlannerAnnouncement(value);
  }

  /// Get do not ask stage planner announcement flag
  Future<bool> getDoNotAskStagePlannerAnnouncement() async {
    return _appPreferences.getDoNotAskStagePlannerAnnouncement();
  }

  /// Get has seen notification prompt flag
  Future<bool> getHasSeenNotificationPrompt() =>
      _appPreferences.getHasSeenNotificationPrompt();

  /// Set has seen notification prompt flag
  Future<void> setHasSeenNotificationPrompt({
    required bool value,
  }) =>
      _appPreferences.setHasSeenNotificationPrompt(
        value: value,
      );

  /// Get announcement IDs marked as read (persisted on device).
  Future<Set<int>> getAnnouncementReadIds() =>
      _appPreferences.getAnnouncementReadIds();

  /// Mark an announcement as read (persists on device).
  Future<void> addAnnouncementReadId(int id) =>
      _appPreferences.addAnnouncementReadId(id);

  /// Replace all announcement read IDs (persists on device).
  Future<void> setAnnouncementReadIds(Set<int> ids) =>
      _appPreferences.setAnnouncementReadIds(ids);

  /// Set show new label on plan tab flag
  Future<void> setShowNewLabelOnPlanTab(bool value) async {
    await _appPreferences.setShowNewLabelOnPlanTab(value);
  }

  /// Get show new label on plan tab flag
  Future<bool> getShowNewLabelOnPlanTab() async {
    return _appPreferences.getShowNewLabelOnPlanTab();
  }

  /// Get optional upgrade minimum build from Firebase config
  Future<int?> getOptionalUpgradeMinBuild() async {
    return _firebaseConfigDataSource.getOptionalUpgradeMinBuild();
  }

  /// Get custom trail feature flag from Firebase Remote Config.
  Future<bool> getCustomTrailEnabled() async {
    return _firebaseConfigDataSource.getCustomTrailEnabled();
  }

  /// Get journey planner feature flag from Firebase Remote Config.
  Future<bool> getJourneyPlannerEnabled() async {
    return _firebaseConfigDataSource.getJourneyPlannerEnabled();
  }
}
