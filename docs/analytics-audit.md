# Analytics Tracking Audit Report

**Date:** 2026-04-02
**Branch:** `feature/amplitude-tracking`
**Providers:** Firebase Analytics + Amplitude (conditional, prod only)

---

## 1. Architecture Summary

| Component | File | Role |
|---|---|---|
| `IAnalyticsService` | `analytics_services.dart` | Interface: `trackEvent`, `trackScreen`, `setUserId` |
| `AnalyticsService` | `analytics_services.dart` | Firebase impl, auto-injects `language` param |
| `AmplitudeAnalyticsService` | `amplitude_analytics_service.dart` | Amplitude impl |
| `CompositeAnalyticsService` | `composite_analytics_service.dart` | Fan-out to all providers |
| `AnalyticsEvent` | `analytics_event.dart` | Base class: `name` + `properties` |
| `track()` extension | `analytics_services.dart` | Typed event → `trackEvent()` bridge |

**Total typed event classes:** 66 across 11 files

---

## 2. User ID Management

### Current State

| Flow | File | Line | Action | Status |
|---|---|---|---|---|
| Google sign-in success | `login_cubit.dart` | 48 | `setUserId(result.user?.id.toString())` | OK |
| Apple sign-in success | `login_cubit.dart` | 103 | `setUserId(result.user?.id.toString())` | OK |
| Proceed as guest | `login_cubit.dart` | 130 | No `setUserId` call | OK (intentional) |
| Sign out | `more_screen.dart` | 462 | `setUserId()` (null) | OK |
| Delete account | `more_screen.dart` | 109 | `setUserId()` (null) | OK |

### Issues

- **No `setUserId` on app relaunch for returning users.** If a user is already logged in and reopens the app, `setUserId` is never called because login flow is skipped. Amplitude creates a new anonymous session. Firebase may or may not retain userId from local cache, but Amplitude SDK initializes fresh.
  - **Fix:** Call `setUserId` during app init if a stored credential exists.

---

## 3. User Properties — NOT IMPLEMENTED

The `IAnalyticsService` interface has **no** `setUserProperties` method. Neither Firebase nor Amplitude user properties are being set.

### Recommended User Properties for Cohort Analysis

| Property | Source | Purpose |
|---|---|---|
| `language` | `AppPreferences.getLanguage()` | Segment by language |
| `unit_preference` | `AppPreferences.getUnit()` | km vs miles users |
| `theme` | `AppPreferences.getTheme()` | Light vs dark |
| `is_authenticated` | `Repository.isAuthenticated()` | Guest vs signed-in |
| `auth_provider` | Login type stored | Google vs Apple |
| `plan_count` | `StagePlanRepository` | Power users vs casual |
| `favorite_count` | `AppDatabase` | Engagement level |
| `app_version` | `PackageInfo.version` | Version adoption |
| `os` | `Platform.isIOS / isAndroid` | Platform split |
| `first_seen_date` | Stored on first launch | Retention cohorts |

**Impact:** Without user properties, Amplitude/Firebase cohort builder is limited to event-only segmentation. Adding even `language`, `is_authenticated`, and `plan_count` would significantly improve segmentation.

---

## 4. Screen View Tracking

### Current State

| Mechanism | File | Coverage |
|---|---|---|
| `RouterObserver` | `router_observer.dart` | Auto-tracks `didPush` and `didReplace` for named routes |
| Tab switch | `root_screen.dart:565` | Tracks tab name on bottom nav tap |

**Status:** Reasonable coverage via GoRouter observer. Both Firebase and Amplitude receive screen events through the composite.

### Gap

- **No tracking of back navigation** (`didPop` not overridden in `RouterObserver`). Pop events are invisible.
- Modal/dialog opens are not tracked (e.g., date picker, confirmation dialogs).

---

## 5. Raw `trackEvent()` Calls — Still in Repository Layer

The `packages/repository/` layer still uses raw string-based `trackEvent()` instead of typed events:

### `repository_favorites.dart`

| Event | Properties | Call Site |
|---|---|---|
| `favorite_added` | `albergue_id`, `city_id`, `route_id` | `addFavoriteAlbergue()` |
| `favorite_removed` | `albergue_id`, `city_id`, `route_id` | `removeFavoriteAlbergue()` |

### `repository_data_sync.dart` (~16 calls)

| Event | Properties | Call Site |
|---|---|---|
| `data_fetched` | `data: 'latest_updated'` | `fetchLatestUpdated()` |
| `data_fetched` | `data: 'routes'` | `fetchAndSaveRoutes()` |
| `data_fetch_failed` | `data: 'routes'` | `fetchAndSaveRoutes()` error |
| `data_fetched` | `data: 'route_points'` | `fetchAndSaveRoutePoints()` |
| `data_fetch_failed` | `data: 'route_points'` | error case |
| `data_fetched` | `data: 'alt_route_points'` | `fetchAndSaveAltRoutePoints()` |
| `data_fetch_failed` | `data: 'alt_route_points'` | error case |
| `data_fetched` | `data: 'cities'` | `fetchAndSaveCities()` |
| `data_fetch_failed` | `data: 'cities'` | error case |
| `data_fetched` | `data: 'albergues'` | `fetchAndSaveAlbergues()` |
| `data_fetch_failed` | `data: 'albergues'` | error case |
| `data_fetched` | `data: 'albergue_user_images'` | `fetchAndSaveAlbergueUserImages()` |
| `data_fetch_failed` | `data: 'albergue_user_images'` | error case |
| `data_fetched` | `data: 'announcements'` | `fetchAndCacheAnnouncements()` |
| `data_fetch_failed` | `data: 'announcements'` | error case |

### Recommendation

- **`data_fetched` / `data_fetch_failed` are noisy internal events** — they fire on every app data refresh (6+ entities each time). This generates high event volume with low analytical value. Consider removing or downsampling these to a single `data_sync_completed` / `data_sync_failed` summary event.
- **`favorite_added` / `favorite_removed` are valuable** — should be converted to typed events for consistency.

---

## 6. Missing Tracking — High Priority

### 6a. Announcement Views

| Action | File | Importance |
|---|---|---|
| User opens an announcement | `announcements_screen.dart` | **HIGH** |

- No tracking when user taps an announcement. Key content engagement metric.
- **Suggested:** `AnnouncementViewedEvent(announcementId, title)`

### 6b. Favorite Toggle (UI layer)

| Action | File | Importance |
|---|---|---|
| User taps favorite/save button | `favorite_cubit.dart` | **HIGH** |

- Repository layer tracks `favorite_added`/`favorite_removed` (raw), but no typed event exists.
- **Suggested:** Convert to typed `FavoriteToggledEvent(albergueId, cityId, routeId, isFavorited)`

### 6c. Albergue Detail View

| Action | File | Importance |
|---|---|---|
| User opens albergue detail screen | `albergue_details_screen.dart` | **HIGH** |

- Most important content screen. We track actions within it (share, feedback, booking) but not the view itself.
- **Suggested:** `AlbergueDetailViewedEvent(albergueId, albergueName, cityId, routeId)`

### 6d. City Detail View

| Action | File | Importance |
|---|---|---|
| User opens city detail screen | `city_details_screen.dart` | **MEDIUM** |

- **Suggested:** `CityDetailViewedEvent(cityId, cityName, routeId)`

### 6e. Plan List View / Plan Selected

| Action | File | Importance |
|---|---|---|
| User taps a plan to view details | `plan_cubit.dart` | **MEDIUM** |

- We track plan CRUD, but not which plan users view most.
- **Suggested:** `PlanDetailViewedEvent(planId, routeId, routeName, stageCount)`

---

## 7. Missing Tracking — Medium Priority

| Action | File | Suggested Event | Notes |
|---|---|---|---|
| Tutorial viewed / step reached | `how_to_ninja_screen.dart` | `TutorialStepViewed(step, animationName)` | Onboarding funnel |
| Contact button tapped | `contact_screen.dart` | `ContactTapped(personName)` | Support intent signal |
| "Open Settings" for notifications | `notification_settings_screen.dart` | `NotificationSettingsOpened` | Permission recovery funnel |
| Map marker/cluster tapped | `map_cluster_handler.dart` | `MapMarkerTapped(cityId)` | Map engagement |
| App first launch | N/A (new) | `AppFirstLaunchEvent(version, platform)` | Acquisition tracking |
| App session start | N/A (new) | `AppSessionStartEvent(isAuthenticated)` | DAU/retention |

---

## 8. Potentially Unnecessary Tracking

| Event | Concern | Recommendation |
|---|---|---|
| `data_fetched` (×7 per sync) | Very high volume, low signal. Fires every time app syncs data. | **Remove or merge** into single `DataSyncCompletedEvent(entities: [...])` |
| `data_fetch_failed` (×7) | Same issue — noisy per-entity failure tracking. | **Merge** into single `DataSyncFailedEvent(entity, error)` |
| `load_route_cached_data` | Fires on every app start with cached prefs. Low value. | **Consider removing** — these are just prefs, not user actions |
| `filter_destinations` + `filter_destinations_filtered` | Two events for the same filter action (before and after). | **Keep one** — `filter_destinations_filtered` with result count is sufficient |
| `launch_url_safely` | Tracks every external URL open. Could be noisy. | **Keep** but only if URL analysis is useful; consider sampling |
| `stage_date_conflict` | Event class exists but unclear if it's ever fired after optional-dates migration. | **Verify** if still triggered or dead code |

---

## 9. Events That Need More Properties

| Event | Missing Properties | Why |
|---|---|---|
| `SignInSuccessEvent` | `is_new_user` (first login vs returning) | Distinguish acquisition vs retention |
| `SignOutEvent` | `session_duration_ms`, `plan_count` | Churn context |
| `ProceedAsGuestEvent` | `had_previous_account` | Re-engagement signal |
| `PlanRenamedEvent` | `routeId`, `routeName` | Segment by route |
| `QrImportCancelledEvent` | `route_ids`, `route_names` | Understand which routes get abandoned |
| `CloudSyncStartedEvent` | `is_first_sync` | Distinguish onboarding sync from routine |
| `DeepLinkOpenedEvent` | `type` (albergue/plan/city/announcement), `resolved` (true/false) | Deep link conversion |
| `MyLocationClickedEvent` | `has_location` (did we actually get a location?) | Permission vs actual success |
| `NotificationPermissionPromptedEvent` | `is_first_prompt`, `screen_context` | Understand prompt timing |
| `UpdateNowPressedEvent` | `current_version`, `available_version` | Version adoption |

---

## 10. Amplitude-Specific Gaps

### No `Identify` Call

Amplitude's `Identify` API (`_amplitude.identify(...)`) is not used anywhere. This means:
- No user properties are set in Amplitude
- Cohort builder cannot filter by user attributes
- No `$set`, `$setOnce`, `$add`, or `$append` operations

### No Revenue Tracking

If the app ever monetizes (donations, premium features), `Amplitude.revenue()` is not plumbed.

### No Session Management

Amplitude SDK handles sessions automatically, but there's no custom session configuration (e.g., `minTimeBetweenSessionsMillis`). Default is 5 minutes, which may be appropriate for a travel app.

### No Flush on Logout

When `setUserId(null)` is called on logout, events in the Amplitude buffer may still be attributed to the old user. Consider calling `_amplitude.flush()` before clearing userId.

---

## 11. Summary of Recommendations

### Critical (do now)

1. **Set userId on app relaunch** for returning authenticated users
2. **Add `setUserProperties` to `IAnalyticsService`** and set at least: `language`, `is_authenticated`, `auth_provider`, `plan_count`, `app_version`
3. **Flush Amplitude before clearing userId on logout**

### High Priority

4. Add `AlbergueDetailViewedEvent` — most important content screen
5. Add `AnnouncementViewedEvent` — content engagement
6. Convert `favorite_added`/`favorite_removed` to typed events
7. Remove or consolidate `data_fetched`/`data_fetch_failed` (reduce event noise)
8. Add `is_new_user` to `SignInSuccessEvent`

### Medium Priority

9. Enrich events per Section 9 table
10. Add `AppSessionStartEvent` for DAU/retention
11. Add `PlanDetailViewedEvent` — content consumption
12. Remove duplicate `filter_destinations` event (keep `filter_destinations_filtered`)
13. Verify `StageDateConflictEvent` is still fired or remove

### Low Priority

14. Add `didPop` tracking to `RouterObserver`
15. Track tutorial onboarding funnel
16. Track map marker interactions
17. Consider Amplitude `Identify` for richer cohort segmentation
