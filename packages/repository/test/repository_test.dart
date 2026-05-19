import 'dart:io';

import 'package:analytics_services/analytics_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/src/repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:storage/storage.dart';

// Mock classes
class MockNetworkService extends Mock implements NetworkService {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockAppPreferences extends Mock implements AppPreferences {}

class MockAnalyticsService extends Mock implements IAnalyticsService {}

class MockFirebaseConfigDataSource extends Mock
    implements FirebaseConfigDataSource {}

class MockDatabase extends Mock implements Database {}

class FakeFile extends Fake implements File {}

class FakeCredentialEntity extends Fake implements CredentialEntity {}

void main() {
  late Repository repository;
  late MockNetworkService mockNetworkService;
  late MockAppDatabase mockAppDatabase;
  late MockAppPreferences mockAppPreferences;
  late MockAnalyticsService mockAnalyticsService;
  late MockFirebaseConfigDataSource mockFirebaseConfigDataSource;
  late MockDatabase mockDatabase;

  setUpAll(() {
    registerFallbackValue(FakeFile());
    registerFallbackValue(<File>[]);
    registerFallbackValue(CancelToken());
    registerFallbackValue(FakeCredentialEntity());
  });

  setUp(() {
    mockNetworkService = MockNetworkService();
    mockAppDatabase = MockAppDatabase();
    mockAppPreferences = MockAppPreferences();
    mockAnalyticsService = MockAnalyticsService();
    mockFirebaseConfigDataSource = MockFirebaseConfigDataSource();
    mockDatabase = MockDatabase();

    repository = Repository(
      mockNetworkService,
      mockAppDatabase,
      mockAppPreferences,
      mockAnalyticsService,
      mockFirebaseConfigDataSource,
    );
  });

  group('Repository', () {
    // =========================================================================
    // Data Sync Operations
    // =========================================================================
    group('getLatestDataUpdate', () {
      test('returns all true flags when local database has no timestamp records',
          () async {
        when(() => mockNetworkService.getLatestDataUpdate()).thenAnswer(
          (_) async => ApiSuccess(
            LatestDataUpdateResponse(
              routes: DateTime(2024),
              routePoints: DateTime(2024),
              altRoutePoints: DateTime(2024),
              cities: DateTime(2024),
              albergues: DateTime(2024),
              albergueUserImages: DateTime(2024),
            ),
          ),
        );
        when(() => mockAppDatabase.queryList(table: 'latest_data_updated'))
            .thenAnswer((_) async => []);

        final result = await repository.getLatestDataUpdate();

        expect(result.shouldUpdateRoutes, isTrue);
        expect(result.shouldUpdateRoutePoints, isTrue);
        expect(result.shouldUpdateAltRoutePoints, isTrue);
        expect(result.shouldUpdateCities, isTrue);
        expect(result.shouldUpdateAlbergues, isTrue);
        expect(result.shouldUpdateAlbergueUserImages, isTrue);
      });

      test('returns false flags when local timestamps are newer than remote',
          () async {
        final remoteTimestamp = DateTime(2024);
        final localTimestamp = DateTime(2024, 6);

        when(() => mockNetworkService.getLatestDataUpdate()).thenAnswer(
          (_) async => ApiSuccess(
            LatestDataUpdateResponse(
              routes: remoteTimestamp,
              routePoints: remoteTimestamp,
              altRoutePoints: remoteTimestamp,
              cities: remoteTimestamp,
              albergues: remoteTimestamp,
              albergueUserImages: remoteTimestamp,
            ),
          ),
        );
        when(() => mockAppDatabase.queryList(table: 'latest_data_updated'))
            .thenAnswer(
          (_) async => [
            {
              'id': 1,
              'routes_updated_at': localTimestamp.toIso8601String(),
              'route_points_updated_at': localTimestamp.toIso8601String(),
              'alt_route_points_updated_at': localTimestamp.toIso8601String(),
              'cities_updated_at': localTimestamp.toIso8601String(),
              'albergues_updated_at': localTimestamp.toIso8601String(),
              'albergue_user_images_updated_at':
                  localTimestamp.toIso8601String(),
            },
          ],
        );
        when(() => mockAnalyticsService.trackEvent(
              eventName: any(named: 'eventName'),
              parameters: any(named: 'parameters'),
            ),).thenReturn(null);

        final result = await repository.getLatestDataUpdate();

        expect(result.shouldUpdateRoutes, isFalse);
        expect(result.shouldUpdateRoutePoints, isFalse);
        expect(result.shouldUpdateAltRoutePoints, isFalse);
        expect(result.shouldUpdateCities, isFalse);
        expect(result.shouldUpdateAlbergues, isFalse);
        expect(result.shouldUpdateAlbergueUserImages, isFalse);
      });

      test('returns true flags when local timestamps are older than remote',
          () async {
        final remoteTimestamp = DateTime(2024, 6);
        final localTimestamp = DateTime(2024);

        when(() => mockNetworkService.getLatestDataUpdate()).thenAnswer(
          (_) async => ApiSuccess(
            LatestDataUpdateResponse(
              routes: remoteTimestamp,
              routePoints: remoteTimestamp,
              altRoutePoints: remoteTimestamp,
              cities: remoteTimestamp,
              albergues: remoteTimestamp,
              albergueUserImages: remoteTimestamp,
            ),
          ),
        );
        when(() => mockAppDatabase.queryList(table: 'latest_data_updated'))
            .thenAnswer(
          (_) async => [
            {
              'id': 1,
              'routes_updated_at': localTimestamp.toIso8601String(),
              'route_points_updated_at': localTimestamp.toIso8601String(),
              'alt_route_points_updated_at': localTimestamp.toIso8601String(),
              'cities_updated_at': localTimestamp.toIso8601String(),
              'albergues_updated_at': localTimestamp.toIso8601String(),
              'albergue_user_images_updated_at':
                  localTimestamp.toIso8601String(),
            },
          ],
        );
        when(() => mockAnalyticsService.trackEvent(
              eventName: any(named: 'eventName'),
              parameters: any(named: 'parameters'),
            ),).thenReturn(null);

        final result = await repository.getLatestDataUpdate();

        expect(result.shouldUpdateRoutes, isTrue);
        expect(result.shouldUpdateRoutePoints, isTrue);
        expect(result.shouldUpdateAltRoutePoints, isTrue);
        expect(result.shouldUpdateCities, isTrue);
        expect(result.shouldUpdateAlbergues, isTrue);
        expect(result.shouldUpdateAlbergueUserImages, isTrue);
      });

      test('throws exception when API returns failure', () async {
        when(() => mockNetworkService.getLatestDataUpdate()).thenAnswer(
          (_) async => const ApiFailure('Network error'),
        );

        expect(
          () => repository.getLatestDataUpdate(),
          throwsA(isA<Exception>()),
        );
      });

      test('returns true when remote timestamp is null', () async {
        when(() => mockNetworkService.getLatestDataUpdate()).thenAnswer(
          (_) async => const ApiSuccess(
            LatestDataUpdateResponse(),
          ),
        );
        when(() => mockAppDatabase.queryList(table: 'latest_data_updated'))
            .thenAnswer(
          (_) async => [
            {
              'id': 1,
              'routes_updated_at': DateTime(2024).toIso8601String(),
            },
          ],
        );
        when(() => mockAnalyticsService.trackEvent(
              eventName: any(named: 'eventName'),
              parameters: any(named: 'parameters'),
            ),).thenReturn(null);

        final result = await repository.getLatestDataUpdate();

        expect(result.shouldUpdateRoutes, isTrue);
      });

      test('handles mixed null timestamps', () async {
        when(() => mockNetworkService.getLatestDataUpdate()).thenAnswer(
          (_) async => ApiSuccess(
            LatestDataUpdateResponse(
              routes: DateTime(2024),
              altRoutePoints: DateTime(2024),
              albergues: DateTime(2024),
            ),
          ),
        );
        when(() => mockAppDatabase.queryList(table: 'latest_data_updated'))
            .thenAnswer(
          (_) async => [
            {
              'id': 1,
              'routes_updated_at': DateTime(2024).toIso8601String(),
              'route_points_updated_at': DateTime(2024).toIso8601String(),
              'alt_route_points_updated_at':
                  DateTime(2024).toIso8601String(),
              'cities_updated_at': DateTime(2024).toIso8601String(),
              'albergues_updated_at': DateTime(2024).toIso8601String(),
              'albergue_user_images_updated_at':
                  DateTime(2024).toIso8601String(),
            },
          ],
        );
        when(() => mockAnalyticsService.trackEvent(
              eventName: any(named: 'eventName'),
              parameters: any(named: 'parameters'),
            ),).thenReturn(null);

        final result = await repository.getLatestDataUpdate();

        expect(result.shouldUpdateRoutes, isFalse);
        expect(result.shouldUpdateRoutePoints, isTrue);
        expect(result.shouldUpdateAltRoutePoints, isFalse);
        expect(result.shouldUpdateCities, isTrue);
        expect(result.shouldUpdateAlbergues, isFalse);
        expect(result.shouldUpdateAlbergueUserImages, isTrue);
      });
    });

    // =========================================================================
    // Query Operations
    // =========================================================================
    group('getRoutesFromDb', () {
      test('returns list of routes from database', () async {
        when(() => mockAppDatabase.queryList(table: 'routes')).thenAnswer(
          (_) async => [
            {
              'id': 1,
              'order_key': 1,
              'route_name': 'Camino Frances',
              'route_sub_name': 'Main Route',
              'legend_color': '#FF0000',
            },
            {
              'id': 2,
              'order_key': 2,
              'route_name': 'Camino Portuguese',
              'route_sub_name': null,
              'legend_color': '#00FF00',
            },
          ],
        );

        final routes = await repository.getRoutesFromDb();

        expect(routes.length, equals(2));
        expect(routes[0].id, equals(1));
        expect(routes[0].routeName, equals('Camino Frances'));
        expect(routes[1].id, equals(2));
        expect(routes[1].routeName, equals('Camino Portuguese'));
      });

      test('returns empty list when no routes in database', () async {
        when(() => mockAppDatabase.queryList(table: 'routes'))
            .thenAnswer((_) async => []);

        final routes = await repository.getRoutesFromDb();

        expect(routes, isEmpty);
      });
    });

    group('getRoutePointsFromDb', () {
      test('returns list of route points from database', () async {
        when(() => mockAppDatabase.queryList(table: 'route_points')).thenAnswer(
          (_) async => [
            {
              'id': 1,
              'order_key': 1,
              'elevation': 100.5,
              'route_id': 1,
              'latitude': 42.8805,
              'longitude': -8.5456,
            },
            {
              'id': 2,
              'order_key': 2,
              'elevation': 150.0,
              'route_id': 1,
              'latitude': 42.8810,
              'longitude': -8.5450,
            },
          ],
        );

        final routePoints = await repository.getRoutePointsFromDb();

        expect(routePoints.length, equals(2));
        expect(routePoints[0].id, equals(1));
        expect(routePoints[0].elevation, equals(100.5));
        expect(routePoints[1].id, equals(2));
        expect(routePoints[1].latitude, equals(42.8810));
      });

      test('returns empty list when no route points', () async {
        when(() => mockAppDatabase.queryList(table: 'route_points'))
            .thenAnswer((_) async => []);

        final routePoints = await repository.getRoutePointsFromDb();

        expect(routePoints, isEmpty);
      });
    });

    group('isDatabaseEmpty', () {
      test('returns true when database is empty', () async {
        when(() => mockAppDatabase.database)
            .thenAnswer((_) async => mockDatabase);
        when(() => mockAppDatabase.isDatabaseEmpty(mockDatabase))
            .thenAnswer((_) async => true);

        final result = await repository.isDatabaseEmpty();

        expect(result, isTrue);
      });

      test('returns false when database has data', () async {
        when(() => mockAppDatabase.database)
            .thenAnswer((_) async => mockDatabase);
        when(() => mockAppDatabase.isDatabaseEmpty(mockDatabase))
            .thenAnswer((_) async => false);

        final result = await repository.isDatabaseEmpty();

        expect(result, isFalse);
      });
    });

    // =========================================================================
    // Preferences Operations
    // =========================================================================
    group('loadCachedData', () {
      test('returns preference data from cache', () async {
        when(() => mockAppPreferences.getSelectedRoute())
            .thenAnswer((_) async => 1);
        when(() => mockAppPreferences.getSelectedStartCity())
            .thenAnswer((_) async => 10);
        when(() => mockAppPreferences.getSelectedEndCity())
            .thenAnswer((_) async => 20);
        when(() => mockAppPreferences.getDarkModeEnabled())
            .thenAnswer((_) async => true);
        when(() => mockAppPreferences.getLanguage())
            .thenAnswer((_) async => 'en');
        when(() => mockAppPreferences.getUnit())
            .thenAnswer((_) async => 'km');
        when(() => mockAppPreferences.getTheme())
            .thenAnswer((_) async => 'dark');

        final prefs = await repository.loadCachedData();

        expect(prefs.selectedRouteId, equals(1));
        expect(prefs.selectedStartCityId, equals(10));
        expect(prefs.selectedEndCityId, equals(20));
        expect(prefs.darkModeEnabled, isTrue);
        expect(prefs.language, equals('en'));
        expect(prefs.unit, equals('km'));
        expect(prefs.theme, equals('dark'));
      });

      test('handles null values in preferences', () async {
        when(() => mockAppPreferences.getSelectedRoute())
            .thenAnswer((_) async => null);
        when(() => mockAppPreferences.getSelectedStartCity())
            .thenAnswer((_) async => null);
        when(() => mockAppPreferences.getSelectedEndCity())
            .thenAnswer((_) async => null);
        when(() => mockAppPreferences.getDarkModeEnabled())
            .thenAnswer((_) async => false);
        when(() => mockAppPreferences.getLanguage())
            .thenAnswer((_) async => null);
        when(() => mockAppPreferences.getUnit())
            .thenAnswer((_) async => null);
        when(() => mockAppPreferences.getTheme())
            .thenAnswer((_) async => null);

        final prefs = await repository.loadCachedData();

        expect(prefs.selectedRouteId, isNull);
        expect(prefs.selectedStartCityId, isNull);
        expect(prefs.selectedEndCityId, isNull);
      });
    });

    group('setSelectedRoute', () {
      test('sets selected route in preferences', () async {
        when(() => mockAppPreferences.setSelectedRoute(any()))
            .thenAnswer((_) async {});

        await repository.setSelectedRoute(1);

        verify(() => mockAppPreferences.setSelectedRoute(1)).called(1);
      });
    });

    group('setSelectedStartCity', () {
      test('sets selected start city in preferences', () async {
        when(() => mockAppPreferences.setSelectedStartCity(any()))
            .thenAnswer((_) async {});

        await repository.setSelectedStartCity(10);

        verify(() => mockAppPreferences.setSelectedStartCity(10)).called(1);
      });
    });

    group('setSelectedEndCity', () {
      test('sets selected end city in preferences', () async {
        when(() => mockAppPreferences.setSelectedEndCity(any()))
            .thenAnswer((_) async {});

        await repository.setSelectedEndCity(20);

        verify(() => mockAppPreferences.setSelectedEndCity(20)).called(1);
      });
    });

    group('setDarkModeEnabled', () {
      test('sets dark mode enabled in preferences', () async {
        when(() => mockAppPreferences.setDarkModeEnabled(any()))
            .thenAnswer((_) async {});

        await repository.setDarkModeEnabled(true);

        verify(() => mockAppPreferences.setDarkModeEnabled(true)).called(1);
      });
    });

    group('setLanguage', () {
      test('sets language in preferences', () async {
        when(() => mockAppPreferences.setLanguage(any()))
            .thenAnswer((_) async {});

        await repository.setLanguage('es');

        verify(() => mockAppPreferences.setLanguage('es')).called(1);
      });
    });

    group('clearCache', () {
      test('clears all cached preferences', () async {
        when(() => mockAppPreferences.clearAll()).thenAnswer((_) async {});

        await repository.clearCache();

        verify(() => mockAppPreferences.clearAll()).called(1);
      });
    });

    group('clearSelectedEndCity', () {
      test('clears selected end city', () async {
        when(() => mockAppPreferences.clearSelectedEndCity())
            .thenAnswer((_) async {});

        await repository.clearSelectedEndCity();

        verify(() => mockAppPreferences.clearSelectedEndCity()).called(1);
      });
    });

    group('clearSelectedStartCity', () {
      test('clears selected start city', () async {
        when(() => mockAppPreferences.clearSelectedStartCity())
            .thenAnswer((_) async {});

        await repository.clearSelectedStartCity();

        verify(() => mockAppPreferences.clearSelectedStartCity()).called(1);
      });
    });

    group('setUnit', () {
      test('sets unit preference', () async {
        when(() => mockAppPreferences.setUnit(any()))
            .thenAnswer((_) async {});

        await repository.setUnit('mi');

        verify(() => mockAppPreferences.setUnit('mi')).called(1);
      });
    });

    group('setTheme', () {
      test('sets theme preference', () async {
        when(() => mockAppPreferences.setTheme(any()))
            .thenAnswer((_) async {});

        await repository.setTheme('light');

        verify(() => mockAppPreferences.setTheme('light')).called(1);
      });
    });

    group('DoNotAsk preferences', () {
      test('setDoNotAskLocationRequired stores value', () async {
        when(() => mockAppPreferences.setDoNotAskLocationRequired(any()))
            .thenAnswer((_) async {});

        await repository.setDoNotAskLocationRequired(true);

        verify(() => mockAppPreferences.setDoNotAskLocationRequired(true))
            .called(1);
      });

      test('getDoNotAskLocationRequired returns stored value', () async {
        when(() => mockAppPreferences.getDoNotAskLocationRequired())
            .thenAnswer((_) async => true);

        final result = await repository.getDoNotAskLocationRequired();

        expect(result, isTrue);
      });

      test('setDoNotAskShareToReport stores value', () async {
        when(() => mockAppPreferences.setDoNotAskShareToReport(any()))
            .thenAnswer((_) async {});

        await repository.setDoNotAskShareToReport(true);

        verify(() => mockAppPreferences.setDoNotAskShareToReport(true))
            .called(1);
      });

      test('getDoNotAskShareToReport returns stored value', () async {
        when(() => mockAppPreferences.getDoNotAskShareToReport())
            .thenAnswer((_) async => false);

        final result = await repository.getDoNotAskShareToReport();

        expect(result, isFalse);
      });

      test('setDoNotAskInAppReview stores value', () async {
        when(() => mockAppPreferences.setDoNotAskInAppReview(any()))
            .thenAnswer((_) async {});

        await repository.setDoNotAskInAppReview(true);

        verify(() => mockAppPreferences.setDoNotAskInAppReview(true)).called(1);
      });

      test('getDoNotAskInAppReview returns stored value', () async {
        when(() => mockAppPreferences.getDoNotAskInAppReview())
            .thenAnswer((_) async => true);

        final result = await repository.getDoNotAskInAppReview();

        expect(result, isTrue);
      });
    });

    group('Location accuracy preferences', () {
      test('setLocationAccuracyDenied stores value', () async {
        when(() => mockAppPreferences.setLocationAccuracyDenied(any()))
            .thenAnswer((_) async {});

        await repository.setLocationAccuracyDenied(true);

        verify(() => mockAppPreferences.setLocationAccuracyDenied(true))
            .called(1);
      });

      test('getLocationAccuracyDenied returns stored value', () async {
        when(() => mockAppPreferences.getLocationAccuracyDenied())
            .thenAnswer((_) async => true);

        final result = await repository.getLocationAccuracyDenied();

        expect(result, isTrue);
      });
    });

    group('In-app review preferences', () {
      test('setInAppReviewShowTimes stores value', () async {
        when(() => mockAppPreferences.setInAppReviewShowTimes(any()))
            .thenAnswer((_) async {});

        await repository.setInAppReviewShowTimes(5);

        verify(() => mockAppPreferences.setInAppReviewShowTimes(5)).called(1);
      });

      test('getInAppReviewShowTimes returns stored value', () async {
        when(() => mockAppPreferences.getInAppReviewShowTimes())
            .thenAnswer((_) async => 3);

        final result = await repository.getInAppReviewShowTimes();

        expect(result, equals(3));
      });

      test('getInAppReviewShowTimes returns null when not set', () async {
        when(() => mockAppPreferences.getInAppReviewShowTimes())
            .thenAnswer((_) async => null);

        final result = await repository.getInAppReviewShowTimes();

        expect(result, isNull);
      });
    });

    group('Stage planner preferences', () {
      test('setDoNotAskStagePlannerAnnouncement stores value', () async {
        when(() => mockAppPreferences.setDoNotAskStagePlannerAnnouncement(any()))
            .thenAnswer((_) async {});

        await repository.setDoNotAskStagePlannerAnnouncement(true);

        verify(
                () => mockAppPreferences.setDoNotAskStagePlannerAnnouncement(true),)
            .called(1);
      });

      test('getDoNotAskStagePlannerAnnouncement returns stored value', () async {
        when(() => mockAppPreferences.getDoNotAskStagePlannerAnnouncement())
            .thenAnswer((_) async => false);

        final result = await repository.getDoNotAskStagePlannerAnnouncement();

        expect(result, isFalse);
      });

      test('setShowNewLabelOnPlanTab stores value', () async {
        when(() => mockAppPreferences.setShowNewLabelOnPlanTab(any()))
            .thenAnswer((_) async {});

        await repository.setShowNewLabelOnPlanTab(true);

        verify(() => mockAppPreferences.setShowNewLabelOnPlanTab(true))
            .called(1);
      });

      test('getShowNewLabelOnPlanTab returns stored value', () async {
        when(() => mockAppPreferences.getShowNewLabelOnPlanTab())
            .thenAnswer((_) async => true);

        final result = await repository.getShowNewLabelOnPlanTab();

        expect(result, isTrue);
      });
    });

    group('Select destination check points', () {
      test('setSelectDestinationCheckPoints stores value', () async {
        final dateTime = DateTime(2024, 6);
        when(() => mockAppPreferences.setSelectDestinationCheckPoints(any()))
            .thenAnswer((_) async {});

        await repository.setSelectDestinationCheckPoints(dateTime);

        verify(
                () => mockAppPreferences.setSelectDestinationCheckPoints(dateTime),)
            .called(1);
      });

      test('setSelectDestinationCheckPoints removes value when null', () async {
        when(() => mockAppPreferences.removeSelectDestinationCheckPoints())
            .thenAnswer((_) async {});

        await repository.setSelectDestinationCheckPoints(null);

        verify(() => mockAppPreferences.removeSelectDestinationCheckPoints())
            .called(1);
      });

      test('getSelectDestinationCheckPoints returns stored value', () async {
        final dateTime = DateTime(2024, 6);
        when(() => mockAppPreferences.getSelectDestinationCheckPoints())
            .thenAnswer((_) async => dateTime);

        final result = await repository.getSelectDestinationCheckPoints();

        expect(result, equals(dateTime));
      });
    });

    group('Firebase config', () {
      test('getOptionalUpgradeMinBuild returns value from config', () async {
        when(() => mockFirebaseConfigDataSource.getOptionalUpgradeMinBuild())
            .thenReturn(100);

        final result = await repository.getOptionalUpgradeMinBuild();

        expect(result, equals(100));
      });

      test('getOptionalUpgradeMinBuild returns null when not configured',
          () async {
        when(() => mockFirebaseConfigDataSource.getOptionalUpgradeMinBuild())
            .thenReturn(null);

        final result = await repository.getOptionalUpgradeMinBuild();

        expect(result, isNull);
      });
    });

    // =========================================================================
    // Auth Operations
    // =========================================================================
    group('login', () {
      test('login success saves credential and returns response', () async {
        const loginResponse = LoginResponse(
          user: UserResponse(
            id: 1,
            fullName: 'Test User',
            email: 'test@example.com',
          ),
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
        );

        when(() => mockNetworkService.login(
              token: any(named: 'token'),
              loginType: any(named: 'loginType'),
              name: any(named: 'name'),
            ),).thenAnswer((_) async => const ApiSuccess(loginResponse));
        when(() => mockAppPreferences.setUserCredential(any()))
            .thenAnswer((_) async {});

        final result = await repository.login(
          token: 'google_token',
          loginType: 'google',
        );

        expect(result.accessToken, equals('access_token'));
        verify(() => mockAppPreferences.setUserCredential(any())).called(1);
      });

      test('login failure throws exception', () async {
        when(() => mockNetworkService.login(
              token: any(named: 'token'),
              loginType: any(named: 'loginType'),
              name: any(named: 'name'),
            ),).thenAnswer((_) async => const ApiFailure('Login failed'));

        expect(
          () => repository.login(token: 'token', loginType: 'google'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('refreshToken', () {
      test('refreshToken success saves credential and returns response',
          () async {
        const loginResponse = LoginResponse(
          user: UserResponse(
            id: 1,
            fullName: 'Test User',
            email: 'test@example.com',
          ),
          accessToken: 'new_access_token',
          refreshToken: 'new_refresh_token',
        );

        when(() => mockNetworkService.refreshToken(
              refreshToken: any(named: 'refreshToken'),
            ),).thenAnswer((_) async => const ApiSuccess(loginResponse));
        when(() => mockAppPreferences.setUserCredential(any()))
            .thenAnswer((_) async {});

        final result = await repository.refreshToken(
          refreshToken: 'old_refresh_token',
        );

        expect(result?.accessToken, equals('new_access_token'));
        verify(() => mockAppPreferences.setUserCredential(any())).called(1);
      });

      test('refreshToken failure returns null', () async {
        when(() => mockNetworkService.refreshToken(
              refreshToken: any(named: 'refreshToken'),
            ),).thenAnswer((_) async => const ApiFailure('Token expired'));

        final result = await repository.refreshToken(
          refreshToken: 'old_refresh_token',
        );

        expect(result, isNull);
      });
    });

    group('getCredential', () {
      test('returns stored credential', () async {
        const storedCredential = CredentialEntity(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
        );
        when(() => mockAppPreferences.getUserCredential())
            .thenAnswer((_) async => storedCredential);

        final result = await repository.getCredential();

        expect(result, equals(storedCredential));
      });

      test('returns null when no credential stored', () async {
        when(() => mockAppPreferences.getUserCredential())
            .thenAnswer((_) async => null);

        final result = await repository.getCredential();

        expect(result, isNull);
      });
    });

    group('isProceedAsGuest', () {
      test('returns true when user is guest', () async {
        when(() => mockAppPreferences.isProceedAsGuest())
            .thenAnswer((_) async => true);

        final result = await repository.isProceedAsGuest();

        expect(result, isTrue);
      });

      test('returns false when user is not guest', () async {
        when(() => mockAppPreferences.isProceedAsGuest())
            .thenAnswer((_) async => false);

        final result = await repository.isProceedAsGuest();

        expect(result, isFalse);
      });
    });

    group('setProceedAsGuest', () {
      test('sets proceed as guest flag', () async {
        when(() => mockAppPreferences.setProceedAsGuest(any()))
            .thenAnswer((_) async {});

        await repository.setProceedAsGuest(true);

        verify(() => mockAppPreferences.setProceedAsGuest(true)).called(1);
      });
    });

    group('logout', () {
      test('clears guest flag and logs out', () async {
        when(() => mockAppPreferences.setProceedAsGuest(any()))
            .thenAnswer((_) async {});
        when(() => mockAppPreferences.logout()).thenAnswer((_) async {});

        await repository.logout();

        verify(() => mockAppPreferences.setProceedAsGuest(false)).called(1);
        verify(() => mockAppPreferences.logout()).called(1);
      });
    });

    group('isAuthenticated', () {
      test('returns true when credential is logged in', () async {
        // Create a valid credential with future expiry dates
        final futureExpiry = DateTime.now().add(const Duration(days: 30));
        final validCredential = CredentialEntity(
          accessToken: 'valid_token',
          refreshToken: 'valid_refresh',
          accessTokenExpiry: futureExpiry,
          refreshTokenExpiry: futureExpiry,
        );
        when(() => mockAppPreferences.getUserCredential())
            .thenAnswer((_) async => validCredential);

        final result = await repository.isAuthenticated();

        expect(result, isTrue);
      });

      test('returns false when no credential', () async {
        when(() => mockAppPreferences.getUserCredential())
            .thenAnswer((_) async => null);

        final result = await repository.isAuthenticated();

        expect(result, isFalse);
      });

      test('returns false when credential is not logged in', () async {
        // Create an expired credential
        final pastExpiry = DateTime.now().subtract(const Duration(days: 30));
        final expiredCredential = CredentialEntity(
          accessToken: 'expired_token',
          refreshToken: 'expired_refresh',
          accessTokenExpiry: pastExpiry,
          refreshTokenExpiry: pastExpiry,
        );
        when(() => mockAppPreferences.getUserCredential())
            .thenAnswer((_) async => expiredCredential);

        final result = await repository.isAuthenticated();

        expect(result, isFalse);
      });
    });

    // =========================================================================
    // User Actions Operations
    // =========================================================================
    group('getAlbergueReviews', () {
      test('returns reviews from API', () async {
        when(() => mockNetworkService.getAlbergueReviews(
              albergueId: any(named: 'albergueId'),
              page: any(named: 'page'),
              perPage: any(named: 'perPage'),
            ),).thenAnswer(
          (_) async => ApiSuccess(
            AlbergueReviewResponse(
              total: 2,
              albergueUserReviews: [
                AlbergueUserReviewResponse(
                  id: 1,
                  albergueId: 100,
                  name: 'User 1',
                  email: 'user1@test.com',
                  userComment: 'Great!',
                  userRating: 5,
                ),
                AlbergueUserReviewResponse(
                  id: 2,
                  albergueId: 100,
                  name: 'User 2',
                  email: 'user2@test.com',
                  userComment: 'Good',
                  userRating: 4,
                ),
              ],
            ),
          ),
        );

        final result = await repository.getAlbergueReviews(albergueId: 100);

        expect(result.total, equals(2));
        expect(result.albergueUserReviews?.length, equals(2));
        expect(result.albergueUserReviews?[0].userRating, equals(5));
      });

      test('throws exception on API failure', () async {
        when(() => mockNetworkService.getAlbergueReviews(
              albergueId: any(named: 'albergueId'),
              page: any(named: 'page'),
              perPage: any(named: 'perPage'),
            ),).thenAnswer((_) async => const ApiFailure('Network error'));

        expect(
          () => repository.getAlbergueReviews(albergueId: 100),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createAlbergueReview', () {
      test('creates review successfully', () async {
        when(() => mockNetworkService.createAlbergueReview(
              albergueId: any(named: 'albergueId'),
              userRating: any(named: 'userRating'),
              userComment: any(named: 'userComment'),
              images: any(named: 'images'),
              email: any(named: 'email'),
              name: any(named: 'name'),
            ),).thenAnswer((_) async => const ApiSuccess({'success': true}));

        final result = await repository.createAlbergueReview(
          albergueId: 100,
          rating: 5,
          comment: 'Great place!',
        );

        expect(result, isNotNull);
      });

      test('throws exception on failure', () async {
        when(() => mockNetworkService.createAlbergueReview(
              albergueId: any(named: 'albergueId'),
              userRating: any(named: 'userRating'),
              userComment: any(named: 'userComment'),
              images: any(named: 'images'),
              email: any(named: 'email'),
              name: any(named: 'name'),
            ),).thenAnswer((_) async => const ApiFailure('Failed to create'));

        expect(
          () => repository.createAlbergueReview(
            albergueId: 100,
            rating: 5,
            comment: 'Test',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createAlbergueFeedback', () {
      test('creates feedback successfully', () async {
        when(() => mockNetworkService.createAlbergueFeedback(
              albergueId: any(named: 'albergueId'),
              feedback: any(named: 'feedback'),
              images: any(named: 'images'),
              email: any(named: 'email'),
              name: any(named: 'name'),
            ),).thenAnswer((_) async => const ApiSuccess({'success': true}));

        final result = await repository.createAlbergueFeedback(
          albergueId: 100,
          feedback: 'Some feedback',
        );

        expect(result, isNotNull);
      });

      test('throws exception on failure', () async {
        when(() => mockNetworkService.createAlbergueFeedback(
              albergueId: any(named: 'albergueId'),
              feedback: any(named: 'feedback'),
              images: any(named: 'images'),
              email: any(named: 'email'),
              name: any(named: 'name'),
            ),).thenAnswer((_) async => const ApiFailure('Failed'));

        expect(
          () => repository.createAlbergueFeedback(
            albergueId: 100,
            feedback: 'Test',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('reportMissingAlbergue', () {
      test('reports missing albergue successfully', () async {
        when(() => mockNetworkService.reportMissingAlbergue(
              cityId: any(named: 'cityId'),
              reportDetails: any(named: 'reportDetails'),
              images: any(named: 'images'),
              lon: any(named: 'lon'),
              lat: any(named: 'lat'),
              email: any(named: 'email'),
              name: any(named: 'name'),
              address: any(named: 'address'),
            ),).thenAnswer((_) async => const ApiSuccess({'success': true}));

        final result = await repository.reportMissingAlbergue(
          cityId: 1,
          reportDetails: 'Missing albergue details',
        );

        expect(result, isNotNull);
      });

      test('throws exception on failure', () async {
        when(() => mockNetworkService.reportMissingAlbergue(
              cityId: any(named: 'cityId'),
              reportDetails: any(named: 'reportDetails'),
              images: any(named: 'images'),
              lon: any(named: 'lon'),
              lat: any(named: 'lat'),
              email: any(named: 'email'),
              name: any(named: 'name'),
              address: any(named: 'address'),
            ),).thenAnswer((_) async => const ApiFailure('Failed'));

        expect(
          () => repository.reportMissingAlbergue(
            cityId: 1,
            reportDetails: 'Test',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createBugReport', () {
      test('creates bug report successfully', () async {
        when(() => mockNetworkService.createBugReport(
              text: any(named: 'text'),
              images: any(named: 'images'),
              email: any(named: 'email'),
              dbDump: any(named: 'dbDump'),
              clientContext: any(named: 'clientContext'),
            ),).thenAnswer((_) async => const ApiSuccess({'success': true}));

        final result = await repository.createBugReport(
          text: 'Bug description',
        );

        expect(result, isNotNull);
      });

      test('throws exception on failure', () async {
        when(() => mockNetworkService.createBugReport(
              text: any(named: 'text'),
              images: any(named: 'images'),
              email: any(named: 'email'),
              dbDump: any(named: 'dbDump'),
              clientContext: any(named: 'clientContext'),
            ),).thenAnswer((_) async => const ApiFailure('Failed'));

        expect(
          () => repository.createBugReport(text: 'Test'),
          throwsA(isA<Exception>()),
        );
      });

      test('forwards dbDump to network service when provided', () async {
        when(() => mockNetworkService.createBugReport(
              text: any(named: 'text'),
              images: any(named: 'images'),
              email: any(named: 'email'),
              dbDump: any(named: 'dbDump'),
              clientContext: any(named: 'clientContext'),
            ),).thenAnswer((_) async => const ApiSuccess({'success': true}));

        // Use a non-existent path; we only verify pass-through, not
        // that the file is read.
        final fakeArchive = File('/tmp/test_db_dump.zip');
        await repository.createBugReport(
          text: 'Bug with attachment',
          dbDump: fakeArchive,
        );

        verify(() => mockNetworkService.createBugReport(
              text: 'Bug with attachment',
              dbDump: fakeArchive,
            ),).called(1);
      });

      test('forwards clientContext to network service when provided',
          () async {
        when(() => mockNetworkService.createBugReport(
              text: any(named: 'text'),
              images: any(named: 'images'),
              email: any(named: 'email'),
              dbDump: any(named: 'dbDump'),
              clientContext: any(named: 'clientContext'),
            ),).thenAnswer((_) async => const ApiSuccess({'success': true}));

        const ctx = '{"schema_version":1,"app_version":"2.2.395",'
            '"build_number":"202395","platform":"ios",'
            '"os_version":"iOS 18.0","device_model":"iPhone17,2"}';
        await repository.createBugReport(
          text: 'Bug with context',
          clientContext: ctx,
        );

        verify(() => mockNetworkService.createBugReport(
              text: 'Bug with context',
              clientContext: ctx,
            ),).called(1);
      });

      test('passes null clientContext when omitted', () async {
        when(() => mockNetworkService.createBugReport(
              text: any(named: 'text'),
              images: any(named: 'images'),
              email: any(named: 'email'),
              dbDump: any(named: 'dbDump'),
              clientContext: any(named: 'clientContext'),
            ),).thenAnswer((_) async => const ApiSuccess({'success': true}));

        await repository.createBugReport(text: 'Plain bug');

        verify(() => mockNetworkService.createBugReport(
              text: 'Plain bug',
            ),).called(1);
      });
    });

    group('uploadAlbergueImage', () {
      test('uploads image successfully', () async {
        when(() => mockNetworkService.uploadAlbergueImage(
              albergueId: any(named: 'albergueId'),
              images: any(named: 'images'),
              cancelToken: any(named: 'cancelToken'),
            ),).thenAnswer((_) async => const ApiSuccess({'success': true}));

        final result = await repository.uploadAlbergueImage(
          albergueId: 100,
          images: [],
        );

        expect(result, isA<ApiSuccess<dynamic>>());
      });

      test('returns failure on API error', () async {
        when(() => mockNetworkService.uploadAlbergueImage(
              albergueId: any(named: 'albergueId'),
              images: any(named: 'images'),
              cancelToken: any(named: 'cancelToken'),
            ),).thenAnswer((_) async => const ApiFailure('Upload failed'));

        final result = await repository.uploadAlbergueImage(
          albergueId: 100,
          images: [],
        );

        expect(result, isA<ApiFailure<dynamic>>());
      });
    });

  });
}
