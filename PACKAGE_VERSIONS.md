# Package Versions

**Updated**: December 23, 2025

## Main Dependencies ✅

| Package | Previous | Current | Latest |
|---------|----------|---------|--------|
| bloc | ^9.1.0 | ^9.1.0 | ✅ |
| flutter_bloc | ^9.1.1 | ^9.1.1 | ✅ |
| cached_network_image | ^3.4.1 | ^3.4.1 | ✅ |
| connectivity_plus | ^7.0.0 | ^7.0.0 | ✅ |
| equatable | ^2.0.5 | ^2.0.7 | ✅ |
| firebase_analytics | ^12.1.0 | ^12.1.0 | ✅ |
| firebase_app_check | ^0.4.1+3 | ^0.4.1+3 | ✅ |
| firebase_core | ^4.3.0 | ^4.3.0 | ✅ |
| firebase_crashlytics | ^5.0.6 | ^5.0.6 | ✅ |
| firebase_auth | ^6.1.3 | ^6.1.3 | ✅ |
| geolocator | ^14.0.2 | ^14.0.2 | ✅ |
| get_it | ^9.2.0 | ^9.2.0 | ✅ |
| go_router | ^17.0.1 | ^17.0.1 | ✅ |
| google_maps_flutter | ^2.9.0 | ^2.14.0 | ✅ |
| google_sign_in | ^7.2.0 | ^7.2.0 | ✅ |
| sign_in_with_apple | ^7.0.1 | ^7.0.1 | ✅ |
| image_picker | ^1.1.2 | ^1.2.1 | ✅ |
| share_plus | ^12.0.1 | ^12.0.1 | ✅ |
| shared_preferences | ^2.5.3 | ^2.5.4 | ✅ |
| url_launcher | ^6.3.1 | ^6.3.2 | ✅ |
| path_provider | ^2.1.5 | ^2.1.5 | ✅ |
| map_launcher | ^4.4.2 | ^4.4.2 | ✅ |
| lottie | ^3.3.1 | ^3.3.2 | ✅ |
| dio | ^5.7.0 | ^5.9.0 | ✅ |
| flutter_svg | ^2.1.0 | ^2.2.3 | ✅ |
| internet_connection_checker_plus | ^2.7.2 | ^2.9.1 | ✅ |

## Dev Dependencies ✅

| Package | Previous | Current | Latest |
|---------|----------|---------|--------|
| bloc_test | ^10.0.0 | ^10.0.0 | ✅ |
| very_good_analysis | ^10.0.0 | ^10.0.0 | ✅ |
| mocktail | ^1.0.4 | ^1.0.4 | ✅ |

## Storage Package ✅

| Package | Previous | Current | Latest |
|---------|----------|---------|--------|
| flutter_secure_storage | ^10.0.0 | ^10.0.0 | ✅ |
| sqflite | ^2.3.3+1 | ^2.4.2 | ✅ |

## Remote Data Package ⚠️

| Package | Previous | Current | Latest | Status |
|---------|----------|---------|--------|--------|
| retrofit | ^4.4.0 | 4.4.2 (pinned) | 4.9.1 | ⚠️ Blocked |
| retrofit_generator | ^8.2.0 | 9.2.0 | 10.2.1 | ⚠️ Blocked |
| protobuf | ^4.2.0 | 4.2.0 | 6.0.0 | ⚠️ Blocked |
| protoc_plugin | ^22.5.0 | 22.5.0 | 25.0.0 | ⚠️ Blocked |
| build_runner | ^2.4.6 | 2.5.4 | 2.10.4 | ⚠️ Blocked |
| json_serializable | ^6.7.1 | 6.9.5 | 6.11.3 | ⚠️ Blocked |

---

## ⚠️ Blocked Packages Details

### 1. package_info_plus (transitive)

| Previous | Current | Latest | Blocked By |
|----------|---------|--------|------------|
| 8.3.1 | 8.3.1 | 9.0.0 | geolocator_linux |

**Reason**: `geolocator ^14.0.2` → `geolocator_linux ^0.2.3` → requires `package_info_plus ^8.0.0`

---

### 2. retrofit + retrofit_generator

| Package | Previous | Current | Latest |
|---------|----------|---------|--------|
| retrofit | ^4.4.0 | 4.4.2 (pinned) | 4.9.1 |
| retrofit_generator | ^8.2.0 | 9.2.0 | 10.2.1 |

**Reason**: 
- `retrofit 4.9.1` changed `logError` to 4 arguments
- `retrofit_generator 9.x` generates 3-argument calls
- Must pin `retrofit 4.4.2` exactly (using `^` resolves to 4.9.1)
- `retrofit_generator 10.x` expects `Parser.DartMappable` not in retrofit

---

### 3. protobuf + protoc_plugin

| Package | Previous | Current | Latest |
|---------|----------|---------|--------|
| protobuf | ^4.2.0 | 4.2.0 | 6.0.0 |
| protoc_plugin | ^22.5.0 | 22.5.0 | 25.0.0 |

**Reason**: Tied to retrofit_generator version - cannot upgrade until retrofit ecosystem is fixed

---

### 4. build_runner + json_serializable

| Package | Previous | Current | Latest |
|---------|----------|---------|--------|
| build_runner | ^2.4.6 | 2.5.4 | 2.10.4 |
| json_serializable | ^6.7.1 | 6.9.5 | 6.11.3 |

**Reason**: `retrofit_generator 9.x` requires:
- `analyzer <8.0.0` (build_runner 2.10.4 needs `>=8.0.0`)
- `source_gen <3.0.0` (json_serializable 6.11.3 needs `^4.1.1`)

---

## Summary

| Category | Count |
|----------|-------|
| ✅ Upgraded to Latest | 26 packages |
| ⚠️ Blocked | 7 packages |

---

## 📋 Blocked Packages - Detailed Reasons

### 🔴 retrofit
> **4.4.2** → 4.9.1

**Why**: v4.9.1 changed `ErrorLogger.logError` from 3 to 4 arguments. `retrofit_generator 9.x` generates 3-argument calls.

**Fix**: Wait for compatible `retrofit_generator` release.

---

### 🔴 retrofit_generator
> **9.2.0** → 10.2.1

**Why**: v10.x expects `Parser.DartMappable` enum in `retrofit`, but `retrofit 4.9.1` doesn't have it.

**Fix**: Wait for `retrofit` to add `Parser.DartMappable` or `retrofit_generator` to fix this bug.

---

### 🔴 protobuf
> **4.2.0** → 6.0.0

**Why**: Blocked by `retrofit_generator`. Upgrading requires `retrofit_generator 10.x` which is broken.

**Fix**: Will unblock when retrofit ecosystem is fixed.

---

### 🔴 protoc_plugin
> **22.5.0** → 25.0.0

**Why**: Tied to `protobuf` version. Must match `protobuf` major version.

**Fix**: Will unblock when `protobuf` upgrades.

---

### 🔴 build_runner
> **2.5.4** → 2.10.4

**Why**: Version conflict on `analyzer`:
- `build_runner 2.10.4` needs `analyzer >=8.0.0`
- `retrofit_generator 9.x` needs `analyzer <8.0.0`

**Fix**: Will unblock when `retrofit_generator 10.x` works.

---

### 🔴 json_serializable
> **6.9.5** → 6.11.3

**Why**: Version conflict on `source_gen`:
- `json_serializable 6.11.3` needs `source_gen ^4.1.1`
- `retrofit_generator 9.x` needs `source_gen <3.0.0`

**Fix**: Will unblock when `retrofit_generator 10.x` works.

---

### 🔴 package_info_plus (transitive)
> **8.3.1** → 9.0.0

**Why**: `geolocator 14.0.2` → `geolocator_linux 0.2.3` → requires `package_info_plus ^8.0.0`

**Fix**: Wait for `geolocator_linux` to update dependency to `^9.0.0`.

---

## 🔗 Root Cause

```
retrofit_generator 10.x ──expects──▶ Parser.DartMappable
                                            │
                                            ▼
                               retrofit 4.9.1 ❌ missing
                                            │
         ┌──────────────────────────────────┴──────────────────────────────────┐
         ▼                                                                      ▼
Must stay on retrofit_generator 9.x                                    Can't upgrade retrofit
         │
         ├── needs analyzer <8.0.0 ──▶ blocks build_runner 2.10.4
         ├── needs source_gen <3.0.0 ──▶ blocks json_serializable 6.11.3
         └── blocks protobuf 6.0.0 ──▶ blocks protoc_plugin 25.0.0
```

---

## 🤖 Android Build Tools

### Android Gradle Plugin (AGP)
> **8.6.1** → 8.9.1

**File**: `android/settings.gradle`

**Why**: Upgraded Flutter packages pull in newer AndroidX dependencies that require AGP 8.9.1:
- `androidx.browser:browser:1.9.0`
- `androidx.activity:activity-ktx:1.11.0`
- `androidx.core:core-ktx:1.17.0`
- `androidx.core:core:1.17.0`
- `androidx.activity:activity:1.11.0`

These are transitive dependencies from packages like `url_launcher`, `image_picker`, `share_plus`, etc.

---

### Gradle
> **8.7** → 8.11.1

**File**: `android/gradle/wrapper/gradle-wrapper.properties`

**Why**: AGP 8.9.1 requires Gradle 8.11.1 or higher. Each AGP version has a minimum Gradle version requirement:

| AGP Version | Minimum Gradle |
|-------------|----------------|
| 8.6.x | 8.7 |
| 8.9.x | 8.11.1 |

---

### Summary of Android Changes

| Component | File | Previous | Current |
|-----------|------|----------|---------|
| Android Gradle Plugin | `android/settings.gradle` | 8.6.1 | 8.9.1 |
| Gradle | `android/gradle/wrapper/gradle-wrapper.properties` | 8.7 | 8.11.1 |

---

## 🍎 iOS Build Configuration

### iOS Deployment Target
> **14.0** → 15.0

**File**: `ios/Podfile`

**Why**: `firebase_app_check` (and other Firebase plugins) require iOS 15.0 minimum deployment target. The FirebaseAppCheck pod has a higher minimum iOS version requirement than what was set in the Podfile.

---

### Summary of iOS Changes

| Component | File | Previous | Current |
|-----------|------|----------|---------|
| iOS Deployment Target | `ios/Podfile` | 14.0 | 15.0 |
