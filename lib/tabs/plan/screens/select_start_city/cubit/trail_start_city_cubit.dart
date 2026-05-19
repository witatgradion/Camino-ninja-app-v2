import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'trail_start_city_state.dart';

/// Cubit that loads cities for every segment in a
/// [MultiRouteTrail], grouped by segment, with search
/// filtering. Used by the stage start-city picker when
/// a multi-route trail is active.
class TrailStartCityCubit extends Cubit<TrailStartCityState>
    with SafeEmitMixin {
  TrailStartCityCubit({
    required this.trail,
    this.selectedCity,
    this.minCity,
    this.maxCity,
  }) : super(
          TrailStartCityState(selectedCity: selectedCity),
        );

  final MultiRouteTrail trail;
  final CityEntity? selectedCity;

  /// Lower bound (inclusive) — cities before this in the
  /// trail are excluded.
  final CityEntity? minCity;

  /// Upper bound (inclusive) — cities after this in the
  /// trail are excluded.
  final CityEntity? maxCity;

  final _repository = GetIt.instance<Repository>();

  Future<void> loadCities() async {
    safeEmit(
      state.copyWith(status: TrailStartCityStatus.loading),
    );

    try {
      final groups = <SegmentCityGroup>[];
      final seenCityIds = <int>{};

      // Resolve bound indices in the flat trail order.
      final minIdx = minCity != null
          ? trail.cityIndexInTrail(minCity!.id)
          : null;
      final maxIdx = maxCity != null
          ? trail.cityIndexInTrail(maxCity!.id)
          : null;

      for (final segment in trail.segments) {
        final allCities =
            await _repository.getCitiesByRouteIdFromDb(
          segment.routeId,
        );

        // Filter to only the city IDs in this segment,
        // preserving DB order, and deduplicate junction
        // cities at segment boundaries.
        final segmentCityIdSet = segment.cityIds.toSet();
        final segmentCities = <CityEntity>[];
        for (final city in allCities) {
          if (segmentCityIdSet.contains(city.id) &&
              !seenCityIds.contains(city.id)) {
            // Apply min/max bounds using trail position.
            final cityIdx =
                trail.cityIndexInTrail(city.id);
            if (cityIdx == null) continue;
            if (minIdx != null && cityIdx < minIdx) {
              continue;
            }
            if (maxIdx != null && cityIdx > maxIdx) {
              continue;
            }

            segmentCities.add(city);
            seenCityIds.add(city.id);
          }
        }

        if (segmentCities.isNotEmpty) {
          groups.add(
            SegmentCityGroup(
              segment: segment,
              cities: segmentCities,
            ),
          );
        }
      }

      safeEmit(
        state.copyWith(
          status: TrailStartCityStatus.success,
          groups: groups,
          filteredGroups: groups,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          status: TrailStartCityStatus.failure,
        ),
      );
    }
  }

  void searchCities(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      safeEmit(
        state.copyWith(
          filteredGroups: state.groups,
          query: '',
        ),
      );
      return;
    }

    final searchLower = trimmed.toLowerCase();
    final filtered = <SegmentCityGroup>[];
    for (final group in state.groups) {
      final matchingCities = group.cities.where((city) {
        return city.name
                .normalize()
                ?.toLowerCase()
                .contains(searchLower) ??
            false;
      }).toList();

      if (matchingCities.isNotEmpty) {
        filtered.add(
          SegmentCityGroup(
            segment: group.segment,
            cities: matchingCities,
          ),
        );
      }
    }

    safeEmit(
      state.copyWith(
        filteredGroups: filtered,
        query: trimmed,
      ),
    );
  }
}
