import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_starting_point/select_starting_point_screen.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/location_service.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'select_starting_point_state.dart';

class SelectStartingPointCubit extends Cubit<SelectStartingPointState>
    with SafeEmitMixin {
  SelectStartingPointCubit({
    required this.selectedRoute,
    this.selectedStartingPoint,
    this.minCity,
    this.maxCity,
  }) : super(const SelectStartingPointState());

  final RouteEntity selectedRoute;
  final CityEntity? selectedStartingPoint;

  /// Lower bound (inclusive) for city filtering.
  final CityEntity? minCity;

  /// Upper bound (inclusive) for city filtering.
  final CityEntity? maxCity;

  final _repository = GetIt.instance<Repository>();

  Stream<int?> get nearestCityIndexStream =>
      stream.map((s) => s.autoScrollCityIndex).distinct();

  Future<void> filterCities() async {
    safeEmit(state.copyWith(initStatus: SelectStartingPointInitStatus.loading));
    final allCities =
        await _repository.getCitiesByRouteIdFromDb(selectedRoute.id);

    // Apply lower bound (inclusive)
    var cities = allCities;
    if (minCity != null) {
      final minIndex =
          cities.indexWhere((c) => c.id == minCity!.id);
      if (minIndex != -1) {
        cities = cities.sublist(minIndex);
      }
    }

    // Apply upper bound (inclusive)
    if (maxCity != null) {
      final maxIndex =
          cities.indexWhere((c) => c.id == maxCity!.id);
      if (maxIndex != -1) {
        cities = cities.sublist(0, maxIndex + 1);
      }
    }

    safeEmit(
      SelectStartingPointState(
        cities: cities,
        filteredCities: cities,
        selectedStartingPoint: selectedStartingPoint,
      ),
    );

    var shouldAutoScrollToNearestCity = true;
    if (selectedStartingPoint != null) {
      final autoScrollCityIndex = cities.indexWhere(
        (city) => city.id == selectedStartingPoint!.id,
      );
      if (autoScrollCityIndex != -1) {
        shouldAutoScrollToNearestCity = false;
        safeEmit(
          state.copyWith(
            initStatus: SelectStartingPointInitStatus.success,
          ),
        );
        Future.delayed(const Duration(milliseconds: 100), () {
          safeEmit(state.copyWith(autoScrollCityIndex: autoScrollCityIndex));
        });
      }
    }
    if (state.cities.isEmpty) {
      safeEmit(
        state.copyWith(
          initStatus: SelectStartingPointInitStatus.success,
        ),
      );
      return;
    }

    safeEmit(state.copyWith(autoScroll: shouldAutoScrollToNearestCity));
    await selectNearestCity();
  }

  Future<bool> selectNearestCity({
    bool locationAccuracyOff = false,
    bool isSelectCurrentLocation = false,
  }) async {
    try {
      safeEmit(
        state.copyWith(
          initStatus: SelectStartingPointInitStatus.loading,
          accuracyDenied: false,
          isSelectCurrentLocation: false,
        ),
      );

      // Get current location using static method
      Position? position;
      try {
        position = await LocationService.getCurrentPosition(
          locationAccuracyOff: locationAccuracyOff,
        );
      } on LocationServiceDisabledException {
        AppLogger.w('Accuracy disabled', tag: 'SelectStartingPointCubit');
        safeEmit(
          state.copyWith(
            accuracyDenied: true,
            isSelectCurrentLocation: isSelectCurrentLocation,
            initStatus: SelectStartingPointInitStatus.success,
          ),
        );
        return false;
      }
      if (position == null) {
        safeEmit(
          state.copyWith(
            initStatus: SelectStartingPointInitStatus.success,
            isSelectCurrentLocation: isSelectCurrentLocation,
          ),
        );
        return false;
      }

      // Find nearest city
      var nearestCity = state.cities.first;
      var shortestDistance = double.infinity;

      for (final city in state.cities) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          city.latitude,
          city.longitude,
        );

        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearestCity = city;
        }
      }
      safeEmit(
        state.copyWith(
          initStatus: SelectStartingPointInitStatus.success,
          nearestCity: nearestCity,
          nearestCityDistance: shortestDistance,
          isSelectCurrentLocation: isSelectCurrentLocation,
        ),
      );
      if (state.autoScroll) {
        final nearestCityIndex = state.cities.indexWhere(
          (city) => city.id == nearestCity.id,
        );
        if (shortestDistance <= maxAllowedDistance) {
          safeEmit(state.copyWith(autoScrollCityIndex: nearestCityIndex));
        }
      }
      return true;
    } catch (e) {
      // Handle location errors
      safeEmit(
        state.copyWith(
          error: 'Could not determine location',
          initStatus: SelectStartingPointInitStatus.success,
          isSelectCurrentLocation: isSelectCurrentLocation,
        ),
      );
      return false;
    }
  }

  void searchCities(String query) {
    safeEmit(
      state.copyWith(
        filteringStatus: SelectStartingPointFilteringStatus.loading,
      ),
    );
    final allCities = state.cities;
    if (query.trim().isEmpty) {
      safeEmit(
        state.copyWith(
          filteredCities: allCities,
          filteringStatus: SelectStartingPointFilteringStatus.success,
        ),
      );
      return;
    }

    final filteredCities = allCities.where((city) {
      final searchLower = query.toLowerCase();
      return city.name.normalize()?.toLowerCase().contains(searchLower) ??
          false;
    }).toList();

    safeEmit(
      state.copyWith(
        filteredCities: filteredCities,
        filteringStatus: SelectStartingPointFilteringStatus.success,
      ),
    );
  }
}
