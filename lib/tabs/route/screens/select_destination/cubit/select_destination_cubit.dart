import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'select_destination_state.dart';

const kMinPercentageForRanking = 2;

/// Tiers = top 3 distinct rounded percentages (among pairs ≥ [kMinPercentageForRanking]).
/// Cities sharing the same rounded % share the same [CityPairRank].
Map<int, CityPairRank> _cityPairRanksFromPairs(
  Map<int, CityPairDetailResponse> cityPairsMap,
) {
  final eligible = cityPairsMap.entries
      .where((e) => (e.value.percentage ?? 0) >= kMinPercentageForRanking)
      .toList()
    ..sort((a, b) {
      final pa = a.value.percentage ?? 0;
      final pb = b.value.percentage ?? 0;
      final byPct = pb.compareTo(pa);
      if (byPct != 0) return byPct;
      return b.key.compareTo(a.key);
    });

  if (eligible.isEmpty) return {};

  final distinctRoundedDesc = eligible
      .map((e) => (e.value.percentage ?? 0).round())
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  final tierRounded = distinctRoundedDesc.take(3).toList();
  final result = <int, CityPairRank>{};
  for (final e in eligible) {
    final r = (e.value.percentage ?? 0).round();
    final idx = tierRounded.indexOf(r);
    if (idx < 0 || idx >= CityPairRank.values.length) continue;
    result[e.key] = CityPairRank.values[idx];
  }
  return result;
}

class SelectDestinationCubit extends Cubit<SelectDestinationState>
    with SafeEmitMixin {
  SelectDestinationCubit({
    required this.selectedStartingPoint,
    required this.selectedRoute,
    this.selectedDestination,
    this.maxEndCity,
  }) : super(const SelectDestinationState());

  final CityEntity selectedStartingPoint;
  final CityEntity? selectedDestination;
  final RouteEntity selectedRoute;
  final CityEntity? maxEndCity;
  final _repository = GetIt.instance<Repository>();
  final _databaseHelper = GetIt.instance<AppDatabase>();
  final _analyticsServices = GetIt.instance<IAnalyticsService>();

  Stream<int?> get nearestCityIndexStream =>
      stream.map((s) => s.nearestCityIndex).distinct();

  bool triggerAutoScroll = false;
  bool _cityPairsLoaded = false;

  Future<void> getCityPairs() async {
    final routeCities =
        await _repository.getCitiesByRouteIdFromDb(selectedRoute.id);
    await _loadCityPairs(routeCities);
  }

  Future<void> _loadCityPairs(List<CityEntity> routeCities) async {
    try {
      safeEmit(state.copyWith(startCityName: selectedStartingPoint.name));

      final cityPairsResult = await _repository
          .getCityPairsExportByStartCityId(selectedStartingPoint.id);
      switch (cityPairsResult) {
        case ApiSuccess(data: final cityPairs):
          final cityPairsMap = Map<int, CityPairDetailResponse>.fromEntries(
            cityPairs.pairs
                    ?.where((value) => value.endCityId != null)
                    .map((value) => MapEntry(value.endCityId!, value)) ??
                [],
          );

          if (cityPairsMap.isEmpty) {
            return;
          }

          // Filter city pairs to only include cities on the
          // current route (starting point forward, with
          // maxEndCity limit).
          var validCities = routeCities;
          final startIdx = routeCities.indexWhere(
            (c) => c.id == selectedStartingPoint.id,
          );
          if (startIdx != -1) {
            validCities = routeCities.sublist(startIdx);
          }
          if (maxEndCity != null) {
            final maxIdx = validCities.indexWhere(
              (c) => c.id == maxEndCity!.id,
            );
            if (maxIdx != -1) {
              validCities =
                  validCities.sublist(0, maxIdx + 1);
            }
          }
          final validCityIds =
              validCities.map((c) => c.id).toSet();
          cityPairsMap.removeWhere(
            (key, _) => !validCityIds.contains(key),
          );
          if (cityPairsMap.isEmpty) {
            return;
          }

          final cityPairRanks = _cityPairRanksFromPairs(cityPairsMap);

          safeEmit(
            state.copyWith(
              cityPairs: cityPairsMap,
              cityPairRanks: cityPairRanks,
            ),
          );
        case ApiFailure(message: final message):
          AppLogger.e(
            'Error getting city pairs',
            tag: 'SelectDestinationCubit',
            error: message,
          );
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error getting city pairs',
        tag: 'SelectDestinationCubit',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _cityPairsLoaded = true;
    }
  }

  Future<void> filterDestinations({
    String? query,
    bool isInitial = true,
  }) async {
    if (isInitial) {
      safeEmit(state.copyWith(initStatus: SelectDestinationInitStatus.loading));
    } else {
      safeEmit(
        state.copyWith(
          filteringStatus: SelectDestinationFilteringStatus.loading,
        ),
      );
    }

    try {
      final cities =
          await _repository.getCitiesByRouteIdFromDb(selectedRoute.id);

      if (isInitial && !_cityPairsLoaded) {
        await _loadCityPairs(cities);
      }

      _analyticsServices.track(
        FilterDestinationsEvent(
          routeId: selectedRoute.id,
          startingPointId: selectedStartingPoint.id,
          cityFilter: state.cityFilter.name,
          cityCount: cities.length,
        ),
      );

      var filteredDestinations = cities;
      final startingCityIndex = cities.indexWhere(
        (c) => c.id == selectedStartingPoint.id,
      );

      if (startingCityIndex != -1) {
        filteredDestinations = cities.sublist(startingCityIndex);
      }

      // Limit to maxEndCity if set (inclusive)
      if (maxEndCity != null) {
        final maxIndex = filteredDestinations.indexWhere(
          (c) => c.id == maxEndCity!.id,
        );
        if (maxIndex != -1) {
          filteredDestinations =
              filteredDestinations.sublist(0, maxIndex + 1);
        }
      }

      if (state.cityFilter == CityFilter.accommodation) {
        filteredDestinations = filteredDestinations
            .where((city) => city.hasAlbergues ?? false)
            .toList();
      }

      final routePoints = await _repository.getRoutePointsByRouteIdFromDb(
        routeId: selectedRoute.id,
      );

      // Always make sure that the starting city is the first item in the list
      // to make calculation distance correctly
      final isStartingCityExists =
          filteredDestinations.any((e) => e.id == selectedStartingPoint.id);

      if (!isStartingCityExists) {
        filteredDestinations.insert(0, selectedStartingPoint);
      }

      var destinationData = await calculateCityDistances(
        filteredDestinations,
        routePoints,
        _databaseHelper,
      );

      _analyticsServices.track(
        FilterDestinationsFilteredEvent(
          routeId: selectedRoute.id,
          startingPointId: selectedStartingPoint.id,
          cityFilter: state.cityFilter.name,
          cityCount: destinationData.length,
        ),
      );

      final actualQuery = query ?? state.query;
      // Filter the destinations by query if it's not empty
      if (actualQuery != null && actualQuery.trim().isNotEmpty) {
        destinationData = destinationData.where((city) {
          final searchLower = actualQuery.toLowerCase();
          return city.name.normalize()?.toLowerCase().contains(searchLower) ??
              false;
        }).toList();
      }

      // Remove the starting city from the destination data
      final outputList = destinationData
          .where((e) => e.id != selectedStartingPoint.id)
          .toList();

      safeEmit(
        state.copyWith(
          destinationData: outputList,
          cityFilter: state.cityFilter,
          query: actualQuery,
          selectedDestination: selectedDestination,
        ),
      );

      if (isInitial) {
        safeEmit(
          state.copyWith(initStatus: SelectDestinationInitStatus.success),
        );
      } else {
        safeEmit(
          state.copyWith(
            filteringStatus: SelectDestinationFilteringStatus.success,
          ),
        );
      }

      if (!triggerAutoScroll) {
        final nearestCityIndex = outputList.indexWhere(
          (city) => city.id == selectedDestination?.id,
        );
        if (nearestCityIndex != -1) {
          Future.delayed(const Duration(milliseconds: 100), () {
            safeEmit(state.copyWith(nearestCityIndex: nearestCityIndex));
          });
          triggerAutoScroll = true;
        }
      }
    } catch (e) {
      // Reset loading state to prevent infinite spinner
      if (isInitial) {
        safeEmit(
          state.copyWith(initStatus: SelectDestinationInitStatus.success),
        );
      } else {
        safeEmit(
          state.copyWith(
            filteringStatus: SelectDestinationFilteringStatus.success,
          ),
        );
      }
    }
  }

  Future<void> changeCityFilter(CityFilter filter) async {
    safeEmit(state.copyWith(cityFilter: filter));
    await filterDestinations(isInitial: false);
  }

  Future<List<CityEntity>> asyncFilter(
    List<CityEntity> items,
    Future<bool> Function(CityEntity) asyncTest,
  ) async {
    final futures = items.map(asyncTest).toList();
    final results = await Future.wait(futures);
    return [
      for (int i = 0; i < items.length; i++)
        if (results[i]) items[i],
    ];
  }

  double? getPercentage(int endCityId) {
    final percent = state.cityPairs[endCityId]?.percentage ?? 0;
    if (percent < kMinPercentageForRanking) return null;
    return percent;
  }

  CityPairRank? cityPairRankFor(int endCityId) =>
      state.cityPairRanks[endCityId];
}

class CityDistance extends Equatable {
  const CityDistance({
    required this.city,
    required this.distanceFromPrevious,
    required this.cumulativeDistance,
  });
  final CityResponse city;
  final double distanceFromPrevious;
  final double cumulativeDistance;

  @override
  List<Object> get props => [
        distanceFromPrevious,
        cumulativeDistance,
      ];
}
