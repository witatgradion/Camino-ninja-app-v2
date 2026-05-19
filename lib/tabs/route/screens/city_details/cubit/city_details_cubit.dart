import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'city_details_state.dart';

class CityDetailsCubit extends Cubit<CityDetailsState> with SafeEmitMixin {
  CityDetailsCubit({
    required this.cityId,
    required this.routeId,
    this.selectedAlbergue,
  }) : super(const CityDetailsState());

  final Repository _repository = GetIt.instance<Repository>();
  final int cityId;
  final int routeId;
  final AlbergueEntity? selectedAlbergue;

  Stream<int?> get selectedIndexStream =>
      stream.map((s) => s.selectedIndex).distinct();

  Future<void> init() async {
    try {
      safeEmit(state.copyWith(status: CityDetailsStatus.loading));
      await Future.wait([
        getCity(),
        getAlbergues(),
        getRoutePoints(),
      ]);

      final albergues = state.albergues;
      final selectedIndex = albergues.indexWhere(
        (albergue) => albergue.id == selectedAlbergue?.id,
      );

      if (selectedIndex != -1) {
        Future.delayed(const Duration(milliseconds: 100), () {
          safeEmit(
            state.copyWith(
              selectedIndex: selectedIndex,
              expandedAlbergueId: selectedAlbergue?.id,
            ),
          );
        });
      }

      safeEmit(state.copyWith(status: CityDetailsStatus.loaded));
    } catch (e) {
      AppLogger.e(
        'Error initializing city details',
        tag: 'CityDetailsCubit',
        error: e,
      );
    }
    safeEmit(state.copyWith(status: CityDetailsStatus.loaded));
  }

  Future<void> getCity() async {
    final city = await _repository.getCityByIdFromDb(cityId);
    final cityHasAlbergues = await _repository.cityHasAlbergues(cityId);
    safeEmit(
      state.copyWith(
        city: city,
        services: parseAvailableServices(
          city: city,
          hasAlbergues: cityHasAlbergues,
        ),
      ),
    );
  }

  Future<void> getRoutePoints() async {
    try {
      final routePoints = await _repository.getRoutePointsByRouteIdFromDb(
        routeId: routeId,
      );
      final altRoutePoints =
          await _repository.getAltRoutePointsWithValueByRouteId(
        routeId: routeId,
      );
      safeEmit(
        state.copyWith(
          routePoints: routePoints.map((point) {
            return LatLng(
              point.latitude,
              point.longitude,
            );
          }).toList(),
          altRoutePoints: altRoutePoints,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          routePoints: [],
          altRoutePoints: [],
        ),
      );
    }
  }

  Future<void> getAlbergues() async {
    try {
      final updatedAlbergues =
          await _repository.getAlberguesWithNestedObjectsFromDb(
        cityId: cityId,
      );

      final albergueIdToBookmarked = <int, bool>{};
      final favoriteAlbergueIds = await _repository.getFavoriteAlbergueIds();
      for (final id in favoriteAlbergueIds) {
        albergueIdToBookmarked[id] = true;
      }

      // Pre-compute lowest prices for all albergues (O(n*m) once, not per comparison)
      final lowestPriceMap = <int, double?>{};
      for (final albergue in updatedAlbergues) {
        lowestPriceMap[albergue.id] = _getLowestPrice(albergue);
      }

      // Sort albergues by bookmarked status first, then by lowest price
      final sortedAlbergues = updatedAlbergues
        ..sort((a, b) {
          // Get bookmark status for each albergue
          final aBookmarked = albergueIdToBookmarked[a.id] ?? false;
          final bBookmarked = albergueIdToBookmarked[b.id] ?? false;

          // First priority: bookmarked albergues come first
          if (aBookmarked && !bBookmarked) return -1;
          if (!aBookmarked && bBookmarked) return 1;

          // Use pre-computed prices for O(1) lookup
          final aLowestPrice = lowestPriceMap[a.id];
          final bLowestPrice = lowestPriceMap[b.id];

          // Handle cases where prices might be null
          if (aLowestPrice == null && bLowestPrice == null) return 0;
          if (aLowestPrice == null) return 1;
          if (bLowestPrice == null) return -1;

          return aLowestPrice.compareTo(bLowestPrice);
        });

      safeEmit(
        state.copyWith(
          albergues: sortedAlbergues,
          filteredAlbergues: sortedAlbergues,
          albergueIdToBookmarked: albergueIdToBookmarked,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          albergues: [],
          filteredAlbergues: [],
        ),
      );
    }
  }

  Future<void> searchAlbergues(String query) async {
    safeEmit(
      state.copyWith(
        filteringStatus: CityDetailsFilteringStatus.loading,
      ),
    );
    final albergues = state.albergues;
    final filteredAlbergues = albergues.where((albergue) {
      return albergue.name
              .normalize()
              ?.toLowerCase()
              .contains(query.toLowerCase()) ??
          false;
    }).toList();
    safeEmit(
      state.copyWith(
        filteredAlbergues: filteredAlbergues,
        filteringStatus: CityDetailsFilteringStatus.success,
      ),
    );
  }

  bool isAlbergueBookmarked(int albergueId) {
    return state.albergueIdToBookmarked[albergueId] ?? false;
  }

  void setExpandedAlbergue(int id) {
    final currentExpandedAlbergueId = state.expandedAlbergueId;
    if (currentExpandedAlbergueId == id) {
      safeEmit(state.copyWith());
    } else {
      safeEmit(state.copyWith(expandedAlbergueId: id));
    }
  }

  bool isAlbergueExpanded(int id) {
    return state.expandedAlbergueId == id;
  }

  double? _getLowestPrice(AlbergueEntity albergue) {
    final prices = albergue.prices;
    final bookingPrice = albergue.bookingPrice;
    if (prices.isEmpty && bookingPrice == null) return null;

    var lowestPrice = bookingPrice;
    for (final price in prices) {
      final priceValues = [
        price.priceFromDormitory,
        price.priceToDormitory,
        price.priceFromBedSharedRoom,
        price.priceToBedSharedRoom,
        price.priceFromSingleroom,
        price.priceToSingleroom,
        price.priceFromDoubleroom,
        price.priceToDoubleroom,
        price.priceFromTripleroom,
        price.priceToTripleroom,
        price.priceFromQuatroroom,
        price.priceToQuatroroom,
        price.priceFromApartment,
        price.priceToApartment,
      ];

      for (final value in priceValues) {
        if (value != null && (lowestPrice == null || value < lowestPrice)) {
          lowestPrice = value;
        }
      }
    }
    return lowestPrice;
  }
}
