import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'elevation_state.dart';

class ElevationCubit extends Cubit<ElevationState> with SafeEmitMixin {
  ElevationCubit({
    required this.routeId,
    required this.startingCityId,
    required this.destCityId,
  }) : super(const ElevationState());

  final Repository _repository = GetIt.instance<Repository>();

  final int routeId;
  final int? startingCityId;
  final int? destCityId;

  StreamSubscription<Position>? _positionStream;

  @override
  Future<void> close() {
    _positionStream?.cancel();
    return super.close();
  }

  void updateCurrentLocationOnChart(Position position) {
    if (state.routePoints == null) return;

    safeEmit(
      state.copyWith(
        currentPosition: position,
      ),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = GeoConstants.earthRadiusKm;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  int? _getRoutePointIdForRoute(CityEntity city) {
    final routePoint = city.routePoints.firstWhere(
      (rp) => rp.routeId == routeId,
      orElse: () => city.routePoints.first,
    );
    return routePoint.id;
  }

  Future<void> getRoutePoints() async {
    try {
      final routePoints = await _repository.getRoutePointsByRouteIdFromDb(
        routeId: routeId,
        startingCityId: startingCityId,
        destCityId: destCityId,
      );

      final points = <ChartRoutePoint>[];
      final allCities = await _repository.getCitiesByRouteIdFromDb(routeId);
      var totalDistance = 0.0;
      ChartRoutePoint? previousPoint;

      for (final point in routePoints) {
        if (previousPoint != null) {
          totalDistance += _calculateDistance(
            previousPoint.lat,
            previousPoint.lon,
            point.latitude,
            point.longitude,
          );
        }
        points.add(
          ChartRoutePoint(
            id: point.id,
            lat: point.latitude,
            lon: point.longitude,
            ele: point.elevation,
            distance: totalDistance,
          ),
        );
        previousPoint = points.last;
      }

      var citiesToProcess = List<CityEntity>.from(allCities);
      if (startingCityId != null && destCityId != null) {
        citiesToProcess = allCities.sublist(
          allCities.indexWhere((element) => element.id == startingCityId),
          allCities.indexWhere((element) => element.id == destCityId) + 1,
        );
      }
      final chartCities = citiesToProcess
          .map((city) {
            final cityRoutePointId = _getRoutePointIdForRoute(city);
            if (cityRoutePointId == null) return null;

            final routePoint = points.firstWhere(
              (element) => element.id == cityRoutePointId,
              orElse: () => points.first,
            );
            return ChartCity(
              name: city.name,
              routePointId: cityRoutePointId,
              distance: routePoint.distance,
            );
          })
          .whereType<ChartCity>() // Filter out null values
          .toList();

      safeEmit(
        state.copyWith(
          routePoints: points,
          cities: chartCities,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          routePoints: [],
          cities: [],
        ),
      );
    }
  }
}
