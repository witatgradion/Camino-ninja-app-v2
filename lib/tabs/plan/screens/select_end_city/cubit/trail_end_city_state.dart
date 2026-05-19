part of 'trail_end_city_cubit.dart';

enum TrailEndCityStatus {
  initial,
  loading,
  success,
  failure,
}

/// A group of destinations belonging to one trail segment.
class SegmentDestinationGroup extends Equatable {
  const SegmentDestinationGroup({
    required this.segment,
    required this.destinations,
  });

  final TrailSegment segment;
  final List<Destination> destinations;

  @override
  List<Object?> get props => [segment, destinations];
}

class TrailEndCityState extends Equatable {
  const TrailEndCityState({
    this.status = TrailEndCityStatus.initial,
    this.destinationData = const [],
    this.filteredData = const [],
    this.groups = const [],
    this.filteredGroups = const [],
    this.selectedCity,
    this.cityFilter = CityFilter.accommodation,
    this.query = '',
    this.segmentRouteName,
  });

  final TrailEndCityStatus status;
  final List<Destination> destinationData;
  final List<Destination> filteredData;
  final List<SegmentDestinationGroup> groups;
  final List<SegmentDestinationGroup> filteredGroups;
  final CityEntity? selectedCity;
  final CityFilter cityFilter;
  final String query;

  /// Name of the segment route for display in the header.
  final String? segmentRouteName;

  TrailEndCityState copyWith({
    TrailEndCityStatus? status,
    List<Destination>? destinationData,
    List<Destination>? filteredData,
    List<SegmentDestinationGroup>? groups,
    List<SegmentDestinationGroup>? filteredGroups,
    CityEntity? selectedCity,
    CityFilter? cityFilter,
    String? query,
    String? segmentRouteName,
  }) {
    return TrailEndCityState(
      status: status ?? this.status,
      destinationData:
          destinationData ?? this.destinationData,
      filteredData: filteredData ?? this.filteredData,
      groups: groups ?? this.groups,
      filteredGroups:
          filteredGroups ?? this.filteredGroups,
      selectedCity: selectedCity ?? this.selectedCity,
      cityFilter: cityFilter ?? this.cityFilter,
      query: query ?? this.query,
      segmentRouteName:
          segmentRouteName ?? this.segmentRouteName,
    );
  }

  @override
  List<Object?> get props => [
        status,
        destinationData,
        filteredData,
        groups,
        filteredGroups,
        selectedCity,
        cityFilter,
        query,
        segmentRouteName,
      ];
}
