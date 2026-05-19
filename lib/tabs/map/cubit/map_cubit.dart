import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> with SafeEmitMixin {
  MapCubit({
    this.routeId,
  }) : super(const MapState());

  final int? routeId;

  final Repository _repository = GetIt.instance<Repository>();

  Stream<List<CityEntity>> get citiesStream => stream.map((s) => s.cities);

  Stream<LoadDataMapStatus> get loadDataMapStatusStream =>
      stream.map((s) => s.loadDataMapStatus).distinct();

  Future<bool> loadDoNotAskLocationRequired() async {
    try {
      final doNotAskLocationRequired =
          await _repository.getDoNotAskLocationRequired();
      return doNotAskLocationRequired;
    } catch (e) {
      return true;
    }
  }

  Future<void> loadCities({int? startingCityId, int? destCityId}) async {
    try {
      if (routeId == null) {
        return;
      }
      safeEmit(state.copyWith(loadDataMapStatus: LoadDataMapStatus.loading));
      final route = await _repository.getRouteById(routeId!);
      final cities = await _repository.getCitiesByRouteIdFromDb(routeId!);

      final filteredCities = _buildCitiesForMap(
        allCities: cities,
        startingCityId: startingCityId,
        destCityId: destCityId,
      );

      safeEmit(state.copyWith(cities: filteredCities, route: route));
      safeEmit(state.copyWith(loadDataMapStatus: LoadDataMapStatus.loaded));
    } catch (e) {
      safeEmit(state.copyWith(loadDataMapStatus: LoadDataMapStatus.error));
    }
  }

  /// Returns a minimal list of cities for the map:
  /// - always includes the first and last city of the route (if available)
  /// - also includes starting/destination cities when provided
  /// - never duplicates cities (by id), even if they overlap
  List<CityEntity> _buildCitiesForMap({
    required List<CityEntity> allCities,
    int? startingCityId,
    int? destCityId,
  }) {
    if (allCities.isEmpty) return const [];

    final result = <CityEntity>[];
    final firstCity = allCities.first;
    final lastCity = allCities.last;

    CityEntity? startingCity;
    if (startingCityId != null) {
      try {
        startingCity =
            allCities.firstWhere((city) => city.id == startingCityId);
      } catch (_) {
        startingCity = null;
      }
    }

    CityEntity? destCity;
    if (destCityId != null) {
      try {
        destCity = allCities.firstWhere((city) => city.id == destCityId);
      } catch (_) {
        destCity = null;
      }
    }

    void addIfUnique(CityEntity? city) {
      if (city == null) return;
      final exists = result.any((c) => c.id == city.id);
      if (!exists) {
        result.add(city);
      }
    }

    // Ensure route endpoints stay as first/last in the list
    addIfUnique(firstCity);
    addIfUnique(startingCity);
    addIfUnique(destCity);
    if (allCities.length > 1) {
      addIfUnique(lastCity);
    }

    return result;
  }

  Future<void> setDoNotAskLocationRequired(bool value) async {
    await _repository.setDoNotAskLocationRequired(value);
  }
}
