part of 'select_destination_cubit.dart';

enum SelectDestinationInitStatus {
  initial,
  loading,
  success,
}

enum SelectDestinationFilteringStatus {
  initial,
  loading,
  success,
}

enum CityPairRank {
  mostPopular,
  secondMostPopular,
  thirdMostPopular;

  String name(BuildContext context) => switch (this) {
        CityPairRank.mostPopular => AppLocalizations.of(context).mostPopular,
        CityPairRank.secondMostPopular =>
          AppLocalizations.of(context).secondMostPopular,
        CityPairRank.thirdMostPopular =>
          AppLocalizations.of(context).thirdMostPopular,
      };

  Color bgColor(BuildContext context) => switch (this) {
        CityPairRank.mostPopular => const Color(0xFFE6C252),
        CityPairRank.secondMostPopular => const Color(0xFFD1DAE2),
        CityPairRank.thirdMostPopular => const Color(0xFFB8987E),
      };
}

class SelectDestinationState extends Equatable {
  const SelectDestinationState({
    this.destinationData = const [],
    this.cityPairs = const {},
    this.cityPairRanks = const {},
    this.cityFilter = CityFilter.accommodation,
    this.query,
    this.selectedDestination,
    this.nearestCityIndex,
    this.filteringStatus = SelectDestinationFilteringStatus.initial,
    this.initStatus = SelectDestinationInitStatus.initial,
    this.startCityName,
  });

  final List<Destination> destinationData;
  final CityFilter cityFilter;
  final String? query;
  final CityEntity? selectedDestination;
  final int? nearestCityIndex;
  final SelectDestinationFilteringStatus filteringStatus;
  final SelectDestinationInitStatus initStatus;
  final Map<int, CityPairDetailResponse> cityPairs;

  /// End city id → medal tier. Same [CityPairRank] when rounded % matches that tier.
  final Map<int, CityPairRank> cityPairRanks;
  final String? startCityName;

  SelectDestinationState copyWith({
    List<Destination>? destinationData,
    CityFilter? cityFilter,
    String? query,
    CityEntity? selectedDestination,
    int? nearestCityIndex,
    SelectDestinationFilteringStatus? filteringStatus,
    SelectDestinationInitStatus? initStatus,
    Map<int, CityPairDetailResponse>? cityPairs,
    Map<int, CityPairRank>? cityPairRanks,
    String? startCityName,
  }) {
    return SelectDestinationState(
      destinationData: destinationData ?? this.destinationData,
      cityFilter: cityFilter ?? this.cityFilter,
      query: query ?? this.query,
      selectedDestination: selectedDestination ?? this.selectedDestination,
      nearestCityIndex: nearestCityIndex ?? this.nearestCityIndex,
      filteringStatus: filteringStatus ?? this.filteringStatus,
      initStatus: initStatus ?? this.initStatus,
      cityPairs: cityPairs ?? this.cityPairs,
      cityPairRanks: cityPairRanks ?? this.cityPairRanks,
      startCityName: startCityName ?? this.startCityName,
    );
  }

  @override
  List<Object?> get props => [
        destinationData,
        cityFilter,
        query,
        selectedDestination,
        nearestCityIndex,
        filteringStatus,
        initStatus,
        cityPairs,
        cityPairRanks,
        startCityName,
      ];
}

enum CityFilter {
  accommodation('Cities with accommodation'),
  all('All cities');

  final String name;

  const CityFilter(this.name);
}
