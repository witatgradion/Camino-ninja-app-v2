# Camino Ninja Flutter - Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Technical Stack](#technical-stack)
4. [Feature Modules](#feature-modules)
5. [Package Structure](#package-structure)
6. [State Management](#state-management)
7. [Navigation & Routing](#navigation--routing)
8. [Dependency Injection](#dependency-injection)
9. [Data Flow](#data-flow)
10. [Localization](#localization)
11. [Development Workflow](#development-workflow)
12. [Build & Deployment](#build--deployment)

---

## Project Overview

### What is Camino Ninja?

Camino Ninja is a mobile application designed for pilgrims walking the Camino de Santiago pilgrimage routes in Spain and Portugal. The app serves pilgrims of all experience levels - from first-time walkers to seasoned veterans - providing comprehensive tools for route exploration, accommodation discovery, and trip planning.

### Target Audience
- **First-time pilgrims**: Need guidance on routes, distances, and accommodations
- **Experienced pilgrims**: Want efficient planning tools and detailed information
- **All pilgrimage levels**: Comprehensive feature set for any skill level

### Supported Routes
The app supports multiple major Camino routes including:
- Camino Francés (French Way)
- Camino Portugués (Portuguese Way)
- Camino del Norte (Northern Way)
- Camino Primitivo (Original Way)
- And other official pilgrimage routes

### Business Model
Revenue is generated through accommodation booking commissions via Booking.com integration. Users can discover and book albergues (pilgrim hostels) and other accommodations directly through the app.

### Key Differentiators
1. **Offline Support**: Full functionality without internet connectivity - essential for remote areas with poor coverage
2. **Stage Planner**: Advanced trip planning with day-by-day stage management
3. **Community Reviews**: User-generated ratings and reviews for accommodations

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Presentation Layer                       │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐            │
│  │  Route  │  │   Map   │  │  Plan   │  │  More   │  (Tabs)    │
│  │   Tab   │  │   Tab   │  │   Tab   │  │   Tab   │            │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘            │
│       │            │            │            │                   │
│  ┌────┴────────────┴────────────┴────────────┴────┐            │
│  │              BLoC / Cubit (State Management)    │            │
│  └────────────────────────┬───────────────────────┘            │
└───────────────────────────┼─────────────────────────────────────┘
                            │
┌───────────────────────────┼─────────────────────────────────────┐
│                      Business Layer                              │
│  ┌────────────────────────┴───────────────────────┐            │
│  │                   Repository                    │            │
│  │     (Data aggregation & business logic)        │            │
│  └─────────────────────┬──────────────────────────┘            │
└────────────────────────┼────────────────────────────────────────┘
                         │
┌────────────────────────┼────────────────────────────────────────┐
│                     Data Layer                                   │
│  ┌──────────────┐     │     ┌──────────────┐                   │
│  │ Remote Data  │◄────┴────►│   Storage    │                   │
│  │   (API)      │           │  (SQLite)    │                   │
│  └──────────────┘           └──────────────┘                   │
└─────────────────────────────────────────────────────────────────┘
```

### Design Patterns Used

| Pattern | Implementation | Purpose |
|---------|---------------|---------|
| **Clean Architecture** | Separate packages for data, domain, presentation | Separation of concerns |
| **BLoC/Cubit** | flutter_bloc | State management |
| **Repository Pattern** | Repository package | Data abstraction |
| **Service Locator** | GetIt | Dependency injection |
| **Singleton** | Lazy singletons via GetIt | Service instances |

### Directory Structure

```
camino_ninja_flutter/
├── lib/
│   ├── app/                    # Core app configuration
│   ├── di/                     # Dependency injection
│   ├── tabs/                   # Feature modules (Route, Map, Plan, More)
│   ├── screens/                # Shared screens (Login)
│   ├── services/               # App services
│   ├── utils/                  # Utilities and helpers
│   ├── widgets/                # Reusable UI components
│   ├── l10n/                   # Localization
│   ├── preferences/            # User preferences state
│   └── mixins/                 # Shared behaviors
├── packages/
│   ├── analytics_services/     # Firebase Analytics
│   ├── remote_data/            # API client & models
│   ├── repository/             # Data layer abstraction
│   └── storage/                # Local persistence
├── assets/                     # Images, fonts, animations
├── android/                    # Android platform code
├── ios/                        # iOS platform code
└── test/                       # Unit & widget tests
```

---

## Technical Stack

### Core Framework
- **Flutter SDK**: ^3.4.0
- **Dart**: Modern null-safe Dart

### State Management
- **flutter_bloc**: ^8.x - BLoC/Cubit pattern implementation
- **equatable**: Value equality for state comparison

### Navigation
- **go_router**: Declarative routing with deep linking support

### Networking
- **dio**: HTTP client with interceptor support
- **retrofit**: Type-safe REST API client (generated code)
- **protobuf**: Protocol Buffers for efficient data serialization

### Local Storage
- **sqflite**: SQLite database for offline data
- **shared_preferences**: Key-value storage for settings

### Maps & Location
- **google_maps_flutter**: Google Maps integration
- **google_maps_cluster_manager_2**: Marker clustering
- **geolocator**: GPS location services
- **location**: Location permissions and tracking

### Firebase Services
- **firebase_analytics**: User analytics
- **firebase_crashlytics**: Crash reporting
- **firebase_auth**: Authentication
- **firebase_app_check**: API security

### UI Components
- **fl_chart**: Chart visualizations
- **syncfusion_flutter_charts**: Advanced charts (elevation profiles)
- **lottie**: Animation support
- **photo_view**: Image gallery
- **modal_bottom_sheet**: Bottom sheet dialogs

### Code Quality
- **very_good_analysis**: Strict lint rules
- **bloc_test**: BLoC testing utilities
- **mocktail**: Mocking for tests

---

## Feature Modules

### Tab 1: Route Explorer (`/lib/tabs/route/`)

The primary feature for discovering and exploring pilgrimage routes.

**Screens:**
| Screen | Path | Description |
|--------|------|-------------|
| Route Screen | `/` | Main route overview with expandable selection |
| Select Route | `/select-route` | Choose a Camino route |
| Select Starting Point | `/select-starting-point` | Pick starting city |
| Select Destination | `/select-destination` | Pick destination city |
| City Details | `/city-details` | City info with accommodations |
| Albergue Details | `/albergue-details` | Full accommodation details |
| Full Map | `/full-map` | Complete route map view |
| Elevation | `/elevation` | Elevation profile chart |
| Distance | `/distance` | Distance calculator |

**Key Features:**
- Interactive route selection with visual previews
- City-by-city exploration along routes
- Detailed albergue information (prices, facilities, ratings)
- Elevation profile visualization
- Distance calculations from current location
- Favorite/save accommodations functionality

### Tab 2: Map View (`/lib/tabs/map/`)

Real-time interactive map with location tracking.

**Features:**
- Google Maps integration with custom markers
- Real-time GPS location tracking
- Route polylines visualization
- Marker clustering for accommodations
- City and albergue markers
- Elevation chart overlay
- My location button with permission handling

**Key Components:**
- `MapCubit`: State management for map data
- `MapLocationHandler`: GPS tracking logic
- `MapMarkerHandler`: Marker generation and placement
- `MapClusterHandler`: Marker clustering algorithms
- `MapChartHandler`: Elevation chart integration

### Tab 3: Stage Planner (`/lib/tabs/plan/`)

Comprehensive trip planning with day-by-day stage management.

**Screens:**
| Screen | Description |
|--------|-------------|
| Plan List | Overview of all saved plans |
| Plan Detail | Detailed view of a specific plan |
| Add/Edit Stage | Create or modify a walking stage |
| Stage Select Route | Choose route for stage |
| Stage Select Start City | Pick stage starting point |
| Stage Select End City | Pick stage ending point |
| Stage Select Date | Set walking date |
| Stage Select Albergue | Choose accommodation |
| Stage Map | Visual map of stage |
| Stage Elevation | Elevation profile for stage |

**Key Features:**
- Create multiple trip plans
- Add walking stages day-by-day
- Set dates for each stage
- Select accommodations for overnight stays
- View stage distances and elevation
- Manual accommodation entry option
- Plan sharing and export (planned)

### Tab 4: More/Settings (`/lib/tabs/more/`)

App settings and additional information.

**Screens:**
| Screen | Description |
|--------|-------------|
| Offline Settings | Manage offline data downloads |
| Updates | Check for app updates |
| Saved Accommodations | View bookmarked albergues |
| Select Language | Change app language (14+ options) |
| Select Unit | Toggle km/miles |
| Select Theme | Light/dark mode |
| Contact | Developer contact info |
| How to Ninja | User guide |
| Legal & Privacy | Terms and privacy policy |
| Useful Links | External resources |

---

## Package Structure

### 1. Analytics Services (`packages/analytics_services/`)

Firebase Analytics and Crashlytics integration.

```dart
// Public API
abstract class IAnalyticsService {
  Future<void> logEvent(String name, Map<String, dynamic>? parameters);
  Future<void> setCurrentScreen(String screenName);
  Future<void> setUserId(String userId);
}
```

**Responsibilities:**
- Event tracking (user actions, feature usage)
- Screen view logging
- User identification
- Crash reporting integration

### 2. Remote Data (`packages/remote_data/`)

API communication layer with Protocol Buffers.

```
remote_data/
├── src/
│   ├── api_client.g.dart      # Generated Retrofit client
│   ├── models/                # API response models
│   │   ├── albergue/          # Accommodation models
│   │   ├── city/              # City models
│   │   ├── route/             # Route models
│   │   └── auth/              # Auth models
│   ├── proto/                 # Protocol Buffer definitions (38 files)
│   ├── converters/            # Data converters
│   └── requests/              # API request models
└── tool/
    └── generate_protos.sh     # Proto generation script
```

**Key Entities:**
- Routes, Cities, Route Points
- Albergues (accommodations) with facilities, prices, reviews
- User authentication data
- File uploads (review images)

### 3. Repository (`packages/repository/`)

Data abstraction combining remote and local sources.

```dart
class Repository {
  final NetworkService _networkService;
  final AppDatabase _database;
  final AppPreferences _preferences;
  final IAnalyticsService _analytics;

  // Fetches from API with local caching
  Future<List<Route>> getRoutes();
  Future<List<City>> getCitiesByRoute(int routeId);
  Future<AlbergueDetails> getAlbergueDetails(int id);
  // ... more methods
}
```

**Responsibilities:**
- Unified data access API
- Remote/local data synchronization
- Offline fallback logic
- Business logic coordination
- Analytics event triggering

### 4. Storage (`packages/storage/`)

Local data persistence with SQLite and SharedPreferences.

**Databases:**
- `AppDatabase`: Main app data (routes, cities, albergues)
- `StagePlannerDatabase`: Trip planning data

**Entities (23+ models):**
- `RouteEntity`, `CityEntity`, `RoutePointEntity`
- `AlbergueEntity` with related entities (facilities, prices, images, reviews)
- `StagePlanEntity`, `StageEntity`
- `UserEntity`, `CredentialEntity`

**Preferences (`AppPreferences`):**
- Selected route/starting point/destination
- Language preference
- Theme preference
- Unit preference (km/miles)
- Offline data status
- First run flags

---

## State Management

### Cubit-Based Architecture

The app uses **Cubit** (simplified BLoC) exclusively for state management. There are **23 Cubits** throughout the application.

### State Structure Pattern

```dart
// Standard state pattern used across the app
class PlanState extends Equatable {
  const PlanState({
    this.stagePlans = const [],
    this.initStatus = PlanInitStatus.initial,
  });

  final PlanInitStatus initStatus;
  final List<StagePlanModel> stagePlans;

  PlanState copyWith({
    List<StagePlanModel>? stagePlans,
    PlanInitStatus? initStatus,
  }) {
    return PlanState(
      stagePlans: stagePlans ?? this.stagePlans,
      initStatus: initStatus ?? this.initStatus,
    );
  }

  @override
  List<Object?> get props => [stagePlans, initStatus];
}
```

### SafeEmit Mixin

Custom utility to prevent emission after disposal:

```dart
mixin SafeEmitMixin<State> on Cubit<State> {
  void safeEmit(State state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
```

### Cubit Hierarchy

```
App Level
├── AppCubit (global state: route selection, preferences)
├── FavoritesCubit (saved accommodations)
└── PreferencesCubit (user settings)

Feature Level
├── Route Tab
│   ├── SelectRouteCubit
│   ├── SelectStartingPointCubit
│   ├── SelectDestinationCubit
│   ├── CityDetailsCubit
│   ├── AlbergueDetailsCubit
│   ├── ElevationCubit
│   ├── DistanceCubit
│   ├── FullMapCubit
│   └── FavoriteCubit
│
├── Map Tab
│   └── MapCubit
│
├── Plan Tab
│   ├── PlanCubit
│   ├── PlanDetailCubit
│   ├── AddEditStageCubit
│   ├── StageSelectRouteCubit
│   ├── StageSelectDateCubit
│   └── StageMapCubit
│
└── More Tab
    └── MoreCubit
```

### Provider Setup

```dart
// App-level providers (lib/app/view/app.dart)
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => AppCubit()..onLoadCachedData()),
    BlocProvider(create: (_) => FavoritesCubit(getIt())),
  ],
  child: // App content
)

// Screen-level providers
BlocProvider(
  create: (_) => CityDetailsCubit(cityId: id)..loadCityDetails(),
  child: CityDetailsScreen(),
)
```

---

## Navigation & Routing

### GoRouter Configuration

The app uses GoRouter with a 4-tab StatefulShellRoute architecture.

### Route Structure

```
/                           # Route tab (home)
├── /select-route
├── /select-starting-point
├── /select-destination
├── /city-details
├── /albergue-details
├── /full-map
├── /elevation
├── /distance
└── /city-full-map

/map                        # Map tab

/plan                       # Plan tab
├── /plan/add-edit-stage
├── /plan/stage-select-start-city
├── /plan/stage-select-end-city
├── /plan/stage-select-route
├── /plan/stage-select-date
├── /plan/stage-select-albergue
├── /plan/plan-detail
├── /plan/stage-distance
├── /plan/stage-elevation
├── /plan/stage-map
└── /plan/stage-albergue-details

/more                       # More tab
├── /more/offline-settings
├── /more/updates
├── /more/useful-links
├── /more/contact
├── /more/legal-privacy
├── /more/select-language
├── /more/saved-accommodations
├── /more/select-unit
├── /more/select-theme
└── /more/how-to-ninja

/login                      # Login screen (global)
/elevation-full-screen      # Full-screen elevation (global)
/gallery                    # Image gallery (global)
```

### Navigation Patterns

```dart
// Tab switching
navigationShell.goBranch(index);

// Push navigation (with back stack)
context.push('/plan/plan-detail', extra: PlanDetailArguments(planId: 1));

// Parameter passing
// Via extra (complex objects)
state.extra as AlbergueDetailsScreenArguments

// Via query parameters (simple values)
state.uri.queryParameters['cityId']
```

### Route Observer

```dart
class RouterObserver extends NavigatorObserver {
  final IAnalyticsService _analyticsService;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _analyticsService.setCurrentScreen(route.settings.name ?? 'unknown');
  }
}
```

---

## Dependency Injection

### GetIt Setup

```dart
// lib/di/dependency_injection.dart
final getIt = GetIt.instance;

void setupDependencies({
  String? appCheckToken,
  required String baseUrl,
}) {
  getIt
    // Storage
    ..registerLazySingleton<AppPreferences>(() => AppPreferences())
    ..registerLazySingleton<AppDatabase>(() => AppDatabase())
    ..registerLazySingleton<StagePlannerDatabase>(() => StagePlannerDatabase())

    // Network
    ..registerLazySingleton<Dio>(() => _createDio(baseUrl, appCheckToken))
    ..registerLazySingleton<NetworkService>(() => NetworkService(getIt()))

    // Repository
    ..registerLazySingleton<Repository>(() => Repository(
      networkService: getIt(),
      database: getIt(),
      preferences: getIt(),
      analytics: getIt(),
    ))
    ..registerLazySingleton<StagePlanRepository>(() => StagePlanRepository())

    // Analytics
    ..registerLazySingleton<IAnalyticsService>(() => AnalyticsService());
}
```

### Interceptor Chain

```
HTTP Request Flow:
┌─────────────────────────────────────────────────────────────┐
│ Dio HTTP Client                                              │
├─────────────────────────────────────────────────────────────┤
│ 1. CrashlyticsInterceptor  - Log errors to Firebase         │
│ 2. AppCheckInterceptor     - Firebase App Check tokens      │
│ 3. NetworkInterceptor      - OAuth token management         │
│ 4. LogInterceptor (debug)  - Request/response logging       │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### API to UI Data Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Remote    │     │  Repository │     │   Cubit     │
│    API      │────►│   (Cache)   │────►│   (State)   │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       │              ┌────┴────┐              │
       │              │ SQLite  │              │
       │              │   DB    │              │
       │              └─────────┘              │
       │                                       │
       ▼                                       ▼
┌─────────────┐                        ┌─────────────┐
│  Protocol   │                        │   Widget    │
│  Buffers    │                        │    Tree     │
└─────────────┘                        └─────────────┘
```

### Offline Support Flow

```
1. User opens app with internet
   └─► API fetches data
       └─► Repository caches to SQLite
           └─► UI displays data

2. User opens app without internet
   └─► API request fails
       └─► Repository reads from SQLite cache
           └─► UI displays cached data

3. User downloads offline data explicitly
   └─► Bulk download from API
       └─► Store in SQLite database files
           └─► Available offline indefinitely
```

---

## Localization

### Supported Languages (14+)

| Code | Language | Status |
|------|----------|--------|
| en | English | Complete |
| es | Spanish | Complete |
| fr | French | Complete |
| de | German | Complete |
| it | Italian | Complete |
| pt | Portuguese | Complete |
| nl | Dutch | Complete |
| pl | Polish | Complete |
| cs | Czech | Complete |
| da | Danish | Complete |
| hu | Hungarian | Complete |
| id | Indonesian | Complete |
| ja | Japanese | Complete |
| ko | Korean | Complete |
| ro | Romanian | Complete |
| ru | Russian | Complete |
| zh | Chinese | Complete |

### Localization Files

```
lib/l10n/
├── app_language.dart           # Language enum and utilities
└── arb/
    ├── app_en.arb              # English (primary)
    ├── app_es.arb              # Spanish
    ├── app_fr.arb              # French
    └── ...                     # Other languages
```

### Usage

```dart
// Access translations
Text(context.l10n.selectRoute)
Text(AppLocalizations.of(context)!.welcomeMessage)

// Generate localizations
flutter gen-l10n --arb-dir="lib/l10n/arb"
```

---

## Development Workflow

### Running the App

```bash
# Development flavor
flutter run --flavor development --target lib/main_development.dart

# Staging flavor
flutter run --flavor staging --target lib/main_staging.dart

# Production flavor
flutter run --flavor production --target lib/main_production.dart
```

### Testing

```bash
# Run all tests with coverage
flutter test --coverage --test-randomize-ordering-seed random

# Generate coverage report
genhtml coverage/lcov.info -o coverage/

# Open coverage report
open coverage/index.html
```

### Code Generation

```bash
# Generate Protocol Buffer files
cd packages/remote_data && ./tool/generate_protos.sh

# Generate localizations
flutter gen-l10n --arb-dir="lib/l10n/arb"

# Generate Retrofit API client (if modified)
dart run build_runner build
```

### Code Quality

```bash
# Run linter
flutter analyze

# Format code
dart format .
```

---

## Build & Deployment

### Flavor Configuration

| Flavor | Environment | Firebase App Check | Base URL |
|--------|-------------|-------------------|----------|
| development | Dev server | Disabled | Dev API |
| staging | Staging server | Debug providers | Staging API |
| production | Production server | Production providers | Production API |

### CI/CD (GitHub Actions)

```
.github/workflows/
├── dev_release.yaml         # Development builds
├── staging_release.yaml     # Staging builds
└── production_release.yaml  # Production builds
```

### iOS Deployment

```bash
# Uses Fastlane for automation
cd ios
fastlane beta  # TestFlight
fastlane release  # App Store
```

### Android Deployment

```bash
# Build release APK
flutter build apk --flavor production --target lib/main_production.dart

# Build App Bundle
flutter build appbundle --flavor production --target lib/main_production.dart
```

---

## Appendix

### Key Files Reference

| File | Purpose |
|------|---------|
| `lib/main_*.dart` | Entry points per flavor |
| `lib/bootstrap.dart` | App initialization |
| `lib/root_screen.dart` | Root navigation shell |
| `lib/app/view/app.dart` | App widget with routing |
| `lib/di/dependency_injection.dart` | DI configuration |
| `lib/utils/safe_emit_mixin.dart` | Cubit utility |
| `analysis_options.yaml` | Lint rules |
| `pubspec.yaml` | Dependencies |

### Version Info

- **App Version**: 2.2.338+202338
- **Flutter SDK**: ^3.4.0
- **Dart SDK**: Modern null-safe

---

*Documentation generated for Camino Ninja Flutter project*
