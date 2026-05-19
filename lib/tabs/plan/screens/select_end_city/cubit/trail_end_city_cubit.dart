import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_destination/cubit/select_destination_cubit.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'trail_end_city_state.dart';

/// Cubit for the end-city picker when a multi-route trail
/// is active. Loads cities that come AFTER the start city
/// in trail order — both from the current segment and all
/// subsequent segments, enabling cross-route stages.
class TrailEndCityCubit extends Cubit<TrailEndCityState>
    with SafeEmitMixin {
  TrailEndCityCubit({
    required this.trail,
    required this.startCity,
    this.selectedCity,
    this.maxEndCity,
  }) : super(
          TrailEndCityState(selectedCity: selectedCity),
        );

  final MultiRouteTrail trail;
  final CityEntity startCity;
  final CityEntity? selectedCity;

  /// Upper bound (inclusive) — cities after this in the
  /// trail are excluded.
  final CityEntity? maxEndCity;

  final _repository = GetIt.instance<Repository>();
  final _database = GetIt.instance<AppDatabase>();

  Future<void> loadCities() async {
    safeEmit(
      state.copyWith(status: TrailEndCityStatus.loading),
    );

    try {
      // Find the first segment containing the start city.
      int? startSegmentIndex;
      for (var i = 0; i < trail.segments.length; i++) {
        if (trail.segments[i].cityIds.contains(
          startCity.id,
        )) {
          startSegmentIndex = i;
          break;
        }
      }

      if (startSegmentIndex == null) {
        safeEmit(
          state.copyWith(
            status: TrailEndCityStatus.success,
          ),
        );
        return;
      }

      // Resolve upper bound index in flat trail order.
      final maxIdx = maxEndCity != null
          ? trail.cityIndexInTrail(maxEndCity!.id)
          : null;

      final segment = trail.segments[startSegmentIndex];

      final allCities =
          await _repository.getCitiesByRouteIdFromDb(
        segment.routeId,
      );

      // Find the start city's position within the segment
      // city IDs and keep only cities that come after it.
      final segmentCityIds = segment.cityIds;
      final startIndex =
          segmentCityIds.indexOf(startCity.id);

      // Cities after the start city in this segment
      // (inclusive of junction/last city).
      final validCityIds = startIndex >= 0
          ? segmentCityIds.sublist(startIndex).toSet()
          : segmentCityIds.toSet();

      // Filter all DB cities to only the valid ones,
      // preserving DB order. Insert startCity at front
      // if needed for distance calculation.
      final filteredCities = <CityEntity>[];
      var startCityIncluded = false;
      for (final city in allCities) {
        if (validCityIds.contains(city.id)) {
          // Apply upper bound using trail position.
          if (maxIdx != null) {
            final cityIdx =
                trail.cityIndexInTrail(city.id);
            if (cityIdx != null && cityIdx > maxIdx) {
              continue;
            }
          }
          filteredCities.add(city);
          if (city.id == startCity.id) {
            startCityIncluded = true;
          }
        }
      }
      if (!startCityIncluded) {
        filteredCities.insert(0, startCity);
      }

      // Collect per-segment city lists for grouping.
      final segmentCityLists = <(TrailSegment, List<CityEntity>)>[
        (segment, filteredCities),
      ];

      // Load cities from subsequent trail segments
      // (cross-route stages).
      for (var i = startSegmentIndex + 1;
          i < trail.segments.length;
          i++) {
        // If the upper bound was already exceeded in a
        // previous segment, skip remaining segments.
        if (maxIdx != null) {
          final firstCityIdx =
              trail.cityIndexInTrail(
            trail.segments[i].cityIds.first,
          );
          if (firstCityIdx != null &&
              firstCityIdx > maxIdx) {
            break;
          }
        }

        final nextSegment = trail.segments[i];
        final nextCities =
            await _repository.getCitiesByRouteIdFromDb(
          nextSegment.routeId,
        );

        final nextSegmentCityIds =
            nextSegment.cityIds.toSet();
        var nextFilteredCities = nextCities
            .where(
              (c) => nextSegmentCityIds.contains(c.id),
            )
            .toList();

        // Skip the junction city — it is already included
        // as the last city of the previous segment.
        final junctionCityId =
            nextSegment.junctionCityId ??
                nextSegment.cityIds.first;
        nextFilteredCities
            .removeWhere((c) => c.id == junctionCityId);

        // Apply upper bound.
        if (maxIdx != null) {
          nextFilteredCities = nextFilteredCities
              .where((c) {
            final idx = trail.cityIndexInTrail(c.id);
            return idx == null || idx <= maxIdx;
          }).toList();
        }

        segmentCityLists
            .add((nextSegment, nextFilteredCities));
      }

      // Load route points from all involved segments
      // for distance calculation.
      final routePoints =
          await _repository.getRoutePointsByRouteIdFromDb(
        routeId: segment.routeId,
      );

      final allRoutePoints = <RoutePointEntity>[
        ...routePoints,
      ];
      for (var i = startSegmentIndex + 1;
          i < trail.segments.length;
          i++) {
        final nextPoints = await _repository
            .getRoutePointsByRouteIdFromDb(
          routeId: trail.segments[i].routeId,
        );
        allRoutePoints.addAll(nextPoints);
      }

      // Build grouped destinations per segment.
      final groups = <SegmentDestinationGroup>[];
      final allOutputList = <Destination>[];

      for (final (seg, cities) in segmentCityLists) {
        // Apply accommodation filter
        var citiesToProcess = cities;
        if (state.cityFilter ==
            CityFilter.accommodation) {
          citiesToProcess = cities
              .where(
                (city) =>
                    (city.hasAlbergues ?? false) ||
                    city.id == startCity.id,
              )
              .toList();
        }

        final destinations =
            await calculateCityDistances(
          citiesToProcess,
          allRoutePoints,
          _database,
        );

        // Remove start city from output
        final segmentOutput = destinations
            .where((d) => d.id != startCity.id)
            .toList();

        if (segmentOutput.isNotEmpty) {
          groups.add(
            SegmentDestinationGroup(
              segment: seg,
              destinations: segmentOutput,
            ),
          );
          allOutputList.addAll(segmentOutput);
        }
      }

      safeEmit(
        state.copyWith(
          status: TrailEndCityStatus.success,
          destinationData: allOutputList,
          filteredData: allOutputList,
          groups: groups,
          filteredGroups: groups,
          segmentRouteName: segment.routeName,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          status: TrailEndCityStatus.failure,
        ),
      );
    }
  }

  Future<void> changeCityFilter(CityFilter filter) async {
    safeEmit(state.copyWith(cityFilter: filter));
    await loadCities();
  }

  void searchCities(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      safeEmit(
        state.copyWith(
          filteredData: state.destinationData,
          filteredGroups: state.groups,
          query: '',
        ),
      );
      return;
    }

    final searchLower = trimmed.toLowerCase();

    bool matchesQuery(Destination d) {
      return d.name
              .normalize()
              ?.toLowerCase()
              .contains(searchLower) ??
          false;
    }

    final filtered =
        state.destinationData.where(matchesQuery).toList();

    final filteredGroups = <SegmentDestinationGroup>[];
    for (final group in state.groups) {
      final matchingDests = group.destinations
          .where(matchesQuery)
          .toList();
      if (matchingDests.isNotEmpty) {
        filteredGroups.add(
          SegmentDestinationGroup(
            segment: group.segment,
            destinations: matchingDests,
          ),
        );
      }
    }

    safeEmit(
      state.copyWith(
        filteredData: filtered,
        filteredGroups: filteredGroups,
        query: trimmed,
      ),
    );
  }
}
