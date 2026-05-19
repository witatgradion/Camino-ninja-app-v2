# Camino Ninja Flutter - Features Documentation

> A comprehensive mobile application for planning and navigating Camino pilgrimage routes.

---

## Table of Contents

- [1. Route Browser](#1-route-browser)
- [2. Interactive Map](#2-interactive-map)
- [3. Stage Planner](#3-stage-planner)
- [4. Accommodation Discovery](#4-accommodation-discovery)
- [5. Elevation & Distance Tracking](#5-elevation--distance-tracking)
- [6. Favorites & Saved Accommodations](#6-favorites--saved-accommodations)
- [7. Reviews & Ratings](#7-reviews--ratings)
- [8. Bug Reporting (Shake to Report)](#8-bug-reporting-shake-to-report)
- [9. Authentication](#9-authentication)
- [10. Settings & Preferences](#10-settings--preferences)
- [11. Localization](#11-localization)
- [12. Offline Data & Sync](#12-offline-data--sync)
- [13. In-App Review Prompts](#13-in-app-review-prompts)
- [14. How To Ninja (Tutorial)](#14-how-to-ninja-tutorial)
- [15. Firebase & Analytics](#15-firebase--analytics)
- [16. Screen Routing](#16-screen-routing)
- [17. Architecture Summary](#17-architecture-summary)

---

## 1. Route Browser

The primary tab of the app. Allows users to browse Camino pilgrimage routes, select their journey parameters, and explore cities along the way.

### Route Selection Wizard (3-Step Flow)

| Step | Screen | Description |
|------|--------|-------------|
| 1 | Select Route | Browse all available Camino routes with search/filter. Displays route name, distance, and statistics. |
| 2 | Select Starting Point | Choose a starting city on the selected route. Supports **auto-locate** via GPS to find the nearest city. |
| 3 | Select Destination | Choose an ending city (must be after the starting point). Auto-highlights the nearest valid destination. |

### Route Screen (Main View)

- Expandable/collapsible header showing the selected route, start, and destination
- Scrollable list of all cities on the selected route segment
- Each city displays available services (ATM, cafe, pharmacy, restaurant, etc.)
- Tap a city to view its details and accommodations
- Auto-snap header behavior for smooth collapse/expand
- Integrated elevation chart at the bottom

### City Details Screen

- City information card with name, region, country
- List of all accommodations (albergues) in the city
- Search/filter accommodations by name
- Booking.com integration with ratings and reserve buttons
- Map view showing all accommodation locations
- Service icons (ATM, pharmacy, bus station, train station, airport, etc.)

---

## 2. Interactive Map

Full-screen Google Maps integration for visualizing routes and tracking location in real time.

### Features

- **Route polylines** drawn on map for the selected route segment
- **Alternative route points** displayed with different colors and line styles (solid/dotted)
- **City markers** and **accommodation markers** with clustering for performance
- **Real-time location tracking** with "My Location" button
- **Dark/light mode** map themes matching app theme
- **Elevation chart panel** at the bottom of the map view
- Tap markers to navigate to city or accommodation details
- Location permission and accuracy dialogs

### Map Handlers

- **MapLocationHandler** - Real-time GPS position updates
- **MapMarkerHandler** - Marker creation and styling (custom icons for cities and albergues)
- **MapClusterHandler** - Marker clustering for large datasets
- **MapChartHandler** - Elevation chart interaction linked to map position

---

## 3. Stage Planner

A multi-day journey planning feature that lets users create detailed stage-by-stage itineraries.

### Plan Management

- View all saved plans on the Plan tab
- Expandable plan cards showing route name and stage summary
- Create new plans or delete existing ones
- Animated list transitions with empty state (Lottie animation)
- Plans persist locally in a dedicated SQLite database

### Plan Detail Screen

- View all stages in a plan with `StageDetailCard` widgets
- Edit or delete individual stages
- **Day gap indicators** showing consecutive vs. non-consecutive days
- Scroll to a specific stage
- Edit plan destination with re-selection dialog
- Save changes confirmation dialog

### Add/Edit Stage (5-Step Animated Flow)

| Step | Screen | Description |
|------|--------|-------------|
| 1 | Select Route | Choose which Camino route for this stage |
| 2 | Select Start City | Pick starting city with optional GPS auto-locate |
| 3 | Select End City | Pick destination city (must be after start) |
| 4 | Select Date | Calendar picker for the stage date with validation |
| 5 | Select Accommodation | Choose an albergue or manually add a custom stay |

### Stage Overview Card

- Shows current selections as they are made
- Distance, elevation gain/loss statistics
- Route segment visualization

### Stage Map Screen

- View individual stage route on Google Maps
- Start/end markers with directional arrows
- Horizontal scrollable list of waypoint cities
- Real-time location tracking overlay

### Cross-Route Support (New)

- Plans can span **multiple Camino routes** at junction cities
- `RouteSegment` model tracks which portion of each route is used
- `CrossRoutePath` model represents paths across route junctions
- Database migration (v2) supports nullable route IDs and JSON route segments

---

## 4. Accommodation Discovery

Comprehensive accommodation (albergue) information system with 40+ facility attributes.

### Albergue Details Screen

Sections:

| Section | Contents |
|---------|----------|
| **Main** | Name, type (municipal/private), capacity, dormitory count, status |
| **Pricing** | Dormitory, single, double, triple, quad room, shared room, apartment prices |
| **Facilities** | 40+ boolean flags covering kitchen, laundry, WiFi, meals, amenities |
| **Address & Contact** | Address, phone numbers (with WhatsApp/Signal indicators), emails, social media |
| **Operating Hours** | Check-in/out times, open season dates, exclusion periods, all-year status |
| **Map** | Location on Google Maps with navigation options |
| **Photos** | Gallery of official and user-uploaded images |
| **Reviews** | User reviews with ratings, comments, and photos |
| **Booking** | Booking.com integration with external rating and reserve button |

### Facility Categories

- **Kitchen & Food**: Kitchen, cooktops, microwave, fridge, oven, water boiler, plates/utensils, cooking pots
- **Meals**: Breakfast, lunch, dinner (included or paid), community meals, donativo breakfast, restaurant
- **Dietary**: Vegetarian, vegan, organic options
- **Laundry**: Washing machine, spin dryer, tumble dryer, full laundry service, clothesline
- **Comfort**: WiFi, TV, vending machine, individual power plugs, private lockers, curtains, cotton sheets, cube beds
- **Other**: Swimming pool, hand-washing sink, pets allowed

### Gallery Screen

- Full-screen photo browsing
- User-uploaded photo support

### Map Options

- Bottom sheet to choose navigation app (Google Maps, etc.)
- Generate geo-links for external navigation

---

## 5. Elevation & Distance Tracking

GPS-based real-time tracking features for pilgrims on the Camino.

### Elevation Profile

- **Elevation chart** showing the elevation profile for the selected route segment
- Interactive chart with indicator overlay
- Fullscreen elevation chart mode
- Min/max elevation, elevation gain/loss statistics
- Real-time location overlay on chart
- Location accuracy dialog for precise tracking

### Distance Tracking

- Calculate real-time distance to destination from current GPS location
- Display distance in user-selected units (km or miles)
- Location permission handling with educational guides
- Location accuracy warnings and improvement prompts
- Continuous location updates via `LocationTracker`

### Unit Conversion

- Metric (km, meters) and Imperial (miles, feet)
- Applies globally across all distance and elevation displays

---

## 6. Favorites & Saved Accommodations

Bookmark system for saving preferred accommodations.

### Features

- **Favorite button** (heart icon) on each accommodation
- **Flying heart animation** from the button to the bottom navigation bar
- Dedicated **Saved Accommodations Screen** with:
  - Full list of favorited accommodations
  - Search/filter functionality
  - Remove from favorites
  - Navigate to accommodation details
- Favorites persist locally in SQLite (`favorites_albergues` table)
- `FavoritesCubit` manages state across the app

---

## 7. Reviews & Ratings

Community-driven rating and review system for accommodations.

### Submitting Reviews

- Star rating (1-5 scale)
- Written comment
- Photo attachments (multi-image upload)
- Requires user authentication
- Submitted via multipart/form-data API

### Viewing Reviews

- Paginated review list per accommodation
- Each review shows: name, rating, comment, date, attached images
- **Ninja Rating** - App's own aggregated user rating
- **Booking.com Rating** - External rating from Booking.com
- **Google Rating** - External rating from Google

### Feedback System

- **Albergue feedback** - Report issues or provide feedback about a specific accommodation
- **Missing albergue report** - Report an accommodation not yet in the database
- Both support image attachments

---

## 8. Bug Reporting (Shake to Report)

Built-in bug reporting triggered by shaking the device.

### How It Works

1. User shakes the device while using the app
2. App automatically captures a screenshot
3. A bottom sheet appears with the bug report form
4. User adds a description of the issue
5. Report is submitted with the screenshot and device info via API
6. Success/failure notification displayed via `TopNotificationOverlay`

### Features

- Automatic screenshot capture via `ImageHelper`
- Shake detection in the root screen
- Can be disabled in settings
- Multipart form upload with image attachment

---

## 9. Authentication

OAuth-based authentication supporting multiple providers.

### Login Methods

- **Google Sign-In** - OAuth flow with Google
- **Apple Sign-In** - OAuth flow with Apple (iOS)
- **Guest Mode** - Browse without logging in (`proceed_as_guest` flag)

### Token Management

- OAuth tokens exchanged for app JWT via `/api/v1/mobile_login`
- Access and refresh tokens stored in `FlutterSecureStorage` (encrypted)
- Automatic token refresh with 60-second buffer before expiry
- Single-flight refresh pattern (prevents concurrent refresh requests)
- `NetworkInterceptor` handles 401/403 retry with refreshed tokens

### Login Required Features

The following actions prompt a `LoginRequiredBottomSheet` if the user is not authenticated:

- **Uploading photos** to an albergue (from Albergue Details screen)
- **Submitting reviews** for an albergue (from Albergue Details screen)
- **Submitting reviews** from the Plan Detail screen

---

## 10. Settings & Preferences

Configurable settings accessible from the More tab.

### Available Settings

| Setting | Options | Description |
|---------|---------|-------------|
| **Language** | 19 languages | Change app display language |
| **Theme** | System / Light / Dark | App color scheme |
| **Distance Unit** | Kilometers / Miles | Affects all distance displays |
| **Shake to Report** | On / Off | Enable/disable shake bug reporting |

### Storage

- Settings stored in `FlutterSecureStorage` via `AppPreferences`
- Real-time updates across the entire app
- Persists across sessions

---

## 11. Localization

Full multi-language support with 19 languages.

### Supported Languages

| Code | Language | Code | Language |
|------|----------|------|----------|
| en | English | ko | Korean |
| es | Spanish | nl | Dutch |
| fr | French | pl | Polish |
| de | German | pt | Portuguese |
| it | Italian | ro | Romanian |
| cs | Czech | ru | Russian |
| da | Danish | zh | Chinese |
| hu | Hungarian | | |
| id | Indonesian | | |
| ja | Japanese | | |

### Implementation

- ARB (Application Resource Bundle) files in `lib/l10n/arb/`
- Auto-generated with `flutter gen-l10n`
- Device locale fallback to English
- Real-time language switching without app restart
- Flag icons (SVG) for each language in the selector

---

## 12. Offline Data & Sync

Local-first data architecture with intelligent sync.

### Local Database (SQLite)

**Main Database** (`camino_database.db` - v7):
- Routes, cities, albergues with all nested data
- Route points (GPS waypoints) and alternative route points
- Albergue facilities, prices, operating hours, reviews, contact info, images
- Favorites table (preserved across data refreshes)
- Seed database shipped with the app for first-run experience

**Stage Planner Database** (`stage_planner_database.db` - v2):
- Stage plans and individual stages
- Cross-route segment support
- Cascade delete (deleting a plan removes all stages)

### Data Sync Strategy

- Timestamp-based sync per data type (routes, cities, albergues, route points, etc.)
- `LatestDataUpdate` API endpoint returns server-side timestamps
- Local timestamps compared to determine which entities need refreshing
- Only changed data types are re-downloaded
- Protocol Buffers (Protobuf) used for bandwidth-efficient downloads

### Synced Data Types

| Data Type | Description |
|-----------|-------------|
| Routes | Camino route definitions |
| Route Points | GPS waypoints for route polylines |
| Alt Route Points | Alternative route variants |
| Cities | City information and services |
| Albergues | Accommodation details with all nested data |
| Albergue User Images | Community-uploaded photos |

---

## 13. In-App Review Prompts

Native app store review prompts at appropriate moments.

### Features

- Uses `in_app_review` package for native iOS/Android review dialogs
- Show-time tracking via `AppPreferences`
- "Do not ask again" option
- Triggered at contextually appropriate moments

---

## 14. How To Ninja (Tutorial)

Interactive animated tutorial introducing the app's features.

### Animation Sequence

The tutorial uses Lottie animations played in sequence:

1. **Intro** - Welcome animation
2. **Walk** - Idle walking state
3. **Eat** - Eating animation
4. **Sleep** - Sleeping animation
5. **Coffee** - Coffee break animation
6. **Happy** - Happy state
7. **Ninja** - Ninja character animation
8. **Buen Camino** - Farewell greeting
9. **Outro** - Exit animation

### Interaction

- Buttons trigger each animation step
- Progress bar shows current animation state
- Sequential playback with animation status listeners
- Exit animation plays before navigating away

---

## 15. Firebase & Analytics

### Firebase Services Used

| Service | Purpose |
|---------|---------|
| **Firebase Analytics** | Screen views, custom events, user tracking |
| **Firebase Crashlytics** | Error reporting, crash logs, network error logging |
| **Firebase App Check** | API security (Play Integrity on Android, DeviceCheck/App Attest on iOS) |
| **Firebase Remote Config** | Feature flags (e.g., `optional_upgrade_min_build`) |
| **Firebase Authentication** | Backend for Google/Apple OAuth |

### Analytics Tracking

- Automatic language parameter injection on all events
- Screen view tracking via `RouterObserver`
- Custom event tracking for user actions
- User ID association after authentication
- Debug logging in development mode

### App Check Security

- All API requests include Firebase App Check token in header
- JWT expiration validation with 60-second refresh buffer
- Debug providers for development/staging environments
- Production uses platform-native attestation

---

## 16. Screen Routing

The app uses **GoRouter** with a `StatefulShellRoute` for tab-based navigation. There are 40 named routes total.

### Top-Level Routes (Outside Tab Shell)

| Path | Route Name | Screen | Notes |
|------|-----------|--------|-------|
| `/login` | `login` | `LoginScreen` | Authentication screen |
| `/elevation-full-screen` | `elevation-full-screen` | `ElevationFullScreen` | Fullscreen elevation chart |
| `/gallery` | `gallery` | `GalleryScreen` | Image gallery viewer |

### Tab 0: Route (`/`)

| Path | Route Name | Screen | Parameters |
|------|-----------|--------|------------|
| `/` | `route` | `RouteScreen` | — |
| `/select-route` | `select-route` | `SelectRouteScreen` | — |
| `/select-starting-point` | `select-starting-point` | `SelectStartingPointScreen` | — |
| `/select-destination` | `select-destination` | `SelectDestinationScreen` | — |
| `/city-details` | `city-details` | `CityDetailsScreen` | Query: `cityId` |
| `/albergue-details` | `albergue-details` | `AlbergueDetailsScreen` | Extra: `AlbergueDetailsScreenArguments` |
| `/full-map` | `full-map` | `FullMapScreen` | Query: `albergueId`, `cityId`, `routeId` |
| `/elevation` | `elevation` | `ElevationScreen` | Extra: `ElevationScreenArguments` |
| `/distance` | `distance` | `DistanceScreen` | Extra: `DistanceScreenArguments` |
| `/city-full-map` | `city-full-map` | `CityFullMapScreen` | Extra: `CityFullMapScreenArguments` |

### Tab 1: Map (`/map`)

| Path | Route Name | Screen | Parameters |
|------|-----------|--------|------------|
| `/map` | `map` | `MapScreen` | Extra: `MapScreenArguments` (optional) |

### Tab 2: Plan (`/plan`)

| Path | Route Name | Screen | Parameters |
|------|-----------|--------|------------|
| `/plan` | `plan` | `PlanListScreen` | — |
| `/plan/add-edit-stage` | `add-edit-stage` | `AddEditStageScreen` | Extra: `AddEditStageScreenArguments` |
| `/plan/stage-select-route` | `stage-select-route` | `StageSelectRouteScreen` | Extra: `StageSelectRouteScreenArguments` (optional) |
| `/plan/stage-select-start-city` | `stage-select-start-city` | `StageSelectStartCityScreen` | Extra: `StageSelectStartCityScreenArguments` |
| `/plan/stage-select-end-city` | `stage-select-end-city` | `StageSelectEndCityScreen` | Extra: `StageSelectEndCityScreenArguments` |
| `/plan/stage-select-date` | `stage-select-date` | `StageSelectDateScreen` | Extra: `StageSelectDateScreenArguments` (optional) |
| `/plan/stage-select-albergue` | `stage-select-albergue` | `StageSelectAlbergueScreen` | Extra: `StageSelectAlbergueScreenArguments` |
| `/plan/plan-detail` | `plan-detail` | `PlanDetailScreen` | Extra: `PlanDetailScreenArguments` |
| `/plan/stage-distance` | `stage-distance` | `DistanceScreen` | Extra: `DistanceScreenArguments` |
| `/plan/stage-elevation` | `stage-elevation` | `ElevationScreen` | Extra: `ElevationScreenArguments` |
| `/plan/stage-map` | `stage-map` | `StageMapScreen` | Extra: `StageMapScreenArguments` |
| `/plan/stage-albergue-details` | `stage-albergue-details` | `AlbergueDetailsScreen` | Extra: `AlbergueDetailsScreenArguments` |

### Tab 3: More (`/more`)

| Path | Route Name | Screen | Parameters |
|------|-----------|--------|------------|
| `/more` | `more` | `MoreScreen` | — |
| `/more/offline-settings` | `offline-settings` | `OfflineSettingsScreen` | — |
| `/more/updates` | `updates` | `UpdatesScreen` | — |
| `/more/useful-links` | `useful-links` | `UsefulLinksScreen` | — |
| `/more/contact` | `contact` | `ContactScreen` | — |
| `/more/legal-privacy` | `legal-privacy` | `LegalPrivacyScreen` | — |
| `/more/select-language` | `select-language` | `SelectLanguageScreen` | — |
| `/more/saved-accommodations` | `saved-accommodations` | `SavedAccommodationsScreen` | — |
| `/more/select-unit` | `select-unit` | `SelectUnitScreen` | — |
| `/more/select-theme` | `select-theme` | `SelectThemeScreen` | — |
| `/more/how-to-ninja` | `how-to-ninja` | `HowToNinjaScreen` | — |

### Route Summary

| Branch | Parent Route | Child Routes | Total |
|--------|-------------|-------------|-------|
| Route Tab | 1 | 9 | 10 |
| Map Tab | 1 | 0 | 1 |
| Plan Tab | 1 | 11 | 12 |
| More Tab | 1 | 10 | 11 |
| Top-level | 3 | 0 | 3 |
| **Total** | | | **37** |

All tab branches use `NoTransitionPage` for instant tab switching. A `RouterObserver` is attached to each branch for analytics tracking.

---

## 17. Architecture Summary

### Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI Framework** | Flutter |
| **State Management** | BLoC / Cubit (flutter_bloc) |
| **Navigation** | GoRouter (declarative routing) |
| **Dependency Injection** | GetIt (service locator) |
| **Local Database** | SQLite (sqflite) |
| **Secure Storage** | FlutterSecureStorage |
| **Networking** | Dio + Retrofit |
| **Serialization** | Protocol Buffers + JSON |
| **Maps** | Google Maps Flutter |
| **Analytics** | Firebase Analytics + Crashlytics |
| **Authentication** | Google Sign-In + Apple Sign-In + JWT |
| **Animations** | Lottie + Rive |

### Multi-Flavor Architecture

| Flavor | API Environment | Firebase Config |
|--------|----------------|-----------------|
| Development | Dev server | Dev Firebase |
| Staging | Dev server | Dev Firebase |
| Production | Production server | Production Firebase |

### Package Structure

```
camino_ninja_flutter/
├── lib/
│   ├── app/              # Core app config, AppCubit, root screen
│   ├── di/               # Dependency injection (GetIt)
│   ├── l10n/             # Localization (19 languages)
│   ├── tabs/
│   │   ├── route/        # Route browser, city/albergue details, elevation, distance
│   │   ├── map/          # Interactive Google Maps
│   │   ├── plan/         # Stage planner
│   │   └── more/         # Settings, about, tutorial, contact
│   ├── utils/            # Themes, extensions, location, map helpers, interceptors
│   └── widgets/          # Reusable UI components
├── packages/
│   ├── analytics_services/  # Firebase Analytics wrapper
│   ├── remote_data/         # API client, DTOs, Protocol Buffers
│   ├── repository/          # Data layer abstraction
│   └── storage/             # SQLite database, entities
└── assets/
    ├── flags/            # Language flag SVGs
    ├── lottie/           # Lottie animation JSONs
    └── ...               # Images, Rive files, seed database
```

### Bottom Navigation Tabs

| Tab | Icon | Feature Area |
|-----|------|-------------|
| 0 | Route | Route browser, cities, accommodations |
| 1 | Map | Interactive route map |
| 2 | Plan | Stage planner |
| 3 | More | Settings, tutorial, contact |

---

*Generated on 2026-02-12 from codebase analysis.*
