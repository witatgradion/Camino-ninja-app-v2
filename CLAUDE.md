# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Camino Ninja Flutter is a mobile application for Camino pilgrimage routes. It's built using Flutter with a multi-flavor architecture (development, staging, production) and follows the Very Good CLI structure with BLoC pattern for state management.

## Common Development Commands

### Running the Application
- **Development**: `flutter run --flavor development --target lib/main_development.dart`
- **Staging**: `flutter run --flavor staging --target lib/main_staging.dart`
- **Production**: `flutter run --flavor production --target lib/main_production.dart`

### Testing
- **Run all tests**: `flutter test --coverage --test-randomize-ordering-seed random`
- **Generate coverage report**: `genhtml coverage/lcov.info -o coverage/`
- **Open coverage report**: `open coverage/index.html`

### Code Analysis & Quality
- **Lint analysis**: Uses `very_good_analysis` package with custom rules in `analysis_options.yaml`
- **API docs**: Disabled via `public_member_api_docs: false` in analysis options

### Protocol Buffers (for remote_data package)
- **Generate proto files**: `cd packages/remote_data && ./tool/generate_protos.sh`
- Requires `protoc-gen-dart` plugin: `dart pub global activate protoc_plugin`

### Localization
- **Generate localizations**: `flutter gen-l10n --arb-dir="lib/l10n/arb"`
- Localization files are in `lib/l10n/arb/` directory
- Supports multiple locales with automatic generation on `flutter run`

## Architecture

### Modular Package Structure
The project uses a modular architecture with separate packages:

- **analytics_services**: Firebase Analytics and Crashlytics integration
- **remote_data**: API communication using Dio/Retrofit, Protocol Buffers for data models
- **repository**: Data layer abstraction combining remote and local data
- **storage**: Local data persistence using SQLite (sqflite) and SharedPreferences

### Main Application Structure
- **lib/app/**: Core app configuration and main app widget
- **lib/di/**: Dependency injection setup using GetIt
- **lib/tabs/**: Feature-based organization (route, etc.)
- **lib/utils/**: Shared utilities and services
- **lib/widgets/**: Reusable UI components

### State Management
- Uses **BLoC pattern** with flutter_bloc
- Cubit classes for simpler state management scenarios
- AppBlocObserver for debugging (currently commented out in bootstrap.dart)

### Dependency Injection
- **GetIt** for service locator pattern
- Dependencies configured in `lib/di/dependency_injection.dart`
- Services include: Dio, NetworkService, Repository, AppDatabase, AppPreferences, AnalyticsService

### Firebase Integration
- Firebase Analytics and Crashlytics enabled
- App Check integration for API security
- Flavor-specific Firebase configurations in `firebase_options_*.dart` files

### Navigation
- **GoRouter** for declarative routing
- Multi-tab architecture with route-based navigation

## Agent Workflow

The user is the **product owner**. Claude acts as the **technical co-founder** — planning, coordinating, and delegating to specialized agents.

### Agents & Responsibilities
- **Technical Co-Founder** (you, the primary agent): Strategic decisions, architecture planning, task delegation, coordination
- **Flutter Expert**: ALL coding tasks — features, bug fixes, refactoring. Never write code directly; always delegate to this agent
- **Code Reviewer**: Reviews EVERY completed coding task before the user sees it. Mandatory step after flutter-expert finishes
- **UI/UX Designer**: Design-related tasks — UI critique, layout feedback, design direction
- **Context Manager**: Maintains project memory across sessions

### Mandatory Flow for Every Coding Task
1. **Plan** — Technical co-founder discusses approach with user, makes architectural decisions
2. **Code** — Delegate to Flutter Expert agent with clear requirements
3. **Review** — Send completed code to Code Reviewer agent before presenting to user
4. **Memory** — After significant work, use Context Manager to update branch memory

### Branch-Based Memory
- Each feature uses a dedicated feature branch (e.g., `feature/my-feature`)
- Per-branch context is stored in `memory/branches/<branch-name>.md`
- On session start, check the current git branch and load its memory file for context
- Branch memory keeps things lean — only store context relevant to that branch
- After significant work (features implemented, decisions made, bugs fixed), update the branch memory file
- When a branch is merged, promote lasting knowledge (gotchas, patterns) to global memory files and archive/delete the branch file
- Branch memory must NOT interfere with other feature branches

## Development Notes

### API Configuration
- Base URL configured per flavor in main_*.dart files
- Development uses: `http://ec2-3-67-133-98.eu-central-1.compute.amazonaws.com:8080`
- Network requests include Firebase App Check token header

### Location Services
- Location permissions and services initialized in main_*.dart
- LocationService.init() called during app startup

### First Run Handling
- App preferences cleared on first run using SharedPreferences flag
- Ensures clean state for new installations

### Assets
- Custom Montserrat font family with multiple weights and styles
- Assets organized in `assets/`, `assets/flags/`, `assets/lottie/` directories
- Native splash screen configured with custom logo and colors