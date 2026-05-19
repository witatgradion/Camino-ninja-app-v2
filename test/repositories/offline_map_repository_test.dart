import 'package:camino_ninja_flutter/repositories/offline_map_repository.dart';
import 'package:camino_ninja_flutter/utils/offline_map_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storage/storage.dart';

class _MockOfflineMapService extends Mock implements OfflineMapService {}

void main() {
  setUpAll(() {
    registerFallbackValue(<RoutePointEntity>[]);
  });

  late _MockOfflineMapService service;
  late OfflineMapRepository repository;

  const routeId = 42;
  const routeName = 'Camino Frances';
  const points = <RoutePointEntity>[
    RoutePointEntity(
      id: 1,
      orderKey: 0,
      elevation: 100,
      routeId: routeId,
      latitude: 42.88,
      longitude: -8.54,
    ),
    RoutePointEntity(
      id: 2,
      orderKey: 1,
      elevation: 110,
      routeId: routeId,
      latitude: 42.89,
      longitude: -8.55,
    ),
  ];

  setUp(() {
    service = _MockOfflineMapService();
    repository = OfflineMapRepository(service);
  });

  group('OfflineMapRepository — flag off', () {
    test('downloadIfNeeded does not call service', () async {
      await repository.downloadIfNeeded(
        routeId: routeId,
        routeName: routeName,
        points: points,
      );

      verifyNever(
        () => service.downloadIfNeeded(
          routeId: any(named: 'routeId'),
          routeName: any(named: 'routeName'),
          points: any(named: 'points'),
        ),
      );
    });

    test('downloadRouteRegion returns false and does not call '
        'service', () async {
      final result = await repository.downloadRouteRegion(
        routeId: routeId,
        routeName: routeName,
        points: points,
        onProgress: (_, __, ___) {},
      );

      expect(result, isFalse);
      verifyNever(
        () => service.downloadRouteRegion(
          routeId: any(named: 'routeId'),
          routeName: any(named: 'routeName'),
          points: any(named: 'points'),
          onProgress: any(named: 'onProgress'),
        ),
      );
    });

    test('downloadStylePacks does not call service', () async {
      await repository.downloadStylePacks(onProgress: (_, __) {});

      verifyNever(
        () => service.downloadStylePacks(
          onProgress: any(named: 'onProgress'),
        ),
      );
    });

    test('isRouteDownloaded returns false and does not call '
        'service', () async {
      final result = await repository.isRouteDownloaded(routeId);

      expect(result, isFalse);
      verifyNever(() => service.isRouteDownloaded(any()));
    });

    test('areStylePacksDownloaded returns false and does not '
        'call service', () async {
      final result = await repository.areStylePacksDownloaded();

      expect(result, isFalse);
      verifyNever(() => service.areStylePacksDownloaded());
    });

    test('listDownloadedRegions returns empty and does not '
        'call service', () async {
      final result = await repository.listDownloadedRegions();

      expect(result, isEmpty);
      verifyNever(() => service.listDownloadedRegions());
    });

    test('getTotalStorageBytes returns 0 and does not call '
        'service', () async {
      final result = await repository.getTotalStorageBytes();

      expect(result, 0);
      verifyNever(() => service.getTotalStorageBytes());
    });
  });

  group('OfflineMapRepository — cleanup forwards regardless of '
      'flag', () {
    test('cancelDownload always forwards to service', () async {
      when(() => service.cancelDownload())
          .thenAnswer((_) async {});

      await repository.cancelDownload();

      verify(() => service.cancelDownload()).called(1);
    });

    test('deleteRouteRegion always forwards to service',
        () async {
      when(() => service.deleteRouteRegion(routeId))
          .thenAnswer((_) async {});

      await repository.deleteRouteRegion(routeId);

      verify(() => service.deleteRouteRegion(routeId)).called(1);
    });
  });
}
