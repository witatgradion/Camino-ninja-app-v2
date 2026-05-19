# Camino Ninja Flutter

![coverage][coverage_badge]  
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]  
[![License: MIT][license_badge]][license_link]

Camino Ninja is the official mobile companion for camino.ninja, providing route planning, accommodation search, offline data and rich map tooling for pilgrims on the Camino de Santiago.

> **Documentation**: For comprehensive project documentation including architecture diagrams, feature details, and developer guides, see [Project Documentation](docs/PROJECT_DOCUMENTATION.md).

This repository is a **multi-package Flutter monorepo** generated with [Very Good CLI][very_good_cli_link] and customized with:

- **State management**: `bloc` / `flutter_bloc`
- **Navigation**: `go_router` with a `StatefulShellRoute` tab layout (`RootScreen`) and deep linking
- **Dependency Injection**: `get_it` and a centralized `setupDependencies` function
- **Data layer**: `dio` + `remote_data` (Retrofit/protobuf) + `repository` + `storage` (SQLite / secure storage + dedicated Stage Planner DB)
- **Analytics & Crash Reporting**: Firebase Analytics, Crashlytics and custom `analytics_services`
- **Maps & Location**: `google_maps_flutter`, clustering and geolocation

The app targets **Flutter 3.35.3** (Dart 3.4+) and runs on **iOS, Android, Web and Windows**.

---

## High-level architecture 🧱

- **Presentation layer (app)**:
  - `lib/app/view/app.dart` defines `App`, a `MaterialApp.router` using:
    - `go_router` for routing with a tabbed `StatefulShellRoute`
    - `AppCubit` / `FavoritesCubit` for global UI state (theme, language, favorites)
    - `lightTheme` / `darkTheme` from `lib/utils/app_theme.dart`
  - `lib/root_screen.dart` wraps tab navigation (**Route**, **Plan**, **Map**, **More**), in-app notifications, Stage Planner announcement, and shake-to-report behavior.
  - Feature screens live mainly under:
    - `lib/tabs/route` – route selection, city and albergue details, elevation and distance views, full maps, etc.
    - `lib/tabs/plan` – **Stage Planner**: multi-day stage plans with per-stage dates, cities, albergues and notes, including a dedicated map view.
    - `lib/tabs/map` – map-focused screens.
    - `lib/tabs/more` – settings, legal/privacy, “How to Ninja”, useful links, contact, etc.
    - `lib/screens/login` – login flow.

- **Routing**:
  - Centralized in `App` via a single `GoRouter`:
    - `/login` for authentication.
    - A `StatefulShellRoute.indexedStack` with `RootScreen` hosting tab branches:
      - **Tab 0 – Route** (`/`):
        - `RouteScreen` at `/`
        - Nested routes: `select-route`, `select-starting-point`, `select-destination`, `city-details`, `albergue-details`, `full-map`, `elevation`, `distance`, `city-full-map`, and `/map` (Map tab entrypoint with optional args).
      - **Tab 1 – Plan** (`/plan` – Stage Planner):
        - `PlanListScreen` at `/plan` (list of saved plans, create-plan CTA).
        - Nested Stage Planner routes:
          - `add-edit-stage` – `AddEditStageScreen` to create/edit a single stage.
          - `stage-select-route` – `StageSelectRouteScreen` to choose a route and bootstrap a plan.
          - `stage-select-start-city` / `stage-select-end-city` – start/destination city selection.
          - `stage-select-date` – date selection for a stage or range.
          - `stage-select-albergue` – pick or manually add start/end albergues.
          - `plan-detail` – `PlanDetailScreen` with full plan overview, per-stage editing and dialogs (delete, reselect destination, save changes).
          - `stage-distance` / `stage-elevation` – per-stage distance/elevation views.
          - `stage-map` – dedicated Stage Planner map with combined markers and horizontal stage list.
      - **Tab 2 – Map**:
        - `/map` – `MapScreen` with its own cubit and clustering.
      - **Tab 3 – More** (`/more`):
        - `MoreScreen` at `/more` with nested routes:
          - `offline-settings`, `updates`, `useful-links`, `contact`, `legal-privacy`, `select-language`, `saved-accommodations`, `select-unit`, `select-theme`, `how-to-ninja`.
    - Additional top-level routes: `/elevation-full-screen`, `/gallery`.
  - `lib/services/router_observer.dart` implements a `NavigatorObserver` that sends **screen view events** to `analytics_services`.

- **Dependency Injection & services**:
  - `lib/di/dependency_injection.dart` configures `get_it`:
    - Registers `AppPreferences` (from `storage`) for local settings.
    - Configures a shared `Dio` instance with:
      - `CrashlyticsInterceptor`
      - `AppCheckInterceptor` (App Check token + auth guard)
      - `NetworkInterceptor` (automatic token refresh via `Repository`).
    - Registers:
      - `IAnalyticsService` (from `analytics_services`)
      - `NetworkService`, `AppDatabase` (from `remote_data`)
      - `Repository` (aggregates network, database, analytics and storage).

- **Domain / data packages (under `packages/`)**:
  - `analytics_services`
    - Wraps Firebase Analytics and Crashlytics.
    - Uses `storage` for analytics-related preferences.
  - `remote_data`
    - Owns network models, Retrofit clients and `.proto` files.
    - Uses `dio`, `json_serializable`, `protobuf` and `retrofit`.
  - `storage`
    - Local persistence using `sqflite`, `flutter_secure_storage`, `intl`, `json_serializable`.
    - Defines the global `Flavor` enum and `AppConfig`:
      - `AppConfig.setFlavor(Flavor.development | staging | production)`
      - `seedDatabasePath` switches between `assets/_dev_camino_database.db` and `assets/camino_database.db`.
    - Adds **Stage Planner storage**:
      - `StagePlannerDatabase` (`stage_planner_database.dart`) – a separate `sqflite` database (`stage_planner_database.db`) with `stage_plans` and `stages` tables plus indexes.
      - `StagePlanEntity` / `StageEntity` and related mappers under `lib/src/models/` to persist plans and stages.
  - `repository`
    - High-level domain APIs that combine `remote_data`, `storage` and `analytics_services`.
    - Adds **Stage Planner domain**:
      - `StageModel` / `StagePlanModel` to represent in-app stages and plans (including `RouteEntity`, stages, timestamps, expansion state).
      - `StagePlanRepository` which:
        - Orchestrates between `AppDatabase` and `StagePlannerDatabase`.
        - Provides CRUD for plans and stages (create/update/delete).
        - Hydrates plans with route and city data, slices route points by stage, and keeps planner data consistent with the main DB.

- **Theming & design system**:
  - `lib/utils/app_theme.dart` contains:
    - Typography (`appTextTheme`).
    - Color palettes (`AppColors` for primary/secondary/tertiary/error/neutral/variants).
    - `lightTheme` and `darkTheme` Material 3 color schemes.

- **Bootstrap and error handling**:
  - `lib/bootstrap.dart` centralizes `runApp` and (optional) global `BlocObserver`.
  - Each flavor’s `main_*.dart`:
    - Ensures `WidgetsFlutterBinding.ensureInitialized()`.
    - Locks orientation to portrait.
    - Initializes Firebase, App Check, Google Sign-In and Crashlytics.
    - Optionally configures App Check token auto-refresh (production).
    - Initializes DI (`setupDependencies`) and environment variables (`AppEnv`).
    - Clears persisted preferences on first run where required.

---

## Flavors & environments 🌱

This app uses three flavors, wired through both **Flutter targets** and **`AppConfig`** in `storage`:

- **development**
  - Entry point: `lib/main_development.dart`
  - Behavior:
    - `AppConfig.setFlavor(Flavor.development)`
    - `Firebase.initializeApp()` (default options).
    - Loads `.env.development` via `AppEnv.load(Flavor.development)`.
    - Initializes Google Sign-In using `GOOGLE_WEB_CLIENT_ID` from env.
    - Configures Crashlytics error handlers.
    - Calls `setupDependencies(baseUrl: AppEnv.baseUrl)` and clears preferences on first run.

- **staging**
  - Entry point: `lib/main_staging.dart`
  - Behavior:
    - `AppConfig.setFlavor(Flavor.staging)`
    - Initializes Firebase with `firebase_options_stg.dart`.
    - Loads `.env.staging` via `AppEnv.load(Flavor.staging)`.
    - Initializes Google Sign-In from env.
    - Activates Firebase App Check in **debug** mode for Android/iOS.
    - Forwards all framework and platform errors to Crashlytics.

- **production**
  - Entry point: `lib/main_production.dart`
  - Behavior:
    - `AppConfig.setFlavor(Flavor.production)`
    - Initializes Firebase with production options (`firebase_options.dart`).
    - Loads `.env.production` via `AppEnv.load(Flavor.production)`.
    - Initializes Google Sign-In from env.
    - Activates Firebase App Check with:
      - `AndroidProvider.playIntegrity` (release) / `AndroidProvider.debug` (debug).
      - `AppleProvider.appAttestWithDeviceCheckFallback` (release) / `AppleProvider.debug` (debug).
    - Enables Firebase Analytics collection in non-debug builds.
    - Retrieves an App Check token and passes it into `setupDependencies`.
    - Clears local preferences the first time the app is launched.

Environment variables are managed by:

- `lib/app_env.dart`
  - Uses `flutter_dotenv` to load `.env.<flavor>` files:
    - `BASE_URL` – API base URL used by `setupDependencies`.
    - `GOOGLE_WEB_CLIENT_ID` – Web client ID for Google Sign-In.

---

## Project structure 📂

Key paths:

- **Application**
  - `lib/app/` – App entry wiring and `App` widget:
    - `app.dart` (export)
    - `view/app.dart` – `MaterialApp.router` + GoRouter configuration.
  - `lib/root_screen.dart` – main shell with bottom navigation (Route / Plan / Map / More), Stage Planner announcement, shake-to-report, in-app review prompts and top notification overlay.
  - `lib/screens/login/` – login screen and supporting widgets.

- **Features**
  - `lib/tabs/route/` – Route tab:
    - `route_screen.dart`
    - `screens/albergue_details/*` – accommodation details & gallery.
    - `screens/city_details/*` – city details and full map.
    - `screens/elevation/*` – elevation charts and full-screen views.
    - `screens/distance/*` – distance breakdowns.
    - `screens/favorite_button/*` – favorites and flying heart animation.
    - Various configuration screens (route, destination, starting point, theme, units, language).
  - `lib/tabs/plan/` – Plan tab (**Stage Planner**):
    - `plan_screen.dart` – `PlanListScreen` with saved plans, empty-state animation and “Create plan” CTA.
    - `screens/plan_detail/*` – detailed plan overview, per-stage editing and dialogs (delete plan/stage, save changes, reselect destination).
    - `screens/add_edit_stage/*` – add/edit a single stage (start/end city, dates, albergues, notes, distance/elevation shortcuts).
    - `screens/select_route/*`, `select_start_city/*`, `select_end_city/*`, `select_date/*`, `select_albergue/*` – guided flows to build stages.
    - `screens/stage_map/*` – Stage Planner-specific map with combined markers and a horizontal stage list.
    - `widgets/*` – `ExpandablePlanCard`, `StageCard`, `DayGapsWidget`, and other Stage Planner-specific UI.
  - `lib/tabs/map/` – Map tab (global map, independent of Stage Planner).
  - `lib/tabs/more/` – More tab, including:
    - `offline_settings`, `useful_links`, `updates`, `contact`, `legal_privacy`, `how_to_ninja`, etc.

- **Cross-cutting**
  - `lib/di/dependency_injection.dart` – DI container (`get_it`).
  - `lib/utils/` – themes, extensions, interceptors, helpers (e.g. `app_theme.dart`, `context_ext.dart`, network/app check/crashlytics interceptors, navigation helpers, image helpers).
  - `lib/widgets/` – reusable UI components (bottom navigation, title widgets, notification overlays, in-app review helper, etc.).
    - Includes `stage_planner_announcement_bottomsheet.dart` to promote the Stage Planner feature from the main shell.
  - `lib/preferences/` – `PreferencesCubit` and local preference abstractions.
  - `lib/mixins/` – shared mixins (e.g. shake detection).
  - `lib/services/router_observer.dart` – analytics-aware navigation observer.
  - `lib/l10n/arb/` – localization ARB files for supported languages.

- **Packages**
  - `packages/analytics_services` – analytics and crash reporting abstraction.
  - `packages/remote_data` – API models/clients, protobuf and network utilities.
  - `packages/repository` – domain-level repositories.
  - `packages/storage` – local persistence, `Flavor` and `AppConfig`.

- **Configuration**
  - `pubspec.yaml` – main app dependencies, env asset declarations and splash configuration.
  - `analysis_options.yaml` – static analysis rules (Very Good Analysis).
  - `l10n.yaml` – localization generation config.
  - `ios/config/{dev,stg,prod}` – flavor-specific iOS configuration plists.
  - `firebase.json`, `firebase_options*.dart` – Firebase configuration.

---

## Local development & tooling 🛠

- **Prerequisites**
  - Flutter **3.35.3** (or compatible with `flutter: ^3.22.0`).
  - Dart SDK `>=3.4.0`.
  - Xcode and/or Android Studio / Android SDK for mobile builds.
  - [Melos](https://melos.invertase.dev/) for monorepo management.

### Melos Setup 🔧

This project uses **Melos** to manage multiple packages. Install and bootstrap:

```sh
# Install melos globally
dart pub global activate melos

# Ensure pub-cache/bin is in your PATH (add to ~/.zshrc or ~/.bashrc)
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Bootstrap all packages (installs dependencies for all)
melos bootstrap
```

**Available Melos commands:**

| Command | Description |
|---------|-------------|
| `melos bootstrap` | Install dependencies for all packages |
| `melos clean` | Clean all packages |
| `melos refresh` | Clean + bootstrap (full reset) |
| `melos analyze` | Run analyzer on all packages |
| `melos test` | Run tests in all packages |
| `melos format` | Format all packages |
| `melos fix` | Apply dart fixes to all packages |
| `melos gen-l10n` | Generate localizations |
| `melos build` | Run build_runner where needed |

### Google Maps API Key Setup 🗺️

The Google Maps API key is **not** committed to version control for security reasons. You must configure it locally:

**Android:**

Add to `android/local.properties` (create if doesn't exist):

```properties
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

**iOS:**

Create `ios/Flutter/Secrets.xcconfig`:

```
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

> **Note**: Get the API key from Google Cloud Console. Ensure API restrictions are configured (Android: package name + SHA-1; iOS: bundle identifier).

- **Install dependencies**

```sh
# Using Melos (recommended - installs all packages)
melos bootstrap

# Or manually for root only
flutter pub get
```

- **Run code generation (if needed)**
  - The app uses:
    - `flutter gen-l10n` for localizations.
    - `build_runner` in the `remote_data` and `storage` packages for JSON / Retrofit / protobuf code.

Using Melos:

```sh
# Generate localizations
melos gen-l10n

# Run build_runner in all packages that need it
melos build
```

Or manually from the repo root:

```sh
# Localizations (normally run automatically by Flutter)
flutter gen-l10n --arb-dir="lib/l10n/arb"

# Example: run build_runner inside remote_data
cd packages/remote_data
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

You can repeat the `build_runner` step similarly in `packages/storage` if you change its generated models.

---

## Running the app 🚀

This project contains three flavors:

- **development**
- **staging**
- **production**

To run a specific flavor from the command line:

```sh
# Development
flutter run --flavor development --target lib/main_development.dart

# Staging
flutter run --flavor staging --target lib/main_staging.dart

# Production
flutter run --flavor production --target lib/main_production.dart
```

You can also use IDE launch configurations in VS Code / Android Studio pointing to the corresponding `main_*.dart` file and `--flavor` value.

### Building for release

```sh
# Android (APK)
flutter build apk --flavor production --target lib/main_production.dart

# Android (App Bundle)
flutter build appbundle --flavor production --target lib/main_production.dart

# iOS
flutter build ios --flavor production --target lib/main_production.dart
```

Make sure your flavor-specific Firebase configuration (`GoogleService-Info.plist` / `google-services.json`) and `.env.<flavor>` files are correctly set up before building.

---

## Firebase, App Check & analytics 📊

- **Firebase initialization**
  - `main_staging.dart` uses `firebase_options_stg.dart`.
  - `main_production.dart` uses `firebase_options.dart`.
  - `main_development.dart` uses default `Firebase.initializeApp()` options.

- **App Check**
  - Staging: App Check is activated in debug mode for both Android and iOS.
  - Production: App Check uses Play Integrity (Android) and App Attest with DeviceCheck fallback (iOS) in release builds; debug providers are used in debug.
  - `setupDependencies` accepts an optional `appCheckToken` which is injected into the `AppCheckInterceptor`.

- **Analytics & Crashlytics**
  - `analytics_services` wraps Firebase Analytics and Crashlytics.
  - `RouterObserver` sends screen-view events on navigation (`didPush`, `didReplace`).
  - Crashlytics is configured to capture:
    - Flutter framework errors (`FlutterError.onError`).
    - Platform-level uncaught errors (`PlatformDispatcher.instance.onError`).

---

## Offline data & storage 💾

- **Seed database**
  - `AppConfig.seedDatabasePath` uses:
    - `assets/camino_database.db` for `Flavor.production`.
    - `assets/_dev_camino_database.db` for other flavors.

- **Local persistence**
  - `storage` uses:
    - `sqflite` for relational data.
    - `flutter_secure_storage` for sensitive data.
  - `Repository` coordinates:
    - Remote API access (`remote_data`).
    - Local DB/storage (`storage`).
    - Analytics side-effects (`analytics_services`).

---

## Translations & localization 🌐

This project relies on [flutter_localizations][flutter_localizations_link] and follows the [official internationalization guide for Flutter][internationalization_link].

- **Configuration**
  - `l10n.yaml`:
    - `arb-dir: lib/l10n/arb`
    - `template-arb-file: app_en.arb`
    - `output-localization-file: app_localizations.dart`
  - Generated output lives under `lib/l10n/arb/app_localizations.dart` and is consumed via `AppLocalizations`.

### Adding strings

1. Add a new key to `lib/l10n/arb/app_en.arb`:

```arb
{
  "@@locale": "en",
  "helloWorld": "Hello World",
  "@helloWorld": {
    "description": "Hello World text"
  }
}
```

2. Use the new string in code:

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return Text(l10n.helloWorld);
}
```

### Adding supported locales

1. Add a new ARB file in `lib/l10n/arb`, e.g. `app_es.arb`.
2. Populate translations mirroring the keys in `app_en.arb`.
3. For iOS, update the `CFBundleLocalizations` array in `ios/Runner/Info.plist`:

```xml
<key>CFBundleLocalizations</key>
<array>
  <string>en</string>
  <string>es</string>
  <!-- Add other language codes here -->
</array>
```

4. Run localization generation:

```sh
flutter gen-l10n --arb-dir="lib/l10n/arb"
```

Alternatively, `flutter run` will also trigger localization generation when needed.

---

## Testing & quality 🧪

- **Unit and widget tests**

```sh
flutter test --coverage --test-randomize-ordering-seed random
```

- **Coverage report**

```sh
genhtml coverage/lcov.info -o coverage/
open coverage/index.html
```

- **Tooling**
  - Uses [very_good_analysis][very_good_analysis_link] for linting and best practices.
  - Common commands:

```sh
dart format .
dart analyze
```

---

## Documentation 📚

Comprehensive project documentation is available in the `docs/` directory:

| Document | Description |
|----------|-------------|
| [Project Documentation](docs/PROJECT_DOCUMENTATION.md) | Full technical documentation covering architecture, features, state management, navigation, dependency injection, data flow, and development workflows |
| [Tech Debt Report](docs/TECH_DEBT.md) | Technical debt analysis covering security issues, performance problems, error handling, permissions, and code quality improvements |

The project documentation includes:
- **Project Overview**: Business context, target audience, supported routes, and key differentiators
- **Architecture**: High-level architecture diagrams and design patterns
- **Technical Stack**: Complete list of dependencies and their purposes
- **Feature Modules**: Detailed breakdown of all tabs and screens
- **Package Structure**: In-depth coverage of the 4 modular packages
- **State Management**: Cubit architecture, patterns, and hierarchy
- **Navigation & Routing**: GoRouter configuration and route definitions
- **Dependency Injection**: GetIt setup and service registration
- **Data Flow**: API to UI data flow and offline support
- **Localization**: Supported languages and localization workflow
- **Development Workflow**: Commands for running, testing, and building
- **Build & Deployment**: Flavor configuration and CI/CD setup

The tech debt report covers:
- **Security Issues**: API key exposure, logging concerns, certificate pinning
- **Performance Problems**: Memory leaks, N+1 queries, missing caching
- **Error Handling**: Empty catch blocks, missing timeouts, null safety
- **Permission Handling**: Location, camera, storage permission flows
- **Code Quality**: Test coverage, code duplication, naming conventions
- **UI/UX Issues**: Missing states, accessibility, responsive design

---

## License 📄

This project is licensed under the [MIT License][license_link].

[coverage_badge]: coverage_badge.svg
[flutter_localizations_link]: https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html
[internationalization_link]: https://flutter.dev/docs/development/accessibility-and-localization/internationalization
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli


