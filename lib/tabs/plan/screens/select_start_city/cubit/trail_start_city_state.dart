part of 'trail_start_city_cubit.dart';

enum TrailStartCityStatus {
  initial,
  loading,
  success,
  failure,
}

/// A group of cities belonging to one trail segment.
class SegmentCityGroup extends Equatable {
  const SegmentCityGroup({
    required this.segment,
    required this.cities,
  });

  final TrailSegment segment;
  final List<CityEntity> cities;

  @override
  List<Object?> get props => [segment, cities];
}

class TrailStartCityState extends Equatable {
  const TrailStartCityState({
    this.status = TrailStartCityStatus.initial,
    this.groups = const [],
    this.filteredGroups = const [],
    this.selectedCity,
    this.query = '',
  });

  final TrailStartCityStatus status;
  final List<SegmentCityGroup> groups;
  final List<SegmentCityGroup> filteredGroups;
  final CityEntity? selectedCity;
  final String query;

  /// Flat list of all cities across filtered groups for
  /// item count and indexing.
  int get totalItemCount {
    var count = 0;
    for (final group in filteredGroups) {
      count += 1 + group.cities.length; // header + cities
    }
    return count;
  }

  TrailStartCityState copyWith({
    TrailStartCityStatus? status,
    List<SegmentCityGroup>? groups,
    List<SegmentCityGroup>? filteredGroups,
    CityEntity? selectedCity,
    String? query,
  }) {
    return TrailStartCityState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      filteredGroups: filteredGroups ?? this.filteredGroups,
      selectedCity: selectedCity ?? this.selectedCity,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [
        status,
        groups,
        filteredGroups,
        selectedCity,
        query,
      ];
}
