# Technical Debt & Issues Report

**Project:** Camino Ninja Flutter
**Generated:** December 2024
**Scope:** Full codebase analysis covering security, performance, error handling, permissions, UI/UX, and code quality

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Critical Issues (Immediate Action Required)](#critical-issues)
3. [High Priority Issues](#high-priority-issues)
4. [Medium Priority Issues](#medium-priority-issues)
5. [Low Priority Issues](#low-priority-issues)
6. [Recommendations by Category](#recommendations-by-category)
7. [Files Requiring Most Attention](#files-requiring-most-attention)

---

## Executive Summary

| Category | Critical | High | Medium | Low | Total |
|----------|----------|------|--------|-----|-------|
| Security | 1 | 3 | 4 | 2 | 10 |
| Error Handling | 0 | 6 | 4 | 0 | 10 |
| Performance | 0 | 6 | 3 | 2 | 11 |
| Permissions | 0 | 2 | 3 | 1 | 6 |
| Code Quality | 0 | 3 | 6 | 3 | 12 |
| UI/UX | 0 | 2 | 6 | 2 | 10 |
| **Total** | **1** | **22** | **26** | **10** | **59** |

---

## Critical Issues

### SEC-001: Hardcoded Google Maps API Key
**Severity:** CRITICAL
**Category:** Security
**File:** `android/app/src/main/AndroidManifest.xml` (Line 10)

```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="AIzaSyDJVW8HjrpMo8J-d4zS4PxsBxAIqEa-Je8"/>
```

**Impact:**
- API key exposed in source control and compiled APK
- Anyone can extract and abuse the key
- Potential for unexpected billing charges

**Remediation:**
1. Immediately rotate the API key in Google Cloud Console
2. Move API key to `local.properties` (not committed to git)
3. Use Secrets Gradle Plugin for Android
4. Add API key restrictions in Google Cloud Console (app signature, package name)
5. For iOS, use similar approach with `.xcconfig` files

---

## High Priority Issues

### SEC-002: Sensitive Data Logged to Crashlytics
**Severity:** HIGH
**Category:** Security
**File:** `lib/utils/crashlytics_interceptor.dart` (Lines 10-24)

```dart
FirebaseCrashlytics.instance.recordError(
  err,
  err.stackTrace,
  information: [
    'Request: ${err.requestOptions.data}',    // May contain tokens
    'Response: ${err.response?.data}',        // May contain PII
    'Headers: ${err.requestOptions.headers}', // Contains auth headers
  ],
);
```

**Impact:** Authentication tokens and user data sent to Crashlytics logs.

**Remediation:**
- Sanitize headers before logging (remove Authorization, Cookie headers)
- Never log request/response bodies
- Only log URL path, status code, and error type

---

### SEC-003: Debug Print Statements in Production
**Severity:** HIGH
**Category:** Security
**Files:** 20+ locations across codebase

| File | Lines |
|------|-------|
| `lib/app/cubit/app_cubit.dart` | 231 |
| `lib/utils/location_service.dart` | 86, 108 |
| `lib/utils/crashlytics_interceptor.dart` | 10-11 |
| `packages/repository/lib/src/repository.dart` | 46-47 |
| `packages/repository/lib/src/stage_plan_repository.dart` | Multiple |
| `packages/remote_data/lib/src/network_service.dart` | 126-127, 174-175 |

**Impact:** Sensitive information exposed in device logs, accessible via ADB.

**Remediation:**
- Replace all `print()` with `debugPrint()` wrapped in `kDebugMode` checks
- Implement proper logging framework (e.g., `logger` package)
- Add lint rule to prevent `print()` in production code

---

### SEC-004: Missing Certificate Pinning
**Severity:** HIGH
**Category:** Security
**File:** `lib/di/dependency_injection.dart`

**Impact:** App vulnerable to man-in-the-middle attacks on compromised networks.

**Remediation:**
```dart
// Add certificate pinning to Dio
dio.interceptors.add(
  CertificatePinningInterceptor(
    allowedSHAFingerprints: ['YOUR_CERT_SHA256_FINGERPRINT'],
  ),
);
```

---

### ERR-001: Empty Catch Blocks (Silent Error Swallowing)
**Severity:** HIGH
**Category:** Error Handling
**Files:**

| File | Lines | Method |
|------|-------|--------|
| `packages/repository/lib/src/repository.dart` | 824-825, 849-850 | `fetchAndSaveAlberguesRating()` |
| `packages/repository/lib/src/stage_plan_repository.dart` | 53-54 | `validateStagePlanner()` |
| `lib/tabs/plan/cubit/plan_cubit.dart` | 49-50, 69-70, 104-105 | Multiple methods |
| `lib/tabs/plan/screens/plan_detail/cubit/plan_detail_cubit.dart` | 88-89, 105-106, 131-132 | Multiple methods |
| `lib/tabs/route/screens/city_details/cubit/city_details_cubit.dart` | 49-50 | `init()` |
| `lib/utils/safe_launcher.dart` | 32-34, 43-44 | `launchUrlSafely()` |

**Impact:** Errors silently ignored, making debugging impossible.

**Remediation:**
- Log all caught exceptions to Crashlytics
- Emit error states to UI for user feedback
- Remove `// ignore: empty_catches` directives

---

### ERR-002: Missing Dio Timeout Configuration
**Severity:** HIGH
**Category:** Error Handling
**File:** `lib/di/dependency_injection.dart` (Lines 25-30)

```dart
final dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    // Missing: connectTimeout, receiveTimeout, sendTimeout
  ),
);
```

**Impact:** Network requests can hang indefinitely on slow connections.

**Remediation:**
```dart
final dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 60),
  ),
);
```

---

### ERR-003: Unhandled Future Errors
**Severity:** HIGH
**Category:** Error Handling
**File:** `lib/app/cubit/app_cubit.dart` (Lines 256-330)

```dart
Future.wait(fetches)  // No error handling if any fetch fails
```

**Impact:** If one data fetch fails, entire data load fails silently.

**Remediation:**
- Add `.catchError()` to each future
- Use `Future.wait` with `eagerError: false`
- Handle partial failures gracefully

---

### ERR-004: Missing Null Checks Before Collection Access
**Severity:** HIGH
**Category:** Error Handling
**Files:**

| File | Line | Issue |
|------|------|-------|
| `packages/repository/lib/src/repository.dart` | 28 | `data.first` without empty check |
| `lib/tabs/plan/screens/plan_detail/cubit/plan_detail_cubit.dart` | 24 | No null check on `getStagePlanById()` |
| `packages/repository/lib/src/stage_plan_repository.dart` | 45 | `sublist()` without bounds validation |

**Impact:** Potential crashes from `StateError` or `RangeError`.

---

### PERF-001: Database N+1 Query Pattern
**Severity:** HIGH
**Category:** Performance
**File:** `packages/storage/lib/src/app_database.dart` (Lines 810-828)

```dart
// getCityById creates N+1 queries
Future.wait(
  routeIds.map((id) => txn.query('routes', where: 'id = ?', whereArgs: [id]))
)
```

**Impact:** Loading a city with 50 routes = 100+ separate database queries.

**Remediation:**
- Use single query with `WHERE id IN (?)` clause
- Implement eager loading for related entities
- Add database query caching

---

### PERF-002: Memory Leak - Unmanaged Stream Subscription
**Severity:** HIGH
**Category:** Performance
**File:** `lib/tabs/route/screens/elevation/new_elevation_chart.dart` (Lines 227-235)

```dart
@override
void initState() {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    context.read<ElevationCubit>().stream.listen((state) {
      // Stream subscription NEVER cancelled
    });
  });
}

@override
void dispose() {
  _scrollController.dispose();
  // Missing: stream subscription cancellation
}
```

**Remediation:**
```dart
StreamSubscription? _subscription;

@override
void initState() {
  _subscription = context.read<ElevationCubit>().stream.listen(...);
}

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

---

### PERF-003: Uncached Network Images
**Severity:** HIGH
**Category:** Performance
**Files:**
- `lib/tabs/route/screens/albergue_details/gallery_screen.dart` (Lines 189-201)
- `lib/tabs/route/screens/albergue_details/reviews_section.dart` (Lines 174-204)

```dart
// Uses Image.network() without caching
Image.network(imageUrl)

// Should use CachedNetworkImage like albergue_images.dart does
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: itemWidth.toInt(),
  maxWidthDiskCache: (itemWidth * 2).toInt(),
)
```

**Impact:** Images re-downloaded on every view, wasting bandwidth and causing UI stutter.

---

### PERF-004: Missing BlocBuilder buildWhen
**Severity:** HIGH
**Category:** Performance
**File:** `lib/tabs/map/map_screen.dart` (Lines 73-95)

```dart
BlocBuilder<ElevationCubit, ElevationState>(
  // Missing: buildWhen to prevent unnecessary rebuilds
  builder: (context, state) { ... },
)
```

**Remediation:**
```dart
BlocBuilder<ElevationCubit, ElevationState>(
  buildWhen: (previous, current) =>
    previous.routePoints != current.routePoints,
  builder: (context, state) { ... },
)
```

---

### PERF-005: Heavy Computations in Build Methods
**Severity:** HIGH
**Category:** Performance
**File:** `lib/tabs/route/screens/elevation/new_elevation_chart.dart` (Lines 292-359)

```dart
@override
Widget build(BuildContext context) {
  // O(n) reduce operation on every build
  final maxElevation = widget.routePoints
    .map((p) => p.ele)
    .reduce(max);

  // Complex nested object creation every frame
  final chartStyle = ElevationChartStyle(...);
}
```

**Remediation:**
- Memoize expensive calculations
- Move style objects to class fields or use `const`
- Use `useMemoized` from `flutter_hooks` or manual caching

---

### PERM-001: Missing Camera Permission Handling
**Severity:** HIGH
**Category:** Permissions
**File:** `lib/widgets/photo_picker.dart` (Line 119)

```dart
// Directly calls ImagePicker without permission check
ImagePicker().pickMultiImage()
```

**Impact:** No user feedback if permission denied; silent failure.

**Remediation:**
- Check `Permission.photos` before calling ImagePicker
- Show custom rationale dialog before system prompt
- Handle "permanently denied" with settings redirect

---

### PERM-002: Incomplete iOS Permission Strings
**Severity:** HIGH
**Category:** Permissions
**File:** `ios/Runner/Info.plist`

**Missing:**
- `NSCameraUsageDescription` (for camera in image picker)
- `NSPhotoLibraryAddOnlyUsageDescription` (iOS 14+ for photo uploads)
- `NSLocationAlwaysAndWhenInUseUsageDescription` (iOS 11+ replacement)

**Impact:** App rejection on App Store or runtime crashes.

---

### QUAL-001: Missing Unit Tests
**Severity:** HIGH
**Category:** Code Quality

**Current State:** Only 2 test helper files found:
- `test/helpers/helpers.dart`
- `test/helpers/pump_app.dart`

**Missing Tests For:**
- 59+ Cubit/BLoC classes
- Repository layer business logic
- Utility functions (distance calculations, unit conversions)
- Data mappers and converters

**Remediation:**
- Establish minimum 70% coverage threshold
- Prioritize testing for repository and cubit layers
- Add widget tests for complex screens

---

### QUAL-002: Magic Numbers & Hardcoded Constants
**Severity:** HIGH
**Category:** Code Quality

**Duplicated Constants:**

| Constant | Value | Locations |
|----------|-------|-----------|
| Earth Radius | 6371 / 6371e3 / 6371000 | 3 files |
| Max Distance | 5000.0 | 4+ files |
| km/mi Conversion | 0.621371 | 3+ files |
| m/ft Conversion | 3.28084 | 3+ files |

**Remediation:**
Create `lib/constants/` directory:
```dart
// lib/constants/geo.dart
class GeoConstants {
  static const double earthRadiusKm = 6371.0;
  static const double earthRadiusM = 6371000.0;
  static const double maxDistanceFromRouteM = 5000.0;
}

// lib/constants/conversions.dart
class UnitConversions {
  static const double kmToMiles = 0.621371;
  static const double metersToFeet = 3.28084;
}
```

---

### QUAL-003: Very Long Files Needing Refactoring
**Severity:** HIGH
**Category:** Code Quality

| File | Lines | Recommendation |
|------|-------|----------------|
| `packages/storage/lib/src/app_database.dart` | 1449 | Split by operation type |
| `packages/repository/lib/src/repository.dart` | 998 | Split by domain |
| `lib/tabs/route/screens/elevation/new_elevation_chart.dart` | 961 | Extract math utilities |
| `lib/root_screen.dart` | 886 | Extract sub-components |
| `packages/storage/lib/src/stage_planner_database.dart` | 597 | Extract queries |

---

### UI-001: Missing Error State UI
**Severity:** HIGH
**Category:** UI/UX
**Files:**
- `lib/tabs/route/screens/albergue_details/albergue_details_screen.dart` (Lines 179-182)
- `lib/tabs/route/screens/city_details/city_details_screen.dart` (Lines 69-78)
- `lib/tabs/route/screens/select_destination/select_destination_screen.dart` (Lines 103-108)

**Impact:** When API calls fail, users see blank screens or indefinite loading.

**Remediation:**
- Add error state to all Cubit state classes
- Show retry button with error message
- Implement offline fallback messaging

---

### UI-002: Text Overflow Issues
**Severity:** HIGH
**Category:** UI/UX
**Locations:**
- City names in `CityInformationCard`
- Albergue names in list items
- Review content in `ReviewItem`

**Remediation:**
```dart
Text(
  albergue.name,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

---

## Medium Priority Issues

### SEC-006: Debug Provider Check Uses kDebugMode
**File:** `lib/main_production.dart` (Lines 40-56)

**Issue:** `kDebugMode` can be true on release builds with debugging enabled.

**Remediation:** Use flavor-specific checks instead of `kDebugMode`.

---

### SEC-007: Verbose Error Messages to UI
**File:** `packages/remote_data/lib/src/network_service.dart`

```dart
catch (e) {
  return ApiFailure(e.toString()); // Exposes internal details
}
```

**Remediation:** Map exceptions to user-friendly messages.

---

### SEC-008: Missing File Upload Validation
**File:** `packages/remote_data/lib/src/api_client.dart` (Lines 39-42)

**Issue:** No client-side file size or type validation before upload.

---

### SEC-009: Hardcoded Placeholder Token
**File:** `lib/main_production.dart`

```dart
String? appCheckToken = 'x';  // Hardcoded placeholder
```

---

### ERR-005: Generic Catch Blocks Without Logging
**File:** `lib/tabs/route/screens/albergue_details/cubit/albergue_details_cubit.dart`

Multiple methods catch exceptions but don't log or provide error details.

---

### ERR-006: Connectivity Check Exceptions Not Caught
**Files:** `lib/app/cubit/app_cubit.dart`, `lib/tabs/route/screens/albergue_details/cubit/albergue_details_cubit.dart`

```dart
Connectivity().checkConnectivity()  // Can throw on some Android versions
```

---

### ERR-007: Missing Error Differentiation in API Responses
**File:** `packages/remote_data/lib/src/network_service.dart`

All `DioException` types converted to generic string, losing error context.

---

### ERR-008: Commented Out Error Handling Code
**File:** `packages/remote_data/lib/src/network_service.dart` (Lines 418-440)

Proper error handling switch statement is commented out.

---

### PERF-006: Inefficient List Filtering
**File:** `lib/tabs/route/screens/saved_accommodations/cubit/saved_accommodations_cubit.dart` (Lines 22-70)

```dart
// Double filtering, recreates lowercase string for each item
albergues.where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
```

**Remediation:** Cache lowercased query, consider search index for large lists.

---

### PERF-007: Large setState Calls Trigger Geometry Recalculation
**File:** `lib/tabs/map/map_screen.dart` (Lines 213-230)

Multiple `setState()` calls for individual updates instead of batching.

---

### PERF-008: Missing Pagination for Reviews
**File:** `lib/tabs/route/screens/albergue_details/reviews_section.dart` (Lines 74-97)

```dart
ListView.separated(
  itemCount: reviews.length,  // ALL reviews rendered at once
)
```

**Impact:** 200+ reviews creates 200+ widgets instantly.

---

### PERM-003: No Storage Permission Handling (Android 10+)
**Issue:** No `READ_MEDIA_IMAGES` permission for Android 13+.

---

### PERM-004: Missing Notification Permission
**Issue:** No `POST_NOTIFICATIONS` permission for Android 13+.

---

### PERM-005: No Pre-Request Rationale Dialog
**File:** `lib/utils/location_service.dart`

Permission requested directly without showing rationale first.

---

### QUAL-004: Debug Print Statements (20+)
See SEC-003 for full list.

---

### QUAL-005: Empty Catch Blocks with ignore Directive (8)
See ERR-001 for full list.

---

### QUAL-006: Inconsistent Naming Conventions
- File: `alberbue_map_section.dart` (typo: should be "albergue")
- Mixed `var` vs explicit types
- Inconsistent constant casing

---

### QUAL-007: Duplicate Haversine Implementation
**Files:**
1. `lib/tabs/route/screens/distance/cubit/distance_cubit.dart`
2. `lib/tabs/route/screens/elevation/cubit/elevation_cubit.dart`
3. `lib/utils/route_distance_calculator.dart`

**Remediation:** Consolidate to single `lib/utils/geo_math.dart`.

---

### QUAL-008: Commented Out Code Block
**File:** `packages/storage/lib/src/app_database.dart` (Lines 41-56)

15-line database initialization block should be removed or feature-flagged.

---

### QUAL-009: Weak Typing Patterns
**Issue:** Excessive use of `var` instead of explicit types.

**Files:** `albergue_contact_list.dart`, `albergue_details_screen.dart`, `city_albergues_map.dart`

---

### UI-003: Missing Empty States
**File:** `lib/tabs/route/screens/albergue_details/reviews_section.dart` (Lines 53-55)

```dart
if (reviews.isEmpty) {
  return const SizedBox();  // Silent empty state
}
```

---

### UI-004: Keyboard Handling Issues
**Files:** `SearchField`, `ReviewFeedbackBottomSheet`, `CustomTextField`

Inconsistent keyboard dismissal behavior.

---

### UI-005: Missing Pull-to-Refresh
**Files:** `PlanListScreen`, `CityDetailsScreen`, `AlbergueDetailsScreen`

No `RefreshIndicator` wrapper on scrollable content.

---

### UI-006: Hardcoded Dimensions
**Files:**
- `SearchField`: Fixed 45px height
- `CityInformationCard`: Fixed 130px tooltip width
- `ElevationChartPanel`: Fixed 500px maxHeight

---

### UI-007: Form Validation Feedback
**Files:** `ManualAddStayDialog`, `ReviewFeedbackBottomSheet`

No real-time validation feedback during input.

---

### UI-008: Inconsistent Loading States
Different loading indicators used across similar screens.

---

## Low Priority Issues

### SEC-010: Test Code in Main Codebase
**File:** `packages/remote_data/tool/test_proto.dart`

Contains `localhost` URLs that should be in test directory.

---

### SEC-011: Network Debug Logging Statement
**File:** `lib/utils/crashlytics_interceptor.dart` (Line 11)

```dart
print(FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled);
```

---

### PERF-009: Redundant API Calls on Navigation
**File:** `lib/tabs/plan/plan_screen.dart` (Lines 300-312)

Full data reload after every navigation instead of incremental updates.

---

### PERF-010: Missing const Constructors
**Files:** `city_information_card.dart`, `albergue_contact_list.dart`

Widgets in `.map()` operations created without const.

---

### PERM-006: iOS Settings Button Missing in Location Dialog
**File:** `lib/widgets/dialogs/location_service_dialog.dart`

No explicit "Open Settings" button for iOS.

---

### QUAL-010: TODO Comments Indicating Unfinished Work
**Files:**
- `lib/tabs/route/screens/city_details/city_details_screen.dart:521` - "TODO: confirm about status orange"
- `android/app/build.gradle:53`
- `windows/flutter/CMakeLists.txt:8`

---

### QUAL-011: Missing Public API Documentation
`analysis_options.yaml` disables `public_member_api_docs` but critical APIs remain undocumented.

---

### QUAL-012: Generated Files Not Properly Separated
56 generated files (`.g.dart`, `.pb.dart`) clutter source directories.

---

### UI-009: Missing Accessibility Labels
No `Semantics` widgets found; icon buttons lack labels.

---

### UI-010: Low Contrast Text
**File:** `lib/screens/login/login_screen.dart`

```dart
color: Colors.black.withOpacity(0.7)  // May fail WCAG AA
```

---

## Recommendations by Category

### Security Action Plan

| Priority | Action | Timeline |
|----------|--------|----------|
| Immediate | Rotate Google Maps API key | 24 hours |
| Immediate | Remove all print statements | 24 hours |
| High | Implement certificate pinning | 1 week |
| High | Sanitize Crashlytics logs | 1 week |
| Medium | Add file upload validation | 2 weeks |

### Performance Action Plan

| Priority | Action | Timeline |
|----------|--------|----------|
| High | Fix memory leak in elevation chart | 1 day |
| High | Add image caching to gallery/reviews | 3 days |
| High | Optimize database queries (N+1) | 1 week |
| Medium | Add pagination to reviews | 1 week |
| Medium | Add buildWhen to BlocBuilders | 2 weeks |

### Error Handling Action Plan

| Priority | Action | Timeline |
|----------|--------|----------|
| High | Add Dio timeout configuration | 1 day |
| High | Remove empty catch blocks | 3 days |
| High | Add null checks before collection access | 3 days |
| Medium | Implement error state UI | 1 week |
| Medium | Differentiate API error types | 2 weeks |

### Code Quality Action Plan

| Priority | Action | Timeline |
|----------|--------|----------|
| High | Establish unit test baseline | 2 weeks |
| High | Centralize constants | 1 week |
| Medium | Refactor large files | 3 weeks |
| Medium | Remove duplicate code | 2 weeks |
| Low | Fix naming inconsistencies | 1 week |

---

## Files Requiring Most Attention

### By Tech Debt Density

| Rank | File | Lines | Issues | Categories |
|------|------|-------|--------|------------|
| 1 | `packages/storage/lib/src/app_database.dart` | 1449 | N+1 queries, commented code, no tests | Performance, Quality |
| 2 | `packages/repository/lib/src/repository.dart` | 998 | Empty catches, prints, null checks | Error, Security, Quality |
| 3 | `lib/tabs/route/screens/elevation/new_elevation_chart.dart` | 961 | Memory leak, heavy build, weak typing | Performance, Quality |
| 4 | `lib/widgets/elevation_chart_panel/elevation_chart.dart` | 454 | Magic numbers, duplication | Quality |
| 5 | `lib/di/dependency_injection.dart` | - | No timeout, no cert pinning | Security, Error |
| 6 | `android/app/src/main/AndroidManifest.xml` | - | Hardcoded API key | Security |
| 7 | `lib/utils/crashlytics_interceptor.dart` | - | Logs sensitive data | Security |
| 8 | `lib/tabs/route/screens/albergue_details/cubit/albergue_details_cubit.dart` | - | Empty catches, no error states | Error, UI |

---

## Appendix: Issue Count by File

```
packages/repository/lib/src/repository.dart          - 6 issues
packages/storage/lib/src/app_database.dart           - 5 issues
lib/tabs/route/screens/elevation/new_elevation_chart.dart - 4 issues
lib/di/dependency_injection.dart                     - 3 issues
lib/utils/crashlytics_interceptor.dart               - 3 issues
lib/tabs/plan/cubit/plan_cubit.dart                  - 3 issues
lib/tabs/plan/screens/plan_detail/cubit/plan_detail_cubit.dart - 3 issues
android/app/src/main/AndroidManifest.xml             - 2 issues
packages/remote_data/lib/src/network_service.dart    - 4 issues
lib/tabs/route/screens/albergue_details/cubit/albergue_details_cubit.dart - 3 issues
lib/tabs/map/map_screen.dart                         - 3 issues
```

---

*This document should be reviewed and updated regularly as issues are resolved and new ones are discovered.*
